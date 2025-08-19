import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Состояние продуктов
  List<ProductModel> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  // Пагинация
  int _currentPage = 0;
  int _limit = 20;
  bool _hasMore = true;
  
  // Фильтры
  String? _selectedCategory;
  String? _searchQuery;
  String? _sortBy;
  String? _sortOrder;

  // Геттеры
  List<ProductModel> get products => _products;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String? get selectedCategory => _selectedCategory;
  String? get searchQuery => _searchQuery;
  String? get sortBy => _sortBy;
  String? get sortOrder => _sortOrder;

  // Инициализация - загружаем категории
  Future<void> initialize() async {
    await loadCategories();
  }

  // Загрузка категорий
  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      _error = null;
      
      final categories = await _apiService.getCategories();
      _categories = categories;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Загрузка продуктов
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _products.clear();
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    try {
      _setLoading(true);
      _error = null;
      
      final products = await _apiService.getProducts(
        limit: _limit,
        offset: _currentPage * _limit,
        category: _selectedCategory,
        search: _searchQuery,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      
      if (refresh) {
        _products = products;
      } else {
        _products.addAll(products);
      }
      
      _hasMore = products.length == _limit;
      _currentPage++;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Обновление фильтров
  Future<void> updateFilters({
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    bool needsRefresh = false;
    
    if (category != _selectedCategory) {
      _selectedCategory = category;
      needsRefresh = true;
    }
    
    if (search != _searchQuery) {
      _searchQuery = search;
      needsRefresh = true;
    }
    
    if (sortBy != _sortBy) {
      _sortBy = sortBy;
      needsRefresh = true;
    }
    
    if (sortOrder != _sortOrder) {
      _sortOrder = sortOrder;
      needsRefresh = true;
    }
    
    if (needsRefresh) {
      await loadProducts(refresh: true);
    }
  }

  // Сброс фильтров
  Future<void> resetFilters() async {
    _selectedCategory = null;
    _searchQuery = null;
    _sortBy = null;
    _sortOrder = null;
    await loadProducts(refresh: true);
  }

  // Поиск продуктов
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    await loadProducts(refresh: true);
  }

  // Сортировка продуктов
  Future<void> sortProducts(String sortBy, String sortOrder) async {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    await loadProducts(refresh: true);
  }

  // Фильтрация по категории
  Future<void> filterByCategory(String? category) async {
    _selectedCategory = category;
    await loadProducts(refresh: true);
  }

  // Получение продукта по ID
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Получение продуктов по категории
  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Получение избранных продуктов (если есть)
  List<ProductModel> getFavoriteProducts() {
    // TODO: Реализовать логику избранных продуктов
    return [];
  }

  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Приватные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Обновление продукта (например, после изменения цены)
  void updateProduct(ProductModel updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  // Добавление нового продукта
  void addProduct(ProductModel product) {
    _products.insert(0, product);
    notifyListeners();
  }

  // Удаление продукта
  void removeProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // Получение статистики
  Map<String, int> getProductStats() {
    final totalProducts = _products.length;
    final categoriesCount = _categories.length;
    
    // Подсчет продуктов по категориям
    final productsByCategory = <String, int>{};
    for (final product in _products) {
      final category = product.category ?? 'Без категории';
      productsByCategory[category] = (productsByCategory[category] ?? 0) + 1;
    }
    
    return {
      'total_products': totalProducts,
      'categories_count': categoriesCount,
      'products_by_category': productsByCategory,
    };
  }
}
