import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

// Category Events
class FetchCategoriesEvent extends MenuEvent {}

class AddCategoryEvent extends MenuEvent {
  final Category category;
  const AddCategoryEvent(this.category);
  @override
  List<Object> get props => [category];
}

class UpdateCategoryEvent extends MenuEvent {
  final Category category;
  const UpdateCategoryEvent(this.category);
  @override
  List<Object> get props => [category];
}

class DeleteCategoryEvent extends MenuEvent {
  final int id;
  const DeleteCategoryEvent(this.id);
  @override
  List<Object> get props => [id];
}

// Item Events
class FetchItemsEvent extends MenuEvent {
  final int categoryId;
  const FetchItemsEvent(this.categoryId);
  @override
  List<Object> get props => [categoryId];
}

class AddItemEvent extends MenuEvent {
  final Item item;
  const AddItemEvent(this.item);
  @override
  List<Object> get props => [item];
}

class UpdateItemEvent extends MenuEvent {
  final Item item;
  const UpdateItemEvent(this.item);
  @override
  List<Object> get props => [item];
}

class DeleteItemEvent extends MenuEvent {
  final int id;
  const DeleteItemEvent(this.id);
  @override
  List<Object> get props => [id];
}