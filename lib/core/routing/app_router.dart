import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/features/auth/presentation/pages/login_screen.dart';
import 'package:ahgzly_pos/features/auth/presentation/pages/license_screen.dart';
import 'package:ahgzly_pos/features/pos/presentation/pages/pos_screen.dart';
import 'package:ahgzly_pos/features/menu/presentation/pages/menu_screen.dart';
import 'package:ahgzly_pos/features/settings/presentation/pages/settings_screen.dart';
import 'package:ahgzly_pos/features/shift/presentation/pages/shift_report_screen.dart';
import 'package:ahgzly_pos/features/orders/presentation/pages/orders_screen.dart';
import 'package:ahgzly_pos/features/expenses/presentation/pages/expenses_screen.dart';

class AppRouter {
  static GoRouter getRouter({
    required bool isActivated, 
    required bool isTrialExpired, 
    required int elapsedDays,
  }) {
    return GoRouter(
      initialLocation: (!isActivated && isTrialExpired) ? '/license' : '/',
      
      // 🪄 الحارس الأمني الإجباري (Guard) الذي يستحيل تخطيه
      redirect: (context, state) {
        final isGoingToLicense = state.matchedLocation == '/license';
        
        // إذا كانت النسخة غير مفعلة وانتهت أو تم التلاعب بها، يُمنع الدخول لأي شاشة ويُجبر على شاشة التفعيل
        if (!isActivated && isTrialExpired && !isGoingToLicense) {
          return '/license';
        }
        
        return null; // السماح بالمرور في الحالات الطبيعية
      },
      
      routes: [
        GoRoute(
          path: '/license', 
          builder: (context, state) => LicenseScreen(isTrialExpired: isTrialExpired)
        ),
        GoRoute(
          path: '/', 
          builder: (context, state) => LoginScreen(
            isActivated: isActivated, 
            elapsedDays: elapsedDays
          )
        ),
        GoRoute(path: '/pos', builder: (context, state) => const PosScreen()),
        GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/shift', builder: (context, state) => const ShiftReportScreen()),
        GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
        GoRoute(path: '/expenses', builder: (context, state) => const ExpensesScreen()),
      ],
    );
  }
}