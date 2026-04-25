import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:ahgzly_pos/features/shift/data/repositories/shift_repository_impl.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/check_active_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/close_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/open_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';

void initShift() {
  sl.registerLazySingleton<ShiftLocalDataSource>(
    () => ShiftLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<ShiftRepository>(
    () => ShiftRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => CheckActiveShiftUseCase(sl()));
  sl.registerLazySingleton(() => OpenShiftUseCase(sl()));
  sl.registerLazySingleton(() => CloseShiftUseCase(sl()));
  sl.registerFactory(
    () => ShiftBloc(
      checkActiveShiftUseCase: sl(),
      openShiftUseCase: sl(),
      closeShiftUseCase: sl(),
    ),
  );
}