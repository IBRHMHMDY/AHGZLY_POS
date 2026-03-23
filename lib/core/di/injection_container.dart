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

// Settings
import 'package:ahgzly_pos/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:ahgzly_pos/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:ahgzly_pos/features/settings/domain/repositories/settings_repository.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_bloc.dart';
// OrdersHistory
import 'package:ahgzly_pos/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:ahgzly_pos/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:ahgzly_pos/features/orders/domain/repositories/orders_repository.dart';
import 'package:ahgzly_pos/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ahgzly_pos/features/orders/domain/usecases/refund_order_usecase.dart';
// Auth
import 'package:ahgzly_pos/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ahgzly_pos/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ahgzly_pos/features/auth/domain/repositories/auth_repository.dart';
import 'package:ahgzly_pos/features/auth/domain/usecases/login_usecase.dart';
import 'package:ahgzly_pos/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';

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
  sl.registerFactory(
    () => MenuBloc(
      getCategories: sl(),
      addCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
      getItems: sl(),
      addItem: sl(),
      updateItem: sl(),
      deleteItem: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteItemUseCase(sl()));

  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<MenuLocalDataSource>(
    () => MenuLocalDataSourceImpl(databaseHelper: sl()),
  );

  // ==========================================
  // Features - POS
  // ==========================================
  sl.registerFactory(
    () => PosBloc(saveOrderUseCase: sl(), getSettingsUseCase: sl()),
  );
  sl.registerLazySingleton(() => SaveOrderUseCase(sl()));
  sl.registerLazySingleton<PosRepository>(
    () => PosRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<PosLocalDataSource>(
    () => PosLocalDataSourceImpl(databaseHelper: sl()),
  );

  // ==========================================
  // Features - Shift Management (الورديات)
  // ==========================================
  sl.registerFactory(
    () => ShiftBloc(getZReportUseCase: sl(), closeShiftUseCase: sl()),
  );
  sl.registerLazySingleton(() => GetZReportUseCase(sl()));
  sl.registerLazySingleton(() => CloseShiftUseCase(sl()));
  sl.registerLazySingleton<ShiftRepository>(
    () => ShiftRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ShiftLocalDataSource>(
    () => ShiftLocalDataSourceImpl(databaseHelper: sl()),
  );

  // ==========================================
  // Features - Settings (الإعدادات)
  // ==========================================
  sl.registerFactory(
    () => SettingsBloc(getSettingsUseCase: sl(), updateSettingsUseCase: sl()),
  );
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSettingsUseCase(sl()));
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(databaseHelper: sl()),
  );

  // ==========================================
  // Features - Orders History (سجل الطلبات)
  // ==========================================
  sl.registerFactory(
    () => OrdersBloc(getOrdersUseCase: sl(), refundOrderUseCase: sl()),
  );
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => RefundOrderUseCase(sl())); // أضفنا هذا السطر
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<OrdersLocalDataSource>(
    () => OrdersLocalDataSourceImpl(databaseHelper: sl()),
  );

  // ==========================================
  // Features - Auth (المصادقة)
  // ==========================================
  // نجعله LazySingleton لكي نتمكن من الوصول إليه في كل الشاشات لمعرفة الصلاحية
  sl.registerLazySingleton(
    () => AuthBloc(loginUseCase: sl(), logoutUseCase: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(databaseHelper: sl()),
  );
}
