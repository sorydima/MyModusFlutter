import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import '../lib/auth.dart' as auth;
import '../lib/database.dart';
import '../lib/scrapers/scraper_manager.dart';

void main(List<String> args) async {
  dotenv.load();
  
  // Initialize database
  await DatabaseService.runMigrations();
  await DatabaseService.seedInitialData();
  
  final app = Router();
  final scraperManager = ScraperManager(DatabaseService());

  // Health check
  app.get('/healthz', (Request req) => Response.ok('ok'));

  // Authentication endpoints
  app.post('/auth/login', (Request req) async {
    final payload = {'userId': 'test_user'}; // TODO: validate input
    final token = auth.generateJwt(payload);
    return Response.ok({'token': token}, headers: {'content-type': 'application/json'});
  });

  // Scraping endpoints
  app.post('/api/scrape/all', (Request req) async {
    try {
      await scraperManager.scrapeAll();
      return Response.ok({'status': 'success', 'message': 'Scraping started'});
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  });

  app.post('/api/scrape/<source>', (Request req) async {
    try {
      final source = req.params['source'];
      await scraperManager.scrapeSource(source!);
      return Response.ok({'status': 'success', 'message': 'Scraping started for $source'});
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  });

  app.get('/api/scrape/jobs', (Request req) async {
    try {
      final jobs = await scraperManager.getScrapingJobs();
      return Response.ok(jobs);
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  });

  app.get('/api/scrape/stats', (Request req) async {
    try {
      final stats = await scraperManager.getScrapingStats();
      return Response.ok(stats);
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  });

  // Product endpoints
  app.get('/api/products', (Request req) async {
    try {
      final conn = await DatabaseService.getConnection();
      final results = await conn.execute('''
        SELECT p.*, c.name as category_name
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        ORDER BY p.created_at DESC
        LIMIT 50
      ''');
      
      final products = results.map((row) => {
        'id': row[0],
        'title': row[1],
        'description': row[2],
        'price': row[3],
        'old_price': row[4],
        'discount': row[5],
        'image_url': row[6],
        'product_url': row[7],
        'brand': row[8],
        'category': row[10],
        'sku': row[9],
        'specifications': row[11],
        'stock': row[12],
        'rating': row[13],
        'review_count': row[14],
        'source': row[15],
        'source_id': row[16],
        'created_at': row[17],
        'updated_at': row[18],
      }).toList();
      
      return Response.ok(products);
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  });

  app.get('/api/products/<id>', (Request req) async {
    try {
      final id = req.params['id'];
      final conn = await DatabaseService.getConnection();
      final results = await conn.execute('''
        SELECT p.*, c.name as category_name
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.id = @id
      ''', substitutionValues: {'id': id});
      
      if (results.isEmpty) {
        return Response.notFound({'error': 'Product not found'});
      }
      
      final row = results.first;
      final product = {
        'id': row[0],
        'title': row[1],
        'description': row[2],
        'price': row[3],
        'old_price': row[4],
        'discount': row[5],
        'image_url': row[6],
        'product_url': row[7],
        'brand': row[8],
        'category': row[10],
        'sku': row[9],
        'specifications': row[11],
        'stock': row[12],
        'rating': row[13],
        'review_count': row[14],
        'source': row[15],
        'source_id': row[16],
        'created_at': row[17],
        'updated_at': row[18],
      };
      
      return Response.ok(product);
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  });

  // Search endpoint
  app.get('/api/search', (Request req) async {
    try {
      final query = req.url.queryParameters['query'] ?? '';
      final category = req.url.queryParameters['category'];
      final minPrice = int.tryParse(req.url.queryParameters['minPrice'] ?? '');
      final maxPrice = int.tryParse(req.url.queryParameters['maxPrice'] ?? '');
      
      final conn = await DatabaseService.getConnection();
      String sql = '''
        SELECT p.*, c.name as category_name
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE 1=1
      ''';
      
      final params = <String, dynamic>{};
      int paramIndex = 0;
      
      if (query.isNotEmpty) {
        sql += ' AND (p.title ILIKE @query OR p.description ILIKE @query OR p.brand ILIKE @query)';
        params['query'] = '%$query%';
      }
      
      if (category != null) {
        sql += ' AND c.name = @category';
        params['category'] = category;
      }
      
      if (minPrice != null) {
        sql += ' AND p.price >= @minPrice';
        params['minPrice'] = minPrice;
      }
      
      if (maxPrice != null) {
        sql += ' AND p.price <= @maxPrice';
        params['maxPrice'] = maxPrice;
      }
      
      sql += ' ORDER BY p.created_at DESC LIMIT 50';
      
      final results = await conn.execute(sql, substitutionValues: params);
      
      final products = results.map((row) => {
        'id': row[0],
        'title': row[1],
        'description': row[2],
        'price': row[3],
        'old_price': row[4],
        'discount': row[5],
        'image_url': row[6],
        'product_url': row[7],
        'brand': row[8],
        'category': row[10],
        'sku': row[9],
        'specifications': row[11],
        'stock': row[12],
        'rating': row[13],
        'review_count': row[14],
        'source': row[15],
        'source_id': row[16],
        'created_at': row[17],
        'updated_at': row[18],
      }).toList();
      
      return Response.ok(products);
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  });

  // Categories endpoint
  app.get('/api/categories', (Request req) async {
    try {
      final conn = await DatabaseService.getConnection();
      final results = await conn.execute('''
        SELECT * FROM categories
        ORDER BY name ASC
      ''');
      
      final categories = results.map((row) => {
        'id': row[0],
        'name': row[1],
        'description': row[2],
        'icon': row[3],
        'parent_id': row[4],
        'product_count': row[5],
        'created_at': row[6],
        'updated_at': row[7],
      }).toList();
      
      return Response.ok(categories);
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  });

  // Serve static files for admin panel
  final staticHandler = createStaticHandler('admin');
  app.mount('/admin', staticHandler);

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, '0.0.0.0', port);
  print('Server running on port ${server.port}');
  print('Admin panel available at /admin');
}
