import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';
import 'package:ahgzly_pos/features/orders/domain/repositories/orders_repository.dart';
import 'package:dartz/dartz.dart';

class OrdersParams {
  final bool isAdmin;
  final int? shiftId;
  OrdersParams({required this.isAdmin, required this.shiftId});
}

class GetOrdersUseCase implements UseCase<List<OrderHistory>, OrdersParams> {
  final OrdersRepository repository;
  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderHistory>>> call(OrdersParams params) {
    return repository.getOrdersHistory(isAdmin: params.isAdmin, shiftId: params.shiftId);
  }
}