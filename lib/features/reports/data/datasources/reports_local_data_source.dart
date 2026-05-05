import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import '../models/sales_report_model.dart';
import '../models/inventory_report_model.dart';
import '../models/supplier_report_model.dart';

abstract class ReportsLocalDataSource {
  Future<SalesReportModel> getSalesReport({required DateTime from, required DateTime to});
  Future<List<InventoryReportItemModel>> getInventoryReport();
  Future<SupplierReportModel> getSupplierReport(int supplierId);
}

class ReportsLocalDataSourceImpl implements ReportsLocalDataSource {
  final AppDatabase db;

  ReportsLocalDataSourceImpl({required this.db});

  @override
  Future<SalesReportModel> getSalesReport({required DateTime from, required DateTime to}) async {
    try {
      final fromStr = from.toIso8601String();
      final toStr = to.add(const Duration(days: 1)).toIso8601String(); // inclusive end

      // Total Sales & Orders
      final summaryResult = await db.customSelect(
        """
        SELECT 
          COALESCE(SUM(total), 0) as total_sales,
          COALESCE(SUM(total_cost), 0) as total_cost,
          COALESCE(SUM(discount), 0) as total_discount,
          COUNT(*) as total_orders
        FROM orders 
        WHERE status = 'completed' AND created_at >= '$fromStr' AND created_at < '$toStr'
        """,
        readsFrom: {db.orders},
      ).getSingle();

      // Daily breakdown
      final dailyResult = await db.customSelect(
        """
        SELECT strftime('%Y-%m-%d', created_at) as day, 
               COALESCE(SUM(total), 0) as total,
               COUNT(*) as count
        FROM orders 
        WHERE status = 'completed' AND created_at >= '$fromStr' AND created_at < '$toStr'
        GROUP BY day ORDER BY day ASC
        """,
        readsFrom: {db.orders},
      ).get();

      // Payment method breakdown
      final paymentResult = await db.customSelect(
        """
        SELECT pm.name, COUNT(o.id) as count, COALESCE(SUM(o.total), 0) as total
        FROM orders o
        LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
        WHERE o.status = 'completed' AND o.created_at >= '$fromStr' AND o.created_at < '$toStr'
        GROUP BY o.payment_method_id
        """,
        readsFrom: {db.orders, db.paymentMethods},
      ).get();

      // Top 10 best sellers
      final bestSellersResult = await db.customSelect(
        """
        SELECT i.name, SUM(oi.quantity) as qty, SUM(oi.quantity * oi.unit_price) as revenue
        FROM order_items oi
        JOIN orders o ON o.id = oi.order_id
        JOIN items i ON i.id = oi.item_id
        WHERE o.status = 'completed' AND o.created_at >= '$fromStr' AND o.created_at < '$toStr'
        GROUP BY oi.item_id
        ORDER BY qty DESC
        LIMIT 10
        """,
        readsFrom: {db.orderItems, db.orders, db.items},
      ).get();

      return SalesReportModel(
        from: from,
        to: to,
        totalSales: summaryResult.data['total_sales'] as int? ?? 0,
        totalCost: summaryResult.data['total_cost'] as int? ?? 0,
        totalDiscount: summaryResult.data['total_discount'] as int? ?? 0,
        totalOrders: summaryResult.data['total_orders'] as int? ?? 0,
        dailyBreakdown: dailyResult.map((r) => DailySalesPoint(
          day: r.data['day'] as String,
          total: r.data['total'] as int? ?? 0,
          orders: r.data['count'] as int? ?? 0,
        )).toList(),
        paymentBreakdown: paymentResult.map((r) => PaymentSummary(
          methodName: r.data['name'] as String? ?? 'غير محدد',
          count: r.data['count'] as int? ?? 0,
          total: r.data['total'] as int? ?? 0,
        )).toList(),
        bestSellers: bestSellersResult.map((r) => SalesBestSeller(
          name: r.data['name'] as String,
          quantity: r.data['qty'] as int? ?? 0,
          revenue: r.data['revenue'] as int? ?? 0,
        )).toList(),
      );
    } catch (e) {
      throw CacheException('فشل في جلب تقرير المبيعات: $e');
    }
  }

  @override
  Future<List<InventoryReportItemModel>> getInventoryReport() async {
    try {
      final result = await db.customSelect(
        """
        SELECT ii.id, ii.name, ii.unit, ii.stock_quantity, ii.cost_per_unit,
               (SELECT COUNT(*) FROM recipes r WHERE r.inventory_item_id = ii.id) as recipe_count
        FROM inventory_items ii
        ORDER BY ii.stock_quantity ASC
        """,
        readsFrom: {db.inventoryItems, db.recipes},
      ).get();

      return result.map((r) => InventoryReportItemModel(
        id: r.data['id'] as int,
        name: r.data['name'] as String,
        unit: r.data['unit'] as String,
        stockQuantity: (r.data['stock_quantity'] as num).toDouble(),
        costPerUnit: r.data['cost_per_unit'] as int? ?? 0,
        recipeCount: r.data['recipe_count'] as int? ?? 0,
      )).toList();
    } catch (e) {
      throw CacheException('فشل في جلب تقرير المخزن: $e');
    }
  }

  @override
  Future<SupplierReportModel> getSupplierReport(int supplierId) async {
    try {
      final supplierResult = await (db.select(db.suppliers)..where((t) => t.id.equals(supplierId))).getSingle();

      final invoicesResult = await db.customSelect(
        """
        SELECT pi.id, pi.total_amount, pi.paid_amount, pi.invoice_date, pi.notes
        FROM purchase_invoices pi
        WHERE pi.supplier_id = $supplierId
        ORDER BY pi.invoice_date DESC
        """,
        readsFrom: {db.purchaseInvoices},
      ).get();

      final totalPurchases = invoicesResult.fold<int>(0, (s, r) => s + (r.data['total_amount'] as int? ?? 0));
      final totalPaid = invoicesResult.fold<int>(0, (s, r) => s + (r.data['paid_amount'] as int? ?? 0));

      return SupplierReportModel(
        supplierId: supplierId,
        supplierName: supplierResult.name,
        supplierPhone: supplierResult.phone,
        totalPurchases: totalPurchases,
        totalPaid: totalPaid,
        invoices: invoicesResult.map((r) => SupplierInvoiceSummary(
          id: r.data['id'] as int,
          totalAmount: r.data['total_amount'] as int? ?? 0,
          paidAmount: r.data['paid_amount'] as int? ?? 0,
          invoiceDate: DateTime.parse(r.data['invoice_date'] as String),
          notes: r.data['notes'] as String?,
        )).toList(),
      );
    } catch (e) {
      throw CacheException('فشل في جلب تقرير المورد: $e');
    }
  }
}
