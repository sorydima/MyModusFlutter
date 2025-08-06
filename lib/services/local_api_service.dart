import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class LocalApiService {
  // Local backend URL
  static const String baseUrl = "http://localhost:8000";
  
  // For mobile/emulator, use 10.0.2.2 for Android emulator
  static String get apiUrl {
    if (kIsWeb) {
      return baseUrl;
    } else {
      // For mobile devices connecting to local server
      // Use your machine's IP address if testing on real device
      return "http://10.0.2.2:8000"; // Android emulator
    }
  }

  static Future<List<Product>> fetchMyModusProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/products'),
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
        
        // Check if response structure is valid
        if (data == null || !data.containsKey('products')) {
          throw Exception("Invalid API response format");
        }
        
        final List products = data['products'] ?? [];
        
        if (products.isEmpty) {
          return [];
        }
        
        // Convert the scraped data to Product model
        return products.map((product) => Product.fromLocalJson(product)).toList();
      } else {
        throw Exception("Failed to load products: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("TimeoutException")) {
        throw Exception("Request timeout. Please check your internet connection.");
      } else if (e.toString().contains("SocketException")) {
        throw Exception("Network error. Please check your internet connection and ensure the local server is running.");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  }

  static Future<List<Product>> refreshProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/products/refresh'),
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
        
        if (data == null || !data.containsKey('products')) {
          throw Exception("Invalid API response format");
        }
        
        final List products = data['products'] ?? [];
        
        return products.map((product) => Product.fromLocalJson(product)).toList();
      } else {
        throw Exception("Failed to refresh products: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to refresh products: $e");
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/health'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return false;
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
