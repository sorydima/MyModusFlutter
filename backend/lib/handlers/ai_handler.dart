import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/ai_service.dart';
import '../database.dart';

class AIHandler {
  final AIService _aiService;
  final DatabaseService _database;

  AIHandler(this._aiService, this._database);

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
    
    // Статистика AI
    router.get('/stats', _getAIStats);

    return router;
  }

  Future<Response> _getRecommendations(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;

      final result = await _aiService.getAIRecommendations(
        userId: userId,
        limit: limit,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'recommendations': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to get recommendations',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getProductRecommendations(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final categoryId = request.url.queryParameters['categoryId'];
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;

      // Получаем предпочтения пользователя
      final userPreferences = await _database.query(
        '''
        SELECT p.category_id, COUNT(*) as view_count, AVG(p.rating) as avg_rating
        FROM products p
        LEFT JOIN product_views pv ON p.id = pv.product_id
        WHERE pv.user_id = @userId
        GROUP BY p.category_id
        ORDER BY view_count DESC, avg_rating DESC
        LIMIT 5
        ''',
        substitutionValues: {'userId': userId},
      );

      // Получаем рекомендуемые продукты
      final recommendedProducts = await _database.query(
        '''
        SELECT p.*, c.name as category_name
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.is_active = true
        ${categoryId != null ? 'AND p.category_id = @categoryId' : ''}
        ORDER BY p.rating DESC, p.review_count DESC
        LIMIT @limit
        ''',
        substitutionValues: {
          'categoryId': categoryId,
          'limit': limit,
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'userPreferences': userPreferences,
          'recommendedProducts': recommendedProducts,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getSocialRecommendations(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;

      // Получаем посты от пользователей, на которых подписан текущий пользователь
      final followedPosts = await _database.query(
        '''
        SELECT p.*, u.name as author_name, u.avatar_url as author_avatar
        FROM posts p
        LEFT JOIN users u ON p.user_id = u.id
        LEFT JOIN follows f ON p.user_id = f.following_id
        WHERE f.follower_id = @userId AND p.is_active = true
        ORDER BY p.created_at DESC
        LIMIT @limit
        ''',
        substitutionValues: {
          'userId': userId,
          'limit': limit,
        },
      );

      // Получаем популярные посты
      final popularPosts = await _database.query(
        '''
        SELECT p.*, u.name as author_name, u.avatar_url as author_avatar
        FROM posts p
        LEFT JOIN users u ON p.user_id = u.id
        WHERE p.is_active = true
        ORDER BY p.like_count DESC, p.comment_count DESC, p.created_at DESC
        LIMIT @limit
        ''',
        substitutionValues: {'limit': limit},
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'followedPosts': followedPosts,
          'popularPosts': popularPosts,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _generateProductDescription(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final productName = data['productName'];
      final category = data['category'];
      final brand = data['brand'];
      final specifications = data['specifications'];

      if (productName == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Product name is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _aiService.generateProductDescription(
        productName: productName,
        category: category,
        brand: brand,
        specifications: specifications,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'description': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to generate description',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _generateHashtags(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final content = data['content'];
      final category = data['category'];
      final count = int.tryParse(data['count']?.toString() ?? '10') ?? 10;

      if (content == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Content is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _aiService.generateHashtags(
        content: content,
        category: category,
        count: count,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'hashtags': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to generate hashtags',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _generatePost(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final topic = data['topic'];
      final style = data['style'];
      final length = data['length'];
      final hashtags = data['hashtags'];

      if (topic == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Topic is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _aiService.generatePost(
        topic: topic,
        style: style,
        length: length,
        hashtags: hashtags,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'post': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to generate post',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _moderateContent(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final content = data['content'];
      final contentType = data['contentType']; // 'post', 'comment', 'product'

      if (content == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Content is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _aiService.moderateContent(
        content: content,
        contentType: contentType,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'moderation': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to moderate content',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _analyzeSentiment(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final content = data['content'];
      final contentType = data['contentType'];

      if (content == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Content is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _aiService.analyzeSentiment(
        content: content,
        contentType: contentType,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'sentiment': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to analyze sentiment',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _analyzeTrends(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final category = data['category'];
      final timeRange = data['timeRange']; // 'day', 'week', 'month'
      final limit = int.tryParse(data['limit']?.toString() ?? '10') ?? 10;

      final result = await _aiService.analyzeTrends(
        category: category,
        timeRange: timeRange,
        limit: limit,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'trends': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to analyze trends',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getAIStats(Request request) async {
    try {
      // Получаем статистику использования AI
      final totalRecommendations = await _database.query(
        'SELECT COUNT(*) as total FROM ai_recommendations',
      );

      final totalGeneratedContent = await _database.query(
        'SELECT COUNT(*) as total FROM ai_generated_content',
      );

      final totalModeratedContent = await _database.query(
        'SELECT COUNT(*) as total FROM ai_moderation_logs',
      );

      final recentActivity = await _database.query(
        '''
        SELECT 
          DATE(created_at) as date,
          COUNT(*) as count,
          'recommendations' as type
        FROM ai_recommendations 
        WHERE created_at >= NOW() - INTERVAL '7 days'
        GROUP BY DATE(created_at)
        UNION ALL
        SELECT 
          DATE(created_at) as date,
          COUNT(*) as count,
          'generated_content' as type
        FROM ai_generated_content 
        WHERE created_at >= NOW() - INTERVAL '7 days'
        GROUP BY DATE(created_at)
        ORDER BY date DESC, type
        ''',
      );

      final stats = {
        'totalRecommendations': totalRecommendations.first['total'] ?? 0,
        'totalGeneratedContent': totalGeneratedContent.first['total'] ?? 0,
        'totalModeratedContent': totalModeratedContent.first['total'] ?? 0,
        'recentActivity': recentActivity,
      };

      return Response.ok(
        jsonEncode({
          'success': true,
          'stats': stats,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
