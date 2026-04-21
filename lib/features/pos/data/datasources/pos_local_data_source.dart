import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/database/app_database_extentions.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_item_model.dart';
import 'package:drift/drift.dart';

// 🚀 [Fix]: إكمال العقد (Contract) ليتوافق مع الـ Repository
abstract class PosLocalDataSource {
  Future<int> saveOrder(OrderModel order);
  Future<List<CustomerData>> getCustomers();
  Future<List<ZoneData>> getZones();
  Future<List<RestaurantTableData>> getTablesByZone(int zoneId);
  Future<List<PaymentMethodData>> getPaymentMethods();
  Future<int> addCustomer(CustomersCompanion customer);
}

class PosLocalDataSourceImpl implements PosLocalDataSource {
  final AppDatabase appDatabase; 

  PosLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<int> saveOrder(OrderModel order) async {
    return await appDatabase.transaction(() async {
      
      if (order.shiftId == null || order.shiftId == 0) {
          throw CacheException('لا يمكن إتمام البيع: لا توجد وردية نشطة محددة.');
      }

      if (order.items.isEmpty) {
        throw CacheException('لا يمكن حفظ فاتورة فارغة.');
      }

      final orderId = await appDatabase.into(appDatabase.orders).insert(
        OrdersCompanion.insert(
          shiftId: order.shiftId!,
          tableId: Value(order.tableId),
          orderType: Value(order.orderType),       
          subTotal: order.subTotal,
          discount: Value(order.discount),
          taxAmount: order.taxAmount,
          serviceFee: order.serviceFee,
          deliveryFee: order.deliveryFee,
          total: order.total,
          paymentMethodId: Value(order.paymentMethodId), 
          status: order.status,               
          customerName: Value(order.customerName),
          customerPhone: Value(order.customerPhone),
          customerAddress: Value(order.customerAddress),
          createdAt: order.createdAt,         
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

      // 🚀 [Fix Critical Bug]: التخلص من الـ Enum نهائياً.
      // نقوم بالبحث عن اسم طريقة الدفع في قاعدة البيانات باستخدام الـ ID
      String methodName = '';
      if (order.paymentMethodId != null) {
        final methodData = await (appDatabase.select(appDatabase.paymentMethods)
              ..where((t) => t.id.equals(order.paymentMethodId!)))
            .getSingleOrNull();
        methodName = methodData?.name ?? '';
      }

      final isCash = methodName.contains('كاش');
      final isVisa = methodName.contains('فيزا') || methodName.contains('بطاقة');
      final isInstapay = methodName.contains('محفظة') || methodName.contains('انستا') || methodName.contains('فودافون');

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
  }

  // ==========================================
  // 🚀 [Fix]: تنفيذ الدوال المساعدة لجلب البيانات
  // ==========================================
  @override
  Future<List<CustomerData>> getCustomers() async {
    return await appDatabase.getAllCustomers();
  }

  @override
  Future<List<ZoneData>> getZones() async {
    return await appDatabase.getAllZones();
  }

  @override
  Future<List<RestaurantTableData>> getTablesByZone(int zoneId) async {
    return await appDatabase.getTablesByZoneId(zoneId);
  }

  @override
  Future<List<PaymentMethodData>> getPaymentMethods() async {
    return await appDatabase.getAllPaymentMethods();
  }

  @override
  Future<int> addCustomer(CustomersCompanion customer) async {
    return await appDatabase.insertCustomer(customer);
  }
}