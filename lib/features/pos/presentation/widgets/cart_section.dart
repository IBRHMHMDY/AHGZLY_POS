// مسار الملف: lib/features/pos/presentation/widgets/cart_section.dart

import 'package:ahgzly_pos/core/common/enums/enums_data.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';
import 'package:ahgzly_pos/core/extensions/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// [Clean Architecture Imports]
// [Added] للتعامل مع الطباعة الآلية
import 'package:ahgzly_pos/core/common/widgets/custom_shimmer.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';

// [Features Imports]
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/checkout_dialog.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/receipt_widgets.dart';

class CartSection extends StatefulWidget {
  const CartSection({super.key});

  @override
  State<CartSection> createState() => _CartSectionState();
}

class _CartSectionState extends State<CartSection> {
  PosUpdated? _lastOrderState;
  Map<String, dynamic>? _lastCustomerData;

  void _handleAutoPrint(
    BuildContext context,
    int orderId,
    PosUpdated orderState,
    dynamic mode, // 🪄 تم تغييره إلى dynamic ليكون مرناً جداً
  ) async {
    final authState = context.read<AuthBloc>().state;
    final String currentCashierName = (authState is AuthAuthenticated)
        ? authState.user.name
        : 'غير معروف';

    final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
    String pName = 'EPSON Printer';
    settingsResult.fold((l) => null, (r) => pName = r.printerName);

    final printerService = sl<PrinterService>();
    bool customerSuccess = true;
    bool kitchenSuccess = true;

    // 🪄 [Robust Check]: التحقق المرن لدعم الـ Enums والنصوص مهما كان محتواها
    bool isCustomer = false;
    bool isKitchen = false;

    if (mode is PrintMode) {
      isCustomer = mode == PrintMode.customer || mode == PrintMode.both;
      isKitchen = mode == PrintMode.kitchen || mode == PrintMode.both;
    } else {
      final modeStr = mode.toString();
      isCustomer = modeStr == 'customer' || modeStr == 'both' || modeStr.contains('العميل') || modeStr.contains('both');
      isKitchen = modeStr == 'kitchen' || modeStr == 'both' || modeStr.contains('المطبخ') || modeStr.contains('both');
    }

    if (isCustomer) {
      customerSuccess = await printerService.printReceiptUsb(
        receiptWidget: CustomerReceiptWidget(
          orderId: orderId,
          orderType: orderState.orderType, // كائن Enum
          items: orderState.cartItems,
          subTotal: orderState.subTotal,
          discountAmount: orderState.discountAmount,
          taxAmount: orderState.taxAmount,
          serviceFee: orderState.serviceFee,
          deliveryFee: orderState.deliveryFee,
          total: orderState.total,
          restaurantName: orderState.restaurantName,
          taxNumber: orderState.taxNumber,
          cashierName: currentCashierName,
          customerName: _lastCustomerData?['name'] ?? '',
          customerPhone: _lastCustomerData?['phone'] ?? '',
          customerAddress: _lastCustomerData?['address'] ?? '',
        ),
        printerName: pName,
      );
    }

    if (isKitchen) {
      kitchenSuccess = await printerService.printReceiptUsb(
        receiptWidget: KitchenReceiptWidget(
          orderId: orderId,
          orderType: orderState.orderType, // كائن Enum
          items: orderState.cartItems,
        ),
        printerName: pName,
      );
    }

    if (context.mounted && (isCustomer || isKitchen)) {
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

  void _showPrintDialog(
    BuildContext context,
    int orderId,
    PosUpdated previousState,
  ) {
    final authState = context.read<AuthBloc>().state;
    final String currentCashierName = (authState is AuthAuthenticated)
        ? authState.user.name
        : 'غير معروف';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PrintOptionsDialog(
        orderId: orderId,
        previousState: previousState,
        customerData: _lastCustomerData,
        cashierName: currentCashierName,
      ),
    );
  }

  void _showDiscountDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const _DiscountDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(-5, 0))],
      ),
      child: BlocConsumer<PosBloc, PosState>(
        listenWhen: (previous, current) => current is PosCheckoutSuccess || current is PosError,
        listener: (context, state) {
          if (state is PosCheckoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم حفظ الفاتورة بنجاح! (رقم: #${state.orderId})'), backgroundColor: Colors.green),
            );
            if (_lastOrderState != null) {
              final mode = _lastOrderState!.printMode;
              
              // 🪄 [Robust Check]: التحقق المرن لدعم الـ Enums والنصوص
              bool isAsk = false;
              isAsk = mode == PrintMode.ask;
            
              if (isAsk) {
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
                _CartHeader(orderType: state.orderType),
                Expanded(child: _CartItemsList(cartItems: state.cartItems)),
                _CartSummary(
                  state: state,
                  onDiscountTap: state.cartItems.isEmpty ? null : () => _showDiscountDialog(context),
                  onPayTap: state.cartItems.isEmpty
                      ? null
                      : () async {
                          final result = await showDialog<Map<String, dynamic>>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => CheckoutDialog(
                              totalAmount: state.total,
                              orderType: state.orderType, 
                            ),
                          );
                          
                          if (result != null && context.mounted) {
                            _lastOrderState = state;
                            _lastCustomerData = result;

                            // تحويل احتياطي (Fallback) في حال أرجعت النافذة نصاً بالخطأ
                            final rawMethod = result['method'];
                            final PaymentMethod paymentMethod = rawMethod is PaymentMethod 
                                ? rawMethod 
                                : PaymentMethodExtension.fromValue(rawMethod.toString());

                            context.read<PosBloc>().add(
                              SubmitOrderEvent(
                                paymentMethod, // كائن Enum
                                customerName: result['name'],
                                customerPhone: result['phone'],
                                customerAddress: result['address'],
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          }
          return const _CartShimmerLoading();
        },
      ),
    );
  }
}

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets) المستخرجة
// ==========================================

class _CartHeader extends StatelessWidget {
  final OrderType orderType; 
  const _CartHeader({required this.orderType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<OrderType>(
                  value: orderType, 
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.teal),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                  items: OrderType.values.map((type) => DropdownMenuItem<OrderType>(
                    value: type, 
                    child: Text(type.toDisplayName(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<PosBloc>().add(ChangeOrderTypeEvent(value));
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => context.read<PosBloc>().add(ClearCartEvent()),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.delete_sweep, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemsList extends StatelessWidget {
  final List<dynamic> cartItems; 
  const _CartItemsList({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('الفاتورة فارغة', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: cartItems.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${MoneyFormatter.format(cartItem.item.price)} ج.م', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade300)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => context.read<PosBloc>().add(UpdateCartItemQuantityEvent(index, cartItem.quantity - 1)),
                    child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8), child: Icon(Icons.remove, size: 16, color: Colors.black87)),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    alignment: Alignment.center,
                    child: Text('${cartItem.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  InkWell(
                    onTap: () => context.read<PosBloc>().add(UpdateCartItemQuantityEvent(index, cartItem.quantity + 1)),
                    child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8), child: Icon(Icons.add, size: 16, color: Colors.black87)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => context.read<PosBloc>().add(RemoveItemFromCartEvent(index)),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CartSummary extends StatelessWidget {
  final PosUpdated state;
  final VoidCallback? onDiscountTap;
  final VoidCallback? onPayTap;

  const _CartSummary({required this.state, this.onDiscountTap, this.onPayTap});

  Widget _buildSummaryRow(String label, int amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: isDiscount ? Colors.red : (isTotal ? Colors.teal.shade800 : Colors.black87)), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text('${isDiscount ? "-" : ""}${MoneyFormatter.format(amount)} ج.م', style: TextStyle(fontSize: isTotal ? 20 : 14, fontWeight: FontWeight.bold, color: isDiscount ? Colors.red : (isTotal ? Colors.teal.shade800 : Colors.black87))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryRow('الإجمالي الفرعي:', state.subTotal),
            if (state.discountAmount > 0) _buildSummaryRow('قيمة الخصم:', state.discountAmount, isDiscount: true),
            _buildSummaryRow('الضريبة المضافة:', state.taxAmount),
            
            // الاعتماد بشكل آمن على الـ Enums
            if (state.orderType == OrderType.dineIn) _buildSummaryRow('رسوم الخدمة:', state.serviceFee),
            if (state.orderType == OrderType.delivery) _buildSummaryRow('رسوم التوصيل:', state.deliveryFee),
              
            const Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: Divider(thickness: 2)),
            _buildSummaryRow('الإجمالي النهائي:', state.total, isTotal: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.teal, side: const BorderSide(color: Colors.teal, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: onDiscountTap,
                    child: const Icon(Icons.discount_outlined, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4),
                    onPressed: onPayTap,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.print, size: 20),
                        SizedBox(width: 4),
                        Flexible(child: Text('دفع وطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountDialog extends StatefulWidget {
  const _DiscountDialog();

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('إضافة خصم (مبلغ ثابت)', style: TextStyle(fontWeight: FontWeight.bold)),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(labelText: 'قيمة الخصم (ج.م)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.money_off, color: Colors.teal)),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontSize: 16))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              final discountDouble = double.tryParse(_controller.text) ?? 0.0;
              final discountCents = MoneyFormatter.toCents(discountDouble);
              context.read<PosBloc>().add(ApplyDiscountEvent(discountCents));
              Navigator.pop(context);
            }
          },
          child: const Text('تطبيق الخصم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _PrintOptionsDialog extends StatelessWidget {
  final int orderId;
  final PosUpdated previousState;
  final Map<String, dynamic>? customerData;
  final String cashierName;

  const _PrintOptionsDialog({required this.orderId, required this.previousState, required this.customerData, required this.cashierName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('تم حفظ الطلب!', style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text('اختر الفاتورة التي ترغب في طباعتها:', style: TextStyle(fontSize: 16)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق', style: TextStyle(color: Colors.red, fontSize: 16))),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          icon: const Icon(Icons.person),
          label: const Text('فاتورة العميل'),
          onPressed: () async {
            final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
            String pName = 'EPSON Printer';
            settingsResult.fold((l) => null, (r) => pName = r.printerName);

            await sl<PrinterService>().printReceiptUsb(
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
                customerName: customerData?['name'] ?? '',
                customerPhone: customerData?['phone'] ?? '',
                customerAddress: customerData?['address'] ?? '',
                cashierName: cashierName,
              ),
              printerName: pName,
            );
          },
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
          icon: const Icon(Icons.kitchen),
          label: const Text('بون المطبخ'),
          onPressed: () async {
            final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
            String pName = 'EPSON Printer';
            settingsResult.fold((l) => null, (r) => pName = r.printerName);

            await sl<PrinterService>().printReceiptUsb(
              receiptWidget: KitchenReceiptWidget(
                orderId: orderId,
                orderType: previousState.orderType,
                items: previousState.cartItems,
              ),
              printerName: pName,
            );
          },
        ),
      ],
    );
  }
}

class _CartShimmerLoading extends StatelessWidget {
  const _CartShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Row(
            children: [
              Expanded(child: CustomShimmer.rectangular(height: 48, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(width: 8),
              CustomShimmer.rectangular(height: 48, width: 48, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: 4, 
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomShimmer.rectangular(height: 16, width: double.infinity, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 8),
                        CustomShimmer.rectangular(height: 14, width: 80, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  CustomShimmer.rectangular(height: 36, width: 90, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  const SizedBox(width: 8),
                  const CustomShimmer.circular(height: 36, width: 36),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
          child: Column(
            children: [
              CustomShimmer.rectangular(height: 20, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              CustomShimmer.rectangular(height: 20, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              CustomShimmer.rectangular(height: 24, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 1, child: CustomShimmer.rectangular(height: 56, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(width: 8),
                  Expanded(flex: 3, child: CustomShimmer.rectangular(height: 56, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}