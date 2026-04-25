import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/database/app_database_extentions.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_item_model.dart';
import 'package:drift/drift.dart';

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

      // 1. حفظ الطلب الأساسي (Order)
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

      // 2. حفظ الأصناف (OrderItems) والمقاسات والإضافات
      for (var item in order.items) {
        final itemModel = item as OrderItemModel;
        
        final orderItemId = await appDatabase.into(appDatabase.orderItems).insert(
          OrderItemsCompanion.insert(
            orderId: orderId,
            itemId: itemModel.itemId,
            variantId: Value(itemModel.selectedVariant?.id), 
            quantity: itemModel.quantity,
            unitPrice: itemModel.unitPrice,
            unitCostPrice: Value(itemModel.unitCostPrice), 
            notes: Value(itemModel.notes),
          ),
        );

        if (itemModel.selectedAddons.isNotEmpty) {
          for (var addon in itemModel.selectedAddons) {
            await appDatabase.into(appDatabase.orderItemAddons).insert(
              OrderItemAddonsCompanion.insert(
                orderItemId: orderItemId,
                addonId: addon.id!,
                price: addon.price,       
                costPrice: Value(addon.costPrice),
              ),
            );
          }
        }
      }

      // 3. تحديث إحصائيات الوردية
      final shift = await (appDatabase.select(appDatabase.shifts)
            ..where((t) => t.id.equals(order.shiftId!) & t.status.equals('active')))
          .getSingleOrNull();

      if (shift == null) {
         throw CacheException('الوردية الحالية غير نشطة أو تم إغلاقها من جهاز آخر.');
      }

      String methodName = '';
      if (order.paymentMethodId != null) {
        final methodData = await (appDatabase.select(appDatabase.paymentMethods)
              ..where((t) => t.id.equals(order.paymentMethodId!)))
            .getSingleOrNull();
        methodName = methodData?.name ?? '';
      }

      // 🚀 [FIXED]: تحسين دقة الفرز المالي لضمان عدم حدوث عجز في الدرج
      final isCash = methodName.contains('كاش') || methodName.contains('نقد');
      final isVisa = methodName.contains('فيزا') || methodName.contains('بطاقة') || methodName.contains('ائتمان');
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

  @override
  Future<List<CustomerData>> getCustomers() async => await appDatabase.getAllCustomers();

  @override
  Future<List<ZoneData>> getZones() async => await appDatabase.getAllZones();

  @override
  Future<List<RestaurantTableData>> getTablesByZone(int zoneId) async => await appDatabase.getTablesByZoneId(zoneId);

  @override
  Future<List<PaymentMethodData>> getPaymentMethods() async => await appDatabase.getAllPaymentMethods();

  @override
  Future<int> addCustomer(CustomersCompanion customer) async => await appDatabase.insertCustomer(customer);
}