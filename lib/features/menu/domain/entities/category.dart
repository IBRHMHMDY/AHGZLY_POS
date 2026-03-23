import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final String? imagePath;
  final String createdAt;
  final String updatedAt;

  const Category({
    this.id,
    required this.name,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, imagePath, createdAt, updatedAt];
}