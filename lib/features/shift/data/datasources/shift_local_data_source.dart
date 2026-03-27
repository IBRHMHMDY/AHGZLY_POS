import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/shift/data/models/shift_model.dart';

abstract class ShiftLocalDataSource {
  Future<ShiftModel?> getActiveShift();
  Future<ShiftModel> openShift({required double startingCash, required int cashierId});
  Future<ShiftModel> closeShift({required int shiftId, required double actualCash});
}

class ShiftLocalDataSourceImpl implements ShiftLocalDataSource {
  final DatabaseHelper databaseHelper;

  ShiftLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<ShiftModel?> getActiveShift() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shifts',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ShiftModel.fromMap(maps.first);
    }
    return null; // لا توجد وردية مفتوحة
  }

@override
  Future<ShiftModel> openShift({required double startingCash, required int cashierId}) async {
    final db = await databaseHelper.database;
    final activeShift = await getActiveShift();
    if (activeShift != null) throw CacheException(message: 'يوجد وردية مفتوحة بالفعل. يجب إغلاقها أولاً.');

    final now = DateTime.now().toIso8601String();
    final id = await db.insert('shifts', {
      'cashier_id': cashierId,
      'start_time': now,
      'starting_cash': startingCash,
      'status': 'active',
      'total_sales': 0.0,
      'total_cash': 0.0,
      'total_visa': 0.0,
      'total_instapay': 0.0, // تمت الإضافة
      'total_orders': 0,     // تمت الإضافة
      'total_expenses': 0.0,
      'expected_cash': startingCash,
      'actual_cash': 0.0,
    });

    return ShiftModel(
      id: id,
      cashierId: cashierId,
      startTime: DateTime.now(),
      startingCash: startingCash,
      totalSales: 0.0,
      totalCash: 0.0,
      totalVisa: 0.0,
      totalInstapay: 0.0, // تمت الإضافة
      totalOrders: 0,     // تمت الإضافة
      totalExpenses: 0.0,
      expectedCash: startingCash,
      actualCash: 0.0,
      status: 'active',
    );
  }

  @override
  Future<ShiftModel> closeShift({required int shiftId, required double actualCash}) async {
    final db = await databaseHelper.database;
    final shiftMaps = await db.query('shifts', where: 'id = ? AND status = ?', whereArgs: [shiftId, 'active']);
    if (shiftMaps.isEmpty) throw CacheException(message: 'لم يتم العثور على وردية نشطة لإغلاقها.');
    final shift = ShiftModel.fromMap(shiftMaps.first);

    final orders = await db.query(
      'orders',
      where: 'created_at >= ? AND status != ?',
      whereArgs: [shift.startTime.toIso8601String(), 'مرتجع'], 
    );

    double totalCash = 0;
    double totalVisa = 0;
    double totalInstapay = 0; // تمت الإضافة
    int totalOrders = orders.length; // تمت الإضافة (عدد الطلبات)
    
    for (var order in orders) {
      final total = (order['total'] as num).toDouble();
      final paymentMethod = order['payment_method'].toString().toLowerCase();
      
      if (paymentMethod == 'cash' || paymentMethod == 'كاش') {
        totalCash += total;
      } else if (paymentMethod == 'visa' || paymentMethod == 'فيزا') {
        totalVisa += total;
      } else if (paymentMethod == 'instapay' || paymentMethod == 'إنستاباي' || paymentMethod == 'انستاباي') {
        totalInstapay += total; // حساب إنستا باي
      }
    }
    // إجمالي المبيعات يشمل الكاش والفيزا وإنستا باي
    final totalSales = totalCash + totalVisa + totalInstapay;

    final expenses = await db.query(
      'expenses',
      where: 'created_at >= ?',
      whereArgs: [shift.startTime.toIso8601String()],
    );
    double totalExpenses = 0;
    for (var exp in expenses) {
      totalExpenses += (exp['amount'] as num).toDouble();
    }

    // ملاحظة محاسبية هامة: الكاش المتوقع في الدرج يتأثر فقط بالكاش الملموس (totalCash) وليس الفيزا أو إنستاباي
    final expectedCash = shift.startingCash + totalCash - totalExpenses;

    final now = DateTime.now().toIso8601String();
    
    await db.update(
      'shifts',
      {
        'end_time': now,
        'total_sales': totalSales,
        'total_cash': totalCash,
        'total_visa': totalVisa,
        'total_instapay': totalInstapay, // تحديث
        'total_orders': totalOrders,     // تحديث
        'total_expenses': totalExpenses,
        'expected_cash': expectedCash,
        'actual_cash': actualCash, 
        'status': 'closed',
      },
      where: 'id = ?',
      whereArgs: [shiftId],
    );

    final updatedShiftMaps = await db.query('shifts', where: 'id = ?', whereArgs: [shiftId]);
    return ShiftModel.fromMap(updatedShiftMaps.first);
  }
}