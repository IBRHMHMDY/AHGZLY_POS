import 'package:ahgzly_pos/core/extensions/order_type.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object?> get props => [];
}

// تحميل البيانات الأولية (أقسام، أصناف، عملاء، طاولات)
class LoadPosDataEvent extends PosEvent {}

// تغيير القسم المختار في الواجهة
class ChangeCategoryEvent extends PosEvent {
  final int categoryId;
  const ChangeCategoryEvent(this.categoryId);
  @override
  List<Object> get props => [categoryId];
}

// 🚀 [Sprint 3] إضافة صنف للسلة (شامل المقاس والإضافات)
class AddItemToCartEvent extends PosEvent {
  final OrderItemEntity orderItem;
  const AddItemToCartEvent(this.orderItem);
  @override
  List<Object> get props => [orderItem];
}

class RemoveItemFromCartEvent extends PosEvent {
  final OrderItemEntity orderItem;
  const RemoveItemFromCartEvent(this.orderItem);
  @override
  List<Object> get props => [orderItem];
}

class UpdateCartItemQuantityEvent extends PosEvent {
  final OrderItemEntity orderItem;
  final int newQuantity;
  const UpdateCartItemQuantityEvent(this.orderItem, this.newQuantity);
  @override
  List<Object> get props => [orderItem, newQuantity];
}

class ClearCartEvent extends PosEvent {}

// 🚀 [Sprint 3] تغيير إعدادات الفاتورة (نوع الطلب، الطاولة، العميل)
class ChangeOrderTypeEvent extends PosEvent {
  final OrderType orderType;
  const ChangeOrderTypeEvent(this.orderType);
  @override
  List<Object> get props => [orderType];
}

class SelectTableEvent extends PosEvent {
  final int? tableId;
  const SelectTableEvent(this.tableId);
  @override
  List<Object?> get props => [tableId];
}

class SelectCustomerEvent extends PosEvent {
  final int? customerId;
  const SelectCustomerEvent(this.customerId);
  @override
  List<Object?> get props => [customerId];
}

// الدفع والحفظ
class CheckoutOrderEvent extends PosEvent {
  final int shiftId;
  final int paymentMethodId; // طريقة الدفع المختارة عند الإغلاق
  final int? tableId;
  final int? customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  const CheckoutOrderEvent({
    required this.shiftId,
    required this.paymentMethodId,
    this.tableId,
    this.customerId,
    this.customerName = '',
    this.customerPhone = '',
    this.customerAddress = '',
  });
  @override
  List<Object?> get props => [shiftId,
        paymentMethodId,
        tableId,
        customerId,
        customerName,
        customerPhone,
        customerAddress];
}
