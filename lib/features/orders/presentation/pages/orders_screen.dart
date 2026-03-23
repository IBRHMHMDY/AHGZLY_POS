import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/di/injection_container.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_event.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/receipt_widgets.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الطلبات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) return const Center(child: CircularProgressIndicator());
            if (state is OrdersError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            if (state is OrdersLoaded) {
              if (state.orders.isEmpty) return const Center(child: Text('لا توجد طلبات سابقة', style: TextStyle(fontSize: 18)));
              
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  final date = DateTime.parse(order.createdAt).toString().substring(0, 16);
                  final isRefunded = order.status == 'مرتجع';
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: isRefunded ? Colors.red.shade50 : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isRefunded ? Colors.red.shade100 : Colors.teal.shade100,
                        child: Text('#${order.id}', style: TextStyle(fontWeight: FontWeight.bold, color: isRefunded ? Colors.red : Colors.teal)),
                      ),
                      title: Text('الإجمالي: ${order.total} ج.م', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, decoration: isRefunded ? TextDecoration.lineThrough : null)),
                      subtitle: Text('$date  |  ${order.orderType}  |  ${isRefunded ? "مرتجع" : order.paymentMethod}', style: TextStyle(color: isRefunded ? Colors.red : Colors.grey)),
                      trailing: const Icon(Icons.visibility, color: Colors.grey),
                      onTap: () => _showOrderDetails(context, order),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderHistory order) {
    final isRefunded = order.status == 'مرتجع';

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تفاصيل الطلب #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, index) {
                final item = order.items[index];
                return ListTile(
                  title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الكمية: ${item.quantity}'),
                  trailing: Text('${item.unitPrice * item.quantity} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            Row(
              children: [
                // زر الاسترجاع (يختفي إذا كان الطلب مرتجعاً بالفعل)
                if (!isRefunded)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext); // إغلاق النافذة
                      context.read<OrdersBloc>().add(RefundOrderEvent(order.id));
                    },
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    label: const Text('استرجاع (Refund)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('تم استرجاع الطلب', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  
                const SizedBox(width: 8),
                // زر إعادة الطباعة
                TextButton.icon(
                  onPressed: () async {
                    // 1. جلب اسم المطعم والرقم الضريبي من الإعدادات
                    final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
                    String rName = 'مـطـعـم احـجـزلـي';
                    String tNum = '123-456-789';
                    settingsResult.fold(
                      (l) => null,
                      (r) { rName = r.restaurantName; tNum = r.taxNumber; }
                    );
                    
                    // 2. أمر الطباعة
                    final printerService = sl<PrinterService>();
                    await printerService.printReceiptUsb(
                      receiptWidget: CustomerHistoryReceiptWidget(
                        order: order,
                        restaurantName: rName,
                        taxNumber: tNum,
                      ),
                    );
                  },
                  icon: const Icon(Icons.print, color: Colors.blue),
                  label: const Text('إعادة طباعة', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}