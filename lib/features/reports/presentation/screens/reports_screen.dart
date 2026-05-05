import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/features/reports/data/models/sales_report_model.dart';
import 'package:ahgzly_pos/features/reports/data/models/supplier_report_model.dart';
import 'package:ahgzly_pos/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:ahgzly_pos/features/reports/presentation/bloc/reports_event.dart';
import 'package:ahgzly_pos/features/reports/presentation/bloc/reports_state.dart';
import 'package:ahgzly_pos/features/suppliers/presentation/bloc/suppliers_bloc.dart';
import 'package:ahgzly_pos/features/suppliers/presentation/bloc/suppliers_event.dart';
import 'package:ahgzly_pos/features/suppliers/presentation/bloc/suppliers_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sales Report Filters
  DateTime _salesFrom = DateTime.now().subtract(const Duration(days: 6));
  DateTime _salesTo = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) _loadSalesReport();
      if (_tabController.index == 1) context.read<ReportsBloc>().add(LoadInventoryReportEvent());
      if (_tabController.index == 2) context.read<SuppliersBloc>().add(LoadSuppliersEvent());
    });
    _loadSalesReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSalesReport() {
    context.read<ReportsBloc>().add(LoadSalesReportEvent(from: _salesFrom, to: _salesTo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1923),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('التقارير التفصيلية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.tealAccent,
          labelColor: Colors.tealAccent,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'المبيعات'),
            Tab(icon: Icon(Icons.inventory_2), text: 'المخزن'),
            Tab(icon: Icon(Icons.local_shipping), text: 'الموردين'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SalesReportTab(
            from: _salesFrom,
            to: _salesTo,
            onDateRangeChanged: (from, to) {
              setState(() { _salesFrom = from; _salesTo = to; });
              _loadSalesReport();
            },
          ),
          const _InventoryReportTab(),
          const _SupplierReportTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 📊 TAB 1: Sales Report
// ─────────────────────────────────────────────────────────

class _SalesReportTab extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final Function(DateTime, DateTime) onDateRangeChanged;

  const _SalesReportTab({required this.from, required this.to, required this.onDateRangeChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        return Column(
          children: [
            _DateRangePicker(from: from, to: to, onChanged: onDateRangeChanged),
            Expanded(
              child: state is ReportsLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
                  : state is ReportsError
                      ? Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent)))
                      : state is SalesReportLoaded
                          ? _SalesReportContent(report: state.report)
                          : const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }
}

class _DateRangePicker extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final Function(DateTime, DateTime) onChanged;

  const _DateRangePicker({required this.from, required this.to, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd');
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1E2D3D),
      child: Row(
        children: [
          const Icon(Icons.date_range, color: Colors.white54, size: 20),
          const SizedBox(width: 8),
          Text('من: ${fmt.format(from)}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 12),
          Text('إلى: ${fmt.format(to)}', style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          _quickButton(context, 'اليوم', () => onChanged(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day), DateTime.now())),
          const SizedBox(width: 8),
          _quickButton(context, '7 أيام', () => onChanged(DateTime.now().subtract(const Duration(days: 6)), DateTime.now())),
          const SizedBox(width: 8),
          _quickButton(context, '30 يوم', () => onChanged(DateTime.now().subtract(const Duration(days: 29)), DateTime.now())),
        ],
      ),
    );
  }

  Widget _quickButton(BuildContext context, String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: Colors.tealAccent.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      child: Text(label, style: const TextStyle(color: Colors.tealAccent, fontSize: 12)),
    );
  }
}

class _SalesReportContent extends StatelessWidget {
  final SalesReportModel report;

  const _SalesReportContent({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
            children: [
              _reportCard('الإجمالي', MoneyFormatter.format(report.totalSales), Colors.tealAccent, Icons.attach_money),
              _reportCard('الربح الصافي', MoneyFormatter.format(report.totalNetProfit), Colors.greenAccent, Icons.trending_up),
              _reportCard('عدد الطلبات', '${report.totalOrders}', Colors.blueAccent, Icons.receipt_long),
              _reportCard('متوسط الطلب', MoneyFormatter.format(report.avgOrderValue.round()), Colors.orangeAccent, Icons.analytics),
            ],
          ),
          const SizedBox(height: 24),

          // Daily Breakdown Table
          if (report.dailyBreakdown.isNotEmpty) ...[
            _sectionTitle('المبيعات اليومية'),
            const SizedBox(height: 12),
            _DailyTable(rows: report.dailyBreakdown),
            const SizedBox(height: 24),
          ],

          // Best Sellers
          if (report.bestSellers.isNotEmpty) ...[
            _sectionTitle('🏆 أكثر الأصناف مبيعاً'),
            const SizedBox(height: 12),
            _BestSellersTable(sellers: report.bestSellers),
          ],
        ],
      ),
    );
  }

  Widget _reportCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E2D3D), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
}

class _DailyTable extends StatelessWidget {
  final List<DailySalesPoint> rows;
  const _DailyTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E2D3D), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _tableHeader(),
          ...rows.map((r) => _tableRow(r.day, r.orders.toString(), MoneyFormatter.format(r.total))),
        ],
      ),
    );
  }

  Widget _tableHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
    child: const Row(children: [
      Expanded(child: Text('اليوم', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold))),
      Expanded(child: Text('الطلبات', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
      Expanded(child: Text('الإجمالي', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
    ]),
  );

  Widget _tableRow(String day, String orders, String total) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Expanded(child: Text(day, style: const TextStyle(color: Colors.white70))),
      Expanded(child: Text(orders, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)),
      Expanded(child: Text(total, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
    ]),
  );
}

class _BestSellersTable extends StatelessWidget {
  final List<SalesBestSeller> sellers;
  const _BestSellersTable({required this.sellers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E2D3D), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _header(),
          ...sellers.asMap().entries.map((e) => _row(e.key + 1, e.value)),
        ],
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
    child: const Row(children: [
      SizedBox(width: 30, child: Text('#', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold))),
      Expanded(child: Text('الصنف', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold))),
      Text('الكمية', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
      SizedBox(width: 16),
      Text('الإيراد', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _row(int rank, SalesBestSeller s) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      SizedBox(width: 30, child: Text('$rank', style: const TextStyle(color: Colors.white54))),
      Expanded(child: Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      Text('${s.quantity}', style: const TextStyle(color: Colors.orangeAccent)),
      const SizedBox(width: 16),
      Text(MoneyFormatter.format(s.revenue), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────
// 📦 TAB 2: Inventory Report
// ─────────────────────────────────────────────────────────

class _InventoryReportTab extends StatelessWidget {
  const _InventoryReportTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
        if (state is ReportsError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent)));
        if (state is InventoryReportLoaded) {
          final items = state.items;
          final totalValue = items.fold<int>(0, (s, i) => s + i.totalValue);
          final lowStock = items.where((i) => i.isLowStock).length;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF1E2D3D),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('إجمالي الخامات', '${items.length}', Colors.blueAccent),
                    _stat('تقييم المخزن', MoneyFormatter.format(totalValue), Colors.greenAccent),
                    _stat('تنبيهات النواقص', '$lowStock', Colors.orangeAccent),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2D3D),
                        borderRadius: BorderRadius.circular(10),
                        border: item.isLowStock ? Border.all(color: Colors.orangeAccent.withOpacity(0.5)) : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8, margin: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item.isOutOfStock ? Colors.redAccent : item.isLowStock ? Colors.orangeAccent : Colors.greenAccent,
                            ),
                          ),
                          Expanded(child: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          Text('${item.stockQuantity} ${item.unit}', style: TextStyle(color: item.isLowStock ? Colors.orangeAccent : Colors.white70)),
                          const SizedBox(width: 16),
                          Text('${MoneyFormatter.format(item.costPerUnit)}/${item.unit}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          const SizedBox(width: 16),
                          Text('قيمة: ${MoneyFormatter.format(item.totalValue)}', style: const TextStyle(color: Colors.tealAccent, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
      },
    );
  }

  Widget _stat(String label, String value, Color color) => Column(
    children: [
      Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ],
  );
}

// ─────────────────────────────────────────────────────────
// 🚚 TAB 3: Supplier Report
// ─────────────────────────────────────────────────────────

class _SupplierReportTab extends StatelessWidget {
  const _SupplierReportTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuppliersBloc, SuppliersState>(
      builder: (context, suppliersState) {
        if (suppliersState is! SuppliersLoaded) {
          return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
        }
        if (suppliersState.suppliers.isEmpty) {
          return const Center(child: Text('لا يوجد موردون مسجلون', style: TextStyle(color: Colors.white54, fontSize: 16)));
        }
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF1E2D3D),
              child: DropdownButtonFormField<int>(
                dropdownColor: const Color(0xFF1E2D3D),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'اختر مورداً لعرض كشف حسابه',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.tealAccent)),
                ),
                items: suppliersState.suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (id) {
                  if (id != null) context.read<ReportsBloc>().add(LoadSupplierReportEvent(id));
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<ReportsBloc, ReportsState>(
                builder: (context, reportsState) {
                  if (reportsState is ReportsLoading) return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
                  if (reportsState is ReportsError) return Center(child: Text(reportsState.message, style: const TextStyle(color: Colors.redAccent)));
                  if (reportsState is SupplierReportLoaded) return _SupplierReportContent(report: reportsState.report);
                  return Center(child: Text('اختر مورداً لعرض تقريره', style: TextStyle(color: Colors.white38)));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SupplierReportContent extends StatelessWidget {
  final SupplierReportModel report;
  const _SupplierReportContent({required this.report});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(children: [
            Expanded(child: _card('إجمالي الفواتير', MoneyFormatter.format(report.totalPurchases), Colors.blueAccent)),
            const SizedBox(width: 12),
            Expanded(child: _card('المدفوع', MoneyFormatter.format(report.totalPaid), Colors.greenAccent)),
            const SizedBox(width: 12),
            Expanded(child: _card('المتبقي', MoneyFormatter.format(report.totalRemaining), report.totalRemaining > 0 ? Colors.redAccent : Colors.white38)),
          ]),
          const SizedBox(height: 24),
          Text('الفواتير (${report.invoices.length})', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...report.invoices.map((inv) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF1E2D3D), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('فاتورة #${inv.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(fmt.format(inv.invoiceDate), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                if (inv.notes != null && inv.notes!.isNotEmpty) Text(inv.notes!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(MoneyFormatter.format(inv.totalAmount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('مدفوع: ${MoneyFormatter.format(inv.paidAmount)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
                if (inv.remaining > 0) Text('متبقي: ${MoneyFormatter.format(inv.remaining)}', style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
              ]),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _card(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF1E2D3D), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ]),
  );
}
