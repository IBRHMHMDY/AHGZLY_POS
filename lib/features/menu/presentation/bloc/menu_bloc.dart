import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/category_usecases.dart';
import '../../domain/usecases/item_usecases.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetCategoriesUseCase getCategories;
  final AddCategoryUseCase addCategory;
  final UpdateCategoryUseCase updateCategory;
  final DeleteCategoryUseCase deleteCategory;
  
  final GetItemsUseCase getItems;
  final AddItemUseCase addItem;
  final UpdateItemUseCase updateItem;
  final DeleteItemUseCase deleteItem;

  MenuBloc({
    required this.getCategories,
    required this.addCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.getItems,
    required this.addItem,
    required this.updateItem,
    required this.deleteItem,
  }) : super(MenuInitial()) {
    
    // Categories
    on<FetchCategoriesEvent>((event, emit) async {
      emit(MenuLoading());
      final failureOrCategories = await getCategories(NoParams());
      failureOrCategories.fold(
        (failure) => emit(MenuError(failure.message)),
        (categories) => emit(CategoriesLoaded(categories)),
      );
    });

    on<AddCategoryEvent>((event, emit) async {
      emit(MenuLoading());
      final failureOrSuccess = await addCategory(event.category);
      failureOrSuccess.fold(
        (failure) => emit(MenuError(failure.message)),
        (id) => emit(const MenuOperationSuccess('تمت إضافة الفئة بنجاح')),
      );
    });

    on<UpdateCategoryEvent>((event, emit) async {
      emit(MenuLoading());
      final failureOrSuccess = await updateCategory(event.category);
      failureOrSuccess.fold(
        (failure) => emit(MenuError(failure.message)),
        (_) => emit(const MenuOperationSuccess('تم تحديث الفئة بنجاح')),
      );
    });

    on<DeleteCategoryEvent>((event, emit) async {
      emit(MenuLoading());
      final failureOrSuccess = await deleteCategory(event.id);
      failureOrSuccess.fold(
        (failure) => emit(MenuError(failure.message)),
        (_) => emit(const MenuOperationSuccess('تم حذف الفئة بنجاح')),
      );
    });

    // Items
    on<FetchItemsEvent>((event, emit) async {
      emit(MenuLoading());
      final failureOrItems = await getItems(event.categoryId);
      failureOrItems.fold(
        (failure) => emit(MenuError(failure.message)),
        (items) => emit(ItemsLoaded(items)),
      );
    });

    on<AddItemEvent>((event, emit) async {
      emit(MenuLoading());
      final failureOrSuccess = await addItem(event.item);
      failureOrSuccess.fold(
        (failure) => emit(MenuError(failure.message)),
        (id) => emit(const MenuOperationSuccess('تمت إضافة الصنف بنجاح')),
      );
    });

    on<UpdateItemEvent>((event, emit) async {
      emit(MenuLoading());
      final failureOrSuccess = await updateItem(event.item);
      failureOrSuccess.fold(
        (failure) => emit(MenuError(failure.message)),
        (_) => emit(const MenuOperationSuccess('تم تحديث الصنف بنجاح')),
      );
    });

    on<DeleteItemEvent>((event, emit) async {
      emit(MenuLoading());
      final failureOrSuccess = await deleteItem(event.id);
      failureOrSuccess.fold(
        (failure) => emit(MenuError(failure.message)),
        (_) => emit(const MenuOperationSuccess('تم حذف الصنف بنجاح')),
      );
    });
  }
}