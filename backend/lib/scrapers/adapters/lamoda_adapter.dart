import 'dart:convert';
import 'package:http/http.dart' as http;
import 'helpers.dart';

Future<Map<String,dynamic>> parseLamoda(String url) async {
  try {
    final res = await http.get(Uri.parse(url));
    final body = res.body;
    final jsonld = tryParseJsonLd(body);
    String title = jsonld['name'] ?? extractMeta(body, 'og:title');
    String image = (jsonld['image'] is String) ? jsonld['image'] : extractMeta(body, 'og:image');
    String desc = jsonld['description'] ?? extractMeta(body, 'og:description');
    String brand = '';
    if (jsonld.containsKey('brand')) {
      if (jsonld['brand'] is Map) brand = jsonld['brand']['name'] ?? '';
      else if (jsonld['brand'] is String) brand = jsonld['brand'];
    }
    // lamoda sometimes includes json with price
    String price = '';
    final priceRe = RegExp(r'"price"\s*[:=]\s*"?(\d+[\.,]?\d*)"?', dotAll: true);
    final pm = priceRe.firstMatch(body);
    if (pm != null) price = pm.group(1)!.replaceAll(',', '.');
    return {'external_id': url, 'title': title ?? '', 'description': desc ?? '', 'image_url': image ?? '', 'url': url, 'price': price, 'currency': '', 'marketplace':'lamoda', 'brand': brand};
  } catch (e) {
    return {'error': e.toString()};
  }
}
