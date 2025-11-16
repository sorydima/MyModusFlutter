import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/product_provider.dart';
import '../utils/responsive_utils.dart';
import 'product_card.dart';
import '../components/shimmer_card.dart' as shimmer_card;

class ProductGrid extends StatefulWidget {
  final int categoryIndex;

  const ProductGrid({
    super.key,
    required this.categoryIndex,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Загружаем продукты при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    final appProvider = context.read<AppProvider>();
    final productProvider = appProvider.productProvider;
    
    // Устанавливаем категорию и загружаем продукты
    final categoryNames = ['Все', 'Одежда', 'Обувь', 'Аксессуары'];
    if (widget.categoryIndex > 0 && widget.categoryIndex < categoryNames.length) {
      final categoryName = categoryNames[widget.categoryIndex];
      await productProvider.filterByCategory(categoryName);
    } else {
      await productProvider.loadProducts(refresh: true);
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;
    
    final appProvider = context.read<AppProvider>();
    final productProvider = appProvider.productProvider;
    
    if (productProvider.hasMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      await productProvider.loadProducts();
      
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final productProvider = appProvider.productProvider;
        
        return RefreshIndicator(
          onRefresh: _refreshProducts,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Основная сетка продуктов
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: _buildProductGrid(productProvider),
              ),
              
              // Индикатор загрузки для подгрузки
              if (_isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              
              // Сообщение о конце списка
              if (!productProvider.hasMore && productProvider.products.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Больше продуктов нет',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(ProductProvider productProvider) {
    // Показываем shimmer во время загрузки
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      return SliverMasonryGrid.count(
        crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
        mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
        crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
        childCount: 6,
        itemBuilder: (context, index) => shimmer_card.ShimmerCard(),
      );
    }
    
    // Показываем ошибку, если есть
    if (productProvider.error != null && productProvider.products.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки продуктов',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                productProvider.error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  productProvider.clearError();
                  _loadProducts();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Показываем пустое состояние, если нет продуктов
    if (productProvider.products.isEmpty && !productProvider.isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Продукты не найдены',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Попробуйте изменить фильтры или поиск',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Основная сетка продуктов
    return SliverMasonryGrid.count(
      crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
      mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
      crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
      childCount: productProvider.products.length,
      itemBuilder: (context, index) {
        final product = productProvider.products[index];
        return ProductCard(
          product: product,
          onTap: () {
            // TODO: Навигация к детальному экрану продукта
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Открыть ${product.title}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }
}
