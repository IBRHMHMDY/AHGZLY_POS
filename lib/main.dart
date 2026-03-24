import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ⬅️ الاستيراد الجديد

import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/core/di/injection_container.dart' as di;
import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // 1. تهيئة نافذة الويندوز (تكبير الشاشة Kiosk Mode)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1024, 768),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Ahgzly POS System',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize(); // تكبير الشاشة بالكامل للكاشير
    });
  }

  // 2. التحقق من التفعيل (License Check)
  final db = await DatabaseHelper().database;
  final licenseData = await db.query('license');
  bool isActivated = false;
  if (licenseData.isNotEmpty) {
    isActivated = licenseData.first['is_activated'] == 1;
  }

  runApp(AhgzlyPosApp(isActivated: isActivated));
}

class AhgzlyPosApp extends StatelessWidget {
  final bool isActivated;
  const AhgzlyPosApp({super.key, required this.isActivated});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<MenuBloc>()),
        BlocProvider(create: (_) => di.sl<PosBloc>()),
        BlocProvider(create: (_) => di.sl<SettingsBloc>()),
        BlocProvider(create: (_) => di.sl<ShiftBloc>()),
        BlocProvider(create: (_) => di.sl<OrdersBloc>()),
        BlocProvider(create: (_) => di.sl<ExpensesBloc>()),
      ],
      child: MaterialApp.router(
        title: 'احجزلي - نقطة بيع',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
          fontFamily: 'Cairo', 
        ),
        // ==========================================
        // 🪄 السحر هنا: تحويل التطبيق بالكامل للغة العربية (RTL)
        // ==========================================
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'EG'), // دعم اللغة العربية - مصر
        ],
        // locale: const Locale('ar', 'EG'), // إجبار النظام على العمل بالعربية
        // ==========================================
        routerConfig: AppRouter.getRouter(isActivated),
      ),
    );
  }
}