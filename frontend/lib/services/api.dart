import 'dart:convert';
import 'package:http/http.dart' as http;

final baseUrl = const String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8080');

Future<List<dynamic>> fetchProducts() async {
  final res = await http.get(Uri.parse('\$baseUrl/products'));
  if (res.statusCode == 200) return List<dynamic>.from(jsonDecode(res.body));
  return [];
}

Future<Map<String, dynamic>> scrapeUrl(String url) async {
  final res = await http.post(Uri.parse('\$baseUrl/scrape'), body: jsonEncode({'url': url}), headers: {'content-type': 'application/json'});
  if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
  throw Exception('Scrape failed: ' + res.body);
}

// Web3 wallet and AI hooks
Future<Map<String, dynamic>> createWallet(int userId, String passphrase) async {
  final res = await http.post(Uri.parse('\$baseUrl/wallets/create'), body: jsonEncode({'user_id': userId, 'passphrase': passphrase}), headers: {'content-type': 'application/json'});
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> getBalance(String address) async {
  final res = await http.get(Uri.parse('\$baseUrl/wallets/\$address/balance'));
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<String> generateDescription(String prompt) async {
  final res = await http.post(Uri.parse('\$baseUrl/ai/generate-description'), body: jsonEncode({'prompt': prompt}), headers: {'content-type': 'application/json'});
  final out = jsonDecode(res.body) as Map<String, dynamic>;
  return out['description'] as String;
}


Future<Map<String, dynamic>> launchScrape(String url, String connector) async {
  final res = await http.post(Uri.parse('\$baseUrl/admin/launch-scrape'), body: jsonEncode({'url': url, 'connector': connector}), headers: {'content-type': 'application/json'});
  if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
  throw Exception('Failed to launch: ' + res.body);
}

Future<Map<String,dynamic>> getFeed({int limit = 20, int offset = 0}) async {
  final res = await http.get(Uri.parse('\$baseUrl/api/v1/feed?limit=\$limit&offset=\$offset'));
  if (res.statusCode == 200) return jsonDecode(res.body);
  return {'error': res.body};
}

Future<Map<String,dynamic>> getItem(int id) async {
  final res = await http.get(Uri.parse('\$baseUrl/api/v1/items/\$id'));
  if (res.statusCode == 200) return jsonDecode(res.body);
  return {'error': res.body};
}
