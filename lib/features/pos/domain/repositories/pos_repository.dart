import 'package:dartz/dartz.dart' hide Order;
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';

abstract class PosRepository {
  Future<Either<Failure, int>> saveOrder(OrderEntity order);
}