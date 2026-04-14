import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/reports/data/models/reports_model.dart';
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
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    // 1. استعلام المبيعات والطلبات
    final salesSum = appDatabase.orders.total.sum();
    final countExp = appDatabase.orders.id.count();
    final salesQuery = appDatabase.selectOnly(appDatabase.orders)
      ..addColumns([salesSum, countExp])
      ..where(appDatabase.orders.createdAt.isBetweenValues(startStr, endStr));

    final salesResult = await salesQuery.getSingle();
    final totalSalesCents = salesResult.read(salesSum) ?? 0;
    final ordersCount = salesResult.read(countExp) ?? 0;

    // 2. استعلام المصروفات التشغيلية
    final expSum = appDatabase.expenses.amount.sum();
    final expQuery = appDatabase.selectOnly(appDatabase.expenses)
      ..addColumns([expSum])
      ..where(appDatabase.expenses.createdAt.isBetweenValues(startStr, endStr));

    final expResult = await expQuery.getSingle();
    final totalExpensesCents = expResult.read(expSum) ?? 0;

    // 3. 🪄 [Refactored]: استعلام تكلفة البضاعة المباعة (COGS)
    // ضرب الكمية في تكلفة الوحدة لكل عنصر تم بيعه خلال هذه الفترة
    final cogsSum = (appDatabase.orderItems.quantity * appDatabase.orderItems.unitCost).sum();
    final cogsQuery = appDatabase.selectOnly(appDatabase.orderItems)
      ..addColumns([cogsSum])
      ..join([
        // الربط مع جدول الطلبات لفلترة التاريخ
        innerJoin(appDatabase.orders, appDatabase.orders.id.equalsExp(appDatabase.orderItems.orderId)),
      ])
      ..where(appDatabase.orders.createdAt.isBetweenValues(startStr, endStr));
      
    final cogsResult = await cogsQuery.getSingle();
    final totalCogsCents = cogsResult.read(cogsSum) ?? 0;

    return ReportSummaryModel(
      totalSales: totalSalesCents / 100.0, 
      totalExpenses: totalExpensesCents / 100.0,
      totalCogs: totalCogsCents / 100.0, // 🪄 [Refactored]: إضافة التكلفة للنموذج
      ordersCount: ordersCount,
    );
  }

  @override
  Future<List<ItemSalesModel>> getItemSalesReport(DateTime startDate, DateTime endDate) async {
    final qtySum = appDatabase.orderItems.quantity.sum();
    final revSum = (appDatabase.orderItems.quantity * appDatabase.orderItems.unitPrice).sum();
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

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
        totalRevenue: (row.read(revSum) ?? 0) / 100.0, 
      );
    }).toList();
  }
}