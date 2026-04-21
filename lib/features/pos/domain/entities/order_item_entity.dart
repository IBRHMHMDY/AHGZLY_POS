import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int? id;
  final int? orderId;
  final int itemId;
  final int quantity;
  final int unitPrice; 
  final int unitCostPrice; // [NEW] التكلفة المجمدة وقت البيع
  final String? notes;

  const OrderItemEntity({
    this.id,
    this.orderId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.unitCostPrice, // [NEW]
    this.notes,
  });

  // [NEW] Helper: إجمالي تكلفة هذا الصنف (الكمية × سعر التكلفة للوحدة)
  int get totalItemCost => quantity * unitCostPrice;

  @override
  List<Object?> get props => [id, orderId, itemId, quantity, unitPrice, unitCostPrice, notes];
}