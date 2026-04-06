import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

class AddUserUseCase {
  final UsersRepository repository;
  AddUserUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String name,
    required String role,
    required String pin,
  }) async {
    // يمكن هنا إضافة Validation مستقبلاً (مثل: طول الـ PIN يجب أن يكون 6)
    if (pin.length < 4) {
      return const Left(ValidationFailure('الرمز السري يجب أن يكون 4 أرقام على الأقل'));
    }
    return await repository.addUser(name: name, role: role, pin: pin);
  }
}