import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final int? id;
  final int categoryId;
  final String name;
  final double price;
  final String? imagePath;
  final String createdAt;
  final String updatedAt;

  const Item({
    this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, categoryId, name, price, imagePath, createdAt, updatedAt];
}