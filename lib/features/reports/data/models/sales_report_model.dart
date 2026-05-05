class DailySalesPoint {
  final String day;
  final int total;
  final int orders;
  DailySalesPoint({required this.day, required this.total, required this.orders});
}

class PaymentSummary {
  final String methodName;
  final int count;
  final int total;
  PaymentSummary({required this.methodName, required this.count, required this.total});
}

class SalesBestSeller {
  final String name;
  final int quantity;
  final int revenue;
  SalesBestSeller({required this.name, required this.quantity, required this.revenue});
}

class SalesReportModel {
  final DateTime from;
  final DateTime to;
  final int totalSales;
  final int totalCost;
  final int totalDiscount;
  final int totalOrders;
  final List<DailySalesPoint> dailyBreakdown;
  final List<PaymentSummary> paymentBreakdown;
  final List<SalesBestSeller> bestSellers;

  int get totalNetProfit => totalSales - totalCost;
  double get profitMargin => totalSales > 0 ? (totalNetProfit / totalSales * 100) : 0;
  double get avgOrderValue => totalOrders > 0 ? totalSales / totalOrders : 0;

  const SalesReportModel({
    required this.from,
    required this.to,
    required this.totalSales,
    required this.totalCost,
    required this.totalDiscount,
    required this.totalOrders,
    required this.dailyBreakdown,
    required this.paymentBreakdown,
    required this.bestSellers,
  });
}
