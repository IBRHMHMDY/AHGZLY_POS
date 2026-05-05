import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/purchases/data/datasources/purchases_local_data_source.dart';
import 'package:ahgzly_pos/features/purchases/data/repositories/purchases_repository_impl.dart';
import 'package:ahgzly_pos/features/purchases/domain/repositories/purchases_repository.dart';
import 'package:ahgzly_pos/features/purchases/domain/usecases/purchases_usecases.dart';
import 'package:ahgzly_pos/features/purchases/presentation/bloc/purchases_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void initPurchases() {
  sl.registerLazySingleton<PurchasesLocalDataSource>(
    () => PurchasesLocalDataSourceImpl(appDatabase: sl<AppDatabase>()),
  );

  sl.registerLazySingleton<PurchasesRepository>(
    () => PurchasesRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetPurchaseInvoicesUseCase(sl()));
  sl.registerLazySingleton(() => SavePurchaseInvoiceUseCase(sl()));

  sl.registerFactory(
    () => PurchasesBloc(
      getPurchaseInvoices: sl(),
      savePurchaseInvoice: sl(),
    ),
  );
}
