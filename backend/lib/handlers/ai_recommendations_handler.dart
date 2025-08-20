import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import '../services/ai_recommendations_service.dart';
import '../models.dart';
import '../database/database_service.dart';

/// API Handler для AI рекомендаций продуктов
class AIRecommendationsHandler {
  final AIRecommendationsService _aiService;
  final DatabaseService _databaseService;
  
  AIRecommendationsHandler({
    AIRecommendationsService? aiService,
    DatabaseService? databaseService,
  }) : _aiService = aiService ?? AIRecommendationsService(),
       _databaseService = databaseService ?? DatabaseService();

  /// Получить роутер для рекомендаций
  Router get router {
    final router = Router();
    
    // Получить персональные рекомендации для пользователя
    router.get('/personal/<userId>', _getPersonalRecommendations);
    
    // Получить рекомендации похожих товаров
    router.get('/similar/<productId>', _getSimilarProductRecommendations);
    
    // Получить рекомендации для новых пользователей
    router.get('/new-user', _getNewUserRecommendations);
    
    // Получить предпочтения пользователя
    router.get('/preferences/<userId>', _getUserPreferences);
    
    // Обновить предпочтения пользователя
    router.post('/preferences/<userId>', _updateUserPreferences);
    
    // Получить статистику рекомендаций
    router.get('/stats', _getRecommendationsStats);
    
    return router;
  }

  /// Получить персональные рекомендации для пользователя
  Future<Response> _getPersonalRecommendations(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }

      // Получаем параметры запроса
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;
      
      // Получаем историю покупок пользователя
      final userHistory = await _getUserPurchaseHistory(userId);
      
      // Получаем недавно просмотренные товары
      final recentlyViewed = await _getUserRecentlyViewed(userId);
      
      // Получаем доступные товары
      final availableProducts = await _getAvailableProducts();
      
      // Генерируем персональные рекомендации
      final recommendations = await _aiService.generatePersonalRecommendations(
        userId: userId,
        userHistory: userHistory,
        availableProducts: availableProducts,
        recentlyViewed: recentlyViewed,
        limit: limit,
      );
      
      return Response(200, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': true,
          'data': {
            'recommendations': recommendations.map((r) => {
              'product': r.product.toJson(),
              'score': r.score,
              'reason': r.reason,
            }).toList(),
            'total': recommendations.length,
            'user_id': userId,
            'generated_at': DateTime.now().toIso8601String(),
          }
        })
      );
      
    } catch (e) {
      return Response(500, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': false,
          'error': 'Failed to generate personal recommendations: $e'
        })
      );
    }
  }

  /// Получить рекомендации похожих товаров
  Future<Response> _getSimilarProductRecommendations(Request request) async {
    try {
      final productId = request.params['productId'];
      if (productId == null) {
        return Response(400, body: jsonEncode({'error': 'Product ID is required'}));
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '8') ?? 8;
      
      // Получаем базовый товар
      final baseProduct = await _getProductById(productId);
      if (baseProduct == null) {
        return Response(404, 
          body: jsonEncode({'error': 'Product not found'})
        );
      }
      
      // Получаем доступные товары
      final availableProducts = await _getAvailableProducts();
      
      // Генерируем рекомендации похожих товаров
      final recommendations = await _aiService.generateSimilarProductRecommendations(
        baseProduct: baseProduct,
        availableProducts: availableProducts,
        limit: limit,
      );
      
      return Response(200, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': true,
          'data': {
            'base_product': baseProduct.toJson(),
            'recommendations': recommendations.map((r) => {
              'product': r.product.toJson(),
              'score': r.score,
              'reason': r.reason,
            }).toList(),
            'total': recommendations.length,
            'generated_at': DateTime.now().toIso8601String(),
          }
        })
      );
      
    } catch (e) {
      return Response(500, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': false,
          'error': 'Failed to generate similar product recommendations: $e'
        })
      );
    }
  }

  /// Получить рекомендации для новых пользователей
  Future<Response> _getNewUserRecommendations(Request request) async {
    try {
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;
      final userLocation = request.url.queryParameters['location'];
      
      // Получаем доступные товары
      final availableProducts = await _getAvailableProducts();
      
      // Генерируем рекомендации для новых пользователей
      final recommendations = await _aiService.generateNewUserRecommendations(
        availableProducts: availableProducts,
        userLocation: userLocation,
        limit: limit,
      );
      
      return Response(200, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': true,
          'data': {
            'recommendations': recommendations.map((r) => {
              'product': r.product.toJson(),
              'score': r.score,
              'reason': r.reason,
            }).toList(),
            'total': recommendations.length,
            'type': 'new_user',
            'generated_at': DateTime.now().toIso8601String(),
          }
        })
      );
      
    } catch (e) {
      return Response(500, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': false,
          'error': 'Failed to generate new user recommendations: $e'
        })
      );
    }
  }

  /// Получить предпочтения пользователя
  Future<Response> _getUserPreferences(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }
      
      // Получаем историю покупок и просмотров
      final userHistory = await _getUserPurchaseHistory(userId);
      final recentlyViewed = await _getUserRecentlyViewed(userId);
      
      // Анализируем предпочтения
      final preferences = await _aiService._analyzeUserPreferences(
        userHistory, 
        recentlyViewed
      );
      
      return Response(200, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': true,
          'data': {
            'user_id': userId,
            'preferences': {
              'top_categories': preferences.topCategories,
              'top_brands': preferences.topBrands,
              'top_styles': preferences.topStyles,
              'top_colors': preferences.topColors,
              'average_price': preferences.averagePrice,
              'total_purchases': preferences.totalPurchases,
              'total_viewed': preferences.totalViewed,
            },
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        })
      );
      
    } catch (e) {
      return Response(500, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get user preferences: $e'
        })
      );
    }
  }

  /// Обновить предпочтения пользователя
  Future<Response> _updateUserPreferences(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }
      
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      // Здесь можно добавить логику для обновления предпочтений
      // Например, сохранение в базу данных или кэш
      
      return Response(200, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': true,
          'message': 'User preferences updated successfully',
          'user_id': userId,
          'updated_at': DateTime.now().toIso8601String(),
        })
      );
      
    } catch (e) {
      return Response(500, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': false,
          'error': 'Failed to update user preferences: $e'
        })
      );
    }
  }

  /// Получить статистику рекомендаций
  Future<Response> _getRecommendationsStats(Request request) async {
    try {
      // Получаем общую статистику по рекомендациям
      final totalProducts = await _getTotalProducts();
      final totalUsers = await _getTotalUsers();
      final totalRecommendations = await _getTotalRecommendations();
      
      return Response(200, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': true,
          'data': {
            'stats': {
              'total_products': totalProducts,
              'total_users': totalUsers,
              'total_recommendations_generated': totalRecommendations,
              'ai_service_status': 'active',
              'last_updated': DateTime.now().toIso8601String(),
            }
          }
        })
      );
      
    } catch (e) {
      return Response(500, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get recommendations stats: $e'
        })
      );
    }
  }

  // Вспомогательные методы для работы с базой данных

  /// Получить историю покупок пользователя
  Future<List<Product>> _getUserPurchaseHistory(String userId) async {
    try {
      // Здесь должна быть логика получения истории покупок
      // Пока возвращаем пустой список
      return [];
    } catch (e) {
      print('Error getting user purchase history: $e');
      return [];
    }
  }

  /// Получить недавно просмотренные товары пользователя
  Future<List<Product>> _getUserRecentlyViewed(String userId) async {
    try {
      // Здесь должна быть логика получения недавно просмотренных товаров
      // Пока возвращаем пустой список
      return [];
    } catch (e) {
      print('Error getting user recently viewed: $e');
      return [];
    }
  }

  /// Получить доступные товары
  Future<List<Product>> _getAvailableProducts() async {
    try {
      // Здесь должна быть логика получения доступных товаров
      // Пока возвращаем пустой список
      return [];
    } catch (e) {
      print('Error getting available products: $e');
      return [];
    }
  }

  /// Получить товар по ID
  Future<Product?> _getProductById(String productId) async {
    try {
      // Здесь должна быть логика получения товара по ID
      // Пока возвращаем null
      return null;
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  /// Получить общее количество товаров
  Future<int> _getTotalProducts() async {
    try {
      // Здесь должна быть логика подсчета товаров
      return 0;
    } catch (e) {
      print('Error getting total products: $e');
      return 0;
    }
  }

  /// Получить общее количество пользователей
  Future<int> _getTotalUsers() async {
    try {
      // Здесь должна быть логика подсчета пользователей
      return 0;
    } catch (e) {
      print('Error getting total users: $e');
      return 0;
    }
  }

  /// Получить общее количество сгенерированных рекомендаций
  Future<int> _getTotalRecommendations() async {
    try {
      // Здесь должна быть логика подсчета рекомендаций
      return 0;
    } catch (e) {
      print('Error getting total recommendations: $e');
      return 0;
    }
  }
}
