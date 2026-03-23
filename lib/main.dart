import 'dart:io';
import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ahgzly_pos/core/di/injection_container.dart';
import 'core/di/injection_container.dart' as di;
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';

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
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Ahgzly POS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
          fontFamily: 'Cairo',
        ),
        routerConfig: AppRouter().appRouter,
      ),
    );
  }   
}