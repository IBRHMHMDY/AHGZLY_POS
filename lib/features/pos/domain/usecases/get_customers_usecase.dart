import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/core/common/entities/customer_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:dartz/dartz.dart';

class GetCustomersUseCase implements UseCase<List<CustomerEntity>, NoParams> {
  final PosRepository repository;
  GetCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, List<CustomerEntity>>> call(NoParams params) async {
    return await repository.getCustomers();
  }
}