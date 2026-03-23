import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // ==========================================
  // Core
  // ==========================================
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  
  // سيتم إضافة الباقي (Blocs, Repositories, DataSources) هنا في الخطوات القادمة
}