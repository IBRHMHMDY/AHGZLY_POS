import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';
import 'package:ahgzly_pos/features/menu/domain/repositories/menu_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final MenuRepository repository;
  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}

class AddCategoryUseCase implements UseCase<int, AddCategoryParams> {
  final MenuRepository repository;
  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(AddCategoryParams params) async {
    if (params.category.name.trim().isEmpty) {
      return const Left(ValidationFailure('اسم القسم لا يمكن أن يكون فارغاً'));
    }
    return await repository.addCategory(params.category);
  }
}

class AddCategoryParams extends Equatable {
  final Category category;
  const AddCategoryParams({required this.category});
  @override List<Object> get props => [category];
}

class UpdateCategoryUseCase implements UseCase<int, UpdateCategoryParams> {
  final MenuRepository repository;
  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(UpdateCategoryParams params) async {
    if (params.category.name.trim().isEmpty) {
      return const Left(ValidationFailure('اسم القسم لا يمكن أن يكون فارغاً'));
    }
    return await repository.updateCategory(params.category);
  }
}

class UpdateCategoryParams extends Equatable {
  final Category category;
  const UpdateCategoryParams({required this.category});
  @override List<Object> get props => [category];
}

class DeleteCategoryUseCase implements UseCase<int, DeleteCategoryParams> {
  final MenuRepository repository;
  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(DeleteCategoryParams params) async {
    return await repository.deleteCategory(params.id);
  }
}

class DeleteCategoryParams extends Equatable {
  final int id;
  const DeleteCategoryParams({required this.id});
  @override List<Object> get props => [id];
}