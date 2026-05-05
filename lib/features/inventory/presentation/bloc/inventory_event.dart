import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

// -- Inventory Items Events --
class LoadInventoryItemsEvent extends InventoryEvent {}

class AddInventoryItemEvent extends InventoryEvent {
  final InventoryItemsCompanion item;
  const AddInventoryItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateInventoryItemEvent extends InventoryEvent {
  final InventoryItemsCompanion item;
  const UpdateInventoryItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteInventoryItemEvent extends InventoryEvent {
  final int id;
  const DeleteInventoryItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// -- Recipes Events --
class LoadRecipesEvent extends InventoryEvent {}

class AddRecipeEvent extends InventoryEvent {
  final RecipesCompanion recipe;
  const AddRecipeEvent(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class DeleteRecipeEvent extends InventoryEvent {
  final int id;
  const DeleteRecipeEvent(this.id);

  @override
  List<Object?> get props => [id];
}
