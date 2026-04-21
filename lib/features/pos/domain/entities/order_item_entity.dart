import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/addon_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_variant_entity.dart';

class OrderItemEntity extends Equatable {
  final int? id;
  final int? orderId; // 🚀 [تمت الإضافة]
  final int itemId;
  final String itemName;
  final int quantity;
  final int unitPrice;
  final int unitCostPrice; 
  final String? notes;
  final ItemVariantEntity? selectedVariant;
  final List<AddonEntity> selectedAddons;

  const OrderItemEntity({
    this.id,
    this.orderId, // 🚀 [تمت الإضافة]
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    this.unitCostPrice = 0,
    this.notes,
    this.selectedVariant,
    this.selectedAddons = const [],
  });

  int get totalPrice {
    int addonsPrice = selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    return (unitPrice + addonsPrice) * quantity;
  }

  int get totalCost {
    int addonsCost = selectedAddons.fold(0, (sum, addon) => sum + addon.costPrice);
    return (unitCostPrice + addonsCost) * quantity;
  }

  OrderItemEntity copyWith({
    int? quantity,
    String? notes,
  }) {
    return OrderItemEntity(
      id: id,
      orderId: orderId,
      itemId: itemId,
      itemName: itemName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      unitCostPrice: unitCostPrice,
      notes: notes ?? this.notes,
      selectedVariant: selectedVariant,
      selectedAddons: selectedAddons,
    );
  }

  @override
  List<Object?> get props => [
        id, orderId, itemId, itemName, quantity, unitPrice, unitCostPrice, 
        notes, selectedVariant, selectedAddons
      ];
}