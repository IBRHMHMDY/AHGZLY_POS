import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_event.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';

// استيراد الـ Widgets المعزولة
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(context),
      body: BlocListener<MenuBloc, MenuState>(
        listener: (context, state) {
          if (state is CategoriesLoaded) {
            setState(() {
              _categories = state.categories;
              if (_selectedCategory == null && _categories.isNotEmpty) {
                _selectedCategory = _categories.first;
                context.read<MenuBloc>().add(FetchItemsEvent(_selectedCategory!.id!));
              }
            });
          } else if (state is ItemsLoaded) {
            setState(() {
              _items = state.items;
            });
          }
        },
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
            const Expanded(
              flex: 2,
              child: CartSection(), // السلة مفصولة تماماً هنا
            ),
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
          Text('نقطة البيع (POS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
            return Row(
              children: [
                if (isAdmin) ...[
                  IconButton(icon: const Icon(Icons.history), tooltip: 'سجل الطلبات', onPressed: () => context.push('/orders')),
                  IconButton(icon: const Icon(Icons.analytics), tooltip: 'تقرير الوردية', onPressed: () => context.push('/shift')),
                  IconButton(icon: const Icon(Icons.money_off, color: Colors.orangeAccent), tooltip: 'المصروفات', onPressed: () => context.push('/expenses')),
                  IconButton(
                    icon: const Icon(Icons.restaurant_menu),
                    tooltip: 'إدارة القائمة',
                    onPressed: () async {
                      await context.push('/menu');
                      if (context.mounted) context.read<MenuBloc>().add(FetchCategoriesEvent());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'إعدادات النظام',
                    onPressed: () async {
                      await context.push('/settings');
                      if (context.mounted) context.read<PosBloc>().add(ReloadSettingsEvent());
                    },
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, elevation: 0),
                    icon: const Icon(Icons.logout),
                    label: const Text('خروج', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutEvent());
                      context.go('/');
                    },
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