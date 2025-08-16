import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database.dart';
import '../services/scraping_service.dart';

class ProductHandler {
  final DatabaseService _db;
  final ScrapingService _scrapingService;

  ProductHandler(this._db, this._scrapingService);

  Router get router {
    final router = Router();

    // Получение всех категорий
    router.get('/categories', _getCategories);
    
    // Получение категории по ID
    router.get('/categories/<id>', _getCategory);
    
    // Получение всех товаров
    router.get('/products', _getProducts);
    
    // Получение товара по ID
    router.get('/products/<id>', _getProduct);
    
    // Получение товаров по категории
    router.get('/categories/<categoryId>/products', _getProductsByCategory);
    
    // Поиск товаров
    router.get('/products/search', _searchProducts);
    
    // Получение истории цен товара
    router.get('/products/<productId>/price-history', _getPriceHistory);
    
    // Получение товаров с лучшими ценами
    router.get('/products/best-prices', _getBestPrices);
    
    // Получение товаров по маркетплейсу
    router.get('/marketplace/<platform>/products', _getProductsByMarketplace);
    
    // Получение статистики товаров
    router.get('/products/stats', _getProductStats);
    
    // Обновление товара (admin)
    router.put('/products/<id>', _updateProduct);
    
    // Удаление товара (admin)
    router.delete('/products/<id>', _deleteProduct);

    return router;
  }

  // Получение всех категорий
  Future<Response> _getCategories(Request request) async {
    try {
      final categories = await _db.query(
        '''
        SELECT c.*, COUNT(p.id) as product_count
        FROM categories c
        LEFT JOIN products p ON c.id = p.category_id
        GROUP BY c.id
        ORDER BY c.name
        '''
      );

      return Response(200, 
        body: json.encode({
          'categories': categories.map((category) => {
            'id': category['id'],
            'name': category['name'],
            'description': category['description'],
            'imageUrl': category['image_url'],
            'productCount': category['product_count'],
            'isActive': category['is_active'],
            'createdAt': category['created_at'].toString(),
            'updatedAt': category['updated_at'].toString()
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

  // Получение категории по ID
  Future<Response> _getCategory(Request request) async {
    try {
      final categoryId = request.params['id'];
      
      if (categoryId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID категории обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final categories = await _db.query(
        '''
        SELECT c.*, COUNT(p.id) as product_count
        FROM categories c
        LEFT JOIN products p ON c.id = p.category_id
        WHERE c.id = @categoryId
        GROUP BY c.id
        ''',
        substitutionValues: {'categoryId': categoryId}
      );

      if (categories.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Категория не найдена'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final category = categories.first;

      return Response(200, 
        body: json.encode({
          'category': {
            'id': category['id'],
            'name': category['name'],
            'description': category['description'],
            'imageUrl': category['image_url'],
            'productCount': category['product_count'],
            'isActive': category['is_active'],
            'createdAt': category['created_at'].toString(),
            'updatedAt': category['updated_at'].toString()
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

  // Получение всех товаров
  Future<Response> _getProducts(Request request) async {
    try {
      final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = (page - 1) * limit;
      
      final sortBy = request.url.queryParameters['sortBy'] ?? 'created_at';
      final sortOrder = request.url.queryParameters['sortOrder'] ?? 'DESC';
      
      // Валидация параметров сортировки
      final allowedSortFields = ['name', 'price', 'rating', 'created_at', 'updated_at'];
      if (!allowedSortFields.contains(sortBy)) {
        return Response(400, 
          body: json.encode({'error': 'Недопустимое поле для сортировки'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final allowedSortOrders = ['ASC', 'DESC'];
      if (!allowedSortOrders.contains(sortOrder.toUpperCase())) {
        return Response(400, 
          body: json.encode({'error': 'Недопустимый порядок сортировки'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Получение товаров
      final products = await _db.query(
        '''
        SELECT p.*, c.name as category_name, c.image_url as category_image
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.is_active = true
        ORDER BY p.$sortBy $sortOrder
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'limit': limit,
          'offset': offset,
        }
      );

      // Получение общего количества товаров
      final totalResult = await _db.query(
        'SELECT COUNT(*) as total FROM products WHERE is_active = true'
      );
      final total = totalResult.first['total'] as int;

      return Response(200, 
        body: json.encode({
          'products': products.map((product) => {
            'id': product['id'],
            'name': product['name'],
            'description': product['description'],
            'price': product['price'],
            'originalPrice': product['original_price'],
            'discount': product['discount'],
            'imageUrl': product['image_url'],
            'brand': product['brand'],
            'rating': product['rating'],
            'reviewCount': product['review_count'],
            'sku': product['sku'],
            'specifications': product['specifications'],
            'stock': product['stock'],
            'marketplace': product['marketplace'],
            'marketplaceUrl': product['marketplace_url'],
            'categoryId': product['category_id'],
            'categoryName': product['category_name'],
            'categoryImage': product['category_image'],
            'isActive': product['is_active'],
            'createdAt': product['created_at'].toString(),
            'updatedAt': product['updated_at'].toString()
          }).toList(),
          'pagination': {
            'page': page,
            'limit': limit,
            'total': total,
            'totalPages': (total / limit).ceil(),
            'hasNext': page < (total / limit).ceil(),
            'hasPrev': page > 1
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

  // Получение товара по ID
  Future<Response> _getProduct(Request request) async {
    try {
      final productId = request.params['id'];
      
      if (productId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID товара обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final products = await _db.query(
        '''
        SELECT p.*, c.name as category_name, c.image_url as category_image
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.id = @productId
        ''',
        substitutionValues: {'productId': productId}
      );

      if (products.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Товар не найден'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final product = products.first;

      // Получение истории цен
      final priceHistory = await _db.query(
        '''
        SELECT price, original_price, discount, created_at
        FROM price_history
        WHERE product_id = @productId
        ORDER BY created_at DESC
        LIMIT 30
        ''',
        substitutionValues: {'productId': productId}
      );

      return Response(200, 
        body: json.encode({
          'product': {
            'id': product['id'],
            'name': product['name'],
            'description': product['description'],
            'price': product['price'],
            'originalPrice': product['original_price'],
            'discount': product['discount'],
            'imageUrl': product['image_url'],
            'brand': product['brand'],
            'rating': product['rating'],
            'reviewCount': product['review_count'],
            'sku': product['sku'],
            'specifications': product['specifications'],
            'stock': product['stock'],
            'marketplace': product['marketplace'],
            'marketplaceUrl': product['marketplace_url'],
            'categoryId': product['category_id'],
            'categoryName': product['category_name'],
            'categoryImage': product['category_image'],
            'isActive': product['is_active'],
            'createdAt': product['created_at'].toString(),
            'updatedAt': product['updated_at'].toString()
          },
          'priceHistory': priceHistory.map((price) => {
            'price': price['price'],
            'originalPrice': price['original_price'],
            'discount': price['discount'],
            'createdAt': price['created_at'].toString()
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

  // Получение товаров по категории
  Future<Response> _getProductsByCategory(Request request) async {
    try {
      final categoryId = request.params['categoryId'];
      
      if (categoryId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID категории обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = (page - 1) * limit;

      // Получение товаров категории
      final products = await _db.query(
        '''
        SELECT p.*, c.name as category_name, c.image_url as category_image
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.category_id = @categoryId AND p.is_active = true
        ORDER BY p.created_at DESC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'categoryId': categoryId,
          'limit': limit,
          'offset': offset,
        }
      );

      // Получение общего количества товаров в категории
      final totalResult = await _db.query(
        'SELECT COUNT(*) as total FROM products WHERE category_id = @categoryId AND is_active = true',
        substitutionValues: {'categoryId': categoryId}
      );
      final total = totalResult.first['total'] as int;

      return Response(200, 
        body: json.encode({
          'products': products.map((product) => {
            'id': product['id'],
            'name': product['name'],
            'description': product['description'],
            'price': product['price'],
            'originalPrice': product['original_price'],
            'discount': product['discount'],
            'imageUrl': product['image_url'],
            'brand': product['brand'],
            'rating': product['rating'],
            'reviewCount': product['review_count'],
            'sku': product['sku'],
            'specifications': product['specifications'],
            'stock': product['stock'],
            'marketplace': product['marketplace'],
            'marketplaceUrl': product['marketplace_url'],
            'categoryId': product['category_id'],
            'categoryName': product['category_name'],
            'categoryImage': product['category_image'],
            'isActive': product['is_active'],
            'createdAt': product['created_at'].toString(),
            'updatedAt': product['updated_at'].toString()
          }).toList(),
          'pagination': {
            'page': page,
            'limit': limit,
            'total': total,
            'totalPages': (total / limit).ceil(),
            'hasNext': page < (total / limit).ceil(),
            'hasPrev': page > 1
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

  // Поиск товаров
  Future<Response> _searchProducts(Request request) async {
    try {
      final query = request.url.queryParameters['q'];
      final categoryId = request.url.queryParameters['categoryId'];
      final minPrice = double.tryParse(request.url.queryParameters['minPrice'] ?? '');
      final maxPrice = double.tryParse(request.url.queryParameters['maxPrice'] ?? '');
      final marketplace = request.url.queryParameters['marketplace'];
      final brand = request.url.queryParameters['brand'];
      
      if (query == null || query.trim().isEmpty) {
        return Response(400, 
          body: json.encode({'error': 'Поисковый запрос обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = (page - 1) * limit;

      // Построение SQL запроса
      var sql = '''
        SELECT p.*, c.name as category_name, c.image_url as category_image
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.is_active = true AND (
          p.name ILIKE @query OR 
          p.description ILIKE @query OR 
          p.brand ILIKE @query OR
          p.sku ILIKE @query
        )
      ''';
      
      final substitutionValues = <String, dynamic>{
        'query': '%${query.trim()}%',
        'limit': limit,
        'offset': offset,
      };

      if (categoryId != null) {
        sql += ' AND p.category_id = @categoryId';
        substitutionValues['categoryId'] = categoryId;
      }

      if (minPrice != null) {
        sql += ' AND p.price >= @minPrice';
        substitutionValues['minPrice'] = minPrice;
      }

      if (maxPrice != null) {
        sql += ' AND p.price <= @maxPrice';
        substitutionValues['maxPrice'] = maxPrice;
      }

      if (marketplace != null) {
        sql += ' AND p.marketplace = @marketplace';
        substitutionValues['marketplace'] = marketplace;
      }

      if (brand != null) {
        sql += ' AND p.brand ILIKE @brand';
        substitutionValues['brand'] = '%$brand%';
      }

      sql += ' ORDER BY p.rating DESC, p.created_at DESC LIMIT @limit OFFSET @offset';

      final products = await _db.query(sql, substitutionValues: substitutionValues);

      // Подсчет общего количества результатов
      var countSql = '''
        SELECT COUNT(*) as total
        FROM products p
        WHERE p.is_active = true AND (
          p.name ILIKE @query OR 
          p.description ILIKE @query OR 
          p.brand ILIKE @query OR
          p.sku ILIKE @query
        )
      ''';
      
      final countSubstitutionValues = <String, dynamic>{
        'query': '%${query.trim()}%',
      };

      if (categoryId != null) {
        countSql += ' AND p.category_id = @categoryId';
        countSubstitutionValues['categoryId'] = categoryId;
      }

      if (minPrice != null) {
        countSql += ' AND p.price >= @minPrice';
        countSubstitutionValues['minPrice'] = minPrice;
      }

      if (maxPrice != null) {
        countSql += ' AND p.price <= @maxPrice';
        countSubstitutionValues['maxPrice'] = maxPrice;
      }

      if (marketplace != null) {
        countSql += ' AND p.marketplace = @marketplace';
        countSubstitutionValues['marketplace'] = marketplace;
      }

      if (brand != null) {
        countSql += ' AND p.brand ILIKE @brand';
        countSubstitutionValues['brand'] = '%$brand%';
      }

      final totalResult = await _db.query(countSql, substitutionValues: countSubstitutionValues);
      final total = totalResult.first['total'] as int;

      return Response(200, 
        body: json.encode({
          'query': query,
          'products': products.map((product) => {
            'id': product['id'],
            'name': product['name'],
            'description': product['description'],
            'price': product['price'],
            'originalPrice': product['original_price'],
            'discount': product['discount'],
            'imageUrl': product['image_url'],
            'brand': product['brand'],
            'rating': product['rating'],
            'reviewCount': product['review_count'],
            'sku': product['sku'],
            'specifications': product['specifications'],
            'stock': product['stock'],
            'marketplace': product['marketplace'],
            'marketplaceUrl': product['marketplace_url'],
            'categoryId': product['category_id'],
            'categoryName': product['category_name'],
            'categoryImage': product['category_image'],
            'isActive': product['is_active'],
            'createdAt': product['created_at'].toString(),
            'updatedAt': product['updated_at'].toString()
          }).toList(),
          'pagination': {
            'page': page,
            'limit': limit,
            'total': total,
            'totalPages': (total / limit).ceil(),
            'hasNext': page < (total / limit).ceil(),
            'hasPrev': page > 1
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

  // Получение истории цен товара
  Future<Response> _getPriceHistory(Request request) async {
    try {
      final productId = request.params['productId'];
      
      if (productId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID товара обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final days = int.tryParse(request.url.queryParameters['days'] ?? '30') ?? 30;

      final priceHistory = await _db.query(
        '''
        SELECT price, original_price, discount, created_at
        FROM price_history
        WHERE product_id = @productId
        AND created_at >= NOW() - INTERVAL '@days days'
        ORDER BY created_at DESC
        ''',
        substitutionValues: {
          'productId': productId,
          'days': days,
        }
      );

      return Response(200, 
        body: json.encode({
          'productId': productId,
          'priceHistory': priceHistory.map((price) => {
            'price': price['price'],
            'originalPrice': price['original_price'],
            'discount': price['discount'],
            'createdAt': price['created_at'].toString()
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

  // Получение товаров с лучшими ценами
  Future<Response> _getBestPrices(Request request) async {
    try {
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final categoryId = request.url.queryParameters['categoryId'];

      var sql = '''
        SELECT p.*, c.name as category_name, c.image_url as category_image
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.is_active = true AND p.discount > 0
      ''';
      
      final substitutionValues = <String, dynamic>{
        'limit': limit,
      };

      if (categoryId != null) {
        sql += ' AND p.category_id = @categoryId';
        substitutionValues['categoryId'] = categoryId;
      }

      sql += ' ORDER BY p.discount DESC, p.rating DESC LIMIT @limit';

      final products = await _db.query(sql, substitutionValues: substitutionValues);

      return Response(200, 
        body: json.encode({
          'products': products.map((product) => {
            'id': product['id'],
            'name': product['name'],
            'description': product['description'],
            'price': product['price'],
            'originalPrice': product['original_price'],
            'discount': product['discount'],
            'imageUrl': product['image_url'],
            'brand': product['brand'],
            'rating': product['rating'],
            'reviewCount': product['review_count'],
            'sku': product['sku'],
            'specifications': product['specifications'],
            'stock': product['stock'],
            'marketplace': product['marketplace'],
            'marketplaceUrl': product['marketplace_url'],
            'categoryId': product['category_id'],
            'categoryName': product['category_name'],
            'categoryImage': product['category_image'],
            'isActive': product['is_active'],
            'createdAt': product['created_at'].toString(),
            'updatedAt': product['updated_at'].toString()
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

  // Получение товаров по маркетплейсу
  Future<Response> _getProductsByMarketplace(Request request) async {
    try {
      final platform = request.params['platform'];
      
      if (platform == null) {
        return Response(400, 
          body: json.encode({'error': 'Платформа обязательна'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = (page - 1) * limit;

      final products = await _db.query(
        '''
        SELECT p.*, c.name as category_name, c.image_url as category_image
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.marketplace = @platform AND p.is_active = true
        ORDER BY p.created_at DESC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'platform': platform,
          'limit': limit,
          'offset': offset,
        }
      );

      final totalResult = await _db.query(
        'SELECT COUNT(*) as total FROM products WHERE marketplace = @platform AND is_active = true',
        substitutionValues: {'platform': platform}
      );
      final total = totalResult.first['total'] as int;

      return Response(200, 
        body: json.encode({
          'platform': platform,
          'products': products.map((product) => {
            'id': product['id'],
            'name': product['name'],
            'description': product['description'],
            'price': product['price'],
            'originalPrice': product['original_price'],
            'discount': product['discount'],
            'imageUrl': product['image_url'],
            'brand': product['brand'],
            'rating': product['rating'],
            'reviewCount': product['review_count'],
            'sku': product['sku'],
            'specifications': product['specifications'],
            'stock': product['stock'],
            'marketplace': product['marketplace'],
            'marketplaceUrl': product['marketplace_url'],
            'categoryId': product['category_id'],
            'categoryName': product['category_name'],
            'categoryImage': product['category_image'],
            'isActive': product['is_active'],
            'createdAt': product['created_at'].toString(),
            'updatedAt': product['updated_at'].toString()
          }).toList(),
          'pagination': {
            'page': page,
            'limit': limit,
            'total': total,
            'totalPages': (total / limit).ceil(),
            'hasNext': page < (total / limit).ceil(),
            'hasPrev': page > 1
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

  // Получение статистики товаров
  Future<Response> _getProductStats(Request request) async {
    try {
      // Общая статистика
      final totalProducts = await _db.query('SELECT COUNT(*) as total FROM products WHERE is_active = true');
      final totalCategories = await _db.query('SELECT COUNT(*) as total FROM categories WHERE is_active = true');
      
      // Статистика по маркетплейсам
      final marketplaceStats = await _db.query(
        'SELECT marketplace, COUNT(*) as count FROM products WHERE is_active = true GROUP BY marketplace'
      );
      
      // Статистика по категориям
      final categoryStats = await _db.query(
        '''
        SELECT c.name, COUNT(p.id) as count
        FROM categories c
        LEFT JOIN products p ON c.id = p.category_id AND p.is_active = true
        WHERE c.is_active = true
        GROUP BY c.id, c.name
        ORDER BY count DESC
        LIMIT 10
        '''
      );
      
      // Статистика цен
      final priceStats = await _db.query(
        '''
        SELECT 
          MIN(price) as min_price,
          MAX(price) as max_price,
          AVG(price) as avg_price,
          COUNT(*) as total_products
        FROM products 
        WHERE is_active = true AND price > 0
        '''
      );

      return Response(200, 
        body: json.encode({
          'overview': {
            'totalProducts': totalProducts.first['total'],
            'totalCategories': totalCategories.first['total']
          },
          'marketplaceStats': marketplaceStats.map((stat) => {
            'marketplace': stat['marketplace'],
            'count': stat['count']
          }).toList(),
          'categoryStats': categoryStats.map((stat) => {
            'category': stat['name'],
            'count': stat['count']
          }).toList(),
          'priceStats': {
            'minPrice': priceStats.first['min_price'],
            'maxPrice': priceStats.first['max_price'],
            'avgPrice': priceStats.first['avg_price'],
            'totalProducts': priceStats.first['total_products']
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

  // Обновление товара (admin)
  Future<Response> _updateProduct(Request request) async {
    try {
      final productId = request.params['id'];
      
      if (productId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID товара обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      // Проверка существования товара
      final existingProducts = await _db.query(
        'SELECT id FROM products WHERE id = @productId',
        substitutionValues: {'productId': productId}
      );

      if (existingProducts.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Товар не найден'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Обновление полей
      final updateFields = <String, dynamic>{};
      if (data['name'] != null) updateFields['name'] = data['name'];
      if (data['description'] != null) updateFields['description'] = data['description'];
      if (data['price'] != null) updateFields['price'] = data['price'];
      if (data['originalPrice'] != null) updateFields['original_price'] = data['originalPrice'];
      if (data['discount'] != null) updateFields['discount'] = data['discount'];
      if (data['imageUrl'] != null) updateFields['image_url'] = data['imageUrl'];
      if (data['brand'] != null) updateFields['brand'] = data['brand'];
      if (data['rating'] != null) updateFields['rating'] = data['rating'];
      if (data['reviewCount'] != null) updateFields['review_count'] = data['reviewCount'];
      if (data['sku'] != null) updateFields['sku'] = data['sku'];
      if (data['specifications'] != null) updateFields['specifications'] = data['specifications'];
      if (data['stock'] != null) updateFields['stock'] = data['stock'];
      if (data['categoryId'] != null) updateFields['category_id'] = data['categoryId'];
      if (data['isActive'] != null) updateFields['is_active'] = data['isActive'];

      if (updateFields.isNotEmpty) {
        final setClause = updateFields.keys.map((key) => '$key = @$key').join(', ');
        final query = 'UPDATE products SET $setClause, updated_at = NOW() WHERE id = @productId';
        
        final substitutionValues = Map<String, dynamic>.from(updateFields);
        substitutionValues['productId'] = productId;

        await _db.execute(query, substitutionValues: substitutionValues);
      }

      return Response(200, 
        body: json.encode({'message': 'Товар успешно обновлен'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Удаление товара (admin)
  Future<Response> _deleteProduct(Request request) async {
    try {
      final productId = request.params['id'];
      
      if (productId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID товара обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка существования товара
      final existingProducts = await _db.query(
        'SELECT id FROM products WHERE id = @productId',
        substitutionValues: {'productId': productId}
      );

      if (existingProducts.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Товар не найден'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Мягкое удаление (установка is_active = false)
      await _db.execute(
        'UPDATE products SET is_active = false, updated_at = NOW() WHERE id = @productId',
        substitutionValues: {'productId': productId}
      );

      return Response(200, 
        body: json.encode({'message': 'Товар успешно удален'}),
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
