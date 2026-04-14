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
    final salesSum = appDatabase.orders.total.sum();
    final countExp = appDatabase.orders.id.count();

    // 🪄 [الإصلاح]: تحويل التاريخ إلى نص قياسي ISO8601 ليتمكن SQLite من مقارنته كنص
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    final salesQuery = appDatabase.selectOnly(appDatabase.orders)
      ..addColumns([salesSum, countExp])
      ..where(appDatabase.orders.createdAt.isBetweenValues(startStr, endStr));

    final salesResult = await salesQuery.getSingle();
    final totalSalesCents = salesResult.read(salesSum) ?? 0;
    final ordersCount = salesResult.read(countExp) ?? 0;

    final expSum = appDatabase.expenses.amount.sum();
    final expQuery = appDatabase.selectOnly(appDatabase.expenses)
      ..addColumns([expSum])
      ..where(appDatabase.expenses.createdAt.isBetweenValues(startStr, endStr));

    final expResult = await expQuery.getSingle();
    final totalExpensesCents = expResult.read(expSum) ?? 0;

    return ReportSummaryModel(
      totalSales: totalSalesCents / 100.0, 
      totalExpenses: totalExpensesCents / 100.0,
      ordersCount: ordersCount,
    );
  }

  @override
  Future<List<ItemSalesModel>> getItemSalesReport(DateTime startDate, DateTime endDate) async {
    final qtySum = appDatabase.orderItems.quantity.sum();
    final revSum = (appDatabase.orderItems.quantity * appDatabase.orderItems.unitPrice).sum();

    // 🪄 [الإصلاح]: تحويل التاريخ إلى نص قياسي ISO8601
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