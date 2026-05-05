class InventoryReportItemModel {
  final int id;
  final String name;
  final String unit;
  final double stockQuantity;
  final int costPerUnit;
  final int recipeCount;

  bool get isLowStock => stockQuantity <= 5;
  bool get isOutOfStock => stockQuantity <= 0;
  int get totalValue => (stockQuantity * costPerUnit).round();

  InventoryReportItemModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.stockQuantity,
    required this.costPerUnit,
    required this.recipeCount,
  });
}
