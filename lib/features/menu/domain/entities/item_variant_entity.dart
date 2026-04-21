import 'package:equatable/equatable.dart';

class ItemVariantEntity extends Equatable {
  final int? id;
  final int itemId;
  final String name;
  final int price;
  final int costPrice;

  const ItemVariantEntity({
    this.id,
    required this.itemId,
    required this.name,
    required this.price,
    required this.costPrice,
  });

  @override
  List<Object?> get props => [id, itemId, name, price, costPrice];
}