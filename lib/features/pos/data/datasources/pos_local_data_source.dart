import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_item_model.dart';

abstract class PosLocalDataSource {
  Future<int> saveOrder(OrderModel order);
}

class PosLocalDataSourceImpl implements PosLocalDataSource {
  final DatabaseHelper databaseHelper;

  PosLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<int> saveOrder(OrderModel order) async {
    final db = await databaseHelper.database;
    
    // استخدام Transaction لضمان حفظ الفاتورة وعناصرها معاً
    return await db.transaction((txn) async {
      // 1. إدخال الطلب الأساسي (فاتورة)
      final orderId = await txn.insert('orders', order.toMap());

      // 2. إدخال الأصناف التابعة لهذه الفاتورة
      for (var item in order.items) {
        final itemModel = item as OrderItemModel;
        final itemMap = itemModel.toMap();
        itemMap['order_id'] = orderId; // ربط الصنف برقم الفاتورة الجديد
        await txn.insert('order_items', itemMap);
      }

      return orderId;
    });
  }
}