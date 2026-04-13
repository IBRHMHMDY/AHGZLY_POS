import 'package:ahgzly_pos/core/common/users/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';

abstract class UsersRepository {
  Future<Either<Failure, List<User>>> getUsers();
  
  // نمرر الـ PIN كـ String عادي، ومسؤولية الـ Repository هي تشفيره
  Future<Either<Failure, void>> addUser({
    required String name,
    required String role,
    required String pin,
  });
  
  Future<Either<Failure, void>> toggleUserStatus(int id, bool isActive);
}