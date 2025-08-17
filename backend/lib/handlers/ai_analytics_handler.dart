import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logger/logger.dart';
import '../services/ai_analytics_service.dart';

class AIAnalyticsHandler {
  final AIAnalyticsService _aiAnalyticsService;
  final Logger _logger = Logger();

  AIAnalyticsHandler(this._aiAnalyticsService);

  Router get router {
    final router = Router();

    // Анализ модных трендов
    router.get('/trends', _getFashionTrends);
    router.get('/trends/<category>', _getFashionTrendsByCategory);
    
    // Анализ поведения пользователей
    router.get('/behavior/<userId>', _getUserBehavior);
    router.get('/behavior/<userId>/<timeframe>', _getUserBehaviorByTimeframe);
    
    // Эффективность рекомендаций
    router.get('/effectiveness', _getRecommendationEffectiveness);
    router.get('/effectiveness/<category>', _getRecommendationEffectivenessByCategory);
    
    // Анализ контента
    router.post('/content', _analyzeContent);
    
    // Прогнозирование спроса
    router.get('/demand', _getDemandPredictions);
    router.get('/demand/<category>', _getDemandPredictionsByCategory);
    
    // Анализ конкурентов
    router.get('/competitors', _getCompetitorAnalysis);
    router.get('/competitors/<category>', _getCompetitorAnalysisByCategory);
    
    // AI статистика и метрики
    router.get('/stats', _getAIStats);
    router.get('/stats/<metric>', _getAIStatsByMetric);

    return router;
  }

  /// Получение модных трендов
  Future<Response> _getFashionTrends(Request request) async {
    try {
      final timeframe = request.url.queryParameters['timeframe'] ?? '30d';
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;
      
      _logger.i('Getting fashion trends for timeframe: $timeframe, limit: $limit');
      
      final trends = await _aiAnalyticsService.analyzeFashionTrends(
        timeframe: timeframe,
        limit: limit,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'trends': trends.map((t) => {
              return {
                'name': t.name,
                'description': t.description,
                'confidence': t.confidence,
                'products_count': t.productsCount,
                'growth_rate': t.growthRate,
                'main_brands': t.mainBrands,
                'target_audience': t.targetAudience,
              };
            }).toList(),
            'total': trends.length,
            'timeframe': timeframe,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting fashion trends: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get fashion trends: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение трендов по категории
  Future<Response> _getFashionTrendsByCategory(Request request, String category) async {
    try {
      final timeframe = request.url.queryParameters['timeframe'] ?? '30d';
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;
      
      _logger.i('Getting fashion trends for category: $category, timeframe: $timeframe');
      
      final trends = await _aiAnalyticsService.analyzeFashionTrends(
        category: category,
        timeframe: timeframe,
        limit: limit,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'category': category,
            'trends': trends.map((t) => {
              return {
                'name': t.name,
                'description': t.description,
                'confidence': t.confidence,
                'products_count': t.productsCount,
                'growth_rate': t.growthRate,
                'main_brands': t.mainBrands,
                'target_audience': t.targetAudience,
              };
            }).toList(),
            'total': trends.length,
            'timeframe': timeframe,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting fashion trends for category $category: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get fashion trends for category $category: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение анализа поведения пользователя
  Future<Response> _getUserBehavior(Request request, String userId) async {
    try {
      _logger.i('Getting user behavior analysis for user: $userId');
      
      final analysis = await _aiAnalyticsService.analyzeUserBehavior(
        userId: userId,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'user_id': analysis.userId,
            'purchase_patterns': analysis.purchasePatterns,
            'activity_patterns': analysis.activityPatterns,
            'engagement_metrics': analysis.engagementMetrics,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting user behavior for user $userId: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get user behavior for user $userId: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение анализа поведения пользователя по временному периоду
  Future<Response> _getUserBehaviorByTimeframe(Request request, String userId, String timeframe) async {
    try {
      _logger.i('Getting user behavior analysis for user: $userId, timeframe: $timeframe');
      
      final analysis = await _aiAnalyticsService.analyzeUserBehavior(
        userId: userId,
        timeframe: timeframe,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'user_id': analysis.userId,
            'timeframe': timeframe,
            'purchase_patterns': analysis.purchasePatterns,
            'activity_patterns': analysis.activityPatterns,
            'engagement_metrics': analysis.engagementMetrics,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting user behavior for user $userId, timeframe $timeframe: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get user behavior for user $userId, timeframe $timeframe: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение эффективности рекомендаций
  Future<Response> _getRecommendationEffectiveness(Request request) async {
    try {
      final userId = request.url.queryParameters['user_id'];
      final timeframe = request.url.queryParameters['timeframe'] ?? '30d';
      
      _logger.i('Getting recommendation effectiveness for user: $userId, timeframe: $timeframe');
      
      final effectiveness = await _aiAnalyticsService.analyzeRecommendationEffectiveness(
        userId: userId,
        timeframe: timeframe,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'user_id': userId,
            'timeframe': timeframe,
            'click_through_rate': effectiveness.clickThroughRate,
            'conversion_rate': effectiveness.conversionRate,
            'average_order_value': effectiveness.averageOrderValue,
            'user_engagement': effectiveness.userEngagement,
            'retention_rate': effectiveness.retentionRate,
            'revenue_impact': effectiveness.revenueImpact,
            'category_performance': effectiveness.categoryPerformance,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting recommendation effectiveness: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get recommendation effectiveness: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение эффективности рекомендаций по категории
  Future<Response> _getRecommendationEffectivenessByCategory(Request request, String category) async {
    try {
      final userId = request.url.queryParameters['user_id'];
      final timeframe = request.url.queryParameters['timeframe'] ?? '30d';
      
      _logger.i('Getting recommendation effectiveness for category: $category, user: $userId');
      
      final effectiveness = await _aiAnalyticsService.analyzeRecommendationEffectiveness(
        userId: userId,
        category: category,
        timeframe: timeframe,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'category': category,
            'user_id': userId,
            'timeframe': timeframe,
            'click_through_rate': effectiveness.clickThroughRate,
            'conversion_rate': effectiveness.conversionRate,
            'average_order_value': effectiveness.averageOrderValue,
            'user_engagement': effectiveness.userEngagement,
            'retention_rate': effectiveness.retentionRate,
            'revenue_impact': effectiveness.revenueImpact,
            'category_performance': effectiveness.categoryPerformance,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting recommendation effectiveness for category $category: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get recommendation effectiveness for category $category: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Анализ контента
  Future<Response> _analyzeContent(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final content = data['content'] as String;
      final contentType = data['content_type'] as String;
      
      _logger.i('Analyzing content of type: $contentType');
      
      final analysis = await _aiAnalyticsService.analyzeContent(
        content: content,
        contentType: contentType,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'content': analysis.content,
            'content_type': analysis.contentType,
            'sentiment': analysis.sentiment,
            'sentiment_score': analysis.sentimentScore,
            'engagement_level': analysis.engagementLevel,
            'relevance_score': analysis.relevanceScore,
            'quality_score': analysis.qualityScore,
            'recommendations': analysis.recommendations,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error analyzing content: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to analyze content: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение прогнозов спроса
  Future<Response> _getDemandPredictions(Request request) async {
    try {
      final timeframe = request.url.queryParameters['timeframe'] ?? '90d';
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      
      _logger.i('Getting demand predictions for timeframe: $timeframe, limit: $limit');
      
      final predictions = await _aiAnalyticsService.predictDemand(
        timeframe: timeframe,
        limit: limit,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'predictions': predictions.map((p) => {
              return {
                'product_name': p.productName,
                'category': p.category,
                'predicted_demand': p.predictedDemand,
                'confidence': p.confidence,
                'influencing_factors': p.influencingFactors,
                'recommendations': p.recommendations,
              };
            }).toList(),
            'total': predictions.length,
            'timeframe': timeframe,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting demand predictions: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get demand predictions: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение прогнозов спроса по категории
  Future<Response> _getDemandPredictionsByCategory(Request request, String category) async {
    try {
      final timeframe = request.url.queryParameters['timeframe'] ?? '90d';
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      
      _logger.i('Getting demand predictions for category: $category, timeframe: $timeframe');
      
      final predictions = await _aiAnalyticsService.predictDemand(
        category: category,
        timeframe: timeframe,
        limit: limit,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'category': category,
            'predictions': predictions.map((p) => {
              return {
                'product_name': p.productName,
                'category': p.category,
                'predicted_demand': p.predictedDemand,
                'confidence': p.confidence,
                'influencing_factors': p.influencingFactors,
                'recommendations': p.recommendations,
              };
            }).toList(),
            'total': predictions.length,
            'timeframe': timeframe,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting demand predictions for category $category: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get demand predictions for category $category: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение анализа конкурентов
  Future<Response> _getCompetitorAnalysis(Request request) async {
    try {
      final region = request.url.queryParameters['region'];
      
      _logger.i('Getting competitor analysis for region: $region');
      
      final analysis = await _aiAnalyticsService.analyzeCompetitors(
        region: region,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'region': region,
            'competitors': analysis.map((c) => {
              return {
                'name': c.competitorName,
                'strengths': c.strengths,
                'weaknesses': c.weaknesses,
                'pricing_strategy': c.pricingStrategy,
                'market_share': c.marketShare,
                'recommendations': c.recommendations,
              };
            }).toList(),
            'total': analysis.length,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting competitor analysis: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get competitor analysis: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение анализа конкурентов по категории
  Future<Response> _getCompetitorAnalysisByCategory(Request request, String category) async {
    try {
      final region = request.url.queryParameters['region'];
      
      _logger.i('Getting competitor analysis for category: $category, region: $region');
      
      final analysis = await _aiAnalyticsService.analyzeCompetitors(
        category: category,
        region: region,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'category': category,
            'region': region,
            'competitors': analysis.map((c) => {
              return {
                'name': c.competitorName,
                'strengths': c.strengths,
                'weaknesses': c.weaknesses,
                'pricing_strategy': c.pricingStrategy,
                'market_share': c.marketShare,
                'recommendations': c.recommendations,
              };
            }).toList(),
            'total': analysis.length,
            'analyzed_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting competitor analysis for category $category: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get competitor analysis for category $category: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение AI статистики
  Future<Response> _getAIStats(Request request) async {
    try {
      _logger.i('Getting AI statistics');
      
      // В реальном приложении здесь будет получение статистики из базы
      final stats = _generateMockAIStats();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'statistics': stats,
            'generated_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting AI statistics: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get AI statistics: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение AI статистики по метрике
  Future<Response> _getAIStatsByMetric(Request request, String metric) async {
    try {
      _logger.i('Getting AI statistics for metric: $metric');
      
      // В реальном приложении здесь будет получение статистики по метрике
      final stats = _generateMockAIStatsByMetric(metric);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'metric': metric,
            'statistics': stats,
            'generated_at': DateTime.now().toIso8601String(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting AI statistics for metric $metric: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get AI statistics for metric $metric: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Вспомогательные методы для тестовых данных

  Map<String, dynamic> _generateMockAIStats() {
    return {
      'total_ai_requests': 15420,
      'successful_requests': 14890,
      'failed_requests': 530,
      'average_response_time_ms': 1250,
      'total_tokens_used': 2847500,
      'cost_estimate_usd': 45.80,
      'trends_analyzed': 156,
      'users_analyzed': 892,
      'content_moderated': 2340,
      'recommendations_generated': 5670,
      'demand_predictions': 890,
      'competitor_analyses': 234,
      'top_performing_models': [
        {'model': 'gpt-4', 'requests': 8900, 'success_rate': 0.98},
        {'model': 'gpt-3.5-turbo', 'requests': 6520, 'success_rate': 0.95},
      ],
      'category_performance': {
        'trends': {'requests': 3200, 'success_rate': 0.97},
        'behavior': {'requests': 2800, 'success_rate': 0.96},
        'content': {'requests': 4100, 'requests': 0.94},
        'demand': {'requests': 1800, 'success_rate': 0.93},
        'competitors': {'requests': 3520, 'success_rate': 0.95},
      },
    };
  }

  Map<String, dynamic> _generateMockAIStatsByMetric(String metric) {
    switch (metric.toLowerCase()) {
      case 'trends':
        return {
          'total_requests': 3200,
          'success_rate': 0.97,
          'average_response_time_ms': 1100,
          'tokens_used': 640000,
          'cost_usd': 12.80,
          'trends_generated': 156,
          'categories_covered': 12,
          'confidence_distribution': {
            'high': 0.45,
            'medium': 0.38,
            'low': 0.17,
          },
        };
      case 'behavior':
        return {
          'total_requests': 2800,
          'success_rate': 0.96,
          'average_response_time_ms': 1350,
          'tokens_used': 560000,
          'cost_usd': 11.20,
          'users_analyzed': 892,
          'timeframes_analyzed': 4,
          'pattern_types': ['purchase', 'activity', 'engagement'],
        };
      case 'content':
        return {
          'total_requests': 4100,
          'success_rate': 0.94,
          'average_response_time_ms': 980,
          'tokens_used': 820000,
          'cost_usd': 16.40,
          'content_moderated': 2340,
          'sentiment_accuracy': 0.89,
          'moderation_decisions': {
            'approved': 0.78,
            'review': 0.18,
            'rejected': 0.04,
          },
        };
      case 'demand':
        return {
          'total_requests': 1800,
          'success_rate': 0.93,
          'average_response_time_ms': 1450,
          'tokens_used': 360000,
          'cost_usd': 7.20,
          'demand_predictions': 890,
          'categories_covered': 8,
          'prediction_horizon_days': 90,
        };
      case 'competitors':
        return {
          'total_requests': 3520,
          'success_rate': 0.95,
          'average_response_time_ms': 1200,
          'tokens_used': 704000,
          'cost_usd': 14.08,
          'competitor_analyses': 234,
          'regions_covered': 6,
          'market_insights_generated': 156,
        };
      default:
        return {
          'error': 'Unknown metric: $metric',
          'available_metrics': ['trends', 'behavior', 'content', 'demand', 'competitors'],
        };
    }
  }
}
