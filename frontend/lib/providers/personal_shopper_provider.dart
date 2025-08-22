import 'package:flutter/foundation.dart';
import '../services/personal_shopper_service.dart';
import '../models/product.dart';

class PersonalShopperProvider with ChangeNotifier {
  final PersonalShopperService _service = PersonalShopperService();
  
  // Данные
  List<AIRecommendation> _recommendations = [];
  List<WishlistItem> _wishlistItems = [];
  UserPreferences? _preferences;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _insights;
  
  // Состояние
  bool _isLoading = false;
  bool _isGeneratingRecommendations = false;
  String? _errorMessage;
  
  // Фильтры
  String? _selectedCategory;
  String? _selectedType;
  
  // Геттеры
  List<AIRecommendation> get recommendations => _recommendations;
  List<WishlistItem> get wishlistItems => _wishlistItems;
  UserPreferences? get preferences => _preferences;
  Map<String, dynamic>? get stats => _stats;
  Map<String, dynamic>? get insights => _insights;
  bool get isLoading => _isLoading;
  bool get isGeneratingRecommendations => _isGeneratingRecommendations;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String? get selectedType => _selectedType;

  /// Инициализация данных для пользователя
  Future<void> initializeForUser(String userId) async {
    setLoading(true);
    clearError();
    
    try {
      await Future.wait([
        loadRecommendations(userId),
        loadWishlist(userId),
        loadPreferences(userId),
        loadStats(userId),
        loadInsights(userId),
      ]);
    } catch (e) {
      setError('Ошибка загрузки данных: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Загрузка рекомендаций
  Future<void> loadRecommendations(String userId) async {
    try {
      final recommendations = await _service.getPersonalRecommendations(
        userId,
        category: _selectedCategory,
        type: _selectedType,
      );
      
      _recommendations = recommendations;
      notifyListeners();
    } catch (e) {
      setError('Ошибка загрузки рекомендаций: $e');
    }
  }

  /// Генерация новых рекомендаций
  Future<bool> generateRecommendations(String userId, {
    int limit = 20,
    String? category,
    List<String>? excludeProductIds,
  }) async {
    _isGeneratingRecommendations = true;
    notifyListeners();
    
    try {
      final newRecommendations = await _service.generateRecommendations(
        userId,
        limit: limit,
        category: category ?? _selectedCategory,
        excludeProductIds: excludeProductIds,
      );
      
      _recommendations = newRecommendations;
      _isGeneratingRecommendations = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isGeneratingRecommendations = false;
      setError('Ошибка генерации рекомендаций: $e');
      return false;
    }
  }

  /// Отметка рекомендации как просмотренной
  Future<bool> markRecommendationViewed(String recId) async {
    try {
      final success = await _service.markRecommendationViewed(recId);
      if (success) {
        // Обновляем локальное состояние
        final index = _recommendations.indexWhere((r) => r.id == recId);
        if (index != -1) {
          // Создаем новый объект с обновленным состоянием
          // (в реальном приложении лучше использовать immutable классы)
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      setError('Ошибка отметки просмотра: $e');
      return false;
    }
  }

  /// Отметка рекомендации как нажатой
  Future<bool> markRecommendationClicked(String recId) async {
    try {
      return await _service.markRecommendationClicked(recId);
    } catch (e) {
      setError('Ошибка отметки клика: $e');
      return false;
    }
  }

  /// Отметка рекомендации как купленной
  Future<bool> markRecommendationPurchased(String recId) async {
    try {
      return await _service.markRecommendationPurchased(recId);
    } catch (e) {
      setError('Ошибка отметки покупки: $e');
      return false;
    }
  }

  /// Загрузка вишлиста
  Future<void> loadWishlist(String userId) async {
    try {
      final wishlist = await _service.getWishlist(userId);
      _wishlistItems = wishlist;
      notifyListeners();
    } catch (e) {
      setError('Ошибка загрузки избранного: $e');
    }
  }

  /// Добавление товара в вишлист
  Future<bool> addToWishlist(String userId, Product product, {
    int priority = 3,
    int? priceAlertThreshold,
    String? notes,
  }) async {
    try {
      final success = await _service.addToWishlist(
        userId,
        product,
        priority: priority,
        priceAlertThreshold: priceAlertThreshold,
        notes: notes,
      );
      
      if (success) {
        await loadWishlist(userId);
      }
      
      return success;
    } catch (e) {
      setError('Ошибка добавления в избранное: $e');
      return false;
    }
  }

  /// Удаление товара из вишлиста
  Future<bool> removeFromWishlist(String userId, String productId) async {
    try {
      final success = await _service.removeFromWishlist(userId, productId);
      
      if (success) {
        _wishlistItems.removeWhere((item) => item.productId == productId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      setError('Ошибка удаления из избранного: $e');
      return false;
    }
  }

  /// Обновление элемента вишлиста
  Future<bool> updateWishlistItem(String userId, String productId, {
    int? priority,
    int? priceAlertThreshold,
    String? notes,
  }) async {
    try {
      final success = await _service.updateWishlistItem(
        userId,
        productId,
        priority: priority,
        priceAlertThreshold: priceAlertThreshold,
        notes: notes,
      );
      
      if (success) {
        await loadWishlist(userId);
      }
      
      return success;
    } catch (e) {
      setError('Ошибка обновления избранного: $e');
      return false;
    }
  }

  /// Загрузка предпочтений
  Future<void> loadPreferences(String userId) async {
    try {
      final preferences = await _service.getUserPreferences(userId);
      _preferences = preferences;
      notifyListeners();
    } catch (e) {
      setError('Ошибка загрузки предпочтений: $e');
    }
  }

  /// Обновление предпочтений
  Future<bool> updatePreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      final success = await _service.updateUserPreferences(userId, preferences);
      
      if (success) {
        await loadPreferences(userId);
      }
      
      return success;
    } catch (e) {
      setError('Ошибка обновления предпочтений: $e');
      return false;
    }
  }

  /// Анализ предпочтений
  Future<bool> analyzePreferences(String userId) async {
    setLoading(true);
    
    try {
      final success = await _service.analyzeUserPreferences(userId);
      
      if (success) {
        await Future.wait([
          loadPreferences(userId),
          loadInsights(userId),
        ]);
      }
      
      setLoading(false);
      return success;
    } catch (e) {
      setLoading(false);
      setError('Ошибка анализа предпочтений: $e');
      return false;
    }
  }

  /// Загрузка статистики
  Future<void> loadStats(String userId) async {
    try {
      final stats = await _service.getUserStats(userId);
      _stats = stats;
      notifyListeners();
    } catch (e) {
      setError('Ошибка загрузки статистики: $e');
    }
  }

  /// Загрузка инсайтов
  Future<void> loadInsights(String userId) async {
    try {
      final insights = await _service.getUserInsights(userId);
      _insights = insights;
      notifyListeners();
    } catch (e) {
      setError('Ошибка загрузки аналитики: $e');
    }
  }

  /// Запись просмотра товара
  Future<void> recordProductView(String userId, Product product, {
    int viewDuration = 0,
    bool clickedDetails = false,
    bool addedToWishlist = false,
  }) async {
    try {
      await _service.recordProductView(
        userId,
        product,
        viewDuration: viewDuration,
        clickedDetails: clickedDetails,
        addedToWishlist: addedToWishlist,
      );
      
      // Опционально обновляем статистику
      if (viewDuration > 5) { // Если просмотр был достаточно долгим
        loadStats(userId);
      }
    } catch (e) {
      // Не показываем ошибку пользователю, так как это фоновая операция
      debugPrint('Ошибка записи просмотра: $e');
    }
  }

  /// Запись покупки
  Future<bool> recordPurchase(String userId, Product product, {
    int quantity = 1,
    int? totalAmount,
    int? purchaseSatisfaction,
    String? purchaseReason,
  }) async {
    try {
      final success = await _service.recordPurchase(
        userId,
        product,
        quantity: quantity,
        totalAmount: totalAmount,
        purchaseSatisfaction: purchaseSatisfaction,
        purchaseReason: purchaseReason,
      );
      
      if (success) {
        // Обновляем статистику и инсайты
        await Future.wait([
          loadStats(userId),
          loadInsights(userId),
        ]);
      }
      
      return success;
    } catch (e) {
      setError('Ошибка записи покупки: $e');
      return false;
    }
  }

  /// Установка фильтров
  void setFilters({String? category, String? type}) {
    bool shouldNotify = false;
    
    if (_selectedCategory != category) {
      _selectedCategory = category;
      shouldNotify = true;
    }
    
    if (_selectedType != type) {
      _selectedType = type;
      shouldNotify = true;
    }
    
    if (shouldNotify) {
      notifyListeners();
    }
  }

  /// Очистка фильтров
  void clearFilters() {
    _selectedCategory = null;
    _selectedType = null;
    notifyListeners();
  }

  /// Поиск в рекомендациях
  List<AIRecommendation> searchRecommendations(String query) {
    if (query.isEmpty) return _recommendations;
    
    final lowercaseQuery = query.toLowerCase();
    return _recommendations.where((rec) =>
      rec.productTitle.toLowerCase().contains(lowercaseQuery) ||
      (rec.productBrand?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (rec.productCategory?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      rec.recommendationReasons.any((reason) =>
        reason.toLowerCase().contains(lowercaseQuery)
      )
    ).toList();
  }

  /// Поиск в вишлисте
  List<WishlistItem> searchWishlist(String query) {
    if (query.isEmpty) return _wishlistItems;
    
    final lowercaseQuery = query.toLowerCase();
    return _wishlistItems.where((item) =>
      item.productTitle.toLowerCase().contains(lowercaseQuery) ||
      (item.productBrand?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (item.productCategory?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (item.notes?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  /// Сортировка рекомендаций
  void sortRecommendations(String sortBy) {
    switch (sortBy) {
      case 'score':
        _recommendations.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));
        break;
      case 'price_low':
        _recommendations.sort((a, b) => a.productPrice.compareTo(b.productPrice));
        break;
      case 'price_high':
        _recommendations.sort((a, b) => b.productPrice.compareTo(a.productPrice));
        break;
      case 'newest':
        _recommendations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        // По умолчанию сортируем по скору
        _recommendations.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));
    }
    notifyListeners();
  }

  /// Сортировка вишлиста
  void sortWishlist(String sortBy) {
    switch (sortBy) {
      case 'priority':
        _wishlistItems.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 'price_low':
        _wishlistItems.sort((a, b) => a.productPrice.compareTo(b.productPrice));
        break;
      case 'price_high':
        _wishlistItems.sort((a, b) => b.productPrice.compareTo(a.productPrice));
        break;
      case 'newest':
        _wishlistItems.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case 'oldest':
        _wishlistItems.sort((a, b) => a.addedAt.compareTo(b.addedAt));
        break;
      default:
        // По умолчанию сортируем по приоритету
        _wishlistItems.sort((a, b) => b.priority.compareTo(a.priority));
    }
    notifyListeners();
  }

  /// Получение рекомендаций по типу
  List<AIRecommendation> getRecommendationsByType(String type) {
    return _recommendations.where((rec) => rec.recommendationType == type).toList();
  }

  /// Получение топ категорий из инсайтов
  List<String> getTopCategories({int limit = 5}) {
    if (_insights == null) return [];
    
    final topCategories = List<Map<String, dynamic>>.from(_insights!['top_categories'] ?? []);
    return topCategories
        .take(limit)
        .map((cat) => cat['category'] as String)
        .toList();
  }

  /// Получение топ брендов из инсайтов
  List<String> getTopBrands({int limit = 5}) {
    if (_insights == null) return [];
    
    final topBrands = List<Map<String, dynamic>>.from(_insights!['top_brands'] ?? []);
    return topBrands
        .take(limit)
        .map((brand) => brand['brand'] as String)
        .toList();
  }

  /// Проверка, есть ли товар в вишлисте
  bool isInWishlist(String productId) {
    return _wishlistItems.any((item) => item.productId == productId);
  }

  /// Получение элемента вишлиста по productId
  WishlistItem? getWishlistItem(String productId) {
    try {
      return _wishlistItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Вспомогательные методы для управления состоянием
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Очистка всех данных (например, при logout)
  void clear() {
    _recommendations.clear();
    _wishlistItems.clear();
    _preferences = null;
    _stats = null;
    _insights = null;
    _selectedCategory = null;
    _selectedType = null;
    _isLoading = false;
    _isGeneratingRecommendations = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh всех данных
  Future<void> refresh(String userId) async {
    await initializeForUser(userId);
  }
}
