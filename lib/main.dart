import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/di/injection_container.dart' as di;
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة SQLite لدعم نظام التشغيل Windows
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // تهيئة حقن التبعيات (Dependency Injection)
  await di.init();

  runApp(const AhgzlyPosApp());
}

class AhgzlyPosApp extends StatelessWidget {
  const AhgzlyPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ahgzly POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Cairo', // يفضل إضافة خط عربي لاحقاً
      ),
      routerConfig: AppRouter.router,
    );
  }
}