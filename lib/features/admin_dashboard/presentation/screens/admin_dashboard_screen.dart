// المسار: lib/features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 🪄 استيراد الشاشات الخاصة بالمدير
import 'package:ahgzly_pos/features/menu/presentation/screens/menu_screen.dart';
import 'package:ahgzly_pos/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:ahgzly_pos/features/users/presentation/screens/users_screen.dart';
import 'package:ahgzly_pos/features/settings/presentation/screens/settings_screen.dart';
import 'package:ahgzly_pos/features/pos/presentation/screens/pos_screen.dart'; // للوصول لشاشة الكاشير عند الحاجة
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_event.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // [Refactored]: استخدام متغير لتتبع الشاشة الحالية
  int _selectedIndex = 0;

  // [Refactored]: ترتيب الشاشات المعروضة في لوحة الإدارة
  final List<Widget> _screens = const [
    PosScreen(),       // 0: نقطة البيع
    MenuScreen(),      // 1: إدارة المنيو
    ExpensesScreen(),  // 2: المصروفات
    UsersScreen(),     // 3: المستخدمين
    SettingsScreen(),  // 4: الإعدادات
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🪄 القائمة الجانبية (Navigation Rail)
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.point_of_sale_outlined),
                selectedIcon: Icon(Icons.point_of_sale),
                label: Text('الكاشير'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: Text('القائمة'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.money_off_outlined),
                selectedIcon: Icon(Icons.money_off),
                label: Text('المصروفات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('المستخدمين'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('الإعدادات'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    tooltip: 'تسجيل الخروج',
                    onPressed: () {
                      // 🪄 استدعاء حدث تسجيل الخروج
                      context.read<AuthBloc>().add(LogoutEvent());
                    },
                  ),
                ),
              ),
            ),
          ),
          
          const VerticalDivider(thickness: 1, width: 1),
          
          // 🪄 منطقة عرض الشاشات (IndexedStack يحافظ على حالة الشاشات أثناء التبديل)
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}