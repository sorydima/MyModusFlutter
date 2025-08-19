import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class CategoryList extends StatefulWidget {
  final int selectedCategoryIndex;
  final Function(int) onCategorySelected;

  const CategoryList({
    super.key,
    required this.selectedCategoryIndex,
    required this.onCategorySelected,
  });

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  void initState() {
    super.initState();
    
    // Загружаем категории при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.productProvider.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final productProvider = appProvider.productProvider;
        
        // Показываем shimmer во время загрузки
        if (productProvider.isLoading && productProvider.categories.isEmpty) {
          return SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
        
        // Показываем ошибку, если есть
        if (productProvider.error != null && productProvider.categories.isEmpty) {
          return Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ошибка загрузки категорий',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Получаем категории из провайдера или используем дефолтные
        final categories = productProvider.categories.isNotEmpty 
            ? productProvider.categories 
            : [
                {'name': 'Все', 'icon': '🏠', 'color': Colors.grey},
                {'name': 'Обувь', 'icon': '👟', 'color': Colors.blue},
                {'name': 'Одежда', 'icon': '👕', 'color': Colors.green},
                {'name': 'Аксессуары', 'icon': '👜', 'color': Colors.orange},
                {'name': 'Электроника', 'icon': '📱', 'color': Colors.purple},
                {'name': 'Спорт', 'icon': '⚽', 'color': Colors.red},
                {'name': 'Красота', 'icon': '💄', 'color': Colors.pink},
              ];
        
        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = index == widget.selectedCategoryIndex;
              
              return GestureDetector(
                onTap: () {
                  widget.onCategorySelected(index);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : (category['color'] as Color? ?? Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : (category['color'] as Color? ?? Colors.grey))
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: isSelected 
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            category['icon'] as String? ?? '📦',
                            style: TextStyle(
                              fontSize: 30,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String? ?? 'Категория',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
