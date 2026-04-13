// مسار الملف: lib/features/pos/data/repositories/pos_repository_impl.dart

import 'dart:developer' as developer; // [Refactored]: استيراد أداة التسجيل الخاصة بـ Dart
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
import 'package:dartz/dartz.dart' hide Order;

class PosRepositoryImpl implements PosRepository {
  final PosLocalDataSource localDataSource;

  PosRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, int>> saveOrder(OrderEntity order) async {
    try {
      final orderModel = OrderModel.fromEntity(order);
      final orderId = await localDataSource.saveOrder(orderModel);
      return Right(orderId);
    } catch (e, stackTrace) {
      // [Refactored]: تسجيل الخطأ الفعلي والـ StackTrace لمساعدة المطورين في الصيانة (Logging)
      // هذا يمنع طمس الأخطاء (Swallowing Exceptions) ويحافظ على أمان النظام
      developer.log(
        'Database Error during saveOrder',
        error: e,
        stackTrace: stackTrace,
        name: 'PosRepositoryImpl',
      );

      // الاستمرار في إرجاع رسالة صديقة للمستخدم لا تحتوي على تفاصيل تقنية معقدة
      return const Left(DatabaseFailure('فشل في حفظ الطلب. يرجى المحاولة مرة أخرى.'));
    }
  }
}