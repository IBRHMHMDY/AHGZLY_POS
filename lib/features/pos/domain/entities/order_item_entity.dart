// مسار الملف: lib/features/pos/domain/entities/order_item_entity.dart
import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int? id;
  final int? orderId;
  final int itemId;
  final int quantity;
  final int unitPrice; 
  final int unitCost; // [Refactored]: إضافة تكلفة الوحدة وقت البيع
  final String? notes;

  const OrderItemEntity({
    this.id,
    this.orderId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost, // مطلوبة لتجنب المبيعات بدون تكلفة
    this.notes,
  });

  @override
  // [Refactored]: تحديث قائمة الخصائص
  List<Object?> get props => [id, orderId, itemId, quantity, unitPrice, unitCost, notes];
}