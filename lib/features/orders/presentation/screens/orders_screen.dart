import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_event.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_state.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';
import 'package:ahgzly_pos/features/orders/presentation/widgets/order_details_dialog.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/core/common/widgets/custom_shimmer.dart'; // 🪄 استيراد الشيمر

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  void _loadOrders() {
    final authState = context.read<AuthBloc>().state;
    final shiftState = context.read<ShiftBloc>().state;
    
    final bool isAdmin = (authState is AuthAuthenticated) && authState.user.isAdmin;
    final int? shiftId = (shiftState is ActiveShiftLoaded) ? shiftState.shift.id : null;
    
    context.read<OrdersBloc>().add(LoadOrdersEvent(isAdmin: isAdmin, shiftId: shiftId));
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.history),
            SizedBox(width: 8),
            Text('سجل الطلبات', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) return const _OrdersShimmerLoading(); // 🪄 الشيمر الاحترافي
          if (state is OrdersError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 18)));
          
          if (state is OrdersLoaded) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildSummaryHeader(state.orders.length),
                    Expanded(
                      child: state.orders.isEmpty
                          ? const _EmptyOrdersView()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: state.orders.length,
                              itemBuilder: (context, index) {
                                return _OrderCard(order: state.orders[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryHeader(int totalOrders) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100, width: 2),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.teal, size: 32),
              SizedBox(width: 12),
              Text('إجمالي الطلبات المسجلة:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          Text(
            '$totalOrders طلب',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets)
// ==========================================

class _OrderCard extends StatelessWidget {
  final OrderHistory order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(order.createdAt).toString().substring(0, 16);
    final isRefunded = order.status == 'مرتجع';
    
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: isRefunded ? Colors.red.shade50 : Colors.teal.shade50,
          child: Text('#${order.id}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isRefunded ? Colors.red : Colors.teal)),
        ),
        title: Text(
          'الإجمالي: ${MoneyFormatter.format(order.total)} ج.م', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isRefunded ? Colors.red : Colors.black87, decoration: isRefunded ? TextDecoration.lineThrough : null)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(date, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(width: 12),
              Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(order.orderType, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(width: 12),
              Icon(isRefunded ? Icons.cancel_outlined : Icons.payment, size: 16, color: isRefunded ? Colors.red : Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(isRefunded ? "مرتجع" : order.paymentMethod, style: TextStyle(color: isRefunded ? Colors.red : Colors.grey.shade700, fontWeight: isRefunded ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ),
        onTap: () => showDialog(
          context: context,
          builder: (_) => OrderDetailsDialog(order: order),
        ),
      ),
    );
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا توجد طلبات سابقة', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _OrdersShimmerLoading extends StatelessWidget {
  const _OrdersShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: CustomShimmer.rectangular(height: 80, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                itemBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomShimmer.rectangular(height: 90, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}