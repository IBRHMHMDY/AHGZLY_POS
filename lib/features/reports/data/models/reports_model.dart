import 'package:ahgzly_pos/features/reports/domain/entities/item_sales_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/report_summary_entity.dart';

// ==========================================
// 📊 Report Summary Model
// ==========================================
class ReportSummaryModel extends ReportSummaryEntity {
  const ReportSummaryModel({
    required super.netSales,
    required super.totalCollected,
    required super.totalExpenses,
    required super.totalCogs,
    required super.ordersCount,
  });

  // 🪄 [Refactored]: دوال التحويل جاهزة في حال المزامنة السحابية (Cloud Sync)
  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      netSales: json['netSales'] as int? ?? 0,
      totalCollected: json['totalCollected'] as int? ?? 0,
      totalExpenses: json['totalExpenses'] as int? ?? 0,
      totalCogs: json['totalCogs'] as int? ?? 0,
      ordersCount: json['ordersCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'netSales': netSales,
      'totalCollected': totalCollected,
      'totalExpenses': totalExpenses,
      'totalCogs': totalCogs,
      'netProfit': netProfit, // موروثة ومحسوبة تلقائياً بدقة من Entity
      'ordersCount': ordersCount,
    };
  }
}

// ==========================================
// 📦 Item Sales Model
// ==========================================
class ItemSalesModel extends ItemSalesEntity {
  const ItemSalesModel({
    required super.itemName,
    required super.quantitySold,
    required super.totalRevenue,
  });

  factory ItemSalesModel.fromJson(Map<String, dynamic> json) {
    return ItemSalesModel(
      itemName: json['itemName'] as String? ?? 'غير معروف',
      quantitySold: json['quantitySold'] as int? ?? 0,
      totalRevenue: json['totalRevenue'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'quantitySold': quantitySold,
      'totalRevenue': totalRevenue,
    };
  }
}