import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:openai_dart/openai_dart.dart';
import 'package:redis/redis.dart';
import '../database.dart';
import '../models.dart';

class AIService {
  final DatabaseService _db;
  final RedisConnection _redis;
  late final OpenAI _openai;
  
  // Cache keys
  static const String _cachePrefix = 'ai:';
  static const String _recommendationsCacheKey = 'recommendations';
  static const String _descriptionsCacheKey = 'descriptions';
  
  // OpenAI configuration
  static const String _openaiApiKey = 'YOUR_OPENAI_API_KEY'; // Set in environment
  static const String _openaiModel = 'gpt-4';
  
  AIService(this._db, this._redis) {
    _initializeOpenAI();
  }

  /// Инициализация OpenAI клиента
  void _initializeOpenAI() {
    try {
      _openai = OpenAI.instance.build(
        token: _openaiApiKey,
        baseUrl: 'https://api.openai.com/v1',
      );
      print('AI service initialized successfully');
    } catch (e) {
      print('Error initializing AI service: $e');
    }
  }

  /// Генерация AI рекомендаций товаров
  Future<List<Product>> getAIRecommendations({
    required String userId,
    int limit = 10,
    bool useCache = true,
  }) async {
    try {
      if (useCache) {
        final cached = await _getCachedRecommendations(userId);
        if (cached.isNotEmpty) {
          return cached.take(limit).toList();
        }
      }
      
      // Получаем историю покупок и предпочтения пользователя
      final userPreferences = await _getUserPreferences(userId);
      
      // Получаем товары для анализа
      final products = await _getProductsForAnalysis();
      
      // Генерируем рекомендации с помощью AI
      final recommendations = await _generateRecommendationsWithAI(
        userPreferences: userPreferences,
        products: products,
        limit: limit,
      );
      
      // Кэшируем рекомендации
      if (useCache) {
        await _cacheRecommendations(userId, recommendations);
      }
      
      return recommendations;
      
    } catch (e) {
      print('Error getting AI recommendations: $e');
      // Fallback to simple recommendations
      return await _getFallbackRecommendations(userId, limit);
    }
  }

  /// Генерация описания товара с помощью AI
  Future<String> generateProductDescription({
    required String title,
    required String brand,
    required Map<String, dynamic> specifications,
    String? existingDescription,
  }) async {
    try {
      // Проверяем кэш
      final cacheKey = '$_cachePrefix${_descriptionsCacheKey}:${title.hashCode}';
      final cached = await _redis.get(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      // Формируем промпт для AI
      final prompt = _buildDescriptionPrompt(
        title: title,
        brand: brand,
        specifications: specifications,
        existingDescription: existingDescription,
      );
      
      // Генерируем описание
      final completion = await _openai.onChatCompletion(
        request: ChatCompletionRequest(
          model: _openaiModel,
          messages: [
            ChatMessage(
              role: ChatMessageRole.system,
              content: 'Ты эксперт по модной одежде и стилю. Создавай привлекательные и информативные описания товаров.',
            ),
            ChatMessage(
              role: ChatMessageRole.user,
              content: prompt,
            ),
          ],
          maxTokens: 300,
          temperature: 0.7,
        ),
      );
      
      final description = completion.choices.first.message.content;
      
      // Кэшируем результат
      await _redis.setex(cacheKey, 3600, description); // Cache for 1 hour
      
      return description;
      
    } catch (e) {
      print('Error generating product description: $e');
      return existingDescription ?? 'Описание товара временно недоступно';
    }
  }

  /// AI модерация контента
  Future<Map<String, dynamic>> moderateContent({
    required String content,
    required String contentType, // 'post', 'comment', 'product_description'
  }) async {
    try {
      // Проверяем контент на токсичность и нежелательные элементы
      final moderation = await _openai.onModeration(
        request: ModerationRequest(
          input: content,
        ),
      );
      
      final results = moderation.results.first;
      final categories = results.categories;
      
      // Анализируем результаты модерации
      final isApproved = !results.flagged;
      final flags = <String, bool>{};
      
      if (categories.hate) flags['hate'] = true;
      if (categories.hateThreatening) flags['hate_threatening'] = true;
      if (categories.selfHarm) flags['self_harm'] = true;
      if (categories.sexual) flags['sexual'] = true;
      if (categories.sexualMinors) flags['sexual_minors'] = true;
      if (categories.violence) flags['violence'] = true;
      if (categories.violenceGraphic) flags['violence_graphic'] = true;
      
      // Дополнительная проверка для постов и комментариев
      if (contentType == 'post' || contentType == 'comment') {
        final sentiment = await _analyzeSentiment(content);
        flags['negative_sentiment'] = sentiment < 0.3;
      }
      
      return {
        'is_approved': isApproved,
        'flags': flags,
        'confidence': results.categoryScores,
        'recommendation': isApproved ? 'approve' : 'review',
      };
      
    } catch (e) {
      print('Error moderating content: $e');
      return {
        'is_approved': true, // Default to approve on error
        'flags': {},
        'confidence': {},
        'recommendation': 'approve',
      };
    }
  }

  /// Анализ настроения текста
  Future<double> analyzeSentiment(String text) async {
    try {
      final completion = await _openai.onChatCompletion(
        request: ChatCompletionRequest(
          model: _openaiModel,
          messages: [
            ChatMessage(
              role: ChatMessageRole.system,
              content: 'Проанализируй настроение текста и верни число от 0 до 1, где 0 - очень негативное, 1 - очень позитивное.',
            ),
            ChatMessage(
              role: ChatMessageRole.user,
              content: 'Проанализируй настроение этого текста: $text',
            ),
          ],
          maxTokens: 50,
          temperature: 0.1,
        ),
      );
      
      final response = completion.choices.first.message.content;
      final sentimentMatch = RegExp(r'(\d+\.?\d*)').firstMatch(response);
      
      if (sentimentMatch != null) {
        final sentiment = double.tryParse(sentimentMatch.group(1)!);
        if (sentiment != null && sentiment >= 0 && sentiment <= 1) {
          return sentiment;
        }
      }
      
      return 0.5; // Default neutral sentiment
      
    } catch (e) {
      print('Error analyzing sentiment: $e');
      return 0.5;
    }
  }

  /// Генерация хештегов для поста
  Future<List<String>> generateHashtags({
    required String content,
    required String category,
    int limit = 5,
  }) async {
    try {
      final prompt = '''
        Сгенерируй $limit релевантных хештегов для поста в Instagram о $category.
        Контент: $content
        
        Верни только хештеги, разделенные запятыми, без символа #.
        Пример: MyModusLook, FashionStyle, TrendyOutfit
      ''';
      
      final completion = await _openai.onChatCompletion(
        request: ChatCompletionRequest(
          model: _openaiModel,
          messages: [
            ChatMessage(
              role: ChatMessageRole.system,
              content: 'Ты эксперт по социальным сетям и модным трендам.',
            ),
            ChatMessage(
              role: ChatMessageRole.user,
              content: prompt,
            ),
          ],
          maxTokens: 100,
          temperature: 0.8,
        ),
      );
      
      final response = completion.choices.first.message.content;
      final hashtags = response
          .split(',')
          .map((tag) => tag.trim().replaceAll('#', ''))
          .where((tag) => tag.isNotEmpty)
          .take(limit)
          .toList();
      
      return hashtags;
      
    } catch (e) {
      print('Error generating hashtags: $e');
      // Fallback hashtags
      return ['MyModusLook', 'Fashion', 'Style', 'Trendy', 'Outfit'];
    }
  }

  /// Получение предпочтений пользователя
  Future<Map<String, dynamic>> _getUserPreferences(String userId) async {
    try {
      final conn = await _db.getConnection();
      
      // История покупок
      final purchaseHistory = await conn.execute('''
        SELECT p.category_id, p.brand, p.price, p.rating
        FROM products p
        JOIN orders o ON p.id = o.product_id
        WHERE o.user_id = @userId
        ORDER BY o.created_at DESC
        LIMIT 50
      ''', substitutionValues: {'userId': userId});
      
      // Лайки и предпочтения
      final likes = await conn.execute('''
        SELECT p.category_id, p.brand, p.price
        FROM products p
        JOIN likes l ON p.id = l.target_id
        WHERE l.user_id = @userId AND l.target_type = 'product'
        ORDER BY l.created_at DESC
        LIMIT 30
      ''', substitutionValues: {'userId': userId});
      
      // Просмотры товаров
      final views = await conn.execute('''
        SELECT p.category_id, p.brand, p.price
        FROM products p
        JOIN product_views v ON p.id = v.product_id
        WHERE v.user_id = @userId
        ORDER BY v.viewed_at DESC
        LIMIT 100
      ''', substitutionValues: {'userId': userId});
      
      await conn.close();
      
      return {
        'purchase_history': purchaseHistory,
        'likes': likes,
        'views': views,
      };
      
    } catch (e) {
      print('Error getting user preferences: $e');
      return {};
    }
  }

  /// Получение товаров для анализа
  Future<List<Product>> _getProductsForAnalysis() async {
    try {
      final conn = await _db.getConnection();
      
      final result = await conn.execute('''
        SELECT * FROM products 
        WHERE is_active = true 
        ORDER BY rating DESC, review_count DESC 
        LIMIT 1000
      ''');
      
      await conn.close();
      
      return result.map((row) => Product.fromRow(row)).toList();
      
    } catch (e) {
      print('Error getting products for analysis: $e');
      return [];
    }
  }

  /// Генерация рекомендаций с помощью AI
  Future<List<Product>> _generateRecommendationsWithAI({
    required Map<String, dynamic> userPreferences,
    required List<Product> products,
    required int limit,
  }) async {
    try {
      // Анализируем предпочтения пользователя
      final preferences = _analyzeUserPreferences(userPreferences);
      
      // Фильтруем и ранжируем товары
      final filteredProducts = products.where((product) {
        // Проверяем соответствие категории
        if (preferences['preferred_categories'].isNotEmpty) {
          if (!preferences['preferred_categories'].contains(product.category)) {
            return false;
          }
        }
        
        // Проверяем соответствие бренду
        if (preferences['preferred_brands'].isNotEmpty) {
          if (!preferences['preferred_brands'].contains(product.brand)) {
            return false;
          }
        }
        
        // Проверяем ценовой диапазон
        if (product.price < preferences['min_price'] || 
            product.price > preferences['max_price']) {
          return false;
        }
        
        return true;
      }).toList();
      
      // Ранжируем по релевантности
      final rankedProducts = filteredProducts.map((product) {
        double score = 0.0;
        
        // Базовый рейтинг
        score += (product.rating ?? 0.0) * 0.3;
        
        // Популярность
        score += (product.reviewCount / 100.0) * 0.2;
        
        // Соответствие предпочтениям
        if (preferences['preferred_categories'].contains(product.category)) {
          score += 0.3;
        }
        if (preferences['preferred_brands'].contains(product.brand)) {
          score += 0.2;
        }
        
        return {'product': product, 'score': score};
      }).toList();
      
      // Сортируем по рейтингу и берем топ
      rankedProducts.sort((a, b) => b['score'].compareTo(a['score']));
      
      return rankedProducts
          .take(limit)
          .map((item) => item['product'] as Product)
          .toList();
      
    } catch (e) {
      print('Error generating AI recommendations: $e');
      return [];
    }
  }

  /// Анализ предпочтений пользователя
  Map<String, dynamic> _analyzeUserPreferences(Map<String, dynamic> preferences) {
    final categories = <String, int>{};
    final brands = <String, int>{};
    final prices = <int>[];
    
    // Анализируем историю покупок
    for (final purchase in preferences['purchase_history'] ?? []) {
      final category = purchase[0]?.toString() ?? '';
      final brand = purchase[1]?.toString() ?? '';
      final price = purchase[2] as int? ?? 0;
      
      if (category.isNotEmpty) {
        categories[category] = (categories[category] ?? 0) + 1;
      }
      if (brand.isNotEmpty) {
        brands[brand] = (brands[brand] ?? 0) + 1;
      }
      if (price > 0) {
        prices.add(price);
      }
    }
    
    // Анализируем лайки
    for (final like in preferences['likes'] ?? []) {
      final category = like[0]?.toString() ?? '';
      final brand = like[1]?.toString() ?? '';
      
      if (category.isNotEmpty) {
        categories[category] = (categories[category] ?? 0) + 1;
      }
      if (brand.isNotEmpty) {
        brands[brand] = (brands[brand] ?? 0) + 1;
      }
    }
    
    // Определяем предпочтения
    final preferredCategories = categories.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .toList();
    
    final preferredBrands = brands.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .toList();
    
    // Ценовой диапазон
    final minPrice = prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 1000;
    final maxPrice = prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b) : 50000;
    
    return {
      'preferred_categories': preferredCategories,
      'preferred_brands': preferredBrands,
      'min_price': minPrice,
      'max_price': maxPrice,
    };
  }

  /// Получение кэшированных рекомендаций
  Future<List<Product>> _getCachedRecommendations(String userId) async {
    try {
      final cacheKey = '$_cachePrefix${_recommendationsCacheKey}:$userId';
      final cached = await _redis.get(cacheKey);
      
      if (cached != null) {
        // Здесь нужно десериализовать JSON в List<Product>
        // Для простоты возвращаем пустой список
        return [];
      }
    } catch (e) {
      print('Error getting cached recommendations: $e');
    }
    
    return [];
  }

  /// Кэширование рекомендаций
  Future<void> _cacheRecommendations(String userId, List<Product> recommendations) async {
    try {
      final cacheKey = '$_cachePrefix${_recommendationsCacheKey}:$userId';
      // await _redis.setex(cacheKey, 1800, jsonEncode(recommendations)); // Cache for 30 minutes
    } catch (e) {
      print('Error caching recommendations: $e');
    }
  }

  /// Fallback рекомендации (без AI)
  Future<List<Product>> _getFallbackRecommendations(String userId, int limit) async {
    try {
      final conn = await _db.getConnection();
      
      final result = await conn.execute('''
        SELECT * FROM products 
        WHERE is_active = true 
        ORDER BY rating DESC, review_count DESC 
        LIMIT @limit
      ''', substitutionValues: {'limit': limit});
      
      await conn.close();
      
      return result.map((row) => Product.fromRow(row)).toList();
      
    } catch (e) {
      print('Error getting fallback recommendations: $e');
      return [];
    }
  }

  /// Построение промпта для генерации описания
  String _buildDescriptionPrompt({
    required String title,
    required String brand,
    required Map<String, dynamic> specifications,
    String? existingDescription,
  }) {
    final specs = specifications.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');
    
    return '''
      Создай привлекательное описание для товара:
      
      Название: $title
      Бренд: $brand
      Характеристики: $specs
      ${existingDescription != null ? 'Существующее описание: $existingDescription' : ''}
      
      Требования:
      - Описание должно быть привлекательным и продающим
      - Упоминай ключевые особенности товара
      - Используй модные термины и тренды
      - Длина: 2-3 предложения
      - Стиль: дружелюбный, современный
      
      Создай новое описание:
    ''';
  }
}
