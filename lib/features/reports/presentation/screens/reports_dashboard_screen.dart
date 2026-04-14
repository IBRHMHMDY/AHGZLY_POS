import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// 🪄 [Refactored]: استيراد دوال الـ Utils الخاصة بك لتطبيق مبدأ DRY
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/core/utils/date_time_utils.dart';

import 'package:ahgzly_pos/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:ahgzly_pos/features/reports/presentation/bloc/reports_event.dart';
import 'package:ahgzly_pos/features/reports/presentation/bloc/reports_state.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  String _selectedFilter = 'today';

  @override
  void initState() {
    super.initState();
    _loadDataForFilter(_selectedFilter);
  }

  void _loadDataForFilter(String filter) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (filter) {
      case 'today':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }

    context.read<ReportsBloc>().add(
      LoadReportsEvent(startDate: start, endDate: end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'التقارير والإحصائيات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث التقارير',
            onPressed: () {
              context.read<ReportsBloc>().add(RefreshReportsEvent());
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  icon: const Icon(Icons.filter_alt, color: Colors.indigo),
                  items: const [
                    DropdownMenuItem(
                      value: 'today',
                      child: Text(
                        'مبيعات اليوم',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'week',
                      child: Text(
                        'هذا الأسبوع',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'month',
                      child: Text(
                        'هذا الشهر',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'year',
                      child: Text(
                        'هذا العام',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFilter = value);
                      _loadDataForFilter(value);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          } else if (state is ReportsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          } else if (state is ReportsLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🪄 [Refactored]: استخدام date_time_utils لعرض فترة التقرير بدقة
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'عرض البيانات من ${state.startDate.toDisplayDate()} إلى ${state.endDate.toDisplayDate()}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.5,
                              children: [
                                _StatCard(
                                  title: 'إجمالي المبيعات',
                                  value: state.summary.totalSales
                                      .toCents()
                                      .toFormattedMoney(currency: 'ج.م'),
                                  icon: Icons.attach_money,
                                  color: Colors.blue,
                                ),

                                // 🪄 [Refactored]: إضافة بطاقة تكلفة البضاعة المباعة (COGS)
                                _StatCard(
                                  title: 'تكلفة البضاعة',
                                  value: state.summary.totalCogs
                                      .toCents()
                                      .toFormattedMoney(currency: 'ج.م'),
                                  icon: Icons.inventory_2_outlined,
                                  color: Colors.teal,
                                ),

                                _StatCard(
                                  title: 'المصروفات',
                                  value: state.summary.totalExpenses
                                      .toCents()
                                      .toFormattedMoney(currency: 'ج.م'),
                                  icon: Icons.money_off,
                                  color: Colors.orange,
                                ),
                                _StatCard(
                                  title: 'صافي الربح',
                                  value: state.summary.netProfit
                                      .toCents()
                                      .toFormattedMoney(currency: 'ج.م'),
                                  icon: Icons.account_balance_wallet,
                                  color: state.summary.netProfit >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                _StatCard(
                                  title: 'عدد الطلبات',
                                  value: '${state.summary.ordersCount} طلب',
                                  icon: Icons.receipt_long,
                                  color: Colors.purple,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: 16,
                            bottom: 16,
                            left: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'الأصناف الأكثر مبيعاً',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: state.itemSales.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'لا توجد مبيعات في هذه الفترة',
                                        ),
                                      )
                                    : ListView.separated(
                                        itemCount: state.itemSales.length,
                                        separatorBuilder: (c, i) =>
                                            const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final item = state.itemSales[index];
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  Colors.indigo.shade50,
                                              child: Text('${index + 1}'),
                                            ),
                                            title: Text(
                                              item.itemName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              'الكمية: ${item.quantitySold}',
                                            ),
                                            // 🪄 [Refactored]: استخدام MoneyFormatterExtension
                                            trailing: Text(
                                              item.totalRevenue
                                                  .toCents()
                                                  .toFormattedMoney(
                                                    currency: 'ج.م',
                                                  ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
