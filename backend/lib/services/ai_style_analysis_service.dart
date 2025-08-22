import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';
import '../models.dart';

/// Специализированный сервис для AI анализа стиля
class AIStyleAnalysisService {
  final String _apiKey;
  final String _baseUrl;
  final Logger _logger = Logger();
  
  AIStyleAnalysisService({String? apiKey, String? baseUrl})
      : _apiKey = apiKey ?? (DotEnv()..load())['OPENAI_API_KEY'] ?? '',
        _baseUrl = baseUrl ?? (DotEnv()..load())['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';

  /// Анализ стиля пользователя на основе истории покупок
  Future<UserStyleProfile> analyzeUserStyle({
    required String userId,
    required List<Product> purchaseHistory,
    required List<Product> wishlist,
    required List<Product> recentlyViewed,
    String? userPreferences,
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Analyzing style for user: $userId');
      
      // Анализируем покупки и предпочтения
      final styleAnalysis = await _analyzeStyleFromProducts(
        purchaseHistory: purchaseHistory,
        wishlist: wishlist,
        recentlyViewed: recentlyViewed,
        userPreferences: userPreferences,
        language: language,
      );
      
      // Генерируем AI-анализ стиля
      final aiStyleAnalysis = await _generateAIStyleAnalysis(
        styleAnalysis: styleAnalysis,
        language: language,
      );
      
      // Создаем профиль стиля
      final styleProfile = UserStyleProfile(
        userId: userId,
        primaryStyle: styleAnalysis.primaryStyle,
        secondaryStyles: styleAnalysis.secondaryStyles,
        colorPalette: styleAnalysis.colorPalette,
        brandPreferences: styleAnalysis.brandPreferences,
        priceRange: styleAnalysis.priceRange,
        occasionPreferences: styleAnalysis.occasionPreferences,
        seasonPreferences: styleAnalysis.seasonPreferences,
        styleConfidence: styleAnalysis.styleConfidence,
        aiInsights: aiStyleAnalysis,
        lastUpdated: DateTime.now(),
      );
      
      _logger.i('Style analysis completed for user: $userId');
      return styleProfile;
      
    } catch (e) {
      _logger.e('Error analyzing user style: $e');
      return _generateFallbackStyleProfile(userId, language);
    }
  }

  /// Анализ совместимости стилей
  Future<StyleCompatibility> analyzeStyleCompatibility({
    required String userStyle,
    required String productStyle,
    required Map<String, dynamic> productAttributes,
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Analyzing style compatibility: $userStyle vs $productStyle');
      
      final prompt = _buildStyleCompatibilityPrompt(
        userStyle: userStyle,
        productStyle: productStyle,
        productAttributes: productAttributes,
        language: language,
      );
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': _getSystemPromptForStyleCompatibility(language),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 300,
        temperature: 0.7,
      );
      
      final content = response['choices'][0]['message']['content'];
      
      // Парсим анализ совместимости
      final compatibility = _parseStyleCompatibility(content, userStyle, productStyle, language);
      
      _logger.i('Style compatibility analysis completed');
      return compatibility;
      
    } catch (e) {
      _logger.e('Error analyzing style compatibility: $e');
      return _generateFallbackStyleCompatibility(userStyle, productStyle, language);
    }
  }

  /// Генерация рекомендаций по стилю
  Future<List<StyleRecommendation>> generateStyleRecommendations({
    required UserStyleProfile userStyleProfile,
    required List<Product> availableProducts,
    required String occasion,
    required String season,
    int limit = 10,
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Generating style recommendations for user: ${userStyleProfile.userId}');
      
      // Фильтруем продукты по стилю и параметрам
      final filteredProducts = _filterProductsByStyle(
        products: availableProducts,
        userStyle: userStyleProfile,
        occasion: occasion,
        season: season,
      );
      
      // Оцениваем совместимость каждого продукта
      final scoredProducts = <StyleRecommendation>[];
      
      for (final product in filteredProducts) {
        final compatibility = await analyzeStyleCompatibility(
          userStyle: userStyleProfile.primaryStyle,
          productStyle: _extractStyleFromProduct(product),
          productAttributes: _extractProductAttributes(product),
          language: language,
        );
        
        if (compatibility.score >= 0.6) {
          scoredProducts.add(StyleRecommendation(
            product: product,
            styleScore: compatibility.score,
            compatibilityReason: compatibility.reason,
            occasion: occasion,
            season: season,
            styleTips: compatibility.styleTips,
          ));
        }
      }
      
      // Сортируем по оценке стиля
      scoredProducts.sort((a, b) => b.styleScore.compareTo(a.styleScore));
      
      final recommendations = scoredProducts.take(limit).toList();
      
      // Улучшаем рекомендации с помощью AI
      final enhancedRecommendations = await _enhanceStyleRecommendations(
        recommendations: recommendations,
        userStyleProfile: userStyleProfile,
        language: language,
      );
      
      _logger.i('Generated ${enhancedRecommendations.length} style recommendations');
      return enhancedRecommendations;
      
    } catch (e) {
      _logger.e('Error generating style recommendations: $e');
      return _generateFallbackStyleRecommendations(availableProducts, limit);
    }
  }

  /// Анализ трендов стиля
  Future<StyleTrends> analyzeStyleTrends({
    required String category,
    required String season,
    String? location,
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Analyzing style trends for: $category in $season');
      
      final prompt = _buildStyleTrendsPrompt(
        category: category,
        season: season,
        location: location,
        language: language,
      );
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': _getSystemPromptForStyleTrends(language),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 400,
        temperature: 0.8,
      );
      
      final content = response['choices'][0]['message']['content'];
      
      // Парсим анализ трендов
      final trends = _parseStyleTrends(content, category, season, language);
      
      _logger.i('Style trends analysis completed');
      return trends;
      
    } catch (e) {
      _logger.e('Error analyzing style trends: $e');
      return _generateFallbackStyleTrends(category, season, language);
    }
  }

  /// Создание капсульного гардероба
  Future<CapsuleWardrobe> createCapsuleWardrobe({
    required UserStyleProfile userStyleProfile,
    required String occasion,
    required String season,
    required int itemCount,
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Creating capsule wardrobe for user: ${userStyleProfile.userId}');
      
      final prompt = _buildCapsuleWardrobePrompt(
        userStyleProfile: userStyleProfile,
        occasion: occasion,
        season: season,
        itemCount: itemCount,
        language: language,
      );
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': _getSystemPromptForCapsuleWardrobe(language),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 500,
        temperature: 0.7,
      );
      
      final content = response['choices'][0]['message']['content'];
      
      // Парсим капсульный гардероб
      final wardrobe = _parseCapsuleWardrobe(content, userStyleProfile, occasion, season, language);
      
      _logger.i('Capsule wardrobe created successfully');
      return wardrobe;
      
    } catch (e) {
      _logger.e('Error creating capsule wardrobe: $e');
      return _generateFallbackCapsuleWardrobe(userStyleProfile, occasion, season, itemCount, language);
    }
  }

  // Вспомогательные методы

  /// Анализ стиля из продуктов
  Future<StyleAnalysis> _analyzeStyleFromProducts({
    required List<Product> purchaseHistory,
    required List<Product> wishlist,
    required List<Product> recentlyViewed,
    String? userPreferences,
    required String language,
  }) async {
    try {
      final allProducts = [...purchaseHistory, ...wishlist, ...recentlyViewed];
      
      // Анализируем стили
      final styleCounts = <String, int>{};
      final colorCounts = <String, int>{};
      final brandCounts = <String, int>{};
      final priceRange = <int>[];
      final occasionCounts = <String, int>{};
      final seasonCounts = <String, int>{};
      
      for (final product in allProducts) {
        // Стиль
        final style = _extractStyleFromProduct(product);
        if (style != null) {
          styleCounts[style] = (styleCounts[style] ?? 0) + 1;
        }
        
        // Цвет
        final color = _extractColorFromProduct(product);
        if (color != null) {
          colorCounts[color] = (colorCounts[color] ?? 0) + 1;
        }
        
        // Бренд
        if (product.brand != null) {
          brandCounts[product.brand!] = (brandCounts[product.brand!] ?? 0) + 1;
        }
        
        // Цена
        priceRange.add(product.price);
        
        // Повод и сезон (извлекаем из названия/описания)
        final occasion = _extractOccasionFromProduct(product);
        if (occasion != null) {
          occasionCounts[occasion] = (occasionCounts[occasion] ?? 0) + 1;
        }
        
        final season = _extractSeasonFromProduct(product);
        if (season != null) {
          seasonCounts[season] = (seasonCounts[season] ?? 0) + 1;
        }
      }
      
      // Определяем основной стиль
      final primaryStyle = _getTopItem(styleCounts);
      final secondaryStyles = _getTopItems(styleCounts, 3).where((s) => s != primaryStyle).toList();
      
      // Определяем цветовую палитру
      final colorPalette = _getTopItems(colorCounts, 5);
      
      // Определяем предпочтения по брендам
      final brandPreferences = _getTopItems(brandCounts, 5);
      
      // Определяем ценовой диапазон
      final avgPrice = priceRange.isNotEmpty 
          ? priceRange.reduce((a, b) => a + b) / priceRange.length 
          : 0;
      
      // Определяем предпочтения по поводам
      final occasionPreferences = _getTopItems(occasionCounts, 3);
      
      // Определяем предпочтения по сезонам
      final seasonPreferences = _getTopItems(seasonCounts, 2);
      
      // Вычисляем уверенность в стиле
      final styleConfidence = _calculateStyleConfidence(allProducts.length, styleCounts.length);
      
      return StyleAnalysis(
        primaryStyle: primaryStyle ?? 'casual',
        secondaryStyles: secondaryStyles,
        colorPalette: colorPalette,
        brandPreferences: brandPreferences,
        priceRange: PriceRange(
          min: priceRange.isNotEmpty ? priceRange.reduce((a, b) => a < b ? a : b) : 0,
          max: priceRange.isNotEmpty ? priceRange.reduce((a, b) => a > b ? a : b) : 0,
          average: avgPrice.round(),
        ),
        occasionPreferences: occasionPreferences,
        seasonPreferences: seasonPreferences,
        styleConfidence: styleConfidence,
      );
      
    } catch (e) {
      _logger.e('Error analyzing style from products: $e');
      return StyleAnalysis.empty();
    }
  }

  /// Генерация AI анализа стиля
  Future<String> _generateAIStyleAnalysis({
    required StyleAnalysis styleAnalysis,
    required String language,
  }) async {
    try {
      final prompt = '''
Проанализируй стиль пользователя и дай рекомендации:

Основной стиль: ${styleAnalysis.primaryStyle}
Дополнительные стили: ${styleAnalysis.secondaryStyles.join(', ')}
Цветовая палитра: ${styleAnalysis.colorPalette.join(', ')}
Любимые бренды: ${styleAnalysis.brandPreferences.join(', ')}
Ценовой диапазон: ${styleAnalysis.priceRange.average} ₽
Любимые поводы: ${styleAnalysis.occasionPreferences.join(', ')}
Любимые сезоны: ${styleAnalysis.seasonPreferences.join(', ')}

Дай краткий анализ стиля и 2-3 совета по улучшению.
''';

      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': _getSystemPromptForStyleAnalysis(language),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 200,
        temperature: 0.7,
      );
      
      return response['choices'][0]['message']['content'];
      
    } catch (e) {
      _logger.e('Error generating AI style analysis: $e');
      return language == 'ru' 
          ? 'Стиль пользователя проанализирован. Рекомендуется экспериментировать с новыми образами.'
          : 'User style analyzed. Recommended to experiment with new looks.';
    }
  }

  /// Фильтрация продуктов по стилю
  List<Product> _filterProductsByStyle({
    required List<Product> products,
    required UserStyleProfile userStyle,
    required String occasion,
    required String season,
  }) {
    return products.where((product) {
      // Проверяем совместимость по стилю
      final productStyle = _extractStyleFromProduct(product);
      if (productStyle != null) {
        if (productStyle == userStyle.primaryStyle) return true;
        if (userStyle.secondaryStyles.contains(productStyle)) return true;
      }
      
      // Проверяем совместимость по цвету
      final productColor = _extractColorFromProduct(product);
      if (productColor != null && userStyle.colorPalette.contains(productColor)) {
        return true;
      }
      
      // Проверяем совместимость по бренду
      if (product.brand != null && userStyle.brandPreferences.contains(product.brand)) {
        return true;
      }
      
      // Проверяем ценовой диапазон
      if (product.price >= userStyle.priceRange.min && 
          product.price <= userStyle.priceRange.max) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Извлечение стиля из продукта
  String _extractStyleFromProduct(Product product) {
    final title = product.title.toLowerCase();
    final description = (product.description ?? '').toLowerCase();
    final text = '$title $description';
    
    final styleKeywords = {
      'casual': ['повседневный', 'casual', 'повседневная', 'комфортный', 'уютный'],
      'business': ['деловой', 'business', 'офисный', 'формальный', 'корпоративный'],
      'sport': ['спортивный', 'sport', 'спортивная', 'активный', 'тренировка'],
      'elegant': ['элегантный', 'elegant', 'изысканный', 'утонченный', 'премиум'],
      'street': ['уличный', 'street', 'urban', 'городской', 'молодежный'],
      'vintage': ['винтажный', 'vintage', 'ретро', 'классический', 'старинный'],
      'modern': ['современный', 'modern', 'актуальный', 'трендовый', 'новый'],
      'bohemian': ['богемный', 'bohemian', 'творческий', 'артистичный', 'свободный'],
      'minimalist': ['минималистичный', 'minimalist', 'простой', 'лаконичный', 'чистый'],
    };
    
    for (final entry in styleKeywords.entries) {
      if (entry.value.any((keyword) => text.contains(keyword))) {
        return entry.key;
      }
    }
    
    return 'casual'; // По умолчанию
  }

  /// Извлечение цвета из продукта
  String? _extractColorFromProduct(Product product) {
    final title = product.title.toLowerCase();
    final description = (product.description ?? '').toLowerCase();
    final text = '$title $description';
    
    final colorKeywords = {
      'black': ['черный', 'black', 'черная', 'темный'],
      'white': ['белый', 'white', 'белая', 'светлый'],
      'red': ['красный', 'red', 'красная', 'алый'],
      'blue': ['синий', 'blue', 'синяя', 'голубой', 'лазурный'],
      'green': ['зеленый', 'green', 'зеленая', 'изумрудный'],
      'yellow': ['желтый', 'yellow', 'желтая', 'золотой'],
      'pink': ['розовый', 'pink', 'розовая', 'малиновый'],
      'purple': ['фиолетовый', 'purple', 'фиолетовая', 'сиреневый'],
      'brown': ['коричневый', 'brown', 'коричневая', 'бежевый'],
      'gray': ['серый', 'gray', 'серая', 'серый', 'серебристый'],
    };
    
    for (final entry in colorKeywords.entries) {
      if (entry.value.any((keyword) => text.contains(keyword))) {
        return entry.key;
      }
    }
    
    return null;
  }

  /// Извлечение повода из продукта
  String? _extractOccasionFromProduct(Product product) {
    final title = product.title.toLowerCase();
    final description = (product.description ?? '').toLowerCase();
    final text = '$title $description';
    
    final occasionKeywords = {
      'everyday': ['повседневный', 'everyday', 'обычный', 'день'],
      'work': ['работа', 'work', 'офис', 'деловой'],
      'party': ['вечеринка', 'party', 'праздник', 'торжество'],
      'date': ['свидание', 'date', 'романтичный', 'вечер'],
      'sport': ['спорт', 'sport', 'тренировка', 'активный'],
      'formal': ['формальный', 'formal', 'официальный', 'церемония'],
    };
    
    for (final entry in occasionKeywords.entries) {
      if (entry.value.any((keyword) => text.contains(keyword))) {
        return entry.key;
      }
    }
    
    return null;
  }

  /// Извлечение сезона из продукта
  String? _extractSeasonFromProduct(Product product) {
    final title = product.title.toLowerCase();
    final description = (product.description ?? '').toLowerCase();
    final text = '$title $description';
    
    final seasonKeywords = {
      'spring': ['весна', 'spring', 'весенний', 'цветочный'],
      'summer': ['лето', 'summer', 'летний', 'легкий'],
      'autumn': ['осень', 'autumn', 'осенний', 'теплый'],
      'winter': ['зима', 'winter', 'зимний', 'теплый'],
    };
    
    for (final entry in seasonKeywords.entries) {
      if (entry.value.any((keyword) => text.contains(keyword))) {
        return entry.key;
      }
    }
    
    return null;
  }

  /// Извлечение атрибутов продукта
  Map<String, dynamic> _extractProductAttributes(Product product) {
    return {
      'title': product.title,
      'category': product.categoryId,
      'brand': product.brand,
      'price': product.price,
      'style': _extractStyleFromProduct(product),
      'color': _extractColorFromProduct(product),
      'occasion': _extractOccasionFromProduct(product),
      'season': _extractSeasonFromProduct(product),
    };
  }

  /// Получение топ элемента
  String? _getTopItem(Map<String, int> items) {
    if (items.isEmpty) return null;
    
    final sorted = items.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  /// Получение топ элементов
  List<String> _getTopItems(Map<String, int> items, int limit) {
    final sorted = items.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// Вычисление уверенности в стиле
  double _calculateStyleConfidence(int totalProducts, int uniqueStyles) {
    if (totalProducts == 0) return 0.0;
    
    // Чем больше продуктов и чем меньше уникальных стилей, тем выше уверенность
    final styleConsistency = uniqueStyles / totalProducts;
    final baseConfidence = 1.0 - styleConsistency;
    
    // Нормализуем до 0.0-1.0
    return (baseConfidence * 0.8 + 0.2).clamp(0.0, 1.0);
  }

  // Промпты для различных типов анализа

  String _buildStyleCompatibilityPrompt({
    required String userStyle,
    required String productStyle,
    required Map<String, dynamic> productAttributes,
    required String language,
  }) {
    return '''
Проанализируй совместимость стилей:

Стиль пользователя: $userStyle
Стиль товара: $productStyle
Атрибуты товара: ${productAttributes.entries.map((e) => '${e.key}: ${e.value}').join(', ')}

Оцени совместимость от 0.0 до 1.0 и объясни почему.
Дай 2-3 совета по стилю.
''';
  }

  String _buildStyleTrendsPrompt({
    required String category,
    required String season,
    String? location,
    required String language,
  }) {
    final locationText = location != null ? 'Локация: $location' : '';
    
    return '''
Проанализируй тренды стиля:

Категория: $category
Сезон: $season
$locationText

Опиши основные тренды, цвета, материалы и стили.
Дай рекомендации по покупкам.
''';
  }

  String _buildCapsuleWardrobePrompt({
    required UserStyleProfile userStyleProfile,
    required String occasion,
    required String season,
    required int itemCount,
    required String language,
  }) {
    return '''
Создай капсульный гардероб:

Стиль пользователя: ${userStyleProfile.primaryStyle}
Цветовая палитра: ${userStyleProfile.colorPalette.join(', ')}
Повод: $occasion
Сезон: $season
Количество вещей: $itemCount

Создай список вещей с описанием и объяснением выбора.
''';
  }

  // Системные промпты

  String _getSystemPromptForStyleCompatibility(String language) {
    if (language == 'ru') {
      return 'Ты эксперт по стилю и модным трендам. Анализируй совместимость стилей и давай полезные советы по созданию образов.';
    } else {
      return 'You are a style and fashion trends expert. Analyze style compatibility and give useful advice on creating looks.';
    }
  }

  String _getSystemPromptForStyleTrends(String language) {
    if (language == 'ru') {
      return 'Ты эксперт по модным трендам. Анализируй текущие тренды и давай рекомендации по покупкам.';
    } else {
      return 'You are a fashion trends expert. Analyze current trends and give shopping recommendations.';
    }
  }

  String _getSystemPromptForCapsuleWardrobe(String language) {
    if (language == 'ru') {
      return 'Ты эксперт по капсульным гардеробам. Создавай функциональные и стильные комплекты одежды.';
    } else {
      return 'You are a capsule wardrobe expert. Create functional and stylish clothing sets.';
    }
  }

  String _getSystemPromptForStyleAnalysis(String language) {
    if (language == 'ru') {
      return 'Ты эксперт по анализу стиля. Анализируй предпочтения пользователя и давай рекомендации по улучшению стиля.';
    } else {
      return 'You are a style analysis expert. Analyze user preferences and give recommendations for style improvement.';
    }
  }

  // Парсинг результатов

  StyleCompatibility _parseStyleCompatibility(String content, String userStyle, String productStyle, String language) {
    try {
      // Простой парсинг - ищем оценку и советы
      final scoreMatch = RegExp(r'(\d+\.?\d*)').firstMatch(content);
      final score = scoreMatch != null ? double.tryParse(scoreMatch.group(1)!) ?? 0.5 : 0.5;
      
      return StyleCompatibility(
        userStyle: userStyle,
        productStyle: productStyle,
        score: score.clamp(0.0, 1.0),
        reason: content,
        styleTips: _extractStyleTips(content),
      );
      
    } catch (e) {
      _logger.e('Error parsing style compatibility: $e');
      return _generateFallbackStyleCompatibility(userStyle, productStyle, language);
    }
  }

  StyleTrends _parseStyleTrends(String content, String category, String season, String language) {
    try {
      return StyleTrends(
        category: category,
        season: season,
        trends: content,
        colors: _extractColorsFromText(content),
        materials: _extractMaterialsFromText(content),
        styles: _extractStylesFromText(content),
        recommendations: _extractRecommendationsFromText(content),
        analyzedAt: DateTime.now(),
      );
      
    } catch (e) {
      _logger.e('Error parsing style trends: $e');
      return _generateFallbackStyleTrends(category, season, language);
    }
  }

  CapsuleWardrobe _parseCapsuleWardrobe(String content, UserStyleProfile userStyle, String occasion, String season, String language) {
    try {
      return CapsuleWardrobe(
        userId: userStyle.userId,
        occasion: occasion,
        season: season,
        items: _extractWardrobeItems(content),
        description: content,
        createdAt: DateTime.now(),
      );
      
    } catch (e) {
      _logger.e('Error parsing capsule wardrobe: $e');
      return _generateFallbackCapsuleWardrobe(userStyle, occasion, season, 5, language);
    }
  }

  // Вспомогательные методы парсинга

  List<String> _extractStyleTips(String content) {
    final tips = <String>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
        final tip = line.trim().substring(1).trim();
        if (tip.isNotEmpty) {
          tips.add(tip);
        }
      }
    }
    
    return tips.take(3).toList();
  }

  List<String> _extractColorsFromText(String text) {
    final colors = <String>[];
    final colorKeywords = ['красный', 'синий', 'зеленый', 'желтый', 'черный', 'белый'];
    
    for (final color in colorKeywords) {
      if (text.toLowerCase().contains(color)) {
        colors.add(color);
      }
    }
    
    return colors;
  }

  List<String> _extractMaterialsFromText(String text) {
    final materials = <String>[];
    final materialKeywords = ['хлопок', 'шелк', 'шерсть', 'кожа', 'джинс', 'трикотаж'];
    
    for (final material in materialKeywords) {
      if (text.toLowerCase().contains(material)) {
        materials.add(material);
      }
    }
    
    return materials;
  }

  List<String> _extractStylesFromText(String text) {
    final styles = <String>[];
    final styleKeywords = ['casual', 'business', 'sport', 'elegant', 'street', 'vintage'];
    
    for (final style in styleKeywords) {
      if (text.toLowerCase().contains(style)) {
        styles.add(style);
      }
    }
    
    return styles;
  }

  List<String> _extractRecommendationsFromText(String text) {
    final recommendations = <String>[];
    final lines = text.split('\n');
    
    for (final line in lines) {
      if (line.trim().startsWith('Рекомендация') || line.trim().startsWith('Совет')) {
        final recommendation = line.trim();
        if (recommendation.isNotEmpty) {
          recommendations.add(recommendation);
        }
      }
    }
    
    return recommendations.take(3).toList();
  }

  List<WardrobeItem> _extractWardrobeItems(String content) {
    final items = <WardrobeItem>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
        final itemText = line.trim().substring(1).trim();
        if (itemText.isNotEmpty) {
          items.add(WardrobeItem(
            name: itemText,
            description: itemText,
            category: 'clothing',
          ));
        }
      }
    }
    
    return items;
  }

  // Fallback генерация

  UserStyleProfile _generateFallbackStyleProfile(String userId, String language) {
    return UserStyleProfile(
      userId: userId,
      primaryStyle: 'casual',
      secondaryStyles: ['street', 'modern'],
      colorPalette: ['black', 'white', 'blue'],
      brandPreferences: ['MyModus'],
      priceRange: PriceRange(min: 1000, max: 10000, average: 5000),
      occasionPreferences: ['everyday', 'work'],
      seasonPreferences: ['spring', 'autumn'],
      styleConfidence: 0.7,
      aiInsights: language == 'ru' 
          ? 'Стиль пользователя проанализирован. Рекомендуется экспериментировать с новыми образами.'
          : 'User style analyzed. Recommended to experiment with new looks.',
      lastUpdated: DateTime.now(),
    );
  }

  StyleCompatibility _generateFallbackStyleCompatibility(String userStyle, String productStyle, String language) {
    return StyleCompatibility(
      userStyle: userStyle,
      productStyle: productStyle,
      score: 0.7,
      reason: language == 'ru' 
          ? 'Стили совместимы. Рекомендуется для создания разнообразных образов.'
          : 'Styles are compatible. Recommended for creating diverse looks.',
      styleTips: [
        language == 'ru' ? 'Сочетайте с базовыми вещами' : 'Combine with basic items',
        language == 'ru' ? 'Добавьте аксессуары' : 'Add accessories',
        language == 'ru' ? 'Экспериментируйте с цветами' : 'Experiment with colors',
      ],
    );
  }

  StyleTrends _generateFallbackStyleTrends(String category, String season, String language) {
    return StyleTrends(
      category: category,
      season: season,
      trends: language == 'ru' 
          ? 'Актуальные тренды для $season в категории $category'
          : 'Current trends for $season in $category category',
      colors: ['black', 'white', 'blue'],
      materials: ['cotton', 'silk', 'wool'],
      styles: ['casual', 'modern', 'elegant'],
      recommendations: [
        language == 'ru' ? 'Следите за трендами' : 'Follow trends',
        language == 'ru' ? 'Выбирайте качественные материалы' : 'Choose quality materials',
      ],
      analyzedAt: DateTime.now(),
    );
  }

  CapsuleWardrobe _generateFallbackCapsuleWardrobe(UserStyleProfile userStyle, String occasion, String season, int itemCount, String language) {
    return CapsuleWardrobe(
      userId: userStyle.userId,
      occasion: occasion,
      season: season,
      items: List.generate(itemCount, (index) => WardrobeItem(
        name: language == 'ru' ? 'Вещь ${index + 1}' : 'Item ${index + 1}',
        description: language == 'ru' ? 'Описание вещи ${index + 1}' : 'Description for item ${index + 1}',
        category: 'clothing',
      )),
      description: language == 'ru' 
          ? 'Базовый капсульный гардероб для $occasion в $season'
          : 'Basic capsule wardrobe for $occasion in $season',
      createdAt: DateTime.now(),
    );
  }

  // OpenAI API запрос

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

// Модели для анализа стиля

/// Анализ стиля
class StyleAnalysis {
  final String primaryStyle;
  final List<String> secondaryStyles;
  final List<String> colorPalette;
  final List<String> brandPreferences;
  final PriceRange priceRange;
  final List<String> occasionPreferences;
  final List<String> seasonPreferences;
  final double styleConfidence;
  
  StyleAnalysis({
    required this.primaryStyle,
    required this.secondaryStyles,
    required this.colorPalette,
    required this.brandPreferences,
    required this.priceRange,
    required this.occasionPreferences,
    required this.seasonPreferences,
    required this.styleConfidence,
  });
  
  StyleAnalysis.empty()
      : primaryStyle = 'casual',
        secondaryStyles = [],
        colorPalette = [],
        brandPreferences = [],
        priceRange = PriceRange(min: 0, max: 0, average: 0),
        occasionPreferences = [],
        seasonPreferences = [],
        styleConfidence = 0.0;
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
}
