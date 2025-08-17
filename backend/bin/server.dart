import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';

import '../lib/database.dart';
import '../lib/handlers/auth_handler.dart';
import '../lib/handlers/ai_handler.dart';
import '../lib/handlers/ai_analytics_handler.dart';
import '../lib/services/ai_service.dart';
import '../lib/services/ai_analytics_service.dart';
import '../lib/services/jwt_service.dart';

void main(List<String> args) async {
  // Инициализация логгера
  final logger = Logger();
  
  try {
    logger.i('🚀 Starting MyModus Backend Server...');
    
    // Загрузка переменных окружения
    final env = DotEnv()..load();
    final port = int.parse(env['PORT'] ?? '8080');
    
    // Инициализация базы данных
    logger.i('📊 Initializing database...');
    await DatabaseService.runMigrations();
    await DatabaseService.seedInitialData();
    logger.i('✅ Database initialized successfully');
    
    // Инициализация сервисов
    logger.i('🤖 Initializing AI services...');
    final aiService = AIService();
    final aiAnalyticsService = AIAnalyticsService();
    final jwtService = JWTService();
    
    // Инициализация handlers
    logger.i('🔧 Setting up API handlers...');
    final authHandler = AuthHandler(jwtService);
    final aiHandler = AIHandler(aiService);
    final aiAnalyticsHandler = AIAnalyticsHandler(aiAnalyticsService);
    
    // Создание основного роутера
    final app = Router();
    
    // API маршруты
    app.mount('/api/auth', authHandler.router);
    app.mount('/api/ai', aiHandler.router);
    app.mount('/api/ai-analytics', aiAnalyticsHandler.router);
    
    // Health check endpoint
    app.get('/health', (Request request) {
      return Response.ok(
        '{"status": "healthy", "service": "MyModus Backend", "timestamp": "${DateTime.now().toIso8601String()}"}',
        headers: {'content-type': 'application/json'},
      );
    });
    
    // API info endpoint
    app.get('/api', (Request request) {
      return Response.ok(
        '{"service": "MyModus Backend API", "version": "1.0.0", "endpoints": {'
        '"auth": "/api/auth", '
        '"ai": "/api/ai", '
        '"ai-analytics": "/api/ai-analytics"'
        '}, "timestamp": "${DateTime.now().toIso8601String()}"}',
        headers: {'content-type': 'application/json'},
      );
    });
    
    // API documentation endpoint
    app.get('/api/docs', (Request request) {
      return Response.ok(
        '{"title": "MyModus Backend API Documentation", '
        '"version": "1.0.0", '
        '"description": "AI-powered fashion social commerce platform API", '
        '"endpoints": {'
        '"Authentication": {'
        '"POST /api/auth/login": "User login", '
        '"POST /api/auth/register": "User registration", '
        '"POST /api/auth/refresh": "Refresh JWT token"'
        '}, '
        '"AI Services": {'
        '"GET /api/ai/recommendations/{userId}": "Get AI recommendations for user", '
        '"POST /api/ai/generate-description": "Generate product description with AI", '
        '"GET /api/ai/preferences/{userId}": "Analyze user preferences", '
        '"POST /api/ai/generate-hashtags": "Generate hashtags for posts", '
        '"POST /api/ai/moderate-content": "AI content moderation", '
        '"POST /api/ai/personalized-offers": "Generate personalized offers", '
        '"GET /api/ai/trends": "Get AI fashion trends"'
        '}, '
        '"AI Analytics": {'
        '"GET /api/ai-analytics/trends": "Get fashion trends analysis", '
        '"GET /api/ai-analytics/trends/{category}": "Get trends by category", '
        '"GET /api/ai-analytics/behavior/{userId}": "Analyze user behavior", '
        '"GET /api/ai-analytics/effectiveness": "Analyze recommendation effectiveness", '
        '"POST /api/ai-analytics/content": "Analyze content sentiment", '
        '"GET /api/ai-analytics/demand": "Get demand predictions", '
        '"GET /api/ai-analytics/competitors": "Analyze competitors", '
        '"GET /api/ai-analytics/stats": "Get AI performance statistics"'
        '}'
        '}, '
        '"timestamp": "${DateTime.now().toIso8601String()}"}',
        headers: {'content-type': 'application/json'},
      );
    });
    
    // 404 handler для несуществующих маршрутов
    app.all('/<ignored|.*>', (Request request) {
      return Response.notFound(
        '{"error": "Endpoint not found", "path": "${request.url.path}", "available_endpoints": ["/api", "/api/docs", "/health"]}',
        headers: {'content-type': 'application/json'},
      );
    });
    
    // Настройка CORS
    final handler = const Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler(app);
    
    // Запуск сервера
    logger.i('🌐 Starting server on port $port...');
    final server = await io.serve(handler, InternetAddress.anyIPv4, port);
    
    logger.i('🎉 MyModus Backend Server is running!');
    logger.i('📍 Server URL: http://localhost:$port');
    logger.i('📚 API Documentation: http://localhost:$port/api/docs');
    logger.i('💚 Health Check: http://localhost:$port/health');
    logger.i('🔐 Auth Endpoints: http://localhost:$port/api/auth');
    logger.i('🤖 AI Endpoints: http://localhost:$port/api/ai');
    logger.i('📊 AI Analytics: http://localhost:$port/api/ai-analytics');
    
    // Graceful shutdown
    ProcessSignal.sigint.watch().listen((_) async {
      logger.i('🛑 Shutting down server...');
      await server.close();
      await DatabaseService.close();
      logger.i('✅ Server shutdown complete');
      exit(0);
    });
    
    ProcessSignal.sigterm.watch().listen((_) async {
      logger.i('🛑 Shutting down server...');
      await server.close();
      await DatabaseService.close();
      logger.i('✅ Server shutdown complete');
      exit(0);
    });
    
  } catch (e, stackTrace) {
    logger.e('❌ Failed to start server: $e');
    logger.e('Stack trace: $stackTrace');
    exit(1);
  }
}

// Middleware для логирования запросов
Response logRequests(Response response) {
  final logger = Logger();
  logger.i('${response.statusCode} ${response.requestedUri?.path ?? 'unknown'}');
  return response;
}
