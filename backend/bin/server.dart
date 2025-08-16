import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:logger/logger.dart';
import 'package:redis/redis.dart';

import '../lib/database.dart';
import '../lib/services/scraping_service.dart';
import '../lib/services/web3_service.dart';
import '../lib/services/ai_service.dart';
import '../lib/handlers/auth_handler.dart';
import '../lib/handlers/product_handler.dart';
import '../lib/handlers/scraping_handler.dart';
import '../lib/handlers/web3_handler.dart';

void main(List<String> args) async {
  // Load environment variables
  dotenv.load();
  
  // Initialize logger
  final logger = Logger();
  logger.i('Starting MyModus Backend Server...');
  
  try {
    // Initialize database
    final db = DatabaseService();
    await db.runMigrations();
    logger.i('Database initialized successfully');
    
    // Initialize Redis
    final redis = await RedisConnection.connect(
      dotenv.env['REDIS_URL'] ?? 'redis://localhost:6379',
    );
    logger.i('Redis connected successfully');
    
    // Initialize services
    final scrapingService = ScrapingService(db, redis);
    final web3Service = Web3Service(
      dotenv.env['ETHEREUM_RPC_URL'] ?? 'http://localhost:8545',
    );
    final aiService = AIService(
      apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
    );
    
    // Initialize Web3 contracts if addresses are provided
    final escrowAddress = dotenv.env['ESCROW_CONTRACT_ADDRESS'];
    final loyaltyTokenAddress = dotenv.env['LOYALTY_TOKEN_ADDRESS'];
    final nftContractAddress = dotenv.env['NFT_CONTRACT_ADDRESS'];
    
    if (escrowAddress != null && loyaltyTokenAddress != null && nftContractAddress != null) {
      await web3Service.initializeContracts(
        escrowAddress: escrowAddress,
        loyaltyTokenAddress: loyaltyTokenAddress,
        nftContractAddress: nftContractAddress,
      );
      logger.i('Web3 contracts initialized successfully');
    } else {
      logger.w('Web3 contract addresses not provided, Web3 features will be disabled');
    }
    
    // Initialize handlers
    final authHandler = AuthHandler(db);
    final productHandler = ProductHandler(db, aiService);
    final scrapingHandler = ScrapingHandler(scrapingService);
    final web3Handler = Web3Handler(web3Service);
    
    // Create router
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
    
    // API routes
    router.mount('/api/auth', authHandler.router);
    router.mount('/api/products', productHandler.router);
    router.mount('/api/scraping', scrapingHandler.router);
    router.mount('/api/web3', web3Handler.router);
    
    // Admin routes
    router.get('/admin/stats', (Request request) async {
      try {
        final scrapingStats = await scrapingService.getScrapingStats();
        final dbStats = await _getDatabaseStats(db);
        
        return Response.ok(
          jsonEncode({
            'scraping': scrapingStats,
            'database': dbStats,
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        logger.e('Error getting admin stats: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to get statistics'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });
    
    // Create pipeline with CORS and logging
    final pipeline = const Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(_loggingMiddleware(logger))
        .addHandler(router);
    
    // Start server
    final port = int.parse(dotenv.env['PORT'] ?? '8080');
    final server = await io.serve(
      pipeline,
      InternetAddress.anyIPv4,
      port,
    );
    
    logger.i('Server running on port ${server.port}');
    
    // Graceful shutdown
    ProcessSignal.sigint.watch().listen((_) async {
      logger.i('Shutting down server...');
      
      scrapingService.dispose();
      web3Service.dispose();
      aiService.dispose();
      await redis.close();
      await db.closeConnection();
      
      await server.close();
      exit(0);
    });
    
  } catch (e, stackTrace) {
    logger.e('Failed to start server: $e');
    logger.e('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Logging middleware
Middleware _loggingMiddleware(Logger logger) {
  return (Handler handler) {
    return (Request request) async {
      final startTime = DateTime.now();
      
      try {
        final response = await handler(request);
        
        final duration = DateTime.now().difference(startTime);
        logger.i('${request.method} ${request.url} - ${response.statusCode} - ${duration.inMilliseconds}ms');
        
        return response;
      } catch (e, stackTrace) {
        final duration = DateTime.now().difference(startTime);
        logger.e('${request.method} ${request.url} - ERROR - ${duration.inMilliseconds}ms');
        logger.e('Error: $e');
        logger.e('Stack trace: $stackTrace');
        
        return Response.internalServerError(
          body: jsonEncode({'error': 'Internal server error'}),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}

/// Get database statistics
Future<Map<String, dynamic>> _getDatabaseStats(DatabaseService db) async {
  try {
    final conn = await db.getConnection();
    
    final userCount = await conn.query('SELECT COUNT(*) FROM users');
    final productCount = await conn.query('SELECT COUNT(*) FROM products');
    final orderCount = await conn.query('SELECT COUNT(*) FROM orders');
    
    await conn.close();
    
    return {
      'users': userCount.first.first,
      'products': productCount.first.first,
      'orders': orderCount.first.first,
    };
  } catch (e) {
    return {'error': e.toString()};
  }
}
