import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/customers/data/datasources/customers_local_data_source.dart';
import 'package:ahgzly_pos/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void initCustomers() {
  sl.registerLazySingleton<CustomersLocalDataSource>(
    () => CustomersLocalDataSourceImpl(db: sl<AppDatabase>()),
  );

  sl.registerFactory(
    () => CustomersBloc(dataSource: sl()),
  );
}
