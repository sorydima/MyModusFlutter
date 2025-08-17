import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';
import '../models.dart';

class AIService {
  final String _apiKey;
  final String _baseUrl;
  final Logger _logger = Logger();
  
  AIService({String? apiKey, String? baseUrl})
      : _apiKey = apiKey ?? (DotEnv()..load())['OPENAI_API_KEY'] ?? '',
        _baseUrl = baseUrl ?? (DotEnv()..load())['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';
  
  /// Generate product description using AI
  Future<String> generateProductDescription({
    required String productName,
    required String category,
    required Map<String, dynamic> specifications,
    String? style,
  }) async {
    try {
      final prompt = _buildProductDescriptionPrompt(
        productName: productName,
        category: category,
        specifications: specifications,
        style: style,
      );
      
      final response = await _makeOpenAIRequest(
        model: 'gpt-4',
        messages: [
          {
            'role': 'system',
            'content': 'You are a fashion expert and copywriter. Create engaging, SEO-friendly product descriptions that highlight key features and benefits.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        maxTokens: 300,
        temperature: 0.7,
      );
      
      return response['choices'][0]['message']['content'];
    } catch (e) {
      _logger.e('Error generating product description: $e');
      return _generateFallbackDescription(productName, category);
    }
  }
  
  /// Generate AI-powered product recommendations
  Future<List<ProductRecommendation>> generateRecommendations({
    required String userId,
    required List<Product> userHistory,
    required List<Product> availableProducts,
    int limit = 10,
  }) async {
    try {
      // Analyze user preferences
      final userPreferences = await _analyzeUserPreferences(userHistory);
      
      // Generate recommendations based on preferences
      final recommendations = await _generateRecommendationsByPreferences(
        userPreferences: userPreferences,
        availableProducts: availableProducts,
        limit: limit,
      );
      
      return recommendations;
    } catch (e) {
      _logger.e('Error generating recommendations: $e');
      return _generateFallbackRecommendations(availableProducts, limit);
    }
  }
  
  /// Analyze user preferences from purchase history
  Future<UserPreferences> _analyzeUserPreferences(List<Product> userHistory) async {
    try {
      // Group products by category and analyze patterns
      final categoryPreferences = <String, int>{};
      final brandPreferences = <String, int>{};
      final priceRange = <int>[];
      final stylePreferences = <String, int>{};
      
      for (final product in userHistory) {
        // Category preferences
        if (product.categoryId != null) {
          categoryPreferences[product.categoryId!] = 
              (categoryPreferences[product.categoryId!] ?? 0) + 1;
        }
        
        // Brand preferences
        if (product.brand != null) {
          brandPreferences[product.brand!] = 
              (brandPreferences[product.brand!] ?? 0) + 1;
        }
        
        // Price range
        priceRange.add(product.price);
        
        // Style preferences (extract from title/description)
        final style = _extractStyleFromProduct(product);
        if (style != null) {
          stylePreferences[style] = (stylePreferences[style] ?? 0) + 1;
        }
      }
      
      // Calculate average price
      final avgPrice = priceRange.isNotEmpty 
          ? priceRange.reduce((a, b) => a + b) / priceRange.length 
          : 0;
      
      // Find top preferences
      final topCategories = _getTopItems(categoryPreferences, 3);
      final topBrands = _getTopItems(brandPreferences, 3);
      final topStyles = _getTopItems(stylePreferences, 3);
      
      return UserPreferences(
        topCategories: topCategories,
        topBrands: topBrands,
        topStyles: topStyles,
        averagePrice: avgPrice.round(),
        totalPurchases: userHistory.length,
      );
    } catch (e) {
      _logger.e('Error analyzing user preferences: $e');
      return UserPreferences.empty();
    }
  }
  
  /// Generate recommendations based on user preferences
  Future<List<ProductRecommendation>> _generateRecommendationsByPreferences({
    required UserPreferences userPreferences,
    required List<Product> availableProducts,
    required int limit,
  }) async {
    try {
      final scoredProducts = <ProductRecommendation>[];
      
      for (final product in availableProducts) {
        double score = 0.0;
        
        // Category preference score
        if (userPreferences.topCategories.contains(product.categoryId)) {
          score += 3.0;
        }
        
        // Brand preference score
        if (product.brand != null && 
            userPreferences.topBrands.contains(product.brand)) {
          score += 2.0;
        }
        
        // Style preference score
        final style = _extractStyleFromProduct(product);
        if (style != null && userPreferences.topStyles.contains(style)) {
          score += 2.0;
        }
        
        // Price preference score (closer to user's average = higher score)
        final priceDiff = (product.price - userPreferences.averagePrice).abs();
        final maxPriceDiff = userPreferences.averagePrice * 0.5;
        if (priceDiff <= maxPriceDiff) {
          score += 1.0;
        }
        
        // Rating score
        score += (product.rating ?? 0) * 0.5;
        
        // Discount score
        if (product.discount != null && product.discount! > 0) {
          score += 0.5;
        }
        
        scoredProducts.add(ProductRecommendation(
          product: product,
          score: score,
          reason: _generateRecommendationReason(product, userPreferences),
        ));
      }
      
      // Sort by score and return top recommendations
      scoredProducts.sort((a, b) => b.score.compareTo(a.score));
      return scoredProducts.take(limit).toList();
    } catch (e) {
      _logger.e('Error generating recommendations by preferences: $e');
      return _generateFallbackRecommendations(availableProducts, limit);
    }
  }
  
  /// Generate recommendation reason
  String _generateRecommendationReason(Product product, UserPreferences preferences) {
    final reasons = <String>[];
    
    if (preferences.topCategories.contains(product.categoryId)) {
      reasons.add('Based on your category preferences');
    }
    
    if (product.brand != null && preferences.topBrands.contains(product.brand)) {
      reasons.add('Similar to brands you like');
    }
    
    if (product.rating != null && product.rating! >= 4.0) {
      reasons.add('Highly rated by customers');
    }
    
    if (product.discount != null && product.discount! > 0) {
      reasons.add('Currently on sale');
    }
    
    return reasons.isNotEmpty ? reasons.join(', ') : 'Recommended for you';
  }
  
  /// Extract style from product
  String? _extractStyleFromProduct(Product product) {
    final title = product.title.toLowerCase();
    final description = product.description?.toLowerCase() ?? '';
    
    final styleKeywords = {
      'casual': ['casual', 'everyday', 'comfortable'],
      'formal': ['formal', 'business', 'office', 'professional'],
      'sporty': ['sport', 'athletic', 'active', 'gym'],
      'elegant': ['elegant', 'sophisticated', 'luxury', 'premium'],
      'vintage': ['vintage', 'retro', 'classic', 'timeless'],
      'trendy': ['trendy', 'fashionable', 'modern', 'contemporary'],
    };
    
    for (final entry in styleKeywords.entries) {
      for (final keyword in entry.value) {
        if (title.contains(keyword) || description.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return null;
  }
  
  /// Get top items from preferences map
  List<String> _getTopItems(Map<String, int> preferences, int count) {
    final sorted = preferences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(count).map((e) => e.key).toList();
  }
  
  /// Generate fallback recommendations
  List<ProductRecommendation> _generateFallbackRecommendations(
    List<Product> availableProducts, 
    int limit,
  ) {
    // Sort by rating and return top products
    final sorted = List<Product>.from(availableProducts)
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    
    return sorted.take(limit).map((product) => ProductRecommendation(
      product: product,
      score: product.rating?.toDouble() ?? 0.0,
      reason: 'Popular choice',
    )).toList();
  }
  
  /// Generate fallback description
  String _generateFallbackDescription(String productName, String category) {
    return '$productName - высококачественный товар в категории $category. '
           'Отличное соотношение цена-качество. Быстрая доставка по всей России.';
  }
  
  /// Build prompt for product description
  String _buildProductDescriptionPrompt({
    required String productName,
    required String category,
    required Map<String, dynamic> specifications,
    String? style,
  }) {
    final specText = specifications.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    
    return '''
Создай привлекательное описание для товара:

Название: $productName
Категория: $category
Стиль: ${style ?? 'не указан'}
Характеристики: $specText

Требования:
- Описание на русском языке
- 2-3 предложения
- Подчеркни ключевые преимущества
- Используй эмоциональные слова
- Добавь призыв к действию
''';
  }
  
  /// Make request to OpenAI API
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
  
  /// Cleanup resources
  void dispose() {
    // No cleanup needed for this service
  }
}

/// User preferences model
class UserPreferences {
  final List<String> topCategories;
  final List<String> topBrands;
  final List<String> topStyles;
  final int averagePrice;
  final int totalPurchases;
  
  UserPreferences({
    required this.topCategories,
    required this.topBrands,
    required this.topStyles,
    required this.averagePrice,
    required this.totalPurchases,
  });
  
  UserPreferences.empty()
      : topCategories = [],
        topBrands = [],
        topStyles = [],
        averagePrice = 0,
        totalPurchases = 0;
}

/// Product recommendation model
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
