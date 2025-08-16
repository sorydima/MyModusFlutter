import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database.dart';
import '../services/ai_service.dart';

class AIHandler {
  final DatabaseService _db;
  final AIService _aiService;

  AIHandler(this._db, this._aiService);

  Router get router {
    final router = Router();

    // Рекомендации
    router.get('/recommendations', _getRecommendations);
    router.get('/recommendations/products', _getProductRecommendations);
    router.get('/recommendations/social', _getSocialRecommendations);
    
    // Генерация контента
    router.post('/generate/description', _generateProductDescription);
    router.post('/generate/hashtags', _generateHashtags);
    router.post('/generate/post', _generatePost);
    
    // Анализ и модерация
    router.post('/moderate/content', _moderateContent);
    router.post('/analyze/sentiment', _analyzeSentiment);
    router.post('/analyze/trends', _analyzeTrends);
    
    // AI статистика
    router.get('/stats', _getAIStats);

    return router;
  }

  // Получение общих рекомендаций
  Future<Response> _getRecommendations(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;

      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Получение рекомендаций от AI сервиса
      final recommendations = await _aiService.getAIRecommendations(
        userId: userId,
        limit: limit,
      );

      return Response(200, 
        body: json.encode({
          'recommendations': recommendations.map((rec) => {
            'type': rec['type'],
            'content': rec['content'],
            'score': rec['score'],
            'reason': rec['reason'],
            'metadata': rec['metadata']
          }).toList()
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение рекомендаций товаров
  Future<Response> _getProductRecommendations(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      final categoryId = request.url.queryParameters['categoryId'];
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;

      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Получение истории покупок пользователя
      final userHistory = await _db.query(
        '''
        SELECT p.*, c.name as category_name
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.id IN (
          SELECT DISTINCT product_id FROM orders WHERE user_id = @userId
        )
        ORDER BY p.created_at DESC
        LIMIT 50
        ''',
        substitutionValues: {'userId': userId}
      );

      // Получение доступных товаров для рекомендаций
      var sql = '''
        SELECT p.*, c.name as category_name
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.is_active = true
      ''';
      
      final substitutionValues = <String, dynamic>{
        'limit': limit,
      };

      if (categoryId != null) {
        sql += ' AND p.category_id = @categoryId';
        substitutionValues['categoryId'] = categoryId;
      }

      sql += ' ORDER BY p.rating DESC, p.created_at DESC LIMIT @limit';

      final availableProducts = await _db.query(sql, substitutionValues: substitutionValues);

      // Генерация рекомендаций на основе истории
      final recommendations = await _aiService.getAIRecommendations(
        userId: userId,
        userHistory: userHistory.map((p) => {
          'id': p['id'],
          'name': p['name'],
          'category': p['category_name'],
          'price': p['price'],
          'rating': p['rating']
        }).toList(),
        availableProducts: availableProducts.map((p) => {
          'id': p['id'],
          'name': p['name'],
          'category': p['category_name'],
          'price': p['price'],
          'rating': p['rating'],
          'brand': p['brand']
        }).toList(),
        limit: limit,
      );

      return Response(200, 
        body: json.encode({
          'recommendations': recommendations.map((rec) => {
            'productId': rec['productId'],
            'productName': rec['productName'],
            'score': rec['score'],
            'reason': rec['reason'],
            'category': rec['category'],
            'price': rec['price']
          }).toList()
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение социальных рекомендаций
  Future<Response> _getSocialRecommendations(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;

      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Получение постов пользователя
      final userPosts = await _db.query(
        '''
        SELECT content, image_url, video_url, created_at
        FROM posts
        WHERE user_id = @userId AND is_active = true
        ORDER BY created_at DESC
        LIMIT 20
        ''',
        substitutionValues: {'userId': userId}
      );

      // Получение подписок пользователя
      final following = await _db.query(
        '''
        SELECT u.id, u.name, u.avatar_url
        FROM users u
        JOIN follows f ON u.id = f.following_id
        WHERE f.follower_id = @userId
        ''',
        substitutionValues: {'userId': userId}
      );

      // Генерация социальных рекомендаций
      final recommendations = await _aiService.getAIRecommendations(
        userId: userId,
        userHistory: userPosts.map((p) => {
          'content': p['content'],
          'type': p['image_url'] != null ? 'image' : 'text',
          'createdAt': p['created_at'].toString()
        }).toList(),
        availableProducts: following.map((u) => {
          'id': u['id'],
          'name': u['name'],
          'avatar': u['avatar_url']
        }).toList(),
        limit: limit,
      );

      return Response(200, 
        body: json.encode({
          'recommendations': recommendations.map((rec) => {
            'type': rec['type'],
            'content': rec['content'],
            'score': rec['score'],
            'reason': rec['reason']
          }).toList()
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Генерация описания товара
  Future<Response> _generateProductDescription(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final productName = data['productName'] as String?;
      final category = data['category'] as String?;
      final brand = data['brand'] as String?;
      final price = data['price'] as num?;
      final features = data['features'] as List<dynamic>?;

      if (productName == null) {
        return Response(400, 
          body: json.encode({'error': 'Название товара обязательно'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Генерация описания через AI
      final description = await _aiService.generateProductDescription(
        productName: productName,
        category: category,
        brand: brand,
        price: price,
        features: features?.cast<String>(),
      );

      return Response(200, 
        body: json.encode({
          'description': description,
          'productName': productName,
          'category': category,
          'brand': brand,
          'price': price
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Генерация хештегов
  Future<Response> _generateHashtags(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final content = data['content'] as String?;
      final category = data['category'] as String?;
      final count = int.tryParse(data['count']?.toString() ?? '5') ?? 5;

      if (content == null) {
        return Response(400, 
          body: json.encode({'error': 'Контент обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Генерация хештегов через AI
      final hashtags = await _aiService.generateHashtags(
        content: content,
        category: category,
        count: count,
      );

      return Response(200, 
        body: json.encode({
          'hashtags': hashtags,
          'content': content,
          'category': category,
          'count': hashtags.length
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Генерация поста
  Future<Response> _generatePost(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final topic = data['topic'] as String?;
      final style = data['style'] as String?; // casual, formal, promotional
      final length = data['length'] as String?; // short, medium, long
      final includeHashtags = data['includeHashtags'] as bool? ?? true;

      if (topic == null) {
        return Response(400, 
          body: json.encode({'error': 'Тема поста обязательна'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Генерация поста через AI
      final post = await _aiService.generatePost(
        topic: topic,
        style: style ?? 'casual',
        length: length ?? 'medium',
        includeHashtags: includeHashtags,
      );

      return Response(200, 
        body: json.encode({
          'post': post['content'],
          'hashtags': post['hashtags'],
          'topic': topic,
          'style': style,
          'length': length
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Модерация контента
  Future<Response> _moderateContent(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final content = data['content'] as String?;
      final contentType = data['contentType'] as String?; // post, comment, product

      if (content == null) {
        return Response(400, 
          body: json.encode({'error': 'Контент обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Модерация через AI
      final moderation = await _aiService.moderateContent(
        content: content,
        contentType: contentType ?? 'post',
      );

      return Response(200, 
        body: json.encode({
          'isAppropriate': moderation['isAppropriate'],
          'confidence': moderation['confidence'],
          'flags': moderation['flags'],
          'suggestions': moderation['suggestions'],
          'content': content,
          'contentType': contentType
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Анализ настроения
  Future<Response> _analyzeSentiment(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final content = data['content'] as String?;
      final context = data['context'] as String?; // review, comment, feedback

      if (content == null) {
        return Response(400, 
          body: json.encode({'error': 'Контент обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Анализ настроения через AI
      final sentiment = await _aiService.analyzeSentiment(
        content: content,
        context: context ?? 'general',
      );

      return Response(200, 
        body: json.encode({
          'sentiment': sentiment['sentiment'], // positive, negative, neutral
          'score': sentiment['score'],
          'confidence': sentiment['confidence'],
          'keywords': sentiment['keywords'],
          'content': content,
          'context': context
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Анализ трендов
  Future<Response> _analyzeTrends(Request request) async {
    try {
      final category = request.url.queryParameters['category'];
      final timeframe = request.url.queryParameters['timeframe'] ?? '7d'; // 1d, 7d, 30d, 90d

      // Получение данных для анализа трендов
      final products = await _db.query(
        '''
        SELECT p.name, p.brand, p.category_id, p.price, p.rating,
               c.name as category_name,
               COUNT(l.id) as like_count,
               COUNT(c.id) as comment_count
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        LEFT JOIN likes l ON p.id = l.post_id
        LEFT JOIN comments c ON p.id = c.post_id
        WHERE p.created_at >= NOW() - INTERVAL '@timeframe days'
        GROUP BY p.id, c.name
        ORDER BY like_count DESC, comment_count DESC
        LIMIT 50
        ''',
        substitutionValues: {
          'timeframe': timeframe == '1d' ? 1 : 
                      timeframe == '7d' ? 7 : 
                      timeframe == '30d' ? 30 : 90
        }
      );

      // Анализ трендов через AI
      final trends = await _aiService.analyzeTrends(
        products: products.map((p) => {
          'name': p['name'],
          'brand': p['brand'],
          'category': p['category_name'],
          'price': p['price'],
          'rating': p['rating'],
          'engagement': (p['like_count'] as int) + (p['comment_count'] as int)
        }).toList(),
        timeframe: timeframe,
        category: category,
      );

      return Response(200, 
        body: json.encode({
          'trends': trends['trends'],
          'topBrands': trends['topBrands'],
          'topCategories': trends['topCategories'],
          'priceTrends': trends['priceTrends'],
          'timeframe': timeframe,
          'category': category
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение AI статистики
  Future<Response> _getAIStats(Request request) async {
    try {
      // Статистика использования AI
      final aiUsage = await _db.query(
        '''
        SELECT 
          COUNT(*) as total_requests,
          COUNT(DISTINCT user_id) as unique_users,
          AVG(response_time) as avg_response_time
        FROM ai_requests
        WHERE created_at >= NOW() - INTERVAL '30 days'
        '''
      );

      // Статистика модерации
      final moderationStats = await _db.query(
        '''
        SELECT 
          COUNT(*) as total_moderated,
          COUNT(CASE WHEN is_appropriate = true THEN 1 END) as approved,
          COUNT(CASE WHEN is_appropriate = false THEN 1 END) as rejected
        FROM content_moderation
        WHERE created_at >= NOW() - INTERVAL '30 days'
        '''
      );

      // Статистика рекомендаций
      final recommendationStats = await _db.query(
        '''
        SELECT 
          COUNT(*) as total_recommendations,
          COUNT(DISTINCT user_id) as users_with_recommendations,
          AVG(click_rate) as avg_click_rate
        FROM ai_recommendations
        WHERE created_at >= NOW() - INTERVAL '30 days'
        '''
      );

      return Response(200, 
        body: json.encode({
          'usage': {
            'totalRequests': aiUsage.first['total_requests'],
            'uniqueUsers': aiUsage.first['unique_users'],
            'avgResponseTime': aiUsage.first['avg_response_time']
          },
          'moderation': {
            'totalModerated': moderationStats.first['total_moderated'],
            'approved': moderationStats.first['approved'],
            'rejected': moderationStats.first['rejected']
          },
          'recommendations': {
            'totalRecommendations': recommendationStats.first['total_recommendations'],
            'usersWithRecommendations': recommendationStats.first['users_with_recommendations'],
            'avgClickRate': recommendationStats.first['avg_click_rate']
          }
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }
}
