import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/repositories/orders_repository.dart';

class RefundOrderUseCase implements UseCase<void, int> {
  final OrdersRepository repository;
  RefundOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int orderId) {
    return repository.refundOrder(orderId);
  }
}