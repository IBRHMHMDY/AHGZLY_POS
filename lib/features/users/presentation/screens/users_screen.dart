import 'package:ahgzly_pos/core/utils/extensions/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_bloc.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_event.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_state.dart';
import 'package:ahgzly_pos/features/users/presentation/widgets/add_user_dialog.dart';
import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:ahgzly_pos/core/widgets/custom_shimmer.dart'; // 🪄 استيراد الشيمر

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(LoadUsersEvent());
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddUserDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.manage_accounts),
            SizedBox(width: 8),
            Text('إدارة المستخدمين', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'users_fab',
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة مستخدم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersLoading) {
            return const _UsersShimmerLoading(); // 🪄 استخدام الشيمر
          }
          if (state is UsersLoaded) {
            if (state.users.isEmpty) {
              return const _EmptyUsersView();
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return _UserCard(user: user);
                  },
                ),
              ),
            );
          }
          if (state is UsersError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets)
// ==========================================

class _UserCard extends StatelessWidget {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.isAdmin;
    final primaryColor = isAdmin ? Colors.red : Colors.teal;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.point_of_sale,
            color: primaryColor,
            size: 28,
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(isAdmin ? Icons.shield : Icons.badge, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                user.role.toDisplayName(), // [Refactored]: استدعاء مباشر لاسم الصلاحية من الـ Enum
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user.isActive ? Colors.green.shade50 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.isActive ? 'نشط' : 'موقوف',
                style: TextStyle(color: user.isActive ? Colors.green.shade700 : Colors.grey.shade700, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Switch(
                value: user.isActive,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  context.read<UsersBloc>().add(ToggleUserStatusEvent(id: user.id, isActive: value));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyUsersView extends StatelessWidget {
  const _EmptyUsersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا يوجد مستخدمين مسجلين', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _UsersShimmerLoading extends StatelessWidget {
  const _UsersShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: 6,
          itemBuilder: (_, _) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomShimmer.rectangular(height: 80, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ),
      ),
    );
  }
}