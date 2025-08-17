import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logger/logger.dart';
import '../services/ai_service.dart';
import '../models.dart';

class AIHandler {
  final AIService _aiService;
  final Logger _logger = Logger();

  AIHandler(this._aiService);

  Router get router {
    final router = Router();

    // AI рекомендации для пользователя
    router.get('/recommendations/<userId>', _getUserRecommendations);
    
    // Генерация описания товара
    router.post('/generate-description', _generateProductDescription);
    
    // AI анализ пользовательских предпочтений
    router.get('/preferences/<userId>', _analyzeUserPreferences);
    
    // Генерация хештегов для постов
    router.post('/generate-hashtags', _generateHashtags);
    
    // AI модерация контента
    router.post('/moderate-content', _moderateContent);
    
    // Генерация персонализированных предложений
    router.post('/personalized-offers', _generatePersonalizedOffers);
    
    // AI анализ трендов
    router.get('/trends', _analyzeTrends);

    return router;
  }

  /// Получение AI рекомендаций для пользователя
  Future<Response> _getUserRecommendations(Request request, String userId) async {
    try {
      _logger.i('Getting AI recommendations for user: $userId');
      
      // В реальном приложении здесь будет получение данных из базы
      // Пока используем тестовые данные
      final userHistory = _getMockUserHistory();
      final availableProducts = _getMockAvailableProducts();
      
      final recommendations = await _aiService.generateRecommendations(
        userId: userId,
        userHistory: userHistory,
        availableProducts: availableProducts,
        limit: 10,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'recommendations': recommendations.map((r) => {
              return {
                'product': {
                  'id': r.product.id,
                  'title': r.product.title,
                  'price': r.product.price,
                  'image_url': r.product.imageUrl,
                  'brand': r.product.brand,
                  'rating': r.product.rating,
                },
                'score': r.score,
                'reason': r.reason,
              };
            }).toList(),
            'total': recommendations.length,
            'generated_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting AI recommendations: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get AI recommendations: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Генерация описания товара с помощью AI
  Future<Response> _generateProductDescription(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final productName = data['product_name'] as String;
      final category = data['category'] as String;
      final specifications = Map<String, dynamic>.from(data['specifications'] ?? {});
      final style = data['style'] as String?;
      
      _logger.i('Generating AI description for product: $productName');
      
      final description = await _aiService.generateProductDescription(
        productName: productName,
        category: category,
        specifications: specifications,
        style: style,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'product_name': productName,
            'category': category,
            'generated_description': description,
            'generated_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error generating product description: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to generate product description: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Анализ пользовательских предпочтений
  Future<Response> _analyzeUserPreferences(Request request, String userId) async {
    try {
      _logger.i('Analyzing preferences for user: $userId');
      
      // В реальном приложении здесь будет получение данных из базы
      final userHistory = _getMockUserHistory();
      
      final preferences = await _aiService.generateRecommendations(
        userId: userId,
        userHistory: userHistory,
        availableProducts: [],
        limit: 0,
      );
      
      // Анализируем предпочтения на основе истории
      final categoryPreferences = <String, int>{};
      final brandPreferences = <String, int>{};
      final priceRange = <int>[];
      
      for (final product in userHistory) {
        if (product.categoryId != null) {
          categoryPreferences[product.categoryId!] = 
              (categoryPreferences[product.categoryId!] ?? 0) + 1;
        }
        
        if (product.brand != null) {
          brandPreferences[product.brand!] = 
              (brandPreferences[product.brand!] ?? 0) + 1;
        }
        
        priceRange.add(product.price);
      }
      
      final avgPrice = priceRange.isNotEmpty 
          ? priceRange.reduce((a, b) => a + b) / priceRange.length 
          : 0;
      
      final topCategories = _getTopItems(categoryPreferences, 5);
      final topBrands = _getTopItems(brandPreferences, 5);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'user_id': userId,
            'preferences': {
              'top_categories': topCategories,
              'top_brands': topBrands,
              'average_price': avgPrice.round(),
              'price_range': {
                'min': priceRange.isNotEmpty ? priceRange.reduce((a, b) => a < b ? a : b) : 0,
                'max': priceRange.isNotEmpty ? priceRange.reduce((a, b) => a > b ? a : b) : 0,
                'average': avgPrice.round(),
              },
              'total_purchases': userHistory.length,
            },
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error analyzing user preferences: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to analyze user preferences: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Генерация хештегов для постов
  Future<Response> _generateHashtags(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final content = data['content'] as String;
      final category = data['category'] as String;
      final limit = data['limit'] as int? ?? 5;
      
      _logger.i('Generating hashtags for content in category: $category');
      
      // В реальном приложении здесь будет вызов AI сервиса
      // Пока используем простую логику
      final hashtags = _generateMockHashtags(content, category, limit);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
          'content': content,
          'category': category,
            'hashtags': hashtags,
            'generated_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error generating hashtags: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to generate hashtags: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// AI модерация контента
  Future<Response> _moderateContent(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final content = data['content'] as String;
      final contentType = data['content_type'] as String; // 'post', 'comment', 'product'
      
      _logger.i('Moderating content of type: $contentType');
      
      // В реальном приложении здесь будет вызов AI сервиса для модерации
      // Пока используем простую логику
      final moderationResult = _mockContentModeration(content, contentType);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'content': content,
            'content_type': contentType,
            'moderation': moderationResult,
            'moderated_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error moderating content: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to moderate content: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Генерация персонализированных предложений
  Future<Response> _generatePersonalizedOffers(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final userId = data['user_id'] as String;
      final offerType = data['offer_type'] as String; // 'discount', 'bundle', 'loyalty'
      
      _logger.i('Generating personalized offers for user: $userId, type: $offerType');
      
      // В реальном приложении здесь будет AI анализ и генерация предложений
      final offers = _generateMockPersonalizedOffers(userId, offerType);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'user_id': userId,
            'offer_type': offerType,
            'offers': offers,
            'generated_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error generating personalized offers: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to generate personalized offers: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// AI анализ трендов
  Future<Response> _analyzeTrends(Request request) async {
    try {
      _logger.i('Analyzing fashion trends');
      
      // В реальном приложении здесь будет AI анализ трендов
      final trends = _generateMockTrends();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'trends': trends,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error analyzing trends: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to analyze trends: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Вспомогательные методы для тестовых данных

  List<Product> _getMockUserHistory() {
    return [
      Product(
        id: '1',
        title: 'Nike Air Max 270',
        description: 'Стильные кроссовки',
        price: 12990,
        imageUrl: 'https://example.com/nike.jpg',
        productUrl: 'https://example.com/nike',
        brand: 'Nike',
        categoryId: 'footwear',
        rating: 4.8,
      ),
      Product(
        id: '2',
        title: 'Levi\'s 501 Jeans',
        description: 'Классические джинсы',
        price: 7990,
        imageUrl: 'https://example.com/levis.jpg',
        productUrl: 'https://example.com/levis',
        brand: 'Levi\'s',
        categoryId: 'clothing',
        rating: 4.6,
      ),
    ];
  }

  List<Product> _getMockAvailableProducts() {
    return [
      Product(
        id: '3',
        title: 'Adidas Ultraboost 22',
        description: 'Беговые кроссовки',
        price: 18990,
        imageUrl: 'https://example.com/adidas.jpg',
        productUrl: 'https://example.com/adidas',
        brand: 'Adidas',
        categoryId: 'footwear',
        rating: 4.9,
      ),
      Product(
        id: '4',
        title: 'Apple Watch Series 8',
        description: 'Умные часы',
        price: 45990,
        imageUrl: 'https://example.com/apple.jpg',
        productUrl: 'https://example.com/apple',
        brand: 'Apple',
        categoryId: 'accessories',
        rating: 4.7,
      ),
    ];
  }

  List<String> _getTopItems(Map<String, int> items, int count) {
    final sorted = items.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(count).map((e) => e.key).toList();
  }

  List<String> _generateMockHashtags(String content, String category, int limit) {
    final baseHashtags = ['MyModusLook', 'FashionStyle', 'TrendyOutfit'];
    final categoryHashtags = {
      'footwear': ['ShoeGame', 'Kicks', 'SneakerHead'],
      'clothing': ['OOTD', 'FashionForward', 'StyleInspo'],
      'accessories': ['Accessorize', 'Jewelry', 'Bags'],
    };
    
    final allHashtags = [...baseHashtags, ...(categoryHashtags[category] ?? [])];
    return allHashtags.take(limit).toList();
  }

  Map<String, dynamic> _mockContentModeration(String content, String contentType) {
    // Простая логика модерации
    final hasSpam = content.toLowerCase().contains('buy now') || 
                     content.toLowerCase().contains('click here');
    final hasInappropriate = content.toLowerCase().contains('bad word');
    
    return {
      'is_approved': !hasSpam && !hasInappropriate,
      'flags': {
        'spam': hasSpam,
        'inappropriate': hasInappropriate,
      },
      'confidence': 0.95,
      'recommendation': (!hasSpam && !hasInappropriate) ? 'approve' : 'review',
    };
  }

  List<Map<String, dynamic>> _generateMockPersonalizedOffers(String userId, String offerType) {
    switch (offerType) {
      case 'discount':
        return [
          {
            'type': 'discount',
            'value': 15,
            'description': 'Скидка 15% на обувь Nike',
            'valid_until': DateTime.now().add(Duration(days: 7)).toIso8601String(),
          },
        ];
      case 'bundle':
        return [
          {
            'type': 'bundle',
            'description': 'Комплект: джинсы + футболка со скидкой 20%',
            'savings': 2500,
            'valid_until': DateTime.now().add(Duration(days: 14)).toIso8601String(),
          },
        ];
      case 'loyalty':
        return [
          {
            'type': 'loyalty',
            'description': 'Бонусные баллы за покупку',
            'points': 500,
            'valid_until': DateTime.now().add(Duration(days: 30)).toIso8601String(),
          },
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _generateMockTrends() {
    return [
      {
        'trend': 'Sustainable Fashion',
        'confidence': 0.92,
        'description': 'Растущий интерес к экологичной моде',
        'products_count': 150,
        'growth_rate': '+25%',
      },
      {
        'trend': 'Athleisure',
        'confidence': 0.88,
        'description': 'Спортивная одежда для повседневной носки',
        'products_count': 89,
        'growth_rate': '+18%',
      },
      {
        'trend': 'Vintage Revival',
        'confidence': 0.85,
        'description': 'Возвращение винтажных стилей',
        'products_count': 67,
        'growth_rate': '+12%',
      },
    ];
  }
}
