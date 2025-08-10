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

class OzonScraper extends BaseScraper {
  OzonScraper({required super.db}) 
      : super(source: 'ozon', baseUrl: 'https://www.ozon.ru');

  @override
  Future<List<Product>> _scrapeProducts() async {
    final products = <Product>[];
    final driver = await _createWebDriver();
    
    try {
      // Get popular categories
      await driver.get('$baseUrl/category/elektronika-15500/');
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
      print('Error in Ozon scraping: $e');
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
      
      // Get product elements
      final productElements = await driver.findElementsByCss('.tile-hover-target');
      
      for (final element in productElements) {
        final href = await element.getAttribute('href');
        if (href != null && href.contains('detail')) {
          links.add(href);
        }
      }
      
      // Also get pagination and scrape multiple pages
      final paginationElements = await driver.findElementsByCss('.paginator-button-next');
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
        category: 'Электроника', // TODO: Implement category detection
        sku: _extractSku(document),
        specifications: _extractSpecifications(document),
        stock: _extractStock(document),
        rating: rating ?? 0.0,
        reviewCount: reviewCount ?? 0,
        source: 'ozon',
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
      // Try multiple selectors
      final selectors = [
        '.p1h9e3v0',
        '.tile2-title',
        '.product-title',
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
      final priceElement = document.querySelector('.c1q5u7u7');
      if (priceElement != null) {
        final priceText = priceElement.text.trim();
        final priceMatch = RegExp(r'(\d+(?:\s\d+)*)').firstMatch(priceText);
        if (priceMatch != null) {
          return int.parse(priceMatch.group(1)!.replaceAll(' ', ''));
        }
      }
    } catch (e) {
      print('Error extracting price: $e');
    }
    return null;
  }

  int? _extractOldPrice(parser.Document document) {
    try {
      final oldPriceElement = document.querySelector('.c1q5u7u7');
      if (oldPriceElement != null) {
        // Ozon often shows old price with strikethrough
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
      final discountElement = document.querySelector('.c1q5u7u7');
      if (discountElement != null) {
        // Look for discount percentage
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
      final imageElement = document.querySelector('.c1d5p4v0');
      if (imageElement != null) {
        final src = imageElement.attributes['src'] ?? imageElement.attributes['data-src'];
        if (src != null) {
          return src.startsWith('http') ? src : 'https:$src';
        }
      }
    } catch (e) {
      print('Error extracting image URL: $e');
    }
    return '';
  }

  String _extractBrand(parser.Document document) {
    try {
      final brandElement = document.querySelector('.c1d5p4v0');
      if (brandElement != null) {
        // Brand is often in the title or separate element
        final title = _extractTitle(document);
        if (title.contains(' ')) {
          return title.split(' ').first;
        }
      }
    } catch (e) {
      print('Error extracting brand: $e');
    }
    return '';
  }

  double? _extractRating(parser.Document document) {
    try {
      final ratingElement = document.querySelector('.c1q5u7u7');
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
      final reviewElement = document.querySelector('.c1q5u7u7');
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
      final descriptionElement = document.querySelector('.c1d5p4v0');
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
      final skuElement = document.querySelector('.c1d5p4v0');
      if (skuElement != null) {
        // SKU might be in the URL or page metadata
        return _extractSourceId(document.outerHtml);
      }
    } catch (e) {
      print('Error extracting SKU: $e');
    }
    return null;
  }

  Map<String, dynamic>? _extractSpecifications(parser.Document document) {
    try {
      final specsElement = document.querySelector('.c1d5p4v0');
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
      final stockElement = document.querySelector('.c1d5p4v0');
      if (stockElement != null) {
        final stockText = stockElement.text.trim();
        if (stockText.toLowerCase().contains('в наличии')) {
          return 10; // Default stock for available items
        }
      }
    } catch (e) {
      print('Error extracting stock: $e');
    }
    return 0;
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