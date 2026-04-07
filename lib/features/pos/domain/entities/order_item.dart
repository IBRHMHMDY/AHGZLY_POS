import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final int? id;
  final int? orderId;
  final int itemId;
  final int quantity;
  final int unitPrice; // Refactored: تغيير من double إلى int (Cents)
  final String? notes;

  const OrderItem({
    this.id,
    this.orderId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  @override
  List<Object?> get props => [id, orderId, itemId, quantity, unitPrice, notes];
}