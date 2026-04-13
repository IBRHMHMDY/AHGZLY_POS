import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/item_entity.dart';

abstract class MenuState extends Equatable {
  const MenuState();
  
  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class CategoriesLoaded extends MenuState {
  final List<CategoryEntity> categories;
  const CategoriesLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class ItemsLoaded extends MenuState {
  final List<ItemEntity> items;
  const ItemsLoaded(this.items);
  @override
  List<Object> get props => [items];
}

class MenuOperationSuccess extends MenuState {
  final String message;
  const MenuOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);
  @override
  List<Object> get props => [message];
}