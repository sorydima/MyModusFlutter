import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/scraping_service.dart';

class ScrapingHandler {
  final ScrapingService _scrapingService;
  
  ScrapingHandler(this._scrapingService);
  
  Router get router {
    final router = Router();
    
    // Получение статистики скрапинга
    router.get('/stats', _getStats);
    
    // Запуск скрапинга
    router.post('/trigger', _triggerScraping);
    
    // Получение кэшированных товаров
    router.get('/products/<platform>', _getCachedProducts);
    
    return router;
  }
  
  /// Получение статистики скрапинга
  Future<Response> _getStats(Request request) async {
    try {
      final stats = await _scrapingService.getScrapingStats();
      
      return Response.ok(
        jsonEncode({
          'stats': stats,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get scraping stats: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Запуск скрапинга
  Future<Response> _triggerScraping(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final platforms = data['platforms'] as List<dynamic>?;
      final platformList = platforms?.cast<String>();
      
      final results = await _scrapingService.triggerScraping(
        platforms: platformList,
      );
      
      return Response.ok(
        jsonEncode({
          'message': 'Scraping triggered successfully',
          'results': results,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to trigger scraping: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Получение кэшированных товаров для платформы
  Future<Response> _getCachedProducts(Request request, String platform) async {
    try {
      final queryParams = request.url.queryParameters;
      final limit = int.tryParse(queryParams['limit'] ?? '50') ?? 50;
      
      final products = await _scrapingService.getCachedProducts(
        platform,
        limit: limit,
      );
      
      return Response.ok(
        jsonEncode({
          'platform': platform,
          'products': products.map((p) => p.toJson()).toList(),
          'total': products.length,
          'limit': limit,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get cached products: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
