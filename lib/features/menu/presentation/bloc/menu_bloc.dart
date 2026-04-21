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
    
    // تسجيل أحداث الفئات (Categories)
    on<FetchCategoriesEvent>(_onFetchCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);

    // تسجيل أحداث الأصناف (Items)
    on<FetchItemsEvent>(_onFetchItems);
    on<AddItemEvent>(_onAddItem);
    on<UpdateItemEvent>(_onUpdateItem);
    on<DeleteItemEvent>(_onDeleteItem);
  }

  // تم فصل العمليات (Handlers) لتقليل التعقيد داخل المُنشئ (Constructor) ولتطبيق مبدأ Single Responsibility

  Future<void> _onFetchCategories(FetchCategoriesEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    final failureOrCategories = await getCategories(NoParams());
    failureOrCategories.fold(
      (failure) => emit(MenuError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    final failureOrSuccess = await addCategory(AddCategoryParams(category: event.category));
    failureOrSuccess.fold(
      (failure) => emit(MenuError(failure.message)),
      (_) => emit(const MenuOperationSuccess('تمت إضافة الفئة بنجاح')),
    );
  }

  Future<void> _onUpdateCategory(UpdateCategoryEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    final failureOrSuccess = await updateCategory(UpdateCategoryParams(category: event.category));
    failureOrSuccess.fold(
      (failure) => emit(MenuError(failure.message)),
      (_) => emit(const MenuOperationSuccess('تم تحديث الفئة بنجاح')),
    );
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    final failureOrSuccess = await deleteCategory(DeleteCategoryParams(id: event.id));
    failureOrSuccess.fold(
      (failure) => emit(MenuError(failure.message)),
      (_) => emit(const MenuOperationSuccess('تم حذف الفئة بنجاح')),
    );
  }

  Future<void> _onFetchItems(FetchItemsEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    final failureOrItems = await getItems(GetItemsParams(categoryId: event.categoryId));
    failureOrItems.fold(
      (failure) => emit(MenuError(failure.message)),
      (items) => emit(ItemsLoaded(items)),
    );
  }

  Future<void> _onAddItem(AddItemEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    final failureOrSuccess = await addItem(AddItemParams(item: event.item));
    failureOrSuccess.fold(
      (failure) => emit(MenuError(failure.message)),
      (_) => emit(const MenuOperationSuccess('تمت إضافة الصنف بنجاح')),
    );
  }

  Future<void> _onUpdateItem(UpdateItemEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    final failureOrSuccess = await updateItem(UpdateItemParams(item: event.item));
    failureOrSuccess.fold(
      (failure) => emit(MenuError(failure.message)),
      (_) => emit(const MenuOperationSuccess('تم تحديث الصنف بنجاح')),
    );
  }

  Future<void> _onDeleteItem(DeleteItemEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    final failureOrSuccess = await deleteItem(DeleteItemParams(id: event.id));
    failureOrSuccess.fold(
      (failure) => emit(MenuError(failure.message)),
      (_) => emit(const MenuOperationSuccess('تم حذف الصنف بنجاح')),
    );
  }
}