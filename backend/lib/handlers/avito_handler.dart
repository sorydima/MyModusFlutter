import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../scrapers/adapters/avito_adapter.dart' as avito_adapter;
import '../scrapers/scraper_manager.dart';
import '../database.dart';
import '../models.dart';

class AvitoHandler {
  final ScraperManager scraperManager;
  final DatabaseService db;

  AvitoHandler({required this.scraperManager, required this.db});

  Router get router {
    final router = Router();

    // Парсинг единичного товара с Avito
    router.post('/parse', _parseProduct);
    
    // Поиск товаров на Avito
    router.get('/search', _searchProducts);
    
    // Получение товаров по категории
    router.get('/category/<category>', _getProductsByCategory);
    
    // Получение информации о продавце
    router.post('/seller', _getSellerInfo);
    
    // Получение похожих товаров
    router.get('/similar/<productId>', _getSimilarProducts);
    
    // Добавление в избранное
    router.post('/favorites', _addToFavorites);
    
    // Удаление из избранного
    router.delete('/favorites/<productId>', _removeFromFavorites);
    
    // Получение избранных товаров
    router.get('/favorites', _getFavorites);
    
    // Проверка актуальности цены
    router.post('/price-check', _checkPriceUpdate);
    
    // Подписка на уведомления о цене
    router.post('/price-alerts', _subscribeToPriceAlerts);
    
    // Получение статистики по категории
    router.get('/stats/<category>', _getCategoryStats);

    return router;
  }

  Future<Response> _parseProduct(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);
      final url = data['url'] as String?;

      if (url == null || !url.contains('avito.ru')) {
        return Response.badRequest(
          body: json.encode({'error': 'Неверный URL Avito'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final parsed = await avito_adapter.parseAvito(url);
      
      if (parsed.containsKey('error')) {
        return Response.internalServerError(
          body: json.encode({'error': parsed['error']}),
          headers: {'content-type': 'application/json'},
        );
      }

      // Сохраняем товар в базу данных
      await _saveProductToDb(parsed);

      return Response.ok(
        json.encode(parsed),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка парсинга: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _searchProducts(Request request) async {
    try {
      final query = request.url.queryParameters['q'];
      final location = request.url.queryParameters['location'];
      final minPrice = request.url.queryParameters['min_price'];
      final maxPrice = request.url.queryParameters['max_price'];
      final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;

      if (query == null || query.isEmpty) {
        return Response.badRequest(
          body: json.encode({'error': 'Параметр поиска не указан'}),
          headers: {'content-type': 'application/json'},
        );
      }

      // Здесь нужно реализовать поиск через scraper
      // Пока возвращаем заглушку
      final products = await _searchAvitoProducts(query, location, minPrice, maxPrice, page);

      return Response.ok(
        json.encode({'products': products}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка поиска: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getProductsByCategory(Request request) async {
    try {
      final category = request.params['category'];
      final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;

      if (category == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Категория не указана'}),
          headers: {'content-type': 'application/json'},
        );
      }

      // Получаем товары из базы данных
      final products = await _getProductsFromDb('avito', category, page);

      return Response.ok(
        json.encode({'products': products}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка получения товаров: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getSellerInfo(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);
      final url = data['url'] as String?;

      if (url == null || !url.contains('avito.ru')) {
        return Response.badRequest(
          body: json.encode({'error': 'Неверный URL продавца'}),
          headers: {'content-type': 'application/json'},
        );
      }

      // Здесь нужно реализовать парсинг информации о продавце
      final sellerInfo = await _parseSellerInfo(url);

      return Response.ok(
        json.encode(sellerInfo),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка получения информации о продавце: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getSimilarProducts(Request request) async {
    try {
      final productId = request.params['productId'];

      if (productId == null) {
        return Response.badRequest(
          body: json.encode({'error': 'ID товара не указан'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final products = await _findSimilarProducts(productId);

      return Response.ok(
        json.encode({'products': products}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка поиска похожих товаров: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _addToFavorites(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);
      final productId = data['product_id'] as String?;
      final userId = _getUserIdFromRequest(request);

      if (productId == null) {
        return Response.badRequest(
          body: json.encode({'error': 'ID товара не указан'}),
          headers: {'content-type': 'application/json'},
        );
      }

      await _addProductToFavorites(userId, productId);

      return Response.ok(
        json.encode({'success': true}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка добавления в избранное: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _removeFromFavorites(Request request) async {
    try {
      final productId = request.params['productId'];
      final userId = _getUserIdFromRequest(request);

      if (productId == null) {
        return Response.badRequest(
          body: json.encode({'error': 'ID товара не указан'}),
          headers: {'content-type': 'application/json'},
        );
      }

      await _removeProductFromFavorites(userId, productId);

      return Response.ok(
        json.encode({'success': true}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка удаления из избранного: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getFavorites(Request request) async {
    try {
      final userId = _getUserIdFromRequest(request);
      final products = await _getUserFavorites(userId);

      return Response.ok(
        json.encode({'products': products}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка получения избранного: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _checkPriceUpdate(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);
      final url = data['url'] as String?;

      if (url == null) {
        return Response.badRequest(
          body: json.encode({'error': 'URL не указан'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final currentPrice = await _getCurrentPrice(url);
      final oldPrice = await _getOldPrice(url);

      return Response.ok(
        json.encode({
          'current_price': currentPrice,
          'old_price': oldPrice,
          'price_changed': currentPrice != oldPrice,
          'price_difference': oldPrice != null ? currentPrice - oldPrice : null,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка проверки цены: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _subscribeToPriceAlerts(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);
      final productId = data['product_id'] as String?;
      final targetPrice = data['target_price'] as int?;
      final userId = _getUserIdFromRequest(request);

      if (productId == null || targetPrice == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Не указаны обязательные параметры'}),
          headers: {'content-type': 'application/json'},
        );
      }

      await _createPriceAlert(userId, productId, targetPrice);

      return Response.ok(
        json.encode({'success': true}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка создания уведомления: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getCategoryStats(Request request) async {
    try {
      final category = request.params['category'];

      if (category == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Категория не указана'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final stats = await _calculateCategoryStats(category);

      return Response.ok(
        json.encode(stats),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Ошибка получения статистики: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Вспомогательные методы

  Future<void> _saveProductToDb(Map<String, dynamic> productData) async {
    final conn = await db.getConnection();
    try {
      await conn.execute('''
        INSERT INTO products (
          external_id, source, title, description, price, currency, 
          url, image_url, location, condition, seller_type, created_at, updated_at
        ) VALUES (
          @external_id, @source, @title, @description, @price, @currency,
          @url, @image_url, @location, @condition, @seller_type, @created_at, @updated_at
        ) ON CONFLICT (external_id, source) DO UPDATE SET
          title = EXCLUDED.title,
          description = EXCLUDED.description,
          price = EXCLUDED.price,
          currency = EXCLUDED.currency,
          image_url = EXCLUDED.image_url,
          location = EXCLUDED.location,
          condition = EXCLUDED.condition,
          seller_type = EXCLUDED.seller_type,
          updated_at = EXCLUDED.updated_at
      ''', substitutionValues: {
        'external_id': productData['external_id'],
        'source': productData['marketplace'],
        'title': productData['title'],
        'description': productData['description'],
        'price': productData['price'],
        'currency': productData['currency'],
        'url': productData['url'],
        'image_url': productData['image_url'],
        'location': productData['location'],
        'condition': productData['condition'],
        'seller_type': productData['seller_type'],
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
      });
    } finally {
      await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> _searchAvitoProducts(String query, String? location, String? minPrice, String? maxPrice, int page) async {
    // Заглушка для поиска. В реальной реализации здесь был бы вызов скрапера
    return [];
  }

  Future<List<Map<String, dynamic>>> _getProductsFromDb(String source, String category, int page) async {
    final conn = await db.getConnection();
    try {
      final results = await conn.execute('''
        SELECT external_id, title, description, price, currency, url, image_url,
               location, condition, seller_type, created_at, updated_at
        FROM products 
        WHERE source = @source 
        ORDER BY created_at DESC 
        LIMIT 20 OFFSET @offset
      ''', substitutionValues: {
        'source': source,
        'offset': (page - 1) * 20,
      });

      return results.map((row) => {
        'external_id': row[0],
        'title': row[1],
        'description': row[2],
        'price': row[3],
        'currency': row[4],
        'url': row[5],
        'image_url': row[6],
        'location': row[7],
        'condition': row[8],
        'seller_type': row[9],
        'created_at': row[10],
        'updated_at': row[11],
      }).toList();
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>> _parseSellerInfo(String url) async {
    // Заглушка для парсинга информации о продавце
    return {
      'name': 'Продавец',
      'rating': 4.5,
      'reviews_count': 123,
      'registration_date': '2020-01-01',
      'is_verified': true,
    };
  }

  Future<List<Map<String, dynamic>>> _findSimilarProducts(String productId) async {
    // Заглушка для поиска похожих товаров
    return [];
  }

  String _getUserIdFromRequest(Request request) {
    // Заглушка для получения ID пользователя из токена
    return 'user_1';
  }

  Future<void> _addProductToFavorites(String userId, String productId) async {
    final conn = await db.getConnection();
    try {
      await conn.execute('''
        INSERT INTO user_favorites (user_id, product_id, created_at)
        VALUES (@user_id, @product_id, @created_at)
        ON CONFLICT (user_id, product_id) DO NOTHING
      ''', substitutionValues: {
        'user_id': userId,
        'product_id': productId,
        'created_at': DateTime.now(),
      });
    } finally {
      await conn.close();
    }
  }

  Future<void> _removeProductFromFavorites(String userId, String productId) async {
    final conn = await db.getConnection();
    try {
      await conn.execute('''
        DELETE FROM user_favorites 
        WHERE user_id = @user_id AND product_id = @product_id
      ''', substitutionValues: {
        'user_id': userId,
        'product_id': productId,
      });
    } finally {
      await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> _getUserFavorites(String userId) async {
    final conn = await db.getConnection();
    try {
      final results = await conn.execute('''
        SELECT p.external_id, p.title, p.description, p.price, p.currency, 
               p.url, p.image_url, p.location, p.condition, p.seller_type
        FROM user_favorites uf
        JOIN products p ON uf.product_id = p.external_id
        WHERE uf.user_id = @user_id
        ORDER BY uf.created_at DESC
      ''', substitutionValues: {
        'user_id': userId,
      });

      return results.map((row) => {
        'external_id': row[0],
        'title': row[1],
        'description': row[2],
        'price': row[3],
        'currency': row[4],
        'url': row[5],
        'image_url': row[6],
        'location': row[7],
        'condition': row[8],
        'seller_type': row[9],
      }).toList();
    } finally {
      await conn.close();
    }
  }

  Future<int> _getCurrentPrice(String url) async {
    final parsed = await avito_adapter.parseAvito(url);
    return int.tryParse(parsed['price']?.toString() ?? '0') ?? 0;
  }

  Future<int?> _getOldPrice(String url) async {
    final conn = await db.getConnection();
    try {
      final results = await conn.execute('''
        SELECT price FROM products WHERE url = @url ORDER BY updated_at DESC LIMIT 1
      ''', substitutionValues: {'url': url});

      if (results.isNotEmpty) {
        return int.tryParse(results.first[0]?.toString() ?? '0');
      }
      return null;
    } finally {
      await conn.close();
    }
  }

  Future<void> _createPriceAlert(String userId, String productId, int targetPrice) async {
    final conn = await db.getConnection();
    try {
      await conn.execute('''
        INSERT INTO price_alerts (user_id, product_id, target_price, created_at, is_active)
        VALUES (@user_id, @product_id, @target_price, @created_at, @is_active)
      ''', substitutionValues: {
        'user_id': userId,
        'product_id': productId,
        'target_price': targetPrice,
        'created_at': DateTime.now(),
        'is_active': true,
      });
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>> _calculateCategoryStats(String category) async {
    final conn = await db.getConnection();
    try {
      final results = await conn.execute('''
        SELECT 
          COUNT(*) as total_products,
          AVG(price) as avg_price,
          MIN(price) as min_price,
          MAX(price) as max_price
        FROM products 
        WHERE source = 'avito' AND price IS NOT NULL AND price > 0
      ''');

      if (results.isNotEmpty) {
        final row = results.first;
        return {
          'total_products': row[0],
          'avg_price': (row[1] as double?)?.round(),
          'min_price': row[2],
          'max_price': row[3],
          'category': category,
        };
      }

      return {
        'total_products': 0,
        'avg_price': 0,
        'min_price': 0,
        'max_price': 0,
        'category': category,
      };
    } finally {
      await conn.close();
    }
  }
}
