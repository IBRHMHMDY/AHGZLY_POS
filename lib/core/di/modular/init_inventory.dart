import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/inventory/data/datasources/inventory_local_data_source.dart';
import 'package:ahgzly_pos/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:ahgzly_pos/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:ahgzly_pos/features/inventory/domain/usecases/inventory_items_usecases.dart';
import 'package:ahgzly_pos/features/inventory/domain/usecases/recipe_usecases.dart';
import 'package:ahgzly_pos/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void initInventory() {
  // Data sources
  sl.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSourceImpl(appDatabase: sl<AppDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetInventoryItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddInventoryItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInventoryItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteInventoryItemUseCase(sl()));
  sl.registerLazySingleton(() => GetRecipesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllMenuEntitiesUseCase(sl()));
  sl.registerLazySingleton(() => AddRecipeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRecipeUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => InventoryBloc(
      getInventoryItems: sl(),
      addInventoryItem: sl(),
      updateInventoryItem: sl(),
      deleteInventoryItem: sl(),
      getRecipes: sl(),
      getAllMenuEntities: sl(),
      addRecipe: sl(),
      deleteRecipe: sl(),
    ),
  );
}
