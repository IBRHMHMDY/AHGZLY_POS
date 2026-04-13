import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';

class CategoriesSection extends StatelessWidget {
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final bool isLoading;
  final ValueChanged<CategoryEntity> onCategorySelected;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.isLoading,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: const Text('الأقسام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.center),
          ),
          Expanded(
            child: isLoading && categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory?.id == category.id;
                      return InkWell(
                        onTap: () => onCategorySelected(category),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.teal : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? Colors.teal : Colors.grey.shade300),
                            boxShadow: isSelected ? [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}