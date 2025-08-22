import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

/// Provider для управления всеми AI сервисами
class AIProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  AIProvider(this._apiService);
  
  // Состояние загрузки
  bool _isLoading = false;
  String? _error;
  
  // AI рекомендации
  List<ProductRecommendation> _personalRecommendations = [];
  List<ProductRecommendation> _similarRecommendations = [];
  List<ProductRecommendation> _newUserRecommendations = [];
  
  // AI контент
  String? _generatedDescription;
  List<String> _generatedHashtags = [];
  String? _generatedSocialMediaPost;
  String? _generatedSEOTitle;
  String? _generatedReview;
  
  // AI анализ стиля
  UserStyleProfile? _userStyleProfile;
  List<StyleRecommendation> _styleRecommendations = [];
  StyleTrends? _styleTrends;
  CapsuleWardrobe? _capsuleWardrobe;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Рекомендации
  List<ProductRecommendation> get personalRecommendations => _personalRecommendations;
  List<ProductRecommendation> get similarRecommendations => _similarRecommendations;
  List<ProductRecommendation> get newUserRecommendations => _newUserRecommendations;
  
  // Контент
  String? get generatedDescription => _generatedDescription;
  List<String> get generatedHashtags => _generatedHashtags;
  String? get generatedSocialMediaPost => _generatedSocialMediaPost;
  String? get generatedSEOTitle => _generatedSEOTitle;
  String? get generatedReview => _generatedReview;
  
  // Стиль
  UserStyleProfile? get userStyleProfile => _userStyleProfile;
  List<StyleRecommendation> get styleRecommendations => _styleRecommendations;
  StyleTrends? get styleTrends => _styleTrends;
  CapsuleWardrobe? get capsuleWardrobe => _capsuleWardrobe;
  
  /// Очистка ошибок
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Сброс состояния
  void reset() {
    _personalRecommendations = [];
    _similarRecommendations = [];
    _newUserRecommendations = [];
    _generatedDescription = null;
    _generatedHashtags = [];
    _generatedSocialMediaPost = null;
    _generatedSEOTitle = null;
    _generatedReview = null;
    _userStyleProfile = null;
    _styleRecommendations = [];
    _styleTrends = null;
    _capsuleWardrobe = null;
    _error = null;
    notifyListeners();
  }
  
  // ===== AI РЕКОМЕНДАЦИИ =====
  
  /// Получение персональных рекомендаций
  Future<void> getPersonalRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.getPersonalRecommendations(
        userId: userId,
        limit: limit,
      );
      
      if (response.success) {
        _personalRecommendations = response.data['recommendations']
            .map<ProductRecommendation>((json) => ProductRecommendation.fromJson(json))
            .toList();
      } else {
        _setError('Failed to get personal recommendations');
      }
      
    } catch (e) {
      _setError('Error getting personal recommendations: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получение рекомендаций похожих товаров
  Future<void> getSimilarProductRecommendations({
    required String productId,
    int limit = 8,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.getSimilarProductRecommendations(
        productId: productId,
        limit: limit,
      );
      
      if (response.success) {
        _similarRecommendations = response.data['recommendations']
            .map<ProductRecommendation>((json) => ProductRecommendation.fromJson(json))
            .toList();
      } else {
        _setError('Failed to get similar product recommendations');
      }
      
    } catch (e) {
      _setError('Error getting similar product recommendations: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получение рекомендаций для новых пользователей
  Future<void> getNewUserRecommendations({
    String? location,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.getNewUserRecommendations(
        location: location,
        limit: limit,
      );
      
      if (response.success) {
        _newUserRecommendations = response.data['recommendations']
            .map<ProductRecommendation>((json) => ProductRecommendation.fromJson(json))
            .toList();
      } else {
        _setError('Failed to get new user recommendations');
      }
      
    } catch (e) {
      _setError('Error getting new user recommendations: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== AI ГЕНЕРАЦИЯ КОНТЕНТА =====
  
  /// Генерация описания товара
  Future<void> generateProductDescription({
    required String productName,
    required String category,
    required Map<String, dynamic> specifications,
    String? brand,
    String? style,
    String? targetAudience,
    int? price,
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.generateProductDescription(
        productName: productName,
        category: category,
        specifications: specifications,
        brand: brand,
        style: style,
        targetAudience: targetAudience,
        price: price,
        language: language,
      );
      
      if (response.success) {
        _generatedDescription = response.data['description']['content'];
      } else {
        _setError('Failed to generate product description');
      }
      
    } catch (e) {
      _setError('Error generating product description: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Генерация хештегов
  Future<void> generateProductHashtags({
    required String productName,
    required String category,
    String? brand,
    String? style,
    String? targetAudience,
    int hashtagCount = 8,
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.generateProductHashtags(
        productName: productName,
        category: category,
        brand: brand,
        style: style,
        targetAudience: targetAudience,
        hashtagCount: hashtagCount,
        language: language,
      );
      
      if (response.success) {
        _generatedHashtags = List<String>.from(response.data['hashtags']);
      } else {
        _setError('Failed to generate hashtags');
      }
      
    } catch (e) {
      _setError('Error generating hashtags: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Генерация поста для соцсети
  Future<void> generateSocialMediaPost({
    required String productName,
    required String category,
    required String productDescription,
    String? brand,
    String? style,
    String? targetAudience,
    String platform = 'instagram',
    String tone = 'casual',
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.generateSocialMediaPost(
        productName: productName,
        category: category,
        productDescription: productDescription,
        brand: brand,
        style: style,
        targetAudience: targetAudience,
        platform: platform,
        tone: tone,
        language: language,
      );
      
      if (response.success) {
        _generatedSocialMediaPost = response.data['post']['caption'];
        _generatedHashtags = List<String>.from(response.data['post']['hashtags']);
      } else {
        _setError('Failed to generate social media post');
      }
      
    } catch (e) {
      _setError('Error generating social media post: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Генерация SEO заголовка
  Future<void> generateSEOOptimizedTitle({
    required String productName,
    required String category,
    String? brand,
    String? style,
    String? keyFeatures,
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.generateSEOOptimizedTitle(
        productName: productName,
        category: category,
        brand: brand,
        style: style,
        keyFeatures: keyFeatures,
        language: language,
      );
      
      if (response.success) {
        _generatedSEOTitle = response.data['title'];
      } else {
        _setError('Failed to generate SEO title');
      }
      
    } catch (e) {
      _setError('Error generating SEO title: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Генерация отзыва
  Future<void> generateProductReview({
    required String productName,
    required String category,
    required int rating,
    String? brand,
    String? style,
    String? pros,
    String? cons,
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.generateProductReview(
        productName: productName,
        category: category,
        rating: rating,
        brand: brand,
        style: style,
        pros: pros,
        cons: cons,
        language: language,
      );
      
      if (response.success) {
        _generatedReview = response.data['review']['content'];
      } else {
        _setError('Failed to generate product review');
      }
      
    } catch (e) {
      _setError('Error generating product review: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== AI АНАЛИЗ СТИЛЯ =====
  
  /// Анализ стиля пользователя
  Future<void> analyzeUserStyle({
    required String userId,
    List<Product>? purchaseHistory,
    List<Product>? wishlist,
    List<Product>? recentlyViewed,
    String? userPreferences,
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.analyzeUserStyle(
        userId: userId,
        purchaseHistory: purchaseHistory ?? [],
        wishlist: wishlist ?? [],
        recentlyViewed: recentlyViewed ?? [],
        userPreferences: userPreferences,
        language: language,
      );
      
      if (response.success) {
        _userStyleProfile = UserStyleProfile.fromJson(response.data['style_profile']);
      } else {
        _setError('Failed to analyze user style');
      }
      
    } catch (e) {
      _setError('Error analyzing user style: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Анализ совместимости стилей
  Future<StyleCompatibility?> analyzeStyleCompatibility({
    required String userStyle,
    required String productStyle,
    required Map<String, dynamic> productAttributes,
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.analyzeStyleCompatibility(
        userStyle: userStyle,
        productStyle: productStyle,
        productAttributes: productAttributes,
        language: language,
      );
      
      if (response.success) {
        return StyleCompatibility.fromJson(response.data['compatibility']);
      } else {
        _setError('Failed to analyze style compatibility');
        return null;
      }
      
    } catch (e) {
      _setError('Error analyzing style compatibility: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Генерация рекомендаций по стилю
  Future<void> generateStyleRecommendations({
    required String userId,
    required String occasion,
    required String season,
    int limit = 10,
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.generateStyleRecommendations(
        userId: userId,
        occasion: occasion,
        season: season,
        limit: limit,
        language: language,
      );
      
      if (response.success) {
        _styleRecommendations = response.data['recommendations']
            .map<StyleRecommendation>((json) => StyleRecommendation.fromJson(json))
            .toList();
      } else {
        _setError('Failed to generate style recommendations');
      }
      
    } catch (e) {
      _setError('Error generating style recommendations: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Анализ трендов стиля
  Future<void> analyzeStyleTrends({
    required String category,
    required String season,
    String? location,
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.analyzeStyleTrends(
        category: category,
        season: season,
        location: location,
        language: language,
      );
      
      if (response.success) {
        _styleTrends = StyleTrends.fromJson(response.data['trends']);
      } else {
        _setError('Failed to analyze style trends');
      }
      
    } catch (e) {
      _setError('Error analyzing style trends: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Создание капсульного гардероба
  Future<void> createCapsuleWardrobe({
    required String userId,
    required String occasion,
    required String season,
    required int itemCount,
    String language = 'ru',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.createCapsuleWardrobe(
        userId: userId,
        occasion: occasion,
        season: season,
        itemCount: itemCount,
        language: language,
      );
      
      if (response.success) {
        _capsuleWardrobe = CapsuleWardrobe.fromJson(response.data['wardrobe']);
      } else {
        _setError('Failed to create capsule wardrobe');
      }
      
    } catch (e) {
      _setError('Error creating capsule wardrobe: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ =====
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
}

// ===== МОДЕЛИ ДАННЫХ =====

/// Рекомендация продукта
class ProductRecommendation {
  final Product product;
  final double score;
  final String reason;
  
  ProductRecommendation({
    required this.product,
    required this.score,
    required this.reason,
  });
  
  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      product: Product.fromJson(json['product']),
      score: json['score']?.toDouble() ?? 0.0,
      reason: json['reason'] ?? '',
    );
  }
}

/// Профиль стиля пользователя
class UserStyleProfile {
  final String userId;
  final String primaryStyle;
  final List<String> secondaryStyles;
  final List<String> colorPalette;
  final List<String> brandPreferences;
  final PriceRange priceRange;
  final List<String> occasionPreferences;
  final List<String> seasonPreferences;
  final double styleConfidence;
  final String aiInsights;
  final DateTime lastUpdated;
  
  UserStyleProfile({
    required this.userId,
    required this.primaryStyle,
    required this.secondaryStyles,
    required this.colorPalette,
    required this.brandPreferences,
    required this.priceRange,
    required this.occasionPreferences,
    required this.seasonPreferences,
    required this.styleConfidence,
    required this.aiInsights,
    required this.lastUpdated,
  });
  
  factory UserStyleProfile.fromJson(Map<String, dynamic> json) {
    return UserStyleProfile(
      userId: json['user_id'] ?? '',
      primaryStyle: json['primary_style'] ?? 'casual',
      secondaryStyles: List<String>.from(json['secondary_styles'] ?? []),
      colorPalette: List<String>.from(json['color_palette'] ?? []),
      brandPreferences: List<String>.from(json['brand_preferences'] ?? []),
      priceRange: PriceRange.fromJson(json['price_range'] ?? {}),
      occasionPreferences: List<String>.from(json['occasion_preferences'] ?? []),
      seasonPreferences: List<String>.from(json['season_preferences'] ?? []),
      styleConfidence: json['style_confidence']?.toDouble() ?? 0.0,
      aiInsights: json['ai_insights'] ?? '',
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Ценовой диапазон
class PriceRange {
  final int min;
  final int max;
  final int average;
  
  PriceRange({
    required this.min,
    required this.max,
    required this.average,
  });
  
  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: json['min'] ?? 0,
      max: json['max'] ?? 0,
      average: json['average'] ?? 0,
    );
  }
}

/// Совместимость стилей
class StyleCompatibility {
  final String userStyle;
  final String productStyle;
  final double score;
  final String reason;
  final List<String> styleTips;
  
  StyleCompatibility({
    required this.userStyle,
    required this.productStyle,
    required this.score,
    required this.reason,
    required this.styleTips,
  });
  
  factory StyleCompatibility.fromJson(Map<String, dynamic> json) {
    return StyleCompatibility(
      userStyle: json['user_style'] ?? '',
      productStyle: json['product_style'] ?? '',
      score: json['score']?.toDouble() ?? 0.0,
      reason: json['reason'] ?? '',
      styleTips: List<String>.from(json['style_tips'] ?? []),
    );
  }
}

/// Рекомендация по стилю
class StyleRecommendation {
  final Product product;
  final double styleScore;
  final String compatibilityReason;
  final String occasion;
  final String season;
  final List<String> styleTips;
  
  StyleRecommendation({
    required this.product,
    required this.styleScore,
    required this.compatibilityReason,
    required this.occasion,
    required this.season,
    required this.styleTips,
  });
  
  factory StyleRecommendation.fromJson(Map<String, dynamic> json) {
    return StyleRecommendation(
      product: Product.fromJson(json['product']),
      styleScore: json['style_score']?.toDouble() ?? 0.0,
      compatibilityReason: json['compatibility_reason'] ?? '',
      occasion: json['occasion'] ?? '',
      season: json['season'] ?? '',
      styleTips: List<String>.from(json['style_tips'] ?? []),
    );
  }
}

/// Тренды стиля
class StyleTrends {
  final String category;
  final String season;
  final String trends;
  final List<String> colors;
  final List<String> materials;
  final List<String> styles;
  final List<String> recommendations;
  final DateTime analyzedAt;
  
  StyleTrends({
    required this.category,
    required this.season,
    required this.trends,
    required this.colors,
    required this.materials,
    required this.styles,
    required this.recommendations,
    required this.analyzedAt,
  });
  
  factory StyleTrends.fromJson(Map<String, dynamic> json) {
    return StyleTrends(
      category: json['category'] ?? '',
      season: json['season'] ?? '',
      trends: json['trends'] ?? '',
      colors: List<String>.from(json['colors'] ?? []),
      materials: List<String>.from(json['materials'] ?? []),
      styles: List<String>.from(json['styles'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      analyzedAt: DateTime.parse(json['analyzed_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Капсульный гардероб
class CapsuleWardrobe {
  final String userId;
  final String occasion;
  final String season;
  final List<WardrobeItem> items;
  final String description;
  final DateTime createdAt;
  
  CapsuleWardrobe({
    required this.userId,
    required this.occasion,
    required this.season,
    required this.items,
    required this.description,
    required this.createdAt,
  });
  
  factory CapsuleWardrobe.fromJson(Map<String, dynamic> json) {
    return CapsuleWardrobe(
      userId: json['user_id'] ?? '',
      occasion: json['occasion'] ?? '',
      season: json['season'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => WardrobeItem.fromJson(item))
          .toList(),
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Вещь в гардеробе
class WardrobeItem {
  final String name;
  final String description;
  final String category;
  
  WardrobeItem({
    required this.name,
    required this.description,
    required this.category,
  });
  
  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
