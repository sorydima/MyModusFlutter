import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8080';
  static const String _apiVersion = '/api/v1';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final http.Client _client = http.Client();

  ApiService();

  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<String?> _getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> _saveTokens(Map<String, dynamic> tokens) async {
    if (tokens['access_token'] != null) {
      await _storage.write(key: 'auth_token', value: tokens['access_token']);
    }
    if (tokens['refresh_token'] != null) {
      await _storage.write(key: 'refresh_token', value: tokens['refresh_token']);
    }
  }

  Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool authRequired = false,
    bool useRefreshToken = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$_apiVersion$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (authRequired) {
        final token = useRefreshToken 
            ? await _getRefreshToken() 
            : await _getAuthToken();
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
      } else if (response.statusCode == 401 && authRequired && !useRefreshToken) {
        // Попытка обновить токен
        final refreshResult = await _refreshToken();
        if (refreshResult) {
          // Повторяем запрос с новым токеном
          return await _makeRequest(endpoint, method: method, body: body, authRequired: authRequired);
        }
      }
      
      throw Exception('Failed to load data: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ===== AUTHENTICATION =====
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final response = await _makeRequest(
      '/auth/register',
      method: 'POST',
      body: {
        'email': email,
        'password': password,
        'name': name,
        if (phone != null) 'phone': phone,
      },
    );
    
    if (response['success'] == true && response['user'] != null) {
      return response['user'];
    }
    
    throw Exception(response['error'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _makeRequest(
      '/auth/login',
      method: 'POST',
      body: {'email': email, 'password': password},
    );
    
    if (response['success'] == true && response['tokens'] != null) {
      await _saveTokens(response['tokens']);
      return response['tokens'];
    }
    
    throw Exception(response['error'] ?? 'Login failed');
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _makeRequest(
        '/auth/refresh',
        method: 'POST',
        body: {'refresh_token': refreshToken},
        useRefreshToken: true,
      );
      
      if (response['success'] == true && response['tokens'] != null) {
        await _saveTokens(response['tokens']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _makeRequest('/auth/logout', method: 'POST', authRequired: true);
    } catch (e) {
      // Игнорируем ошибки при logout
    } finally {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _makeRequest('/auth/profile', authRequired: true);
    return response;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (bio != null) body['bio'] = bio;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final response = await _makeRequest(
      '/auth/profile',
      method: 'PUT',
      body: body,
      authRequired: true,
    );
    return response;
  }

  // ===== PRODUCTS =====

  Future<List<ProductModel>> getProducts({
    int limit = 50,
    int offset = 0,
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (sortOrder != null) queryParams['sort_order'] = sortOrder;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _makeRequest('/products?$queryString');
    return (response['products'] as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> getProduct(String productId) async {
    final response = await _makeRequest('/products/$productId');
    return ProductModel.fromJson(response);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _makeRequest('/products/categories');
    return (response['categories'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPriceHistory(String productId) async {
    final response = await _makeRequest('/products/$productId/price-history');
    return (response['price_history'] as List).cast<Map<String, dynamic>>();
  }

  // ===== SOCIAL NETWORK =====

  Future<List<Map<String, dynamic>>> getPosts({
    int limit = 20,
    int offset = 0,
    String? userId,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (userId != null) queryParams['user_id'] = userId;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _makeRequest('/social/posts?$queryString', authRequired: true);
    return (response['posts'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createPost({
    required String caption,
    List<String>? imageUrls,
    List<String>? hashtags,
  }) async {
    final response = await _makeRequest(
      '/social/posts',
      method: 'POST',
      body: {
        'caption': caption,
        if (imageUrls != null) 'image_urls': imageUrls,
        if (hashtags != null) 'hashtags': hashtags,
      },
      authRequired: true,
    );
    return response;
  }

  Future<void> likePost(String postId) async {
    await _makeRequest(
      '/social/posts/$postId/like',
      method: 'POST',
      authRequired: true,
    );
  }

  Future<void> unlikePost(String postId) async {
    await _makeRequest(
      '/social/posts/$postId/like',
      method: 'DELETE',
      authRequired: true,
    );
  }

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    final response = await _makeRequest(
      '/social/posts/$postId/comments',
      method: 'POST',
      body: {'content': content},
      authRequired: true,
    );
    return response;
  }

  Future<void> followUser(String userId) async {
    await _makeRequest(
      '/social/follow/$userId',
      method: 'POST',
      authRequired: true,
    );
  }

  Future<void> unfollowUser(String userId) async {
    await _makeRequest(
      '/social/follow/$userId',
      method: 'DELETE',
      authRequired: true,
    );
  }

  // ===== CHAT =====

  Future<List<Map<String, dynamic>>> getChats() async {
    final response = await _makeRequest('/social/chats', authRequired: true);
    return (response['chats'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    final response = await _makeRequest('/social/chats/$chatId/messages', authRequired: true);
    return (response['messages'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String content,
    String? messageType,
  }) async {
    final response = await _makeRequest(
      '/social/chats/$chatId/messages',
      method: 'POST',
      body: {
        'content': content,
        if (messageType != null) 'message_type': messageType,
      },
      authRequired: true,
    );
    return response;
  }

  // ===== WEB3 =====

  Future<Map<String, dynamic>> connectWallet(String walletAddress) async {
    final response = await _makeRequest(
      '/web3/connect',
      method: 'POST',
      body: {'wallet_address': walletAddress},
      authRequired: true,
    );
    return response;
  }

  Future<List<Map<String, dynamic>>> getNFTs() async {
    final response = await _makeRequest('/web3/nfts', authRequired: true);
    return (response['nfts'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> mintNFT({
    required String name,
    required String description,
    required String imageUrl,
    required String tokenType,
  }) async {
    final response = await _makeRequest(
      '/web3/nfts/mint',
      method: 'POST',
      body: {
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'token_type': tokenType,
      },
      authRequired: true,
    );
    return response;
  }

  Future<List<Map<String, dynamic>>> getLoyaltyTokens() async {
    final response = await _makeRequest('/web3/loyalty-tokens', authRequired: true);
    return (response['tokens'] as List).cast<Map<String, dynamic>>();
  }

  // ===== AI RECOMMENDATIONS =====

  Future<List<Map<String, dynamic>>> getProductRecommendations() async {
    final response = await _makeRequest('/ai/recommendations/products', authRequired: true);
    return (response['recommendations'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getSocialRecommendations() async {
    final response = await _makeRequest('/ai/recommendations/social', authRequired: true);
    return (response['recommendations'] as List).cast<Map<String, dynamic>>();
  }

  Future<String> generateProductDescription(String productName) async {
    final response = await _makeRequest(
      '/ai/generate/description',
      method: 'POST',
      body: {'product_name': productName},
      authRequired: true,
    );
    return response['description'];
  }

  Future<List<String>> generateHashtags(String content) async {
    final response = await _makeRequest(
      '/ai/generate/hashtags',
      method: 'POST',
      body: {'content': content},
      authRequired: true,
    );
    return (response['hashtags'] as List).cast<String>();
  }

  // ===== SCRAPING STATUS =====

  Future<Map<String, dynamic>> getScrapingStatus() async {
    final response = await _makeRequest('/scraping/status');
    return response;
  }

  Future<Map<String, dynamic>> getScrapingStats() async {
    final response = await _makeRequest('/scraping/stats');
    return response;
  }

  // ===== HEALTH CHECK =====

  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _makeRequest('/health');
    return response;
  }

  // ===== UTILITIES =====

  void dispose() {
    _client.close();
  }
}