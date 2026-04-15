import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';

// 1. [Refactoring] واجهة محايدة لتجريد الاعتماد على واجهة المستخدم (UI State)
abstract class CalculableItem {
  int get itemQuantity;
  int get itemPrice; // السعر بالقروش (Cents)
  int get itemCost;  // التكلفة بالقروش (COGS - Cost of Goods Sold)
}

class OrderTotals {
  final int subTotal;      // إجمالي المبيعات قبل الخصم (Gross Sales)
  final int discount;      // قيمة الخصم
  final int netSales;      // صافي المبيعات (subTotal - discount)
  final int taxAmount;     // قيمة الضريبة
  final int serviceFee;    // رسوم الخدمة
  final int deliveryFee;   // رسوم التوصيل
  final int total;         // الإجمالي النهائي المطلوب من العميل
  final int totalCost;     // إجمالي تكلفة البضاعة المباعة للطلب (COGS)
  final int grossProfit;   // إجمالي الربح (netSales - totalCost)

  const OrderTotals({
    required this.subTotal,
    required this.discount,
    required this.netSales,
    required this.taxAmount,
    required this.serviceFee,
    required this.deliveryFee,
    required this.total,
    required this.totalCost,
    required this.grossProfit,
  });
}

class OrderCalculatorService {
  
  /// دالة نقية (Pure Function) لحساب الدورة المحاسبية للطلب بدقة
  OrderTotals calculate({
    required List<CalculableItem> items,
    required OrderType orderType,
    required int discountAmount,
    required AppSettingsEntity settings,
    // bool isTaxInclusive = false, // يمكن تفعيلها مستقبلاً إذا كانت الضرائب ضمن السعر
  }) {
    int subTotal = 0;
    int totalCost = 0;

    // 1. حساب الإجمالي الفرعي وتكلفة البضاعة
    for (var item in items) {
      subTotal += (item.itemPrice * item.itemQuantity);
      totalCost += (item.itemCost * item.itemQuantity);
    }

    // 2. تطبيق الخصم وتحديد صافي المبيعات
    int afterDiscount = subTotal - discountAmount;
    int netSales = afterDiscount < 0 ? 0 : afterDiscount;

    // 3. حساب الضرائب (بناءً على صافي المبيعات)
    int taxAmount = (netSales * settings.taxRate).round();

    // 4. حساب الرسوم الإضافية بناءً على نوع الطلب
    int serviceFee = orderType == OrderType.dineIn 
        ? (netSales * settings.serviceRate).round() 
        : 0;
        
    int deliveryFee = orderType == OrderType.delivery 
        ? settings.deliveryFee 
        : 0;

    // 5. الإجمالي النهائي
    int total = netSales + taxAmount + serviceFee + deliveryFee;

    // 6. حساب إجمالي الربح للطلب
    int grossProfit = netSales - totalCost;

    return OrderTotals(
      subTotal: subTotal,
      discount: discountAmount,
      netSales: netSales,
      taxAmount: taxAmount,
      serviceFee: serviceFee,
      deliveryFee: deliveryFee,
      total: total,
      totalCost: totalCost,
      grossProfit: grossProfit,
    );
  }

  /// [Refactoring] دالة المرتجعات تعكس القيم بالسالب لضمان دقة تقارير الوردية
  OrderTotals calculateRefund(OrderTotals originalTotals) {
    return OrderTotals(
      subTotal: -originalTotals.subTotal,
      discount: -originalTotals.discount,
      netSales: -originalTotals.netSales,
      taxAmount: -originalTotals.taxAmount,
      serviceFee: -originalTotals.serviceFee,
      deliveryFee: -originalTotals.deliveryFee,
      total: -originalTotals.total,
      totalCost: -originalTotals.totalCost,
      grossProfit: -originalTotals.grossProfit,
    );
  }
}