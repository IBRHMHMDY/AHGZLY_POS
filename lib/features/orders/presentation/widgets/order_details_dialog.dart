import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/receipt_widgets.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';

class OrderDetailsDialog extends StatelessWidget {
  final OrderHistory order;

  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isRefunded = order.status == 'مرتجع';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: isRefunded ? Colors.red : Colors.teal,
          ),
          const SizedBox(width: 8),
          Text(
            'تفاصيل الطلب #${order.id}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRefunded ? Colors.red.shade50 : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إجمالي الطلب:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${order.total} ج.م',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isRefunded ? Colors.red : Colors.teal,
                      decoration: isRefunded
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: order.items.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (ctx, index) {
                  final item = order.items[index];
                  return ListTile(
                    title: Text(
                      item.itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'الكمية: ${item.quantity}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    trailing: Text(
                      '${item.unitPrice * item.quantity} ج.م',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (!isRefunded)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      final authState = context.read<AuthBloc>().state;
                      final shiftState = context.read<ShiftBloc>().state;

                      final bool isAdmin =
                          (authState is AuthAuthenticated) &&
                          authState.user.isAdmin;
                      final int? shiftId = (shiftState is ActiveShiftLoaded)
                          ? shiftState.shift.id
                          : null;
                      context.read<OrdersBloc>().add(
                        RefundOrderEvent(
                          isAdmin: isAdmin,
                          shiftId: shiftId,
                          orderId: order.id,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'استرجاع (Refund)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'تم استرجاع الطلب',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(width: 12),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final settingsResult = await sl<GetSettingsUseCase>().call(
                      NoParams(),
                    );
                    String rName = 'مـطـعـم احـجـزلـي';
                    String tNum = '123-456-789';
                    settingsResult.fold((l) => null, (r) {
                      rName = r.restaurantName;
                      tNum = r.taxNumber;
                    });

                    final printerService = sl<PrinterService>();
                    await printerService.printReceiptUsb(
                      receiptWidget: CustomerHistoryReceiptWidget(
                        order: order,
                        restaurantName: rName,
                        taxNumber: tNum,
                      ),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text(
                    'إعادة طباعة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إغلاق',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
