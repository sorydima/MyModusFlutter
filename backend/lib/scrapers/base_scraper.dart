import 'dart:async';
import 'dart:io';
import 'package:botasaurus/botasaurus.dart';
import 'package:botasaurus/src/utils.dart';
import 'package:webdriver/selenium.dart' as selenium;
import 'package:webdriver/io.dart' as webdriver_io;
import 'package:html/parser.dart' as parser;
import 'package:uuid/uuid.dart';
import '../models.dart';
import '../database.dart';

abstract class BaseScraper {
  final String source;
  final String baseUrl;
  final DatabaseService db;
  
  BaseScraper({
    required this.source,
    required this.baseUrl,
    required this.db,
  });

  Future<void> scrape() async {
    print('Starting scrape for $source');
    
    try {
      // Create scraping job
      final job = await _createScrapingJob();
      
      // Start scraping
      final products = await _scrapeProducts();
      
      // Save products to database
      await _saveProducts(products);
      
      // Update job status
      await _updateScrapingJob(job.id, 'completed', products.length);
      
      print('Scraping completed for $source. Found ${products.length} products');
    } catch (e, stackTrace) {
      print('Error scraping $source: $e');
      print(stackTrace);
      await _updateScrapingJobError(e.toString());
    }
  }

  Future<List<Product>> _scrapeProducts() async {
    throw UnimplementedError();
  }

  Future<ScrapingJob> _createScrapingJob() async {
    final conn = await db.getConnection();
    final job = ScrapingJob(
      id: const Uuid().v4(),
      source: source,
      status: 'running',
      productsScraped: 0,
      startedAt: DateTime.now(),
    );
    
    await conn.execute('''
      INSERT INTO scraping_jobs (id, source, status, products_scraped, started_at)
      VALUES (@id, @source, @status, @products_scraped, @started_at)
    ''', substitutionValues: {
      'id': job.id,
      'source': job.source,
      'status': job.status,
      'products_scraped': job.productsScraped,
      'started_at': job.startedAt,
    });
    
    return job;
  }

  Future<void> _updateScrapingJob(String jobId, String status, int productsUpdated) async {
    final conn = await db.getConnection();
    await conn.execute('''
      UPDATE scraping_jobs 
      SET status = @status, products_updated = @products_updated, completed_at = @completed_at
      WHERE id = @id
    ''', substitutionValues: {
      'id': jobId,
      'status': status,
      'products_updated': productsUpdated,
      'completed_at': DateTime.now(),
    });
  }

  Future<void> _updateScrapingJobError(String error) async {
    // This would need to be implemented to track the current job
    print('Scraping error: $error');
  }

  Future<void> _saveProducts(List<Product> products) async {
    final conn = await db.getConnection();
    
    for (final product in products) {
      try {
        await conn.execute('''
          INSERT INTO products (
            id, title, description, price, old_price, discount, 
            image_url, product_url, brand, category_id, sku, 
            specifications, stock, rating, review_count, source, source_id
          ) VALUES (
            @id, @title, @description, @price, @old_price, @discount,
            @image_url, @product_url, @brand, @category_id, @sku,
            @specifications, @stock, @rating, @review_count, @source, @source_id
          ) ON CONFLICT (source, source_id) DO UPDATE SET
            title = EXCLUDED.title,
            description = EXCLUDED.description,
            price = EXCLUDED.price,
            old_price = EXCLUDED.old_price,
            discount = EXCLUDED.discount,
            image_url = EXCLUDED.image_url,
            product_url = EXCLUDED.product_url,
            brand = EXCLUDED.brand,
            category_id = EXCLUDED.category_id,
            sku = EXCLUDED.sku,
            specifications = EXCLUDED.specifications,
            stock = EXCLUDED.stock,
            rating = EXCLUDED.rating,
            review_count = EXCLUDED.review_count,
            updated_at = CURRENT_TIMESTAMP
        ''', substitutionValues: {
          'id': product.id,
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'old_price': product.oldPrice,
          'discount': product.discount,
          'image_url': product.imageUrl,
          'product_url': product.productUrl,
          'brand': product.brand,
          'category_id': null, // TODO: Map to actual category
          'sku': product.sku,
          'specifications': product.specifications != null 
              ? postgres.Text(product.specifications.toString())
              : null,
          'stock': product.stock,
          'rating': product.rating,
          'review_count': product.reviewCount,
          'source': product.source,
          'source_id': product.sourceId,
        });
      } catch (e) {
        print('Error saving product ${product.title}: $e');
      }
    }
  }

  Future<selenium.WebDriver> _createWebDriver() async {
    final capabilities = selenium.CapabilitySet('chrome')
      ..add(selenium.ChromeOption('headless', true))
      ..add(selenium.ChromeOption('disable-gpu', true))
      ..add(selenium.ChromeOption('no-sandbox', true))
      ..add(selenium.ChromeOption('disable-dev-shm-usage', true))
      ..add(selenium.ChromeOption('window-size', '1920,1080'));
    
    return await webdriver_io.createDriver(
      capabilities: capabilities,
    );
  }

  String _extractText(String html, String selector) {
    final document = parser.parse(html);
    final element = document.querySelector(selector);
    return element?.text.trim() ?? '';
  }

  int? _extractPrice(String html, String selector) {
    final text = _extractText(html, selector);
    final priceMatch = RegExp(r'(\d+(?:\s\d+)*)').firstMatch(text);
    if (priceMatch != null) {
      return int.parse(priceMatch.group(1)!.replaceAll(' ', ''));
    }
    return null;
  }

  double? _extractRating(String html, String selector) {
    final text = _extractText(html, selector);
    final ratingMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    if (ratingMatch != null) {
      return double.parse(ratingMatch.group(1)!);
    }
    return null;
  }
}