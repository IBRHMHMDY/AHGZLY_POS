class SalesChartPoint {
  final DateTime date;
  final int totalSales;

  SalesChartPoint({required this.date, required this.totalSales});
}

class BestSellerItem {
  final String name;
  final int quantity;
  final int revenue;

  BestSellerItem({required this.name, required this.quantity, required this.revenue});
}

class PaymentBreakdown {
  final String methodName;
  final int count;
  final int total;

  PaymentBreakdown({required this.methodName, required this.count, required this.total});
}

class DashboardModel {
  final int todaySales;
  final int yesterdaySales;
  final int todayOrders;
  final int todayNetProfit;
  final List<SalesChartPoint> weeklyChart;
  final List<BestSellerItem> bestSellers;
  final List<PaymentBreakdown> paymentBreakdown;
  final int lowStockCount;

  const DashboardModel({
    required this.todaySales,
    required this.yesterdaySales,
    required this.todayOrders,
    required this.todayNetProfit,
    required this.weeklyChart,
    required this.bestSellers,
    required this.paymentBreakdown,
    required this.lowStockCount,
  });
}
