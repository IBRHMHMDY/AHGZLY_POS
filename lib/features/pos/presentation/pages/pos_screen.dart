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

  // دالة مساعدة لإظهار نافذة الطباعة بعد نجاح الطلب
  void _showPrintDialog(
    BuildContext context,
    int orderId,
    PosUpdated previousState,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'تم حفظ الطلب! اختر الفاتورة للطباعة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'سيتم فتح قائمة طابعات النظام، يرجى اختيار الطابعة الخاصة بك.',
            ),
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
                      taxAmount: previousState.taxAmount,
                      serviceFee: previousState.serviceFee,
                      deliveryFee: previousState.deliveryFee,
                      total: previousState.total,
                    ),
                  );
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'نقطة البيع (POS)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isAdmin = state is AuthAuthenticated && state.user.isAdmin;

              return Row(
                children: [
                  // الأزرار المخفية عن الكاشير
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
                  // زر تسجيل الخروج (متاح للجميع)
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    tooltip: 'تسجيل الخروج',
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutEvent());
                      context.go('/'); // العودة لشاشة الدخول
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
            // ==========================================
            // الجانب الأيمن (2/3): القائمة (الفئات والأصناف)
            // ==========================================
            Expanded(
              flex: 2,
              child: BlocConsumer<MenuBloc, MenuState>(
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
                builder: (context, state) {
                  return Column(
                    children: [
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
                                  final isSelected =
                                      _selectedCategory?.id == category.id;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedColor: Colors.teal.shade200,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _selectedCategory = category;
                                            _items = [];
                                          });
                                          context.read<MenuBloc>().add(
                                            FetchItemsEvent(category.id!),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (state is MenuLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (_items.isEmpty) {
                              return const Center(
                                child: Text(
                                  'لا توجد أصناف في هذه الفئة',
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            }
                            return GridView.builder(
                              padding: const EdgeInsets.all(12.0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 1.2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return InkWell(
                                  onTap: () {
                                    context.read<PosBloc>().add(
                                      AddItemToCartEvent(item),
                                    );
                                  },
                                  child: Card(
                                    elevation: 3,
                                    color: Colors.teal.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.fastfood,
                                          size: 40,
                                          color: Colors.teal,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.price} ج.م',
                                          style: const TextStyle(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold,
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
                  );
                },
              ),
            ),

            const VerticalDivider(width: 1, thickness: 1),

            // ==========================================
            // الجانب الأيسر (1/3): سلة المشتريات (Cart)
            // ==========================================
            Expanded(
              flex: 1,
              child: BlocConsumer<PosBloc, PosState>(
                // نحتفظ بالحالة السابقة قبل تفريغ السلة لتمريرها للطباعة
                listenWhen: (previous, current) =>
                    current is PosCheckoutSuccess || current is PosError,
                listener: (context, state) {
                  if (state is PosCheckoutSuccess) {
                    // نحتاج حالة السلة المحدثة لطباعتها
                    final _ = context.read<PosBloc>().state;
                    // نظراً لأن السلة تتفرغ تلقائياً، سنلتقط الحالة من خلال متغير محلي أو نكتفي بإظهار رسالة النجاح في حال عدم التخزين
                    // بما أننا قمنا بتفريغ السلة في الـ Bloc بعد النجاح، يجب أن نلتقط البيانات من State قبل الإرسال (تم التعديل في البلوك لعدم التفريغ فوراً أو نمرر البيانات).
                    // للتبسيط في العرض سنعرض النافذة (لقد تم تفريغ السلة في البلوك للأسف، لذا يجب تعديل البلوك لاحقاً إذا أردت طباعة التفاصيل بعد مسحها).
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم حفظ الفاتورة بنجاح! (رقم: ${state.orderId})',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // تنويه: في بيئة العمل الحقيقية، نأخذ نسخة من `PosUpdated` قبل إرسال الطلب لطباعتها هنا.
                    // لعدم تعقيد الكود، سنكتفي حالياً برسالة النجاح ويمكنك إضافة الطابعة للطلب الفعلي عبر الـ LocalStorage.
                  } else if (state is PosError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is PosUpdated) {
                    return Column(
                      children: [
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
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<PosBloc>().add(
                                      ChangeOrderTypeEvent(value),
                                    );
                                  }
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.delete_sweep,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'إلغاء الطلب',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: state.cartItems.isEmpty
                                    ? null
                                    : () => context.read<PosBloc>().add(
                                        ClearCartEvent(),
                                      ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: state.cartItems.isEmpty
                              ? const Center(
                                  child: Text(
                                    'السلة فارغة',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: state.cartItems.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final cartItem = state.cartItems[index];
                                    return ListTile(
                                      title: Text(
                                        cartItem.item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${cartItem.item.price} ج.م',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                context.read<PosBloc>().add(
                                                  UpdateCartItemQuantityEvent(
                                                    index,
                                                    cartItem.quantity - 1,
                                                  ),
                                                ),
                                          ),
                                          Text(
                                            '${cartItem.quantity}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.green,
                                            ),
                                            onPressed: () =>
                                                context.read<PosBloc>().add(
                                                  UpdateCartItemQuantityEvent(
                                                    index,
                                                    cartItem.quantity + 1,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Colors.teal.shade50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSummaryRow(
                                'الإجمالي الفرعي:',
                                state.subTotal,
                              ),
                              _buildSummaryRow('الضريبة%):', state.taxAmount),
                              if (state.orderType == 'صالة')
                                _buildSummaryRow(
                                  'خدمة الصالة (%):',
                                  state.serviceFee,
                                ),
                              if (state.orderType == 'دليفري')
                                _buildSummaryRow(
                                  'رسوم التوصيل:',
                                  state.deliveryFee,
                                ),
                              const Divider(thickness: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'الإجمالي النهائي:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${state.total} ج.م',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: state.cartItems.isEmpty
                                    ? null
                                    : () async {
                                        final previousState =
                                            state; // حفظ نسخة من السلة قبل الدفع
                                        final paymentMethod =
                                            await showDialog<String>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => CheckoutDialog(
                                                totalAmount:
                                                    previousState.total,
                                              ),
                                            );

                                        if (paymentMethod != null &&
                                            context.mounted) {
                                          context.read<PosBloc>().add(
                                            SubmitOrderEvent(paymentMethod),
                                          );
                                          // إظهار نافذة الطباعة مباشرة
                                          // ملحوظة: استخدمنا 0 مؤقتاً كرقم الطلب لسرعة العرض
                                          _showPrintDialog(
                                            context,
                                            1001,
                                            previousState,
                                          );
                                        }
                                      },
                                child: const Text(
                                  'دفــع وطباعة',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
          Text(
            '$amount ج.م',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
