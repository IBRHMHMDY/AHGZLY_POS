import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

// ==========================================
// 🪄 Core Entities & Blocs
// ==========================================
import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';

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

// [Refactored]: إضافة كلاس مساعد لتحويل Stream الخاص بالـ Bloc إلى Listenable ليعمل مع GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  // --------------------------------------------------------
  // 1. Route Constants (Type-Safe Paths)
  // --------------------------------------------------------
  static const String splashPath = '/';
  static const String licensePath = '/license';
  static const String loginPath = '/login';
  static const String lockPath = '/lock'; 
  static const String openShiftPath = '/open-shift'; 
  static const String shiftPath = '/shift';
  static const String posPath = '/pos';
  static const String menuPath = '/menu';
  static const String ordersPath = '/orders';
  static const String expensesPath = '/expenses';
  static const String usersPath = '/users';
  static const String settingsPath = '/settings';
  static const String adminDashboardPath = '/admin-dashboard'; // 🪄 مسار شاشة الإدارة الجديد

  // --------------------------------------------------------
  // 2. Router Configuration
  // --------------------------------------------------------
  // [Refactored]: حقن AuthBloc للاستماع لتغيرات حالة المستخدم
  static GoRouter getRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: splashPath,
      // [Refactored]: تحديث الراوتر تلقائياً عند أي تغيير في حالة الـ AuthBloc
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      
      // [Refactored]: منطق الحماية وتوجيه المستخدمين (Route Guards)
      redirect: (context, state) {
        final authState = authBloc.state;
        final currentPath = state.matchedLocation;

        final isSplashOrLicense = currentPath == splashPath || currentPath == licensePath;
        final isLoginOrLock = currentPath == loginPath || currentPath == lockPath;

        // 1. إذا لم يسجل الدخول، امنعه من الدخول لأي مسار آخر غير شاشات البداية
        if (authState is AuthUnauthenticated || authState is AuthInitial) {
          if (!isSplashOrLicense && !isLoginOrLock) {
            return loginPath;
          }
          return null; // اتركه يكمل للمسار المطلوب (سبلاش أو لوجن)
        }

        // 2. إذا سجل الدخول بنجاح
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          final isAdmin = user.isAdmin;

          // إذا حاول الدخول لشاشة اللوجن وهو مسجل دخول، وجهه للشاشة الرئيسية الخاصة به
          if (isSplashOrLicense || isLoginOrLock) {
            return isAdmin ? adminDashboardPath : posPath;
          }

          // [Refactored] حماية مسارات الإدارة: منع الكاشير من الدخول إليها
          if (!isAdmin) {
            const adminOnlyRoutes = [
              expensesPath,
              usersPath,
              settingsPath,
              adminDashboardPath,
            ];
            
            // إذا كان المسار ضمن مسارات الإدارة، أرجعه لشاشة الـ POS
            if (adminOnlyRoutes.contains(currentPath)) {
              return posPath; 
            }
          }
        }

        // لا توجد مشكلة، اسمح بالمرور
        return null; 
      },
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
          path: lockPath, 
          builder: (context, state) {
            // توفير مستخدم افتراضي أو جلبه من الـ State في حال تم عمل Reload
            final user = state.extra as User?; 
            if(user != null) return LockScreen(currentUser: user);
            
            // حماية إضافية في حال عدم تمرير المستخدم كـ Extra
            if(authBloc.state is AuthAuthenticated) {
               return LockScreen(currentUser: (authBloc.state as AuthAuthenticated).user);
            }
            return const LoginScreen(); // Fallback
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
        
        // -- Admin Dashboard (مؤقت حتى بنائها في Sprint 2) --
        GoRoute(
          path: adminDashboardPath,
          builder: (context, state) => const SettingsScreen(), // 🪄 سنستبدلها لاحقاً بـ AdminDashboardScreen
        ),
      ],
    );
  }
}