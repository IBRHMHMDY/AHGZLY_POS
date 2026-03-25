import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart'; // تم الاستيراد
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login(String pin) async {
    try {
      final user = await localDataSource.loginWithPin(pin);
      return Right(user);
    } on AuthException catch (e) {
      // هنا نلتقط رسالتنا الصافية التي كتبناها بالعربية ونمررها للـ UI
      return Left(AuthFailure(e.message));
    } catch (e) {
      // أي خطأ آخر برمجي غير متوقع
      return Left(const CacheFailure('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(const CacheFailure('فشل تسجيل الخروج. يرجى المحاولة لاحقاً.'));
    }
  }
}