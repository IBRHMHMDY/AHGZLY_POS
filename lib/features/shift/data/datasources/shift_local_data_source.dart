import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/features/shift/data/models/shift_report_model.dart';

abstract class ShiftLocalDataSource {
  Future<ShiftReportModel> getZReport();
  Future<int> closeShift(ShiftReportModel report);
}

class ShiftLocalDataSourceImpl implements ShiftLocalDataSource {
  final DatabaseHelper databaseHelper;

  ShiftLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<ShiftReportModel> getZReport() async {
    final db = await databaseHelper.database;

    // 1. إيجاد وقت آخر وردية مغلقة (وإذا لم يكن هناك، نعتبر البداية من الصفر)
    final lastShiftResult = await db.rawQuery(
      "SELECT end_time FROM shifts WHERE status = 'closed' ORDER BY id DESC LIMIT 1"
    );
    
    String lastEndTime = "1970-01-01T00:00:00.000";
    if (lastShiftResult.isNotEmpty) {
      lastEndTime = lastShiftResult.first['end_time'] as String;
    }

    // 2. تجميع المبيعات من جدول الطلبات (orders) التي تمت بعد وقت الإغلاق الأخير
    final ordersResult = await db.rawQuery('''
      SELECT 
        COUNT(id) as total_orders,
        SUM(total) as total_sales,
        SUM(CASE WHEN payment_method = 'كاش' THEN total ELSE 0 END) as total_cash,
        SUM(CASE WHEN payment_method = 'فيزا' THEN total ELSE 0 END) as total_visa,
        SUM(CASE WHEN payment_method = 'InstaPay' THEN total ELSE 0 END) as total_instapay,
        MIN(created_at) as first_order_time
      FROM orders 
      WHERE created_at > ? AND status = 'مكتمل'
    ''', [lastEndTime]);

    final data = ordersResult.first;

    // معالجة القيم في حال لم تكن هناك طلبات (Null values)
    final int totalOrders = (data['total_orders'] as int?) ?? 0;
    final double totalSales = (data['total_sales'] as num?)?.toDouble() ?? 0.0;
    final double totalCash = (data['total_cash'] as num?)?.toDouble() ?? 0.0;
    final double totalVisa = (data['total_visa'] as num?)?.toDouble() ?? 0.0;
    final double totalInstaPay = (data['total_instapay'] as num?)?.toDouble() ?? 0.0;
    
    // إذا كان هناك طلبات نأخذ وقت أول طلب كبداية للوردية، وإلا نأخذ وقت آخر إغلاق
    final String startTime = (data['first_order_time'] as String?) ?? lastEndTime;
    final String endTime = DateTime.now().toIso8601String();

    return ShiftReportModel(
      startTime: startTime,
      endTime: endTime,
      totalCash: totalCash,
      totalVisa: totalVisa,
      totalInstaPay: totalInstaPay,
      totalSales: totalSales,
      totalOrders: totalOrders,
    );
  }

  @override
  Future<int> closeShift(ShiftReportModel report) async {
    final db = await databaseHelper.database;
    
    // نظراً لأن قاعدة البيانات (shifts) صممناها في البداية بـ total_visa و total_cash فقط
    // سنقوم بجمع InstaPay مع الـ Visa في قاعدة البيانات باعتبارها مدفوعات إلكترونية، 
    // ولكننا نعرضها مفصلة في واجهة الـ Z-Report
    
    final Map<String, dynamic> shiftData = {
      'start_time': report.startTime,
      'end_time': report.endTime,
      'total_cash': report.totalCash,
      'total_visa': report.totalVisa + report.totalInstaPay, // دمج المدفوعات غير النقدية
      'total_sales': report.totalSales,
      'status': 'closed',
    };

    return await db.insert('shifts', shiftData);
  }
}