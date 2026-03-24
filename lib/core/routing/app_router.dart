import 'package:ahgzly_pos/features/auth/presentation/pages/login_screen.dart';
import 'package:ahgzly_pos/features/splash/presentation/pages/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/features/license/presentation/pages/license_screen.dart';
import 'package:ahgzly_pos/features/pos/presentation/pages/pos_screen.dart';
import 'package:ahgzly_pos/features/menu/presentation/pages/menu_screen.dart';
import 'package:ahgzly_pos/features/orders/presentation/pages/orders_screen.dart';
import 'package:ahgzly_pos/features/shift/presentation/pages/shift_report_screen.dart';
import 'package:ahgzly_pos/features/expenses/presentation/pages/expenses_screen.dart';
import 'package:ahgzly_pos/features/settings/presentation/pages/settings_screen.dart';

class AppRouter {
  static GoRouter getRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/license',
          builder: (context, state) => const LicenseScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/pos',
          builder: (context, state) => const PosScreen(),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/shift',
          builder: (context, state) => const ShiftReportScreen(),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const ExpensesScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}