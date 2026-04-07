// مسار الملف: lib/features/menu/domain/entities/item.dart

import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final int? id;
  final int categoryId;
  final String name;
  final int price; // Refactored: تغيير من double إلى int (Cents)
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