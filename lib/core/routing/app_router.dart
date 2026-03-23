import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/di/injection_container.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/pages/menu_management_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/menu', // سنجعلها الشاشة الافتراضية مؤقتاً للتجربة
    routes: [
      GoRoute(
        path: '/menu',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => sl<MenuBloc>()..add(FetchCategoriesEvent()),
            child: const MenuManagementScreen(),
          );
        },
      ),
    ],
  );
}