import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class CorsProxyService {
  // CORS proxy URL for web environment
  static const String corsProxyUrl = "https://api.allorigins.win/get?url=";
  
  static Future<String> _fetchWithProxy(String targetUrl) async {
    try {
      final proxyUrl = "$corsProxyUrl${Uri.encodeComponent(targetUrl)}";
      final response = await http.get(
        Uri.parse(proxyUrl),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timeout. Please check your internet connection.");
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('contents')) {
          return data['contents'];
        } else {
          throw Exception("Invalid proxy response format");
        }
      } else {
        throw Exception("Proxy request failed: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("TimeoutException")) {
        throw Exception("Request timeout. Please check your internet connection and try again.");
      } else if (e.toString().contains("SocketException")) {
        throw Exception("Network error. Please check your internet connection.");
      } else {
        throw Exception("Proxy error: $e");
      }
    }
  }

  static Future<List<Product>> fetchMyModusProducts() async {
    try {
      final targetUrl = "https://search.wb.ru/exactmatch/ru/common/v4/search?TestGroup=no_test&TestID=no_test&appType=1&cat=8126&curr=rub&dest=-1257786&filters=xsubject&query=My%20Modus&resultset=catalog&sort=popular&spp=0&suppressSpellcheck=false";
      
      final responseBody = await _fetchWithProxy(targetUrl);
      final data = json.decode(responseBody);
      
      // Check if API response structure is valid
      if (data == null || !data.containsKey('data') || !data['data'].containsKey('products')) {
        throw Exception("Invalid API response format");
      }
      
      final List products = data['data']['products'] ?? [];
      
      if (products.isEmpty) {
        return [];
      }
      
      return products.map((product) => Product.fromWildberriesJson(product)).toList();
    } catch (e) {
      throw Exception("Failed to fetch products: $e");
    }
  }

  static Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final targetUrl = "https://search.wb.ru/exactmatch/ru/common/v4/search?TestGroup=no_test&TestID=no_test&appType=1&cat=$category&curr=rub&dest=-1257786&filters=xsubject&query=My%20Modus&resultset=catalog&sort=popular&spp=0&suppressSpellcheck=false";
      
      final responseBody = await _fetchWithProxy(targetUrl);
      final data = json.decode(responseBody);
      
      // Check if API response structure is valid
      if (data == null || !data.containsKey('data') || !data['data'].containsKey('products')) {
        throw Exception("Invalid API response format");
      }
      
      final List products = data['data']['products'] ?? [];
      
      if (products.isEmpty) {
        return [];
      }
      
      return products.map((product) => Product.fromWildberriesJson(product)).toList();
    } catch (e) {
      throw Exception("Failed to fetch products: $e");
    }
  }
}