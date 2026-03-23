import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/di/injection_container.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/pages/menu_management_screen.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/pages/pos_screen.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_event.dart';
import 'package:ahgzly_pos/features/shift/presentation/pages/shift_report_screen.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_event.dart';
import 'package:ahgzly_pos/features/settings/presentation/pages/settings_screen.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_event.dart';
import 'package:ahgzly_pos/features/orders/presentation/pages/orders_screen.dart';
import 'package:ahgzly_pos/features/auth/presentation/pages/login_screen.dart';

class AppRouter {
  final appRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/pos',
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
      GoRoute(
        path: '/shift',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => sl<ShiftBloc>()..add(LoadZReportEvent()),
            child: const ShiftReportScreen(),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => sl<SettingsBloc>()..add(LoadSettingsEvent()),
            child: const SettingsScreen(),
          );
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => sl<OrdersBloc>()..add(LoadOrdersEvent()),
            child: const OrdersScreen(),
          );
        },
      ),
    ],
  );
}