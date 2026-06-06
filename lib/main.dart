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
        // [Keyboard Fix]: هذا السطر السحري يمنع انضغاط واجهة التطبيق عند صعود الكيبورد في بعض الحالات
        builder: (context, child) {
          return MediaQuery(
            // تحديد حجم الخط الثابت لمنع المستخدم من تكبير الخطوط من إعدادات الهاتف وإفساد الـ POS
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        routerConfig: AppRouter.getRouter(),
      ),
    );
  }
}
