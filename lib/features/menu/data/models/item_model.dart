// مسار الملف: lib/features/menu/data/models/item_model.dart

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

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      // Refactored: تحويل إلى int لضمان التوافق مع قاعدة البيانات الجديدة (القروش)
      price: (map['price'] as num).toInt(), 
      imagePath: map.containsKey('image_path') ? map['image_path'] : null,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
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