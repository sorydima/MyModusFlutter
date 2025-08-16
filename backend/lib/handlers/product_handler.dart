import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database.dart';
import '../services/ai_service.dart';
import '../models.dart';

class ProductHandler {
  final DatabaseService _db;
  final AIService _aiService;
  
  ProductHandler(this._db, this._aiService);
  
  Router get router {
    final router = Router();
    
    // Получение списка товаров
    router.get('/', _getProducts);
    
    // Получение товара по ID
    router.get('/<id>', _getProduct);
    
    // Получение рекомендаций
    router.get('/recommendations', _getRecommendations);
    
    // Поиск товаров
    router.get('/search', _searchProducts);
    
    // Создание товара (admin)
    router.post('/', _createProduct);
    
    // Обновление товара (admin)
    router.put('/<id>', _updateProduct);
    
    // Удаление товара (admin)
    router.delete('/<id>', _deleteProduct);
    
    return router;
  }
  
  /// Получение списка товаров
  Future<Response> _getProducts(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final limit = int.tryParse(queryParams['limit'] ?? '50') ?? 50;
      final offset = int.tryParse(queryParams['offset'] ?? '0') ?? 0;
      final category = queryParams['category'];
      final source = queryParams['source'];
      final minPrice = int.tryParse(queryParams['min_price'] ?? '0') ?? 0;
      final maxPrice = int.tryParse(queryParams['max_price'] ?? '999999') ?? 999999;
      
      final conn = await _db.getConnection();
      try {
        String query = '''
          SELECT * FROM products 
          WHERE price BETWEEN @min_price AND @max_price
        ''';
        
        final params = <String, dynamic>{
          'min_price': minPrice,
          'max_price': maxPrice,
          'limit': limit,
          'offset': offset,
        };
        
        if (category != null) {
          query += ' AND category_id = @category';
          params['category'] = category;
        }
        
        if (source != null) {
          query += ' AND source = @source';
          params['source'] = source;
        }
        
        query += ' ORDER BY created_at DESC LIMIT @limit OFFSET @offset';
        
        final results = await conn.query(query, substitutionValues: params);
        
        final products = results.map((row) => Product.fromRow(row)).toList();
        
        return Response.ok(
          jsonEncode({
            'products': products.map((p) => p.toJson()).toList(),
            'total': products.length,
            'limit': limit,
            'offset': offset,
          }),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get products: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Получение товара по ID
  Future<Response> _getProduct(Request request, String id) async {
    try {
      final conn = await _db.getConnection();
      try {
        final results = await conn.query(
          'SELECT * FROM products WHERE id = @id',
          substitutionValues: {'id': id},
        );
        
        if (results.isEmpty) {
          return Response(404,
            body: jsonEncode({'error': 'Product not found'}),
            headers: {'content-type': 'application/json'},
          );
        }
        
        final product = Product.fromRow(results.first);
        
        return Response.ok(
          jsonEncode(product.toJson()),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get product: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Получение рекомендаций
  Future<Response> _getRecommendations(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final userId = queryParams['user_id'];
      final limit = int.tryParse(queryParams['limit'] ?? '10') ?? 10;
      
      if (userId == null) {
        return Response(400,
          body: jsonEncode({'error': 'User ID is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final conn = await _db.getConnection();
      try {
        // Получение истории покупок пользователя
        final userHistory = await conn.query(
          '''
          SELECT p.* FROM products p
          JOIN orders o ON p.id = o.product_id
          WHERE o.user_id = @user_id
          ''',
          substitutionValues: {'user_id': userId},
        );
        
        // Получение доступных товаров
        final availableProducts = await conn.query(
          'SELECT * FROM products ORDER BY rating DESC LIMIT 100',
        );
        
        final historyProducts = userHistory.map((row) => Product.fromRow(row)).toList();
        final availableProductsList = availableProducts.map((row) => Product.fromRow(row)).toList();
        
        // Генерация рекомендаций
        final recommendations = await _aiService.generateRecommendations(
          userId: userId,
          userHistory: historyProducts,
          availableProducts: availableProductsList,
          limit: limit,
        );
        
        return Response.ok(
          jsonEncode({
            'recommendations': recommendations.map((r) => {
              'product': r.product.toJson(),
              'score': r.score,
              'reason': r.reason,
            }).toList(),
          }),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get recommendations: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Поиск товаров
  Future<Response> _searchProducts(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final query = queryParams['q'];
      final limit = int.tryParse(queryParams['limit'] ?? '20') ?? 20;
      
      if (query == null || query.isEmpty) {
        return Response(400,
          body: jsonEncode({'error': 'Search query is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final conn = await _db.getConnection();
      try {
        final results = await conn.query(
          '''
          SELECT * FROM products 
          WHERE title ILIKE @query OR description ILIKE @query
          ORDER BY rating DESC, created_at DESC
          LIMIT @limit
          ''',
          substitutionValues: {
            'query': '%$query%',
            'limit': limit,
          },
        );
        
        final products = results.map((row) => Product.fromRow(row)).toList();
        
        return Response.ok(
          jsonEncode({
            'products': products.map((p) => p.toJson()).toList(),
            'query': query,
            'total': products.length,
          }),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Search failed: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Создание товара (admin)
  Future<Response> _createProduct(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      // TODO: Проверка прав администратора
      
      final conn = await _db.getConnection();
      try {
        final result = await conn.query(
          '''
          INSERT INTO products (
            title, description, price, old_price, discount,
            image_url, product_url, brand, category_id, sku,
            specifications, stock, rating, review_count, source, source_id
          ) VALUES (
            @title, @description, @price, @old_price, @discount,
            @image_url, @product_url, @brand, @category_id, @sku,
            @specifications, @stock, @rating, @review_count, @source, @source_id
          ) RETURNING id
          ''',
          substitutionValues: {
            'title': data['title'],
            'description': data['description'],
            'price': data['price'],
            'old_price': data['old_price'],
            'discount': data['discount'],
            'image_url': data['image_url'],
            'product_url': data['product_url'],
            'brand': data['brand'],
            'category_id': data['category_id'],
            'sku': data['sku'],
            'specifications': jsonEncode(data['specifications'] ?? {}),
            'stock': data['stock'] ?? 0,
            'rating': data['rating'] ?? 0.0,
            'review_count': data['review_count'] ?? 0,
            'source': data['source'],
            'source_id': data['source_id'],
          },
        );
        
        final productId = result.first.first;
        
        return Response(201,
          body: jsonEncode({
            'message': 'Product created successfully',
            'product_id': productId,
          }),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create product: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Обновление товара (admin)
  Future<Response> _updateProduct(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      // TODO: Проверка прав администратора
      
      final conn = await _db.getConnection();
      try {
        final result = await conn.query(
          '''
          UPDATE products SET
            title = COALESCE(@title, title),
            description = COALESCE(@description, description),
            price = COALESCE(@price, price),
            old_price = COALESCE(@old_price, old_price),
            discount = COALESCE(@discount, discount),
            image_url = COALESCE(@image_url, image_url),
            product_url = COALESCE(@product_url, product_url),
            brand = COALESCE(@brand, brand),
            category_id = COALESCE(@category_id, category_id),
            sku = COALESCE(@sku, sku),
            specifications = COALESCE(@specifications, specifications),
            stock = COALESCE(@stock, stock),
            rating = COALESCE(@rating, rating),
            review_count = COALESCE(@review_count, review_count),
            updated_at = CURRENT_TIMESTAMP
          WHERE id = @id
          RETURNING id
          ''',
          substitutionValues: {
            'id': id,
            'title': data['title'],
            'description': data['description'],
            'price': data['price'],
            'old_price': data['old_price'],
            'discount': data['discount'],
            'image_url': data['image_url'],
            'product_url': data['product_url'],
            'brand': data['brand'],
            'category_id': data['category_id'],
            'sku': data['sku'],
            'specifications': data['specifications'] != null ? jsonEncode(data['specifications']) : null,
            'stock': data['stock'],
            'rating': data['rating'],
            'review_count': data['review_count'],
          },
        );
        
        if (result.isEmpty) {
          return Response(404,
            body: jsonEncode({'error': 'Product not found'}),
            headers: {'content-type': 'application/json'},
          );
        }
        
        return Response.ok(
          jsonEncode({'message': 'Product updated successfully'}),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update product: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Удаление товара (admin)
  Future<Response> _deleteProduct(Request request, String id) async {
    try {
      // TODO: Проверка прав администратора
      
      final conn = await _db.getConnection();
      try {
        final result = await conn.query(
          'DELETE FROM products WHERE id = @id RETURNING id',
          substitutionValues: {'id': id},
        );
        
        if (result.isEmpty) {
          return Response(404,
            body: jsonEncode({'error': 'Product not found'}),
            headers: {'content-type': 'application/json'},
          );
        }
        
        return Response.ok(
          jsonEncode({'message': 'Product deleted successfully'}),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete product: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
