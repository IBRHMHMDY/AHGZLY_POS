import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      await windowManager.maximize(); 
    });
  }

  // 🪄 نظام فحص التراخيص والفترة التجريبية (المحمي ضد التلاعب)
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;
  final licenseData = await db.query('license');
  
  bool isActivated = false;
  bool isTrialExpired = false;
  int elapsedDays = 0;

  if (licenseData.isNotEmpty) {
    isActivated = licenseData.first['is_activated'] == 1;
    final trialStartStr = licenseData.first['trial_start_date'] as String;

    if (!isActivated && trialStartStr.isNotEmpty) {
      try {
        final trialStart = DateTime.parse(trialStartStr);
        final difference = DateTime.now().difference(trialStart);
        elapsedDays = difference.inDays;

        // حماية التلاعب بالزمن: إذا رجع بالزمن للوراء (سالب) أو تجاوز 37 يوم
        if (elapsedDays > 37 || elapsedDays < 0) {
          isTrialExpired = true;
          await dbHelper.clearFinancialData(); // تنفيذ العقوبة
        }
      } catch (e) {
        // حماية إضافية: إذا قام المستخدم بتعديل التاريخ في قاعدة البيانات لنص غير مفهوم
        isTrialExpired = true;
        await dbHelper.clearFinancialData();
      }
    }
  } else {
    // 🚨🚨 ثغرة الحذف: تم اكتشاف تلاعب حيث قام المستخدم بحذف السجل بالكامل!
    isTrialExpired = true; 
    
    // إعادة إنشاء السجل ولكن بتاريخ منتهي (منذ 40 يوماً) لضمان عدم عودته للعمل
    await db.insert('license', {
      'id': 1,
      'is_activated': 0,
      'license_key': '',
      'trial_start_date': DateTime.now().subtract(const Duration(days: 40)).toIso8601String()
    });
    
    await dbHelper.clearFinancialData(); // تنفيذ العقوبة فوراً
  }

  runApp(MyApp(
    isActivated: isActivated,
    isTrialExpired: isTrialExpired,
    elapsedDays: elapsedDays,
  ));
}

class MyApp extends StatelessWidget {
  final bool isActivated;
  final bool isTrialExpired;
  final int elapsedDays;

  const MyApp({
    super.key, 
    required this.isActivated,
    required this.isTrialExpired,
    required this.elapsedDays,
  });

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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar', 'EG')],
        locale: const Locale('ar', 'EG'),
        
        // تمرير حالات الترخيص للموجه
        routerConfig: AppRouter.getRouter(
          isActivated: isActivated, 
          isTrialExpired: isTrialExpired, 
          elapsedDays: elapsedDays,
        ),
      ),
    );
  }
}