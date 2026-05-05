import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/inventory_item_entity.dart';
import 'package:ahgzly_pos/features/inventory/domain/repositories/inventory_repository.dart';

class GetInventoryItemsUseCase implements UseCase<List<InventoryItemEntity>, NoParams> {
  final InventoryRepository repository;
  GetInventoryItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<InventoryItemEntity>>> call(NoParams params) async {
    return await repository.getInventoryItems();
  }
}

class AddInventoryItemUseCase implements UseCase<InventoryItemEntity, InventoryItemsCompanion> {
  final InventoryRepository repository;
  AddInventoryItemUseCase(this.repository);

  @override
  Future<Either<Failure, InventoryItemEntity>> call(InventoryItemsCompanion params) async {
    return await repository.addInventoryItem(params);
  }
}

class UpdateInventoryItemUseCase implements UseCase<InventoryItemEntity, InventoryItemsCompanion> {
  final InventoryRepository repository;
  UpdateInventoryItemUseCase(this.repository);

  @override
  Future<Either<Failure, InventoryItemEntity>> call(InventoryItemsCompanion params) async {
    return await repository.updateInventoryItem(params);
  }
}

class DeleteInventoryItemUseCase implements UseCase<void, int> {
  final InventoryRepository repository;
  DeleteInventoryItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteInventoryItem(id);
  }
}
