import 'package:equatable/equatable.dart';

class RecipeEntity extends Equatable {
  final int id;
  final int? itemId;
  final int? variantId;
  final int? addonId;
  final int inventoryItemId;
  final double quantityNeeded;

  const RecipeEntity({
    required this.id,
    this.itemId,
    this.variantId,
    this.addonId,
    required this.inventoryItemId,
    required this.quantityNeeded,
  });

  @override
  List<Object?> get props => [
        id,
        itemId,
        variantId,
        addonId,
        inventoryItemId,
        quantityNeeded,
      ];
}
