import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import '../../domain/usecases/inventory_items_usecases.dart';
import '../../domain/usecases/recipe_usecases.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryItemsUseCase getInventoryItems;
  final AddInventoryItemUseCase addInventoryItem;
  final UpdateInventoryItemUseCase updateInventoryItem;
  final DeleteInventoryItemUseCase deleteInventoryItem;

  final GetRecipesUseCase getRecipes;
  final GetAllMenuEntitiesUseCase getAllMenuEntities;
  final AddRecipeUseCase addRecipe;
  final DeleteRecipeUseCase deleteRecipe;

  InventoryBloc({
    required this.getInventoryItems,
    required this.addInventoryItem,
    required this.updateInventoryItem,
    required this.deleteInventoryItem,
    required this.getRecipes,
    required this.getAllMenuEntities,
    required this.addRecipe,
    required this.deleteRecipe,
  }) : super(InventoryInitial()) {
    on<LoadInventoryItemsEvent>(_onLoadInventoryItems);
    on<AddInventoryItemEvent>(_onAddInventoryItem);
    on<UpdateInventoryItemEvent>(_onUpdateInventoryItem);
    on<DeleteInventoryItemEvent>(_onDeleteInventoryItem);

    on<LoadRecipesEvent>(_onLoadRecipes);
    on<AddRecipeEvent>(_onAddRecipe);
    on<DeleteRecipeEvent>(_onDeleteRecipe);
  }

  Future<void> _onLoadInventoryItems(
    LoadInventoryItemsEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryInitial) emit(InventoryLoading());

    final failureOrItems = await getInventoryItems(NoParams());
    final failureOrRecipes = await getRecipes(NoParams());
    final failureOrMenuEntities = await getAllMenuEntities(NoParams());

    failureOrItems.fold(
      (failure) => emit(InventoryError(failure.message)),
      (items) {
        failureOrRecipes.fold(
          (failure) => emit(InventoryError(failure.message)),
          (recipes) {
            failureOrMenuEntities.fold(
              (failure) => emit(InventoryError(failure.message)),
              (menuEntities) => emit(InventoryLoaded(
                items: items,
                recipes: recipes,
                menuEntities: menuEntities,
              )),
            );
          },
        );
      },
    );
  }

  Future<void> _onAddInventoryItem(
    AddInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoaded) {
      final failureOrResult = await addInventoryItem(event.item);
      failureOrResult.fold(
        (failure) => emit(InventoryError(failure.message)),
        (_) => add(LoadInventoryItemsEvent()),
      );
    }
  }

  Future<void> _onUpdateInventoryItem(
    UpdateInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoaded) {
      final failureOrResult = await updateInventoryItem(event.item);
      failureOrResult.fold(
        (failure) => emit(InventoryError(failure.message)),
        (_) => add(LoadInventoryItemsEvent()),
      );
    }
  }

  Future<void> _onDeleteInventoryItem(
    DeleteInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoaded) {
      final failureOrResult = await deleteInventoryItem(event.id);
      failureOrResult.fold(
        (failure) => emit(InventoryError(failure.message)),
        (_) => add(LoadInventoryItemsEvent()),
      );
    }
  }

  Future<void> _onLoadRecipes(
    LoadRecipesEvent event,
    Emitter<InventoryState> emit,
  ) async {
    add(LoadInventoryItemsEvent());
  }

  Future<void> _onAddRecipe(
    AddRecipeEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoaded) {
      final failureOrResult = await addRecipe(event.recipe);
      failureOrResult.fold(
        (failure) => emit(InventoryError(failure.message)),
        (_) => add(LoadInventoryItemsEvent()),
      );
    }
  }

  Future<void> _onDeleteRecipe(
    DeleteRecipeEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoaded) {
      final failureOrResult = await deleteRecipe(event.id);
      failureOrResult.fold(
        (failure) => emit(InventoryError(failure.message)),
        (_) => add(LoadInventoryItemsEvent()),
      );
    }
  }
}
