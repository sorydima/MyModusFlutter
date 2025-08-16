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

class WildberriesScraper extends BaseScraper {
  WildberriesScraper({required super.db}) 
      : super(source: 'wildberries', baseUrl: 'https://www.wildberries.ru');

  @override
  Future<List<Product>> _scrapeProducts() async {
    final products = <Product>[];
    final driver = await _createWebDriver();
    
    try {
      // Get popular categories
      final categories = [
        '/catalog/zhenshchinam',
        '/catalog/muzhchinam',
        '/catalog/detyam',
        '/catalog/obuv',
        '/catalog/aksessuary'
      ];
      
      for (final category in categories) {
        try {
          await driver.get('$baseUrl$category');
          await Future.delayed(Duration(seconds: 3));
          
          // Extract product links
          final productLinks = await _extractProductLinks(driver);
          
          // Scrape each product
          for (int i = 0; i < productLinks.length && i < 20; i++) { // Limit to 20 products per category
            try {
              final product = await _scrapeProductPage(driver, productLinks[i]);
              if (product != null) {
                products.add(product);
              }
              
              // Add delay to avoid being blocked
              await Future.delayed(Duration(seconds: 2));
              
              print('Scraped ${i + 1}/${productLinks.length} products from $category');
            } catch (e) {
              print('Error scraping product ${productLinks[i]}: $e');
            }
          }
          
          await Future.delayed(Duration(seconds: 5)); // Delay between categories
        } catch (e) {
          print('Error scraping category $category: $e');
        }
      }
    } catch (e) {
      print('Error in Wildberries scraping: $e');
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
      
      // Scroll down to load more products
      await _scrollDown(driver);
      
      // Get product elements - Wildberries uses different selectors
      final productElements = await driver.findElementsByCss('.product-card__link');
      
      for (final element in productElements) {
        try {
          final href = await element.getAttribute('href');
          if (href != null && href.contains('/catalog/')) {
            final fullUrl = href.startsWith('http') ? href : '$baseUrl$href';
            links.add(fullUrl);
          }
        } catch (e) {
          print('Error extracting link from element: $e');
        }
      }
      
      // Also try alternative selectors
      if (links.isEmpty) {
        final altElements = await driver.findElementsByCss('.product-card');
        for (final element in altElements) {
          try {
            final linkElement = await element.findElementByCss('a');
            final href = await linkElement.getAttribute('href');
            if (href != null && href.contains('/catalog/')) {
              final fullUrl = href.startsWith('http') ? href : '$baseUrl$href';
              links.add(fullUrl);
            }
          } catch (e) {
            // Continue to next element
          }
        }
      }
      
    } catch (e) {
      print('Error extracting product links: $e');
    }
    
    return links.toSet().toList(); // Remove duplicates
  }

  Future<void> _scrollDown(selenium.WebDriver driver) async {
    try {
      for (int i = 0; i < 3; i++) {
        await driver.executeScript('window.scrollTo(0, document.body.scrollHeight);');
        await Future.delayed(Duration(seconds: 1));
      }
    } catch (e) {
      print('Error scrolling: $e');
    }
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
        category: _extractCategory(productUrl),
        sku: _extractSku(document),
        specifications: _extractSpecifications(document),
        stock: _extractStock(document),
        rating: rating ?? 0.0,
        reviewCount: reviewCount ?? 0,
        source: 'wildberries',
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
      // Try multiple selectors for Wildberries
      final selectors = [
        '.product-page__title',
        '.product-page__header h1',
        '.product-page__title h1',
        '.product-page__header .product-page__title',
        'h1',
        '.product-card__title'
      ];
      
      for (final selector in selectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          final title = element.text.trim();
          if (title.isNotEmpty) {
            return title;
          }
        }
      }
    } catch (e) {
      print('Error extracting title: $e');
    }
    return '';
  }

  int? _extractPrice(parser.Document document) {
    try {
      // Try multiple selectors for price
      final selectors = [
        '.product-page__price .price-block__price',
        '.product-page__price .price-block__final-price',
        '.price-block__price',
        '.price-block__final-price',
        '.product-page__price'
      ];
      
      for (final selector in selectors) {
        final priceElement = document.querySelector(selector);
        if (priceElement != null) {
          final priceText = priceElement.text.trim();
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
      final oldPriceElement = document.querySelector('.price-block__old-price');
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
      final discountElement = document.querySelector('.price-block__discount');
      if (discountElement != null) {
        final discountMatch = RegExp(r'(-?\d+)%').firstMatch(discountElement.text);
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
      // Try multiple selectors for images
      final selectors = [
        '.product-page__image img',
        '.product-page__gallery img',
        '.product-card__image img',
        '.product-page__image .image-slider img'
      ];
      
      for (final selector in selectors) {
        final imageElement = document.querySelector(selector);
        if (imageElement != null) {
          final src = imageElement.attributes['src'] ?? imageElement.attributes['data-src'];
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
      final brandElement = document.querySelector('.product-page__brand');
      if (brandElement != null) {
        return brandElement.text.trim();
      }
      
      // Try to extract from title
      final title = _extractTitle(document);
      if (title.contains(' ')) {
        return title.split(' ').first;
      }
    } catch (e) {
      print('Error extracting brand: $e');
    }
    return '';
  }

  double? _extractRating(parser.Document document) {
    try {
      final ratingElement = document.querySelector('.product-page__rating');
      if (ratingElement != null) {
        final ratingText = ratingElement.text.trim();
        final ratingMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(ratingText);
        if (ratingMatch != null) {
          return double.parse(ratingMatch.group(1)!);
        }
      }
    } catch (e) {
      print('Error extracting rating: $e');
    }
    return null;
  }

  int? _extractReviewCount(parser.Document document) {
    try {
      final reviewElement = document.querySelector('.product-page__reviews-count');
      if (reviewElement != null) {
        final reviewText = reviewElement.text.trim();
        final reviewMatch = RegExp(r'(\d+)').firstMatch(reviewText);
        if (reviewMatch != null) {
          return int.parse(reviewMatch.group(1)!);
        }
      }
    } catch (e) {
      print('Error extracting review count: $e');
    }
    return null;
  }

  String _extractDescription(parser.Document document) {
    try {
      final descriptionElement = document.querySelector('.product-page__description');
      if (descriptionElement != null) {
        return descriptionElement.text.trim();
      }
    } catch (e) {
      print('Error extracting description: $e');
    }
    return '';
  }

  String? _extractSku(parser.Document document) {
    try {
      final skuElement = document.querySelector('.product-page__article');
      if (skuElement != null) {
        return skuElement.text.trim();
      }
    } catch (e) {
      print('Error extracting SKU: $e');
    }
    return null;
  }

  Map<String, dynamic>? _extractSpecifications(parser.Document document) {
    try {
      final specsElement = document.querySelector('.product-page__specifications');
      if (specsElement != null) {
        final specs = <String, dynamic>{};
        final rows = specsElement.querySelectorAll('tr');
        
        for (final row in rows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 2) {
            specs[cells[0].text.trim()] = cells[1].text.trim();
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
      final stockElement = document.querySelector('.product-page__stock');
      if (stockElement != null) {
        final stockText = stockElement.text.trim().toLowerCase();
        if (stockText.contains('в наличии') || stockText.contains('есть')) {
          return 10; // Default stock for available items
        }
      }
    } catch (e) {
      print('Error extracting stock: $e');
    }
    return 0;
  }

  String _extractCategory(String url) {
    try {
      if (url.contains('/zhenshchinam')) return 'Женщинам';
      if (url.contains('/muzhchinam')) return 'Мужчинам';
      if (url.contains('/detyam')) return 'Детям';
      if (url.contains('/obuv')) return 'Обувь';
      if (url.contains('/aksessuary')) return 'Аксессуары';
      return 'Одежда';
    } catch (e) {
      return 'Одежда';
    }
  }

  String _extractSourceId(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
    } catch (e) {
      print('Error extracting source ID: $e');
    }
    return '';
  }
}