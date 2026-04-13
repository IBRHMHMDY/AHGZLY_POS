import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.id,
    required super.name,
    super.imagePath,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      imagePath: map.containsKey('image_path') ? map['image_path'] : null,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      // 'image_path': imagePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}