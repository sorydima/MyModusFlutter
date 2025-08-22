import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Фронтенд сервис для блокчейн-экосистемы приложения
class BlockchainEcosystemService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api/blockchain';

  final http.Client _httpClient = http.Client();

  // Состояние сервиса
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  // Кэш данных
  final Map<String, dynamic> _nftCollections = {};
  final Map<String, dynamic> _nftTokens = {};
  final Map<String, dynamic> _marketplaceListings = {};
  final Map<String, dynamic> _brandTokens = {};
  final Map<String, dynamic> _smartContracts = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _currentUserId;

  // ===== NFT КОЛЛЕКЦИИ =====

  /// Создание новой NFT коллекции
  Future<Map<String, dynamic>?> createNFTCollection({
    required String name,
    required String description,
    required String creatorId,
    required String imageUrl,
    required int totalSupply,
    required double price,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/nft/collections'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'creatorId': creatorId,
          'imageUrl': imageUrl,
          'totalSupply': totalSupply,
          'price': price,
          'category': category,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final collection = data['data'];
          _nftCollections[collection['id']] = collection;
          notifyListeners();
          return collection;
        } else {
          _setError(data['error'] ?? 'Ошибка создания коллекции');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка создания NFT коллекции: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение NFT коллекций
  Future<List<Map<String, dynamic>>> getNFTCollections({
    String? category,
    String? creatorId,
    String? status,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (creatorId != null) queryParams['creatorId'] = creatorId;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/nft/collections').replace(queryParameters: queryParams);
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final collections = List<Map<String, dynamic>>.from(data['data']);
          
          // Обновляем кэш
          for (final collection in collections) {
            _nftCollections[collection['id']] = collection;
          }
          
          notifyListeners();
          return collections;
        } else {
          _setError(data['error'] ?? 'Ошибка получения коллекций');
          return [];
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      _setError('Ошибка получения NFT коллекций: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Минтинг NFT токена
  Future<Map<String, dynamic>?> mintNFTToken({
    required String collectionId,
    required String ownerId,
    required String tokenName,
    required String tokenDescription,
    required String tokenImageUrl,
    Map<String, dynamic>? attributes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/nft/tokens/mint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'collectionId': collectionId,
          'ownerId': ownerId,
          'tokenName': tokenName,
          'tokenDescription': tokenDescription,
          'tokenImageUrl': tokenImageUrl,
          'attributes': attributes ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final token = data['data'];
          _nftTokens[token['id']] = token;
          notifyListeners();
          return token;
        } else {
          _setError(data['error'] ?? 'Ошибка минтинга токена');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка минтинга NFT токена: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение NFT токенов пользователя
  Future<List<Map<String, dynamic>>> getUserNFTTokens(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/nft/tokens/user/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final tokens = List<Map<String, dynamic>>.from(data['data']);
          
          // Обновляем кэш
          for (final token in tokens) {
            _nftTokens[token['id']] = token;
          }
          
          notifyListeners();
          return tokens;
        } else {
          _setError(data['error'] ?? 'Ошибка получения токенов');
          return [];
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      _setError('Ошибка получения NFT токенов: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ===== ТОРГОВАЯ ПЛОЩАДКА =====

  /// Создание листинга на торговой площадке
  Future<Map<String, dynamic>?> createMarketplaceListing({
    required String tokenId,
    required String sellerId,
    required double price,
    required String currency,
    String? description,
    int? durationDays,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/marketplace/listings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tokenId': tokenId,
          'sellerId': sellerId,
          'price': price,
          'currency': currency,
          'description': description ?? '',
          'duration': durationDays,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final listing = data['data'];
          _marketplaceListings[listing['id']] = listing;
          notifyListeners();
          return listing;
        } else {
          _setError(data['error'] ?? 'Ошибка создания листинга');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка создания листинга: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение активных листингов
  Future<List<Map<String, dynamic>>> getActiveListings({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? currency,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (currency != null) queryParams['currency'] = currency;

      final uri = Uri.parse('$baseUrl/marketplace/listings').replace(queryParameters: queryParams);
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final listings = List<Map<String, dynamic>>.from(data['data']);
          
          // Обновляем кэш
          for (final listing in listings) {
            _marketplaceListings[listing['id']] = listing;
          }
          
          notifyListeners();
          return listings;
        } else {
          _setError(data['error'] ?? 'Ошибка получения листингов');
          return [];
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      _setError('Ошибка получения листингов: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Покупка NFT на торговой площадке
  Future<Map<String, dynamic>?> purchaseNFT({
    required String listingId,
    required String buyerId,
    required double amount,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/marketplace/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'listingId': listingId,
          'buyerId': buyerId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final order = data['data'];
          notifyListeners();
          return order;
        } else {
          _setError(data['error'] ?? 'Ошибка покупки NFT');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка покупки NFT: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ===== ВЕРИФИКАЦИЯ ПОДЛИННОСТИ =====

  /// Создание верификации подлинности
  Future<Map<String, dynamic>?> createAuthenticityVerification({
    required String productId,
    required String brandId,
    required String verificationType,
    required Map<String, dynamic> verificationData,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/verification/authenticity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': productId,
          'brandId': brandId,
          'verificationType': verificationType,
          'verificationData': verificationData,
          'description': description ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final verification = data['data'];
          notifyListeners();
          return verification;
        } else {
          _setError(data['error'] ?? 'Ошибка создания верификации');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка создания верификации: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение верификаций бренда
  Future<List<Map<String, dynamic>>> getBrandVerifications(String brandId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/verification/authenticity/brand/$brandId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final verifications = List<Map<String, dynamic>>.from(data['data']);
          notifyListeners();
          return verifications;
        } else {
          _setError(data['error'] ?? 'Ошибка получения верификаций');
          return [];
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      _setError('Ошибка получения верификаций: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ===== ТОКЕНИЗАЦИЯ БРЕНДОВ =====

  /// Создание токена бренда
  Future<Map<String, dynamic>?> createBrandToken({
    required String brandId,
    required String brandName,
    required String symbol,
    required int totalSupply,
    required double initialPrice,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/brands/tokens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'brandId': brandId,
          'brandName': brandName,
          'symbol': symbol,
          'totalSupply': totalSupply,
          'initialPrice': initialPrice,
          'description': description,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final token = data['data'];
          _brandTokens[token['id']] = token;
          notifyListeners();
          return token;
        } else {
          _setError(data['error'] ?? 'Ошибка создания токена бренда');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка создания токена бренда: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение токенов брендов
  Future<List<Map<String, dynamic>>> getBrandTokens({String? status}) async {
    try {
      _setLoading(true);
      _clearError();

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/brands/tokens').replace(queryParameters: queryParams);
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final tokens = List<Map<String, dynamic>>.from(data['data']);
          
          // Обновляем кэш
          for (final token in tokens) {
            _brandTokens[token['id']] = token;
          }
          
          notifyListeners();
          return tokens;
        } else {
          _setError(data['error'] ?? 'Ошибка получения токенов брендов');
          return [];
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      _setError('Ошибка получения токенов брендов: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ===== СМАРТ-КОНТРАКТЫ =====

  /// Создание смарт-контракта
  Future<Map<String, dynamic>?> createSmartContract({
    required String name,
    required String type,
    required String creatorId,
    required Map<String, dynamic> contractData,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/smart-contracts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'type': type,
          'creatorId': creatorId,
          'contractData': contractData,
          'description': description ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final contract = data['data'];
          _smartContracts[contract['id']] = contract;
          notifyListeners();
          return contract;
        } else {
          _setError(data['error'] ?? 'Ошибка создания смарт-контракта');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка создания смарт-контракта: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение смарт-контрактов
  Future<List<Map<String, dynamic>>> getSmartContracts({String? type, String? status}) async {
    try {
      _setLoading(true);
      _clearError();

      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/smart-contracts').replace(queryParameters: queryParams);
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final contracts = List<Map<String, dynamic>>.from(data['data']);
          
          // Обновляем кэш
          for (final contract in contracts) {
            _smartContracts[contract['id']] = contract;
          }
          
          notifyListeners();
          return contracts;
        } else {
          _setError(data['error'] ?? 'Ошибка получения смарт-контрактов');
          return [];
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      _setError('Ошибка получения смарт-контрактов: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ===== АНАЛИТИКА И СТАТИСТИКА =====

  /// Получение статистики блокчейн-экосистемы
  Future<Map<String, dynamic>?> getEcosystemStats() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/analytics/ecosystem-stats'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          _setError(data['error'] ?? 'Ошибка получения статистики');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка получения статистики: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение истории транзакций пользователя
  Future<List<Map<String, dynamic>>> getUserTransactionHistory(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/analytics/user-transactions/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final transactions = List<Map<String, dynamic>>.from(data['data']);
          notifyListeners();
          return transactions;
        } else {
          _setError(data['error'] ?? 'Ошибка получения истории транзакций');
          return [];
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      _setError('Ошибка получения истории транзакций: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ===== ДЕМО И ТЕСТИРОВАНИЕ =====

  /// Создание демо-данных
  Future<Map<String, dynamic>?> createSampleData() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/demo/create-sample-data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          notifyListeners();
          return data['data'];
        } else {
          _setError(data['error'] ?? 'Ошибка создания демо-данных');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка создания демо-данных: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Симуляция торговли NFT
  Future<Map<String, dynamic>?> simulateNFTTrade({
    String? buyerId,
    required String listingId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/demo/simulate-nft-trade'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'buyerId': buyerId,
          'listingId': listingId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          notifyListeners();
          return data['data'];
        } else {
          _setError(data['error'] ?? 'Ошибка симуляции торговли');
          return null;
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка симуляции торговли: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ===== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ =====

  /// Установка пользователя
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  /// Очистка данных пользователя
  void clearUserData() {
    _currentUserId = null;
    _nftCollections.clear();
    _nftTokens.clear();
    _marketplaceListings.clear();
    _brandTokens.clear();
    _smartContracts.clear();
    notifyListeners();
  }

  /// Получение данных из кэша
  Map<String, dynamic>? getCachedNFTCollection(String id) => _nftCollections[id];
  Map<String, dynamic>? getCachedNFTToken(String id) => _nftTokens[id];
  Map<String, dynamic>? getCachedMarketplaceListing(String id) => _marketplaceListings[id];
  Map<String, dynamic>? getCachedBrandToken(String id) => _brandTokens[id];
  Map<String, dynamic>? getCachedSmartContract(String id) => _smartContracts[id];

  /// Установка состояния загрузки
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Установка ошибки
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Очистка ошибки
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Очистка ошибки (публичный метод)
  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}
