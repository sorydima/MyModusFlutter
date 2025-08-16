import 'dart:async';
import 'dart:io';
import 'package:redis/redis.dart';
import '../scrapers/base_scraper.dart';
import '../scrapers/ozon_scraper.dart';
import '../scrapers/wildberries_scraper.dart';
import '../scrapers/lamoda_scraper.dart';
import '../database.dart';
import '../models.dart';

class ScrapingService {
  final DatabaseService _db;
  final RedisConnection _redis;
  Timer? _scheduler;
  bool _isRunning = false;
  
  // Cache keys
  static const String _cachePrefix = 'scraping:';
  static const String _lastScrapeKey = 'last_scrape';
  static const String _productsCacheKey = 'products_cache';
  static const String _categoriesCacheKey = 'categories_cache';
  
  ScrapingService(this._db, this._redis);

  /// Запуск планировщика парсинга
  Future<void> startScheduler() async {
    if (_scheduler != null) return;
    
    // Запускаем парсинг каждые 6 часов
    _scheduler = Timer.periodic(Duration(hours: 6), (timer) {
      _runScheduledScraping();
    });
    
    print('Scraping scheduler started');
  }

  /// Остановка планировщика
  Future<void> stopScheduler() async {
    _scheduler?.cancel();
    _scheduler = null;
    _isRunning = false;
    print('Scraping scheduler stopped');
  }

  /// Запуск запланированного парсинга
  Future<void> _runScheduledScraping() async {
    if (_isRunning) {
      print('Scraping already in progress, skipping...');
      return;
    }
    
    await runFullScraping();
  }

  /// Полный парсинг всех маркетплейсов
  Future<void> runFullScraping() async {
    if (_isRunning) {
      throw Exception('Scraping already in progress');
    }
    
    _isRunning = true;
    final startTime = DateTime.now();
    
    try {
      print('Starting full scraping at ${startTime.toIso8601String()}');
      
      // Создаем список всех парсеров
      final scrapers = [
        OzonScraper(db: _db),
        WildberriesScraper(db: _db),
        LamodaScraper(db: _db),
      ];
      
      // Запускаем парсинг параллельно для каждого маркетплейса
      final futures = scrapers.map((scraper) => scraper.scrape());
      final results = await Future.wait(futures);
      
      // Подсчитываем общее количество товаров
      int totalProducts = 0;
      for (final result in results) {
        totalProducts += result.length;
      }
      
      // Обновляем кэш
      await _updateCache();
      
      // Сохраняем время последнего парсинга
      await _redis.set('$_cachePrefix$_lastScrapeKey', startTime.toIso8601String());
      
      print('Full scraping completed. Total products: $totalProducts');
      
    } catch (e, stackTrace) {
      print('Error during full scraping: $e');
      print(stackTrace);
    } finally {
      _isRunning = false;
    }
  }

  /// Парсинг конкретного маркетплейса
  Future<List<Product>> scrapeMarketplace(String marketplace) async {
    if (_isRunning) {
      throw Exception('Scraping already in progress');
    }
    
    _isRunning = true;
    
    try {
      BaseScraper scraper;
      
      switch (marketplace.toLowerCase()) {
        case 'ozon':
          scraper = OzonScraper(db: _db);
          break;
        case 'wildberries':
          scraper = WildberriesScraper(db: _db);
          break;
        case 'lamoda':
          scraper = LamodaScraper(db: _db);
          break;
        default:
          throw Exception('Unknown marketplace: $marketplace');
      }
      
      final products = await scraper.scrape();
      
      // Обновляем кэш для конкретного маркетплейса
      await _updateMarketplaceCache(marketplace, products);
      
      return products;
      
    } finally {
      _isRunning = false;
    }
  }

  /// Получение товаров с кэшированием
  Future<List<Product>> getProducts({
    String? marketplace,
    String? category,
    String? brand,
    int? minPrice,
    int? maxPrice,
    int limit = 50,
    int offset = 0,
    bool useCache = true,
  }) async {
    if (useCache) {
      final cached = await _getCachedProducts(
        marketplace: marketplace,
        category: category,
        brand: brand,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      
      if (cached.isNotEmpty) {
        return cached.take(limit).skip(offset).toList();
      }
    }
    
    // Если кэш пуст или не используется, получаем из БД
    return await _getProductsFromDatabase(
      marketplace: marketplace,
      category: category,
      brand: brand,
      minPrice: minPrice,
      maxPrice: maxPrice,
      limit: limit,
      offset: offset,
    );
  }

  /// Получение товаров из кэша
  Future<List<Product>> _getCachedProducts({
    String? marketplace,
    String? category,
    String? brand,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      final cacheKey = _buildCacheKey(
        marketplace: marketplace,
        category: category,
        brand: brand,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      
      final cached = await _redis.get('$_cachePrefix$cacheKey');
      if (cached != null) {
        // Здесь нужно десериализовать JSON в List<Product>
        // Для простоты возвращаем пустой список
        return [];
      }
    } catch (e) {
      print('Error getting cached products: $e');
    }
    
    return [];
  }

  /// Получение товаров из базы данных
  Future<List<Product>> _getProductsFromDatabase({
    String? marketplace,
    String? category,
    String? brand,
    int? minPrice,
    int? maxPrice,
    int limit = 50,
    int offset = 0,
  }) async {
    final conn = await _db.getConnection();
    
    try {
      String query = '''
        SELECT * FROM products 
        WHERE is_active = true
      ''';
      
      final params = <String, dynamic>{};
      
      if (marketplace != null) {
        query += ' AND source = @marketplace';
        params['marketplace'] = marketplace;
      }
      
      if (category != null) {
        query += ' AND category_id = (SELECT id FROM categories WHERE name = @category)';
        params['category'] = category;
      }
      
      if (brand != null) {
        query += ' AND brand ILIKE @brand';
        params['brand'] = '%$brand%';
      }
      
      if (minPrice != null) {
        query += ' AND price >= @minPrice';
        params['minPrice'] = minPrice;
      }
      
      if (maxPrice != null) {
        query += ' AND price <= @maxPrice';
        params['maxPrice'] = maxPrice;
      }
      
      query += ' ORDER BY created_at DESC LIMIT @limit OFFSET @offset';
      params['limit'] = limit;
      params['offset'] = offset;
      
      final result = await conn.execute(query, substitutionValues: params);
      
      return result.map((row) => Product.fromRow(row)).toList();
      
    } finally {
      await conn.close();
    }
  }

  /// Обновление кэша
  Future<void> _updateCache() async {
    try {
      // Получаем все активные товары
      final products = await _getProductsFromDatabase(limit: 1000);
      
      // Кэшируем по категориям
      final categories = <String, List<Product>>{};
      for (final product in products) {
        final category = product.category ?? 'other';
        categories.putIfAbsent(category, () => []).add(product);
      }
      
      // Сохраняем в кэш
      for (final entry in categories.entries) {
        final cacheKey = '$_cachePrefix${_categoriesCacheKey}:${entry.key}';
        // Здесь нужно сериализовать в JSON
        // await _redis.set(cacheKey, jsonEncode(entry.value));
      }
      
      // Кэшируем общий список товаров
      // await _redis.set('$_cachePrefix$_productsCacheKey', jsonEncode(products));
      
    } catch (e) {
      print('Error updating cache: $e');
    }
  }

  /// Обновление кэша для конкретного маркетплейса
  Future<void> _updateMarketplaceCache(String marketplace, List<Product> products) async {
    try {
      final cacheKey = '$_cachePrefix$_productsCacheKey:$marketplace';
      // await _redis.set(cacheKey, jsonEncode(products));
    } catch (e) {
      print('Error updating marketplace cache: $e');
    }
  }

  /// Построение ключа кэша
  String _buildCacheKey({
    String? marketplace,
    String? category,
    String? brand,
    int? minPrice,
    int? maxPrice,
  }) {
    final parts = <String>[];
    
    if (marketplace != null) parts.add('mp:$marketplace');
    if (category != null) parts.add('cat:$category');
    if (brand != null) parts.add('brand:$brand');
    if (minPrice != null) parts.add('min:$minPrice');
    if (maxPrice != null) parts.add('max:$maxPrice');
    
    return parts.isEmpty ? 'all' : parts.join(':');
  }

  /// Получение статистики парсинга
  Future<Map<String, dynamic>> getScrapingStats() async {
    try {
      final conn = await _db.getConnection();
      
      // Статистика по маркетплейсам
      final marketplaceStats = await conn.execute('''
        SELECT 
          source,
          COUNT(*) as total_products,
          COUNT(CASE WHEN is_active = true THEN 1 END) as active_products,
          AVG(price) as avg_price,
          MAX(price) as max_price,
          MIN(price) as min_price
        FROM products 
        GROUP BY source
      ''');
      
      // Последние задания парсинга
      final recentJobs = await conn.execute('''
        SELECT 
          source,
          status,
          products_scraped,
          products_updated,
          started_at,
          completed_at
        FROM scraping_jobs 
        ORDER BY created_at DESC 
        LIMIT 10
      ''');
      
      // Время последнего парсинга
      final lastScrape = await _redis.get('$_cachePrefix$_lastScrapeKey');
      
      await conn.close();
      
      return {
        'marketplace_stats': marketplaceStats,
        'recent_jobs': recentJobs,
        'last_scrape': lastScrape,
        'is_running': _isRunning,
      };
      
    } catch (e) {
      print('Error getting scraping stats: $e');
      return {};
    }
  }

  /// Очистка старых данных
  Future<void> cleanupOldData() async {
    try {
      final conn = await _db.getConnection();
      
      // Удаляем товары старше 30 дней
      await conn.execute('''
        DELETE FROM products 
        WHERE updated_at < NOW() - INTERVAL '30 days'
        AND is_active = false
      ''');
      
      // Удаляем старые задания парсинга
      await conn.execute('''
        DELETE FROM scraping_jobs 
        WHERE created_at < NOW() - INTERVAL '7 days'
        AND status IN ('completed', 'failed')
      ''');
      
      // Удаляем старую историю цен
      await conn.execute('''
        DELETE FROM price_history 
        WHERE recorded_at < NOW() - INTERVAL '90 days'
      ''');
      
      await conn.close();
      
      print('Old data cleanup completed');
      
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }
}
