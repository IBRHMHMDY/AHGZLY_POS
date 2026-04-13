// مسار الملف: lib/features/pos/data/datasources/pos_local_data_source.dart

import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
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
        
        // 🪄 [Fixed 1]: جلب الوردية النشطة تلقائياً من قاعدة البيانات بدلاً من انتظارها من الـ BLoC
        final activeShift = await (appDatabase.select(appDatabase.shifts)
              ..where((t) => t.status.equals('active')))
            .getSingleOrNull();

        if (activeShift == null) {
           throw CacheException('لا يمكن إتمام البيع: لا توجد وردية نشطة مفتوحة حالياً.');
        }

        if (order.items.isEmpty) {
          throw CacheException('لا يمكن حفظ فاتورة فارغة.');
        }

        // 1. حفظ الفاتورة الأساسية
        final orderId = await appDatabase.into(appDatabase.orders).insert(
          OrdersCompanion.insert(
            shiftId: activeShift.id, // الاعتماد على الوردية النشطة
            tableId: Value(order.tableId),
            orderType: order.orderType,       
            subTotal: order.subTotal,
            discount: Value(order.discount),
            taxAmount: order.taxAmount,
            serviceFee: order.serviceFee,
            deliveryFee: order.deliveryFee,
            total: order.total,
            paymentMethod: order.paymentMethod, 
            status: order.status,               
            customerName: Value(order.customerName),
            customerPhone: Value(order.customerPhone),
            customerAddress: Value(order.customerAddress),
            createdAt: order.createdAt,         
          ),
        );

        // 2. حفظ عناصر الفاتورة
        for (var item in order.items) {
          // 🪄 [Fixed 2]: إزالة الـ Cast (as OrderItemModel) واستخدام الخصائص المشتركة مباشرة لتجنب CastError
          await appDatabase.into(appDatabase.orderItems).insert(
            OrderItemsCompanion.insert(
              orderId: orderId,
              itemId: item.itemId,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              notes: Value(item.notes),
            ),
          );
        }

        // 3. تحديث مبالغ الوردية بناءً على طريقة الدفع
        final isVisa = order.paymentMethod == PaymentMethod.visa;
        final isInstapay = order.paymentMethod == PaymentMethod.wallet;
        final isCash = order.paymentMethod == PaymentMethod.cash;

        final updatedShift = activeShift.copyWith(
          totalSales: activeShift.totalSales + order.total,
          totalOrders: activeShift.totalOrders + 1,
          totalCash: isCash ? activeShift.totalCash + order.total : activeShift.totalCash,
          totalVisa: isVisa ? activeShift.totalVisa + order.total : activeShift.totalVisa,
          totalInstapay: isInstapay ? activeShift.totalInstapay + order.total : activeShift.totalInstapay,
          expectedCash: isCash ? activeShift.expectedCash + order.total : activeShift.expectedCash,
        );

        await appDatabase.update(appDatabase.shifts).replace(updatedShift);

        return orderId; // إرجاع رقم الفاتورة لطباعته
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('حدث خطأ غير متوقع أثناء حفظ الفاتورة: ${e.toString()}');
    }
  }
}