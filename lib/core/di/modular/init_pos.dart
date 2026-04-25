import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:ahgzly_pos/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/get_customers_usecase.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/get_payment_methods_usecase.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';

void initPos() {
  sl.registerLazySingleton<PosLocalDataSource>(
    () => PosLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<PosRepository>(
    () => PosRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(
    () => SaveOrderUseCase(posRepository: sl(), checkActiveShiftUseCase: sl()),
  );

  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentMethodsUseCase(sl()));
  sl.registerFactory(
    () => PosBloc(
      saveOrderUseCase: sl(),
      getSettingsUseCase: sl(),
      getCategoriesUseCase: sl(),
      getCustomersUseCase: sl(),
      getItemsUseCase: sl(),
      getPaymentMethodsUseCase: sl(),
    ),
  );
}