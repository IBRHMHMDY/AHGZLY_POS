import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:ahgzly_pos/core/di/dependency_injection.dart' as di;
import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:ahgzly_pos/core/init/app_initializer.dart';
import 'package:ahgzly_pos/core/providers/app_providers.dart';

void main() async {
  // 1. تهيئة بيئة التطبيق (نوافذ، قاعدة بيانات، وغيرها)
  await AppInitializer.initialize();

  // 2. تهيئة حقن التبعيات
  await di.init();

  // 3. تشغيل التطبيق
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // تم تغليف MaterialApp بـ AppProviders
    return AppProviders(
      child: MaterialApp.router(
        title: 'احجزلي - نقطة بيع',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
          fontFamily: 'Cairo', 
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar', 'EG')],
        locale: const Locale('ar', 'EG'),
        routerConfig: AppRouter.getRouter(),
      ),
    );
  }
}