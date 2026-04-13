import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/auth/domain/repositories/auth_repository.dart';

class UnlockParams {
  final String pin;
  final User currentUser;
  UnlockParams({required this.pin, required this.currentUser});
}

class UnlockUseCase implements UseCase<User, UnlockParams> {
  final AuthRepository repository;

  UnlockUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UnlockParams params) async {
    // 1. التحقق من الـ PIN عبر المستودع
    final result = await repository.login(params.pin);
    
    // 2. تطبيق منطق العمل (Business Logic) الخاص بفك القفل
    return result.bind((user) {
      if (user.id == params.currentUser.id || user.isAdmin) {
        return Right(user); // مسموح بالدخول
      } else {
        return Left(AuthFailure('يجب إدخال الرمز الخاص بك (${params.currentUser.name}) أو رمز المدير'));
      }
    });
  }
}