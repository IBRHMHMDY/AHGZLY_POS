import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/check_active_shift_usecase.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';

// Refactored: Implement UseCase Interface & Add Domain Validation
class SaveOrderUseCase implements UseCase<int, SaveOrderParams> {
  final PosRepository posRepository;
  final CheckActiveShiftUseCase checkActiveShiftUseCase;

  SaveOrderUseCase({
    required this.posRepository,
    required this.checkActiveShiftUseCase,
  });

  @override
  Future<Either<Failure, int>> call(SaveOrderParams params) async {
    // 🛡️ حماية مالية صارمة: لا يمكن حفظ طلب بإجمالي سالب
    if (params.order.total < 0) {
      return const Left(ValidationFailure('لا يمكن إتمام البيع، إجمالي الطلب بالسالب!'));
    }

    final shiftResult = await checkActiveShiftUseCase(NoParams());
    
    return shiftResult.fold(
      (failure) => Left(failure),
      (activeShift) async {
        if (activeShift == null) {
          // Refactored: استخدام ValidationFailure بدلاً من CacheFailure لدقة التعبير
          return const Left(ValidationFailure('يجب فتح وردية جديدة أولاً لإتمام عملية البيع.'));
        }

        final orderWithShift = Order(
          shiftId: activeShift.id, 
          orderType: params.order.orderType,
          subTotal: params.order.subTotal,
          discount: params.order.discount,
          taxAmount: params.order.taxAmount,
          serviceFee: params.order.serviceFee,
          deliveryFee: params.order.deliveryFee,
          total: params.order.total,
          paymentMethod: params.order.paymentMethod,
          status: params.order.status,
          createdAt: params.order.createdAt,
          customerName: params.order.customerName,
          customerPhone: params.order.customerPhone,
          customerAddress: params.order.customerAddress,
          items: params.order.items,
        );

        return await posRepository.saveOrder(orderWithShift);
      },
    );
  }
}

class SaveOrderParams extends Equatable {
  final Order order;
  const SaveOrderParams({required this.order});
  @override List<Object> get props => [order];
}