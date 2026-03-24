import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart'; 
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // ⬅️ استيراد مكتبة الويندوز

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

  // ==============================================================
  // 🛠️ الحل هنا: تهيئة محرك قاعدة بيانات الويندوز قبل أي شيء آخر
  // ==============================================================
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
      await windowManager.setFullScreen(true);
    });
  }

  // ==============================================================
  // 🪄 نظام الحماية المزدوج (قاعدة البيانات + الملف المخفي)
  // ==============================================================
  final dbPath = await getDatabasesPath(); // الآن لن يظهر أي خطأ بفضل التهيئة في الأعلى
  final hiddenFile = File(join(dbPath, '.sys_auth_config')); 
  
  String hiddenDate = '';
  if (await hiddenFile.exists()) {
    hiddenDate = await hiddenFile.readAsString();
  }

  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;
  final licenseData = await db.query('license');
  
  bool isActivated = false;
  bool isTrialExpired = false;
  int elapsedDays = 0;
  
  String dbDate = '';
  if (licenseData.isNotEmpty) {
    isActivated = licenseData.first['is_activated'] == 1;
    dbDate = licenseData.first['trial_start_date'] as String;
  }

  String trueStartDateStr = '';

  if (hiddenDate.isNotEmpty) {
    trueStartDateStr = hiddenDate;
    // 🚨 تم اكتشاف محاولة تلاعب: العميل حذف قاعدة البيانات لتبدأ من جديد!
    if (dbDate != hiddenDate && !isActivated) {
      if (licenseData.isEmpty) {
        await db.insert('license', {'id': 1, 'is_activated': 0, 'license_key': '', 'trial_start_date': hiddenDate});
      } else {
        await db.update('license', {'trial_start_date': hiddenDate}, where: 'id = 1');
      }
    }
  } else if (dbDate.isNotEmpty) {
    // تشغيل طبيعي لأول مرة (تم إنشاء الداتابيز للتو)، نحفظ التاريخ في الملف المخفي
    trueStartDateStr = dbDate;
    await hiddenFile.writeAsString(dbDate); 
  } else {
    // 🚨🚨 تلاعب مدمر: العميل بحث وحذف الداتابيز وحذف الملف المخفي أيضاً!
    trueStartDateStr = DateTime.now().subtract(const Duration(days: 40)).toIso8601String(); // عقاب فوري بالمنع
    await hiddenFile.writeAsString(trueStartDateStr);
    if (licenseData.isEmpty) {
      await db.insert('license', {'id': 1, 'is_activated': 0, 'license_key': '', 'trial_start_date': trueStartDateStr});
    } else {
      await db.update('license', {'trial_start_date': trueStartDateStr}, where: 'id = 1');
    }
  }

  // حساب الأيام وتنفيذ العقوبة إن لزم الأمر
  if (!isActivated) {
    try {
      final trialStart = DateTime.parse(trueStartDateStr);
      final difference = DateTime.now().difference(trialStart);
      elapsedDays = difference.inDays;

      // حماية من إرجاع ساعة الكمبيوتر للوراء أو تجاوز المدة
      if (elapsedDays > 37 || elapsedDays < 0) {
        isTrialExpired = true;
        await dbHelper.clearFinancialData(); // تنفيذ العقوبة بتصفير الأموال
      }
    } catch (e) {
      isTrialExpired = true;
      await dbHelper.clearFinancialData();
    }
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
        
        routerConfig: AppRouter.getRouter(
          isActivated: isActivated, 
          isTrialExpired: isTrialExpired, 
          elapsedDays: elapsedDays,
        ),
      ),
    );
  }
}