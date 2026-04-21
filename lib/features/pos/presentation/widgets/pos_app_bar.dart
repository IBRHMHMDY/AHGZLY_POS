import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';

class PosAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PosAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // 🚀 [Sprint 4 - Task 4.1]: Graceful Shutdown
  void _performGracefulShutdown(BuildContext context) async {
    // 1. إغلاق اتصالات قاعدة البيانات بأمان لضمان عدم تلف البيانات
    await sl<AppDatabase>().close();
    
    // 2. إغلاق التطبيق برمجياً بناءً على نوع المنصة
    if (Platform.isAndroid || Platform.isIOS) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.power_settings_new, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('إغلاق النظام', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('هل أنت متأكد من أنك تريد إغلاق البرنامج بالكامل؟', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('تأكيد الإغلاق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () => _performGracefulShutdown(context), // 🚀 استدعاء الإغلاق الآمن
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.point_of_sale, size: 28),
          SizedBox(width: 8),
          Text('نقطة البيع (POS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      actions: [
        BlocSelector<AuthBloc, AuthState, AuthAuthenticated?>(
          selector: (state) => state is AuthAuthenticated ? state : null,
          builder: (context, authState) {
            final bool isAdmin = authState != null && authState.user.isAdmin;

            return Row(
              children: [
                if (isAdmin) ...[
                  IconButton(icon: const Icon(Icons.manage_accounts), tooltip: 'إدارة المستخدمين', onPressed: () => context.push('/users')),
                  IconButton(icon: const Icon(Icons.restaurant_menu), tooltip: 'إدارة القائمة', onPressed: () async {
                    await context.push('/menu');
                    if (context.mounted) context.read<MenuBloc>().add(FetchCategoriesEvent());
                  }),
                  IconButton(icon: const Icon(Icons.settings), tooltip: 'إعدادات النظام', onPressed: () async {
                    await context.push('/settings');
                    if (context.mounted) context.read<PosBloc>().add(LoadPosDataEvent());
                  }),
                ],
                IconButton(icon: const Icon(Icons.history), tooltip: 'سجل الطلبات', onPressed: () => context.push('/orders')),
                IconButton(icon: const Icon(Icons.money_off), tooltip: 'المصروفات', onPressed: () => context.push('/expenses')),
                IconButton(icon: const Icon(Icons.analytics), tooltip: 'الوردية الحالية', onPressed: () => context.push('/shift')),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade50, foregroundColor: Colors.blueGrey.shade800, elevation: 0),
                    icon: const Icon(Icons.lock),
                    label: const Text('قفل الشاشة', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      context.push('/lock');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, elevation: 0),
                    icon: const Icon(Icons.power_settings_new),
                    label: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showExitConfirmation(context),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}