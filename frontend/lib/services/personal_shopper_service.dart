import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// Модель пользовательских предпочтений
class UserPreferences {
  final String id;
  final String userId;
  final Map<String, double> categoryPreferences;
  final Map<String, double> brandPreferences;
  final Map<String, int> priceRange;
  final Map<String, String> sizePreferences;
  final List<String> colorPreferences;
  final List<String> stylePreferences;
  final Map<String, String> seasonalPreferences;
  final Map<String, int> shoppingFrequency;
  final int budgetMonthly;
  final List<String> preferredMarketplaces;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.categoryPreferences,
    required this.brandPreferences,
    required this.priceRange,
    required this.sizePreferences,
    required this.colorPreferences,
    required this.stylePreferences,
    required this.seasonalPreferences,
    required this.shoppingFrequency,
    required this.budgetMonthly,
    required this.preferredMarketplaces,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      categoryPreferences: Map<String, double>.from(json['category_preferences'] ?? {}),
      brandPreferences: Map<String, double>.from(json['brand_preferences'] ?? {}),
      priceRange: Map<String, int>.from(json['price_range'] ?? {'min': 0, 'max': 1000000}),
      sizePreferences: Map<String, String>.from(json['size_preferences'] ?? {}),
      colorPreferences: List<String>.from(json['color_preferences'] ?? []),
      stylePreferences: List<String>.from(json['style_preferences'] ?? []),
      seasonalPreferences: Map<String, String>.from(json['seasonal_preferences'] ?? {}),
      shoppingFrequency: Map<String, int>.from(json['shopping_frequency'] ?? {}),
      budgetMonthly: json['budget_monthly'] ?? 0,
      preferredMarketplaces: List<String>.from(json['preferred_marketplaces'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_preferences': categoryPreferences,
      'brand_preferences': brandPreferences,
      'price_range': priceRange,
      'size_preferences': sizePreferences,
      'color_preferences': colorPreferences,
      'style_preferences': stylePreferences,
      'seasonal_preferences': seasonalPreferences,
      'shopping_frequency': shoppingFrequency,
      'budget_monthly': budgetMonthly,
      'preferred_marketplaces': preferredMarketplaces,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Модель AI-рекомендации
class AIRecommendation {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final int productPrice;
  final String? productCategory;
  final String? productBrand;
  final String productSource;
  final String productUrl;
  final String? productImageUrl;
  final double recommendationScore;
  final List<String> recommendationReasons;
  final String recommendationType;
  final bool isViewed;
  final bool isClicked;
  final bool isPurchased;
  final DateTime createdAt;
  final DateTime? expiresAt;

  AIRecommendation({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    this.productCategory,
    this.productBrand,
    required this.productSource,
    required this.productUrl,
    this.productImageUrl,
    required this.recommendationScore,
    required this.recommendationReasons,
    required this.recommendationType,
    required this.isViewed,
    required this.isClicked,
    required this.isPurchased,
    required this.createdAt,
    this.expiresAt,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? '',
      productTitle: json['product_title'] ?? '',
      productPrice: json['product_price'] ?? 0,
      productCategory: json['product_category'],
      productBrand: json['product_brand'],
      productSource: json['product_source'] ?? '',
      productUrl: json['product_url'] ?? '',
      productImageUrl: json['product_image_url'],
      recommendationScore: (json['recommendation_score'] ?? 0.0).toDouble(),
      recommendationReasons: List<String>.from(json['recommendation_reasons'] ?? []),
      recommendationType: json['recommendation_type'] ?? '',
      isViewed: json['is_viewed'] ?? false,
      isClicked: json['is_clicked'] ?? false,
      isPurchased: json['is_purchased'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }

  /// Конвертация в Product для совместимости с существующими компонентами
  Product toProduct() {
    return Product(
      id: productId,
      title: productTitle,
      price: productPrice,
      oldPrice: null,
      discount: null,
      image: productImageUrl,
      link: productUrl,
      source: productSource,
      description: recommendationReasons.join(' • '),
    );
  }
}

/// Модель товара в вишлисте
class WishlistItem {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final int productPrice;
  final String? productCategory;
  final String? productBrand;
  final String productSource;
  final String productUrl;
  final String? productImageUrl;
  final int priority;
  final int? priceAlertThreshold;
  final String? notes;
  final DateTime addedAt;
  final DateTime updatedAt;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    this.productCategory,
    this.productBrand,
    required this.productSource,
    required this.productUrl,
    this.productImageUrl,
    required this.priority,
    this.priceAlertThreshold,
    this.notes,
    required this.addedAt,
    required this.updatedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? '',
      productTitle: json['product_title'] ?? '',
      productPrice: json['product_price'] ?? 0,
      productCategory: json['product_category'],
      productBrand: json['product_brand'],
      productSource: json['product_source'] ?? '',
      productUrl: json['product_url'] ?? '',
      productImageUrl: json['product_image_url'],
      priority: json['priority'] ?? 3,
      priceAlertThreshold: json['price_alert_threshold'],
      notes: json['notes'],
      addedAt: DateTime.parse(json['added_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Конвертация в Product для совместимости
  Product toProduct() {
    return Product(
      id: productId,
      title: productTitle,
      price: productPrice,
      oldPrice: null,
      discount: null,
      image: productImageUrl,
      link: productUrl,
      source: productSource,
      description: notes,
    );
  }
}

/// Сервис для работы с AI-персональным шоппером
class PersonalShopperService {
  final String baseUrl;

  PersonalShopperService({this.baseUrl = 'http://localhost:8080/api/personal-shopper'});

  /// Получение предпочтений пользователя
  Future<UserPreferences?> getUserPreferences(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/preferences/$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserPreferences.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting user preferences: $e');
      return null;
    }
  }

  /// Обновление предпочтений пользователя
  Future<bool> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/preferences/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(preferences),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user preferences: $e');
      return false;
    }
  }

  /// Анализ предпочтений пользователя
  Future<bool> analyzeUserPreferences(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/preferences/$userId/analyze'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error analyzing user preferences: $e');
      return false;
    }
  }

  /// Получение персональных рекомендаций
  Future<List<AIRecommendation>> getPersonalRecommendations(
    String userId, {
    int limit = 20,
    String? category,
    String? type,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      if (type != null) queryParams['type'] = type;
      
      final uri = Uri.parse('$baseUrl/recommendations/$userId')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recommendations = List<Map<String, dynamic>>.from(data['recommendations'] ?? []);
        return recommendations.map((r) => AIRecommendation.fromJson(r)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  /// Генерация новых рекомендаций
  Future<List<AIRecommendation>> generateRecommendations(
    String userId, {
    int limit = 20,
    String? category,
    List<String>? excludeProductIds,
  }) async {
    try {
      final body = <String, dynamic>{
        'limit': limit,
      };
      
      if (category != null) body['category'] = category;
      if (excludeProductIds != null) body['exclude_product_ids'] = excludeProductIds;
      
      final response = await http.post(
        Uri.parse('$baseUrl/recommendations/$userId/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recommendations = List<Map<String, dynamic>>.from(data['recommendations'] ?? []);
        return recommendations.map((r) => AIRecommendation.fromJson(r)).toList();
      }
      return [];
    } catch (e) {
      print('Error generating recommendations: $e');
      return [];
    }
  }

  /// Отметка рекомендации как просмотренной
  Future<bool> markRecommendationViewed(String recId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendations/$recId/viewed'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking recommendation as viewed: $e');
      return false;
    }
  }

  /// Отметка рекомендации как нажатой
  Future<bool> markRecommendationClicked(String recId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendations/$recId/clicked'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking recommendation as clicked: $e');
      return false;
    }
  }

  /// Отметка рекомендации как купленной
  Future<bool> markRecommendationPurchased(String recId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendations/$recId/purchased'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking recommendation as purchased: $e');
      return false;
    }
  }

  /// Получение вишлиста
  Future<List<WishlistItem>> getWishlist(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/wishlist/$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final wishlistItems = List<Map<String, dynamic>>.from(data['wishlist'] ?? []);
        return wishlistItems.map((item) => WishlistItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting wishlist: $e');
      return [];
    }
  }

  /// Добавление товара в вишлист
  Future<bool> addToWishlist(String userId, Product product, {
    int priority = 3,
    int? priceAlertThreshold,
    String? notes,
  }) async {
    try {
      final body = {
        'product_id': product.id,
        'product_title': product.title,
        'product_price': product.price ?? 0,
        'product_category': null, // Можно добавить в модель Product
        'product_brand': null, // Можно добавить в модель Product
        'product_source': product.source ?? 'unknown',
        'product_url': product.link,
        'product_image_url': product.image,
        'priority': priority,
        'price_alert_threshold': priceAlertThreshold,
        'notes': notes,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/wishlist/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  /// Удаление товара из вишлиста
  Future<bool> removeFromWishlist(String userId, String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/wishlist/$userId/$productId'),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error removing from wishlist: $e');
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
      final body = <String, dynamic>{};
      if (priority != null) body['priority'] = priority;
      if (priceAlertThreshold != null) body['price_alert_threshold'] = priceAlertThreshold;
      if (notes != null) body['notes'] = notes;
      
      final response = await http.put(
        Uri.parse('$baseUrl/wishlist/$userId/$productId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating wishlist item: $e');
      return false;
    }
  }

  /// Запись просмотра товара
  Future<bool> recordProductView(String userId, Product product, {
    int viewDuration = 0,
    bool clickedDetails = false,
    bool addedToWishlist = false,
  }) async {
    try {
      final body = {
        'user_id': userId,
        'product_id': product.id,
        'product_title': product.title,
        'product_price': product.price ?? 0,
        'product_category': null, // Можно добавить в модель Product
        'product_brand': null, // Можно добавить в модель Product
        'product_source': product.source ?? 'unknown',
        'view_duration': viewDuration,
        'clicked_details': clickedDetails,
        'added_to_wishlist': addedToWishlist,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/activity/view'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error recording product view: $e');
      return false;
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
      final body = {
        'user_id': userId,
        'product_id': product.id,
        'product_title': product.title,
        'product_price': product.price ?? 0,
        'product_category': null, // Можно добавить в модель Product
        'product_brand': null, // Можно добавить в модель Product
        'product_source': product.source ?? 'unknown',
        'quantity': quantity,
        'total_amount': totalAmount ?? (product.price ?? 0) * quantity,
        'purchase_satisfaction': purchaseSatisfaction,
        'purchase_reason': purchaseReason,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/activity/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error recording purchase: $e');
      return false;
    }
  }

  /// Получение статистики пользователя
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats/$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['stats'];
      }
      return null;
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  /// Получение инсайтов пользователя
  Future<Map<String, dynamic>?> getUserInsights(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/insights/$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['insights'];
      }
      return null;
    } catch (e) {
      print('Error getting user insights: $e');
      return null;
    }
  }
}
