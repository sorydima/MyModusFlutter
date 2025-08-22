import 'dart:async';
import 'dart:io';
import 'package:botasaurus/botasaurus.dart';
import 'package:botasaurus/src/utils.dart';
import 'package:webdriver/selenium.dart' as selenium;
import 'package:webdriver/io.dart' as webdriver_io;
import 'package:html/parser.dart' as parser;
import 'package:uuid/uuid.dart';
import 'base_scraper.dart';
import '../models.dart';
import '../database.dart';

class AvitoScraper extends BaseScraper {
  AvitoScraper({required super.db}) 
      : super(source: 'avito', baseUrl: 'https://www.avito.ru');

  @override
  Future<List<Product>> _scrapeProducts() async {
    final products = <Product>[];
    final driver = await _createWebDriver();
    
    try {
      // Get popular categories
      await driver.get('$baseUrl/moskva/odezhda_obuv_aksessuary');
      await Future.delayed(Duration(seconds: 3));
      
      // Extract product links
      final productLinks = await _extractProductLinks(driver);
      
      // Scrape each product
      for (int i = 0; i < productLinks.length; i++) {
        try {
          final product = await _scrapeProductPage(driver, productLinks[i]);
          if (product != null) {
            products.add(product);
          }
          
          // Add delay to avoid being blocked
          await Future.delayed(Duration(seconds: 2));
          
          print('Scraped ${i + 1}/${productLinks.length} products');
        } catch (e) {
          print('Error scraping product ${productLinks[i]}: $e');
        }
      }
    } catch (e) {
      print('Error in Avito scraping: $e');
    } finally {
      await driver.quit();
    }
    
    return products;
  }

  Future<List<String>> _extractProductLinks(selenium.WebDriver driver) async {
    final links = <String>[];
    
    try {
      // Wait for products to load
      await Future.delayed(Duration(seconds: 3));
      
      // Get product elements - Avito specific selectors
      final productElements = await driver.findElementsByCss('[data-marker="item"]');
      
      for (final element in productElements) {
        try {
          final linkElement = await element.findElementByCss('a[data-marker="item-title"]');
          final href = await linkElement.getAttribute('href');
          if (href != null && href.contains('/item/')) {
            links.add(href.startsWith('http') ? href : 'https://www.avito.ru$href');
          }
        } catch (e) {
          print('Error extracting link from product element: $e');
        }
      }
      
      // Also get pagination and scrape multiple pages
      final paginationElements = await driver.findElementsByCss('[data-marker="pagination-button/nextPage"]');
      if (paginationElements.isNotEmpty) {
        await Future.delayed(Duration(seconds: 2));
        await driver.get(paginationElements.first.getAttribute('href')!);
        final moreLinks = await _extractProductLinks(driver);
        links.addAll(moreLinks);
      }
    } catch (e) {
      print('Error extracting product links: $e');
    }
    
    return links.toSet().toList(); // Remove duplicates
  }

  Future<Product?> _scrapeProductPage(selenium.WebDriver driver, String productUrl) async {
    try {
      await driver.get(productUrl);
      await Future.delayed(Duration(seconds: 2));
      
      final pageSource = await driver.pageSource;
      final document = parser.parse(pageSource);
      
      // Extract product information
      final title = _extractTitle(document);
      final price = _extractPrice(document);
      final oldPrice = _extractOldPrice(document);
      final discount = _extractDiscount(document);
      final imageUrl = _extractImageUrl(document);
      final brand = _extractBrand(document);
      final rating = _extractRating(document);
      final reviewCount = _extractReviewCount(document);
      final description = _extractDescription(document);
      
      if (title.isEmpty || price == null) {
        return null;
      }
      
      return Product(
        id: const Uuid().v4(),
        title: title,
        description: description,
        price: price,
        oldPrice: oldPrice,
        discount: discount,
        imageUrl: imageUrl,
        productUrl: productUrl,
        brand: brand,
        category: 'Одежда и обувь', // Default category for Avito
        sku: _extractSku(document),
        specifications: _extractSpecifications(document),
        stock: _extractStock(document),
        rating: rating ?? 0.0,
        reviewCount: reviewCount ?? 0,
        source: 'avito',
        sourceId: _extractSourceId(productUrl),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error scraping product page $productUrl: $e');
      return null;
    }
  }

  String _extractTitle(parser.Document document) {
    try {
      // Avito specific selectors
      final selectors = [
        '[data-marker="item-view/title"]',
        'h1[data-marker="item-view/title"]',
        '.title-info-title',
        'h1'
      ];
      
      for (final selector in selectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          return element.text.trim();
        }
      }
    } catch (e) {
      print('Error extracting title: $e');
    }
    return '';
  }

  int? _extractPrice(parser.Document document) {
    try {
      // Avito price selectors
      final priceElement = document.querySelector('[data-marker="item-view/item-price"]');
      if (priceElement != null) {
        final priceText = priceElement.text.trim();
        final priceMatch = RegExp(r'(\d+(?:\s\d+)*)').firstMatch(priceText);
        if (priceMatch != null) {
          return int.parse(priceMatch.group(1)!.replaceAll(' ', ''));
        }
      }
      
      // Alternative price selectors
      final altPriceSelectors = [
        '.price-value-string',
        '.price-value',
        '[class*="price"]'
      ];
      
      for (final selector in altPriceSelectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          final priceText = element.text.trim();
          final priceMatch = RegExp(r'(\d+(?:\s\d+)*)').firstMatch(priceText);
          if (priceMatch != null) {
            return int.parse(priceMatch.group(1)!.replaceAll(' ', ''));
          }
        }
      }
    } catch (e) {
      print('Error extracting price: $e');
    }
    return null;
  }

  int? _extractOldPrice(parser.Document document) {
    try {
      // Avito old price selectors
      final oldPriceElement = document.querySelector('[data-marker="item-view/old-price"]');
      if (oldPriceElement != null) {
        final oldPriceText = oldPriceElement.text.trim();
        final priceMatch = RegExp(r'(\d+(?:\s\d+)*)').firstMatch(oldPriceText);
        if (priceMatch != null) {
          return int.parse(priceMatch.group(1)!.replaceAll(' ', ''));
        }
      }
    } catch (e) {
      print('Error extracting old price: $e');
    }
    return null;
  }

  int? _extractDiscount(parser.Document document) {
    try {
      // Look for discount percentage in price elements
      final priceElements = document.querySelectorAll('[class*="price"]');
      for (final element in priceElements) {
        final text = element.text;
        final discountMatch = RegExp(r'(-?\d+)%').firstMatch(text);
        if (discountMatch != null) {
          return int.parse(discountMatch.group(1)!);
        }
      }
    } catch (e) {
      print('Error extracting discount: $e');
    }
    return null;
  }

  String _extractImageUrl(parser.Document document) {
    try {
      // Avito image selectors
      final imageSelectors = [
        '[data-marker="item-view/gallery-image"] img',
        '.gallery-img img',
        '.photo-slider img',
        'img[data-marker="item-view/gallery-image"]'
      ];
      
      for (final selector in imageSelectors) {
        final imageElement = document.querySelector(selector);
        if (imageElement != null) {
          final src = imageElement.attributes['src'] ?? 
                     imageElement.attributes['data-src'] ??
                     imageElement.attributes['data-lazy'];
          if (src != null) {
            return src.startsWith('http') ? src : 'https:$src';
          }
        }
      }
    } catch (e) {
      print('Error extracting image URL: $e');
    }
    return '';
  }

  String _extractBrand(parser.Document document) {
    try {
      // Try to extract brand from title or specifications
      final title = _extractTitle(document);
      if (title.contains(' ')) {
        final words = title.split(' ');
        // Common brand patterns
        for (final word in words) {
          if (word.length > 2 && RegExp(r'^[A-Z][a-z]+$').hasMatch(word)) {
            return word;
          }
        }
      }
      
      // Look for brand in specifications
      final brandElement = document.querySelector('[data-marker="item-view/item-params"]');
      if (brandElement != null) {
        final text = brandElement.text.toLowerCase();
        if (text.contains('бренд:')) {
          final brandMatch = RegExp(r'бренд:\s*([^\n]+)').firstMatch(text);
          if (brandMatch != null) {
            return brandMatch.group(1)!.trim();
          }
        }
      }
    } catch (e) {
      print('Error extracting brand: $e');
    }
    return '';
  }

  double? _extractRating(parser.Document document) {
    try {
      // Avito rating selectors
      final ratingSelectors = [
        '[data-marker="item-view/rating"]',
        '.rating-value',
        '[class*="rating"]'
      ];
      
      for (final selector in ratingSelectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          final ratingText = element.text.trim();
          final ratingMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(ratingText);
          if (ratingMatch != null) {
            return double.parse(ratingMatch.group(1)!);
          }
        }
      }
    } catch (e) {
      print('Error extracting rating: $e');
    }
    return null;
  }

  int? _extractReviewCount(parser.Document document) {
    try {
      // Avito review count selectors
      final reviewSelectors = [
        '[data-marker="item-view/reviews-count"]',
        '.reviews-count',
        '[class*="review"]'
      ];
      
      for (final selector in reviewSelectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          final reviewText = element.text.trim();
          final reviewMatch = RegExp(r'(\d+)').firstMatch(reviewText);
          if (reviewMatch != null) {
            return int.parse(reviewMatch.group(1)!);
          }
        }
      }
    } catch (e) {
      print('Error extracting review count: $e');
    }
    return null;
  }

  String _extractDescription(parser.Document document) {
    try {
      // Avito description selectors
      final descriptionSelectors = [
        '[data-marker="item-view/item-description"]',
        '.item-description',
        '.description-text'
      ];
      
      for (final selector in descriptionSelectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          return element.text.trim();
        }
      }
    } catch (e) {
      print('Error extracting description: $e');
    }
    return '';
  }

  String? _extractSku(parser.Document document) {
    try {
      // Try to extract SKU from URL or page metadata
      return _extractSourceId(document.outerHtml);
    } catch (e) {
      print('Error extracting SKU: $e');
    }
    return null;
  }

  Map<String, dynamic>? _extractSpecifications(parser.Document document) {
    try {
      // Avito specifications selectors
      final specsElement = document.querySelector('[data-marker="item-view/item-params"]');
      if (specsElement != null) {
        final specs = <String, dynamic>{};
        final rows = specsElement.querySelectorAll('.item-params-list-item');
        
        for (final row in rows) {
          final labelElement = row.querySelector('.item-params-label');
          final valueElement = row.querySelector('.item-params-value');
          
          if (labelElement != null && valueElement != null) {
            final label = labelElement.text.trim();
            final value = valueElement.text.trim();
            if (label.isNotEmpty && value.isNotEmpty) {
              specs[label] = value;
            }
          }
        }
        
        return specs;
      }
    } catch (e) {
      print('Error extracting specifications: $e');
    }
    return null;
  }

  int _extractStock(parser.Document document) {
    try {
      // Check if item is available
      final availabilityElement = document.querySelector('[data-marker="item-view/availability"]');
      if (availabilityElement != null) {
        final text = availabilityElement.text.toLowerCase();
        if (text.contains('в наличии') || text.contains('доступен')) {
          return 10; // Default stock for available items
        }
      }
      
      // Alternative availability check
      final soldElement = document.querySelector('[data-marker="item-view/sold"]');
      if (soldElement != null) {
        return 0; // Item is sold
      }
    } catch (e) {
      print('Error extracting stock: $e');
    }
    return 5; // Default stock
  }

  String _extractSourceId(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty && pathSegments.last.contains('_')) {
        return pathSegments.last;
      }
    } catch (e) {
      print('Error extracting source ID: $e');
    }
    return '';
  }

  Future<selenium.WebDriver> _createWebDriver() async {
    final capabilities = selenium.Capabilities.chrome;
    capabilities['goog:chromeOptions'] = {
      'args': [
        '--no-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--disable-web-security',
        '--disable-features=VizDisplayCompositor',
        '--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      ]
    };
    
    final driver = await selenium.createDriver(
      uri: Uri.parse('http://localhost:4444/wd/hub'),
      desired: capabilities,
    );
    
    return driver;
  }
}
