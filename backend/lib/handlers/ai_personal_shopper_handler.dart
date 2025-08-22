import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logger/logger.dart';
import '../database.dart';
import '../services/ai_personal_shopper_service.dart';
import '../services/ai_service.dart';
import '../models.dart';

/// API Handler для AI-персонального шоппера
class AIPersonalShopperHandler {
  final AIPersonalShopperService personalShopperService;
  final DatabaseService db;
  final Logger logger = Logger();
  final Router router = Router();

  AIPersonalShopperHandler({
    required this.personalShopperService,
    required this.db,
  }) {
    _setupRoutes();
  }

  void _setupRoutes() {
    // Предпочтения пользователя
    router.get('/preferences/<userId>', _getUserPreferences);
    router.post('/preferences/<userId>', _updateUserPreferences);
    router.post('/preferences/<userId>/analyze', _analyzeUserPreferences);
    
    // Рекомендации
    router.get('/recommendations/<userId>', _getPersonalRecommendations);
    router.post('/recommendations/<userId>/generate', _generateRecommendations);
    router.post('/recommendations/<recId>/viewed', _markRecommendationViewed);
    router.post('/recommendations/<recId>/clicked', _markRecommendationClicked);
    router.post('/recommendations/<recId>/purchased', _markRecommendationPurchased);
    
    // Вишлист
    router.get('/wishlist/<userId>', _getWishlist);
    router.post('/wishlist/<userId>', _addToWishlist);
    router.delete('/wishlist/<userId>/<productId>', _removeFromWishlist);
    router.put('/wishlist/<userId>/<productId>', _updateWishlistItem);
    
    // Активность пользователя
    router.post('/activity/view', _recordProductView);
    router.post('/activity/purchase', _recordPurchase);
    
    // Анализ трендов
    router.get('/trends/<userId>/<analysisType>', _getUserTrends);
    router.post('/trends/<userId>/<analysisType>/analyze', _analyzeUserTrends);
    
    // Статистика и аналитика
    router.get('/stats/<userId>', _getUserStats);
    router.get('/insights/<userId>', _getUserInsights);
  }

  /// Получение предпочтений пользователя
  Future<Response> _getUserPreferences(Request request) async {
    try {
      final userId = request.params['userId']!;
      
      logger.i('Getting preferences for user: $userId');
      
      final preferences = await personalShopperService.getUserPreferences(userId);
      
      return Response.ok(
        jsonEncode(preferences.toJson()),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error getting user preferences: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get user preferences', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Обновление предпочтений пользователя
  Future<Response> _updateUserPreferences(Request request) async {
    try {
      final userId = request.params['userId']!;
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      logger.i('Updating preferences for user: $userId');
      
      // Получаем текущие предпочтения
      final currentPreferences = await personalShopperService.getUserPreferences(userId);
      
      // Обновляем только переданные поля
      final updatedPreferences = UserPreferences(
        id: currentPreferences.id,
        userId: userId,
        categoryPreferences: Map<String, double>.from(
          data['category_preferences'] ?? currentPreferences.categoryPreferences
        ),
        brandPreferences: Map<String, double>.from(
          data['brand_preferences'] ?? currentPreferences.brandPreferences
        ),
        priceRange: Map<String, int>.from(
          data['price_range'] ?? currentPreferences.priceRange
        ),
        sizePreferences: Map<String, String>.from(
          data['size_preferences'] ?? currentPreferences.sizePreferences
        ),
        colorPreferences: List<String>.from(
          data['color_preferences'] ?? currentPreferences.colorPreferences
        ),
        stylePreferences: List<String>.from(
          data['style_preferences'] ?? currentPreferences.stylePreferences
        ),
        seasonalPreferences: Map<String, String>.from(
          data['seasonal_preferences'] ?? currentPreferences.seasonalPreferences
        ),
        shoppingFrequency: Map<String, int>.from(
          data['shopping_frequency'] ?? currentPreferences.shoppingFrequency
        ),
        budgetMonthly: data['budget_monthly'] ?? currentPreferences.budgetMonthly,
        preferredMarketplaces: List<String>.from(
          data['preferred_marketplaces'] ?? currentPreferences.preferredMarketplaces
        ),
        createdAt: currentPreferences.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await personalShopperService.updateUserPreferences(updatedPreferences);
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Preferences updated successfully'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error updating user preferences: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update preferences', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Анализ предпочтений пользователя на основе истории
  Future<Response> _analyzeUserPreferences(Request request) async {
    try {
      final userId = request.params['userId']!;
      
      logger.i('Analyzing preferences for user: $userId');
      
      final preferences = await personalShopperService.analyzeUserPreferences(userId);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Preferences analyzed successfully',
          'preferences': preferences.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error analyzing user preferences: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to analyze preferences', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение персональных рекомендаций
  Future<Response> _getPersonalRecommendations(Request request) async {
    try {
      final userId = request.params['userId']!;
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final category = request.url.queryParameters['category'];
      final type = request.url.queryParameters['type'];
      
      logger.i('Getting recommendations for user: $userId');
      
      // Получаем существующие рекомендации из базы
      final whereConditions = ['user_id = \$1', 'expires_at > \$2'];
      final parameters = [userId, DateTime.now()];
      
      if (category != null) {
        whereConditions.add('product_category = \$${parameters.length + 1}');
        parameters.add(category);
      }
      
      if (type != null) {
        whereConditions.add('recommendation_type = \$${parameters.length + 1}');
        parameters.add(type);
      }
      
      final result = await db.query(
        '''SELECT * FROM ai_recommendations 
           WHERE ${whereConditions.join(' AND ')}
           ORDER BY recommendation_score DESC
           LIMIT \$${parameters.length + 1}''',
        [...parameters, limit],
      );
      
      final recommendations = result.map((row) => AIRecommendation.fromRow(row)).toList();
      
      return Response.ok(
        jsonEncode({
          'recommendations': recommendations.map((r) => r.toJson()).toList(),
          'count': recommendations.length,
        }),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error getting recommendations: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get recommendations', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Генерация новых рекомендаций
  Future<Response> _generateRecommendations(Request request) async {
    try {
      final userId = request.params['userId']!;
      final body = await request.readAsString();
      final data = body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : <String, dynamic>{};
      
      final limit = data['limit'] ?? 20;
      final category = data['category'];
      final excludeProductIds = data['exclude_product_ids'] != null 
        ? List<String>.from(data['exclude_product_ids'])
        : <String>[];
      
      logger.i('Generating recommendations for user: $userId');
      
      final recommendations = await personalShopperService.generatePersonalRecommendations(
        userId,
        limit: limit,
        category: category,
        excludeProductIds: excludeProductIds,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Recommendations generated successfully',
          'recommendations': recommendations.map((r) => r.toJson()).toList(),
          'count': recommendations.length,
        }),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error generating recommendations: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to generate recommendations', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Отметка рекомендации как просмотренной
  Future<Response> _markRecommendationViewed(Request request) async {
    try {
      final recId = request.params['recId']!;
      
      await db.execute(
        'UPDATE ai_recommendations SET is_viewed = true WHERE id = \$1',
        [recId],
      );
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Recommendation marked as viewed'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error marking recommendation as viewed: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to mark as viewed', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Отметка рекомендации как нажатой
  Future<Response> _markRecommendationClicked(Request request) async {
    try {
      final recId = request.params['recId']!;
      
      await db.execute(
        'UPDATE ai_recommendations SET is_clicked = true, is_viewed = true WHERE id = \$1',
        [recId],
      );
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Recommendation marked as clicked'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error marking recommendation as clicked: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to mark as clicked', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Отметка рекомендации как купленной
  Future<Response> _markRecommendationPurchased(Request request) async {
    try {
      final recId = request.params['recId']!;
      
      await db.execute(
        'UPDATE ai_recommendations SET is_purchased = true, is_clicked = true, is_viewed = true WHERE id = \$1',
        [recId],
      );
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Recommendation marked as purchased'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error marking recommendation as purchased: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to mark as purchased', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение вишлиста пользователя
  Future<Response> _getWishlist(Request request) async {
    try {
      final userId = request.params['userId']!;
      
      final result = await db.query(
        'SELECT * FROM user_wishlist WHERE user_id = \$1 ORDER BY priority DESC, added_at DESC',
        [userId],
      );
      
      final wishlistItems = result.map((row) => UserWishlistItem.fromRow(row)).toList();
      
      return Response.ok(
        jsonEncode({
          'wishlist': wishlistItems.map((item) => item.toJson()).toList(),
          'count': wishlistItems.length,
        }),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error getting wishlist: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get wishlist', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Добавление товара в вишлист
  Future<Response> _addToWishlist(Request request) async {
    try {
      final userId = request.params['userId']!;
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final wishlistItem = UserWishlistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        productId: data['product_id'],
        productTitle: data['product_title'],
        productPrice: data['product_price'],
        productCategory: data['product_category'],
        productBrand: data['product_brand'],
        productSource: data['product_source'],
        productUrl: data['product_url'],
        productImageUrl: data['product_image_url'],
        priority: data['priority'] ?? 3,
        priceAlertThreshold: data['price_alert_threshold'],
        notes: data['notes'],
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await personalShopperService.addToWishlist(wishlistItem);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Item added to wishlist',
          'item': wishlistItem.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error adding to wishlist: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to add to wishlist', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Удаление товара из вишлиста
  Future<Response> _removeFromWishlist(Request request) async {
    try {
      final userId = request.params['userId']!;
      final productId = request.params['productId']!;
      
      await db.execute(
        'DELETE FROM user_wishlist WHERE user_id = \$1 AND product_id = \$2',
        [userId, productId],
      );
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Item removed from wishlist'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error removing from wishlist: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to remove from wishlist', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Обновление элемента вишлиста
  Future<Response> _updateWishlistItem(Request request) async {
    try {
      final userId = request.params['userId']!;
      final productId = request.params['productId']!;
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final updateFields = <String>[];
      final parameters = <dynamic>[];
      
      if (data.containsKey('priority')) {
        updateFields.add('priority = \$${parameters.length + 1}');
        parameters.add(data['priority']);
      }
      
      if (data.containsKey('price_alert_threshold')) {
        updateFields.add('price_alert_threshold = \$${parameters.length + 1}');
        parameters.add(data['price_alert_threshold']);
      }
      
      if (data.containsKey('notes')) {
        updateFields.add('notes = \$${parameters.length + 1}');
        parameters.add(data['notes']);
      }
      
      if (updateFields.isNotEmpty) {
        updateFields.add('updated_at = \$${parameters.length + 1}');
        parameters.add(DateTime.now());
        
        parameters.addAll([userId, productId]);
        
        await db.execute(
          '''UPDATE user_wishlist 
             SET ${updateFields.join(', ')}
             WHERE user_id = \$${parameters.length - 1} AND product_id = \$${parameters.length}''',
          parameters,
        );
      }
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Wishlist item updated'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error updating wishlist item: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update wishlist item', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Запись просмотра товара
  Future<Response> _recordProductView(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final view = UserProductView(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: data['user_id'],
        productId: data['product_id'],
        productTitle: data['product_title'],
        productPrice: data['product_price'],
        productCategory: data['product_category'],
        productBrand: data['product_brand'],
        productSource: data['product_source'],
        viewDuration: data['view_duration'] ?? 0,
        clickedDetails: data['clicked_details'] ?? false,
        addedToWishlist: data['added_to_wishlist'] ?? false,
        viewedAt: DateTime.now(),
      );
      
      await personalShopperService.recordProductView(view);
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Product view recorded'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error recording product view: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to record view', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Запись покупки
  Future<Response> _recordPurchase(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final purchase = UserPurchase(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: data['user_id'],
        productId: data['product_id'],
        productTitle: data['product_title'],
        productPrice: data['product_price'],
        productCategory: data['product_category'],
        productBrand: data['product_brand'],
        productSource: data['product_source'],
        quantity: data['quantity'] ?? 1,
        totalAmount: data['total_amount'],
        purchaseSatisfaction: data['purchase_satisfaction'],
        purchaseReason: data['purchase_reason'],
        purchasedAt: DateTime.now(),
      );
      
      await personalShopperService.recordPurchase(purchase);
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Purchase recorded'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error recording purchase: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to record purchase', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение анализа трендов пользователя
  Future<Response> _getUserTrends(Request request) async {
    try {
      final userId = request.params['userId']!;
      final analysisType = request.params['analysisType']!;
      
      final result = await db.query(
        '''SELECT * FROM user_trend_analysis 
           WHERE user_id = \$1 AND analysis_type = \$2 
           AND valid_until > \$3
           ORDER BY generated_at DESC 
           LIMIT 1''',
        [userId, analysisType, DateTime.now()],
      );
      
      if (result.isNotEmpty) {
        final analysis = UserTrendAnalysis.fromRow(result.first);
        return Response.ok(
          jsonEncode(analysis.toJson()),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'error': 'No valid trend analysis found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
    } catch (e, stackTrace) {
      logger.e('Error getting user trends: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get trends', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Анализ трендов пользователя
  Future<Response> _analyzeUserTrends(Request request) async {
    try {
      final userId = request.params['userId']!;
      final analysisType = request.params['analysisType']!;
      
      logger.i('Analyzing trends: $analysisType for user: $userId');
      
      final analysis = await personalShopperService.analyzeUserTrends(userId, analysisType);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Trends analyzed successfully',
          'analysis': analysis.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error analyzing user trends: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to analyze trends', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение статистики пользователя
  Future<Response> _getUserStats(Request request) async {
    try {
      final userId = request.params['userId']!;
      
      // Получаем различную статистику
      final viewsResult = await db.query(
        'SELECT COUNT(*) as view_count FROM user_product_views WHERE user_id = \$1',
        [userId],
      );
      
      final purchasesResult = await db.query(
        'SELECT COUNT(*) as purchase_count, SUM(total_amount) as total_spent FROM user_purchases WHERE user_id = \$1',
        [userId],
      );
      
      final wishlistResult = await db.query(
        'SELECT COUNT(*) as wishlist_count FROM user_wishlist WHERE user_id = \$1',
        [userId],
      );
      
      final recommendationsResult = await db.query(
        'SELECT COUNT(*) as total_recommendations, SUM(CASE WHEN is_viewed THEN 1 ELSE 0 END) as viewed_recommendations FROM ai_recommendations WHERE user_id = \$1',
        [userId],
      );
      
      final stats = {
        'views': {
          'total_views': viewsResult.first[0],
        },
        'purchases': {
          'total_purchases': purchasesResult.first[0],
          'total_spent': purchasesResult.first[1] ?? 0,
        },
        'wishlist': {
          'items_count': wishlistResult.first[0],
        },
        'recommendations': {
          'total_generated': recommendationsResult.first[0],
          'total_viewed': recommendationsResult.first[1],
        },
      };
      
      return Response.ok(
        jsonEncode({'stats': stats}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error getting user stats: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get stats', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение инсайтов пользователя
  Future<Response> _getUserInsights(Request request) async {
    try {
      final userId = request.params['userId']!;
      
      // Получаем предпочтения
      final preferences = await personalShopperService.getUserPreferences(userId);
      
      // Получаем топ категории
      final topCategories = preferences.categoryPreferences.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      // Получаем топ бренды
      final topBrands = preferences.brandPreferences.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      // Получаем последние покупки для анализа трендов
      final recentPurchasesResult = await db.query(
        '''SELECT product_category, COUNT(*) as count 
           FROM user_purchases 
           WHERE user_id = \$1 AND purchased_at > \$2
           GROUP BY product_category 
           ORDER BY count DESC 
           LIMIT 5''',
        [userId, DateTime.now().subtract(Duration(days: 90))],
      );
      
      final insights = {
        'top_categories': topCategories.take(5).map((e) => {
          'category': e.key,
          'score': e.value,
        }).toList(),
        'top_brands': topBrands.take(5).map((e) => {
          'brand': e.key,
          'score': e.value,
        }).toList(),
        'recent_category_trends': recentPurchasesResult.map((row) => {
          'category': row[0],
          'purchase_count': row[1],
        }).toList(),
        'price_range': preferences.priceRange,
        'budget_monthly': preferences.budgetMonthly,
        'preferred_marketplaces': preferences.preferredMarketplaces,
      };
      
      return Response.ok(
        jsonEncode({'insights': insights}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      logger.e('Error getting user insights: $e', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get insights', 'details': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
