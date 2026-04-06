import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/utils/snackbar_utils.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';

import 'package:ahgzly_pos/features/pos/presentation/widgets/categories_section.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/items_section.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/cart_section.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  Category? _selectedCategory;
  List<Category> _categories = [];
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchCategoriesEvent());
  }

  // 🪄 نافذة تأكيد الإغلاق
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.power_settings_new, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              'إغلاق النظام',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من أنك تريد إغلاق البرنامج بالكامل؟',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.exit_to_app),
            label: const Text(
              'تأكيد الإغلاق',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: () => exit(0), // أمر الإغلاق الفوري للبرنامج
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(context),
      // استخدام MultiBlocListener للاستماع للمبيعات والقوائم في آن واحد
      body: MultiBlocListener(
        listeners: [
          // 1. المستمع الخاص بالقوائم (Menu)
          BlocListener<MenuBloc, MenuState>(
            listener: (context, state) {
              if (state is CategoriesLoaded) {
                setState(() {
                  _categories = state.categories;
                  if (_selectedCategory == null && _categories.isNotEmpty) {
                    _selectedCategory = _categories.first;
                    context.read<MenuBloc>().add(
                      FetchItemsEvent(_selectedCategory!.id!),
                    );
                  }
                });
              } else if (state is ItemsLoaded) {
                setState(() {
                  _items = state.items;
                });
              }
            },
          ),
          // 2. المستمع الخاص بالمبيعات (POS) لاعتراض الأخطاء (مثل: لا توجد وردية مفتوحة)
          BlocListener<PosBloc, PosState>(
            listener: (context, state) {
              if (state is PosError) {
                SnackbarUtils.showError(context, state.message);
              } else if (state is PosCheckoutSuccess) {
                SnackbarUtils.showSuccess(
                  context,
                  'تم حفظ الفاتورة بنجاح برقم #${state.orderId}',
                );
                // يمكن إضافة حدث تفريغ السلة هنا إذا لزم الأمر مستقبلاً
              }
            },
          ),
        ],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: CategoriesSection(
                categories: _categories,
                selectedCategory: _selectedCategory,
                isLoading: context.watch<MenuBloc>().state is MenuLoading,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                  context.read<MenuBloc>().add(FetchItemsEvent(category.id!));
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: ItemsSection(
                items: _items,
                categoryName: _selectedCategory?.name ?? 'الأصناف',
                isLoading: context.watch<MenuBloc>().state is MenuLoading,
              ),
            ),
            const Expanded(flex: 2, child: CartSection()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.point_of_sale, size: 28),
          SizedBox(width: 8),
          Text(
            'نقطة البيع (POS)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // استخدام state مباشرة بدلاً من context.read لضمان التحديث اللحظي
            final bool isAdmin = (state is AuthAuthenticated) && state.user.isAdmin;
            final currentUser = (state is AuthAuthenticated) ? state.user : null;

            return Row(
              children: [
                // 🛑 أزرار الإدارة العليا (للمدير فقط) 🛑
                if (isAdmin) ...[
                  IconButton(
                    icon: const Icon(Icons.manage_accounts),
                    tooltip: 'إدارة المستخدمين',
                    onPressed: () => context.push('/users'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.restaurant_menu),
                    tooltip: 'إدارة القائمة',
                    onPressed: () async {
                      await context.push('/menu');
                      if (context.mounted) {
                        context.read<MenuBloc>().add(FetchCategoriesEvent());
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'إعدادات النظام',
                    onPressed: () async {
                      await context.push('/settings');
                      if (context.mounted) {
                        context.read<PosBloc>().add(ReloadSettingsEvent());
                      }
                    },
                  ),
                ],

                // 🟢 الأزرار التشغيلية (للكاشير والمدير معاً) 🟢

                // 1. سجل الطلبات
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'سجل الطلبات',
                  onPressed: () => context.push('/orders'),
                ),
                
                // 2. المصروفات النثرية
                IconButton(
                  icon: const Icon(Icons.money_off, color: Colors.orangeAccent),
                  tooltip: 'المصروفات',
                  onPressed: () => context.push('/expenses'),
                ),

                // 3. الوردية (لإصدار تقارير X و Z)
                IconButton(
                  icon: const Icon(Icons.analytics),
                  tooltip: 'الوردية الحالية',
                  onPressed: () => context.push('/shift'),
                ),

                // 🔒 4. زر قفل الشاشة (الآمن) بدلاً من تبديل المستخدم
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade50,
                      foregroundColor: Colors.blueGrey.shade800,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.lock),
                    label: const Text(
                      'قفل الشاشة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (currentUser != null) {
                        // الانتقال لشاشة القفل مع تمرير المستخدم الحالي
                        context.push('/lock', extra: currentUser);
                      }
                    },
                  ),
                ),

                // 5. زر إغلاق البرنامج
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.power_settings_new),
                    label: const Text(
                      'إغلاق البرنامج',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
