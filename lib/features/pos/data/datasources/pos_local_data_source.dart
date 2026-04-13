// مسار الملف: lib/features/pos/data/datasources/pos_local_data_source.dart

import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_item_model.dart';
import 'package:ahgzly_pos/core/common/enums/payment_method.dart'; // [Added] 
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
        
        // 1. التحقق من الوردية
        if (order.shiftId == null || order.shiftId == 0) {
            throw CacheException('لا يمكن إتمام البيع: لا توجد وردية نشطة محددة.');
        }

        if (order.items.isEmpty) {
          throw CacheException('لا يمكن حفظ فاتورة فارغة.');
        }

        // 2. إدخال الفاتورة (Mapping Enums/DateTime to Drift Strings)
        final orderId = await appDatabase.into(appDatabase.orders).insert(
          OrdersCompanion.insert(
            shiftId: order.shiftId!,
            tableId: Value(order.tableId), // تمرير معرف الطاولة إذا وُجد
            orderType: order.orderType.name,
            subTotal: order.subTotal,
            discount: Value(order.discount),
            taxAmount: order.taxAmount,
            serviceFee: order.serviceFee,
            deliveryFee: order.deliveryFee,
            total: order.total,
            paymentMethod: order.paymentMethod.name,
            status: order.status.name,
            customerName: Value(order.customerName),
            customerPhone: Value(order.customerPhone),
            customerAddress: Value(order.customerAddress),
            createdAt: order.createdAt.toIso8601String(), // String
          ),
        );

        // 3. إدخال عناصر الفاتورة
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

        // 4. تحديث الوردية
        final shift = await (appDatabase.select(appDatabase.shifts)
              ..where((t) => t.id.equals(order.shiftId!) & t.status.equals('active')))
            .getSingleOrNull();

        if (shift == null) {
           throw CacheException('الوردية الحالية غير نشطة أو تم إغلاقها.');
        }

        // [Clean Code]: تقييم طرق الدفع مباشرة باستخدام الـ Enums (Type Safe)
        final isVisa = order.paymentMethod == PaymentMethod.visa;
        final isInstapay = order.paymentMethod == PaymentMethod.wallet;
        final isCash = order.paymentMethod == PaymentMethod.cash;

        // حساب القيم الجديدة للوردية
        final updatedShift = shift.copyWith(
          totalSales: shift.totalSales + order.total,
          totalOrders: shift.totalOrders + 1,
          totalCash: isCash ? shift.totalCash + order.total : shift.totalCash,
          totalVisa: isVisa ? shift.totalVisa + order.total : shift.totalVisa,
          totalInstapay: isInstapay ? shift.totalInstapay + order.total : shift.totalInstapay,
          expectedCash: isCash ? shift.expectedCash + order.total : shift.expectedCash,
        );

        // حفظ الوردية
        await appDatabase.update(appDatabase.shifts).replace(updatedShift);

        return orderId;
      });
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException('حدث خطأ غير متوقع أثناء حفظ الفاتورة: ${e.toString()}');
    }
  }
}