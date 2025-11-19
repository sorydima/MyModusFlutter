import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../utils/responsive_utils.dart';
import 'product_card.dart';
import 'search_bar.dart' as search_bar;
import 'category_list.dart';

class ProductFeed extends StatefulWidget {
  const ProductFeed({super.key});

  @override
  State<ProductFeed> createState() => _ProductFeedState();
}

class _ProductFeedState extends State<ProductFeed> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  int _selectedCategoryIndex = 0;
  bool _isSearching = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // Загружаем продукты при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
    
    // Добавляем слушатель скролла для пагинации
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.productProvider.loadProducts(refresh: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll - 200;
    
    if (currentScroll >= threshold && !_isLoadingMore) {
      final appProvider = context.read<AppProvider>();
      final productProvider = appProvider.productProvider;
      
      // Проверяем, что есть еще данные для загрузки и не идет загрузка
      if (productProvider.hasMore && !productProvider.isLoading) {
        setState(() {
          _isLoadingMore = true;
        });
        
        productProvider.loadProducts().then((_) {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    
    final appProvider = context.read<AppProvider>();
    final productProvider = appProvider.productProvider;
    
    // Получаем название категории
    String? categoryName;
    if (index == 0) {
      categoryName = null; // "Все"
    } else if (productProvider.categories.isNotEmpty && index < productProvider.categories.length) {
      categoryName = productProvider.categories[index]['name'];
    }
    
    // Применяем фильтр по категории
    productProvider.filterByCategory(categoryName);
  }

  void _onSearchSubmitted(String query) {
    final appProvider = context.read<AppProvider>();
    appProvider.productProvider.searchProducts(query);
  }

  void _onSearchCleared() {
    _searchController.clear();
    final appProvider = context.read<AppProvider>();
    appProvider.productProvider.resetFilters();
  }

  void _onSortChanged(String sortBy, String sortOrder) {
    final appProvider = context.read<AppProvider>();
    appProvider.productProvider.sortProducts(sortBy, sortOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final productProvider = appProvider.productProvider;
        
        // Используем child для статических виджетов, чтобы избежать лишних перестроек
        return Column(
          children: [
            // Поисковая строка
            Padding(
              padding: const EdgeInsets.all(16),
              child: search_bar.SearchBar(
                controller: _searchController,
                onSubmitted: _onSearchSubmitted,
                onCleared: _onSearchCleared,
                hintText: 'Поиск товаров...',
              ),
            ),
            
            // Список категорий
            CategoryList(
              selectedCategoryIndex: _selectedCategoryIndex,
              onCategorySelected: _onCategorySelected,
            ),
            
            // Панель сортировки
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Сортировка:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _SortChip(
                            label: 'По цене',
                            onTap: () => _onSortChanged('price', 'asc'),
                          ),
                          const SizedBox(width: 8),
                          _SortChip(
                            label: 'По популярности',
                            onTap: () => _onSortChanged('popularity', 'desc'),
                          ),
                          const SizedBox(width: 8),
                          _SortChip(
                            label: 'По дате',
                            onTap: () => _onSortChanged('created_at', 'desc'),
                          ),
                          const SizedBox(width: 8),
                          _SortChip(
                            label: 'По рейтингу',
                            onTap: () => _onSortChanged('rating', 'desc'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Счетчик товаров
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Найдено товаров: ${productProvider.products.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (productProvider.error != null)
                    TextButton.icon(
                      onPressed: () => _loadProducts(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Повторить'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                ],
              ),
            ),
            
            // Список товаров
            Expanded(
              child: _buildProductsList(productProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsList(ProductProvider productProvider) {
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      // Показываем shimmer во время первой загрузки
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
          childAspectRatio: 0.75,
          crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
          mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _ProductCardShimmer();
        },
      );
    }
    
    if (productProvider.error != null && productProvider.products.isEmpty) {
      // Показываем ошибку
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки товаров',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productProvider.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadProducts(),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    
    if (productProvider.products.isEmpty) {
      // Показываем пустое состояние
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Товары не найдены',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить параметры поиска или фильтры',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Показываем список товаров
    return RefreshIndicator(
      onRefresh: _loadProducts,
        child: RepaintBoundary(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            cacheExtent: 500,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
              childAspectRatio: 0.75,
              crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
              mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
            ),
            itemCount: productProvider.products.length + (productProvider.hasMore && !_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == productProvider.products.length) {
              // Показываем индикатор загрузки для следующей страницы
              return const _LoadingIndicator();
            }

            final product = productProvider.products[index];
            return RepaintBoundary(
              child: ProductCard(
                key: ValueKey('product_${product.id}'),
                product: product,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ProductCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                                 borderRadius: const BorderRadius.vertical(
                   top: Radius.circular(12),
                 ),
              ),
            ),
          ),
          // Информация
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 16,
                    width: 80,
                                       decoration: BoxDecoration(
                     color: Colors.grey.shade300,
                     borderRadius: BorderRadius.circular(8),
                   ),
                 ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
