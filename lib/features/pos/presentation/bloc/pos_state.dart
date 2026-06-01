import 'package:ahgzly_pos/core/common/entities/customer_entity.dart';
import 'package:ahgzly_pos/core/common/entities/restaurant_table_entity.dart';
import 'package:ahgzly_pos/core/common/entities/payment_method_entity.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';
import 'package:ahgzly_pos/core/extensions/print_mode.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PosState extends Equatable {
  const PosState();
  @override
  List<Object?> get props => [];
}

class PosInitial extends PosState {}
class PosLoading extends PosState {}

class PosDataLoaded extends PosState {
  final List<CategoryEntity> categories;
  final List<ItemEntity> currentItems;
  final int? selectedCategoryId;
  
  final List<OrderItemEntity> cartItems;
  final OrderType orderType;
  final int? selectedTableId;
  final int? selectedCustomerId;
  final List<CustomerEntity> customers;
  final List<RestaurantTableEntity> tables;
  final List<PaymentMethodEntity> paymentMethods; // 🚀 [Fix]: طرق الدفع من قاعدة البيانات

  // 🚀 [Fix]: المتغيرات المالية للحساب الدقيق في الواجهة
  final int discountAmount;
  final double taxRate;
  final double serviceRate;
  final int deliveryFee;

  final PrintMode printMode;
  final String restaurantName;
  final String taxNumber;

  const PosDataLoaded({
    required this.categories,
    required this.currentItems,
    this.selectedCategoryId,
    this.cartItems = const [],
    this.orderType = OrderType.takeaway,
    this.selectedTableId,
    this.selectedCustomerId,
    this.customers = const [],
    this.tables = const [],
    this.paymentMethods = const [],
    this.discountAmount = 0,
    this.taxRate = 0.0,
    this.serviceRate = 0.0,
    this.deliveryFee = 0,
    this.printMode = PrintMode.ask,
    this.restaurantName = '',
    this.taxNumber = '',
  });

  // 🚀 [Fix]: الحسابات الديناميكية الحقيقية
  // استخراج الإجمالي الفرعي (بناءً على سعر البيع)
  int get subTotal => cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  
  // 🚀 [تمت إعادتها]: استخراج إجمالي التكلفة (بناءً على سعر الشراء/التكلفة لحساب الأرباح)
  int get totalCost => cartItems.fold(0, (sum, item) => sum + item.totalCost);
  
  // الإجمالي بعد الخصم (وهو الأساس الذي سنحسب عليه كل شيء)
  int get afterDiscount => (subTotal - discountAmount) > 0 ? (subTotal - discountAmount) : 0;
  
  // حساب رسوم الخدمة تضرب في الإجمالي بعد الخصم
  int get serviceFeeAmount => orderType == OrderType.dineIn ? (afterDiscount * serviceRate).round() : 0;
  
  // التوصيل (إن وجد)
  int get deliveryFeeAmount => orderType == OrderType.delivery ? deliveryFee : 0;

  // الضريبة تُحسب الآن مباشرة على (الإجمالي بعد الخصم) كما في الصور (Exclusive)
  int get taxAmount => (afterDiscount * taxRate).round(); 

  // الإجمالي النهائي المماثل للصور
  int get total {
    return afterDiscount + serviceFeeAmount + taxAmount + deliveryFeeAmount;
  }

  PosDataLoaded copyWith({
    List<CategoryEntity>? categories,
    List<ItemEntity>? currentItems,
    int? selectedCategoryId,
    List<OrderItemEntity>? cartItems,
    OrderType? orderType,
    int? selectedTableId,
    int? selectedCustomerId,
    List<CustomerEntity>? customers,
    List<RestaurantTableEntity>? tables,
    List<PaymentMethodEntity>? paymentMethods,
    int? discountAmount,
    double? taxRate,
    double? serviceRate,
    int? deliveryFee,
    PrintMode? printMode,
    String? restaurantName,
    String? taxNumber,
    bool? isTaxInclusive,
  }) {
    return PosDataLoaded(
      categories: categories ?? this.categories,
      currentItems: currentItems ?? this.currentItems,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      cartItems: cartItems ?? this.cartItems,
      orderType: orderType ?? this.orderType,
      selectedTableId: selectedTableId ?? this.selectedTableId,
      selectedCustomerId: selectedCustomerId ?? this.selectedCustomerId,
      customers: customers ?? this.customers,
      tables: tables ?? this.tables,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      serviceRate: serviceRate ?? this.serviceRate,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      printMode: printMode ?? this.printMode,
      restaurantName: restaurantName ?? this.restaurantName,
      taxNumber: taxNumber ?? this.taxNumber,
    );
  }

  @override
  List<Object?> get props => [
        categories, currentItems, selectedCategoryId, cartItems, orderType, 
        selectedTableId, selectedCustomerId, customers, tables, paymentMethods,
        discountAmount, taxRate, serviceRate, deliveryFee, printMode, restaurantName, taxNumber,
      ];
}

class PosCheckoutSuccess extends PosState {
  final int orderId;
  const PosCheckoutSuccess(this.orderId);
  @override
  List<Object> get props => [orderId];
}

class PosError extends PosState {
  final String message;
  const PosError(this.message);
  @override
  List<Object> get props => [message];
}