import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'cors_proxy_service.dart';

class WildberriesApiService {
  // Wildberries API endpoints
  static const String baseUrl = "https://search.wb.ru/exactmatch/ru/common/v4/search";
  static const String brandId = "311036101"; // My Modus brand ID
  static const String brandName = "My Modus";

  static Future<List<Product>> fetchMyModusProducts() async {
    try {
      // Use CORS proxy for web environment, direct API for mobile
      if (kIsWeb) {
        return await CorsProxyService.fetchMyModusProducts();
      } else {
        return await _fetchDirectApi(
          "$baseUrl?TestGroup=no_test&TestID=no_test&appType=1&cat=8126&curr=rub&dest=-1257786&filters=xsubject&query=My%20Modus&resultset=catalog&sort=popular&spp=0&suppressSpellcheck=false"
        );
      }
    } catch (e) {
      // Fallback to proxy if direct API fails
      if (kIsWeb) {
        throw Exception("Failed to fetch products: $e");
      } else {
        throw Exception("Failed to fetch products: $e");
      }
    }
  }

  static Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      // Use CORS proxy for web environment, direct API for mobile
      if (kIsWeb) {
        return await CorsProxyService.fetchProductsByCategory(category);
      } else {
        return await _fetchDirectApi(
          "$baseUrl?TestGroup=no_test&TestID=no_test&appType=1&cat=$category&curr=rub&dest=-1257786&filters=xsubject&query=My%20Modus&resultset=catalog&sort=popular&spp=0&suppressSpellcheck=false"
        );
      }
    } catch (e) {
      // Fallback to proxy if direct API fails
      if (kIsWeb) {
        throw Exception("Failed to fetch products: $e");
      } else {
        throw Exception("Failed to fetch products: $e");
      }
    }
  }

  static Future<List<Product>> _fetchDirectApi(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'application/json',
          'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timeout. Please check your internet connection.");
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if API response structure is valid
        if (data == null || !data.containsKey('data') || !data['data'].containsKey('products')) {
          throw Exception("Invalid API response format");
        }
        
        final List products = data['data']['products'] ?? [];
        
        if (products.isEmpty) {
          return [];
        }
        
        return products.map((product) => Product.fromWildberriesJson(product)).toList();
      } else if (response.statusCode == 404) {
        throw Exception("API endpoint not found. Please try again later.");
      } else if (response.statusCode == 429) {
        throw Exception("Too many requests. Please wait before trying again.");
      } else {
        throw Exception("Failed to load products: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("TimeoutException")) {
        throw Exception("Request timeout. Please check your internet connection and try again.");
      } else if (e.toString().contains("SocketException")) {
        throw Exception("Network error. Please check your internet connection.");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  }
}