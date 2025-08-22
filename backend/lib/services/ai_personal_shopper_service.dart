import 'dart:convert';
import 'dart:math';
import 'package:logger/logger.dart';
import '../database.dart';
import '../models.dart';
import 'ai_service.dart';

/// AI-сервис для персонального шоппера
class AIPersonalShopperService {
  final DatabaseService db;
  final AIService aiService;
  final Logger logger = Logger();

  AIPersonalShopperService({
    required this.db,
    required this.aiService,
  });

  /// Анализ предпочтений пользователя на основе истории
  Future<UserPreferences> analyzeUserPreferences(String userId) async {
    logger.i('Analyzing user preferences for user: $userId');

    try {
      // Получаем существующие предпочтения или создаем новые
      var preferences = await getUserPreferences(userId);
      
      // Анализируем историю просмотров
      final viewHistory = await _getRecentViewHistory(userId, limit: 200);
      
      // Анализируем историю покупок
      final purchaseHistory = await _getRecentPurchaseHistory(userId, limit: 100);
      
      // Анализируем вишлист
      final wishlistItems = await _getWishlistItems(userId);
      
      // Обновляем предпочтения на основе анализа
      preferences = await _updatePreferencesFromHistory(
        preferences, 
        viewHistory, 
        purchaseHistory, 
        wishlistItems
      );
      
      // Сохраняем обновленные предпочтения
      await _saveUserPreferences(preferences);
      
      logger.i('Successfully analyzed preferences for user: $userId');
      return preferences;
      
    } catch (e, stackTrace) {
      logger.e('Error analyzing user preferences: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Генерация персональных рекомендаций
  Future<List<AIRecommendation>> generatePersonalRecommendations(
    String userId, {
    int limit = 20,
    String? category,
    List<String>? excludeProductIds,
  }) async {
    logger.i('Generating personal recommendations for user: $userId');

    try {
      // Получаем предпочтения пользователя
      final preferences = await getUserPreferences(userId);
      
      // Получаем историю взаимодействий
      final recentViews = await _getRecentViewHistory(userId, limit: 50);
      final recentPurchases = await _getRecentPurchaseHistory(userId, limit: 20);
      
      // Получаем товары для анализа
      final candidateProducts = await _getCandidateProducts(
        preferences, 
        category: category,
        excludeIds: excludeProductIds ?? [],
        limit: limit * 3, // Берем больше для лучшей фильтрации
      );
      
      // Вычисляем скоры рекомендаций
      final recommendations = <AIRecommendation>[];
      
      for (final product in candidateProducts) {
        final score = await _calculateRecommendationScore(
          product, 
          preferences, 
          recentViews, 
          recentPurchases
        );
        
        if (score > 0.3) { // Минимальный порог для рекомендации
          final reasons = _generateRecommendationReasons(
            product, 
            preferences, 
            score
          );
          
          final recommendation = AIRecommendation(
            id: _generateId(),
            userId: userId,
            productId: product.id,
            productTitle: product.title,
            productPrice: product.price,
            productCategory: product.categoryId,
            productBrand: product.brand,
            productSource: product.source,
            productUrl: product.productUrl,
            productImageUrl: product.imageUrl,
            recommendationScore: score,
            recommendationReasons: reasons,
            recommendationType: _determineRecommendationType(product, preferences),
            isViewed: false,
            isClicked: false,
            isPurchased: false,
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(Duration(days: 7)),
          );
          
          recommendations.add(recommendation);
        }
      }
      
      // Сортируем по скору и берем нужное количество
      recommendations.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));
      final finalRecommendations = recommendations.take(limit).toList();
      
      // Сохраняем рекомендации в базу
      await _saveRecommendations(finalRecommendations);
      
      logger.i('Generated ${finalRecommendations.length} recommendations for user: $userId');
      return finalRecommendations;
      
    } catch (e, stackTrace) {
      logger.e('Error generating recommendations: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Анализ трендов пользователя
  Future<UserTrendAnalysis> analyzeUserTrends(
    String userId, 
    String analysisType
  ) async {
    logger.i('Analyzing user trends: $analysisType for user: $userId');

    try {
      Map<String, dynamic> analysisData = {};
      double confidenceScore = 0.0;
      
      switch (analysisType) {
        case 'style_evolution':
          analysisData = await _analyzeStyleEvolution(userId);
          confidenceScore = _calculateStyleConfidence(analysisData);
          break;
          
        case 'spending_pattern':
          analysisData = await _analyzeSpendingPattern(userId);
          confidenceScore = _calculateSpendingConfidence(analysisData);
          break;
          
        case 'seasonal_trends':
          analysisData = await _analyzeSeasonalTrends(userId);
          confidenceScore = _calculateSeasonalConfidence(analysisData);
          break;
          
        default:
          throw ArgumentError('Unknown analysis type: $analysisType');
      }
      
      final analysis = UserTrendAnalysis(
        id: _generateId(),
        userId: userId,
        analysisType: analysisType,
        analysisData: analysisData,
        confidenceScore: confidenceScore,
        generatedAt: DateTime.now(),
        validUntil: DateTime.now().add(Duration(days: 30)),
      );
      
      await _saveTrendAnalysis(analysis);
      
      logger.i('Successfully analyzed trends: $analysisType for user: $userId');
      return analysis;
      
    } catch (e, stackTrace) {
      logger.e('Error analyzing user trends: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Получение предпочтений пользователя
  Future<UserPreferences> getUserPreferences(String userId) async {
    try {
      final result = await db.query(
        'SELECT * FROM user_preferences WHERE user_id = \$1',
        [userId],
      );
      
      if (result.isNotEmpty) {
        return UserPreferences.fromRow(result.first);
      } else {
        // Создаем дефолтные предпочтения
        return _createDefaultPreferences(userId);
      }
    } catch (e) {
      logger.e('Error getting user preferences: $e');
      return _createDefaultPreferences(userId);
    }
  }

  /// Обновление предпочтений пользователя
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      await _saveUserPreferences(preferences);
      logger.i('Updated preferences for user: ${preferences.userId}');
    } catch (e, stackTrace) {
      logger.e('Error updating user preferences: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Добавление товара в вишлист
  Future<void> addToWishlist(UserWishlistItem item) async {
    try {
      await db.execute(
        '''INSERT INTO user_wishlist 
           (id, user_id, product_id, product_title, product_price, product_category, 
            product_brand, product_source, product_url, product_image_url, priority, 
            price_alert_threshold, notes, added_at, updated_at)
           VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13, \$14, \$15)
           ON CONFLICT (user_id, product_id) DO UPDATE SET
           priority = EXCLUDED.priority,
           price_alert_threshold = EXCLUDED.price_alert_threshold,
           notes = EXCLUDED.notes,
           updated_at = EXCLUDED.updated_at''',
        [
          item.id, item.userId, item.productId, item.productTitle, item.productPrice,
          item.productCategory, item.productBrand, item.productSource, item.productUrl,
          item.productImageUrl, item.priority, item.priceAlertThreshold, item.notes,
          item.addedAt, item.updatedAt,
        ],
      );
      
      logger.i('Added item to wishlist: ${item.productTitle}');
    } catch (e, stackTrace) {
      logger.e('Error adding to wishlist: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Запись просмотра товара
  Future<void> recordProductView(UserProductView view) async {
    try {
      await db.execute(
        '''INSERT INTO user_product_views 
           (id, user_id, product_id, product_title, product_price, product_category,
            product_brand, product_source, view_duration, clicked_details, 
            added_to_wishlist, viewed_at)
           VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12)''',
        [
          view.id, view.userId, view.productId, view.productTitle, view.productPrice,
          view.productCategory, view.productBrand, view.productSource, view.viewDuration,
          view.clickedDetails, view.addedToWishlist, view.viewedAt,
        ],
      );
      
      logger.d('Recorded product view: ${view.productTitle}');
    } catch (e, stackTrace) {
      logger.e('Error recording product view: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Запись покупки
  Future<void> recordPurchase(UserPurchase purchase) async {
    try {
      await db.execute(
        '''INSERT INTO user_purchases 
           (id, user_id, product_id, product_title, product_price, product_category,
            product_brand, product_source, quantity, total_amount, purchase_satisfaction,
            purchase_reason, purchased_at)
           VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13)''',
        [
          purchase.id, purchase.userId, purchase.productId, purchase.productTitle,
          purchase.productPrice, purchase.productCategory, purchase.productBrand,
          purchase.productSource, purchase.quantity, purchase.totalAmount,
          purchase.purchaseSatisfaction, purchase.purchaseReason, purchase.purchasedAt,
        ],
      );
      
      logger.i('Recorded purchase: ${purchase.productTitle}');
    } catch (e, stackTrace) {
      logger.e('Error recording purchase: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Приватные методы

  Future<List<UserProductView>> _getRecentViewHistory(String userId, {int limit = 100}) async {
    final result = await db.query(
      '''SELECT * FROM user_product_views 
         WHERE user_id = \$1 
         ORDER BY viewed_at DESC 
         LIMIT \$2''',
      [userId, limit],
    );
    
    return result.map((row) => UserProductView.fromRow(row)).toList();
  }

  Future<List<UserPurchase>> _getRecentPurchaseHistory(String userId, {int limit = 50}) async {
    final result = await db.query(
      '''SELECT * FROM user_purchases 
         WHERE user_id = \$1 
         ORDER BY purchased_at DESC 
         LIMIT \$2''',
      [userId, limit],
    );
    
    return result.map((row) => UserPurchase.fromRow(row)).toList();
  }

  Future<List<UserWishlistItem>> _getWishlistItems(String userId) async {
    final result = await db.query(
      'SELECT * FROM user_wishlist WHERE user_id = \$1 ORDER BY priority DESC',
      [userId],
    );
    
    return result.map((row) => UserWishlistItem.fromRow(row)).toList();
  }

  Future<UserPreferences> _updatePreferencesFromHistory(
    UserPreferences preferences,
    List<UserProductView> viewHistory,
    List<UserPurchase> purchaseHistory,
    List<UserWishlistItem> wishlistItems,
  ) async {
    // Анализируем категории
    final categoryWeights = Map<String, double>.from(preferences.categoryPreferences);
    final brandWeights = Map<String, double>.from(preferences.brandPreferences);
    
    // Обновляем веса на основе просмотров (меньший вес)
    for (final view in viewHistory) {
      if (view.productCategory != null) {
        categoryWeights[view.productCategory!] = 
          (categoryWeights[view.productCategory!] ?? 0.0) + 0.1;
      }
      if (view.productBrand != null) {
        brandWeights[view.productBrand!] = 
          (brandWeights[view.productBrand!] ?? 0.0) + 0.1;
      }
    }
    
    // Обновляем веса на основе покупок (больший вес)
    for (final purchase in purchaseHistory) {
      if (purchase.productCategory != null) {
        categoryWeights[purchase.productCategory!] = 
          (categoryWeights[purchase.productCategory!] ?? 0.0) + 0.5;
      }
      if (purchase.productBrand != null) {
        brandWeights[purchase.productBrand!] = 
          (brandWeights[purchase.productBrand!] ?? 0.0) + 0.5;
      }
    }
    
    // Обновляем веса на основе вишлиста (средний вес)
    for (final item in wishlistItems) {
      if (item.productCategory != null) {
        categoryWeights[item.productCategory!] = 
          (categoryWeights[item.productCategory!] ?? 0.0) + 0.3;
      }
      if (item.productBrand != null) {
        brandWeights[item.productBrand!] = 
          (brandWeights[item.productBrand!] ?? 0.0) + 0.3;
      }
    }
    
    // Анализируем ценовой диапазон
    final prices = <int>[];
    prices.addAll(purchaseHistory.map((p) => p.productPrice));
    prices.addAll(wishlistItems.map((w) => w.productPrice));
    
    Map<String, int> priceRange = Map.from(preferences.priceRange);
    if (prices.isNotEmpty) {
      prices.sort();
      final percentile20 = prices[(prices.length * 0.2).floor()];
      final percentile80 = prices[(prices.length * 0.8).floor()];
      
      priceRange['min'] = min(priceRange['min'] ?? 0, percentile20);
      priceRange['max'] = max(priceRange['max'] ?? 1000000, percentile80);
    }
    
    return UserPreferences(
      id: preferences.id,
      userId: preferences.userId,
      categoryPreferences: categoryWeights,
      brandPreferences: brandWeights,
      priceRange: priceRange,
      sizePreferences: preferences.sizePreferences,
      colorPreferences: preferences.colorPreferences,
      stylePreferences: preferences.stylePreferences,
      seasonalPreferences: preferences.seasonalPreferences,
      shoppingFrequency: preferences.shoppingFrequency,
      budgetMonthly: preferences.budgetMonthly,
      preferredMarketplaces: preferences.preferredMarketplaces,
      createdAt: preferences.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<List<Product>> _getCandidateProducts(
    UserPreferences preferences, {
    String? category,
    List<String> excludeIds = const [],
    int limit = 100,
  }) async {
    // Формируем SQL-запрос для получения кандидатов
    final whereConditions = <String>[];
    final parameters = <dynamic>[];
    
    if (category != null) {
      whereConditions.add('category_id = \$${parameters.length + 1}');
      parameters.add(category);
    }
    
    if (excludeIds.isNotEmpty) {
      whereConditions.add('id NOT IN (${excludeIds.map((id) => '\$${parameters.length + 1}').join(',')})');
      parameters.addAll(excludeIds);
    }
    
    // Фильтр по ценовому диапазону
    final minPrice = preferences.priceRange['min'] ?? 0;
    final maxPrice = preferences.priceRange['max'] ?? 1000000;
    whereConditions.add('price >= \$${parameters.length + 1} AND price <= \$${parameters.length + 2}');
    parameters.addAll([minPrice, maxPrice]);
    
    // Предпочитаемые маркетплейсы
    if (preferences.preferredMarketplaces.isNotEmpty) {
      whereConditions.add('source IN (${preferences.preferredMarketplaces.map((mp) => '\$${parameters.length + 1}').join(',')})');
      parameters.addAll(preferences.preferredMarketplaces);
    }
    
    final whereClause = whereConditions.isNotEmpty ? 'WHERE ${whereConditions.join(' AND ')}' : '';
    
    final result = await db.query(
      '''SELECT * FROM products 
         $whereClause
         ORDER BY rating DESC NULLS LAST, review_count DESC
         LIMIT \$${parameters.length + 1}''',
      [...parameters, limit],
    );
    
    return result.map((row) => Product.fromRow(row)).toList();
  }

  Future<double> _calculateRecommendationScore(
    Product product,
    UserPreferences preferences,
    List<UserProductView> recentViews,
    List<UserPurchase> recentPurchases,
  ) async {
    double score = 0.0;
    
    // Скор на основе предпочтений категорий
    if (product.categoryId != null && preferences.categoryPreferences.containsKey(product.categoryId)) {
      score += preferences.categoryPreferences[product.categoryId]! * 0.3;
    }
    
    // Скор на основе предпочтений брендов
    if (product.brand != null && preferences.brandPreferences.containsKey(product.brand)) {
      score += preferences.brandPreferences[product.brand]! * 0.25;
    }
    
    // Скор на основе ценового диапазона
    final minPrice = preferences.priceRange['min'] ?? 0;
    final maxPrice = preferences.priceRange['max'] ?? 1000000;
    if (product.price >= minPrice && product.price <= maxPrice) {
      score += 0.2;
    }
    
    // Скор на основе рейтинга и отзывов
    if (product.rating != null && product.rating! > 0) {
      score += (product.rating! / 5.0) * 0.15;
    }
    
    // Скор на основе скидки
    if (product.discount != null && product.discount! > 0) {
      score += min(product.discount! / 100.0, 0.1);
    }
    
    // Бонус за новизну
    final daysSinceCreated = DateTime.now().difference(product.createdAt).inDays;
    if (daysSinceCreated <= 7) {
      score += 0.05;
    }
    
    // Нормализуем скор
    return min(score, 1.0);
  }

  List<String> _generateRecommendationReasons(
    Product product,
    UserPreferences preferences,
    double score,
  ) {
    final reasons = <String>[];
    
    if (product.categoryId != null && preferences.categoryPreferences.containsKey(product.categoryId)) {
      reasons.add('Популярная категория в ваших покупках');
    }
    
    if (product.brand != null && preferences.brandPreferences.containsKey(product.brand)) {
      reasons.add('Предпочитаемый бренд');
    }
    
    if (product.discount != null && product.discount! > 20) {
      reasons.add('Большая скидка ${product.discount}%');
    }
    
    if (product.rating != null && product.rating! >= 4.0) {
      reasons.add('Высокий рейтинг ${product.rating!.toStringAsFixed(1)}');
    }
    
    if (score > 0.7) {
      reasons.add('Идеально подходит под ваши предпочтения');
    }
    
    return reasons;
  }

  String _determineRecommendationType(Product product, UserPreferences preferences) {
    if (product.discount != null && product.discount! > 30) {
      return 'price_drop';
    }
    
    final daysSinceCreated = DateTime.now().difference(product.createdAt).inDays;
    if (daysSinceCreated <= 3) {
      return 'trending';
    }
    
    if (product.categoryId != null && 
        preferences.categoryPreferences.containsKey(product.categoryId) &&
        preferences.categoryPreferences[product.categoryId]! > 1.0) {
      return 'personal';
    }
    
    return 'similar';
  }

  Future<Map<String, dynamic>> _analyzeStyleEvolution(String userId) async {
    // Анализируем эволюцию стиля пользователя
    final purchases = await _getRecentPurchaseHistory(userId, limit: 200);
    
    final stylesByMonth = <String, Map<String, int>>{};
    
    for (final purchase in purchases) {
      final monthKey = '${purchase.purchasedAt.year}-${purchase.purchasedAt.month.toString().padLeft(2, '0')}';
      stylesByMonth[monthKey] ??= {};
      
      // Простая классификация стиля на основе категории и бренда
      final style = _classifyStyle(purchase.productCategory, purchase.productBrand);
      stylesByMonth[monthKey]![style] = (stylesByMonth[monthKey]![style] ?? 0) + 1;
    }
    
    return {
      'styles_by_month': stylesByMonth,
      'dominant_style': _findDominantStyle(stylesByMonth),
      'style_diversity': _calculateStyleDiversity(stylesByMonth),
    };
  }

  Future<Map<String, dynamic>> _analyzeSpendingPattern(String userId) async {
    final purchases = await _getRecentPurchaseHistory(userId, limit: 200);
    
    final spendingByMonth = <String, int>{};
    final spendingByCategory = <String, int>{};
    
    for (final purchase in purchases) {
      final monthKey = '${purchase.purchasedAt.year}-${purchase.purchasedAt.month.toString().padLeft(2, '0')}';
      spendingByMonth[monthKey] = (spendingByMonth[monthKey] ?? 0) + purchase.totalAmount;
      
      if (purchase.productCategory != null) {
        spendingByCategory[purchase.productCategory!] = 
          (spendingByCategory[purchase.productCategory!] ?? 0) + purchase.totalAmount;
      }
    }
    
    return {
      'spending_by_month': spendingByMonth,
      'spending_by_category': spendingByCategory,
      'average_monthly_spending': _calculateAverageMonthlySpending(spendingByMonth),
      'top_categories': _getTopSpendingCategories(spendingByCategory),
    };
  }

  Future<Map<String, dynamic>> _analyzeSeasonalTrends(String userId) async {
    final purchases = await _getRecentPurchaseHistory(userId, limit: 300);
    
    final purchasesBySeason = <String, Map<String, int>>{};
    
    for (final purchase in purchases) {
      final season = _getSeason(purchase.purchasedAt.month);
      purchasesBySeason[season] ??= {};
      
      if (purchase.productCategory != null) {
        purchasesBySeason[season]![purchase.productCategory!] = 
          (purchasesBySeason[season]![purchase.productCategory!] ?? 0) + 1;
      }
    }
    
    return {
      'purchases_by_season': purchasesBySeason,
      'seasonal_preferences': _calculateSeasonalPreferences(purchasesBySeason),
    };
  }

  UserPreferences _createDefaultPreferences(String userId) {
    return UserPreferences(
      id: _generateId(),
      userId: userId,
      categoryPreferences: {},
      brandPreferences: {},
      priceRange: {'min': 0, 'max': 1000000},
      sizePreferences: {},
      colorPreferences: [],
      stylePreferences: [],
      seasonalPreferences: {},
      shoppingFrequency: {},
      budgetMonthly: 0,
      preferredMarketplaces: ['wildberries', 'ozon', 'lamoda', 'avito'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _saveUserPreferences(UserPreferences preferences) async {
    await db.execute(
      '''INSERT INTO user_preferences 
         (id, user_id, category_preferences, brand_preferences, price_range, 
          size_preferences, color_preferences, style_preferences, seasonal_preferences,
          shopping_frequency, budget_monthly, preferred_marketplaces, created_at, updated_at)
         VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13, \$14)
         ON CONFLICT (user_id) DO UPDATE SET
         category_preferences = EXCLUDED.category_preferences,
         brand_preferences = EXCLUDED.brand_preferences,
         price_range = EXCLUDED.price_range,
         size_preferences = EXCLUDED.size_preferences,
         color_preferences = EXCLUDED.color_preferences,
         style_preferences = EXCLUDED.style_preferences,
         seasonal_preferences = EXCLUDED.seasonal_preferences,
         shopping_frequency = EXCLUDED.shopping_frequency,
         budget_monthly = EXCLUDED.budget_monthly,
         preferred_marketplaces = EXCLUDED.preferred_marketplaces,
         updated_at = EXCLUDED.updated_at''',
      [
        preferences.id,
        preferences.userId,
        jsonEncode(preferences.categoryPreferences),
        jsonEncode(preferences.brandPreferences),
        jsonEncode(preferences.priceRange),
        jsonEncode(preferences.sizePreferences),
        preferences.colorPreferences,
        preferences.stylePreferences,
        jsonEncode(preferences.seasonalPreferences),
        jsonEncode(preferences.shoppingFrequency),
        preferences.budgetMonthly,
        preferences.preferredMarketplaces,
        preferences.createdAt,
        preferences.updatedAt,
      ],
    );
  }

  Future<void> _saveRecommendations(List<AIRecommendation> recommendations) async {
    for (final rec in recommendations) {
      await db.execute(
        '''INSERT INTO ai_recommendations 
           (id, user_id, product_id, product_title, product_price, product_category,
            product_brand, product_source, product_url, product_image_url,
            recommendation_score, recommendation_reasons, recommendation_type,
            is_viewed, is_clicked, is_purchased, created_at, expires_at)
           VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13, \$14, \$15, \$16, \$17, \$18)''',
        [
          rec.id, rec.userId, rec.productId, rec.productTitle, rec.productPrice,
          rec.productCategory, rec.productBrand, rec.productSource, rec.productUrl,
          rec.productImageUrl, rec.recommendationScore, jsonEncode(rec.recommendationReasons),
          rec.recommendationType, rec.isViewed, rec.isClicked, rec.isPurchased,
          rec.createdAt, rec.expiresAt,
        ],
      );
    }
  }

  Future<void> _saveTrendAnalysis(UserTrendAnalysis analysis) async {
    await db.execute(
      '''INSERT INTO user_trend_analysis 
         (id, user_id, analysis_type, analysis_data, confidence_score, generated_at, valid_until)
         VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7)''',
      [
        analysis.id,
        analysis.userId,
        analysis.analysisType,
        jsonEncode(analysis.analysisData),
        analysis.confidenceScore,
        analysis.generatedAt,
        analysis.validUntil,
      ],
    );
  }

  // Вспомогательные методы
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  String _classifyStyle(String? category, String? brand) {
    // Простая классификация стиля
    if (category?.toLowerCase().contains('sport') == true) return 'sport';
    if (category?.toLowerCase().contains('formal') == true) return 'formal';
    if (category?.toLowerCase().contains('casual') == true) return 'casual';
    return 'other';
  }

  String _findDominantStyle(Map<String, Map<String, int>> stylesByMonth) {
    final totalStyles = <String, int>{};
    for (final monthStyles in stylesByMonth.values) {
      for (final entry in monthStyles.entries) {
        totalStyles[entry.key] = (totalStyles[entry.key] ?? 0) + entry.value;
      }
    }
    
    if (totalStyles.isEmpty) return 'undefined';
    
    return totalStyles.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double _calculateStyleDiversity(Map<String, Map<String, int>> stylesByMonth) {
    final allStyles = <String>{};
    for (final monthStyles in stylesByMonth.values) {
      allStyles.addAll(monthStyles.keys);
    }
    return allStyles.length.toDouble();
  }

  double _calculateStyleConfidence(Map<String, dynamic> analysisData) {
    final diversity = analysisData['style_diversity'] as double;
    return min(1.0, diversity / 5.0); // Максимум 5 стилей для 100% уверенности
  }

  double _calculateSpendingConfidence(Map<String, dynamic> analysisData) {
    final spendingByMonth = analysisData['spending_by_month'] as Map<String, int>;
    if (spendingByMonth.length < 3) return 0.3; // Мало данных
    
    final values = spendingByMonth.values.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    final stability = 1.0 - min(1.0, sqrt(variance) / mean);
    
    return max(0.3, stability);
  }

  double _calculateSeasonalConfidence(Map<String, dynamic> analysisData) {
    final purchasesBySeason = analysisData['purchases_by_season'] as Map<String, Map<String, int>>;
    return min(1.0, purchasesBySeason.length / 4.0); // Данные по всем сезонам
  }

  int _calculateAverageMonthlySpending(Map<String, int> spendingByMonth) {
    if (spendingByMonth.isEmpty) return 0;
    return spendingByMonth.values.reduce((a, b) => a + b) ~/ spendingByMonth.length;
  }

  List<MapEntry<String, int>> _getTopSpendingCategories(Map<String, int> spendingByCategory) {
    final entries = spendingByCategory.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  String _getSeason(int month) {
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  Map<String, double> _calculateSeasonalPreferences(Map<String, Map<String, int>> purchasesBySeason) {
    final totalPurchases = purchasesBySeason.values
        .expand((seasonPurchases) => seasonPurchases.values)
        .fold(0, (sum, count) => sum + count);
    
    if (totalPurchases == 0) return {};
    
    return purchasesBySeason.map((season, purchases) {
      final seasonTotal = purchases.values.fold(0, (sum, count) => sum + count);
      return MapEntry(season, seasonTotal / totalPurchases);
    });
  }
}
