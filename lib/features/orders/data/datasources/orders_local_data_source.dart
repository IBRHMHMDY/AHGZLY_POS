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
          innerJoin(appDatabase.items, appDatabase.items.id.equalsExp(appDatabase.orderItems.itemId)),
          leftOuterJoin(appDatabase.itemVariants, appDatabase.itemVariants.id.equalsExp(appDatabase.orderItems.variantId))
        ])..where(appDatabase.orderItems.orderId.equals(order.id));
        
        final rows = await query.get();
        
        List<OrderItemHistoryModel> items = [];
        for (var row in rows) {
          final orderItem = row.readTable(appDatabase.orderItems);
          final item = row.readTable(appDatabase.items);
          final variant = row.readTableOrNull(appDatabase.itemVariants);
          
          final addonsQuery = appDatabase.select(appDatabase.orderItemAddons).join([
            innerJoin(appDatabase.addons, appDatabase.addons.id.equalsExp(appDatabase.orderItemAddons.addonId))
          ])..where(appDatabase.orderItemAddons.orderItemId.equals(orderItem.id));
          
          final addonsRows = await addonsQuery.get();
          
          String finalItemName = item.name;
          if (variant != null) finalItemName += ' (${variant.name})';
          if (addonsRows.isNotEmpty) {
            final addonsNames = addonsRows.map((r) => r.readTable(appDatabase.addons).name).join(' + ');
            finalItemName += ' + $addonsNames';
          }
          
          items.add(OrderItemHistoryModel.fromDrift(finalItemName, orderItem.quantity, orderItem.unitPrice));
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
        final order = await (appDatabase.select(appDatabase.orders)..where((t) => t.id.equals(orderId))).getSingleOrNull();
        
        if (order == null) throw CacheException('لم يتم العثور على الفاتورة.');
        if (order.status == OrderStatus.refunded) throw CacheException('هذه الفاتورة مسترجعة بالفعل.');

        // تحديث حالة الفاتورة
        await (appDatabase.update(appDatabase.orders)..where((t) => t.id.equals(orderId))).write(
          OrdersCompanion(status: Value(OrderStatus.refunded))
        );

        // تحديث الوردية والتحقق من نشاطها
        final shift = await (appDatabase.select(appDatabase.shifts)..where((t) => t.id.equals(order.shiftId) & t.status.equals('active'))).getSingleOrNull();
        if (shift == null) throw CacheException('لا يمكن استرجاع الفاتورة: الوردية الخاصة بها مغلقة أو غير نشطة.');

        // 🚀 [FIXED]: معرفة طريقة الدفع لخصم الأموال من المكان الصحيح (الدرج، الفيزا، الخ)
        String methodName = '';
        if (order.paymentMethodId != null) {
          final methodData = await (appDatabase.select(appDatabase.paymentMethods)..where((t) => t.id.equals(order.paymentMethodId!))).getSingleOrNull();
          methodName = methodData?.name ?? '';
        }

        final isCash = methodName.contains('كاش') || methodName.contains('نقد');
        final isVisa = methodName.contains('فيزا') || methodName.contains('بطاقة') || methodName.contains('ائتمان');
        final isInstapay = methodName.contains('محفظة') || methodName.contains('انستا') || methodName.contains('فودافون');

        final total = order.total;
        
        final updatedShift = shift.copyWith(
          totalSales: shift.totalSales - total,
          totalRefunds: shift.totalRefunds + total,
          refundedOrdersCount: shift.refundedOrdersCount + 1,
          totalOrders: shift.totalOrders - 1,
          totalCash: isCash ? shift.totalCash - total : shift.totalCash,
          totalVisa: isVisa ? shift.totalVisa - total : shift.totalVisa,
          totalInstapay: isInstapay ? shift.totalInstapay - total : shift.totalInstapay,
          expectedCash: isCash ? shift.expectedCash - total : shift.expectedCash, // 🚀 تأمين درج الكاشير
        );

        await appDatabase.update(appDatabase.shifts).replace(updatedShift);
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('حدث خطأ أثناء إتمام عملية المرتجع.');
    }
  }
}