import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/features/users/data/datasources/users_local_data_source.dart';
import 'package:ahgzly_pos/features/users/data/repositories/users_repository_impl.dart';
import 'package:ahgzly_pos/features/users/domain/repositories/users_repository.dart';
import 'package:ahgzly_pos/features/users/domain/usecases/add_user_usecase.dart';
import 'package:ahgzly_pos/features/users/domain/usecases/get_users_usecase.dart';
import 'package:ahgzly_pos/features/users/domain/usecases/toggle_user_status_usecase.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_bloc.dart';

void initUsers() {
  sl.registerLazySingleton<UsersLocalDataSource>(
    () => UsersLocalDataSourceImpl(appDatabase: sl()),
  ); // 🪄 تم مسح التعليق الميت
  sl.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => AddUserUseCase(sl()));
  sl.registerLazySingleton(() => ToggleUserStatusUseCase(sl()));
  sl.registerFactory(
    () => UsersBloc(
      getUsersUseCase: sl(),
      addUserUseCase: sl(),
      toggleUserStatusUseCase: sl(),
    ),
  );
}