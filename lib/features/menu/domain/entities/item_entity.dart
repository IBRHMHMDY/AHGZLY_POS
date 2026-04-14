// مسار الملف: lib/features/menu/domain/entities/item_entity.dart

import 'package:equatable/equatable.dart';

class ItemEntity extends Equatable {
  final int? id;
  final int categoryId;
  final String name;
  final int price; 
  final int cost; // [Refactored]: إضافة التكلفة
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItemEntity({
    this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.cost, // تم جعلها مطلوبة لضمان الإدخال
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  // [Refactored]: إضافة cost للمقارنة
  List<Object?> get props => [id, categoryId, name, price, cost, imagePath, createdAt, updatedAt]; 
}