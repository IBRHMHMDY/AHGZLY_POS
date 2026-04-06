import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
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

  void _handleAutoPrint(BuildContext context, int orderId, PosUpdated orderState, String mode) async {
    final authState = context.read<AuthBloc>().state;
    final String currentCashierName = (authState is AuthAuthenticated) ? authState.user.name : 'غير معروف';
    final printerService = sl<PrinterService>();
    bool customerSuccess = true;
    bool kitchenSuccess = true;
    

    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري الطباعة التلقائية...')));

    if (mode == 'customer' || mode == 'both') {
      customerSuccess = await printerService.printReceiptUsb(
        receiptWidget: CustomerReceiptWidget(
          orderId: orderId, orderType: orderState.orderType, items: orderState.cartItems,
          subTotal: orderState.subTotal, discountAmount: orderState.discountAmount, taxAmount: orderState.taxAmount,
          serviceFee: orderState.serviceFee, deliveryFee: orderState.deliveryFee, total: orderState.total,
          restaurantName: orderState.restaurantName, taxNumber: orderState.taxNumber,
          cashierName: currentCashierName,
          customerName: _lastCustomerData?['name'] ?? '', customerPhone: _lastCustomerData?['phone'] ?? '', customerAddress: _lastCustomerData?['address'] ?? '',
        ),
      );
    }

    if (mode == 'kitchen' || mode == 'both') {
      kitchenSuccess = await printerService.printReceiptUsb(
        receiptWidget: KitchenReceiptWidget(orderId: orderId, orderType: orderState.orderType, items: orderState.cartItems),
      );
    }

    if (context.mounted) {
      if (customerSuccess && kitchenSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الطباعة بنجاح'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الاتصال بالطابعة!'), backgroundColor: Colors.red));
      }
    }
  }

  void _showPrintDialog(BuildContext context, int orderId, PosUpdated previousState) {
    final authState = context.read<AuthBloc>().state;
    final String currentCashierName = (authState is AuthAuthenticated) ? authState.user.name : 'غير معروف';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تم حفظ الطلب!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('اختر الفاتورة التي ترغب في طباعتها:', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق', style: TextStyle(color: Colors.red, fontSize: 16))),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            icon: const Icon(Icons.person),
            label: const Text('فاتورة العميل'),
            onPressed: () async {
              await sl<PrinterService>().printReceiptUsb(
                receiptWidget: CustomerReceiptWidget(
                  orderId: orderId, orderType: previousState.orderType, items: previousState.cartItems,
                  subTotal: previousState.subTotal, discountAmount: previousState.discountAmount, taxAmount: previousState.taxAmount,
                  serviceFee: previousState.serviceFee, deliveryFee: previousState.deliveryFee, total: previousState.total,
                  restaurantName: previousState.restaurantName, taxNumber: previousState.taxNumber,
                  customerName: _lastCustomerData?['name'] ?? '', customerPhone: _lastCustomerData?['phone'] ?? '', customerAddress: _lastCustomerData?['address'] ?? '',
                  cashierName: currentCashierName,
                ),
              );
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
            icon: const Icon(Icons.kitchen),
            label: const Text('بون المطبخ'),
            onPressed: () async {
              await sl<PrinterService>().printReceiptUsb(receiptWidget: KitchenReceiptWidget(orderId: orderId, orderType: previousState.orderType, items: previousState.cartItems));
            },
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة خصم (مبلغ ثابت)', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller, keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          decoration: InputDecoration(labelText: 'قيمة الخصم (ج.م)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.money_off, color: Colors.teal)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontSize: 16))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final discount = double.tryParse(controller.text) ?? 0.0;
                context.read<PosBloc>().add(ApplyDiscountEvent(discount));
                Navigator.pop(ctx);
              }
            },
            child: const Text('تطبيق الخصم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الحماية من الـ Overflow عن طريق تقليص النص الطويل
          Expanded(
            child: Text(
              label, 
              style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: isDiscount ? Colors.red : (isTotal ? Colors.teal.shade800 : Colors.black87)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text('${isDiscount ? "-" : ""}${amount.toStringAsFixed(2)} ج.م', style: TextStyle(fontSize: isTotal ? 20 : 14, fontWeight: FontWeight.bold, color: isDiscount ? Colors.red : (isTotal ? Colors.teal.shade800 : Colors.black87))),
        ],
      ),
    );
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ الفاتورة بنجاح! (رقم: #${state.orderId})'), backgroundColor: Colors.green));
            if (_lastOrderState != null) {
              final mode = _lastOrderState!.printMode;
              if (mode == 'ask') {
                _showPrintDialog(context, state.orderId, _lastOrderState!);
              } else {
                _handleAutoPrint(context, state.orderId, _lastOrderState!, mode);
              }
            }
          } else if (state is PosError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        buildWhen: (previous, current) => current is PosUpdated || current is PosInitial,
        builder: (context, state) {
          if (state is PosUpdated) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: state.orderType,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.teal),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                              items: ['تيك أواي', 'صالة', 'دليفري'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                              onChanged: (value) {
                                if (value != null) context.read<PosBloc>().add(ChangeOrderTypeEvent(value));
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.read<PosBloc>().add(ClearCartEvent()),
                        child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete_sweep, color: Colors.red)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('الفاتورة فارغة', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: state.cartItems.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, index) {
                            final cartItem = state.cartItems[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // تم تصحيح الـ Expanded وتحديد maxLines لحماية النص
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.item.name, 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text('${cartItem.item.price} ج.م', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // 🪄 السحر هنا: mainAxisSize: MainAxisSize.min لحماية الأزرار من التمدد العشوائي
                                Container(
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade300)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, 
                                    children: [
                                      InkWell(onTap: () => context.read<PosBloc>().add(UpdateCartItemQuantityEvent(index, cartItem.quantity - 1)), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8), child: Icon(Icons.remove, size: 16, color: Colors.black87))),
                                      Container(constraints: const BoxConstraints(minWidth: 20), alignment: Alignment.center, child: Text('${cartItem.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                                      InkWell(onTap: () => context.read<PosBloc>().add(UpdateCartItemQuantityEvent(index, cartItem.quantity + 1)), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8), child: Icon(Icons.add, size: 16, color: Colors.black87))),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => context.read<PosBloc>().add(RemoveItemFromCartEvent(index)),
                                  child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle), child: const Icon(Icons.delete_outline, color: Colors.red, size: 18)),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSummaryRow('الإجمالي الفرعي:', state.subTotal),
                        if (state.discountAmount > 0) _buildSummaryRow('قيمة الخصم:', state.discountAmount, isDiscount: true),
                        _buildSummaryRow('الضريبة المضافة:', state.taxAmount),
                        if (state.orderType == 'صالة') _buildSummaryRow('رسوم الخدمة:', state.serviceFee),
                        if (state.orderType == 'دليفري') _buildSummaryRow('رسوم التوصيل:', state.deliveryFee),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: Divider(thickness: 2)),
                        _buildSummaryRow('الإجمالي النهائي:', state.total, isTotal: true),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.teal, side: const BorderSide(color: Colors.teal, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: state.cartItems.isEmpty ? null : () => _showDiscountDialog(context),
                                child: const Icon(Icons.discount_outlined, size: 24),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4),
                                onPressed: state.cartItems.isEmpty ? null : () async {
                                  final previousState = state;
                                  final result = await showDialog<Map<String, dynamic>>(
                                    context: context, barrierDismissible: false,
                                    builder: (_) => CheckoutDialog(totalAmount: previousState.total, orderType: previousState.orderType),
                                  );
                                  if (result != null && context.mounted) {
                                    _lastOrderState = previousState;
                                    _lastCustomerData = result;
                                    context.read<PosBloc>().add(SubmitOrderEvent(result['method'], customerName: result['name'], customerPhone: result['phone'], customerAddress: result['address']));
                                  }
                                },
                                // حماية زر الدفع من التمدد والخطأ
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center, 
                                  children: [
                                    Icon(Icons.print, size: 20), 
                                    SizedBox(width: 4), 
                                    Flexible(
                                      child: Text('دفع وطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)
                                    )
                                  ]
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}