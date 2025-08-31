import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/products_provider.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Инициализируем провайдер при создании экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Поиск'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (context.watch<ProductsProvider>().searchQuery.isNotEmpty)
            _buildSearchResults()
          else
            _buildSearchSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Поиск товаров...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      suffixIcon: productsProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                productsProvider.searchProducts('');
                              },
                              icon: Icon(Icons.clear, color: Colors.grey.shade600),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      productsProvider.searchProducts(value);
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Кнопка фильтров
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showFiltersDialog();
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        if (productsProvider.isLoading) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final products = productsProvider.filteredProducts;
        
        if (products.isEmpty) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Товары не найдены',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Попробуйте изменить параметры поиска\nили фильтры',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Expanded(
          child: Column(
            children: [
              // Заголовок с количеством результатов
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Найдено ${products.length} товаров',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Сортировка: ${productsProvider.selectedSort}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Сетка товаров
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.error, size: 30),
                    ),
                  ),
                  
                  // Статус товара
                  if (product.isNew || product.isSale || !product.inStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(product.statusColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  
                  // Кнопка избранного
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<ProductsProvider>(
                      builder: (context, productsProvider, child) {
                        final isFavorite = productsProvider.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            productsProvider.toggleFavorite(product.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Информация о товаре
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Бренд
                  Text(
                    product.brand,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Название
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Рейтинг и отзывы
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.formattedRating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.formattedReviewCount})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Цена
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          product.formattedOldPrice,
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.formattedDiscount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        return Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Популярные поиски
                Text(
                  'Популярные поиски',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    'My Modus', 'Nike', 'Adidas', 'Levi\'s', 'Apple', 'Samsung', 'Кроссовки',
                    'Джинсы', 'Часы', 'Телефон', 'Спорт', 'Мода', 'Стиль'
                  ].map((tag) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _searchController.text = tag;
                        productsProvider.searchProducts(tag);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 40),
                
                // Категории
                Text(
                  'Популярные категории',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                FutureBuilder<List<String>>(
                  future: Future.value(productsProvider.getCategories()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final categories = snapshot.data ?? [];
                    
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: categories.take(4).map((category) {
                        return _buildCategoryCard(category);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String title) {
    IconData icon;
    Color color;
    
    switch (title) {
      case 'Обувь':
        icon = Icons.sports_soccer;
        color = Colors.blue;
        break;
      case 'Одежда':
        icon = Icons.checkroom;
        color = Colors.green;
        break;
      case 'Электроника':
        icon = Icons.phone_android;
        color = Colors.purple;
        break;
      case 'Спорт':
        icon = Icons.fitness_center;
        color = Colors.orange;
        break;
      default:
        icon = Icons.shopping_bag;
        color = Colors.grey;
    }
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<ProductsProvider>().setCategory(title);
        _searchController.text = title;
        context.read<ProductsProvider>().searchProducts(title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltersBottomSheet(),
    );
  }

  Widget _buildFiltersBottomSheet() {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Заголовок
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Фильтры',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        productsProvider.clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Сбросить'),
                    ),
                  ],
                ),
              ),
              
              // Содержимое фильтров
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Категории
                      Text(
                        'Категория',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      FutureBuilder<List<String>>(
                        future: Future.value(productsProvider.getCategories()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final categories = snapshot.data ?? [];
                          
                          return Wrap(
                            spacing: 8,
                            children: categories.map((category) {
                              final isSelected = productsProvider.selectedCategory == category;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  productsProvider.setCategory(category);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Сортировка
                      Text(
                        'Сортировка',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      RadioListTile<String>(
                        title: const Text('Популярные'),
                        value: 'Популярные',
                        groupValue: productsProvider.selectedSort,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          productsProvider.setSort(value!);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<String>(
                        title: const Text('По цене ↑'),
                        value: 'По цене ↑',
                        groupValue: productsProvider.selectedSort,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          productsProvider.setSort(value!);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<String>(
                        title: const Text('По цене ↓'),
                        value: 'По цене ↓',
                        groupValue: productsProvider.selectedSort,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          productsProvider.setSort(value!);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<String>(
                        title: const Text('По рейтингу'),
                        value: 'По рейтингу',
                        groupValue: productsProvider.selectedSort,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          productsProvider.setSort(value!);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<String>(
                        title: const Text('По новизне'),
                        value: 'По новизне',
                        groupValue: productsProvider.selectedSort,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          productsProvider.setSort(value!);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Диапазон цен
                      Text(
                        'Диапазон цен',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      RangeSlider(
                        values: RangeValues(
                          productsProvider.minPrice,
                          productsProvider.maxPrice,
                        ),
                        min: 0,
                        max: 100000,
                        divisions: 100,
                        labels: RangeLabels(
                          '${productsProvider.minPrice.toInt()} ₽',
                          '${productsProvider.maxPrice.toInt()} ₽',
                        ),
                        onChanged: (values) {
                          HapticFeedback.lightImpact();
                          productsProvider.setPriceRange(values.start, values.end);
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Кнопка применить
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Применить фильтры',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}