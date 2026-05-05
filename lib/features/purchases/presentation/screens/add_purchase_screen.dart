import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import '../../data/models/purchase_invoice_item_model.dart';
import '../bloc/purchases_bloc.dart';
import '../bloc/purchases_event.dart';
import '../bloc/purchases_state.dart';
import 'package:ahgzly_pos/features/suppliers/presentation/bloc/suppliers_bloc.dart';
import 'package:ahgzly_pos/features/suppliers/presentation/bloc/suppliers_event.dart';
import 'package:ahgzly_pos/features/suppliers/presentation/bloc/suppliers_state.dart';
import 'package:ahgzly_pos/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:ahgzly_pos/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:ahgzly_pos/features/inventory/presentation/bloc/inventory_state.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  int? _selectedSupplierId;
  final List<PurchaseInvoiceItemModel> _items = [];
  
  final _paidAmountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  // Temporary controllers for adding item
  int? _selectedInventoryItemId;
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController(); // Unit cost in regular currency (e.g., 50.5 EGP)

  @override
  void initState() {
    super.initState();
    context.read<SuppliersBloc>().add(LoadSuppliersEvent());
    context.read<InventoryBloc>().add(LoadInventoryItemsEvent());
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  int get _totalAmount {
    int total = 0;
    for (var item in _items) {
      total += item.totalCost;
    }
    return total;
  }

  void _addItem() {
    if (_selectedInventoryItemId == null || _quantityController.text.isEmpty || _unitCostController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء كافة بيانات الخامة'), backgroundColor: Colors.red));
      return;
    }

    final qty = double.tryParse(_quantityController.text) ?? 0;
    final unitCostCents = MoneyFormatter.toCents(double.tryParse(_unitCostController.text) ?? 0);

    if (qty <= 0 || unitCostCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكمية والسعر يجب أن يكونا أكبر من صفر'), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _items.add(PurchaseInvoiceItemModel(
        id: 0,
        invoiceId: 0, // Assigned later
        inventoryItemId: _selectedInventoryItemId!,
        quantity: qty,
        unitCost: unitCostCents,
        totalCost: (unitCostCents * qty).round(),
      ));
      
      // Reset form
      _selectedInventoryItemId = null;
      _quantityController.clear();
      _unitCostController.clear();
      
      // Default full payment
      _paidAmountController.text = (_totalAmount / 100).toString();
    });
  }

  void _saveInvoice() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب إضافة خامة واحدة على الأقل'), backgroundColor: Colors.red));
      return;
    }

    final paidAmount = MoneyFormatter.toCents(double.tryParse(_paidAmountController.text) ?? 0);

    context.read<PurchasesBloc>().add(SavePurchaseInvoiceEvent(
      supplierId: _selectedSupplierId,
      totalAmount: _totalAmount,
      paidAmount: paidAmount,
      notes: _notesController.text,
      items: _items,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchasesBloc, PurchasesState>(
      listener: (context, state) {
        if (state is PurchaseInvoiceSavedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الفاتورة وتحديث المخزون بنجاح'), backgroundColor: Colors.green));
          context.read<InventoryBloc>().add(LoadInventoryItemsEvent()); // Refresh stock
          context.pop();
        } else if (state is PurchasesError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('تسجيل فاتورة مشتريات', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          actions: [
            TextButton.icon(
              onPressed: _saveInvoice,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('حفظ الفاتورة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Right Side: Form (Supplier + Add Items)
                Expanded(
                  flex: 4,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Supplier Selection
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('المورد (اختياري)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              BlocBuilder<SuppliersBloc, SuppliersState>(
                                builder: (context, state) {
                                  if (state is SuppliersLoaded) {
                                    return DropdownButtonFormField<int>(
                                      value: _selectedSupplierId,
                                      decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                                      items: state.suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                                      onChanged: (val) => setState(() => _selectedSupplierId = val),
                                      hint: const Text('اختر مورد (أو اتركه فارغاً)'),
                                    );
                                  }
                                  return const LinearProgressIndicator();
                                },
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _notesController,
                                decoration: const InputDecoration(labelText: 'ملاحظات الفاتورة', border: OutlineInputBorder(), prefixIcon: Icon(Icons.note)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Add Item Form
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إضافة خامة للفاتورة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              BlocBuilder<InventoryBloc, InventoryState>(
                                builder: (context, state) {
                                  if (state is InventoryLoaded) {
                                    return DropdownButtonFormField<int>(
                                      value: _selectedInventoryItemId,
                                      decoration: const InputDecoration(labelText: 'اختر الخامة', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2)),
                                      items: state.items.map((i) => DropdownMenuItem(value: i.id, child: Text('${i.name} (${i.unit})'))).toList(),
                                      onChanged: (val) => setState(() => _selectedInventoryItemId = val),
                                    );
                                  }
                                  return const LinearProgressIndicator();
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _quantityController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(labelText: 'الكمية الواردة', border: OutlineInputBorder(), prefixIcon: Icon(Icons.scale)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _unitCostController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(labelText: 'سعر الوحدة (ج.م)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: _addItem,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24)),
                                    child: const Text('إضافة'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Left Side: Invoice Items & Totals
                Expanded(
                  flex: 3,
                  child: Card(
                    margin: const EdgeInsets.all(16).copyWith(right: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('عناصر الفاتورة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Divider(),
                          Expanded(
                            child: _items.isEmpty
                                ? const Center(child: Text('لا توجد خامات مضافة بعد', style: TextStyle(color: Colors.grey)))
                                : ListView.builder(
                                    itemCount: _items.length,
                                    itemBuilder: (context, index) {
                                      final item = _items[index];
                                      return ListTile(
                                        title: Text('خامة ID: ${item.inventoryItemId} (الكمية: ${item.quantity})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('السعر: ${MoneyFormatter.format(item.unitCost)} للوحدة'),
                                        trailing: Text(MoneyFormatter.format(item.totalCost), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      );
                                    },
                                  ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الإجمالي العام:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(MoneyFormatter.format(_totalAmount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _paidAmountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'المبلغ المدفوع للمورد', border: OutlineInputBorder(), prefixIcon: Icon(Icons.payment)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
