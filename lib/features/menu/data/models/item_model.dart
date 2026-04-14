// مسار الملف: lib/features/menu/data/models/item_model.dart

import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    super.id,
    required super.categoryId,
    required super.name,
    required super.price,
    required super.cost, // [Refactored]: تمرير التكلفة للكيان
    super.imagePath,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ItemModel.fromDrift(ItemData data) {
    return ItemModel(
      id: data.id,
      categoryId: data.categoryId,
      name: data.name,
      price: data.price,
      cost: data.cost, // [Refactored]: قراءة التكلفة من قاعدة البيانات
      createdAt: data.createdAt, 
      updatedAt: data.updatedAt, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price, 
      'cost': cost, // [Refactored]: تحضير التكلفة للحفظ
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}