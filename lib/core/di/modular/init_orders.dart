import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:ahgzly_pos/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:ahgzly_pos/features/orders/domain/repositories/orders_repository.dart';
import 'package:ahgzly_pos/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/usecases/refund_order_usecase.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';

void initOrders() {
  sl.registerLazySingleton<OrdersLocalDataSource>(
    () => OrdersLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => RefundOrderUseCase(sl()));
  sl.registerFactory(
    () => OrdersBloc(getOrdersUseCase: sl(), refundOrderUseCase: sl()),
  );
}