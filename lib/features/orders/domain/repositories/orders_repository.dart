import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';

abstract class OrdersRepository {
  Future<Either<Failure, List<OrderHistory>>> getOrdersHistory({required bool isAdmin, required int? shiftId});
  Future<Either<Failure, void>> refundOrder(int orderId);
}