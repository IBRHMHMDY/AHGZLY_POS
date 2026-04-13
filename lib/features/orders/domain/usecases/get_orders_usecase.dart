import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history_entity.dart';
import 'package:ahgzly_pos/features/orders/domain/repositories/orders_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Refactored: جعل الـ Params ترث من Equatable لتوافق المعايير
class OrdersParams extends Equatable {
  final bool isAdmin;
  final int? shiftId;
  
  const OrdersParams({required this.isAdmin, required this.shiftId});

  @override
  List<Object?> get props => [isAdmin, shiftId];
}

class GetOrdersUseCase implements UseCase<List<OrderHistoryEntity>, OrdersParams> {
  final OrdersRepository repository;
  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderHistoryEntity>>> call(OrdersParams params) {
    return repository.getOrdersHistory(isAdmin: params.isAdmin, shiftId: params.shiftId);
  }
}