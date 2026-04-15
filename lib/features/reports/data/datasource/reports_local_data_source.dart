import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/reports/data/models/reports_model.dart'; // تأكد أن الموديل يرث من Entity
import 'package:drift/drift.dart';

abstract class ReportsLocalDataSource {
  Future<ReportSummaryModel> getSummaryReport(DateTime startDate, DateTime endDate);
  Future<List<ItemSalesModel>> getItemSalesReport(DateTime startDate, DateTime endDate);
}

class ReportsLocalDataSourceImpl implements ReportsLocalDataSource {
  final AppDatabase appDatabase;

  ReportsLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<ReportSummaryModel> getSummaryReport(DateTime startDate, DateTime endDate) async {
    // استخدمنا UTC لأننا وحدنا التوقيت في الخطوة 1.1 لضمان عدم تداخل الورديات
    final startStr = startDate.toUtc().toIso8601String();
    final endStr = endDate.toUtc().toIso8601String();

    // 1. استعلام المبيعات (الصافي والنقدي)
    final netSalesSum = appDatabase.orders.netSales.sum(); // إيراد المطعم
    final totalSum = appDatabase.orders.total.sum();       // درج الكاشير
    final countExp = appDatabase.orders.id.count();

    final salesQuery = appDatabase.selectOnly(appDatabase.orders)
      ..addColumns([netSalesSum, totalSum, countExp])
      ..where(appDatabase.orders.createdAt.isBetweenValues(startStr, endStr));

    final salesResult = await salesQuery.getSingle();
    final netSalesCents = salesResult.read(netSalesSum) ?? 0;
    final totalCollectedCents = salesResult.read(totalSum) ?? 0;
    final ordersCount = salesResult.read(countExp) ?? 0;

    // 2. استعلام المصروفات التشغيلية
    final expSum = appDatabase.expenses.amount.sum();
    final expQuery = appDatabase.selectOnly(appDatabase.expenses)
      ..addColumns([expSum])
      ..where(appDatabase.expenses.createdAt.isBetweenValues(startStr, endStr));

    final expResult = await expQuery.getSingle();
    final totalExpensesCents = expResult.read(expSum) ?? 0;

    // 3. استعلام تكلفة البضاعة المباعة (COGS) من جدول العناصر المرتبطة بطلبات هذه الفترة
    final cogsSum = (appDatabase.orderItems.quantity * appDatabase.orderItems.unitCost).sum();
    final cogsQuery = appDatabase.selectOnly(appDatabase.orderItems)
      ..addColumns([cogsSum])
      ..join([
        innerJoin(appDatabase.orders, appDatabase.orders.id.equalsExp(appDatabase.orderItems.orderId)),
      ])
      ..where(appDatabase.orders.createdAt.isBetweenValues(startStr, endStr));
      
    final cogsResult = await cogsQuery.getSingle();
    final totalCogsCents = cogsResult.read(cogsSum) ?? 0;

    return ReportSummaryModel(
      netSales: netSalesCents,
      totalCollected: totalCollectedCents,
      totalExpenses: totalExpensesCents,
      totalCogs: totalCogsCents,
      ordersCount: ordersCount,
    );
  }

  @override
  Future<List<ItemSalesModel>> getItemSalesReport(DateTime startDate, DateTime endDate) async {
    final qtySum = appDatabase.orderItems.quantity.sum();
    final revSum = (appDatabase.orderItems.quantity * appDatabase.orderItems.unitPrice).sum();
    
    final startStr = startDate.toUtc().toIso8601String();
    final endStr = endDate.toUtc().toIso8601String();

    final query = appDatabase.selectOnly(appDatabase.orderItems)
      ..addColumns([appDatabase.items.name, qtySum, revSum])
      ..join([
        innerJoin(appDatabase.orders, appDatabase.orders.id.equalsExp(appDatabase.orderItems.orderId)),
        innerJoin(appDatabase.items, appDatabase.items.id.equalsExp(appDatabase.orderItems.itemId)),
      ])
      ..where(appDatabase.orders.createdAt.isBetweenValues(startStr, endStr))
      ..groupBy([appDatabase.items.id])
      ..orderBy([OrderingTerm(expression: qtySum, mode: OrderingMode.desc)]);

    final results = await query.get();

    return results.map((row) {
      return ItemSalesModel(
        itemName: row.read(appDatabase.items.name) ?? 'غير معروف',
        quantitySold: row.read(qtySum) ?? 0,
        totalRevenue: row.read(revSum) ?? 0, // نمررها كقروش ونستخدم MoneyFormatterExtension في الواجهة
      );
    }).toList();
  }
}