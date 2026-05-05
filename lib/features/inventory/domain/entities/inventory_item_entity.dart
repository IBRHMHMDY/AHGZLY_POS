import 'package:equatable/equatable.dart';

class InventoryItemEntity extends Equatable {
  final int id;
  final String name;
  final String unit;
  final double stockQuantity;
  final int costPerUnit;

  const InventoryItemEntity({
    required this.id,
    required this.name,
    required this.unit,
    required this.stockQuantity,
    required this.costPerUnit,
  });

  @override
  List<Object?> get props => [id, name, unit, stockQuantity, costPerUnit];
}
