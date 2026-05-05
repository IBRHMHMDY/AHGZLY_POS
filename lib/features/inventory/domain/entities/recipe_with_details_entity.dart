import 'package:equatable/equatable.dart';

class RecipeWithDetailsEntity extends Equatable {
  final int id;
  final int? itemId;
  final String? itemName;
  final int? variantId;
  final String? variantName;
  final int? addonId;
  final String? addonName;
  final int inventoryItemId;
  final String inventoryItemName;
  final String unit;
  final double quantityNeeded;

  const RecipeWithDetailsEntity({
    required this.id,
    this.itemId,
    this.itemName,
    this.variantId,
    this.variantName,
    this.addonId,
    this.addonName,
    required this.inventoryItemId,
    required this.inventoryItemName,
    required this.unit,
    required this.quantityNeeded,
  });

  @override
  List<Object?> get props => [
        id,
        itemId,
        itemName,
        variantId,
        variantName,
        addonId,
        addonName,
        inventoryItemId,
        inventoryItemName,
        unit,
        quantityNeeded,
      ];
}
