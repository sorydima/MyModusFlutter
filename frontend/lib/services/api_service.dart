import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8080';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final http.Client _client = http.Client();

  ApiService();

  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool authRequired = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (authRequired) {
        final token = await _getAuthToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      http.Response response;

      switch (method) {
        case 'POST':
          response = await _client.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await _client.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await _client.delete(
            url,
            headers: headers,
          );
          break;
        default:
          response = await _client.get(
            url,
            headers: headers,
          );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _makeRequest(
      '/auth/login',
      method: 'POST',
      body: {'email': email, 'password': password},
    );
    
    if (response['token'] != null) {
      await _storage.write(key: 'auth_token', value: response['token']);
    }
    
    return response;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Products
  Future<List<ProductModel>> getProducts({int limit = 50}) async {
    final response = await _makeRequest('/api/products?limit=$limit');
    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> getProduct(String id) async {
    final response = await _makeRequest('/api/products/$id');
    return ProductModel.fromJson(response);
  }

  Future<List<ProductModel>> searchProducts({
    String query = '',
    String? category,
    int? minPrice,
    int? maxPrice,
  }) async {
    final params = <String, dynamic>{};
    if (query.isNotEmpty) params['query'] = query;
    if (category != null) params['category'] = category;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    final response = await _makeRequest('/api/search?$queryString');
    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _makeRequest('/api/categories');
    return List<Map<String, dynamic>>.from(response);
  }

  // Scraping
  Future<Map<String, dynamic>> startScrapingAll() async {
    return await _makeRequest('/api/scrape/all', method: 'POST');
  }

  Future<Map<String, dynamic>> startScrapingSource(String source) async {
    return await _makeRequest('/api/scrape/$source', method: 'POST');
  }

  Future<List<Map<String, dynamic>>> getScrapingJobs() async {
    final response = await _makeRequest('/api/scrape/jobs');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getScrapingStats() async {
    final response = await _makeRequest('/api/scrape/stats');
    return response;
  }

  // Cart
  Future<Map<String, dynamic>> addToCart(String productId, int quantity) async {
    return await _makeRequest(
      '/api/cart',
      method: 'POST',
      body: {'productId': productId, 'quantity': quantity},
      authRequired: true,
    );
  }

  Future<Map<String, dynamic>> removeFromCart(String productId) async {
    return await _makeRequest(
      '/api/cart/$productId',
      method: 'DELETE',
      authRequired: true,
    );
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final response = await _makeRequest('/api/cart', authRequired: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // Favorites
  Future<Map<String, dynamic>> addToFavorites(String productId) async {
    return await _makeRequest(
      '/api/favorites',
      method: 'POST',
      body: {'productId': productId},
      authRequired: true,
    );
  }

  Future<Map<String, dynamic>> removeFromFavorites(String productId) async {
    return await _makeRequest(
      '/api/favorites/$productId',
      method: 'DELETE',
      authRequired: true,
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await _makeRequest('/api/favorites', authRequired: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // Orders
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    return await _makeRequest(
      '/api/orders',
      method: 'POST',
      body: orderData,
      authRequired: true,
    );
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _makeRequest('/api/orders', authRequired: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getOrder(String orderId) async {
    final response = await _makeRequest('/api/orders/$orderId', authRequired: true);
    return response;
  }

  // Reviews
  Future<Map<String, dynamic>> addReview(String productId, int rating, String comment) async {
    return await _makeRequest(
      '/api/reviews',
      method: 'POST',
      body: {'productId': productId, 'rating': rating, 'comment': comment},
      authRequired: true,
    );
  }

  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    final response = await _makeRequest('/api/products/$productId/reviews');
    return List<Map<String, dynamic>>.from(response);
  }

  // User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _makeRequest('/api/user/profile', authRequired: true);
    return response;
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    return await _makeRequest(
      '/api/user/profile',
      method: 'PUT',
      body: profileData,
      authRequired: true,
    );
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _makeRequest('/api/analytics', authRequired: true);
    return response;
  }

  // Export/Import
  Future<String> exportData() async {
    final response = await _makeRequest('/api/export', authRequired: true);
    return response['data'];
  }

  Future<void> importData(String data) async {
    await _makeRequest(
      '/api/import',
      method: 'POST',
      body: {'data': data},
      authRequired: true,
    );
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await _makeRequest('/healthz');
      return response == 'ok';
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}