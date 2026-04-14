import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/services/order_calculator_service.dart';
import 'package:ahgzly_pos/features/auth/domain/usecases/unlock_usecase.dart';
import 'package:ahgzly_pos/features/reports/data/datasource/reports_local_data_source.dart';
import 'package:ahgzly_pos/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:ahgzly_pos/features/reports/domain/repositories/reports_repository.dart';
import 'package:ahgzly_pos/features/reports/domain/usecases/get_reports_usecases.dart';
import 'package:ahgzly_pos/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/check_active_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/open_shift_usecase.dart';
import 'package:get_it/get_it.dart';

// ==========================================
// Core & Security Imports
// ==========================================
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
import 'package:ahgzly_pos/core/services/backup_service.dart'; // 🪄 استيراد خدمة النسخ الاحتياطي
import 'package:ahgzly_pos/core/services/security/crypto_service.dart';
import 'package:ahgzly_pos/core/services/security/device_security_service.dart';
import 'package:ahgzly_pos/core/services/security/time_guard_service.dart';

// ==========================================
// License Feature Imports
// ==========================================
import 'package:ahgzly_pos/features/license/data/datasources/license_local_data_source.dart';
import 'package:ahgzly_pos/features/license/data/repositories/license_repository_impl.dart';
import 'package:ahgzly_pos/features/license/domain/repositories/license_repository.dart';
import 'package:ahgzly_pos/features/license/domain/usecases/check_license_status_usecase.dart';
import 'package:ahgzly_pos/features/license/domain/usecases/activate_license_usecase.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_bloc.dart';

// ==========================================
// Auth Feature Imports
// ==========================================
import 'package:ahgzly_pos/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ahgzly_pos/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ahgzly_pos/features/auth/domain/repositories/auth_repository.dart';
import 'package:ahgzly_pos/features/auth/domain/usecases/login_usecase.dart';
import 'package:ahgzly_pos/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';

// ==========================================
// Menu Feature Imports
// ==========================================
import 'package:ahgzly_pos/features/menu/data/datasources/menu_local_data_source.dart';
import 'package:ahgzly_pos/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:ahgzly_pos/features/menu/domain/repositories/menu_repository.dart';
import 'package:ahgzly_pos/features/menu/domain/usecases/category_usecases.dart';
import 'package:ahgzly_pos/features/menu/domain/usecases/item_usecases.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';

// ==========================================
// POS Feature Imports
// ==========================================
import 'package:ahgzly_pos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:ahgzly_pos/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';

// ==========================================
// Settings Feature Imports
// ==========================================
import 'package:ahgzly_pos/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:ahgzly_pos/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:ahgzly_pos/features/settings/domain/repositories/settings_repository.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_bloc.dart';

// ==========================================
// Shift Feature Imports
// ==========================================
import 'package:ahgzly_pos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:ahgzly_pos/features/shift/data/repositories/shift_repository_impl.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/close_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';

// ==========================================
// Orders Feature Imports
// ==========================================
import 'package:ahgzly_pos/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:ahgzly_pos/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:ahgzly_pos/features/orders/domain/repositories/orders_repository.dart';
import 'package:ahgzly_pos/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/usecases/refund_order_usecase.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';

// ==========================================
// Expenses Feature Imports
// ==========================================
import 'package:ahgzly_pos/features/expenses/data/datasources/expenses_local_data_source.dart';
import 'package:ahgzly_pos/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/get_today_expenses_usecase.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_bloc.dart';

// ==========================================
// Users Feature Imports
// ==========================================
import 'package:ahgzly_pos/features/users/data/datasources/users_local_data_source.dart';
import 'package:ahgzly_pos/features/users/data/repositories/users_repository_impl.dart';
import 'package:ahgzly_pos/features/users/domain/repositories/users_repository.dart';
import 'package:ahgzly_pos/features/users/domain/usecases/get_users_usecase.dart';
import 'package:ahgzly_pos/features/users/domain/usecases/add_user_usecase.dart';
import 'package:ahgzly_pos/features/users/domain/usecases/toggle_user_status_usecase.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  _initCore();
  _initLicense();
  _initAuth();
  _initMenu();
  _initShift();
  _initPos();
  _initSettings();
  _initOrders();
  _initExpenses();
  _initUsers();
  _initReports();
}

// ==========================================
// Core & Security Registrations
// ==========================================
void _initCore() {
  sl.registerLazySingleton<AppDatabase>(
    () => AppDatabase(openConnection('pos_sys_drift.db')),
  );
  sl.registerLazySingleton<PrinterService>(() => PrinterService());
  sl.registerLazySingleton<BackupService>(
    () => BackupService(appDatabase: sl()),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<CryptoService>(() => CryptoService());
  sl.registerLazySingleton<DeviceSecurityService>(
    () => DeviceSecurityService(sl()),
  );
  sl.registerLazySingleton<TimeGuardService>(() => TimeGuardService(sl()));
  sl.registerLazySingleton(() => OrderCalculatorService());
}

// ==========================================
// Features Registrations
// ==========================================
void _initLicense() {
  sl.registerLazySingleton<LicenseLocalDataSource>(
    () => LicenseLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<LicenseRepository>(
    () => LicenseRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(
    () => CheckLicenseStatusUseCase(
      cryptoService: sl(),
      deviceSecurityService: sl(),
      repository: sl(),
      timeGuardService: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => ActivateLicenseUseCase(
      cryptoService: sl(),
      deviceSecurityService: sl(),
      repository: sl(),
    ),
  );
  sl.registerFactory(
    () => LicenseBloc(
      checkLicenseStatusUseCase: sl(),
      activateLicenseUseCase: sl(),
    ),
  );
}

void _initAuth() {
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(appDatabase: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => UnlockUseCase(sl()));
  sl.registerLazySingleton(
    () =>
        AuthBloc(loginUseCase: sl(), logoutUseCase: sl(), unlockUseCase: sl()),
  );
}

void _initMenu() {
  sl.registerLazySingleton<MenuLocalDataSource>(
    () => MenuLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteItemUseCase(sl()));
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
}

void _initPos() {
  sl.registerLazySingleton<PosLocalDataSource>(
    () => PosLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<PosRepository>(
    () => PosRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(
    () => SaveOrderUseCase(posRepository: sl(), checkActiveShiftUseCase: sl()),
  );
  sl.registerFactory(
    () => PosBloc(saveOrderUseCase: sl(), getSettingsUseCase: sl(), calculatorService: sl(),),
  );
}

void _initSettings() {
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSettingsUseCase(sl()));
  sl.registerFactory(
    () => SettingsBloc(getSettingsUseCase: sl(), updateSettingsUseCase: sl()),
  );
}

void _initShift() {
  sl.registerLazySingleton<ShiftLocalDataSource>(
    () => ShiftLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<ShiftRepository>(
    () => ShiftRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => CheckActiveShiftUseCase(sl()));
  sl.registerLazySingleton(() => OpenShiftUseCase(sl()));
  sl.registerLazySingleton(() => CloseShiftUseCase(sl()));
  sl.registerFactory(
    () => ShiftBloc(
      checkActiveShiftUseCase: sl(),
      openShiftUseCase: sl(),
      closeShiftUseCase: sl(),
    ),
  );
}

void _initOrders() {
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

void _initExpenses() {
  sl.registerLazySingleton<ExpensesLocalDataSource>(
    () => ExpensesLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<ExpensesRepository>(
    () => ExpensesRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(
    () => AddExpenseUseCase(sl()),
  ); // 🪄 تم مسح الفاصلة الزائدة
  sl.registerLazySingleton(() => DeleteExpenseUseCase(sl()));
  sl.registerLazySingleton(() => GetTodayExpensesUseCase(sl()));
  sl.registerFactory(
    () => ExpensesBloc(
      addExpenseUseCase: sl(),
      deleteExpenseUseCase: sl(),
      getTodayExpensesUseCase: sl(),
    ),
  );
}

void _initUsers() {
  sl.registerLazySingleton<UsersLocalDataSource>(
    () => UsersLocalDataSourceImpl(appDatabase: sl()),
  ); // 🪄 تم مسح التعليق الميت
  sl.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => AddUserUseCase(sl()));
  sl.registerLazySingleton(() => ToggleUserStatusUseCase(sl()));
  sl.registerFactory(
    () => UsersBloc(
      getUsersUseCase: sl(),
      addUserUseCase: sl(),
      toggleUserStatusUseCase: sl(),
    ),
  );
}

void _initReports() {
  sl.registerLazySingleton<ReportsLocalDataSource>(
    () => ReportsLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetSummaryReportUseCase(sl()));
  sl.registerLazySingleton(() => GetItemSalesReportUseCase(sl()));
  sl.registerFactory(
    () => ReportsBloc(
      getSummaryReportUseCase: sl(),
      getItemSalesReportUseCase: sl(),
    ),
  );
}
