import 'dart:io';
import 'package:ahgzly_pos/core/extensions/order_type.dart';
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
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';

class PosAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PosAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _performGracefulShutdown(BuildContext context) async {
    await sl<AppDatabase>().close();
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold))),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('تأكيد الإغلاق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () => _performGracefulShutdown(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.point_of_sale, size: 28),
          const SizedBox(width: 8),
          const Text('نقطة البيع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(width: 24),
          
          // 🚀 [Sprint 4]: UX Indicator لمعرفة حالة الطلب الحالي من أي شاشة
          BlocBuilder<PosBloc, PosState>(
            builder: (context, state) {
              if (state is PosDataLoaded) {
                if (state.orderType == OrderType.dineIn && state.selectedTableId != null) {
                  final table = state.tables.firstWhere((t) => t.id == state.selectedTableId, orElse: () => state.tables.first);
                  return Chip(
                    avatar: const Icon(Icons.table_restaurant, color: Colors.white, size: 18),
                    label: Text('طاولة: ${table.tableNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.blue.shade700,
                  );
                } else if (state.orderType == OrderType.delivery && state.selectedCustomerId != null) {
                   final customer = state.customers.firstWhere((c) => c.id == state.selectedCustomerId, orElse: () => state.customers.first);
                   return Chip(
                    avatar: const Icon(Icons.delivery_dining, color: Colors.white, size: 18),
                    label: Text('عميل: ${customer.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.orange.shade700,
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
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
                    onPressed: () => context.push('/lock'),
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