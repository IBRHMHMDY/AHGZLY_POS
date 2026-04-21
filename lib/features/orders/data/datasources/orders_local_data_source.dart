import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/extensions/order_status.dart';
import 'package:ahgzly_pos/features/orders/data/models/order_history_model.dart';

import 'package:drift/drift.dart';

abstract class OrdersLocalDataSource {
  Future<List<OrderHistoryModel>> getOrdersHistory({required bool isAdmin, required int? shiftId});
  Future<void> refundOrder(int orderId); 
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final AppDatabase appDatabase;

  OrdersLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<List<OrderHistoryModel>> getOrdersHistory({required bool isAdmin, required int? shiftId}) async {
    try {
      List<OrderData> ordersDrift = [];
      
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
      
      for (var order in ordersDrift) {
        final query = appDatabase.select(appDatabase.orderItems).join([
          innerJoin(appDatabase.items, appDatabase.items.id.equalsExp(appDatabase.orderItems.itemId))
        ])..where(appDatabase.orderItems.orderId.equals(order.id));
        
        final rows = await query.get();
        
        List<OrderItemHistoryModel> items = [];
        for (var row in rows) {
          final orderItem = row.readTable(appDatabase.orderItems);
          final item = row.readTable(appDatabase.items);
          
          // [Refactor]: تمرير المتغيرات مباشرة بدلاً من Map
          items.add(OrderItemHistoryModel.fromDrift(item.name, orderItem.quantity, orderItem.unitPrice));
        }
        
        orders.add(OrderHistoryModel.fromDrift(order, items));
      }
      
      return orders;
    } catch (e) {
      throw CacheException('فشل في جلب سجل الطلبات: $e');
    }
  }

  @override
  Future<void> refundOrder(int orderId) async {
    try {
      await appDatabase.transaction(() async {
        final order = await (appDatabase.select(appDatabase.orders)
              ..where((t) => t.id.equals(orderId)))
            .getSingleOrNull();
        
        if (order == null) throw CacheException('لم يتم العثور على الفاتورة.');

        // [Refactor]: استخدام الـ Enum بدلاً من النص
        if (order.status == OrderStatus.refunded) {
          throw CacheException('هذه الفاتورة مسترجعة بالفعل.');
        }

        // [Refactor]: تمرير الـ Enum للـ Companion
        await (appDatabase.update(appDatabase.orders)..where((t) => t.id.equals(orderId))).write(
          const OrdersCompanion(status: Value(OrderStatus.refunded))
        );

        final shiftId = order.shiftId;
        final shift = await (appDatabase.select(appDatabase.shifts)
              ..where((t) => t.id.equals(shiftId) & t.status.equals('active')))
            .getSingleOrNull();

        if (shift == null) throw CacheException('لا يمكن استرجاع الفاتورة: الوردية الخاصة بها مغلقة أو غير نشطة.');

        final total = order.total;
        // [Refactor]: استخدام الـ Enum بدلاً من النصوص المتعددة
        // final isCash = order.paymentMethod == PaymentMethod.cash;
        // final isVisa = order.paymentMethod == PaymentMethod.visa;
        // final isInstapay = order.paymentMethod == PaymentMethod.wallet;

        final updatedShift = shift.copyWith(
          totalSales: shift.totalSales - total,
          totalRefunds: shift.totalRefunds + total,
          refundedOrdersCount: shift.refundedOrdersCount + 1,
          totalOrders: shift.totalOrders - 1,
          // totalCash: isCash ? shift.totalCash - total : shift.totalCash,
          // totalVisa: isVisa ? shift.totalVisa - total : shift.totalVisa,
          // totalInstapay: isInstapay ? shift.totalInstapay - total : shift.totalInstapay,
          // expectedCash: isCash ? shift.expectedCash - total : shift.expectedCash,
        );

        await appDatabase.update(appDatabase.shifts).replace(updatedShift);
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('حدث خطأ أثناء إتمام عملية المرتجع: ${e.toString()}');
    }
  }
}