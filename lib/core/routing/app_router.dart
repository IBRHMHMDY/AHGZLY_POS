import 'package:go_router/go_router.dart';

// ==========================================
// 🪄 Core Entities
// ==========================================
import 'package:ahgzly_pos/core/common/entities/user.dart';

// ==========================================
// 🪄 Features Screens Imports
// ==========================================
// 1. Splash & License
import 'package:ahgzly_pos/features/splash/presentation/screens/splash_screen.dart';
import 'package:ahgzly_pos/features/license/presentation/screens/license_screen.dart';

// 2. Auth & Lock
import 'package:ahgzly_pos/features/auth/presentation/screens/login_screen.dart';
import 'package:ahgzly_pos/features/auth/presentation/screens/lock_screen.dart';

// 3. Shift Management
import 'package:ahgzly_pos/features/shift/presentation/screens/open_shift_screen.dart';
import 'package:ahgzly_pos/features/shift/presentation/screens/shift_report_screen.dart';

// 4. POS Core (Menu, Orders, Point of Sale)
import 'package:ahgzly_pos/features/pos/presentation/screens/pos_screen.dart';
import 'package:ahgzly_pos/features/menu/presentation/screens/menu_screen.dart';
import 'package:ahgzly_pos/features/orders/presentation/screens/orders_screen.dart';

// 5. Finance & Management (Expenses, Users, Settings)
import 'package:ahgzly_pos/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:ahgzly_pos/features/users/presentation/screens/users_screen.dart';
import 'package:ahgzly_pos/features/settings/presentation/screens/settings_screen.dart';


class AppRouter {
  // --------------------------------------------------------
  // 1. Route Constants (Type-Safe Paths)
  // --------------------------------------------------------
  static const String splashPath = '/';
  static const String licensePath = '/license';
  static const String loginPath = '/login';
  static const String lockPath = '/lock'; // 🪄 تم إضافة الثابت المفقود
  static const String openShiftPath = '/open-shift'; 
  static const String shiftPath = '/shift';
  static const String posPath = '/pos';
  static const String menuPath = '/menu';
  static const String ordersPath = '/orders';
  static const String expensesPath = '/expenses';
  static const String usersPath = '/users';
  static const String settingsPath = '/settings';

  // --------------------------------------------------------
  // 2. Router Configuration
  // --------------------------------------------------------
  static GoRouter getRouter() {
    return GoRouter(
      initialLocation: splashPath,
      routes: [
        // -- Initial & Licensing --
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

        // -- Authentication --
        GoRoute(
          path: loginPath,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: lockPath, // 🪄 استخدام الثابت بدلاً من النص الصلب
          builder: (context, state) {
            final user = state.extra as User; 
            return LockScreen(currentUser: user);
          },
        ),

        // -- Shift Management --
        GoRoute(
          path: openShiftPath, 
          builder: (context, state) {
            final cashierId = state.extra as int? ?? 1; 
            return OpenShiftScreen(cashierId: cashierId);
          }
        ),
        GoRoute(
          path: shiftPath,
          builder: (context, state) => const ShiftReportScreen(),
        ),

        // -- Main POS Operations --
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

        // -- Management & Finance --
        GoRoute(
          path: expensesPath,
          builder: (context, state) => const ExpensesScreen(),
        ),
        GoRoute(
          path: usersPath,
          builder: (context, state) => const UsersScreen(),
        ),
        GoRoute(
          path: settingsPath,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}