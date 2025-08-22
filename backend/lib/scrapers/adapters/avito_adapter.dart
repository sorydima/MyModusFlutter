import 'dart:convert';
import 'package:http/http.dart' as http;
import 'helpers.dart';

Future<Map<String,dynamic>> parseAvito(String url) async {
  try {
    final headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language': 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
      'Accept-Encoding': 'gzip, deflate',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
    };

    final res = await http.get(Uri.parse(url), headers: headers);
    final body = res.body;
    
    // Try JSON-LD first
    final jsonld = tryParseJsonLd(body);
    String title = jsonld['name'] ?? extractMeta(body, 'og:title');
    String image = (jsonld['image'] is String) ? jsonld['image'] : (jsonld['image'] is List ? (jsonld['image'].isNotEmpty ? jsonld['image'][0] : '') : extractMeta(body, 'og:image'));
    String desc = jsonld['description'] ?? extractMeta(body, 'og:description');
    String brand = '';
    
    if (jsonld.containsKey('brand')) {
      if (jsonld['brand'] is Map) brand = jsonld['brand']['name'] ?? '';
      else if (jsonld['brand'] is String) brand = jsonld['brand'];
    }
    
    // Try to find price in JSON-LD
    String price = '';
    String currency = '';
    if (jsonld.containsKey('offers')) {
      final offers = jsonld['offers'];
      if (offers is Map) {
        price = offers['price']?.toString() ?? '';
        currency = offers['priceCurrency'] ?? '';
      } else if (offers is List && offers.isNotEmpty && offers[0] is Map) {
        price = offers[0]['price']?.toString() ?? '';
        currency = offers[0]['priceCurrency'] ?? '';
      }
    }
    
    // If no price in JSON-LD, try to extract from HTML
    if (price.isEmpty) {
      price = _extractPriceFromHtml(body);
    }
    
    // Extract additional Avito-specific information
    final location = _extractLocation(body);
    final condition = _extractCondition(body);
    final sellerType = _extractSellerType(body);
    
    return {
      'external_id': url,
      'title': title ?? '',
      'description': desc ?? '',
      'image_url': image ?? '',
      'url': url,
      'price': price,
      'currency': currency,
      'marketplace': 'avito',
      'brand': brand,
      'location': location,
      'condition': condition,
      'seller_type': sellerType,
      'source': 'avito'
    };
  } catch (e) {
    return {'error': e.toString()};
  }
}

String _extractPriceFromHtml(String html) {
  try {
    // Look for price patterns in HTML
    final pricePatterns = [
      RegExp(r'(\d+(?:\s\d+)*)\s*₽'), // Russian ruble
      RegExp(r'(\d+(?:\s\d+)*)\s*руб'), // Russian ruble text
      RegExp(r'price["\']?\s*[:=]\s*["\']?(\d+(?:\s\d+)*)'), // Price attribute
      RegExp(r'(\d+(?:\s\d+)*)\s*[₽ру]'), // Combined patterns
    ];
    
    for (final pattern in pricePatterns) {
      final match = pattern.firstMatch(html);
      if (match != null) {
        return match.group(1)!.replaceAll(' ', '');
      }
    }
    
    // Look for price in specific Avito selectors
    final avitoPriceSelectors = [
      RegExp(r'data-marker="item-view/item-price"[^>]*>([^<]+)'),
      RegExp(r'class="[^"]*price[^"]*"[^>]*>([^<]+)'),
      RegExp(r'price-value[^>]*>([^<]+)'),
    ];
    
    for (final selector in avitoPriceSelectors) {
      final match = selector.firstMatch(html);
      if (match != null) {
        final priceText = match.group(1)!.trim();
        final priceMatch = RegExp(r'(\d+(?:\s\d+)*)').firstMatch(priceText);
        if (priceMatch != null) {
          return priceMatch.group(1)!.replaceAll(' ', '');
        }
      }
    }
  } catch (e) {
    print('Error extracting price from HTML: $e');
  }
  return '';
}

String _extractLocation(String html) {
  try {
    // Look for location information
    final locationPatterns = [
      RegExp(r'data-marker="item-view/location"[^>]*>([^<]+)'),
      RegExp(r'location[^>]*>([^<]+)'),
      RegExp(r'город[^:]*:\s*([^<\n]+)'),
      RegExp(r'адрес[^:]*:\s*([^<\n]+)'),
    ];
    
    for (final pattern in locationPatterns) {
      final match = pattern.firstMatch(html);
      if (match != null) {
        return match.group(1)!.trim();
      }
    }
  } catch (e) {
    print('Error extracting location: $e');
  }
  return '';
}

String _extractCondition(String html) {
  try {
    // Look for condition information
    final conditionPatterns = [
      RegExp(r'состояние[^:]*:\s*([^<\n]+)'),
      RegExp(r'condition[^:]*:\s*([^<\n]+)'),
      RegExp(r'новый'),
      RegExp(r'б/у'),
      RegExp(r'used'),
      RegExp(r'new'),
    ];
    
    for (final pattern in conditionPatterns) {
      final match = pattern.firstMatch(html.toLowerCase());
      if (match != null) {
        return match.group(1)?.trim() ?? match.group(0)!.trim();
      }
    }
  } catch (e) {
    print('Error extracting condition: $e');
  }
  return '';
}

String _extractSellerType(String html) {
  try {
    // Look for seller type information
    final sellerPatterns = [
      RegExp(r'продавец[^:]*:\s*([^<\n]+)'),
      RegExp(r'seller[^:]*:\s*([^<\n]+)'),
      RegExp(r'частное лицо'),
      RegExp(r'компания'),
      RegExp(r'private'),
      RegExp(r'company'),
    ];
    
    for (final pattern in sellerPatterns) {
      final match = pattern.firstMatch(html.toLowerCase());
      if (match != null) {
        return match.group(1)?.trim() ?? match.group(0)!.trim();
      }
    }
  } catch (e) {
    print('Error extracting seller type: $e');
  }
  return '';
}
