import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';

class ItemModel extends Item {
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
      price: map['price'],
      imagePath: map['image_path'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'image_path': imagePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}