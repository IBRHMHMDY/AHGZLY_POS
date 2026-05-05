import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:ahgzly_pos/features/dashboard/data/models/dashboard_model.dart';
import 'package:ahgzly_pos/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ahgzly_pos/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ahgzly_pos/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1923),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('لوحة التحكم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
            Text(DateFormat('EEEE، d MMMM y', 'ar').format(DateTime.now()), style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_rounded, color: Colors.white70),
            onPressed: () => context.push(AppRoutes.customers),
            tooltip: 'إدارة العملاء',
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: Colors.white70),
            onPressed: () => context.push(AppRoutes.reports),
            tooltip: 'التقارير التفصيلية',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => context.read<DashboardBloc>().add(LoadDashboardEvent()),
            tooltip: 'تحديث',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
          }
          if (state is DashboardError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent, fontSize: 18)));
          }
          if (state is DashboardLoaded) {
            final d = state.data;
            return RefreshIndicator(
              onRefresh: () async => context.read<DashboardBloc>().add(LoadDashboardEvent()),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Cards Row
                    _buildKpiCards(d),
                    const SizedBox(height: 24),

                    // Weekly Sales Chart
                    _buildSectionTitle('مبيعات آخر 7 أيام'),
                    const SizedBox(height: 12),
                    _buildWeeklyChart(d.weeklyChart),
                    const SizedBox(height: 24),

                    // Best Sellers + Payment Breakdown
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('🏆 أكثر الأصناف مبيعاً اليوم'),
                              const SizedBox(height: 12),
                              _buildBestSellers(d.bestSellers),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('💳 طرق الدفع اليوم'),
                              const SizedBox(height: 12),
                              _buildPaymentChart(d.paymentBreakdown),
                            ],
                          ),
                        ),
                      ],
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

  // ─────────────────────────────────────────
  // KPI Cards
  // ─────────────────────────────────────────

  Widget _buildKpiCards(DashboardModel d) {
    final salesDiff = d.todaySales - d.yesterdaySales;
    final salesChange = d.yesterdaySales > 0 ? (salesDiff / d.yesterdaySales * 100).toStringAsFixed(1) : '0';
    final isUp = salesDiff >= 0;
    final profitMargin = d.todaySales > 0 ? (d.todayNetProfit / d.todaySales * 100).toStringAsFixed(1) : '0';

    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _kpiCard(
          title: 'مبيعات اليوم',
          value: MoneyFormatter.format(d.todaySales),
          icon: Icons.trending_up_rounded,
          color: Colors.tealAccent,
          badge: '$salesChange%',
          badgeColor: isUp ? Colors.greenAccent : Colors.redAccent,
          badgeIcon: isUp ? Icons.arrow_upward : Icons.arrow_downward,
        ),
        _kpiCard(
          title: 'الطلبات اليوم',
          value: '${d.todayOrders} طلب',
          icon: Icons.receipt_long_rounded,
          color: Colors.blueAccent,
        ),
        _kpiCard(
          title: 'الربح الصافي',
          value: MoneyFormatter.format(d.todayNetProfit),
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.greenAccent,
          badge: '$profitMargin%',
          badgeColor: Colors.greenAccent.withOpacity(0.7),
        ),
        _kpiCard(
          title: 'تنبيهات المخزن',
          value: '${d.lowStockCount} خامة',
          icon: Icons.warning_amber_rounded,
          color: d.lowStockCount > 0 ? Colors.orangeAccent : Colors.grey,
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? badge,
    Color? badgeColor,
    IconData? badgeIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D3D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? Colors.grey).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeIcon != null) Icon(badgeIcon, color: badgeColor ?? Colors.grey, size: 12),
                      Text(badge, style: TextStyle(color: badgeColor ?? Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Weekly Chart
  // ─────────────────────────────────────────

  Widget _buildWeeklyChart(List<SalesChartPoint> points) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxY = (points.map((p) => p.totalSales).reduce((a, b) => a > b ? a : b) * 1.2).toDouble();
    final dayFormat = DateFormat('E', 'ar');

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D3D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 100 : maxY,
          gridData: FlGridData(show: true, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white10, strokeWidth: 1), drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final index = val.toInt();
                  if (index < 0 || index >= points.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(dayFormat.format(points[index].date), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          barGroups: points.asMap().entries.map((entry) {
            final isToday = entry.key == points.length - 1;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.totalSales.toDouble(),
                  color: isToday ? Colors.tealAccent : Colors.tealAccent.withOpacity(0.4),
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY <= 0 ? 100 : maxY, color: Colors.white.withOpacity(0.03)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Best Sellers
  // ─────────────────────────────────────────

  Widget _buildBestSellers(List<BestSellerItem> sellers) {
    if (sellers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: const Color(0xFF1E2D3D), borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('لا توجد مبيعات اليوم بعد', style: TextStyle(color: Colors.white38))),
      );
    }

    final maxQty = sellers.first.quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E2D3D), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: sellers.asMap().entries.map((entry) {
          final i = entry.key;
          final seller = entry.value;
          final percent = maxQty > 0 ? seller.quantity / maxQty : 0.0;
          final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text(medals[i], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(seller.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ]),
                    Text('${seller.quantity} وجبة', style: const TextStyle(color: Colors.tealAccent, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent.toDouble(),
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent.withOpacity(0.7)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Payment Pie Chart
  // ─────────────────────────────────────────

  Widget _buildPaymentChart(List<PaymentBreakdown> breakdown) {
    if (breakdown.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: const Color(0xFF1E2D3D), borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('لا توجد بيانات', style: TextStyle(color: Colors.white38))),
      );
    }

    final colors = [Colors.tealAccent, Colors.blueAccent, Colors.orangeAccent, Colors.purpleAccent, Colors.pinkAccent];
    final total = breakdown.fold<int>(0, (sum, p) => sum + p.total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E2D3D), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: breakdown.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final pct = total > 0 ? (p.total / total * 100) : 0.0;
                  return PieChartSectionData(
                    value: p.total.toDouble(),
                    color: colors[i % colors.length],
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    radius: 50,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...breakdown.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(p.methodName, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                  Text(MoneyFormatter.format(p.total), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }
}
