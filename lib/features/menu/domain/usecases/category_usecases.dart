import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';
import 'package:ahgzly_pos/features/menu/domain/repositories/menu_repository.dart';
import 'package:dartz/dartz.dart';


class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final MenuRepository repository;
  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}

class AddCategoryUseCase implements UseCase<int, Category> {
  final MenuRepository repository;
  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(Category category) async {
    return await repository.addCategory(category);
  }
}

class UpdateCategoryUseCase implements UseCase<int, Category> {
  final MenuRepository repository;
  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(Category category) async {
    return await repository.updateCategory(category);
  }
}

class DeleteCategoryUseCase implements UseCase<int, int> {
  final MenuRepository repository;
  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(int id) async {
    return await repository.deleteCategory(id);
  }
}