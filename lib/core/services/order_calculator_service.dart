import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart'; // لجلب CartItem أو يفضل نقل CartItem لطبقة الـ Domain لاحقاً
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';

class OrderTotals {
  final int subTotal;
  final int discount;
  final int taxAmount;
  final int serviceFee;
  final int deliveryFee;
  final int total;

  OrderTotals({
    required this.subTotal,
    required this.discount,
    required this.taxAmount,
    required this.serviceFee,
    required this.deliveryFee,
    required this.total,
  });
}

class OrderCalculatorService {
  OrderTotals calculate({
    required List<CartItem> cartItems,
    required OrderType orderType,
    required int discountAmount,
    required AppSettingsEntity settings,
  }) {
    // 1. حساب الإجمالي الفرعي
    int subTotal = cartItems.fold(0, (sum, item) => sum + (item.item.price * item.quantity));
    
    // 2. تطبيق الخصم
    int afterDiscount = subTotal - discountAmount;
    if (afterDiscount < 0) afterDiscount = 0;

    // 3. حساب الضرائب والرسوم بناءً على نوع الطلب والإعدادات
    int taxAmount = (afterDiscount * settings.taxRate).round(); 
    
    int serviceFee = orderType == OrderType.dineIn 
        ? (afterDiscount * settings.serviceRate).round() 
        : 0;
        
    int deliveryFee = orderType == OrderType.delivery 
        ? settings.deliveryFee 
        : 0;
    
    // 4. الإجمالي النهائي
    int total = afterDiscount + taxAmount + serviceFee + deliveryFee;

    return OrderTotals(
      subTotal: subTotal,
      discount: discountAmount,
      taxAmount: taxAmount,
      serviceFee: serviceFee,
      deliveryFee: deliveryFee,
      total: total,
    );
  }
}