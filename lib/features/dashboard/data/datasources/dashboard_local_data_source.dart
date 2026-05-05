import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import '../models/dashboard_model.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardModel> getDashboardData();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final AppDatabase db;

  DashboardLocalDataSourceImpl({required this.db});

  @override
  Future<DashboardModel> getDashboardData() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));
      final weekStart = todayStart.subtract(const Duration(days: 6));

      final todayStartStr = todayStart.toIso8601String();
      final yesterdayStartStr = yesterdayStart.toIso8601String();
      final weekStartStr = weekStart.toIso8601String();

      // ── 1. إجمالي مبيعات اليوم ──
      final todaySalesResult = await db.customSelect(
        "SELECT COALESCE(SUM(total), 0) as total, COUNT(*) as count FROM orders WHERE status = 'completed' AND created_at >= '$todayStartStr'",
        readsFrom: {db.orders},
      ).getSingle();
      final todaySales = todaySalesResult.data['total'] as int? ?? 0;
      final todayOrders = todaySalesResult.data['count'] as int? ?? 0;

      // ── 2. إجمالي مبيعات أمس ──
      final yesterdaySalesResult = await db.customSelect(
        "SELECT COALESCE(SUM(total), 0) as total FROM orders WHERE status = 'completed' AND created_at >= '$yesterdayStartStr' AND created_at < '$todayStartStr'",
        readsFrom: {db.orders},
      ).getSingle();
      final yesterdaySales = yesterdaySalesResult.data['total'] as int? ?? 0;

      // ── 3. إجمالي التكلفة اليوم (للأرباح الصافية) ──
      final todayCostResult = await db.customSelect(
        "SELECT COALESCE(SUM(total_cost), 0) as cost FROM orders WHERE status = 'completed' AND created_at >= '$todayStartStr'",
        readsFrom: {db.orders},
      ).getSingle();
      final todayCost = todayCostResult.data['cost'] as int? ?? 0;

      // ── 4. مبيعات آخر 7 أيام ──
      final weeklySalesResult = await db.customSelect(
        """
        SELECT strftime('%Y-%m-%d', created_at) as day, COALESCE(SUM(total), 0) as total
        FROM orders
        WHERE status = 'completed' AND created_at >= '$weekStartStr'
        GROUP BY day
        ORDER BY day ASC
        """,
        readsFrom: {db.orders},
      ).get();

      final Map<String, int> weeklySalesMap = {
        for (final row in weeklySalesResult)
          row.data['day'] as String: row.data['total'] as int? ?? 0,
      };

      // Fill all 7 days (even if 0 sales)
      final List<SalesChartPoint> weeklyChart = [];
      for (int i = 6; i >= 0; i--) {
        final day = todayStart.subtract(Duration(days: i));
        final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        weeklyChart.add(SalesChartPoint(date: day, totalSales: weeklySalesMap[key] ?? 0));
      }

      // ── 5. أكثر الأصناف مبيعاً اليوم ──
      final bestSellersResult = await db.customSelect(
        """
        SELECT i.name, SUM(oi.quantity) as qty, SUM(oi.quantity * oi.unit_price) as revenue
        FROM order_items oi
        JOIN orders o ON o.id = oi.order_id
        JOIN items i ON i.id = oi.item_id
        WHERE o.status = 'completed' AND o.created_at >= '$todayStartStr'
        GROUP BY oi.item_id
        ORDER BY qty DESC
        LIMIT 5
        """,
        readsFrom: {db.orders, db.orderItems, db.items},
      ).get();

      final bestSellers = bestSellersResult.map((row) => BestSellerItem(
        name: row.data['name'] as String,
        quantity: row.data['qty'] as int? ?? 0,
        revenue: row.data['revenue'] as int? ?? 0,
      )).toList();

      // ── 6. توزيع طرق الدفع اليوم ──
      final paymentBreakdownResult = await db.customSelect(
        """
        SELECT pm.name, COUNT(o.id) as count, SUM(o.total) as total
        FROM orders o
        LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
        WHERE o.status = 'completed' AND o.created_at >= '$todayStartStr'
        GROUP BY o.payment_method_id
        """,
        readsFrom: {db.orders, db.paymentMethods},
      ).get();

      final paymentBreakdown = paymentBreakdownResult.map((row) => PaymentBreakdown(
        methodName: row.data['name'] as String? ?? 'غير محدد',
        count: row.data['count'] as int? ?? 0,
        total: row.data['total'] as int? ?? 0,
      )).toList();

      // ── 7. تنبيهات المخزن ──
      final lowStockResult = await db.customSelect(
        "SELECT COUNT(*) as count FROM inventory_items WHERE stock_quantity <= 5",
        readsFrom: {db.inventoryItems},
      ).getSingle();
      final lowStockCount = lowStockResult.data['count'] as int? ?? 0;

      return DashboardModel(
        todaySales: todaySales,
        yesterdaySales: yesterdaySales,
        todayOrders: todayOrders,
        todayNetProfit: todaySales - todayCost,
        weeklyChart: weeklyChart,
        bestSellers: bestSellers,
        paymentBreakdown: paymentBreakdown,
        lowStockCount: lowStockCount,
      );
    } catch (e) {
      throw CacheException('فشل في جلب بيانات لوحة التحكم: $e');
    }
  }
}
