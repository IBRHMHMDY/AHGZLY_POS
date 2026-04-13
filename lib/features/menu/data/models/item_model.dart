// مسار الملف: lib/features/menu/data/models/item_model.dart

import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    super.id,
    required super.categoryId,
    required super.name,
    required super.price,
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
      createdAt: data.createdAt, // من المفترض أن تكون DateTime
      updatedAt: data.updatedAt, // من المفترض أن تكون DateTime
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price, // سيتم حفظه كـ Integer
      // 'image_path': imagePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}