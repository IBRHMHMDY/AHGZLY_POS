import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:ahgzly_pos/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void initDashboard() {
  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(db: sl<AppDatabase>()),
  );

  sl.registerFactory(
    () => DashboardBloc(dataSource: sl()),
  );
}
