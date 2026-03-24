import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/features/shift/data/models/shift_report_model.dart';

abstract class ShiftLocalDataSource {
  Future<ShiftReportModel> getZReport();
  Future<int> closeShift(ShiftReportModel report); // تعديل إلى int
}

class ShiftLocalDataSourceImpl implements ShiftLocalDataSource {
  final DatabaseHelper databaseHelper;

  ShiftLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<ShiftReportModel> getZReport() async {
    final db = await databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        SUM(total) as total_sales,
        SUM(CASE WHEN payment_method = 'كاش' THEN total ELSE 0 END) as total_cash,
        SUM(CASE WHEN payment_method = 'فيزا' THEN total ELSE 0 END) as total_visa,
        SUM(CASE WHEN payment_method = 'InstaPay' THEN total ELSE 0 END) as total_instapay,
        COUNT(id) as total_orders
      FROM orders
      WHERE date(created_at) = date('now', 'localtime') AND status != 'مرتجع'
    ''');

    final expensesResult = await db.rawQuery('''
      SELECT SUM(amount) as total_expenses 
      FROM expenses 
      WHERE date(created_at) = date('now', 'localtime')
    ''');

    final row = result.first;
    final expRow = expensesResult.first;

    return ShiftReportModel.fromMap({
      'total_sales': row['total_sales'],
      'total_cash': row['total_cash'],
      'total_visa': row['total_visa'],
      'total_instapay': row['total_instapay'],
      'total_orders': row['total_orders'],
      'total_expenses': expRow['total_expenses'],
    });
  }

  @override
  Future<int> closeShift(ShiftReportModel report) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().toIso8601String();
    
    // إرجاع رقم الوردية المغلقة ID
    return await db.insert('shifts', {
      'start_time': now, 
      'end_time': now,
      'total_cash': report.totalCash - report.totalExpenses, 
      'total_visa': report.totalVisa,
      'total_sales': report.totalSales,
      'status': 'closed'
    });
  }
}