import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/entities/recipe_with_details_entity.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();
  
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItemEntity> items;
  final List<RecipeWithDetailsEntity> recipes;
  final Map<String, List<dynamic>> menuEntities;

  const InventoryLoaded({
    required this.items,
    required this.recipes,
    required this.menuEntities,
  });

  InventoryLoaded copyWith({
    List<InventoryItemEntity>? items,
    List<RecipeWithDetailsEntity>? recipes,
    Map<String, List<dynamic>>? menuEntities,
  }) {
    return InventoryLoaded(
      items: items ?? this.items,
      recipes: recipes ?? this.recipes,
      menuEntities: menuEntities ?? this.menuEntities,
    );
  }

  @override
  List<Object?> get props => [items, recipes, menuEntities];
}

class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}
