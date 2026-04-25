import 'package:go_router/go_router.dart';

// ==========================================
// 🪄 Features Screens Imports
// ==========================================
import 'package:ahgzly_pos/features/splash/presentation/screens/splash_screen.dart';
import 'package:ahgzly_pos/features/license/presentation/screens/license_screen.dart';
import 'package:ahgzly_pos/features/auth/presentation/screens/login_screen.dart';
import 'package:ahgzly_pos/features/auth/presentation/screens/lock_screen.dart';
import 'package:ahgzly_pos/features/shift/presentation/screens/open_shift_screen.dart';
import 'package:ahgzly_pos/features/shift/presentation/screens/shift_report_screen.dart';
import 'package:ahgzly_pos/features/pos/presentation/screens/pos_screen.dart';
import 'package:ahgzly_pos/features/menu/presentation/screens/menu_screen.dart';
import 'package:ahgzly_pos/features/orders/presentation/screens/orders_screen.dart';
import 'package:ahgzly_pos/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:ahgzly_pos/features/users/presentation/screens/users_screen.dart';
import 'package:ahgzly_pos/features/settings/presentation/screens/settings_screen.dart';

/// 🛣️ مسارات التطبيق (Route Constants)
abstract class AppRoutes {
  static const String splash = '/';
  static const String license = '/license';
  static const String login = '/login';
  static const String lock = '/lock';
  static const String openShift = '/open-shift';
  static const String shift = '/shift';
  static const String pos = '/pos';
  static const String menu = '/menu';
  static const String orders = '/orders';
  static const String expenses = '/expenses';
  static const String users = '/users';
  static const String settings = '/settings';
}

/// 🗺️ مدير التوجيه المركزي (Router Configuration)
class AppRouter {
  static GoRouter getRouter() {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      // يمكن تفعيل الـ debugLogDiagnostics في وضع التطوير فقط
      debugLogDiagnostics: false, 
      routes: [
        // -- Initial & Licensing --
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.license,
          builder: (context, state) {
            final errorMessage = state.extra as String?;
            return LicenseScreen(errorMessage: errorMessage);
          },
        ),

        // -- Authentication --
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.lock,
          builder: (context, state) => const LockScreen(),
        ),

        // -- Shift Management --
        GoRoute(
          path: AppRoutes.openShift,
          builder: (context, state) {
            final cashierId = state.extra as int? ?? 1;
            return OpenShiftScreen(cashierId: cashierId);
          },
        ),
        GoRoute(
          path: AppRoutes.shift,
          builder: (context, state) => const ShiftReportScreen(),
        ),

        // -- Main POS Operations --
        GoRoute(
          path: AppRoutes.pos,
          builder: (context, state) => const PosScreen(),
        ),
        GoRoute(
          path: AppRoutes.menu,
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: AppRoutes.orders,
          builder: (context, state) => const OrdersScreen(),
        ),

        // -- Management & Finance --
        GoRoute(
          path: AppRoutes.expenses,
          builder: (context, state) => const ExpensesScreen(),
        ),
        GoRoute(
          path: AppRoutes.users,
          builder: (context, state) => const UsersScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}