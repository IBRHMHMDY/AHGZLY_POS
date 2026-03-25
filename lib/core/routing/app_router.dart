import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/features/auth/presentation/pages/login_screen.dart';
import 'package:ahgzly_pos/features/splash/presentation/pages/splash_screen.dart';
import 'package:ahgzly_pos/features/license/presentation/pages/license_screen.dart';
import 'package:ahgzly_pos/features/pos/presentation/pages/pos_screen.dart';
import 'package:ahgzly_pos/features/menu/presentation/pages/menu_screen.dart';
import 'package:ahgzly_pos/features/orders/presentation/pages/orders_screen.dart';
import 'package:ahgzly_pos/features/shift/presentation/pages/shift_report_screen.dart';
import 'package:ahgzly_pos/features/expenses/presentation/pages/expenses_screen.dart';
import 'package:ahgzly_pos/features/settings/presentation/pages/settings_screen.dart';
// تم إضافة استيراد شاشة فتح الوردية
import 'package:ahgzly_pos/features/shift/presentation/pages/open_shift_screen.dart';

class AppRouter {
  // --------------------------------------------------------
  // 1. Route Constants (Type-Safe Paths)
  // --------------------------------------------------------
  static const String splashPath = '/';
  static const String licensePath = '/license';
  static const String loginPath = '/login';
  static const String openShiftPath = '/open-shift'; // تمت الإضافة هنا
  static const String posPath = '/pos';
  static const String menuPath = '/menu';
  static const String ordersPath = '/orders';
  static const String shiftPath = '/shift';
  static const String expensesPath = '/expenses';
  static const String settingsPath = '/settings';

  // --------------------------------------------------------
  // 2. Router Configuration
  // --------------------------------------------------------
  static GoRouter getRouter() {
    return GoRouter(
      initialLocation: splashPath,
      routes: [
        GoRoute(
          path: splashPath,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: licensePath,
          builder: (context, state) {
            final errorMessage = state.extra as String?;
            return LicenseScreen(errorMessage: errorMessage);
          },
        ),
        GoRoute(
          path: loginPath,
          builder: (context, state) => const LoginScreen(),
        ),
        // تمت إضافة مسار الوردية الافتتاحية مع تمرير الـ ID
        GoRoute(
          path: openShiftPath, 
          builder: (context, state) {
            final cashierId = state.extra as int? ?? 1; // الافتراضي 1
            return OpenShiftScreen(cashierId: cashierId);
          }
        ),
        GoRoute(
          path: posPath,
          builder: (context, state) => const PosScreen(),
        ),
        GoRoute(
          path: menuPath,
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: ordersPath,
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: shiftPath,
          builder: (context, state) => const ShiftReportScreen(),
        ),
        GoRoute(
          path: expensesPath,
          builder: (context, state) => const ExpensesScreen(),
        ),
        GoRoute(
          path: settingsPath,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}