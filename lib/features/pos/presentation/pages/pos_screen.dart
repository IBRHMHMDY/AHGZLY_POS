import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/di/injection_container.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/checkout_dialog.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/receipt_widgets.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_event.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  Category? _selectedCategory;
  List<Category> _categories = [];
  List<Item> _items = [];
  
  PosUpdated? _lastOrderState;
  Map<String, dynamic>? _lastCustomerData;

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchCategoriesEvent());
  }

  void _handleAutoPrint(BuildContext context, int orderId, PosUpdated orderState, String mode) async {
    final printerService = sl<PrinterService>();
    bool customerSuccess = true;
    bool kitchenSuccess = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري الطباعة التلقائية...')),
    );

    if (mode == 'customer' || mode == 'both') {
      customerSuccess = await printerService.printReceiptUsb(
        receiptWidget: CustomerReceiptWidget(
          orderId: orderId,
          orderType: orderState.orderType,
          items: orderState.cartItems,
          subTotal: orderState.subTotal,
          discountAmount: orderState.discountAmount,
          taxAmount: orderState.taxAmount,
          serviceFee: orderState.serviceFee,
          deliveryFee: orderState.deliveryFee,
          total: orderState.total,
          restaurantName: orderState.restaurantName,
          taxNumber: orderState.taxNumber,
          customerName: _lastCustomerData?['name'] ?? '',
          customerPhone: _lastCustomerData?['phone'] ?? '',
          customerAddress: _lastCustomerData?['address'] ?? '',
        ),
      );
    }

    if (mode == 'kitchen' || mode == 'both') {
      kitchenSuccess = await printerService.printReceiptUsb(
        receiptWidget: KitchenReceiptWidget(
          orderId: orderId,
          orderType: orderState.orderType,
          items: orderState.cartItems,
        ),
      );
    }

    if (context.mounted) {
      if (customerSuccess && kitchenSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت الطباعة بنجاح'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء الاتصال بالطابعة!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showPrintDialog(BuildContext context, int orderId, PosUpdated previousState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تم حفظ الطلب!', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('اختر الفاتورة التي ترغب في طباعتها:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إغلاق', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('فاتورة العميل'),
                onPressed: () async {
                  final printerService = sl<PrinterService>();
                  await printerService.printReceiptUsb(
                    receiptWidget: CustomerReceiptWidget(
                      orderId: orderId,
                      orderType: previousState.orderType,
                      items: previousState.cartItems,
                      subTotal: previousState.subTotal,
                      discountAmount: previousState.discountAmount,
                      taxAmount: previousState.taxAmount,
                      serviceFee: previousState.serviceFee,
                      deliveryFee: previousState.deliveryFee,
                      total: previousState.total,
                      restaurantName: previousState.restaurantName,
                      taxNumber: previousState.taxNumber,
                      customerName: _lastCustomerData?['name'] ?? '',
                      customerPhone: _lastCustomerData?['phone'] ?? '',
                      customerAddress: _lastCustomerData?['address'] ?? '',
                    ),
                  );
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                icon: const Icon(Icons.kitchen),
                label: const Text('بون المطبخ'),
                onPressed: () async {
                  final printerService = sl<PrinterService>();
                  await printerService.printReceiptUsb(
                    receiptWidget: KitchenReceiptWidget(
                      orderId: orderId,
                      orderType: previousState.orderType,
                      items: previousState.cartItems,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة خصم (مبلغ ثابت)'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'قيمة الخصم (ج.م)', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final discount = double.tryParse(controller.text) ?? 0.0;
                  context.read<PosBloc>().add(ApplyDiscountEvent(discount));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('تطبيق الخصم'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: isDiscount ? Colors.red : Colors.black)),
          Text('${isDiscount ? "-" : ""}$amount ج.م', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDiscount ? Colors.red : Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نقطة البيع (POS)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
              return Row(
                children: [
                  if (isAdmin) ...[
                    IconButton(
                      icon: const Icon(Icons.history),
                      tooltip: 'سجل الطلبات',
                      onPressed: () => context.push('/orders'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.analytics),
                      tooltip: 'تقرير الوردية',
                      onPressed: () => context.push('/shift'),
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
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    tooltip: 'تسجيل الخروج',
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutEvent());
                      context.go('/');
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey.shade100,
                child: BlocConsumer<MenuBloc, MenuState>(
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
                  buildWhen: (previous, current) => current is CategoriesLoaded || current is MenuLoading,
                  builder: (context, state) {
                    if (state is MenuLoading && _categories.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory?.id == category.id;
                        return ListTile(
                          title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          selectedTileColor: Colors.teal.shade100,
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            context.read<MenuBloc>().add(FetchItemsEvent(category.id!));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 3,
              child: BlocBuilder<MenuBloc, MenuState>(
                buildWhen: (previous, current) => current is ItemsLoaded || current is MenuLoading,
                builder: (context, state) {
                  if (state is MenuLoading && _items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_items.isEmpty) {
                    return const Center(child: Text('اختر فئة لعرض الأصناف'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return InkWell(
                        onTap: () {
                          context.read<PosBloc>().add(AddItemToCartEvent(item));
                        },
                        child: Card(
                          elevation: 4,
                          color: Colors.teal.shade50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text('${item.price} ج.م', style: const TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 2,
              child: BlocConsumer<PosBloc, PosState>(
                listenWhen: (previous, current) => current is PosCheckoutSuccess || current is PosError,
                listener: (context, state) {
                  if (state is PosCheckoutSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم حفظ الفاتورة بنجاح! (رقم: #${state.orderId})'), backgroundColor: Colors.green),
                    );
                    
                    if (_lastOrderState != null) {
                      final mode = _lastOrderState!.printMode;
                      if (mode == 'ask') {
                        _showPrintDialog(context, state.orderId, _lastOrderState!);
                      } else {
                        _handleAutoPrint(context, state.orderId, _lastOrderState!, mode);
                      }
                    }
                  } else if (state is PosError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                },
                buildWhen: (previous, current) => current is PosUpdated || current is PosInitial,
                builder: (context, state) {
                  if (state is PosUpdated) {
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.grey.shade200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<String>(
                                value: state.orderType,
                                items: ['تيك أواي', 'صالة', 'دليفري']
                                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<PosBloc>().add(ChangeOrderTypeEvent(value));
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                                tooltip: 'إلغاء الطلب بالكامل',
                                onPressed: () {
                                  context.read<PosBloc>().add(ClearCartEvent());
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: state.cartItems.isEmpty
                              ? const Center(child: Text('السلة فارغة', style: TextStyle(fontSize: 18, color: Colors.grey)))
                              : ListView.builder(
                                  itemCount: state.cartItems.length,
                                  itemBuilder: (context, index) {
                                    final cartItem = state.cartItems[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  Text('${cartItem.item.price} ج.م', style: const TextStyle(color: Colors.teal)),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline),
                                                  onPressed: () => context.read<PosBloc>().add(UpdateCartItemQuantityEvent(index, cartItem.quantity - 1)),
                                                ),
                                                Text('${cartItem.quantity}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                IconButton(
                                                  icon: const Icon(Icons.add_circle_outline),
                                                  onPressed: () => context.read<PosBloc>().add(UpdateCartItemQuantityEvent(index, cartItem.quantity + 1)),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => context.read<PosBloc>().add(RemoveItemFromCartEvent(index)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSummaryRow('الإجمالي الفرعي:', state.subTotal),
                              if (state.discountAmount > 0) 
                                _buildSummaryRow('قيمة الخصم:', state.discountAmount, isDiscount: true),
                              _buildSummaryRow('الضريبة المضافة:', state.taxAmount),
                              if (state.orderType == 'صالة') _buildSummaryRow('رسوم الخدمة:', state.serviceFee),
                              if (state.orderType == 'دليفري') _buildSummaryRow('رسوم التوصيل:', state.deliveryFee),
                              const Divider(thickness: 2),
                              _buildSummaryRow('الإجمالي النهائي:', state.total),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.red),
                                      icon: const Icon(Icons.discount),
                                      label: const Text('إضافة خصم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      onPressed: state.cartItems.isEmpty ? null : () => _showDiscountDialog(context),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      onPressed: state.cartItems.isEmpty ? null : () async {
                                        final previousState = state; 
                                        final result = await showDialog<Map<String, dynamic>>(
                                          context: context, 
                                          barrierDismissible: false, 
                                          builder: (_) => CheckoutDialog(totalAmount: previousState.total, orderType: previousState.orderType),
                                        );
                                        if (result != null && context.mounted) {
                                          _lastOrderState = previousState; 
                                          _lastCustomerData = result;
                                          context.read<PosBloc>().add(SubmitOrderEvent(
                                            result['method'],
                                            customerName: result['name'],
                                            customerPhone: result['phone'],
                                            customerAddress: result['address'],
                                          ));
                                        }
                                      },
                                      child: const Text('دفــع وطباعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
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
}