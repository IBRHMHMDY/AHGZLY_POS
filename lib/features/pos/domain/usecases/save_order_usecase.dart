import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/check_active_shift_usecase.dart';
import 'package:dartz/dartz.dart' hide Order;

class SaveOrderUseCase {
  final PosRepository posRepository;
  final CheckActiveShiftUseCase checkActiveShiftUseCase;

  SaveOrderUseCase({
    required this.posRepository,
    required this.checkActiveShiftUseCase,
  });

  Future<Either<Failure, int>> call(Order order) async {
    // 1. استخدام הـ UseCase الخاص بالوردية واستدعاء دالة execute()
    final shiftResult = await checkActiveShiftUseCase.execute();
    
    return shiftResult.fold(
      (failure) => Left(failure),
      (activeShift) async {
        if (activeShift == null) {
          // استخدام CacheFailure بالصيغة المعرفة في مشروعك
          return const Left(CacheFailure('يجب فتح وردية جديدة أولاً لإتمام عملية البيع.'));
        }

        // 2. تحديث الطلب ليحتوي على shiftId
        final orderWithShift = Order(
          shiftId: activeShift.id, // تم الربط بالوردية النشطة
          orderType: order.orderType,
          subTotal: order.subTotal,
          discount: order.discount,
          taxAmount: order.taxAmount,
          serviceFee: order.serviceFee,
          deliveryFee: order.deliveryFee,
          total: order.total,
          paymentMethod: order.paymentMethod,
          status: order.status,
          createdAt: order.createdAt,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          customerAddress: order.customerAddress,
          items: order.items,
        );

        return await posRepository.saveOrder(orderWithShift);
      },
    );
  }
}