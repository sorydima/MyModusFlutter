import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/avito_service.dart';
import '../models/product.dart';
import '../components/product_card.dart';

class AvitoIntegrationScreen extends StatefulWidget {
  const AvitoIntegrationScreen({super.key});

  @override
  State<AvitoIntegrationScreen> createState() => _AvitoIntegrationScreenState();
}

class _AvitoIntegrationScreenState extends State<AvitoIntegrationScreen>
    with TickerProviderStateMixin {
  final AvitoService _avitoService = AvitoService();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  
  bool _isLoading = false;
  Product? _parsedProduct;
  List<Product> _searchResults = [];
  List<Product> _favorites = [];
  String? _errorMessage;
  String _selectedCategory = 'odezhda_obuv_aksessuary';
  String _selectedLocation = '';

  final List<Map<String, String>> _locations = [
    {'name': 'Все регионы', 'code': ''},
    {'name': 'Москва', 'code': 'moskva'},
    {'name': 'Санкт-Петербург', 'code': 'sankt-peterburg'},
    {'name': 'Новосибирск', 'code': 'novosibirsk'},
    {'name': 'Екатеринбург', 'code': 'ekaterinburg'},
    {'name': 'Казань', 'code': 'kazan'},
    {'name': 'Нижний Новгород', 'code': 'nizhniy_novgorod'},
    {'name': 'Челябинск', 'code': 'chelyabinsk'},
    {'name': 'Самара', 'code': 'samara'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _parseUrl() async {
    if (_urlController.text.isEmpty) {
      _showError('Введите URL товара с Avito');
      return;
    }

    if (!AvitoService.isValidAvitoUrl(_urlController.text)) {
      _showError('Неверный URL Avito. Убедитесь, что URL содержит avito.ru');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _parsedProduct = null;
    });

    try {
      final product = await _avitoService.parseProductUrl(_urlController.text);
      
      setState(() {
        _parsedProduct = product;
        _isLoading = false;
      });

      if (product == null) {
        _showError('Не удалось получить информацию о товаре');
      } else {
        _showSuccess('Товар успешно загружен!');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Ошибка при парсинге: $e');
    }
  }

  Future<void> _searchProducts() async {
    if (_searchController.text.isEmpty) {
      _showError('Введите поисковый запрос');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final products = await _avitoService.searchProducts(
        _searchController.text,
        location: _selectedLocation.isNotEmpty ? _selectedLocation : null,
      );
      
      setState(() {
        _searchResults = products;
        _isLoading = false;
      });

      if (products.isEmpty) {
        _showError('По вашему запросу ничего не найдено');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Ошибка поиска: $e');
    }
  }

  Future<void> _loadCategoryProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final products = await _avitoService.getProductsByCategory(_selectedCategory);
      
      setState(() {
        _searchResults = products;
        _isLoading = false;
      });

      if (products.isEmpty) {
        _showError('В этой категории товары не найдены');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Ошибка загрузки категории: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _avitoService.getFavorites();
      setState(() {
        _favorites = favorites;
      });
    } catch (e) {
      _showError('Ошибка загрузки избранного: $e');
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    try {
      bool success;
      if (_favorites.any((p) => p.id == product.id)) {
        success = await _avitoService.removeFromFavorites(product.id);
        if (success) {
          setState(() {
            _favorites.removeWhere((p) => p.id == product.id);
          });
          _showSuccess('Товар удален из избранного');
        }
      } else {
        success = await _avitoService.addToFavorites(product.id);
        if (success) {
          setState(() {
            _favorites.add(product);
          });
          _showSuccess('Товар добавлен в избранное');
        }
      }
      
      if (!success) {
        _showError('Не удалось изменить статус избранного');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      _urlController.text = data.text!;
    }
  }

  Future<void> _openInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError('Не удалось открыть ссылку');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Интеграция с Avito'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.link), text: 'Парсинг'),
            Tab(icon: Icon(Icons.search), text: 'Поиск'),
            Tab(icon: Icon(Icons.category), text: 'Категории'),
            Tab(icon: Icon(Icons.favorite), text: 'Избранное'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildParsingTab(),
          _buildSearchTab(),
          _buildCategoriesTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildParsingTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Парсинг товара с Avito',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Вставьте ссылку на товар с Avito для получения подробной информации',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'URL товара с Avito',
                            hintText: 'https://www.avito.ru/...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.link),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _pasteFromClipboard,
                        icon: const Icon(Icons.paste),
                        tooltip: 'Вставить из буфера',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _parseUrl,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Получить информацию'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            ),
          if (_parsedProduct != null)
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_parsedProduct!.image != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _parsedProduct!.image!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _parsedProduct!.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_parsedProduct!.price != null)
                                  Text(
                                    _parsedProduct!.formattedPrice,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                if (_parsedProduct!.location != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(_parsedProduct!.location!, style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                if (_parsedProduct!.condition != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Chip(
                                      label: Text(_parsedProduct!.condition!),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_parsedProduct!.description != null) ...[
                        const SizedBox(height: 16),
                        const Text('Описание:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_parsedProduct!.description!),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openInBrowser(_parsedProduct!.link),
                              icon: const Icon(Icons.open_in_browser),
                              label: const Text('Открыть на Avito'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _toggleFavorite(_parsedProduct!),
                            icon: Icon(
                              _favorites.any((p) => p.id == _parsedProduct!.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            tooltip: 'Добавить в избранное',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Поиск товаров',
                      hintText: 'Введите название товара',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchProducts(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: const InputDecoration(
                      labelText: 'Регион',
                      border: OutlineInputBorder(),
                    ),
                    items: _locations.map((location) {
                      return DropdownMenuItem(
                        value: location['code'],
                        child: Text(location['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _searchProducts,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Найти товары'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'Введите поисковый запрос и нажмите "Найти товары"',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _openInBrowser(product.link),
                        onFavorite: () => _toggleFavorite(product),
                        isFavorite: _favorites.any((p) => p.id == product.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final categories = AvitoService.getPopularCategories();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Выберите категорию',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category['code'],
                        child: Text(category['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _loadCategoryProducts,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Загрузить товары'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'Выберите категорию и нажмите "Загрузить товары"',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _openInBrowser(product.link),
                        onFavorite: () => _toggleFavorite(product),
                        isFavorite: _favorites.any((p) => p.id == product.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Нет избранных товаров',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Добавьте товары в избранное для быстрого доступа',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final product = _favorites[index];
                return ProductCard(
                  product: product,
                  onTap: () => _openInBrowser(product.link),
                  onFavorite: () => _toggleFavorite(product),
                  isFavorite: true,
                );
              },
            ),
    );
  }
}
