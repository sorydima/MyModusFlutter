import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/wildberries_api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'all';
  int _retryCount = 0;
  static const int maxRetries = 3;

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  int get retryCount => _retryCount;

  final Map<String, String> categories = {
    'all': 'Все товары',
    '8126': 'Одежда',
    '8127': 'Обувь',
    '8128': 'Аксессуары',
    '8129': 'Спорт',
  };

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<Product> loadedProducts;
      if (_selectedCategory == 'all') {
        loadedProducts = await WildberriesApiService.fetchMyModusProducts();
      } else {
        loadedProducts = await WildberriesApiService.fetchProductsByCategory(_selectedCategory);
      }
      
      _products = loadedProducts;
      _filteredProducts = loadedProducts;
      _retryCount = 0; // Reset retry count on success
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _retryCount++;
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryFetchProducts() async {
    if (_retryCount >= maxRetries) {
      _error = "Maximum retry attempts reached. Please try again later.";
      notifyListeners();
      return;
    }
    
    await fetchProducts();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    
    if (category == 'all') {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        // This is a simple filter - in a real app, you might want to
        // add category information to the Product model
        return true;
      }).toList();
    }
    
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refreshProducts() {
    fetchProducts();
  }

  bool get hasError => _error != null;
  bool get hasProducts => _products.isNotEmpty;
  bool get hasFilteredProducts => _filteredProducts.isNotEmpty;
}