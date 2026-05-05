import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/reports/data/datasources/reports_local_data_source.dart';
import 'package:ahgzly_pos/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void initReports() {
  sl.registerLazySingleton<ReportsLocalDataSource>(
    () => ReportsLocalDataSourceImpl(db: sl<AppDatabase>()),
  );

  sl.registerFactory(
    () => ReportsBloc(dataSource: sl()),
  );
}
