import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

// Minimal scraper reused earlier heuristics - keep simple here
Future<Map<String, dynamic>?> scrapeProductFromUrl(String url) async {
  try {
    final res = await http.get(Uri.parse(url), headers: {'User-Agent': 'MyModusBot/1.0'});
    if (res.statusCode != 200) return null;
    final doc = parse(res.body);
    final title = doc.querySelector('meta[property="og:title"]')?.attributes['content'] ?? doc.querySelector('h1')?.text?.trim() ?? '';
    final image = doc.querySelector('meta[property="og:image"]')?.attributes['content'] ?? doc.querySelector('img')?.attributes['src'] ?? '';
    final price = doc.querySelector('[class*="price"]')?.text?.trim() ?? '';
    final externalId = base64Url.encode(utf8.encode(url)).replaceAll('=', '');
    return {'external_id': externalId, 'title': title, 'price': price, 'image': image, 'source_url': url};
  } catch (e) {
    print('scrape error: \$e');
    return null;
  }
}
