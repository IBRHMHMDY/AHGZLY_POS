import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/di/injection_container.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/pages/menu_management_screen.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/pages/pos_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          // توفير Bloc القائمة وسلة المشتريات لشاشة نقطة البيع
          return MultiBlocProvider(
            providers: [
              // أضفنا استدعاء الحدث فور إنشاء البلوك
              BlocProvider(create: (_) => sl<MenuBloc>()..add(FetchCategoriesEvent())),
              BlocProvider(create: (_) => sl<PosBloc>()),
            ],
            child: const PosScreen(),
          );
        },
      ),
      GoRoute(
        path: '/menu',
        builder: (BuildContext context, GoRouterState state) {
          // شاشة إدارة القائمة تحتاج MenuBloc فقط
          return BlocProvider(
            create: (_) => sl<MenuBloc>()..add(FetchCategoriesEvent()),
            child: const MenuManagementScreen(),
          );
        },
      ),
    ],
  );
}