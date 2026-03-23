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
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/checkout_dialog.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  Category? _selectedCategory;
  // أضفنا متغيرات للاحتفاظ بالبيانات محلياً (Caching)
  List<Category> _categories = [];
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    // جلب الفئات فور فتح الشاشة
    context.read<MenuBloc>().add(FetchCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نقطة البيع (POS)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'إدارة القائمة',
            onPressed: () async {
              // الانتظار حتى العودة من شاشة الإدارة
              await context.push('/menu');
              // تحديث البيانات بعد العودة
              if (context.mounted) {
                context.read<MenuBloc>().add(FetchCategoriesEvent());
              }
            },
          )
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // ==========================================
            // الجانب الأيمن (2/3): القائمة (الفئات والأصناف)
            // ==========================================
            Expanded(
              flex: 2,
              child: BlocConsumer<MenuBloc, MenuState>(
                listener: (context, state) {
                  // تحديث المتغيرات المحلية بناءً على الحالات
                  if (state is CategoriesLoaded) {
                    setState(() {
                      _categories = state.categories;
                      // اختيار أول فئة تلقائياً إن لم يكن هناك فئة محددة
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
                builder: (context, state) {
                  return Column(
                    children: [
                      // شريط الفئات الأفقي
                      Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey.shade100,
                        child: _categories.isEmpty
                            ? const Center(child: Text('لا توجد فئات'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  final category = _categories[index];
                                  final isSelected = _selectedCategory?.id == category.id;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: ChoiceChip(
                                      label: Text(category.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      selected: isSelected,
                                      selectedColor: Colors.teal.shade200,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _selectedCategory = category;
                                            _items = []; // تصفير الأصناف حتى يتم التحميل
                                          });
                                          context.read<MenuBloc>().add(FetchItemsEvent(category.id!));
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                      const Divider(height: 1),
                      // شبكة الأصناف
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (state is MenuLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (_items.isEmpty) {
                              return const Center(child: Text('لا توجد أصناف في هذه الفئة', style: TextStyle(fontSize: 18)));
                            }
                            return GridView.builder(
                              padding: const EdgeInsets.all(12.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4, // 4 أعمدة للشاشات العريضة
                                childAspectRatio: 1.2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return InkWell(
                                  onTap: () {
                                    // إضافة الصنف للسلة
                                    context.read<PosBloc>().add(AddItemToCartEvent(item));
                                  },
                                  child: Card(
                                    elevation: 3,
                                    color: Colors.teal.shade50,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.fastfood, size: 40, color: Colors.teal),
                                        const SizedBox(height: 8),
                                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                                        const SizedBox(height: 4),
                                        Text('${item.price} ج.م', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // الفاصل بين القسمين
            const VerticalDivider(width: 1, thickness: 1),

            // ==========================================
            // الجانب الأيسر (1/3): سلة المشتريات (Cart)
            // ==========================================
            Expanded(
              flex: 1,
              child: BlocConsumer<PosBloc, PosState>(
                listener: (context, state) {
                  if (state is PosCheckoutSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم حفظ الفاتورة بنجاح! (رقم: ${state.orderId})'), backgroundColor: Colors.green),
                    );
                  } else if (state is PosError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is PosUpdated) {
                    return Column(
                      children: [
                        // ترويسة السلة
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey.shade200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<String>(
                                value: state.orderType,
                                underline: const SizedBox(),
                                items: ['تيك أواي', 'صالة', 'دليفري']
                                    .map((type) => DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<PosBloc>().add(ChangeOrderTypeEvent(value));
                                  }
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                                label: const Text('إلغاء الطلب', style: TextStyle(color: Colors.red)),
                                onPressed: state.cartItems.isEmpty
                                    ? null
                                    : () {
                                        context.read<PosBloc>().add(ClearCartEvent());
                                      },
                              )
                            ],
                          ),
                        ),

                        // قائمة الأصناف في السلة
                        Expanded(
                          child: state.cartItems.isEmpty
                              ? const Center(child: Text('السلة فارغة', style: TextStyle(fontSize: 18, color: Colors.grey)))
                              : ListView.separated(
                                  itemCount: state.cartItems.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final cartItem = state.cartItems[index];
                                    return ListTile(
                                      title: Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('${cartItem.item.price} ج.م'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                            onPressed: () {
                                              context.read<PosBloc>().add(UpdateCartItemQuantityEvent(index, cartItem.quantity - 1));
                                            },
                                          ),
                                          Text('${cartItem.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                            onPressed: () {
                                              context.read<PosBloc>().add(UpdateCartItemQuantityEvent(index, cartItem.quantity + 1));
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // ملخص الحسابات
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Colors.teal.shade50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSummaryRow('الإجمالي الفرعي:', state.subTotal),
                              _buildSummaryRow('الضريبة (14%):', state.taxAmount),
                              if (state.orderType == 'صالة') _buildSummaryRow('خدمة الصالة (12%):', state.serviceFee),
                              if (state.orderType == 'دليفري') _buildSummaryRow('رسوم التوصيل:', state.deliveryFee),
                              const Divider(thickness: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('الإجمالي النهائي:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text('${state.total} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: state.cartItems.isEmpty
                                    ? null
                                    : () async {
                                        final paymentMethod = await showDialog<String>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) => CheckoutDialog(totalAmount: state.total),
                                        );
                                        
                                        if (paymentMethod != null && context.mounted) {
                                          context.read<PosBloc>().add(SubmitOrderEvent(paymentMethod));
                                        }
                                      },
                                child: const Text('دفــع (Checkout)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text('$amount ج.م', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}