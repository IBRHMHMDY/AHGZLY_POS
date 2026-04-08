import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart'; // [Refactoring Specialist]: ضروري لالتقاط الأخطاء
import 'package:ahgzly_pos/features/orders/data/models/order_history_model.dart';

abstract class OrdersLocalDataSource {
  Future<List<OrderHistoryModel>> getOrdersHistory({required bool isAdmin, required int? shiftId});
  Future<void> refundOrder(int orderId); 
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final DatabaseHelper databaseHelper;
  OrdersLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<OrderHistoryModel>> getOrdersHistory({required bool isAdmin, required int? shiftId}) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> ordersMap;
    List<OrderHistoryModel> orders = [];
    if(isAdmin){
      ordersMap = await db.query('orders', orderBy: 'id DESC');
    }else{
      if (shiftId == null) return [];
      ordersMap = await db.query(
        'orders', 
        where: 'shift_id = ?', 
        whereArgs: [shiftId], 
        orderBy: 'id DESC'
      );
    }
    for (var order in ordersMap) {
      final orderId = order['id'];
      final List<Map<String, dynamic>> itemsMap = await db.rawQuery('''
        SELECT oi.quantity, oi.unit_price, i.name as item_name
        FROM order_items oi
        JOIN items i ON oi.item_id = i.id
        WHERE oi.order_id = ?
      ''', [orderId]);
      final items = itemsMap.map((item) => OrderHistoryItemModel.fromMap(item)).toList();
      orders.add(OrderHistoryModel.fromMap(order, items));
    }
    return orders;
  }

  @override
  Future<void> refundOrder(int orderId) async {
    final db = await databaseHelper.database;
    
    try {
      // [Refactoring Specialist]: استخدام Transaction لضمان تزامن المرتجع مع الوردية
      await db.transaction((txn) async {
        // 1. جلب الفاتورة لمعرفة قيمتها وطريقة الدفع والوردية التابعة لها
        final orderResult = await txn.query(
          'orders',
          where: 'id = ?',
          whereArgs: [orderId],
        );
        
        if (orderResult.isEmpty) {
          throw CacheException(message: 'لم يتم العثور على الفاتورة.');
        }

        final order = orderResult.first;
        final String status = order['status'] as String;
        
        if (status == 'مرتجع') {
          throw CacheException(message: 'هذه الفاتورة مسترجعة بالفعل.');
        }

        final int total = (order['total'] as num).toInt();
        final String paymentMethod = order['payment_method'].toString().toLowerCase();
        final int shiftId = (order['shift_id'] as num).toInt();

        // 2. تحديث حالة الفاتورة إلى مرتجع
        await txn.update(
          'orders', 
          {'status': 'مرتجع'}, 
          where: 'id = ?', 
          whereArgs: [orderId],
        );

        // 3. تحديث إحصائيات الوردية لحظياً (Live Update) لتعكس التقرير اللحظي Z/X Report
        String paymentColumn = 'total_cash';
        if (paymentMethod == 'visa' || paymentMethod == 'فيزا') paymentColumn = 'total_visa';
        if (paymentMethod == 'instapay' || paymentMethod == 'إنستاباي' || paymentMethod == 'انستاباي') paymentColumn = 'total_instapay';

        await txn.rawUpdate('''
          UPDATE shifts 
          SET total_sales = total_sales - ?, 
              $paymentColumn = $paymentColumn - ?, 
              expected_cash = expected_cash - ?, 
              total_refunds = total_refunds + ?,
              refunded_orders_count = refunded_orders_count + 1,
              total_orders = total_orders - 1
          WHERE id = ? AND status = 'active'
        ''', [
          total, 
          total, 
          (paymentColumn == 'total_cash' ? total : 0), // نخصم المرتجع من الدرج المتوقع فقط إذا كان كاش
          total,
          shiftId
        ]);
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'حدث خطأ أثناء إتمام عملية المرتجع: ${e.toString()}');
    }
  }
}