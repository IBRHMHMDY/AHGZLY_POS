// مسار الملف: lib/features/orders/data/datasources/orders_local_data_source.dart

import 'package:ahgzly_pos/core/database/drift/app_database.dart'; // استيراد Drift
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/orders/data/models/order_history_model.dart';
import 'package:drift/drift.dart';

abstract class OrdersLocalDataSource {
  Future<List<OrderHistoryModel>> getOrdersHistory({required bool isAdmin, required int? shiftId});
  Future<void> refundOrder(int orderId); 
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final AppDatabase appDatabase; // Refactored: استخدام AppDatabase

  OrdersLocalDataSourceImpl({required this.appDatabase});

  // Mapper لتحويل كائن Order الخاص بـ Drift إلى Map ليقبله Model القديم
  Map<String, dynamic> _driftOrderToMap(OrderDrift order) {
    return {
      'id': order.id,
      'order_type': order.orderType,
      'sub_total': order.subTotal,
      'discount': order.discount,
      'total': order.total,
      'payment_method': order.paymentMethod,
      'created_at': order.createdAt,
      'status': order.status,
      'shift_id': order.shiftId,
    };
  }

  // Mapper لعناصر الطلب 
  Map<String, dynamic> _driftItemToMap(int quantity, int unitPrice, String itemName) {
    return {
      'quantity': quantity,
      'unit_price': unitPrice,
      'item_name': itemName,
    };
  }

  @override
  Future<List<OrderHistoryModel>> getOrdersHistory({required bool isAdmin, required int? shiftId}) async {
    try {
      List<OrderDrift> ordersDrift = [];
      
      // 1. جلب الطلبات بناءً على الصلاحية
      if (isAdmin) {
        ordersDrift = await (appDatabase.select(appDatabase.orders)
              ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
            .get();
      } else {
        if (shiftId == null) return [];
        ordersDrift = await (appDatabase.select(appDatabase.orders)
              ..where((t) => t.shiftId.equals(shiftId))
              ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
            .get();
      }

      List<OrderHistoryModel> orders = [];
      
      // 2. جلب العناصر التابعة لكل طلب (الاستعاضة عن RawQuery بـ Type-Safe JOIN)
      for (var order in ordersDrift) {
        final query = appDatabase.select(appDatabase.orderItems).join([
          innerJoin(appDatabase.items, appDatabase.items.id.equalsExp(appDatabase.orderItems.itemId))
        ])..where(appDatabase.orderItems.orderId.equals(order.id));
        
        final rows = await query.get();
        
        List<OrderHistoryItemModel> items = [];
        for (var row in rows) {
          final orderItem = row.readTable(appDatabase.orderItems);
          final item = row.readTable(appDatabase.items); // جلب بيانات المنتج المرتبط
          
          items.add(OrderHistoryItemModel.fromMap(
            _driftItemToMap(orderItem.quantity, orderItem.unitPrice, item.name)
          ));
        }
        
        orders.add(OrderHistoryModel.fromMap(_driftOrderToMap(order), items));
      }
      
      return orders;
    } catch (e) {
      throw CacheException(message: 'فشل في جلب سجل الطلبات: $e');
    }
  }

  @override
  Future<void> refundOrder(int orderId) async {
    try {
      await appDatabase.transaction(() async {
        // 1. جلب الفاتورة من Drift
        final order = await (appDatabase.select(appDatabase.orders)
              ..where((t) => t.id.equals(orderId)))
            .getSingleOrNull();
        
        if (order == null) {
          throw CacheException(message: 'لم يتم العثور على الفاتورة.');
        }

        if (order.status == 'مرتجع') {
          throw CacheException(message: 'هذه الفاتورة مسترجعة بالفعل.');
        }

        // 2. تحديث حالة الفاتورة إلى مرتجع
        await (appDatabase.update(appDatabase.orders)..where((t) => t.id.equals(orderId))).write(
          const OrdersCompanion(status: Value('مرتجع'))
        );

        // 3. جلب الوردية وتحديث إحصائياتها لحظياً
        final shiftId = order.shiftId;
        final shift = await (appDatabase.select(appDatabase.shifts)
              ..where((t) => t.id.equals(shiftId) & t.status.equals('active')))
            .getSingleOrNull();

        if (shift == null) {
          throw CacheException(message: 'لا يمكن استرجاع الفاتورة: الوردية الخاصة بها مغلقة أو غير نشطة.');
        }

        final total = order.total;
        final paymentMethod = order.paymentMethod.toLowerCase();
        final isCash = paymentMethod == 'cash' || paymentMethod == 'كاش';
        final isVisa = paymentMethod == 'visa' || paymentMethod == 'فيزا';
        final isInstapay = paymentMethod == 'instapay' || paymentMethod == 'إنستاباي' || paymentMethod == 'انستاباي';

        // حساب القيم الجديدة بأمان (خصم المرتجع)
        final updatedShift = shift.copyWith(
          totalSales: shift.totalSales - total,
          totalRefunds: shift.totalRefunds + total,
          refundedOrdersCount: shift.refundedOrdersCount + 1,
          totalOrders: shift.totalOrders - 1,
          totalCash: isCash ? shift.totalCash - total : shift.totalCash,
          totalVisa: isVisa ? shift.totalVisa - total : shift.totalVisa,
          totalInstapay: isInstapay ? shift.totalInstapay - total : shift.totalInstapay,
          expectedCash: isCash ? shift.expectedCash - total : shift.expectedCash,
        );

        // حفظ الوردية بعد التحديث
        await appDatabase.update(appDatabase.shifts).replace(updatedShift);
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'حدث خطأ أثناء إتمام عملية المرتجع: ${e.toString()}');
    }
  }
}