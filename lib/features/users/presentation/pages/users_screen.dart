import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_bloc.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_event.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_state.dart';
import '../widgets/add_user_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل المستخدمين عند فتح الشاشة
    context.read<UsersBloc>().add(LoadUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddUserDialog());
        },
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('مستخدم جديد'),
      ),
      body: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UserOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
          } else if (state is UsersError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            if (state.users.isEmpty) return const Center(child: Text('لا يوجد مستخدمين إضافيين'));
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isAdmin ? Colors.red.shade100 : Colors.blue.shade100,
                      child: Icon(
                        user.isAdmin ? Icons.admin_panel_settings : Icons.point_of_sale,
                        color: user.isAdmin ? Colors.red : Colors.blue,
                      ),
                    ),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(user.isAdmin ? 'مدير نظام' : 'كاشير'),
                    trailing: Switch(
                      value: user.isActive,
                      activeColor: Colors.green,
                      onChanged: (bool value) {
                        context.read<UsersBloc>().add(ToggleUserStatusEvent(id: user.id, isActive: value));
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('حدث خطأ أثناء التحميل'));
        },
      ),
    );
  }
}