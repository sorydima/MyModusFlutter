import 'dart:convert';
import 'package:http/http.dart' as http;
import 'helpers.dart';

Future<Map<String,dynamic>> parseOzon(String url) async {
  try {
    final res = await http.get(Uri.parse(url));
    final body = res.body;
    // try JSON-LD
    final jsonld = tryParseJsonLd(body);
    String title = jsonld['name'] ?? extractMeta(body, 'og:title');
    String image = (jsonld['image'] is String) ? jsonld['image'] : (jsonld['image'] is List ? (jsonld['image'].isNotEmpty ? jsonld['image'][0] : '') : extractMeta(body, 'og:image'));
    String desc = jsonld['description'] ?? extractMeta(body, 'og:description');
    String brand = '';
    if (jsonld.containsKey('brand')) {
      if (jsonld['brand'] is Map) brand = jsonld['brand']['name'] ?? '';
      else if (jsonld['brand'] is String) brand = jsonld['brand'];
    }
    // try to find price in JSON-LD
    String price;
    String currency = '';
    if (jsonld.containsKey('offers')) {
      final offers = jsonld['offers'];
      if (offers is Map) {
        price = offers['price']?.toString() ?? '';
        currency = offers['priceCurrency'] ?? '';
      } else if (offers is List && offers.isNotEmpty && offers[0] is Map) {
        price = offers[0]['price']?.toString() ?? '';
        currency = offers[0]['priceCurrency'] ?? '';
      } else {
        price = '';
      }
    } else {
      price = '';
    }
    return {'external_id': url, 'title': title ?? '', 'description': desc ?? '', 'image_url': image ?? '', 'url': url, 'price': price, 'currency': currency, 'marketplace':'ozon', 'brand': brand};
  } catch (e) {
    return {'error': e.toString()};
  }
}
