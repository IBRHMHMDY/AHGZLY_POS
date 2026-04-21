import 'package:ahgzly_pos/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart' as di;
import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:ahgzly_pos/core/init/app_initializer.dart';
import 'package:ahgzly_pos/core/providers/app_providers.dart';

void main() async {
  await AppInitializer.initialize();
  await di.init();
  runApp(AhgzlyPOS());
}

class AhgzlyPOS extends StatelessWidget {
  const AhgzlyPOS({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp.router(
        title: 'احجزلي - نقطة بيع',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar', 'EG'),
        supportedLocales: const [Locale('ar', 'EG')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: AppRouter.getRouter(),
      ),
    );
  }
}