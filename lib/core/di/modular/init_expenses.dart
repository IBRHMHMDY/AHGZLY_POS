import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/features/expenses/data/datasources/expenses_local_data_source.dart';
import 'package:ahgzly_pos/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/get_today_expenses_usecase.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_bloc.dart';

void initExpenses() {
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