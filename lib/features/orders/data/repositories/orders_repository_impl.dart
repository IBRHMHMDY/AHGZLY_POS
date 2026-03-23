import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';
import 'package:ahgzly_pos/features/orders/domain/repositories/orders_repository.dart';
import 'package:ahgzly_pos/features/orders/data/datasources/orders_local_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersLocalDataSource localDataSource;

  OrdersRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<OrderHistory>>> getOrdersHistory() async {
    try {
      final orders = await localDataSource.getOrdersHistory();
      return Right(orders);
    } catch (e) {
      return Left(DatabaseFailure('فشل في جلب سجل الطلبات: ${e.toString()}'));
    }
  }
}