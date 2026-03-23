import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/item.dart';
import '../repositories/menu_repository.dart';

class GetItemsUseCase implements UseCase<List<Item>, int> {
  final MenuRepository repository;
  GetItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call(int categoryId) async {
    return await repository.getItems(categoryId);
  }
}

class AddItemUseCase implements UseCase<int, Item> {
  final MenuRepository repository;
  AddItemUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(Item item) async {
    return await repository.addItem(item);
  }
}

class UpdateItemUseCase implements UseCase<int, Item> {
  final MenuRepository repository;
  UpdateItemUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(Item item) async {
    return await repository.updateItem(item);
  }
}

class DeleteItemUseCase implements UseCase<int, int> {
  final MenuRepository repository;
  DeleteItemUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(int id) async {
    return await repository.deleteItem(id);
  }
}