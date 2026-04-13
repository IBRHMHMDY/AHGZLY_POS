import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/item_entity.dart';
import '../repositories/menu_repository.dart';

class GetItemsUseCase implements UseCase<List<ItemEntity>, GetItemsParams> {
  final MenuRepository repository;
  GetItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ItemEntity>>> call(GetItemsParams params) async {
    return await repository.getItems(params.categoryId);
  }
}

class GetItemsParams extends Equatable {
  final int categoryId;
  const GetItemsParams({required this.categoryId});
  @override List<Object> get props => [categoryId];
}

class AddItemUseCase implements UseCase<int, AddItemParams> {
  final MenuRepository repository;
  AddItemUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(AddItemParams params) async {
    if (params.item.name.trim().isEmpty) {
      return const Left(ValidationFailure('اسم الصنف لا يمكن أن يكون فارغاً'));
    }
    // 🛡️ حماية الحسابات: منع إدخال سعر بالسالب
    if (params.item.price < 0) {
      return const Left(ValidationFailure('سعر الصنف لا يمكن أن يكون أقل من صفر'));
    }
    return await repository.addItem(params.item);
  }
}

class AddItemParams extends Equatable {
  final ItemEntity item;
  const AddItemParams({required this.item});
  @override List<Object> get props => [item];
}

class UpdateItemUseCase implements UseCase<int, UpdateItemParams> {
  final MenuRepository repository;
  UpdateItemUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(UpdateItemParams params) async {
    if (params.item.name.trim().isEmpty) return const Left(ValidationFailure('اسم الصنف لا يمكن أن يكون فارغاً'));
    if (params.item.price < 0) return const Left(ValidationFailure('سعر الصنف لا يمكن أن يكون أقل من صفر'));
    
    return await repository.updateItem(params.item);
  }
}

class UpdateItemParams extends Equatable {
  final ItemEntity item;
  const UpdateItemParams({required this.item});
  @override List<Object> get props => [item];
}

class DeleteItemUseCase implements UseCase<int, DeleteItemParams> {
  final MenuRepository repository;
  DeleteItemUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(DeleteItemParams params) async {
    return await repository.deleteItem(params.id);
  }
}

class DeleteItemParams extends Equatable {
  final int id;
  const DeleteItemParams({required this.id});
  @override List<Object> get props => [id];
}