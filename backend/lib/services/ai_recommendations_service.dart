import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';
import '../models.dart';

/// Специализированный сервис для AI рекомендаций продуктов
class AIRecommendationsService {
  final String _apiKey;
  final String _baseUrl;
  final Logger _logger = Logger();
  
  AIRecommendationsService({String? apiKey, String? baseUrl})
      : _apiKey = apiKey ?? (DotEnv()..load())['OPENAI_API_KEY'] ?? '',
        _baseUrl = baseUrl ?? (DotEnv()..load())['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';

  /// Генерация персональных рекомендаций для пользователя
  Future<List<ProductRecommendation>> generatePersonalRecommendations({
    required String userId,
    required List<Product> userHistory,
    required List<Product> availableProducts,
    required List<Product> recentlyViewed,
    int limit = 10,
  }) async {
    try {
      _logger.i('Generating personal recommendations for user: $userId');
      
      // Анализируем предпочтения пользователя
      final userPreferences = await _analyzeUserPreferences(userHistory, recentlyViewed);
      
      // Генерируем рекомендации на основе предпочтений
      final recommendations = await _generateRecommendationsByPreferences(
        userPreferences: userPreferences,
        availableProducts: availableProducts,
        limit: limit,
      );
      
      // Добавляем AI-объяснения для рекомендаций
      final enhancedRecommendations = await _enhanceRecommendationsWithAI(
        recommendations: recommendations,
        userPreferences: userPreferences,
      );
      
      _logger.i('Generated ${enhancedRecommendations.length} recommendations for user: $userId');
      return enhancedRecommendations;
      
    } catch (e) {
      _logger.e('Error generating personal recommendations: $e');
      return _generateFallbackRecommendations(availableProducts, limit);
    }
  }

  /// Генерация рекомендаций на основе похожих товаров
  Future<List<ProductRecommendation>> generateSimilarProductRecommendations({
    required Product baseProduct,
    required List<Product> availableProducts,
    int limit = 8,
  }) async {
    try {
      _logger.i('Generating similar product recommendations for: ${baseProduct.title}');
      
      final similarProducts = <ProductRecommendation>[];
      
      for (final product in availableProducts) {
        if (product.id == baseProduct.id) continue;
        
        double similarityScore = 0.0;
        
        // Схожесть по категории
        if (product.categoryId == baseProduct.categoryId) {
          similarityScore += 3.0;
        }
        
        // Схожесть по бренду
        if (product.brand != null && baseProduct.brand != null &&
            product.brand == baseProduct.brand) {
          similarityScore += 2.5;
        }
        
        // Схожесть по ценовому диапазону
        final priceDiff = (product.price - baseProduct.price).abs();
        final maxPriceDiff = baseProduct.price * 0.3;
        if (priceDiff <= maxPriceDiff) {
          similarityScore += 2.0;
        }
        
        // Схожесть по стилю (анализ названия и описания)
        final styleSimilarity = _calculateStyleSimilarity(baseProduct, product);
        similarityScore += styleSimilarity;
        
        // Схожесть по рейтингу
        if (product.rating != null && baseProduct.rating != null) {
          final ratingDiff = (product.rating! - baseProduct.rating!).abs();
          if (ratingDiff <= 0.5) {
            similarityScore += 1.0;
          }
        }
        
        if (similarityScore > 2.0) {
          similarProducts.add(ProductRecommendation(
            product: product,
            score: similarityScore,
            reason: _generateSimilarProductReason(product, baseProduct),
          ));
        }
      }
      
      // Сортируем по схожести и возвращаем топ рекомендации
      similarProducts.sort((a, b) => b.score.compareTo(a.score));
      return similarProducts.take(limit).toList();
      
    } catch (e) {
      _logger.e('Error generating similar product recommendations: $e');
      return _generateFallbackRecommendations(availableProducts, limit);
    }
  }

  /// Генерация рекомендаций для новых пользователей
  Future<List<ProductRecommendation>> generateNewUserRecommendations({
    required List<Product> availableProducts,
    required String? userLocation,
    int limit = 10,
  }) async {
    try {
      _logger.i('Generating new user recommendations');
      
      // Для новых пользователей используем популярные товары и тренды
      final popularProducts = availableProducts
          .where((p) => p.rating != null && p.rating! >= 4.0)
          .where((p) => p.reviewCount >= 10)
          .toList();
      
      // Сортируем по популярности (рейтинг * количество отзывов)
      popularProducts.sort((a, b) {
        final scoreA = (a.rating ?? 0) * a.reviewCount;
        final scoreB = (b.rating ?? 0) * b.reviewCount;
        return scoreB.compareTo(scoreA);
      });
      
      return popularProducts.take(limit).map((product) => ProductRecommendation(
        product: product,
        score: (product.rating ?? 0) * product.reviewCount.toDouble(),
        reason: 'Популярный товар с высоким рейтингом',
      )).toList();
      
    } catch (e) {
      _logger.e('Error generating new user recommendations: $e');
      return _generateFallbackRecommendations(availableProducts, limit);
    }
  }

  /// Анализ предпочтений пользователя
  Future<UserPreferences> _analyzeUserPreferences(
    List<Product> userHistory,
    List<Product> recentlyViewed,
  ) async {
    try {
      final allProducts = [...userHistory, ...recentlyViewed];
      
      // Группируем продукты по категориям и анализируем паттерны
      final categoryPreferences = <String, int>{};
      final brandPreferences = <String, int>{};
      final priceRange = <int>[];
      final stylePreferences = <String, int>{};
      final colorPreferences = <String, int>{};
      
      for (final product in allProducts) {
        // Предпочтения по категориям
        if (product.categoryId != null) {
          categoryPreferences[product.categoryId!] = 
              (categoryPreferences[product.categoryId!] ?? 0) + 1;
        }
        
        // Предпочтения по брендам
        if (product.brand != null) {
          brandPreferences[product.brand!] = 
              (brandPreferences[product.brand!] ?? 0) + 1;
        }
        
        // Ценовой диапазон
        priceRange.add(product.price);
        
        // Предпочтения по стилю (извлекаем из названия/описания)
        final style = _extractStyleFromProduct(product);
        if (style != null) {
          stylePreferences[style] = (stylePreferences[style] ?? 0) + 1;
        }
        
        // Предпочтения по цвету
        final color = _extractColorFromProduct(product);
        if (color != null) {
          colorPreferences[color] = (colorPreferences[color] ?? 0) + 1;
        }
      }
      
      // Вычисляем среднюю цену
      final avgPrice = priceRange.isNotEmpty 
          ? priceRange.reduce((a, b) => a + b) / priceRange.length 
          : 0;
      
      // Находим топ предпочтения
      final topCategories = _getTopItems(categoryPreferences, 5);
      final topBrands = _getTopItems(brandPreferences, 5);
      final topStyles = _getTopItems(stylePreferences, 5);
      final topColors = _getTopItems(colorPreferences, 5);
      
      return UserPreferences(
        topCategories: topCategories,
        topBrands: topBrands,
        topStyles: topStyles,
        topColors: topColors,
        averagePrice: avgPrice.round(),
        totalPurchases: userHistory.length,
        totalViewed: recentlyViewed.length,
      );
      
    } catch (e) {
      _logger.e('Error analyzing user preferences: $e');
      return UserPreferences.empty();
    }
  }

  /// Генерация рекомендаций на основе предпочтений
  Future<List<ProductRecommendation>> _generateRecommendationsByPreferences({
    required UserPreferences userPreferences,
    required List<Product> availableProducts,
    required int limit,
  }) async {
    try {
      final scoredProducts = <ProductRecommendation>[];
      
      for (final product in availableProducts) {
        double score = 0.0;
        final reasons = <String>[];
        
        // Оценка по категории
        if (userPreferences.topCategories.contains(product.categoryId)) {
          score += 4.0;
          reasons.add('Любимая категория');
        }
        
        // Оценка по бренду
        if (product.brand != null && 
            userPreferences.topBrands.contains(product.brand)) {
          score += 3.5;
          reasons.add('Любимый бренд');
        }
        
        // Оценка по стилю
        final style = _extractStyleFromProduct(product);
        if (style != null && userPreferences.topStyles.contains(style)) {
          score += 3.0;
          reasons.add('Любимый стиль: $style');
        }
        
        // Оценка по цвету
        final color = _extractColorFromProduct(product);
        if (color != null && userPreferences.topColors.contains(color)) {
          score += 2.5;
          reasons.add('Любимый цвет: $color');
        }
        
        // Оценка по цене (ближе к средней = выше оценка)
        final priceDiff = (product.price - userPreferences.averagePrice).abs();
        final maxPriceDiff = userPreferences.averagePrice * 0.4;
        if (priceDiff <= maxPriceDiff) {
          score += 2.0;
          reasons.add('Подходящая цена');
        }
        
        // Оценка по рейтингу
        if (product.rating != null) {
          score += product.rating! * 0.8;
          if (product.rating! >= 4.5) {
            reasons.add('Высокий рейтинг');
          }
        }
        
        // Оценка по скидке
        if (product.discount != null && product.discount! > 0) {
          score += 1.5;
          reasons.add('Скидка ${product.discount}%');
        }
        
        // Оценка по новизне
        final daysSinceCreation = DateTime.now().difference(product.createdAt).inDays;
        if (daysSinceCreation <= 7) {
          score += 1.0;
          reasons.add('Новинка');
        }
        
        if (score > 3.0) {
          scoredProducts.add(ProductRecommendation(
            product: product,
            score: score,
            reason: reasons.take(2).join(', '),
          ));
        }
      }
      
      // Сортируем по оценке и возвращаем топ рекомендации
      scoredProducts.sort((a, b) => b.score.compareTo(a.score));
      return scoredProducts.take(limit).toList();
      
    } catch (e) {
      _logger.e('Error generating recommendations by preferences: $e');
      return _generateFallbackRecommendations(availableProducts, limit);
    }
  }

  /// Улучшение рекомендаций с помощью AI
  Future<List<ProductRecommendation>> _enhanceRecommendationsWithAI({
    required List<ProductRecommendation> recommendations,
    required UserPreferences userPreferences,
  }) async {
    try {
      if (recommendations.isEmpty) return recommendations;
      
      // Создаем промпт для AI анализа
      final prompt = '''
Проанализируй следующие рекомендации товаров для пользователя и улучши объяснения:

Предпочтения пользователя:
- Любимые категории: ${userPreferences.topCategories.join(', ')}
- Любимые бренды: ${userPreferences.topBrands.join(', ')}
- Любимые стили: ${userPreferences.topStyles.join(', ')}
- Средняя цена: ${userPreferences.averagePrice} руб.

Рекомендации:
${recommendations.map((r) => '- ${r.product.title} (${r.reason})').join('\n')}

Улучши объяснения для каждой рекомендации, сделав их более персонализированными и убедительными.
''';

      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': 'Ты эксперт по модным трендам и персональным рекомендациям. Помоги пользователю понять, почему именно этот товар подходит именно ему.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 500,
        temperature: 0.7,
      );
      
      final aiExplanation = response['choices'][0]['message']['content'];
      
      // Парсим AI объяснения и обновляем рекомендации
      final enhancedRecommendations = <ProductRecommendation>[];
      final explanations = _parseAIExplanations(aiExplanation, recommendations.length);
      
      for (int i = 0; i < recommendations.length; i++) {
        final explanation = i < explanations.length ? explanations[i] : recommendations[i].reason;
        enhancedRecommendations.add(ProductRecommendation(
          product: recommendations[i].product,
          score: recommendations[i].score,
          reason: explanation,
        ));
      }
      
      return enhancedRecommendations;
      
    } catch (e) {
      _logger.e('Error enhancing recommendations with AI: $e');
      return recommendations;
    }
  }

  /// Извлечение стиля из продукта
  String? _extractStyleFromProduct(Product product) {
    final title = product.title.toLowerCase();
    final description = (product.description ?? '').toLowerCase();
    final text = '$title $description';
    
    final styleKeywords = {
      'casual': ['повседневный', 'casual', 'повседневная', 'комфортный'],
      'business': ['деловой', 'business', 'офисный', 'формальный'],
      'sport': ['спортивный', 'sport', 'спортивная', 'активный'],
      'elegant': ['элегантный', 'elegant', 'изысканный', 'утонченный'],
      'street': ['уличный', 'street', 'urban', 'городской'],
      'vintage': ['винтажный', 'vintage', 'ретро', 'классический'],
      'modern': ['современный', 'modern', 'актуальный', 'трендовый'],
    };
    
    for (final entry in styleKeywords.entries) {
      if (entry.value.any((keyword) => text.contains(keyword))) {
        return entry.key;
      }
    }
    
    return null;
  }

  /// Извлечение цвета из продукта
  String? _extractColorFromProduct(Product product) {
    final title = product.title.toLowerCase();
    final description = (product.description ?? '').toLowerCase();
    final text = '$title $description';
    
    final colorKeywords = {
      'black': ['черный', 'black', 'черная'],
      'white': ['белый', 'white', 'белая'],
      'red': ['красный', 'red', 'красная'],
      'blue': ['синий', 'blue', 'синяя', 'голубой'],
      'green': ['зеленый', 'green', 'зеленая'],
      'yellow': ['желтый', 'yellow', 'желтая'],
      'pink': ['розовый', 'pink', 'розовая'],
      'purple': ['фиолетовый', 'purple', 'фиолетовая'],
      'brown': ['коричневый', 'brown', 'коричневая'],
      'gray': ['серый', 'gray', 'серая', 'серый'],
    };
    
    for (final entry in colorKeywords.entries) {
      if (entry.value.any((keyword) => text.contains(keyword))) {
        return entry.key;
      }
    }
    
    return null;
  }

  /// Вычисление схожести стилей
  double _calculateStyleSimilarity(Product product1, Product product2) {
    final style1 = _extractStyleFromProduct(product1);
    final style2 = _extractStyleFromProduct(product2);
    
    if (style1 == null || style2 == null) return 0.0;
    
    if (style1 == style2) return 3.0;
    
    // Схожие стили
    final similarStyles = {
      'casual': ['street', 'sport'],
      'business': ['elegant'],
      'elegant': ['business', 'modern'],
      'street': ['casual', 'sport'],
      'sport': ['casual', 'street'],
      'modern': ['elegant', 'casual'],
    };
    
    if (similarStyles[style1]?.contains(style2) == true) {
      return 1.5;
    }
    
    return 0.0;
  }

  /// Генерация причины для похожего продукта
  String _generateSimilarProductReason(Product product, Product baseProduct) {
    final reasons = <String>[];
    
    if (product.categoryId == baseProduct.categoryId) {
      reasons.add('Та же категория');
    }
    
    if (product.brand == baseProduct.brand) {
      reasons.add('Тот же бренд');
    }
    
    final style1 = _extractStyleFromProduct(baseProduct);
    final style2 = _extractStyleFromProduct(product);
    if (style1 == style2 && style1 != null) {
      reasons.add('Такой же стиль');
    }
    
    if (reasons.isEmpty) {
      reasons.add('Похожий товар');
    }
    
    return reasons.join(', ');
  }

  /// Получение топ элементов из Map
  List<String> _getTopItems(Map<String, int> items, int limit) {
    final sorted = items.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// Генерация fallback рекомендаций
  List<ProductRecommendation> _generateFallbackRecommendations(
    List<Product> availableProducts,
    int limit,
  ) {
    try {
      // Возвращаем популярные товары с высоким рейтингом
      final popularProducts = availableProducts
          .where((p) => p.rating != null && p.rating! >= 4.0)
          .toList();
      
      popularProducts.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      
      return popularProducts.take(limit).map((product) => ProductRecommendation(
        product: product,
        score: product.rating ?? 0,
        reason: 'Популярный товар',
      )).toList();
      
    } catch (e) {
      _logger.e('Error generating fallback recommendations: $e');
      return [];
    }
  }

  /// Парсинг AI объяснений
  List<String> _parseAIExplanations(String aiText, int expectedCount) {
    try {
      final lines = aiText.split('\n');
      final explanations = <String>[];
      
      for (final line in lines) {
        if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
          final explanation = line.trim().substring(1).trim();
          if (explanation.isNotEmpty) {
            explanations.add(explanation);
          }
        }
      }
      
      // Если не удалось распарсить, возвращаем исходный текст
      if (explanations.length != expectedCount) {
        return List.generate(expectedCount, (index) => 'Персонализированная рекомендация ${index + 1}');
      }
      
      return explanations;
      
    } catch (e) {
      _logger.e('Error parsing AI explanations: $e');
      return List.generate(expectedCount, (index) => 'Персонализированная рекомендация ${index + 1}');
    }
  }

  /// Запрос к OpenAI API
  Future<Map<String, dynamic>> _makeOpenAIRequest({
    required String model,
    required List<Map<String, String>> messages,
    int? maxTokens,
    double? temperature,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
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

  /// Очистка ресурсов
  void dispose() {
    // Нет необходимости в очистке для этого сервиса
  }
}

/// Расширенная модель предпочтений пользователя
class UserPreferences {
  final List<String> topCategories;
  final List<String> topBrands;
  final List<String> topStyles;
  final List<String> topColors;
  final int averagePrice;
  final int totalPurchases;
  final int totalViewed;
  
  UserPreferences({
    required this.topCategories,
    required this.topBrands,
    required this.topStyles,
    required this.topColors,
    required this.averagePrice,
    required this.totalPurchases,
    required this.totalViewed,
  });
  
  UserPreferences.empty()
      : topCategories = [],
        topBrands = [],
        topStyles = [],
        topColors = [],
        averagePrice = 0,
        totalPurchases = 0,
        totalViewed = 0;
}

/// Модель рекомендации продукта
class ProductRecommendation {
  final Product product;
  final double score;
  final String reason;
  
  ProductRecommendation({
    required this.product,
    required this.score,
    required this.reason,
  });
}
