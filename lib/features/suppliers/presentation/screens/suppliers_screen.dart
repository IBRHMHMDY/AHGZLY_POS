import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/suppliers_bloc.dart';
import '../bloc/suppliers_event.dart';
import '../bloc/suppliers_state.dart';
import '../widgets/add_supplier_dialog.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SuppliersBloc>().add(LoadSuppliersEvent());
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<SuppliersBloc>(),
        child: const AddSupplierDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_shipping),
            SizedBox(width: 8),
            Text('إدارة الموردين', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSupplierDialog,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مورد', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<SuppliersBloc, SuppliersState>(
        builder: (context, state) {
          if (state is SuppliersLoading || state is SuppliersInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SuppliersError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 18)));
          }
          if (state is SuppliersLoaded) {
            final suppliers = state.suppliers;
            if (suppliers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_off_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('لا يوجد موردين مسجلين', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                  ],
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                  itemCount: suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = suppliers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: const Icon(Icons.person, color: Colors.teal),
                        ),
                        title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (supplier.phone != null && supplier.phone!.isNotEmpty) Text('الهاتف: ${supplier.phone}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => context.read<SuppliersBloc>().add(DeleteSupplierEvent(supplier.id)),
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
