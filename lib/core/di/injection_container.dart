import 'package:get_it/get_it.dart';
import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart'; // تأكد من وجود الـ import

// Menu Imports
import 'package:ahgzly_pos/features/menu/data/datasources/menu_local_data_source.dart';
import 'package:ahgzly_pos/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:ahgzly_pos/features/menu/domain/repositories/menu_repository.dart';
import 'package:ahgzly_pos/features/menu/domain/usecases/category_usecases.dart';
import 'package:ahgzly_pos/features/menu/domain/usecases/item_usecases.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';

// POS Imports
import 'package:ahgzly_pos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:ahgzly_pos/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';

// Shifts Management
import 'package:ahgzly_pos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:ahgzly_pos/features/shift/data/repositories/shift_repository_impl.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/get_z_report_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/close_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================================
  // Core (يجب تسجيل الخدمات الأساسية أولاً)
  // ==========================================
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  
  // تأكد أن هذا السطر موجود هنا وليس داخل دالة أخرى
  sl.registerLazySingleton<PrinterService>(() => PrinterService());

  // ==========================================
  // Features - Menu
  // ==========================================
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

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteItemUseCase(sl()));

  sl.registerLazySingleton<MenuRepository>(() => MenuRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<MenuLocalDataSource>(() => MenuLocalDataSourceImpl(databaseHelper: sl()));

  // ==========================================
  // Features - POS
  // ==========================================
  sl.registerFactory(() => PosBloc(saveOrderUseCase: sl()));
  sl.registerLazySingleton(() => SaveOrderUseCase(sl()));
  sl.registerLazySingleton<PosRepository>(() => PosRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<PosLocalDataSource>(() => PosLocalDataSourceImpl(databaseHelper: sl()));

  // ==========================================
  // Features - Shift Management (الورديات)
  // ==========================================
  sl.registerFactory(() => ShiftBloc(getZReportUseCase: sl(),closeShiftUseCase: sl(),));
  sl.registerLazySingleton(() => GetZReportUseCase(sl()));
  sl.registerLazySingleton(() => CloseShiftUseCase(sl()));
  sl.registerLazySingleton<ShiftRepository>(() => ShiftRepositoryImpl(localDataSource: sl()),);
  sl.registerLazySingleton<ShiftLocalDataSource>(() => ShiftLocalDataSourceImpl(databaseHelper: sl()),);
}