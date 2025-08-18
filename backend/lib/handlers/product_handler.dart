import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/scraping_service.dart';
import '../database.dart';

class ProductHandler {
  final ScrapingService _scrapingService;
  final DatabaseService _database;

  ProductHandler(this._scrapingService, this._database);

  Router get router {
    final router = Router();

    // Категории
    router.get('/categories', _getCategories);
    router.get('/categories/<id>', _getCategory);
    
    // Продукты
    router.get('/products', _getProducts);
    router.get('/products/<id>', _getProduct);
    router.get('/categories/<categoryId>/products', _getProductsByCategory);
    router.get('/products/search', _searchProducts);
    router.get('/products/<productId>/price-history', _getPriceHistory);
    router.get('/products/best-prices', _getBestPrices);
    
    // Данные с маркетплейсов
    router.get('/marketplace/<platform>/products', _getMarketplaceProducts);
    
    // Статистика
    router.get('/products/stats', _getProductStats);
    
    // Админ функции
    router.put('/products/<id>', _updateProduct);
    router.delete('/products/<id>', _deleteProduct);

    return router;
  }

  Future<Response> _getCategories(Request request) async {
    try {
      final result = await _database.query(
        'SELECT * FROM categories ORDER BY name',
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'categories': result,
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

  Future<Response> _getCategory(Request request) async {
    try {
      final categoryId = request.params['id'];
      if (categoryId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Category ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _database.query(
        'SELECT * FROM categories WHERE id = @id',
        substitutionValues: {'id': categoryId},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Category not found',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'category': result.first,
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

  Future<Response> _getProducts(Request request) async {
    try {
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;
      final sortBy = request.url.queryParameters['sort'] ?? 'created_at';
      final order = request.url.queryParameters['order'] ?? 'desc';

      final result = await _database.query(
        '''
        SELECT p.*, c.name as category_name 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.id 
        ORDER BY p.$sortBy $order 
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query('SELECT COUNT(*) as total FROM products');
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'products': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
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

  Future<Response> _getProduct(Request request) async {
    try {
      final productId = request.params['id'];
      if (productId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Product ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _database.query(
        '''
        SELECT p.*, c.name as category_name 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.id 
        WHERE p.id = @id
        ''',
        substitutionValues: {'id': productId},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Product not found',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'product': result.first,
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

  Future<Response> _getProductsByCategory(Request request) async {
    try {
      final categoryId = request.params['categoryId'];
      if (categoryId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Category ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT p.*, c.name as category_name 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.id 
        WHERE p.category_id = @categoryId 
        ORDER BY p.created_at DESC 
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'categoryId': categoryId,
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query(
        'SELECT COUNT(*) as total FROM products WHERE category_id = @categoryId',
        substitutionValues: {'categoryId': categoryId},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'products': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
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

  Future<Response> _searchProducts(Request request) async {
    try {
      final query = request.url.queryParameters['q'];
      if (query == null || query.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Search query is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT p.*, c.name as category_name 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.id 
        WHERE p.title ILIKE @query 
           OR p.description ILIKE @query 
           OR p.brand ILIKE @query 
           OR c.name ILIKE @query
        ORDER BY p.created_at DESC 
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'query': '%$query%',
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query(
        '''
        SELECT COUNT(*) as total 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.id 
        WHERE p.title ILIKE @query 
           OR p.description ILIKE @query 
           OR p.brand ILIKE @query 
           OR c.name ILIKE @query
        ''',
        substitutionValues: {'query': '%$query%'},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'products': result,
          'query': query,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
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

  Future<Response> _getPriceHistory(Request request) async {
    try {
      final productId = request.params['productId'];
      if (productId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Product ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final days = int.tryParse(request.url.queryParameters['days'] ?? '30') ?? 30;

      final result = await _database.query(
        '''
        SELECT * FROM price_history 
        WHERE product_id = @productId 
        AND created_at >= NOW() - INTERVAL '@days days'
        ORDER BY created_at DESC
        ''',
        substitutionValues: {
          'productId': productId,
          'days': days,
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'priceHistory': result,
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

  Future<Response> _getBestPrices(Request request) async {
    try {
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;

      final result = await _database.query(
        '''
        SELECT p.*, c.name as category_name,
               (p.old_price - p.current_price) as discount_amount,
               ROUND(((p.old_price - p.current_price) / p.old_price * 100), 2) as discount_percent
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.id 
        WHERE p.old_price > p.current_price 
        ORDER BY discount_percent DESC 
        LIMIT @limit
        ''',
        substitutionValues: {'limit': limit},
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'bestPrices': result,
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

  Future<Response> _getMarketplaceProducts(Request request) async {
    try {
      final platform = request.params['platform'];
      if (platform == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Platform is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT p.*, c.name as category_name 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.id 
        WHERE p.source = @platform 
        ORDER BY p.created_at DESC 
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'platform': platform,
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query(
        'SELECT COUNT(*) as total FROM products WHERE source = @platform',
        substitutionValues: {'platform': platform},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'platform': platform,
          'products': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
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

  Future<Response> _getProductStats(Request request) async {
    try {
      final totalProducts = await _database.query('SELECT COUNT(*) as total FROM products');
      final totalCategories = await _database.query('SELECT COUNT(*) as total FROM categories');
      final avgPrice = await _database.query('SELECT AVG(current_price) as avg FROM products WHERE current_price > 0');
      final totalDiscounts = await _database.query('SELECT COUNT(*) as total FROM products WHERE old_price > current_price');

      final stats = {
        'totalProducts': totalProducts.first['total'],
        'totalCategories': totalCategories.first['total'],
        'averagePrice': avgPrice.first['avg'] ?? 0,
        'totalDiscounts': totalDiscounts.first['total'],
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

  Future<Response> _updateProduct(Request request) async {
    try {
      final productId = request.params['id'];
      if (productId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Product ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);

      // TODO: Implement product update logic
      return Response(501, body: 'Not implemented');
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

  Future<Response> _deleteProduct(Request request) async {
    try {
      final productId = request.params['id'];
      if (productId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Product ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // TODO: Implement product deletion logic
      return Response(501, body: 'Not implemented');
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
