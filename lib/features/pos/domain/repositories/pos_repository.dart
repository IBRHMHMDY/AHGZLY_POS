import 'package:dartz/dartz.dart' hide Order;
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order.dart';

abstract class PosRepository {
  Future<Either<Failure, int>> saveOrder(Order order);
}