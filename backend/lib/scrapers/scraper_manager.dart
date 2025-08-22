import 'dart:async';
import 'dart:io';
import 'package:botasaurus/botasaurus.dart';
import 'wildberries_scraper.dart';
import 'ozon_scraper.dart';
import 'lamoda_scraper.dart';
import 'avito_scraper.dart';
import '../database.dart';
import '../models.dart';

class ScraperManager {
  final DatabaseService db;
  final Map<String, BaseScraper> _scrapers = {};
  
  ScraperManager(this.db) {
    _scrapers['wildberries'] = WildberriesScraper(db: db);
    _scrapers['ozon'] = OzonScraper(db: db);
    _scrapers['lamoda'] = LamodaScraper(db: db);
    _scrapers['avito'] = AvitoScraper(db: db);
  }

  Future<void> scrapeAll() async {
    print('Starting scraping for all sources...');
    
    // Run scrapers in parallel
    final futures = _scrapers.values.map((scraper) => scraper.scrape());
    await Future.wait(futures);
    
    print('All scraping completed');
  }

  Future<void> scrapeSource(String source) async {
    final scraper = _scrapers[source];
    if (scraper != null) {
      print('Starting scraping for $source...');
      await scraper.scrape();
      print('Scraping completed for $source');
    } else {
      print('Unknown source: $source');
    }
  }

  Future<List<ScrapingJob>> getScrapingJobs() async {
    final conn = await db.getConnection();
    final results = await conn.execute('''
      SELECT id, source, status, products_scraped, products_updated, error, started_at, completed_at
      FROM scraping_jobs 
      ORDER BY created_at DESC 
      LIMIT 50
    ''');
    
    return results.map((row) => ScrapingJob(
      id: row[0],
      source: row[1],
      status: row[2],
      productsScraped: row[3],
      productsUpdated: row[4],
      error: row[5],
      startedAt: row[6],
      completedAt: row[7],
    )).toList();
  }

  Future<void> runScheduledScraping() async {
    // This would be called by a cron job or scheduled task
    print('Running scheduled scraping...');
    
    try {
      await scrapeAll();
      print('Scheduled scraping completed successfully');
    } catch (e) {
      print('Error in scheduled scraping: $e');
    }
  }

  Future<void> cleanupOldProducts() async {
    final conn = await db.getConnection();
    
    // Delete products older than 30 days
    final cutoffDate = DateTime.now().subtract(Duration(days: 30));
    
    await conn.execute('''
      DELETE FROM products 
      WHERE created_at < @cutoff_date
      AND source NOT IN ('wildberries', 'ozon', 'lamoda')
    ''', substitutionValues: {
      'cutoff_date': cutoffDate,
    });
    
    print('Cleaned up old products');
  }

  Future<void> updateProductStock() async {
    final conn = await db.getConnection();
    
    // Update stock for products from major sources
    await conn.execute('''
      UPDATE products 
      SET stock = CASE 
        WHEN source = 'wildberries' THEN 10
        WHEN source = 'ozon' THEN 15
        WHEN source = 'lamoda' THEN 8
        ELSE stock
      END
      WHERE source IN ('wildberries', 'ozon', 'lamoda')
      AND stock = 0
    ''');
    
    print('Updated product stock');
  }

  Future<Map<String, dynamic>> getScrapingStats() async {
    final conn = await db.getConnection();
    
    // Get total products by source
    final sourceStats = await conn.execute('''
      SELECT source, COUNT(*) as count 
      FROM products 
      GROUP BY source 
      ORDER BY count DESC
    ''');
    
    // Get total products
    final totalProducts = await conn.execute('SELECT COUNT(*) FROM products');
    
    // Get recent scraping jobs
    final recentJobs = await conn.execute('''
      SELECT source, status, products_scraped 
      FROM scraping_jobs 
      WHERE created_at > NOW() - INTERVAL '24 hours'
      ORDER BY created_at DESC
    ''');
    
    return {
      'totalProducts': totalProducts.first[0],
      'sourceStats': sourceStats.map((row) => {
        'source': row[0],
        'count': row[1],
      }).toList(),
      'recentJobs': recentJobs.map((row) => {
        'source': row[0],
        'status': row[1],
        'productsScraped': row[2],
      }).toList(),
    };
  }
}