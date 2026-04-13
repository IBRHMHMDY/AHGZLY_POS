import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.id,
    required super.name,
    super.imagePath,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CategoryModel.fromDrift(CategoryData data) {
    return CategoryModel(
      id: data.id,
      name: data.name,
      createdAt: data.createdAt, // من المفترض أن تكون DateTime
      updatedAt: data.updatedAt, // من المفترض أن تكون DateTime
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