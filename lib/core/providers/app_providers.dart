import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart' as di;

// استيراد الـ Blocs
import 'package:ahgzly_pos/features/license/presentation/bloc/license_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_bloc.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<LicenseBloc>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<MenuBloc>()),
        BlocProvider(create: (_) => di.sl<PosBloc>()),
        BlocProvider(create: (_) => di.sl<SettingsBloc>()),
        BlocProvider(create: (_) => di.sl<ShiftBloc>()),
        BlocProvider(create: (_) => di.sl<OrdersBloc>()),
        BlocProvider(create: (_) => di.sl<ExpensesBloc>()),
      ],
      child: child,
    );
  }
}