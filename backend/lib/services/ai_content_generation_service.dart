import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';
import '../models.dart';

/// Специализированный сервис для AI генерации контента
class AIContentGenerationService {
  final String _apiKey;
  final String _baseUrl;
  final Logger _logger = Logger();
  
  AIContentGenerationService({String? apiKey, String? baseUrl})
      : _apiKey = apiKey ?? (DotEnv()..load())['OPENAI_API_KEY'] ?? '',
        _baseUrl = baseUrl ?? (DotEnv()..load())['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';

  /// Генерация описания товара
  Future<ProductDescription> generateProductDescription({
    required String productName,
    required String category,
    required Map<String, dynamic> specifications,
    String? brand,
    String? style,
    String? targetAudience,
    int? price,
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Generating product description for: $productName');
      
      final prompt = _buildProductDescriptionPrompt(
        productName: productName,
        category: category,
        specifications: specifications,
        brand: brand,
        style: style,
        targetAudience: targetAudience,
        price: price,
        language: language,
      );
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': _getSystemPromptForProductDescription(language),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 400,
        temperature: 0.7,
      );
      
      final content = response['choices'][0]['message']['content'];
      
      // Парсим сгенерированный контент
      final description = _parseProductDescription(content, language);
      
      _logger.i('Generated product description successfully');
      return description;
      
    } catch (e) {
      _logger.e('Error generating product description: $e');
      return _generateFallbackDescription(productName, category, language);
    }
  }

  /// Генерация хештегов для товара
  Future<List<String>> generateProductHashtags({
    required String productName,
    required String category,
    String? brand,
    String? style,
    String? targetAudience,
    int hashtagCount = 8,
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Generating hashtags for: $productName');
      
      final prompt = _buildHashtagGenerationPrompt(
        productName: productName,
        category: category,
        brand: brand,
        style: style,
        targetAudience: targetAudience,
        hashtagCount: hashtagCount,
        language: language,
      );
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': _getSystemPromptForHashtags(language),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 200,
        temperature: 0.8,
      );
      
      final content = response['choices'][0]['message']['content'];
      
      // Парсим хештеги
      final hashtags = _parseHashtags(content, hashtagCount);
      
      _logger.i('Generated ${hashtags.length} hashtags successfully');
      return hashtags;
      
    } catch (e) {
      _logger.e('Error generating hashtags: $e');
      return _generateFallbackHashtags(category, brand, hashtagCount);
    }
  }

  /// Генерация поста для соцсети
  Future<SocialMediaPost> generateSocialMediaPost({
    required String productName,
    required String category,
    required String productDescription,
    String? brand,
    String? style,
    String? targetAudience,
    String? platform = 'instagram',
    String? tone = 'casual',
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Generating social media post for: $productName');
      
      final prompt = _buildSocialMediaPostPrompt(
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
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': _getSystemPromptForSocialMedia(language),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 500,
        temperature: 0.8,
      );
      
      final content = response['choices'][0]['message']['content'];
      
      // Парсим пост
      final post = _parseSocialMediaPost(content, platform, language);
      
      _logger.i('Generated social media post successfully');
      return post;
      
    } catch (e) {
      _logger.e('Error generating social media post: $e');
      return _generateFallbackSocialMediaPost(productName, category, platform, language);
    }
  }

  /// Генерация SEO-оптимизированного заголовка
  Future<String> generateSEOOptimizedTitle({
    required String productName,
    required String category,
    String? brand,
    String? style,
    String? keyFeatures,
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Generating SEO title for: $productName');
      
      final prompt = _buildSEOTitlePrompt(
        productName: productName,
        category: category,
        brand: brand,
        style: style,
        keyFeatures: keyFeatures,
        language: language,
      );
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': _getSystemPromptForSEOTitle(language),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 100,
        temperature: 0.6,
      );
      
      final title = response['choices'][0]['message']['content'].trim();
      
      _logger.i('Generated SEO title successfully');
      return title;
      
    } catch (e) {
      _logger.e('Error generating SEO title: $e');
      return _generateFallbackSEOTitle(productName, category, language);
    }
  }

  /// Генерация отзыва о товаре
  Future<ProductReview> generateProductReview({
    required String productName,
    required String category,
    required int rating,
    String? brand,
    String? style,
    String? pros,
    String? cons,
    String? language = 'ru',
  }) async {
    try {
      _logger.i('Generating product review for: $productName');
      
      final prompt = _buildProductReviewPrompt(
        productName: productName,
        category: category,
        rating: rating,
        brand: brand,
        style: style,
        pros: pros,
        cons: cons,
        language: language,
      );
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': _getSystemPromptForProductReview(language),
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
      
      // Парсим отзыв
      final review = _parseProductReview(content, rating, language);
      
      _logger.i('Generated product review successfully');
      return review;
      
    } catch (e) {
      _logger.e('Error generating product review: $e');
      return _generateFallbackProductReview(productName, category, rating, language);
    }
  }

  // Промпты для различных типов контента

  String _buildProductDescriptionPrompt({
    required String productName,
    required String category,
    required Map<String, dynamic> specifications,
    String? brand,
    String? style,
    String? targetAudience,
    int? price,
    required String language,
  }) {
    final specText = specifications.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    
    final brandText = brand != null ? 'Бренд: $brand' : '';
    final styleText = style != null ? 'Стиль: $style' : '';
    final audienceText = targetAudience != null ? 'Целевая аудитория: $targetAudience' : '';
    final priceText = price != null ? 'Цена: $price ₽' : '';
    
    return '''
Создай привлекательное описание для товара:

Название: $productName
Категория: $category
$brandText
$styleText
$audienceText
$priceText
Характеристики: $specText

Требования:
- Описание на ${language == 'ru' ? 'русском' : 'английском'} языке
- 3-4 предложения
- Подчеркни ключевые преимущества
- Используй эмоциональные слова
- Добавь призыв к действию
- Сделай описание продающим
''';
  }

  String _buildHashtagGenerationPrompt({
    required String productName,
    required String category,
    String? brand,
    String? style,
    String? targetAudience,
    required int hashtagCount,
    required String language,
  }) {
    final brandText = brand != null ? 'Бренд: $brand' : '';
    final styleText = style != null ? 'Стиль: $style' : '';
    final audienceText = targetAudience != null ? 'Целевая аудитория: $targetAudience' : '';
    
    return '''
Сгенерируй $hashtagCount хештегов для товара:

Название: $productName
Категория: $category
$brandText
$styleText
$audienceText

Требования:
- Хештеги на ${language == 'ru' ? 'русском' : 'английском'} языке
- Включай общие и специфичные хештеги
- Добавь трендовые хештеги
- Используй #MyModusLook для брендинга
- Сделай хештеги привлекательными для поиска
''';
  }

  String _buildSocialMediaPostPrompt({
    required String productName,
    required String category,
    required String productDescription,
    String? brand,
    String? style,
    String? targetAudience,
    required String platform,
    required String tone,
    required String language,
  }) {
    final brandText = brand != null ? 'Бренд: $brand' : '';
    final styleText = style != null ? 'Стиль: $style' : '';
    final audienceText = targetAudience != null ? 'Целевая аудитория: $targetAudience' : '';
    
    return '''
Создай пост для $platform:

Название товара: $productName
Категория: $category
$brandText
$styleText
$audienceText
Описание: $productDescription

Требования:
- Тон: $tone
- Язык: ${language == 'ru' ? 'русский' : 'английский'}
- Адаптируй под $platform
- Добавь эмодзи
- Сделай привлекательным для ленты
- Включи призыв к действию
- Добавь хештеги
''';
  }

  String _buildSEOTitlePrompt({
    required String productName,
    required String category,
    String? brand,
    String? style,
    String? keyFeatures,
    required String language,
  }) {
    final brandText = brand != null ? 'Бренд: $brand' : '';
    final styleText = style != null ? 'Стиль: $style' : '';
    final featuresText = keyFeatures != null ? 'Ключевые особенности: $keyFeatures' : '';
    
    return '''
Создай SEO-оптимизированный заголовок:

Название: $productName
Категория: $category
$brandText
$styleText
$featuresText

Требования:
- Язык: ${language == 'ru' ? 'русский' : 'английский'}
- Длина: 50-60 символов
- Включи ключевые слова
- Сделай привлекательным для кликов
- Оптимизируй для поиска
''';
  }

  String _buildProductReviewPrompt({
    required String productName,
    required String category,
    required int rating,
    String? brand,
    String? style,
    String? pros,
    String? cons,
    required String language,
  }) {
    final brandText = brand != null ? 'Бренд: $brand' : '';
    final styleText = style != null ? 'Стиль: $style' : '';
    final prosText = pros != null ? 'Плюсы: $pros' : '';
    final consText = cons != null ? 'Минусы: $cons' : '';
    
    return '''
Создай отзыв о товаре:

Название: $productName
Категория: $category
$brandText
$styleText
Рейтинг: $rating/5
$prosText
$consText

Требования:
- Язык: ${language == 'ru' ? 'русский' : 'английский'}
- Тон должен соответствовать рейтингу
- 2-3 предложения
- Объективный и честный
- Полезный для других покупателей
''';
  }

  // Системные промпты

  String _getSystemPromptForProductDescription(String language) {
    if (language == 'ru') {
      return 'Ты эксперт по копирайтингу и маркетингу. Создавай продающие, привлекательные описания товаров на русском языке. Используй эмоциональные слова, подчеркивай преимущества и создавай желание купить.';
    } else {
      return 'You are a copywriting and marketing expert. Create selling, attractive product descriptions in English. Use emotional words, highlight benefits and create desire to buy.';
    }
  }

  String _getSystemPromptForHashtags(String language) {
    if (language == 'ru') {
      return 'Ты эксперт по социальным сетям и хештегам. Создавай привлекательные, трендовые хештеги на русском языке для продвижения товаров в соцсетях.';
    } else {
      return 'You are a social media and hashtag expert. Create attractive, trending hashtags in English for promoting products on social media.';
    }
  }

  String _getSystemPromptForSocialMedia(String language) {
    if (language == 'ru') {
      return 'Ты эксперт по социальным сетям и контент-маркетингу. Создавай привлекательные посты для различных платформ на русском языке.';
    } else {
      return 'You are a social media and content marketing expert. Create attractive posts for various platforms in English.';
    }
  }

  String _getSystemPromptForSEOTitle(String language) {
    if (language == 'ru') {
      return 'Ты SEO-эксперт. Создавай оптимизированные заголовки для поисковых систем на русском языке.';
    } else {
      return 'You are an SEO expert. Create optimized titles for search engines in English.';
    }
  }

  String _getSystemPromptForProductReview(String language) {
    if (language == 'ru') {
      return 'Ты эксперт по анализу товаров. Создавай объективные, полезные отзывы на русском языке.';
    } else {
      return 'You are a product analysis expert. Create objective, helpful reviews in English.';
    }
  }

  // Парсинг сгенерированного контента

  ProductDescription _parseProductDescription(String content, String language) {
    try {
      // Убираем лишние символы и форматирование
      final cleanContent = content
          .replaceAll(RegExp(r'^["""\s]+|["""\s]+$'), '')
          .trim();
      
      return ProductDescription(
        content: cleanContent,
        language: language,
        generatedAt: DateTime.now(),
        wordCount: cleanContent.split(' ').length,
      );
    } catch (e) {
      _logger.e('Error parsing product description: $e');
      return ProductDescription(
        content: 'Описание товара',
        language: language,
        generatedAt: DateTime.now(),
        wordCount: 3,
      );
    }
  }

  List<String> _parseHashtags(String content, int expectedCount) {
    try {
      final hashtags = <String>[];
      
      // Ищем хештеги в тексте
      final regex = RegExp(r'#\w+');
      final matches = regex.allMatches(content);
      
      for (final match in matches) {
        final hashtag = match.group(0)!;
        if (hashtags.length < expectedCount && !hashtags.contains(hashtag)) {
          hashtags.add(hashtag);
        }
      }
      
      // Если не нашли достаточно хештегов, генерируем дополнительные
      if (hashtags.length < expectedCount) {
        final additionalHashtags = _generateAdditionalHashtags(expectedCount - hashtags.length);
        hashtags.addAll(additionalHashtags);
      }
      
      return hashtags.take(expectedCount).toList();
      
    } catch (e) {
      _logger.e('Error parsing hashtags: $e');
      return _generateFallbackHashtags('general', null, expectedCount);
    }
  }

  SocialMediaPost _parseSocialMediaPost(String content, String platform, String language) {
    try {
      // Разделяем контент на части
      final lines = content.split('\n');
      String caption = '';
      List<String> hashtags = [];
      
      for (final line in lines) {
        if (line.trim().startsWith('#')) {
          hashtags.add(line.trim());
        } else if (line.trim().isNotEmpty) {
          caption += line.trim() + '\n';
        }
      }
      
      return SocialMediaPost(
        caption: caption.trim(),
        hashtags: hashtags,
        platform: platform,
        language: language,
        generatedAt: DateTime.now(),
      );
      
    } catch (e) {
      _logger.e('Error parsing social media post: $e');
      return _generateFallbackSocialMediaPost('Product', 'general', platform, language);
    }
  }

  ProductReview _parseProductReview(String content, int rating, String language) {
    try {
      final cleanContent = content
          .replaceAll(RegExp(r'^["""\s]+|["""\s]+$'), '')
          .trim();
      
      return ProductReview(
        content: cleanContent,
        rating: rating,
        language: language,
        generatedAt: DateTime.now(),
        isAIGenerated: true,
      );
      
    } catch (e) {
      _logger.e('Error parsing product review: $e');
      return _generateFallbackProductReview('Product', 'general', rating, language);
    }
  }

  // Fallback генерация

  ProductDescription _generateFallbackDescription(String productName, String category, String language) {
    final content = language == 'ru' 
        ? 'Отличный товар в категории $category. $productName - это качественный продукт, который обязательно понравится покупателям.'
        : 'Great product in the $category category. $productName is a quality product that customers will definitely love.';
    
    return ProductDescription(
      content: content,
      language: language,
      generatedAt: DateTime.now(),
      wordCount: content.split(' ').length,
    );
  }

  List<String> _generateFallbackHashtags(String category, String? brand, int count) {
    final hashtags = <String>[];
    
    // Базовые хештеги
    hashtags.add('#$category');
    if (brand != null) hashtags.add('#$brand');
    hashtags.add('#MyModusLook');
    hashtags.add('#fashion');
    hashtags.add('#style');
    
    // Дополнительные хештеги
    final additional = ['#trending', '#new', '#quality', '#shopping'];
    for (final hashtag in additional) {
      if (hashtags.length < count) {
        hashtags.add(hashtag);
      }
    }
    
    return hashtags.take(count).toList();
  }

  SocialMediaPost _generateFallbackSocialMediaPost(String productName, String category, String platform, String language) {
    final caption = language == 'ru'
        ? '🔥 Новинка! $productName в категории $category\n\n✨ Качество и стиль в одном товаре\n\n💫 Попробуй прямо сейчас!'
        : '🔥 New! $productName in the $category category\n\n✨ Quality and style in one product\n\n💫 Try it now!';
    
    final hashtags = _generateFallbackHashtags(category, null, 6);
    
    return SocialMediaPost(
      caption: caption,
      hashtags: hashtags,
      platform: platform,
      language: language,
      generatedAt: DateTime.now(),
    );
  }

  String _generateFallbackSEOTitle(String productName, String category, String language) {
    return language == 'ru'
        ? '$productName - $category | MyModus'
        : '$productName - $category | MyModus';
  }

  ProductReview _generateFallbackProductReview(String productName, String category, int rating, String language) {
    final content = language == 'ru'
        ? 'Хороший товар в категории $category. $productName соответствует ожиданиям.'
        : 'Good product in the $category category. $productName meets expectations.';
    
    return ProductReview(
      content: content,
      rating: rating,
      language: language,
      generatedAt: DateTime.now(),
      isAIGenerated: true,
    );
  }

  List<String> _generateAdditionalHashtags(int count) {
    final hashtags = [
      '#MyModusLook', '#fashion', '#style', '#trending', '#new',
      '#quality', '#shopping', '#lifestyle', '#beauty', '#trendy'
    ];
    
    return hashtags.take(count).toList();
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

// Модели для сгенерированного контента

/// Описание товара
class ProductDescription {
  final String content;
  final String language;
  final DateTime generatedAt;
  final int wordCount;
  
  ProductDescription({
    required this.content,
    required this.language,
    required this.generatedAt,
    required this.wordCount,
  });
}

/// Пост для соцсети
class SocialMediaPost {
  final String caption;
  final List<String> hashtags;
  final String platform;
  final String language;
  final DateTime generatedAt;
  
  SocialMediaPost({
    required this.caption,
    required this.hashtags,
    required this.platform,
    required this.language,
    required this.generatedAt,
  });
}

/// Отзыв о товаре
class ProductReview {
  final String content;
  final int rating;
  final String language;
  final DateTime generatedAt;
  final bool isAIGenerated;
  
  ProductReview({
    required this.content,
    required this.rating,
    required this.language,
    required this.generatedAt,
    required this.isAIGenerated,
  });
}
