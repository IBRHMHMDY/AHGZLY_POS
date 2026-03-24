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

  void _handleAutoPrint(
    BuildContext context,
    int orderId,
    PosUpdated orderState,
    String mode,
  ) async {
    final printerService = sl<PrinterService>();
    bool customerSuccess = true;
    bool kitchenSuccess = true;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جاري الطباعة التلقائية...')));

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
          const SnackBar(
            content: Text('تمت الطباعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء الاتصال بالطابعة!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPrintDialog(
    BuildContext context,
    int orderId,
    PosUpdated previousState,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'تم حفظ الطلب!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'اختر الفاتورة التي ترغب في طباعتها:',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'إغلاق',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
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
        );
      },
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'إضافة خصم (مبلغ ثابت)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: 'قيمة الخصم (ج.م)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.money_off, color: Colors.teal),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final discount = double.tryParse(controller.text) ?? 0.0;
                context.read<PosBloc>().add(ApplyDiscountEvent(discount));
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              'تطبيق الخصم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? Colors.red
                  : (isTotal ? Colors.teal.shade800 : Colors.black87),
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}${amount.toStringAsFixed(2)} ج.م',
            style: TextStyle(
              fontSize: isTotal ? 24 : 16,
              fontWeight: FontWeight.bold,
              color: isDiscount
                  ? Colors.red
                  : (isTotal ? Colors.teal.shade800 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // خلفية هادئة جداً للنظام
      appBar: AppBar(
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
                      icon: const Icon(
                        Icons.money_off,
                        color: Colors.orangeAccent,
                      ),
                      tooltip: 'المصروفات',
                      onPressed: () => context.push('/expenses'),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'خروج',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // ==========================================
            // العمود الأول: الأقسام (Categories)
            // ==========================================
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(left: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.teal.shade50,
                      child: const Text(
                        'الأقسام',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: BlocConsumer<MenuBloc, MenuState>(
                        listener: (context, state) {
                          if (state is CategoriesLoaded) {
                            setState(() {
                              _categories = state.categories;
                              if (_selectedCategory == null &&
                                  _categories.isNotEmpty) {
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
                        buildWhen: (previous, current) =>
                            current is CategoriesLoaded ||
                            current is MenuLoading,
                        builder: (context, state) {
                          if (state is MenuLoading && _categories.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected =
                                  _selectedCategory?.id == category.id;
                              return InkWell(
                                onTap: () {
                                  setState(() => _selectedCategory = category);
                                  context.read<MenuBloc>().add(
                                    FetchItemsEvent(category.id!),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.teal
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.teal
                                          : Colors.grey.shade300,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.teal.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // العمود الثاني: الأصناف (Items)
            // ==========================================
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _selectedCategory?.name ?? 'الأصناف',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<MenuBloc, MenuState>(
                      buildWhen: (previous, current) =>
                          current is ItemsLoaded || current is MenuLoading,
                      builder: (context, state) {
                        if (state is MenuLoading && _items.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (_items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fastfood_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد أصناف في هذا القسم',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    4, // 4 عناصر في الصف ليكون الشكل أجمل
                                childAspectRatio: 0.9,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Card(
                              elevation: 2,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => context.read<PosBloc>().add(
                                  AddItemToCartEvent(item),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: Colors.teal.shade50,
                                        child: Center(
                                          child: Icon(
                                            Icons.restaurant,
                                            size: 40,
                                            color: Colors.teal.shade200,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${item.price} ج.م',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.teal,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
              ),
            ),

            // ==========================================
            // العمود الثالث: الفاتورة والدفع (Cart & Checkout)
            // ==========================================
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: BlocConsumer<PosBloc, PosState>(
                  listenWhen: (previous, current) =>
                      current is PosCheckoutSuccess || current is PosError,
                  listener: (context, state) {
                    if (state is PosCheckoutSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حفظ الفاتورة بنجاح! (رقم: #${state.orderId})',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      if (_lastOrderState != null) {
                        final mode = _lastOrderState!.printMode;
                        if (mode == 'ask') {
                          _showPrintDialog(
                            context,
                            state.orderId,
                            _lastOrderState!,
                          );
                        } else {
                          _handleAutoPrint(
                            context,
                            state.orderId,
                            _lastOrderState!,
                            mode,
                          );
                        }
                      }
                    } else if (state is PosError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  buildWhen: (previous, current) =>
                      current is PosUpdated || current is PosInitial,
                  builder: (context, state) {
                    if (state is PosUpdated) {
                      return Column(
                        children: [
                          // نوع الطلب
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: state.orderType,
                                        isExpanded: true,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.teal,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                        items: ['تيك أواي', 'صالة', 'دليفري']
                                            .map((type) {
                                              return DropdownMenuItem(
                                                value: type,
                                                child: Text(type),
                                              );
                                            })
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null)
                                            {
                                              context.read<PosBloc>().add(
                                              ChangeOrderTypeEvent(value),
                                            );
                                            }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () => context.read<PosBloc>().add(
                                    ClearCartEvent(),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.delete_sweep,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // السلة (Cart Items)
                          Expanded(
                            child: state.cartItems.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_basket_outlined,
                                          size: 80,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'الفاتورة فارغة',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: state.cartItems.length,
                                    separatorBuilder: (_, _) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final cartItem = state.cartItems[index];
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cartItem.item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${cartItem.item.price} ج.م',
                                                  style: const TextStyle(
                                                    color: Colors.teal,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // أزرار التحكم بالكمية
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap: () => context
                                                      .read<PosBloc>()
                                                      .add(
                                                        UpdateCartItemQuantityEvent(
                                                          index,
                                                          cartItem.quantity - 1,
                                                        ),
                                                      ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 20,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 30,
                                                      ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '${cartItem.quantity}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () => context
                                                      .read<PosBloc>()
                                                      .add(
                                                        UpdateCartItemQuantityEvent(
                                                          index,
                                                          cartItem.quantity + 1,
                                                        ),
                                                      ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 20,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () =>
                                                context.read<PosBloc>().add(
                                                  RemoveItemFromCartEvent(
                                                    index,
                                                  ),
                                                ),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),

                          // ملخص الحساب (Totals & Checkout)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSummaryRow(
                                  'الإجمالي الفرعي:',
                                  state.subTotal,
                                ),
                                if (state.discountAmount > 0)
                                  _buildSummaryRow(
                                    'قيمة الخصم:',
                                    state.discountAmount,
                                    isDiscount: true,
                                  ),
                                _buildSummaryRow(
                                  'الضريبة المضافة:',
                                  state.taxAmount,
                                ),
                                if (state.orderType == 'صالة')
                                  _buildSummaryRow(
                                    'رسوم الخدمة:',
                                    state.serviceFee,
                                  ),
                                if (state.orderType == 'دليفري')
                                  _buildSummaryRow(
                                    'رسوم التوصيل:',
                                    state.deliveryFee,
                                  ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Divider(thickness: 2),
                                ),

                                _buildSummaryRow(
                                  'الإجمالي النهائي:',
                                  state.total,
                                  isTotal: true,
                                ),

                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20,
                                          ),
                                          foregroundColor: Colors.teal,
                                          side: const BorderSide(
                                            color: Colors.teal,
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        onPressed: state.cartItems.isEmpty
                                            ? null
                                            : () =>
                                                  _showDiscountDialog(context),
                                        child: const Icon(
                                          Icons.discount_outlined,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 3,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 4,
                                        ),
                                        onPressed: state.cartItems.isEmpty
                                            ? null
                                            : () async {
                                                final previousState = state;
                                                final result =
                                                    await showDialog<
                                                      Map<String, dynamic>
                                                    >(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (_) =>
                                                          CheckoutDialog(
                                                            totalAmount:
                                                                previousState
                                                                    .total,
                                                            orderType:
                                                                previousState
                                                                    .orderType,
                                                          ),
                                                    );
                                                if (result != null &&
                                                    context.mounted) {
                                                  _lastOrderState =
                                                      previousState;
                                                  _lastCustomerData = result;
                                                  context.read<PosBloc>().add(
                                                    SubmitOrderEvent(
                                                      result['method'],
                                                      customerName:
                                                          result['name'],
                                                      customerPhone:
                                                          result['phone'],
                                                      customerAddress:
                                                          result['address'],
                                                    ),
                                                  );
                                                }
                                              },
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.print, size: 24),
                                            SizedBox(width: 8),
                                            Text(
                                              'دفع وطباعة',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}
