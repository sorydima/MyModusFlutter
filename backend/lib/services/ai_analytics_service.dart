import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import '../models.dart';

class AIAnalyticsService {
  final Logger _logger = Logger();
  late final String _openaiApiKey;
  late final String _openaiBaseUrl;
  
  AIAnalyticsService() {
    final env = DotEnv()..load();
    _openaiApiKey = env['OPENAI_API_KEY'] ?? '';
    _openaiBaseUrl = env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';
  }

  /// Анализ трендов в моде
  Future<List<FashionTrend>> analyzeFashionTrends({
    String? category,
    String? timeframe = '30d',
    int limit = 10,
  }) async {
    try {
      _logger.i('Analyzing fashion trends for category: $category, timeframe: $timeframe');
      
      // В реальном приложении здесь будет анализ данных из базы
      // Пока используем AI для генерации трендов
      final trends = await _generateTrendsWithAI(category, timeframe, limit);
      
      return trends;
    } catch (e) {
      _logger.e('Error analyzing fashion trends: $e');
      return _generateFallbackTrends(category, limit);
    }
  }

  /// Анализ поведения пользователей
  Future<UserBehaviorAnalysis> analyzeUserBehavior({
    required String userId,
    String? timeframe = '30d',
  }) async {
    try {
      _logger.i('Analyzing user behavior for user: $userId, timeframe: $timeframe');
      
      // В реальном приложении здесь будет анализ данных из базы
      final analysis = await _generateBehaviorAnalysisWithAI(userId, timeframe);
      
      return analysis;
    } catch (e) {
      _logger.e('Error analyzing user behavior: $e');
      return _generateFallbackBehaviorAnalysis(userId);
    }
  }

  /// Анализ эффективности рекомендаций
  Future<RecommendationEffectiveness> analyzeRecommendationEffectiveness({
    String? userId,
    String? category,
    String? timeframe = '30d',
  }) async {
    try {
      _logger.i('Analyzing recommendation effectiveness for user: $userId, category: $category');
      
      // В реальном приложении здесь будет анализ метрик
      final effectiveness = await _generateEffectivenessAnalysisWithAI(userId, category, timeframe);
      
      return effectiveness;
    } catch (e) {
      _logger.e('Error analyzing recommendation effectiveness: $e');
      return _generateFallbackEffectivenessAnalysis();
    }
  }

  /// Анализ контента и сентимента
  Future<ContentAnalysis> analyzeContent({
    required String content,
    required String contentType, // 'post', 'comment', 'review'
  }) async {
    try {
      _logger.i('Analyzing content of type: $contentType');
      
      final analysis = await _generateContentAnalysisWithAI(content, contentType);
      
      return analysis;
    } catch (e) {
      _logger.e('Error analyzing content: $e');
      return _generateFallbackContentAnalysis(content, contentType);
    }
  }

  /// Предсказание спроса на товары
  Future<List<DemandPrediction>> predictDemand({
    String? category,
    String? timeframe = '90d',
    int limit = 20,
  }) async {
    try {
      _logger.i('Predicting demand for category: $category, timeframe: $timeframe');
      
      final predictions = await _generateDemandPredictionsWithAI(category, timeframe, limit);
      
      return predictions;
    } catch (e) {
      _logger.e('Error predicting demand: $e');
      return _generateFallbackDemandPredictions(category, limit);
    }
  }

  /// Анализ конкурентов
  Future<List<CompetitorAnalysis>> analyzeCompetitors({
    String? category,
    String? region,
  }) async {
    try {
      _logger.i('Analyzing competitors for category: $category, region: $region');
      
      final analysis = await _generateCompetitorAnalysisWithAI(category, region);
      
      return analysis;
    } catch (e) {
      _logger.e('Error analyzing competitors: $e');
      return _generateFallbackCompetitorAnalysis(category);
    }
  }

  // AI-методы для генерации анализа

  Future<List<FashionTrend>> _generateTrendsWithAI(
    String? category, 
    String? timeframe, 
    int limit,
  ) async {
    try {
      final prompt = _buildTrendAnalysisPrompt(category, timeframe, limit);
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': 'You are a fashion industry expert and trend analyst. Analyze current fashion trends and provide insights.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 800,
        temperature: 0.7,
      );
      
      final content = response['choices'][0]['message']['content'];
      return _parseTrendsFromAI(content, limit);
    } catch (e) {
      _logger.e('Error generating trends with AI: $e');
      rethrow;
    }
  }

  Future<UserBehaviorAnalysis> _generateBehaviorAnalysisWithAI(
    String userId, 
    String? timeframe,
  ) async {
    try {
      final prompt = _buildBehaviorAnalysisPrompt(userId, timeframe);
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': 'You are a user behavior analyst specializing in e-commerce and fashion.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 600,
        temperature: 0.6,
      );
      
      final content = response['choices'][0]['message']['content'];
      return _parseBehaviorAnalysisFromAI(content, userId);
    } catch (e) {
      _logger.e('Error generating behavior analysis with AI: $e');
      rethrow;
    }
  }

  Future<RecommendationEffectiveness> _generateEffectivenessAnalysisWithAI(
    String? userId, 
    String? category, 
    String? timeframe,
  ) async {
    try {
      final prompt = _buildEffectivenessAnalysisPrompt(userId, category, timeframe);
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': 'You are a data analyst specializing in recommendation system effectiveness.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 500,
        temperature: 0.5,
      );
      
      final content = response['choices'][0]['message']['content'];
      return _parseEffectivenessAnalysisFromAI(content);
    } catch (e) {
      _logger.e('Error generating effectiveness analysis with AI: $e');
      rethrow;
    }
  }

  Future<ContentAnalysis> _generateContentAnalysisWithAI(
    String content, 
    String contentType,
  ) async {
    try {
      final prompt = _buildContentAnalysisPrompt(content, contentType);
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': 'You are a content analyst specializing in social media and e-commerce content.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 400,
        temperature: 0.4,
      );
      
      final aiContent = response['choices'][0]['message']['content'];
      return _parseContentAnalysisFromAI(aiContent, content, contentType);
    } catch (e) {
      _logger.e('Error generating content analysis with AI: $e');
      rethrow;
    }
  }

  Future<List<DemandPrediction>> _generateDemandPredictionsWithAI(
    String? category, 
    String? timeframe, 
    int limit,
  ) async {
    try {
      final prompt = _buildDemandPredictionPrompt(category, timeframe, limit);
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': 'You are a demand forecasting expert specializing in fashion retail.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 600,
        temperature: 0.6,
      );
      
      final content = response['choices'][0]['message']['content'];
      return _parseDemandPredictionsFromAI(content, limit);
    } catch (e) {
      _logger.e('Error generating demand predictions with AI: $e');
      rethrow;
    }
  }

  Future<List<CompetitorAnalysis>> _generateCompetitorAnalysisWithAI(
    String? category, 
    String? region,
  ) async {
    try {
      final prompt = _buildCompetitorAnalysisPrompt(category, region);
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': 'You are a competitive intelligence analyst specializing in fashion retail.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 700,
        temperature: 0.5,
      );
      
      final content = response['choices'][0]['message']['content'];
      return _parseCompetitorAnalysisFromAI(content);
    } catch (e) {
      _logger.e('Error generating competitor analysis with AI: $e');
      rethrow;
    }
  }

  // Промпты для AI

  String _buildTrendAnalysisPrompt(String? category, String? timeframe, int limit) {
    return '''
Проанализируй текущие тренды в моде для категории: ${category ?? 'все категории'}.
Временной период: $timeframe.
Количество трендов: $limit.

Для каждого тренда укажи:
- Название тренда
- Описание
- Уровень уверенности (0.0-1.0)
- Количество связанных товаров
- Темп роста (в %)
- Основные бренды
- Целевую аудиторию

Формат ответа: JSON массив с объектами трендов.
''';
  }

  String _buildBehaviorAnalysisPrompt(String userId, String? timeframe) {
    return '''
Проанализируй поведение пользователя $userId за период $timeframe.

Проанализируй:
- Паттерны покупок
- Предпочтения по категориям
- Ценовые предпочтения
- Время активности
- Вовлеченность с контентом
- Социальные взаимодействия

Формат ответа: JSON объект с анализом поведения.
''';
  }

  String _buildEffectivenessAnalysisPrompt(String? userId, String? category, String? timeframe) {
    return '''
Проанализируй эффективность рекомендаций для пользователя ${userId ?? 'всех пользователей'}.
Категория: ${category ?? 'все категории'}.
Период: $timeframe.

Метрики для анализа:
- Click-through rate (CTR)
- Conversion rate
- Average order value (AOV)
- User engagement
- Retention rate
- Revenue impact

Формат ответа: JSON объект с метриками эффективности.
''';
  }

  String _buildContentAnalysisPrompt(String content, String contentType) {
    return '''
Проанализируй контент типа "$contentType":

$content

Анализ должен включать:
- Тональность (позитивная/негативная/нейтральная)
- Уровень вовлеченности
- Релевантность для аудитории
- Качество контента
- Рекомендации по улучшению

Формат ответа: JSON объект с анализом контента.
''';
  }

  String _buildDemandPredictionPrompt(String? category, String? timeframe, int limit) {
    return '''
Спрогнозируй спрос на товары категории ${category ?? 'всех категорий'} на период $timeframe.
Количество прогнозов: $limit.

Для каждого прогноза укажи:
- Название товара/категории
- Прогнозируемый спрос
- Уровень уверенности
- Факторы влияния
- Рекомендации по закупкам

Формат ответа: JSON массив с прогнозами спроса.
''';
  }

  String _buildCompetitorAnalysisPrompt(String? category, String? region) {
    return '''
Проведи анализ конкурентов для категории ${category ?? 'всех категорий'} в регионе ${region ?? 'всех регионов'}.

Анализ должен включать:
- Основных конкурентов
- Их сильные и слабые стороны
- Ценовую политику
- Маркетинговые стратегии
- Долю рынка
- Рекомендации по позиционированию

Формат ответа: JSON массив с анализом конкурентов.
''';
  }

  // Парсинг ответов AI

  List<FashionTrend> _parseTrendsFromAI(String aiContent, int limit) {
    try {
      // В реальном приложении здесь будет парсинг JSON от AI
      // Пока возвращаем заглушку
      return _generateFallbackTrends(null, limit);
    } catch (e) {
      _logger.e('Error parsing trends from AI: $e');
      return _generateFallbackTrends(null, limit);
    }
  }

  UserBehaviorAnalysis _parseBehaviorAnalysisFromAI(String aiContent, String userId) {
    try {
      // В реальном приложении здесь будет парсинг JSON от AI
      return _generateFallbackBehaviorAnalysis(userId);
    } catch (e) {
      _logger.e('Error parsing behavior analysis from AI: $e');
      return _generateFallbackBehaviorAnalysis(userId);
    }
  }

  RecommendationEffectiveness _parseEffectivenessAnalysisFromAI(String aiContent) {
    try {
      // В реальном приложении здесь будет парсинг JSON от AI
      return _generateFallbackEffectivenessAnalysis();
    } catch (e) {
      _logger.e('Error parsing effectiveness analysis from AI: $e');
      return _generateFallbackEffectivenessAnalysis();
    }
  }

  ContentAnalysis _parseContentAnalysisFromAI(String aiContent, String content, String contentType) {
    try {
      // В реальном приложении здесь будет парсинг JSON от AI
      return _generateFallbackContentAnalysis(content, contentType);
    } catch (e) {
      _logger.e('Error parsing content analysis from AI: $e');
      return _generateFallbackContentAnalysis(content, contentType);
    }
  }

  List<DemandPrediction> _parseDemandPredictionsFromAI(String aiContent, int limit) {
    try {
      // В реальном приложении здесь будет парсинг JSON от AI
      return _generateFallbackDemandPredictions(null, limit);
    } catch (e) {
      _logger.e('Error parsing demand predictions from AI: $e');
      return _generateFallbackDemandPredictions(null, limit);
    }
  }

  List<CompetitorAnalysis> _parseCompetitorAnalysisFromAI(String aiContent) {
    try {
      // В реальном приложении здесь будет парсинг JSON от AI
      return _generateFallbackCompetitorAnalysis(null);
    } catch (e) {
      _logger.e('Error parsing competitor analysis from AI: $e');
      return _generateFallbackCompetitorAnalysis(null);
    }
  }

  // OpenAI API запросы

  Future<Map<String, dynamic>> _makeOpenAIRequest({
    required String model,
    required List<Map<String, String>> messages,
    int? maxTokens,
    double? temperature,
  }) async {
    if (_openaiApiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final response = await http.post(
      Uri.parse('$_openaiBaseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_openaiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        if (maxTokens != null) 'max_tokens': maxTokens,
        if (temperature != null) 'temperature': temperature,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
    }
  }

  // Fallback методы

  List<FashionTrend> _generateFallbackTrends(String? category, int limit) {
    return [
      FashionTrend(
        name: 'Sustainable Fashion',
        description: 'Растущий интерес к экологичной моде',
        confidence: 0.92,
        productsCount: 150,
        growthRate: 25.0,
        mainBrands: ['Patagonia', 'Stella McCartney', 'Veja'],
        targetAudience: 'Экологически сознательные потребители 25-40 лет',
      ),
      FashionTrend(
        name: 'Athleisure',
        description: 'Спортивная одежда для повседневной носки',
        confidence: 0.88,
        productsCount: 89,
        growthRate: 18.0,
        mainBrands: ['Lululemon', 'Nike', 'Adidas'],
        targetAudience: 'Активные люди 18-35 лет',
      ),
      FashionTrend(
        name: 'Vintage Revival',
        description: 'Возвращение винтажных стилей',
        confidence: 0.85,
        productsCount: 67,
        growthRate: 12.0,
        mainBrands: ['Levi\'s', 'Carhartt', 'Champion'],
        targetAudience: 'Модные энтузиасты 20-30 лет',
      ),
    ].take(limit).toList();
  }

  UserBehaviorAnalysis _generateFallbackBehaviorAnalysis(String userId) {
    return UserBehaviorAnalysis(
      userId: userId,
      purchasePatterns: {
        'preferred_categories': ['footwear', 'clothing'],
        'preferred_brands': ['Nike', 'Adidas', 'Levi\'s'],
        'price_range': {'min': 5000, 'max': 25000, 'average': 15000},
        'purchase_frequency': 'weekly',
        'seasonal_preferences': {'spring': 'light_colors', 'winter': 'dark_colors'},
      },
      activityPatterns: {
        'peak_hours': ['12:00', '18:00', '21:00'],
        'preferred_days': ['wednesday', 'friday', 'saturday'],
        'session_duration': '15-30 minutes',
        'return_rate': 0.85,
      },
      engagementMetrics: {
        'posts_viewed': 45,
        'comments_made': 12,
        'likes_given': 67,
        'shares_made': 8,
        'followers_count': 234,
        'following_count': 156,
      },
    );
  }

  RecommendationEffectiveness _generateFallbackEffectivenessAnalysis() {
    return RecommendationEffectiveness(
      clickThroughRate: 0.15,
      conversionRate: 0.08,
      averageOrderValue: 18500,
      userEngagement: 0.72,
      retentionRate: 0.68,
      revenueImpact: 0.23,
      categoryPerformance: {
        'footwear': {'ctr': 0.18, 'conversion': 0.12},
        'clothing': {'ctr': 0.14, 'conversion': 0.07},
        'accessories': {'ctr': 0.11, 'conversion': 0.05},
      },
    );
  }

  ContentAnalysis _generateFallbackContentAnalysis(String content, String contentType) {
    return ContentAnalysis(
      content: content,
      contentType: contentType,
      sentiment: 'positive',
      sentimentScore: 0.75,
      engagementLevel: 'high',
      relevanceScore: 0.88,
      qualityScore: 0.82,
      recommendations: [
        'Добавить больше визуального контента',
        'Использовать актуальные хештеги',
        'Включить призыв к действию',
      ],
    );
  }

  List<DemandPrediction> _generateFallbackDemandPredictions(String? category, int limit) {
    return [
      DemandPrediction(
        productName: 'Nike Air Max 270',
        category: 'footwear',
        predictedDemand: 1200,
        confidence: 0.85,
        influencingFactors: ['Seasonal trend', 'Brand popularity', 'Price point'],
        recommendations: 'Increase inventory by 20% for Q2',
      ),
      DemandPrediction(
        productName: 'Levi\'s 501 Jeans',
        category: 'clothing',
        predictedDemand: 800,
        confidence: 0.78,
        influencingFactors: ['Classic style', 'Versatility', 'Brand loyalty'],
        recommendations: 'Maintain current inventory levels',
      ),
    ].take(limit).toList();
  }

  List<CompetitorAnalysis> _generateFallbackCompetitorAnalysis(String? category) {
    return [
      CompetitorAnalysis(
        competitorName: 'Zara',
        strengths: ['Fast fashion', 'Global presence', 'Affordable prices'],
        weaknesses: ['Quality concerns', 'Environmental impact', 'Limited customization'],
        pricingStrategy: 'Competitive pricing',
        marketShare: 0.15,
        recommendations: 'Focus on quality and sustainability',
      ),
      CompetitorAnalysis(
        competitorName: 'H&M',
        strengths: ['Wide product range', 'Sustainability initiatives', 'Collaborations'],
        weaknesses: ['Fast fashion model', 'Quality inconsistency', 'Overstock issues'],
        pricingStrategy: 'Budget-friendly pricing',
        marketShare: 0.12,
        recommendations: 'Emphasize unique value proposition',
      ),
    ];
  }
}

// Модели данных для AI аналитики

class FashionTrend {
  final String name;
  final String description;
  final double confidence;
  final int productsCount;
  final double growthRate;
  final List<String> mainBrands;
  final String targetAudience;

  FashionTrend({
    required this.name,
    required this.description,
    required this.confidence,
    required this.productsCount,
    required this.growthRate,
    required this.mainBrands,
    required this.targetAudience,
  });
}

class UserBehaviorAnalysis {
  final String userId;
  final Map<String, dynamic> purchasePatterns;
  final Map<String, dynamic> activityPatterns;
  final Map<String, dynamic> engagementMetrics;

  UserBehaviorAnalysis({
    required this.userId,
    required this.purchasePatterns,
    required this.activityPatterns,
    required this.engagementMetrics,
  });
}

class RecommendationEffectiveness {
  final double clickThroughRate;
  final double conversionRate;
  final int averageOrderValue;
  final double userEngagement;
  final double retentionRate;
  final double revenueImpact;
  final Map<String, Map<String, double>> categoryPerformance;

  RecommendationEffectiveness({
    required this.clickThroughRate,
    required this.conversionRate,
    required this.averageOrderValue,
    required this.userEngagement,
    required this.retentionRate,
    required this.revenueImpact,
    required this.categoryPerformance,
  });
}

class ContentAnalysis {
  final String content;
  final String contentType;
  final String sentiment;
  final double sentimentScore;
  final String engagementLevel;
  final double relevanceScore;
  final double qualityScore;
  final List<String> recommendations;

  ContentAnalysis({
    required this.content,
    required this.contentType,
    required this.sentiment,
    required this.sentimentScore,
    required this.engagementLevel,
    required this.relevanceScore,
    required this.qualityScore,
    required this.recommendations,
  });
}

class DemandPrediction {
  final String productName;
  final String category;
  final int predictedDemand;
  final double confidence;
  final List<String> influencingFactors;
  final String recommendations;

  DemandPrediction({
    required this.productName,
    required this.category,
    required this.predictedDemand,
    required this.confidence,
    required this.influencingFactors,
    required this.recommendations,
  });
}

class CompetitorAnalysis {
  final String competitorName;
  final List<String> strengths;
  final List<String> weaknesses;
  final String pricingStrategy;
  final double marketShare;
  final String recommendations;

  CompetitorAnalysis({
    required this.competitorName,
    required this.strengths,
    required this.weaknesses,
    required this.pricingStrategy,
    required this.marketShare,
    required this.recommendations,
  });
}
