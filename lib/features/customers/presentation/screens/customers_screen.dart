import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/features/customers/data/models/customer_model.dart';
import 'package:ahgzly_pos/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:ahgzly_pos/features/customers/presentation/bloc/customers_event.dart';
import 'package:ahgzly_pos/features/customers/presentation/bloc/customers_state.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomersBloc>().add(const LoadCustomersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog([CustomerModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomersBloc>(),
        child: AlertDialog(
          title: Text(existing == null ? 'إضافة عميل جديد' : 'تعديل بيانات العميل',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'اسم العميل', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'العنوان (للدليفري)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            Builder(
              builder: (builderContext) => ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (existing == null) {
                      builderContext.read<CustomersBloc>().add(AddCustomerEvent(
                        CustomersCompanion.insert(
                          name: nameCtrl.text.trim(),
                          phone: drift.Value(phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim()),
                          address: drift.Value(addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim()),
                        ),
                      ));
                    } else {
                      builderContext.read<CustomersBloc>().add(UpdateCustomerEvent(
                        CustomersCompanion(
                          id: drift.Value(existing.id),
                          name: drift.Value(nameCtrl.text.trim()),
                          phone: drift.Value(phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim()),
                          address: drift.Value(addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim()),
                        ),
                      ));
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext ctx, CustomerModel customer) {
    ctx.read<CustomersBloc>().add(LoadCustomerDetailEvent(customer.id));
    showDialog(
      context: ctx,
      builder: (_) => BlocProvider.value(
        value: ctx.read<CustomersBloc>(),
        child: _CustomerDetailDialog(customer: customer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1923),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('إدارة العملاء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('إضافة عميل', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E2D3D),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو رقم الهاتف...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, color: Colors.white38), onPressed: () {
                        _searchController.clear();
                        context.read<CustomersBloc>().add(const LoadCustomersEvent());
                      })
                    : null,
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (q) {
                context.read<CustomersBloc>().add(LoadCustomersEvent(searchQuery: q.isNotEmpty ? q : null));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomersBloc, CustomersState>(
              buildWhen: (prev, curr) => curr is CustomersLoaded || curr is CustomersLoading || curr is CustomersError,
              builder: (context, state) {
                if (state is CustomersLoading) return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
                if (state is CustomersError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent)));
                if (state is CustomersLoaded) {
                  if (state.customers.isEmpty) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.people_outline, size: 80, color: Colors.white12),
                        const SizedBox(height: 16),
                        Text(state.searchQuery != null ? 'لا توجد نتائج' : 'لا يوجد عملاء مسجلون بعد',
                            style: const TextStyle(color: Colors.white38, fontSize: 18)),
                      ]),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                    itemCount: state.customers.length,
                    itemBuilder: (ctx, i) {
                      final c = state.customers[i];
                      return _CustomerCard(
                        customer: c,
                        onTap: () => _showDetail(ctx, c),
                        onEdit: () => _showAddDialog(c),
                        onDelete: () => ctx.read<CustomersBloc>().add(DeleteCustomerEvent(c.id)),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Customer Card
// ─────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({required this.customer, required this.onTap, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF1E2D3D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.tealAccent.withOpacity(0.15),
                child: Text(customer.name[0], style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    if (customer.phone != null) Text(customer.phone!, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    if (customer.address != null && customer.address!.isNotEmpty)
                      Text(customer.address!, style: const TextStyle(color: Colors.white38, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.chevron_left, color: Colors.white38),
                  PopupMenuButton(
                    color: const Color(0xFF1E2D3D),
                    icon: const Icon(Icons.more_vert, color: Colors.white38),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.tealAccent, size: 18), SizedBox(width: 8), Text('تعديل', style: TextStyle(color: Colors.white))])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.redAccent, size: 18), SizedBox(width: 8), Text('حذف', style: TextStyle(color: Colors.redAccent))])),
                    ],
                    onSelected: (val) {
                      if (val == 'edit') onEdit();
                      if (val == 'delete') onDelete();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Customer Detail Dialog
// ─────────────────────────────────────────

class _CustomerDetailDialog extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerDetailDialog({required this.customer});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd HH:mm');

    return AlertDialog(
      backgroundColor: const Color(0xFF1E2D3D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        CircleAvatar(backgroundColor: Colors.tealAccent.withOpacity(0.15), child: Text(customer.name[0], style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(customer.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          if (customer.phone != null) Text(customer.phone!, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ])),
      ]),
      content: SizedBox(
        width: 500,
        child: BlocBuilder<CustomersBloc, CustomersState>(
          buildWhen: (prev, curr) => curr is CustomerDetailLoaded || curr is CustomersLoading,
          builder: (context, state) {
            if (state is CustomersLoading) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.tealAccent)));
            if (state is CustomerDetailLoaded && state.detail.customer.id == customer.id) {
              final d = state.detail;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    Row(children: [
                      _statChip('إجمالي الإنفاق', MoneyFormatter.format(d.totalSpent), Colors.greenAccent),
                      const SizedBox(width: 12),
                      _statChip('عدد الطلبات', '${d.totalOrders}', Colors.blueAccent),
                      const SizedBox(width: 12),
                      _statChip('متوسط الطلب', MoneyFormatter.format(d.avgOrderValue), Colors.orangeAccent),
                    ]),
                    if (customer.address != null && customer.address!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(children: [
                        const Icon(Icons.location_on, color: Colors.white38, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(customer.address!, style: const TextStyle(color: Colors.white54))),
                      ]),
                    ],
                    const SizedBox(height: 16),
                    const Text('آخر الطلبات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    if (d.recentOrders.isEmpty)
                      const Text('لا توجد طلبات مسجلة', style: TextStyle(color: Colors.white38))
                    else
                      ...d.recentOrders.map((o) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('طلب #${o.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('${o.itemsCount} صنف | ${fmt.format(o.createdAt)}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ])),
                          Text(MoneyFormatter.format(o.total), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                        ]),
                      )),
                  ],
                ),
              );
            }
            return const SizedBox(height: 100);
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق', style: TextStyle(color: Colors.white54))),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ]),
      ),
    );
  }
}
