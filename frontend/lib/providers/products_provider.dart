import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/wildberries_parser_service.dart';

class ProductsProvider extends ChangeNotifier {
  // Сервисы
  final WildberriesParserService _wildberriesService = WildberriesParserService();
  
  // Состояние
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedSort = 'Популярные';
  double _minPrice = 0.0;
  double _maxPrice = 100000.0;
  String _selectedBrand = '';
  bool _isInitialized = false;
  
  // Данные
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _favorites = [];
  List<CartProductModel> _cart = [];
  List<String> _categories = [];
  List<String> _popularBrands = [];
  
  // Геттеры
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedSort => _selectedSort;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get selectedBrand => _selectedBrand;
  bool get isInitialized => _isInitialized;
  
  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get filteredProducts => _filteredProducts;
  List<ProductModel> get products => _filteredProducts.isEmpty ? _allProducts : _filteredProducts;
  
  List<String> get favorites => _favorites;
  List<CartProductModel> get cart => _cart;
  List<String> get categories => _categories;
  List<String> get popularBrands => _popularBrands;
  
  int get favoritesCount => _favorites.length;
  int get cartItemCount => _cart.length;
  double get cartTotal => _cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  
  // Инициализация
  Future<void> initialize() async {
    if (_isInitialized || _isLoading) {
      return;
    }

    _setLoading(true);
    
    try {
      // Загружаем данные параллельно
      await Future.wait([
        _loadCategories(),
        _loadPopularBrands(),
        _loadBrandProducts(),
      ]);
      
      _applyFilters();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка инициализации: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Загрузка категорий
  Future<void> _loadCategories() async {
    try {
      _categories = await _wildberriesService.getCategories();
    } catch (e) {
      debugPrint('Ошибка загрузки категорий: $e');
      _categories = [];
    }
  }
  
  // Загрузка популярных брендов
  Future<void> _loadPopularBrands() async {
    try {
      _popularBrands = await _wildberriesService.getPopularBrands();
    } catch (e) {
      debugPrint('Ошибка загрузки брендов: $e');
      _popularBrands = [];
    }
  }
  
  // Загрузка товаров бренда
  Future<void> _loadBrandProducts() async {
    try {
      // Загружаем больше товаров для лучшего UX
      _allProducts = await _wildberriesService.getBrandProducts(limit: 100);
    } catch (e) {
      debugPrint('Ошибка загрузки товаров: $e');
      _allProducts = [];
    }
  }
  
  // Поиск товаров
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _setLoading(true);
    
    try {
      if (query.trim().isEmpty) {
        _allProducts = await _wildberriesService.getBrandProducts(limit: 100);
      } else {
        _allProducts = await _wildberriesService.searchProducts(query, limit: 100);
      }
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка поиска товаров: $e');
      _allProducts = [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Загрузка товаров по категории
  Future<void> loadProductsByCategory(String category) async {
    _selectedCategory = category;
    _setLoading(true);
    
    try {
      // Фильтруем по категории из уже загруженных товаров
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки товаров по категории: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Загрузка товаров со скидкой
  Future<void> loadDiscountedProducts() async {
    _setLoading(true);
    
    try {
      // Фильтруем товары со скидкой из уже загруженных
      _allProducts = _allProducts.where((product) => product.hasDiscount).toList();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки товаров со скидкой: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Применение фильтров
  void _applyFilters() {
    _filteredProducts = List.from(_allProducts);
    
    // Фильтр по категории
    if (_selectedCategory.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) => 
        product.category == _selectedCategory
      ).toList();
    }
    
    // Фильтр по бренду
    if (_selectedBrand.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) => 
        product.brand == _selectedBrand
      ).toList();
    }
    
    // Фильтр по цене
    _filteredProducts = _filteredProducts.where((product) => 
      product.price >= _minPrice && product.price <= _maxPrice
    ).toList();
    
    // Сортировка
    _sortProducts();
  }
  
  // Сортировка товаров
  void _sortProducts() {
    switch (_selectedSort) {
      case 'Популярные':
        _filteredProducts.sort((a, b) => (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
        break;
      case 'По цене (возрастание)':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'По цене (убывание)':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'По рейтингу':
        _filteredProducts.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'По дате':
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'По скидке':
        _filteredProducts.sort((a, b) {
          final aDiscount = a.oldPrice != null ? (a.oldPrice! - a.price) : 0;
          final bDiscount = b.oldPrice != null ? (b.oldPrice! - b.price) : 0;
          return bDiscount.compareTo(aDiscount);
        });
        break;
    }
  }
  
  // Установка фильтров
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }
  
  void setBrand(String brand) {
    _selectedBrand = brand;
    _applyFilters();
    notifyListeners();
  }
  
  void setSort(String sort) {
    _selectedSort = sort;
    _sortProducts();
    notifyListeners();
  }
  
  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
    notifyListeners();
  }
  
  void clearFilters() {
    _selectedCategory = '';
    _selectedBrand = '';
    _minPrice = 0.0;
    _maxPrice = 100000.0;
    _filteredProducts.clear();
    notifyListeners();
  }
  
  // Избранное
  void toggleFavorite(String productId) {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    notifyListeners();
  }
  
  bool isFavorite(String productId) {
    return _favorites.contains(productId);
  }
  
  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
  
  // Корзина
  void addToCart(ProductModel product, {int quantity = 1, String? size, String? color}) {
    final existingIndex = _cart.indexWhere((item) => 
      item.product.id == product.id && 
      item.selectedSize == size && 
      item.selectedColor == color
    );
    
    if (existingIndex != -1) {
      _cart[existingIndex] = _cart[existingIndex].copyWith(
        quantity: _cart[existingIndex].quantity + quantity,
      );
    } else {
      _cart.add(CartProductModel(
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedColor: color,
      ));
    }
    notifyListeners();
  }
  
  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }
  
  void updateCartItemQuantity(String productId, int quantity) {
    final item = _cart.firstWhere((item) => item.product.id == productId);
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      final index = _cart.indexOf(item);
      _cart[index] = item.copyWith(quantity: quantity);
      notifyListeners();
    }
  }
  
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
  
  bool isInCart(String productId) {
    return _cart.any((item) => item.product.id == productId);
  }
  
  // Дополнительные методы
  Future<Map<String, dynamic>> getBrandInfo() async {
    try {
      return await _wildberriesService.getBrandInfo();
    } catch (e) {
      debugPrint('Ошибка получения информации о бренде: $e');
      return {
        'name': 'My Modus',
        'description': 'Бренд модной одежды и аксессуаров',
        'productsCount': '150+',
        'url': 'https://www.wildberries.ru/brands/311036101-my-modus',
      };
    }
  }
  
  List<String> getCategories() => _categories;
  List<String> getPopularBrands() => _popularBrands;
  
  List<ProductModel> getProductsByCategory(String category) {
    return _allProducts.where((product) => product.category == category).toList();
  }
  
  List<ProductModel> getDiscountedProducts() {
    return _allProducts.where((product) => product.hasDiscount).toList();
  }
  
  List<ProductModel> getSimilarProducts(ProductModel product, {int limit = 4}) {
    return _allProducts
        .where((p) => p.id != product.id && p.category == product.category)
        .take(limit)
        .toList();
  }
  
  List<ProductModel> getBrandProducts(String brand, {int limit = 20}) {
    return _allProducts
        .where((product) => product.brand == brand)
        .take(limit)
        .toList();
  }
  
  List<ProductModel> getSimilarPriceProducts(ProductModel product, {int limit = 4}) {
    final priceRange = product.price * 0.3; // ±30% от цены
    return _allProducts
        .where((p) => 
          p.id != product.id && 
          (p.price - product.price).abs() <= priceRange
        )
        .take(limit)
        .toList();
  }
  
  void incrementViewCount(String productId) {
    final product = _allProducts.firstWhere((p) => p.id == productId);
    final index = _allProducts.indexOf(product);
    _allProducts[index] = product.copyWith(
      viewCount: (product.viewCount ?? 0) + 1,
    );
    notifyListeners();
  }
  
  void incrementLikeCount(String productId) {
    final product = _allProducts.firstWhere((p) => p.id == productId);
    final index = _allProducts.indexOf(product);
    _allProducts[index] = product.copyWith(
      likeCount: (product.likeCount ?? 0) + 1,
    );
    notifyListeners();
  }
  
  Map<String, dynamic> getStats() {
    return {
      'totalProducts': _allProducts.length,
      'totalCategories': _categories.length,
      'totalBrands': _popularBrands.length,
      'averagePrice': _allProducts.isEmpty ? 0 : 
        _allProducts.map((p) => p.price).reduce((a, b) => a + b) / _allProducts.length,
      'discountedProducts': _allProducts.where((p) => p.hasDiscount).length,
      'newProducts': _allProducts.where((p) => p.isNew).length,
    };
  }
  
  List<ProductModel> getTopProducts({int limit = 10}) {
    final sorted = List<ProductModel>.from(_allProducts);
    sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return sorted.take(limit).toList();
  }
  
  List<ProductModel> getNewProducts({int limit = 10}) {
    final sorted = List<ProductModel>.from(_allProducts);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }
  
  List<ProductModel> getMaxDiscountProducts({int limit = 10}) {
    final sorted = List<ProductModel>.from(_allProducts);
    sorted.sort((a, b) {
      final aDiscount = a.oldPrice != null ? (a.oldPrice! - a.price) : 0;
      final bDiscount = b.oldPrice != null ? (b.oldPrice! - b.price) : 0;
      return bDiscount.compareTo(aDiscount);
    });
    return sorted.take(limit).toList();
  }
  
  // Приватные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
