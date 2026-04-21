import 'package:equatable/equatable.dart';

class ItemEntity extends Equatable {
  final int? id;
  final int categoryId;
  final String name;
  final int price; 
  final int costPrice; // [NEW] سعر التكلفة بالقروش
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItemEntity({
    this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.costPrice, // [NEW]
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, categoryId, name, price, costPrice, imagePath, createdAt, updatedAt];
}