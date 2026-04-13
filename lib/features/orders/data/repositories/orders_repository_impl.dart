import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history_entity.dart';
import 'package:ahgzly_pos/features/orders/domain/repositories/orders_repository.dart';
import 'package:ahgzly_pos/features/orders/data/datasources/orders_local_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersLocalDataSource localDataSource;
  OrdersRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<OrderHistoryEntity>>> getOrdersHistory({required bool isAdmin, required int? shiftId}) async {
    try {
      final orders = await localDataSource.getOrdersHistory(isAdmin: isAdmin, shiftId: shiftId);
      return Right(orders);
    } catch (_) {
      // Refactored: User-friendly message
      return const Left(DatabaseFailure('فشل في جلب سجل الطلبات. يرجى التأكد من مساحة التخزين.'));
    }
  }

  @override
  Future<Either<Failure, void>> refundOrder(int orderId) async {
    try {
      await localDataSource.refundOrder(orderId);
      return const Right(null);
    } catch (_) {
      // Refactored: User-friendly message
      return const Left(DatabaseFailure('فشل استرجاع الطلب. يرجى المحاولة مرة أخرى.'));
    }
  }
}