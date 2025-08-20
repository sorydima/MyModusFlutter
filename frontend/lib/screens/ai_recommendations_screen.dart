import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';

/// Экран AI рекомендаций продуктов
class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() => _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  
  // Данные рекомендаций
  List<ProductRecommendation> _personalRecommendations = [];
  List<ProductRecommendation> _similarRecommendations = [];
  List<ProductRecommendation> _newUserRecommendations = [];
  
  // Выбранный товар для похожих рекомендаций
  ProductModel? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Загружаем рекомендации при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Рекомендации'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadRecommendations,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить рекомендации',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Персональные'),
            Tab(icon: Icon(Icons.compare), text: 'Похожие'),
            Tab(icon: Icon(Icons.trending_up), text: 'Популярные'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalRecommendationsTab(),
          _buildSimilarRecommendationsTab(),
          _buildNewUserRecommendationsTab(),
        ],
      ),
    );
  }

  /// Вкладка персональных рекомендаций
  Widget _buildPersonalRecommendationsTab() {
    return _buildRecommendationsContent(
      recommendations: _personalRecommendations,
      title: 'Персональные рекомендации',
      subtitle: 'Товары, подобранные специально для вас на основе ваших предпочтений',
      emptyMessage: 'У нас пока недостаточно данных для персональных рекомендаций.\nПросматривайте товары, чтобы мы могли лучше понять ваши предпочтения!',
      onRefresh: () => _loadPersonalRecommendations(),
    );
  }

  /// Вкладка похожих товаров
  Widget _buildSimilarRecommendationsTab() {
    return Column(
      children: [
        // Выбор товара для сравнения
        Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите товар для поиска похожих:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (_selectedProduct != null) ...[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _selectedProduct!.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedProduct!.title,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_selectedProduct!.price} ₽',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _selectedProduct = null),
                        icon: const Icon(Icons.close),
                        tooltip: 'Очистить выбор',
                      ),
                    ],
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _selectProductForComparison,
                    icon: const Icon(Icons.search),
                    label: const Text('Выбрать товар'),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Похожие товары
        Expanded(
          child: _buildRecommendationsContent(
            recommendations: _similarRecommendations,
            title: 'Похожие товары',
            subtitle: _selectedProduct != null 
                ? 'Товары, похожие на "${_selectedProduct!.title}"'
                : 'Выберите товар для поиска похожих',
            emptyMessage: _selectedProduct != null
                ? 'К сожалению, не найдено похожих товаров.\nПопробуйте выбрать другой товар или изменить параметры поиска.'
                : 'Выберите товар, чтобы найти похожие варианты',
            onRefresh: () => _loadSimilarRecommendations(),
          ),
        ),
      ],
    );
  }

  /// Вкладка популярных товаров для новых пользователей
  Widget _buildNewUserRecommendationsTab() {
    return _buildRecommendationsContent(
      recommendations: _newUserRecommendations,
      title: 'Популярные товары',
      subtitle: 'Товары с высоким рейтингом, которые нравятся многим покупателям',
      emptyMessage: 'Популярные товары загружаются...',
      onRefresh: () => _loadNewUserRecommendations(),
    );
  }

  /// Общий контент для рекомендаций
  Widget _buildRecommendationsContent({
    required List<ProductRecommendation> recommendations,
    required String title,
    required String subtitle,
    required String emptyMessage,
    required VoidCallback onRefresh,
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    if (recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.recommend,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Обновить'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        slivers: [
          // Заголовок
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Найдено ${recommendations.length} рекомендаций',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Список рекомендаций
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recommendation = recommendations[index];
                  return _buildRecommendationCard(recommendation);
                },
                childCount: recommendations.length,
              ),
            ),
          ),
          
          // Отступ внизу
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  /// Карточка рекомендации
  Widget _buildRecommendationCard(ProductRecommendation recommendation) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение товара
          Expanded(
            child: Stack(
              children: [
                // Основное изображение
                SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    recommendation.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 48),
                      );
                    },
                  ),
                ),
                
                // Оценка рекомендации
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recommendation.score.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Скидка
                if (recommendation.product.discount != null && 
                    recommendation.product.discount! > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${recommendation.product.discount}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Информация о товаре
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название товара
                Text(
                  recommendation.product.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Цена
                Row(
                  children: [
                    Text(
                      '${recommendation.product.price} ₽',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (recommendation.product.oldPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${recommendation.product.oldPrice} ₽',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Причина рекомендации
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    recommendation.reason,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Методы загрузки данных

  /// Загрузка всех рекомендаций
  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _loadPersonalRecommendations(),
        _loadNewUserRecommendations(),
      ]);
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки рекомендаций: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Загрузка персональных рекомендаций
  Future<void> _loadPersonalRecommendations() async {
    try {
      // TODO: Реализовать API вызов
      // final response = await context.read<AppProvider>().apiService.getPersonalRecommendations();
      // setState(() {
      //   _personalRecommendations = response;
      // });
      
      // Пока используем mock данные
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _personalRecommendations = _generateMockPersonalRecommendations();
      });
    } catch (e) {
      print('Error loading personal recommendations: $e');
    }
  }

  /// Загрузка похожих товаров
  Future<void> _loadSimilarRecommendations() async {
    if (_selectedProduct == null) return;
    
    try {
      // TODO: Реализовать API вызов
      // final response = await context.read<AppProvider>().apiService.getSimilarProducts(_selectedProduct!.id);
      // setState(() {
      //   _similarRecommendations = response;
      // });
      
      // Пока используем mock данные
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _similarRecommendations = _generateMockSimilarRecommendations();
      });
    } catch (e) {
      print('Error loading similar recommendations: $e');
    }
  }

  /// Загрузка популярных товаров
  Future<void> _loadNewUserRecommendations() async {
    try {
      // TODO: Реализовать API вызов
      // final response = await context.read<AppProvider>().apiService.getNewUserRecommendations();
      // setState(() {
      //   _newUserRecommendations = response;
      // });
      
      // Пока используем mock данные
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _newUserRecommendations = _generateMockNewUserRecommendations();
      });
    } catch (e) {
      print('Error loading new user recommendations: $e');
    }
  }

  /// Выбор товара для сравнения
  Future<void> _selectProductForComparison() async {
    // TODO: Реализовать выбор товара
    // Можно открыть модальное окно с поиском или список недавно просмотренных
    
    // Пока используем mock товар
    setState(() {
      _selectedProduct = _generateMockProduct();
    });
    
    // Загружаем похожие товары
    await _loadSimilarRecommendations();
  }

  // Mock данные для демонстрации

  ProductModel _generateMockProduct() {
    return ProductModel(
      id: 'mock_1',
      title: 'Стильная футболка Casual',
      description: 'Удобная футболка из натурального хлопка',
      price: 2500,
      oldPrice: 3500,
      discount: 29,
      imageUrl: 'https://via.placeholder.com/300x400/4A90E2/FFFFFF?text=Mock+Product',
      productUrl: 'https://example.com/product1',
      brand: 'MockBrand',
      categoryId: 'clothing',
      sku: 'MOCK001',
      specifications: {'material': 'cotton', 'size': 'M'},
      stock: 10,
      rating: 4.5,
      reviewCount: 25,
      source: 'mock',
      sourceId: 'mock_1',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    );
  }

  List<ProductRecommendation> _generateMockPersonalRecommendations() {
    return [
      ProductRecommendation(
        product: _generateMockProduct(),
        score: 4.8,
        reason: 'Любимая категория, подходящая цена',
      ),
      ProductRecommendation(
        product: ProductModel(
          id: 'mock_2',
          title: 'Джинсы Street Style',
          description: 'Современные джинсы в уличном стиле',
          price: 4500,
          oldPrice: null,
          discount: null,
          imageUrl: 'https://via.placeholder.com/300x400/50C878/FFFFFF?text=Mock+Product+2',
          productUrl: 'https://example.com/product2',
          brand: 'MockBrand',
          categoryId: 'clothing',
          sku: 'MOCK002',
          specifications: {'material': 'denim', 'size': 'L'},
          stock: 15,
          rating: 4.3,
          reviewCount: 18,
          source: 'mock',
          sourceId: 'mock_2',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now(),
        ),
        score: 4.5,
        reason: 'Любимый бренд, высокий рейтинг',
      ),
    ];
  }

  List<ProductRecommendation> _generateMockSimilarRecommendations() {
    return [
      ProductRecommendation(
        product: ProductModel(
          id: 'mock_3',
          title: 'Футболка Sport Edition',
          description: 'Спортивная футболка для активного образа жизни',
          price: 2800,
          oldPrice: 3200,
          discount: 13,
          imageUrl: 'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=Mock+Product+3',
          productUrl: 'https://example.com/product3',
          brand: 'MockBrand',
          categoryId: 'clothing',
          sku: 'MOCK003',
          specifications: {'material': 'polyester', 'size': 'M'},
          stock: 8,
          rating: 4.2,
          reviewCount: 12,
          source: 'mock',
          sourceId: 'mock_3',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
        score: 4.2,
        reason: 'Та же категория, похожий стиль',
      ),
    ];
  }

  List<ProductRecommendation> _generateMockNewUserRecommendations() {
    return [
      ProductRecommendation(
        product: ProductModel(
          id: 'mock_4',
          title: 'Классическая рубашка',
          description: 'Элегантная рубашка для делового стиля',
          price: 3800,
          oldPrice: null,
          discount: null,
          imageUrl: 'https://via.placeholder.com/300x400/9B59B6/FFFFFF?text=Mock+Product+4',
          productUrl: 'https://example.com/product4',
          brand: 'PremiumBrand',
          categoryId: 'clothing',
          sku: 'MOCK004',
          specifications: {'material': 'cotton', 'size': 'L'},
          stock: 20,
          rating: 4.7,
          reviewCount: 45,
          source: 'mock',
          sourceId: 'mock_4',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
        ),
        score: 4.7,
        reason: 'Популярный товар с высоким рейтингом',
      ),
    ];
  }
}

/// Модель рекомендации продукта для Flutter
class ProductRecommendation {
  final ProductModel product;
  final double score;
  final String reason;
  
  ProductRecommendation({
    required this.product,
    required this.score,
    required this.reason,
  });
}
