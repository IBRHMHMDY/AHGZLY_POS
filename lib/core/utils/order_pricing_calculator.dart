//  : lib/core/utils/order_pricing_calculator.dart

import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';

/// كلاس مستقل ومسؤول حصرياً عن كافة العمليات الحسابية والضرائب للطلب.
/// تم فصله لضمان الالتزام بمبدأ المسؤولية الواحدة (SRP) وسهولة عمل الـ Unit Tests.
class OrderPricingCalculator {
  final List<OrderItemEntity> cartItems;
  final OrderType orderType;
  final int discountAmount;
  final double taxRate;
  final double serviceRate;
  final int deliveryFee;

  const OrderPricingCalculator({
    required this.cartItems,
    required this.orderType,
    required this.discountAmount,
    required this.taxRate,
    required this.serviceRate,
    required this.deliveryFee,
  });

  /// حساب الإجمالي الفرعي (بناءً على سعر البيع للعناصر)
  int get subTotal => cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  
  /// حساب إجمالي التكلفة (بناءً على سعر الشراء لحساب صافي الأرباح)
  int get totalCost => cartItems.fold(0, (sum, item) => sum + item.totalCost);
  
  /// الإجمالي الفرعي بعد تطبيق الخصم
  int get afterDiscount => (subTotal - discountAmount) > 0 ? (subTotal - discountAmount) : 0;
  
  /// حساب رسوم الخدمة (تطبق فقط في حالة تناول الطعام داخل الصالة Dine-In)
  int get serviceFeeAmount => orderType == OrderType.dineIn ? (afterDiscount * serviceRate).round() : 0;
  
  /// حساب رسوم التوصيل (تطبق فقط في حالة طلبات التوصيل Delivery)
  int get deliveryFeeAmount => orderType == OrderType.delivery ? deliveryFee : 0;

  /// حساب قيمة الضريبة المضافة (Exclusive) مباشرة بناءً على السعر بعد الخصم
  int get taxAmount => (afterDiscount * taxRate).round(); 

  /// الإجمالي النهائي الخاضع للطباعة والدفع
  int get total => afterDiscount + serviceFeeAmount + taxAmount + deliveryFeeAmount;
}