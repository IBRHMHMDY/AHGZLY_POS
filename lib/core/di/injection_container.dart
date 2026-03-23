import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // سيتم تسجيل الـ Blocs, UseCases, Repositories, و DataSources هنا في الخطوات القادمة
  
  // مثال (Core):
  // sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
}