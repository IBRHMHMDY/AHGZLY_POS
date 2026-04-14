import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history_entity.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/receipt_widgets.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';

class OrderDetailsDialog extends StatelessWidget {
  final OrderHistoryEntity order;

  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isRefunded = order.status == OrderStatus.refunded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: _DialogHeader(orderId: order.id, isRefunded: isRefunded),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🪄 1. ملخص الإجمالي
              _OrderSummary(total: order.total, isRefunded: isRefunded),
              const SizedBox(height: 16),
              
              // 🪄 2. قائمة الأصناف
              Flexible(child: _OrderItemsList(items: order.items)),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          _DialogActions(order: order, isRefunded: isRefunded),
        ],
      ),
    );
  }
}

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets)
// ==========================================

class _DialogHeader extends StatelessWidget {
  final int orderId;
  final bool isRefunded;

  const _DialogHeader({required this.orderId, required this.isRefunded});

  @override
  Widget build(BuildContext context) {
    final color = isRefunded ? Colors.red : Colors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isRefunded ? Colors.red.shade50 : Colors.teal.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isRefunded ? Colors.red.shade100 : Colors.teal.shade100, shape: BoxShape.circle),
            child: Icon(Icons.receipt_long, color: color.shade800, size: 28),
          ),
          const SizedBox(width: 12),
          Text('تفاصيل الطلب #$orderId', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color.shade900)),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final int total;
  final bool isRefunded;

  const _OrderSummary({required this.total, required this.isRefunded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRefunded ? Colors.red.shade50 : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isRefunded ? Colors.red.shade200 : Colors.teal.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('إجمالي الطلب:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isRefunded ? Colors.red.shade900 : Colors.teal.shade900)),
          Text(
            '${MoneyFormatter.format(total)} ج.م',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isRefunded ? Colors.red : Colors.teal,
              decoration: isRefunded ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemsList extends StatelessWidget {
  final List<dynamic> items; // يفضل استخدام النوع الصحيح بدلاً من dynamic لاحقاً

  const _OrderItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (ctx, index) {
        final item = items[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text('الكمية: ${item.quantity}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          trailing: Text(
            '${MoneyFormatter.format(item.unitPrice * item.quantity)} ج.م',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
        );
      },
    );
  }
}

class _DialogActions extends StatelessWidget {
  final OrderHistoryEntity order;
  final bool isRefunded;

  const _DialogActions({required this.order, required this.isRefunded});

  Future<void> _handleReprint() async {
    final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
    String rName = 'مـطـعـم احـجـزلـي';
    String tNum = '123-456-789';
    String pName = 'EPSON Printer';

    settingsResult.fold(
      (failure) => debugPrint('Failed to get settings: ${failure.message}'), 
      (settings) {
        rName = settings.restaurantName;
        tNum = settings.taxNumber;
        pName = settings.printerName;
      }
    );

    final printerService = sl<PrinterService>();
    await printerService.printReceiptUsb(
      receiptWidget: CustomerHistoryReceiptWidget(order: order, restaurantName: rName, taxNumber: tNum),
      printerName: pName,
    );
  }

  void _handleRefund(BuildContext context) {
    Navigator.pop(context);
    final authState = context.read<AuthBloc>().state;
    final shiftState = context.read<ShiftBloc>().state;

    final bool isAdmin = (authState is AuthAuthenticated) && authState.user.isAdmin;
    final int? shiftId = (shiftState is ActiveShiftLoaded) ? shiftState.shift.id : null;
    
    context.read<OrdersBloc>().add(RefundOrderEvent(isAdmin: isAdmin, shiftId: shiftId, orderId: order.id));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          child: const Text('إغلاق', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        const Spacer(),
        if (!isRefunded)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _handleRefund(context),
            icon: const Icon(Icons.refresh),
            label: const Text('استرجاع الفاتورة', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('تم استرجاع الطلب', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          onPressed: _handleReprint,
          icon: const Icon(Icons.print),
          label: const Text('إعادة طباعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}