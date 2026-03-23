import 'package:dartz/dartz.dart' hide Order;
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';

class SaveOrderUseCase implements UseCase<int, Order> {
  final PosRepository repository;

  SaveOrderUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(Order order) {
    return repository.saveOrder(order);
  }
}