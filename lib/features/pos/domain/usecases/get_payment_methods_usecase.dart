import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/core/common/entities/payment_method_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:dartz/dartz.dart';

class GetPaymentMethodsUseCase implements UseCase<List<PaymentMethodEntity>, NoParams> {
  final PosRepository repository;
  GetPaymentMethodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> call(NoParams params) async {
    return await repository.getPaymentMethods();
  }
}