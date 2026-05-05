import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/suppliers/data/datasources/suppliers_local_data_source.dart';
import 'package:ahgzly_pos/features/suppliers/data/repositories/suppliers_repository_impl.dart';
import 'package:ahgzly_pos/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:ahgzly_pos/features/suppliers/domain/usecases/suppliers_usecases.dart';
import 'package:ahgzly_pos/features/suppliers/presentation/bloc/suppliers_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void initSuppliers() {
  sl.registerLazySingleton<SuppliersLocalDataSource>(
    () => SuppliersLocalDataSourceImpl(appDatabase: sl<AppDatabase>()),
  );

  sl.registerLazySingleton<SuppliersRepository>(
    () => SuppliersRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetSuppliersUseCase(sl()));
  sl.registerLazySingleton(() => AddSupplierUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSupplierUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSupplierUseCase(sl()));

  sl.registerFactory(
    () => SuppliersBloc(
      getSuppliers: sl(),
      addSupplier: sl(),
      updateSupplier: sl(),
      deleteSupplier: sl(),
    ),
  );
}
