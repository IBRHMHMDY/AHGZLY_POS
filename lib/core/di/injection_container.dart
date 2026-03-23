import 'package:ahgzly_pos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:ahgzly_pos/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';

// Menu
import '../../features/menu/data/datasources/menu_local_data_source.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/domain/usecases/category_usecases.dart';
import '../../features/menu/domain/usecases/item_usecases.dart';
import '../../features/menu/presentation/bloc/menu_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // ==========================================
  // Core
  // ==========================================
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // ==========================================
  // Features - Menu
  // ==========================================
  
  // Bloc
  sl.registerFactory(() => MenuBloc(
        getCategories: sl(),
        addCategory: sl(),
        updateCategory: sl(),
        deleteCategory: sl(),
        getItems: sl(),
        addItem: sl(),
        updateItem: sl(),
        deleteItem: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  
  sl.registerLazySingleton(() => GetItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteItemUseCase(sl()));

  // Repository
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<MenuLocalDataSource>(
    () => MenuLocalDataSourceImpl(databaseHelper: sl()),
  );

// ==========================================
  // Features - POS (نقطة البيع)
  // ==========================================
  
  // Bloc
  sl.registerFactory(() => PosBloc(saveOrderUseCase: sl()));

  // UseCases
  sl.registerLazySingleton(() => SaveOrderUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PosRepository>(
    () => PosRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<PosLocalDataSource>(
    () => PosLocalDataSourceImpl(databaseHelper: sl()),
  );


}