import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
import 'package:dartz/dartz.dart' hide Order;

class PosRepositoryImpl implements PosRepository {
  final PosLocalDataSource localDataSource;

  PosRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, int>> saveOrder(Order order) async {
    try {
      final orderModel = OrderModel.fromEntity(order);
      final orderId = await localDataSource.saveOrder(orderModel);
      return Right(orderId);
    } catch (_) {
      // Refactored: إخفاء رسائل النظام الفنية عن المستخدم وإرجاع رسالة مفهومة
      return const Left(DatabaseFailure('فشل في حفظ الطلب. يرجى المحاولة مرة أخرى.'));
    }
  }
}