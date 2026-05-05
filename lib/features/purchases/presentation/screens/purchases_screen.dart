import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/purchases_bloc.dart';
import '../bloc/purchases_event.dart';
import '../bloc/purchases_state.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:intl/intl.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PurchasesBloc>().add(LoadPurchasesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shopping_cart),
            SizedBox(width: 8),
            Text('فواتير المشتريات والتوريد', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addPurchase),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('تسجيل فاتورة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<PurchasesBloc, PurchasesState>(
        builder: (context, state) {
          if (state is PurchasesLoading || state is PurchasesInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PurchasesError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 18)));
          }
          if (state is PurchasesLoaded) {
            final invoices = state.invoices;
            if (invoices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('لا توجد فواتير مشتريات مسجلة', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                  ],
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: const Icon(Icons.receipt, color: Colors.teal),
                        ),
                        title: Text('رقم الفاتورة: #${invoice.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.invoiceDate)}'),
                            if (invoice.notes != null && invoice.notes!.isNotEmpty) Text('ملاحظات: ${invoice.notes}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(MoneyFormatter.format(invoice.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                            Text('المدفوع: ${MoneyFormatter.format(invoice.paidAmount)}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
