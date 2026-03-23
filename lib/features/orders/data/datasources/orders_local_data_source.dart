import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/features/orders/data/models/order_history_model.dart';

abstract class OrdersLocalDataSource {
  Future<List<OrderHistoryModel>> getOrdersHistory();
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final DatabaseHelper databaseHelper;

  OrdersLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<OrderHistoryModel>> getOrdersHistory() async {
    final db = await databaseHelper.database;
    
    // جلب الطلبات من الأحدث للأقدم
    final List<Map<String, dynamic>> ordersMap = await db.query(
      'orders',
      orderBy: 'id DESC',
    );

    List<OrderHistoryModel> orders = [];

    for (var order in ordersMap) {
      final orderId = order['id'];
      
      // جلب عناصر الطلب مع أسماء الأصناف من جدول items
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
}