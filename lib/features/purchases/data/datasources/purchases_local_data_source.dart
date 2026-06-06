import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:drift/drift.dart';
import '../models/purchase_invoice_model.dart';
import '../models/purchase_invoice_item_model.dart';

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

  // 🛠️ دالة المساعدة الداخلية
  Future<void> _recalculateCostsForInventoryItem(int inventoryItemId) async {
    final recipes = await appDatabase.inventoryDao.getRecipesByInventoryItemId(inventoryItemId);
    final itemIds = <int>{};
    final variantIds = <int>{};
    final addonIds = <int>{};

    for (var recipe in recipes) {
      if (recipe.itemId != null) itemIds.add(recipe.itemId!);
      if (recipe.variantId != null) variantIds.add(recipe.variantId!);
      if (recipe.addonId != null) addonIds.add(recipe.addonId!);
    }

    for (var id in itemIds) {
      final newCost = await appDatabase.inventoryDao.calculateTotalCostForTarget(itemId: id);
      await appDatabase.inventoryDao.updateItemCost(id, newCost);
    }
    for (var id in variantIds) {
      final newCost = await appDatabase.inventoryDao.calculateTotalCostForTarget(variantId: id);
      await appDatabase.inventoryDao.updateVariantCost(id, newCost);
    }
    for (var id in addonIds) {
      final newCost = await appDatabase.inventoryDao.calculateTotalCostForTarget(addonId: id);
      await appDatabase.inventoryDao.updateAddonCost(id, newCost);
    }
  }

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

          final inventoryItem = await (appDatabase.select(appDatabase.inventoryItems)
            ..where((t) => t.id.equals(item.inventoryItemId))).getSingle();
            
          final newStock = inventoryItem.stockQuantity + item.quantity;
          
          await (appDatabase.update(appDatabase.inventoryItems)
            ..where((t) => t.id.equals(item.inventoryItemId)))
            .write(InventoryItemsCompanion(
              stockQuantity: Value(newStock),
              costPerUnit: Value(item.unitCost), 
            ));

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

        // 🚀 الـ Costing الجديد لتحديث تكلفة المنيو بناءً على المشتريات
        for (var item in items) {
          await _recalculateCostsForInventoryItem(item.inventoryItemId);
        }

        return PurchaseInvoiceModel.fromDrift(invoiceData);
      });
    } catch (e) {
      throw CacheException('فشل في حفظ فاتورة المشتريات: $e');
    }
  }
}