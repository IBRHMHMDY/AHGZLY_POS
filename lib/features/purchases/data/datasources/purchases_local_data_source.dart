import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:drift/drift.dart';
import '../models/purchase_invoice_model.dart';
import '../models/purchase_invoice_item_model.dart';
import 'package:ahgzly_pos/core/database/costing_helper.dart';

abstract class PurchasesLocalDataSource {
  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices();
  Future<PurchaseInvoiceModel> savePurchaseInvoice({
    required int? supplierId,
    required int totalAmount,
    required int paidAmount,
    required String? notes,
    required List<PurchaseInvoiceItemModel> items,
  });
}

class PurchasesLocalDataSourceImpl implements PurchasesLocalDataSource {
  final AppDatabase appDatabase;

  PurchasesLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices() async {
    try {
      final query = appDatabase.select(appDatabase.purchaseInvoices)
        ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]);
      final invoices = await query.get();
      return invoices.map((i) => PurchaseInvoiceModel.fromDrift(i)).toList();
    } catch (e) {
      throw CacheException('فشل في جلب فواتير المشتريات: $e');
    }
  }

  @override
  Future<PurchaseInvoiceModel> savePurchaseInvoice({
    required int? supplierId,
    required int totalAmount,
    required int paidAmount,
    required String? notes,
    required List<PurchaseInvoiceItemModel> items,
  }) async {
    try {
      return await appDatabase.transaction(() async {
        final now = DateTime.now();
        
        // 1. إنشاء الفاتورة
        final invoiceId = await appDatabase.into(appDatabase.purchaseInvoices).insert(
          PurchaseInvoicesCompanion.insert(
            supplierId: Value(supplierId),
            totalAmount: totalAmount,
            paidAmount: Value(paidAmount),
            invoiceDate: now,
            notes: Value(notes),
            createdAt: now,
          ),
        );

        // 2. تسجيل العناصر وحركات المخزون
        for (var item in items) {
          await appDatabase.into(appDatabase.purchaseInvoiceItems).insert(
            PurchaseInvoiceItemsCompanion.insert(
              invoiceId: invoiceId,
              inventoryItemId: item.inventoryItemId,
              quantity: item.quantity,
              unitCost: item.unitCost,
              totalCost: item.totalCost,
            ),
          );

          // 3. زيادة كمية المخزون في الخامات
          final inventoryItem = await (appDatabase.select(appDatabase.inventoryItems)
            ..where((t) => t.id.equals(item.inventoryItemId))).getSingle();
            
          final newStock = inventoryItem.stockQuantity + item.quantity;
          
          // 4. تحديث سعر التكلفة للوحدة (متوسط مرجح أو سعر آخر شراء)
          // هنا سنستخدم سعر آخر شراء لتسهيل الحسابات (أو يمكن عمل Weighted Average)
          await (appDatabase.update(appDatabase.inventoryItems)
            ..where((t) => t.id.equals(item.inventoryItemId)))
            .write(InventoryItemsCompanion(
              stockQuantity: Value(newStock),
              costPerUnit: Value(item.unitCost), // 🚀 [Costing]: تحديث سعر الخامة لتحديث أسعار المنيو تلقائياً
            ));

          // 5. تسجيل حركة مخزنية (Transaction)
          await appDatabase.into(appDatabase.inventoryTransactions).insert(
            InventoryTransactionsCompanion.insert(
              inventoryItemId: item.inventoryItemId,
              transactionType: 'in',
              quantity: item.quantity,
              referenceId: Value(invoiceId),
              notes: const Value('فاتورة مشتريات'),
              createdAt: now,
            ),
          );
        }

        final invoiceData = await (appDatabase.select(appDatabase.purchaseInvoices)
          ..where((t) => t.id.equals(invoiceId))).getSingle();

        // 6. [Costing] Recalculate cost prices for affected menu items
        final costingHelper = CostingHelper(appDatabase);
        for (var item in items) {
          await costingHelper.recalculateCostsForInventoryItem(item.inventoryItemId);
        }

        return PurchaseInvoiceModel.fromDrift(invoiceData);
      });
    } catch (e) {
      throw CacheException('فشل في حفظ فاتورة المشتريات: $e');
    }
  }
}
