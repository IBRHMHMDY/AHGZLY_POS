import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/repositories/orders_repository.dart';
import 'package:equatable/equatable.dart';

// Refactored: إضافة RefundOrderParams بدلاً من تمرير int مباشرة
class RefundOrderUseCase implements UseCase<void, RefundOrderParams> {
  final OrdersRepository repository;
  RefundOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RefundOrderParams params) {
    return repository.refundOrder(params.orderId);
  }
}

class RefundOrderParams extends Equatable {
  final int orderId;
  const RefundOrderParams({required this.orderId});

  @override
  List<Object> get props => [orderId];
}