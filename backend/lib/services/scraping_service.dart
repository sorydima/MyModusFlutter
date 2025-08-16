import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:redis/redis.dart';
import 'package:logger/logger.dart';
import '../database.dart';
import '../scrapers/base_scraper.dart';
import '../scrapers/lamoda_scraper.dart';
import '../scrapers/ozon_scraper.dart';
import '../scrapers/wildberries_scraper.dart';
import '../models.dart';

class ScrapingService {
  final DatabaseService _db;
  final RedisConnection _redis;
  final Logger _logger = Logger();
  
  // Scrapers
  late final LamodaScraper _lamodaScraper;
  late final OzonScraper _ozonScraper;
  late final WildberriesScraper _wildberriesScraper;
  
  // Scheduling
  Timer? _scheduledScrapingTimer;
  static const Duration _scrapingInterval = Duration(hours: 6);
  
  ScrapingService(this._db, this._redis) {
    _initializeScrapers();
    _startScheduledScraping();
  }
  
  void _initializeScrapers() {
    _lamodaScraper = LamodaScraper(db: _db);
    _ozonScraper = OzonScraper(db: _db);
    _wildberriesScraper = WildberriesScraper(db: _db);
  }
  
  /// Start scheduled scraping every 6 hours
  void _startScheduledScraping() {
    _scheduledScrapingTimer = Timer.periodic(_scrapingInterval, (timer) {
      _runScheduledScraping();
    });
    _logger.i('Scheduled scraping started with interval: $_scrapingInterval');
  }
  
  /// Run scraping for all platforms
  Future<void> _runScheduledScraping() async {
    try {
      _logger.i('Starting scheduled scraping...');
      
      await Future.wait([
        _scrapePlatform('lamoda'),
        _scrapePlatform('ozon'),
        _scrapePlatform('wildberries'),
      ]);
      
      _logger.i('Scheduled scraping completed successfully');
    } catch (e) {
      _logger.e('Error in scheduled scraping: $e');
    }
  }
  
  /// Scrape specific platform
  Future<void> _scrapePlatform(String platform) async {
    try {
      _logger.i('Starting scraping for platform: $platform');
      
      // Check cache to avoid unnecessary scraping
      final cacheKey = 'scraping:${platform}:last_run';
      final lastRun = await _redis.get(cacheKey);
      
      if (lastRun != null) {
        final lastRunTime = DateTime.parse(lastRun);
        if (DateTime.now().difference(lastRunTime) < _scrapingInterval) {
          _logger.i('Skipping $platform - recently scraped');
          return;
        }
      }
      
      // Run scraper
      List<Product> products;
      switch (platform) {
        case 'lamoda':
          products = await _lamodaScraper.scrape();
          break;
        case 'ozon':
          products = await _ozonScraper.scrape();
          break;
        case 'wildberries':
          products = await _wildberriesScraper.scrape();
          break;
        default:
          throw ArgumentError('Unknown platform: $platform');
      }
      
      // Update cache
      await _redis.set(cacheKey, DateTime.now().toIso8601String());
      await _redis.set('scraping:${platform}:product_count', products.length.toString());
      await _cacheProducts(platform, products); // Cache products themselves

      _logger.i('Successfully scraped ${products.length} products from $platform');
      
    } catch (e) {
      _logger.e('Error scraping $platform: $e');
      // Update cache with error timestamp
      await _redis.set('scraping:${platform}:last_error', DateTime.now().toIso8601String());
      await _redis.set('scraping:${platform}:error_message', e.toString());
    }
  }
  
  /// Manual scraping trigger
  Future<Map<String, dynamic>> triggerScraping({List<String>? platforms}) async {
    final selectedPlatforms = platforms ?? ['lamoda', 'ozon', 'wildberries'];
    final results = <String, dynamic>{};
    
    for (final platform in selectedPlatforms) {
      try {
        await _scrapePlatform(platform);
        results[platform] = {'status': 'success'};
      } catch (e) {
        results[platform] = {'status': 'error', 'message': e.toString()};
      }
    }
    
    return results;
  }
  
  /// Get scraping statistics
  Future<Map<String, dynamic>> getScrapingStats() async {
    final stats = <String, dynamic>{};
    
    for (final platform in ['lamoda', 'ozon', 'wildberries']) {
      try {
        final lastRun = await _redis.get('scraping:${platform}:last_run');
        final productCount = await _redis.get('scraping:${platform}:product_count');
        final lastError = await _redis.get('scraping:${platform}:last_error');
        final errorMessage = await _redis.get('scraping:${platform}:error_message');
        
        stats[platform] = {
          'last_run': lastRun,
          'product_count': productCount != null ? int.tryParse(productCount) : 0,
          'last_error': lastError,
          'error_message': errorMessage,
          'status': lastError != null ? 'error' : 'healthy',
        };
      } catch (e) {
        stats[platform] = {'status': 'unknown', 'error': e.toString()};
      }
    }
    
    return stats;
  }
  
  /// Get cached products for platform
  Future<List<Product>> getCachedProducts(String platform, {int limit = 50}) async {
    try {
      final cacheKey = 'products:${platform}:latest';
      final cachedData = await _redis.get(cacheKey);
      
      if (cachedData != null) {
        // Parse cached JSON data
        final List<dynamic> jsonList = jsonDecode(cachedData);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      }
      
      // Fallback to database
      return await _getProductsFromDatabase(platform, limit: limit);
    } catch (e) {
      _logger.e('Error getting cached products for $platform: $e');
      return await _getProductsFromDatabase(platform, limit: limit);
    }
  }
  
  /// Get products from database
  Future<List<Product>> _getProductsFromDatabase(String platform, {int limit = 50}) async {
    final conn = await _db.getConnection();
    try {
      final results = await conn.query(
        'SELECT * FROM products WHERE source = @platform ORDER BY updated_at DESC LIMIT @limit',
        substitutionValues: {
          'platform': platform,
          'limit': limit,
        },
      );
      
      return results.map((row) => Product.fromRow(row)).toList();
    } finally {
      await conn.close();
    }
  }
  
  /// Cache products for platform
  Future<void> _cacheProducts(String platform, List<Product> products) async {
    try {
      final cacheKey = 'products:${platform}:latest';
      final jsonData = jsonEncode(products.map((p) => p.toJson()).toList());
      
      // Cache for 1 hour
      await _redis.setex(cacheKey, 3600, jsonData);
    } catch (e) {
      _logger.e('Error caching products for $platform: $e');
    }
  }
  
  /// Cleanup resources
  void dispose() {
    _scheduledScrapingTimer?.cancel();
    _redis.close();
  }
}
