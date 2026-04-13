import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/utils/snackbar_utils.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/categories_section.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/items_section.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/cart_section.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/pos_app_bar.dart'; // [Added]

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  CategoryEntity? _selectedCategory;
  List<CategoryEntity> _categories = [];
  List<ItemEntity> _items = [];

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const PosAppBar(), 
      body: MultiBlocListener(
        listeners: [
          BlocListener<MenuBloc, MenuState>(
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
          ),
          BlocListener<PosBloc, PosState>(
            listener: (context, state) {
              if (state is PosError) {
                SnackbarUtils.showError(context, state.message);
              } else if (state is PosCheckoutSuccess) {
                SnackbarUtils.showSuccess(context, 'تم حفظ الفاتورة بنجاح برقم #${state.orderId}');
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
}