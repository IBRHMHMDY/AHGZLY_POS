import 'package:equatable/equatable.dart';
import 'item_variant_entity.dart';
import 'addon_entity.dart';

class ItemEntity extends Equatable {
  final int? id;
  final int categoryId;
  final String name;
  final int price; 
  final int costPrice; 
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // [NEW] الإضافات والمقاسات
  final List<ItemVariantEntity> variants;
  final List<AddonEntity> availableAddons;

  const ItemEntity({
    this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.costPrice, 
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
    this.variants = const [],
    this.availableAddons = const [],
  });

  @override
  List<Object?> get props => [id, categoryId, name, price, costPrice, imagePath, createdAt, updatedAt, variants, availableAddons];
}