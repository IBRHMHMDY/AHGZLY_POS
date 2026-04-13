// مسار الملف: lib/features/pos/domain/usecases/save_order_usecase.dart

import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/check_active_shift_usecase.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';

class SaveOrderUseCase implements UseCase<int, SaveOrderParams> {
  final PosRepository posRepository;
  final CheckActiveShiftUseCase checkActiveShiftUseCase;

  SaveOrderUseCase({
    required this.posRepository,
    required this.checkActiveShiftUseCase,
  });

  @override
  Future<Either<Failure, int>> call(SaveOrderParams params) async {
    // 🛡️ استخدام قواعد العمل الموجودة داخل الكيان نفسه بدلاً من تكرارها
    if (!params.order.isValid) {
      return const Left(ValidationFailure('لا يمكن إتمام البيع، السلة فارغة أو الإجمالي بالسالب!'));
    }

    final shiftResult = await checkActiveShiftUseCase(NoParams());
    
    return shiftResult.fold(
      (failure) => Left(failure),
      (activeShift) async {
        if (activeShift == null) {
          return const Left(ValidationFailure('يجب فتح وردية جديدة أولاً لإتمام عملية البيع.'));
        }

        // [Refactored]: استخدام دالة copyWithShift بدلاً من إعادة تمرير المتغيرات يدوياً
        // هذا يحافظ على مبدأ DRY (Don't Repeat Yourself) ويمنع نسيان أي حقل مستقبلاً
        final orderWithShift = params.order.copyWithShift(activeShift.id);

        return await posRepository.saveOrder(orderWithShift);
      },
    );
  }
}

class SaveOrderParams extends Equatable {
  final OrderEntity order;
  const SaveOrderParams({required this.order});
  @override List<Object> get props => [order];
}