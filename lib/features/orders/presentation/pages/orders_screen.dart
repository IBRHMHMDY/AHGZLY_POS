import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ahgzly_pos/features/orders/presentation/bloc/orders_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الطلبات'),
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
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      ),
                      title: Text('الإجمالي: ${order.total} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('$date  |  ${order.orderType}  |  ${order.paymentMethod}'),
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
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تفاصيل الطلب #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: order.items.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الكمية: ${item.quantity}'),
                  trailing: Text('${item.unitPrice * item.quantity} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}