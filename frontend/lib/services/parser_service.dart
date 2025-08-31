
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// API URL can be overridden at build/run time:
/// flutter run -d chrome --dart-define=API_URL=http://localhost:8080/api/products
/// Default points to localhost backend which you should run: dart run backend/bin/server.dart
class ApiService {
  static const String BASE_URL = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080/api/products');
  static Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse(BASE_URL);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((e) => Product.fromJson(e)).toList();
      } else if (data is Map && data.containsKey('products')) {
        final list = data['products'] as List;
        return list.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}
