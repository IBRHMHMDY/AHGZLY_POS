// مسار الملف: lib/features/pos/data/datasources/pos_local_data_source.dart

import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_item_model.dart';
import 'package:ahgzly_pos/core/common/enums/enums_data.dart'; 
import 'package:drift/drift.dart';

abstract class PosLocalDataSource {
  Future<int> saveOrder(OrderModel order);
}

class PosLocalDataSourceImpl implements PosLocalDataSource {
  final AppDatabase appDatabase; 

  PosLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<int> saveOrder(OrderModel order) async {
    try {
      return await appDatabase.transaction(() async {
        
        if (order.shiftId == null || order.shiftId == 0) {
            throw CacheException('لا يمكن إتمام البيع: لا توجد وردية نشطة محددة.');
        }

        if (order.items.isEmpty) {
          throw CacheException('لا يمكن حفظ فاتورة فارغة.');
        }

        // [Refactor]: تمرير الـ Enums والـ DateTime مباشرة بفضل TypeConverters
        final orderId = await appDatabase.into(appDatabase.orders).insert(
          OrdersCompanion.insert(
            shiftId: order.shiftId!,
            tableId: Value(order.tableId),
            orderType: order.orderType,       // بدون .name
            subTotal: order.subTotal,
            discount: Value(order.discount),
            taxAmount: order.taxAmount,
            serviceFee: order.serviceFee,
            deliveryFee: order.deliveryFee,
            total: order.total,
            paymentMethod: order.paymentMethod, // بدون .name
            status: order.status,               // بدون .name
            customerName: Value(order.customerName),
            customerPhone: Value(order.customerPhone),
            customerAddress: Value(order.customerAddress),
            createdAt: order.createdAt,         // بدون toIso8601String()
          ),
        );

        for (var item in order.items) {
          final itemModel = item as OrderItemModel;
          await appDatabase.into(appDatabase.orderItems).insert(
            OrderItemsCompanion.insert(
              orderId: orderId,
              itemId: itemModel.itemId,
              quantity: itemModel.quantity,
              unitPrice: itemModel.unitPrice,
              notes: Value(itemModel.notes),
            ),
          );
        }

        final shift = await (appDatabase.select(appDatabase.shifts)
              ..where((t) => t.id.equals(order.shiftId!) & t.status.equals('active')))
            .getSingleOrNull();

        if (shift == null) {
           throw CacheException('الوردية الحالية غير نشطة أو تم إغلاقها.');
        }

        final isVisa = order.paymentMethod == PaymentMethod.visa;
        final isInstapay = order.paymentMethod == PaymentMethod.wallet;
        final isCash = order.paymentMethod == PaymentMethod.cash;

        final updatedShift = shift.copyWith(
          totalSales: shift.totalSales + order.total,
          totalOrders: shift.totalOrders + 1,
          totalCash: isCash ? shift.totalCash + order.total : shift.totalCash,
          totalVisa: isVisa ? shift.totalVisa + order.total : shift.totalVisa,
          totalInstapay: isInstapay ? shift.totalInstapay + order.total : shift.totalInstapay,
          expectedCash: isCash ? shift.expectedCash + order.total : shift.expectedCash,
        );

        await appDatabase.update(appDatabase.shifts).replace(updatedShift);

        return orderId;
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('حدث خطأ غير متوقع أثناء حفظ الفاتورة: ${e.toString()}');
    }
  }
}