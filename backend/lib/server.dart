import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:dotenv/dotenv.dart';
import 'package:redis/redis.dart';
import 'database.dart';
import 'services/scraping_service.dart';
import 'services/web3_service.dart';
import 'services/ai_service.dart';
import 'services/ai_recommendations_service.dart';
import 'services/ai_content_generation_service.dart';
import 'services/ai_style_analysis_service.dart';
import 'services/ipfs_service.dart';
import 'handlers/auth_handler.dart';
import 'handlers/product_handler.dart';
import 'handlers/social_handler.dart';
import 'handlers/web3_handler.dart';
import 'handlers/ai_handler.dart';
import 'handlers/ai_recommendations_handler.dart';
import 'handlers/ipfs_handler.dart';
import 'services/auth_service.dart';
import 'services/jwt_service.dart';

class MyModusServer {
  late final HttpServer _server;
  late final DatabaseService _database;
  late final RedisConnection _redis;
  late final ScrapingService _scrapingService;
  late final Web3Service _web3Service;
  late final AIService _aiService;
  late final AIRecommendationsService _aiRecommendationsService;
  late final AIContentGenerationService _aiContentGenerationService;
  late final AIStyleAnalysisService _aiStyleAnalysisService;
  late final IPFSService _ipfsService;
  late final JWTService _jwtService;
  late final AuthService _authService;
  
  // Handlers
  late final AuthHandler _authHandler;
  late final ProductHandler _productHandler;
  late final SocialHandler _socialHandler;
  late final Web3Handler _web3Handler;
  late final AIHandler _aiHandler;
  late final AIRecommendationsHandler _aiRecommendationsHandler;
  late final IPFSHandler _ipfsHandler;
  
  // Configuration
  static const int _port = 8080;
  static const String _host = '0.0.0.0';
  
  MyModusServer() {
    _initializeServices();
  }

  /// Инициализация всех сервисов
  Future<void> _initializeServices() async {
    try {
      // Загружаем переменные окружения
      load();
      
      // Инициализируем базу данных
      _database = DatabaseService();
      await _database.initialize();
      
      // Инициализируем Redis
      _redis = await RedisConnection.connect('redis://localhost:6379');
      
      // Инициализируем сервисы
      _jwtService = JWTService();
      _authService = AuthService(_database, _jwtService);
      _scrapingService = ScrapingService(_database, _redis);
      _web3Service = Web3Service(_database);
      _aiService = AIService(_database, _redis);
      _aiRecommendationsService = AIRecommendationsService();
      _aiContentGenerationService = AIContentGenerationService();
      _aiStyleAnalysisService = AIStyleAnalysisService();
      
      // Инициализируем IPFS сервис
      _ipfsService = IPFSService(
        ipfsNodeUrl: env['IPFS_NODE_URL'] ?? 'http://localhost:5001',
        ipfsGatewayUrl: env['IPFS_GATEWAY_URL'] ?? 'http://localhost:8080/ipfs',
      );
      
      // Инициализируем обработчики
      _authHandler = AuthHandler(_authService, _jwtService);
      _productHandler = ProductHandler(_scrapingService, _database);
      _socialHandler = SocialHandler(_database);
      _web3Handler = Web3Handler(_web3Service, _database);
      _aiHandler = AIHandler(_aiService, _database);
      _aiRecommendationsHandler = AIRecommendationsHandler();
      _ipfsHandler = IPFSHandler(ipfsService: _ipfsService);
      
      print('All services initialized successfully');
      
    } catch (e) {
      print('Error initializing services: $e');
      rethrow;
    }
  }

  /// Создание роутера с API эндпоинтами
  Router _createRouter() {
    final router = Router();
    
    // Health check
    router.get('/health', (Request request) {
      return Response.ok(
        jsonEncode({
          'status': 'healthy',
          'timestamp': DateTime.now().toIso8601String(),
          'version': '1.0.0',
        }),
        headers: {'content-type': 'application/json'},
      );
    });
    
    // API v1
    final apiV1 = Router();
    
    // Auth endpoints
    apiV1.mount('/auth', _authHandler.router);
    
    // Product endpoints
    apiV1.mount('/products', _productHandler.router);
    
    // Scraping endpoints
    apiV1.post('/scraping/start', (request) => _scrapingService.startScheduler());
    apiV1.get('/scraping/status', (request) => _scrapingService.getScrapingStats());
    apiV1.get('/scraping/stats', (request) => _scrapingService.getScrapingStats());
    
    // Social endpoints
    apiV1.mount('/social', _socialHandler.router);
    
    // Web3 endpoints
    apiV1.mount('/web3', _web3Handler.router);
    
    // AI endpoints
    apiV1.mount('/ai', _aiHandler.router);
    
    // AI Recommendations endpoints
    apiV1.mount('/ai/recommendations', _aiRecommendationsHandler.router);
    
    // IPFS endpoints
    apiV1.mount('/ipfs', _ipfsHandler.router);
    
    // Admin endpoints
    apiV1.get('/admin/stats', (request) => _getAdminStats(request));
    apiV1.post('/admin/scraping/cleanup', (request) => _cleanupOldData(request));
    apiV1.post('/admin/cache/clear', (request) => _clearCache(request));
    
    // Mount API v1
    router.mount('/api/v1', apiV1);
    
    // Static files (for web interface)
    final staticHandler = createStaticHandler(
      'web',
      defaultDocument: 'index.html',
    );
    router.mount('/web', staticHandler);
    
    // Catch-all for SPA routing
    router.get('/<path|.*>', (Request request) {
      return staticHandler(request.change(path: 'index.html'));
    });
    
    return router;
  }

  /// Middleware для CORS и логирования
  Pipeline _createPipeline() {
    return const Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(_loggingMiddleware)
        .addMiddleware(_errorHandlingMiddleware);
  }

  /// Middleware для логирования запросов
  Response _loggingMiddleware(Request request) {
    final startTime = DateTime.now();
    
    return request.response.then((response) {
      final duration = DateTime.now().difference(startTime);
      print('${request.method} ${request.url.path} - ${response.statusCode} - ${duration.inMilliseconds}ms');
      return response;
    });
  }

  /// Middleware для обработки ошибок
  Response _errorHandlingMiddleware(Request request) {
    try {
      return request.response;
    } catch (e, stackTrace) {
      print('Error handling request: $e');
      print(stackTrace);
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение административной статистики
  Future<Response> _getAdminStats(Request request) async {
    try {
      // TODO: Проверяем права администратора
      // final token = request.headers['authorization']?.replaceFirst('Bearer ', '');
      // if (token == null) {
      //   return Response(401, body: 'Unauthorized');
      // }
      
      // Получаем статистику по всем сервисам
      final scrapingStats = await _scrapingService.getScrapingStats();
      final web3Stats = await _web3Service.getWeb3Stats();
      
      final stats = {
        'scraping': scrapingStats,
        'web3': web3Stats,
        'database': await _getDatabaseStats(),
        'redis': await _getRedisStats(),
        'system': {
          'uptime': 0, // TODO: Реализовать подсчет uptime
          'memory_usage': 0, // TODO: Реализовать подсчет памяти
          'timestamp': DateTime.now().toIso8601String(),
        },
      };
      
      return Response.ok(
        jsonEncode(stats),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Очистка старых данных
  Future<Response> _cleanupOldData(Request request) async {
    try {
      await _scrapingService.cleanupOldData();
      
      return Response.ok(
        jsonEncode({'message': 'Cleanup completed successfully'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Очистка кэша
  Future<Response> _clearCache(Request request) async {
    try {
      // Очистка кэша Redis
      // await _redis.flushdb();
      
      return Response.ok(
        jsonEncode({'message': 'Cache cleared successfully'}),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение статистики базы данных
  Future<Map<String, dynamic>> _getDatabaseStats() async {
    try {
      // Количество записей в основных таблицах
      final userCount = await _database.query('SELECT COUNT(*) as count FROM users');
      final productCount = await _database.query('SELECT COUNT(*) as count FROM products');
      final postCount = await _database.query('SELECT COUNT(*) as count FROM posts');
      final nftCount = await _database.query('SELECT COUNT(*) as count FROM nfts');
      
      return {
        'users': userCount.first['count'],
        'products': productCount.first['count'],
        'posts': postCount.first['count'],
        'nfts': nftCount.first['count'],
      };
      
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Получение статистики Redis
  Future<Map<String, dynamic>> _getRedisStats() async {
    try {
      // Простая статистика Redis
      return {
        'status': 'connected',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Запуск сервера
  Future<void> start() async {
    try {
      final router = _createRouter();
      final pipeline = _createPipeline();
      final handler = pipeline.addHandler(router);
      
      _server = await io.serve(handler, _host, _port);
      
      print('MyModus server started on http://$_host:$_port');
      print('API available at http://$_host:$_port/api/v1');
      print('Web interface available at http://$_host:$_port/web');
      
      // Запускаем планировщик парсинга
      await _scrapingService.startScheduler();
      
      // Обработка сигналов завершения
      ProcessSignal.sigint.watch().listen((signal) async {
        print('\nShutting down server...');
        await stop();
        exit(0);
      });
      
    } catch (e) {
      print('Error starting server: $e');
      rethrow;
    }
  }

  /// Остановка сервера
  Future<void> stop() async {
    try {
      // Останавливаем планировщик парсинга
      await _scrapingService.stopScheduler();
      
      // Закрываем соединения
      await _redis.close();
      await _web3Service.dispose();
      
      // Останавливаем сервер
      await _server.close();
      
      print('Server stopped successfully');
      
    } catch (e) {
      print('Error stopping server: $e');
    }
  }
}

/// Точка входа
void main(List<String> args) async {
  try {
    final server = MyModusServer();
    await server.start();
  } catch (e) {
    print('Failed to start server: $e');
    exit(1);
  }
}
