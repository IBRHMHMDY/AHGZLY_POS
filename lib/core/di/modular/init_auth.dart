import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ahgzly_pos/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ahgzly_pos/features/auth/domain/repositories/auth_repository.dart';
import 'package:ahgzly_pos/features/auth/domain/usecases/login_usecase.dart';
import 'package:ahgzly_pos/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';

void initAuth() {
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(appDatabase: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(loginUseCase: sl(), logoutUseCase: sl()),
  );
}