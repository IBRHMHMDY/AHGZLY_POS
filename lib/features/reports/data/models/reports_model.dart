import 'package:ahgzly_pos/features/reports/domain/entities/report_summary_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/item_sales_entity.dart';

class ReportSummaryModel extends ReportSummaryEntity {
  const ReportSummaryModel({
    required super.totalSales,
    required super.totalExpenses,
    required super.ordersCount,
  });
}

class ItemSalesModel extends ItemSalesEntity {
  const ItemSalesModel({
    required super.itemName,
    required super.quantitySold,
    required super.totalRevenue,
  });
}