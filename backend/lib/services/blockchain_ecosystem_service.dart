import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../models.dart';
import 'notification_service.dart';

/// Сервис блокчейн-экосистемы приложения
class BlockchainEcosystemService {
  final NotificationService _notificationService;
  final Logger _logger = Logger();

  // NFT коллекции
  final Map<String, NFTCollection> _nftCollections = {};
  final Map<String, NFTToken> _nftTokens = {};

  // Торговая площадка
  final Map<String, MarketplaceListing> _marketplaceListings = {};
  final Map<String, MarketplaceOrder> _marketplaceOrders = {};

  // Верификация подлинности
  final Map<String, AuthenticityVerification> _verifications = {};
  final Map<String, BrandToken> _brandTokens = {};

  // Смарт-контракты
  final Map<String, SmartContract> _smartContracts = {};

  BlockchainEcosystemService({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;

  // ===== NFT КОЛЛЕКЦИИ =====
  
  /// Создание новой NFT коллекции
  Future<NFTCollection> createNFTCollection({
    required String name,
    required String description,
    required String creatorId,
    required String imageUrl,
    required int totalSupply,
    required double price,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    final collectionId = 'collection_${DateTime.now().millisecondsSinceEpoch}';
    
    final collection = NFTCollection(
      id: collectionId,
      name: name,
      description: description,
      creatorId: creatorId,
      imageUrl: imageUrl,
      totalSupply: totalSupply,
      currentSupply: 0,
      price: price,
      category: category,
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
      status: 'active',
    );

    _nftCollections[collectionId] = collection;
    
    _logger.i('Создана NFT коллекция: $name (ID: $collectionId)');
    
    // Уведомление о создании коллекции
    await _notificationService.sendNotification(
      userId: creatorId,
      title: 'NFT Коллекция создана',
      body: 'Коллекция "$name" успешно создана',
      type: 'nft_collection_created',
      data: {'collectionId': collectionId},
    );

    return collection;
  }

  /// Минтинг NFT токена
  Future<NFTToken> mintNFTToken({
    required String collectionId,
    required String ownerId,
    required String tokenName,
    required String tokenDescription,
    required String tokenImageUrl,
    Map<String, dynamic>? attributes,
  }) async {
    final collection = _nftCollections[collectionId];
    if (collection == null) {
      throw Exception('Коллекция не найдена');
    }

    if (collection.currentSupply >= collection.totalSupply) {
      throw Exception('Достигнут лимит токенов в коллекции');
    }

    final tokenId = 'token_${DateTime.now().millisecondsSinceEpoch}';
    
    final token = NFTToken(
      id: tokenId,
      collectionId: collectionId,
      ownerId: ownerId,
      name: tokenName,
      description: tokenDescription,
      imageUrl: tokenImageUrl,
      attributes: attributes ?? {},
      mintedAt: DateTime.now(),
      status: 'active',
      transactionHash: 'tx_${DateTime.now().millisecondsSinceEpoch}',
    );

    _nftTokens[tokenId] = token;
    collection.currentSupply++;
    
    _logger.i('Заминчен NFT токен: $tokenName (ID: $tokenId)');
    
    // Уведомление о минтинге
    await _notificationService.sendNotification(
      userId: ownerId,
      title: 'NFT Токен заминчен',
      body: 'Токен "$tokenName" успешно создан',
      type: 'nft_token_minted',
      data: {'tokenId': tokenId, 'collectionId': collectionId},
    );

    return token;
  }

  /// Получение NFT коллекций
  List<NFTCollection> getNFTCollections({
    String? category,
    String? creatorId,
    String? status,
  }) {
    var collections = _nftCollections.values.toList();
    
    if (category != null) {
      collections = collections.where((c) => c.category == category).toList();
    }
    
    if (creatorId != null) {
      collections = collections.where((c) => c.creatorId == creatorId).toList();
    }
    
    if (status != null) {
      collections = collections.where((c) => c.status == status).toList();
    }
    
    return collections;
  }

  /// Получение NFT токенов пользователя
  List<NFTToken> getUserNFTTokens(String userId) {
    return _nftTokens.values
        .where((token) => token.ownerId == userId)
        .toList();
  }

  // ===== ТОРГОВАЯ ПЛОЩАДКА =====
  
  /// Создание листинга на торговой площадке
  Future<MarketplaceListing> createMarketplaceListing({
    required String tokenId,
    required String sellerId,
    required double price,
    required String currency,
    String? description,
    Duration? duration,
  }) async {
    final token = _nftTokens[tokenId];
    if (token == null) {
      throw Exception('NFT токен не найден');
    }

    if (token.ownerId != sellerId) {
      throw Exception('Только владелец может выставить токен на продажу');
    }

    final listingId = 'listing_${DateTime.now().millisecondsSinceEpoch}';
    
    final listing = MarketplaceListing(
      id: listingId,
      tokenId: tokenId,
      sellerId: sellerId,
      price: price,
      currency: currency,
      description: description ?? '',
      createdAt: DateTime.now(),
      expiresAt: duration != null 
          ? DateTime.now().add(duration)
          : DateTime.now().add(const Duration(days: 30)),
      status: 'active',
    );

    _marketplaceListings[listingId] = listing;
    
    _logger.i('Создан листинг: ${token.name} за $price $currency');
    
    return listing;
  }

  /// Покупка NFT на торговой площадке
  Future<MarketplaceOrder> purchaseNFT({
    required String listingId,
    required String buyerId,
    required double amount,
  }) async {
    final listing = _marketplaceListings[listingId];
    if (listing == null) {
      throw Exception('Листинг не найден');
    }

    if (listing.status != 'active') {
      throw Exception('Листинг неактивен');
    }

    if (listing.expiresAt.isBefore(DateTime.now())) {
      throw Exception('Листинг истек');
    }

    if (amount < listing.price) {
      throw Exception('Недостаточно средств');
    }

    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    
    final order = MarketplaceOrder(
      id: orderId,
      listingId: listingId,
      buyerId: buyerId,
      sellerId: listing.sellerId,
      tokenId: listing.tokenId,
      amount: amount,
      currency: listing.currency,
      createdAt: DateTime.now(),
      status: 'completed',
      transactionHash: 'tx_${DateTime.now().millisecondsSinceEpoch}',
    );

    _marketplaceOrders[orderId] = listing;
    
    // Обновление владельца токена
    final token = _nftTokens[listing.tokenId];
    if (token != null) {
      token.ownerId = buyerId;
    }
    
    // Деактивация листинга
    listing.status = 'sold';
    
    _logger.i('NFT продан: ${token?.name} за $amount ${listing.currency}');
    
    // Уведомления
    await Future.wait([
      _notificationService.sendNotification(
        userId: buyerId,
        title: 'NFT Куплен',
        body: 'Вы успешно приобрели ${token?.name}',
        type: 'nft_purchased',
        data: {'tokenId': listing.tokenId, 'orderId': orderId},
      ),
      _notificationService.sendNotification(
        userId: listing.sellerId,
        title: 'NFT Продан',
        body: 'Ваш ${token?.name} успешно продан',
        type: 'nft_sold',
        data: {'tokenId': listing.tokenId, 'orderId': orderId},
      ),
    ]);
    
    return order;
  }

  /// Получение активных листингов
  List<MarketplaceListing> getActiveListings({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? currency,
  }) {
    var listings = _marketplaceListings.values
        .where((l) => l.status == 'active')
        .toList();
    
    if (minPrice != null) {
      listings = listings.where((l) => l.price >= minPrice).toList();
    }
    
    if (maxPrice != null) {
      listings = listings.where((l) => l.price <= maxPrice).toList();
    }
    
    if (currency != null) {
      listings = listings.where((l) => l.currency == currency).toList();
    }
    
    return listings;
  }

  // ===== ВЕРИФИКАЦИЯ ПОДЛИННОСТИ =====
  
  /// Создание верификации подлинности
  Future<AuthenticityVerification> createAuthenticityVerification({
    required String productId,
    required String brandId,
    required String verificationType,
    required Map<String, dynamic> verificationData,
    String? description,
  }) async {
    final verificationId = 'verification_${DateTime.now().millisecondsSinceEpoch}';
    
    final verification = AuthenticityVerification(
      id: verificationId,
      productId: productId,
      brandId: brandId,
      verificationType: verificationType,
      verificationData: verificationData,
      description: description ?? '',
      createdAt: DateTime.now(),
      status: 'pending',
      verifiedAt: null,
    );

    _verifications[verificationId] = verification;
    
    _logger.i('Создана верификация: $verificationType для продукта $productId');
    
    return verification;
  }

  /// Подтверждение верификации
  Future<void> approveVerification({
    required String verificationId,
    required String approverId,
    String? notes,
  }) async {
    final verification = _verifications[verificationId];
    if (verification == null) {
      throw Exception('Верификация не найдена');
    }

    verification.status = 'approved';
    verification.verifiedAt = DateTime.now();
    verification.verificationData['approverId'] = approverId;
    verification.verificationData['notes'] = notes;
    
    _logger.i('Верификация подтверждена: $verificationId');
  }

  /// Получение верификаций бренда
  List<AuthenticityVerification> getBrandVerifications(String brandId) {
    return _verifications.values
        .where((v) => v.brandId == brandId)
        .toList();
  }

  // ===== ТОКЕНИЗАЦИЯ БРЕНДОВ =====
  
  /// Создание токена бренда
  Future<BrandToken> createBrandToken({
    required String brandId,
    required String brandName,
    required String symbol,
    required int totalSupply,
    required double initialPrice,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final tokenId = 'brand_${DateTime.now().millisecondsSinceEpoch}';
    
    final token = BrandToken(
      id: tokenId,
      brandId: brandId,
      brandName: brandName,
      symbol: symbol,
      totalSupply: totalSupply,
      currentSupply: 0,
      initialPrice: initialPrice,
      currentPrice: initialPrice,
      description: description,
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
      status: 'active',
    );

    _brandTokens[tokenId] = token;
    
    _logger.i('Создан токен бренда: $brandName ($symbol)');
    
    return token;
  }

  /// Минтинг токенов бренда
  Future<void> mintBrandTokens({
    required String brandTokenId,
    required int amount,
    required String recipientId,
  }) async {
    final token = _brandTokens[brandTokenId];
    if (token == null) {
      throw Exception('Токен бренда не найден');
    }

    if (token.currentSupply + amount > token.totalSupply) {
      throw Exception('Превышен лимит токенов');
    }

    token.currentSupply += amount;
    
    _logger.i('Заминчено $amount токенов бренда ${token.brandName}');
  }

  /// Получение токенов брендов
  List<BrandToken> getBrandTokens({String? status}) {
    var tokens = _brandTokens.values.toList();
    
    if (status != null) {
      tokens = tokens.where((t) => t.status == status).toList();
    }
    
    return tokens;
  }

  // ===== СМАРТ-КОНТРАКТЫ =====
  
  /// Создание смарт-контракта
  Future<SmartContract> createSmartContract({
    required String name,
    required String type,
    required String creatorId,
    required Map<String, dynamic> contractData,
    String? description,
  }) async {
    final contractId = 'contract_${DateTime.now().millisecondsSinceEpoch}';
    
    final contract = SmartContract(
      id: contractId,
      name: name,
      type: type,
      creatorId: creatorId,
      contractData: contractData,
      description: description ?? '',
      createdAt: DateTime.now(),
      deployedAt: null,
      status: 'draft',
      address: null,
      abi: null,
    );

    _smartContracts[contractId] = contract;
    
    _logger.i('Создан смарт-контракт: $name ($type)');
    
    return contract;
  }

  /// Деплой смарт-контракта
  Future<void> deploySmartContract({
    required String contractId,
    required String address,
    required Map<String, dynamic> abi,
  }) async {
    final contract = _smartContracts[contractId];
    if (contract == null) {
      throw Exception('Смарт-контракт не найден');
    }

    contract.status = 'deployed';
    contract.deployedAt = DateTime.now();
    contract.address = address;
    contract.abi = abi;
    
    _logger.i('Деплоен смарт-контракт: ${contract.name} по адресу $address');
  }

  /// Получение смарт-контрактов
  List<SmartContract> getSmartContracts({String? type, String? status}) {
    var contracts = _smartContracts.values.toList();
    
    if (type != null) {
      contracts = contracts.where((c) => c.type == type).toList();
    }
    
    if (status != null) {
      contracts = contracts.where((c) => c.status == status).toList();
    }
    
    return contracts;
  }

  // ===== АНАЛИТИКА И СТАТИСТИКА =====
  
  /// Получение статистики блокчейн-экосистемы
  Map<String, dynamic> getEcosystemStats() {
    final totalCollections = _nftCollections.length;
    final totalTokens = _nftTokens.length;
    final totalListings = _marketplaceListings.values
        .where((l) => l.status == 'active')
        .length;
    final totalOrders = _marketplaceOrders.length;
    final totalVerifications = _verifications.length;
    final totalBrandTokens = _brandTokens.length;
    final totalContracts = _smartContracts.length;

    final totalVolume = _marketplaceOrders.values
        .where((o) => o.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.amount);

    return {
      'collections': totalCollections,
      'tokens': totalTokens,
      'activeListings': totalListings,
      'orders': totalOrders,
      'verifications': totalVerifications,
      'brandTokens': totalBrandTokens,
      'smartContracts': totalContracts,
      'totalVolume': totalVolume,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Получение истории транзакций пользователя
  List<Map<String, dynamic>> getUserTransactionHistory(String userId) {
    final transactions = <Map<String, dynamic>>[];

    // NFT транзакции
    final userTokens = _nftTokens.values
        .where((t) => t.ownerId == userId)
        .map((t) => {
          'type': 'nft_mint',
          'id': t.id,
          'timestamp': t.mintedAt,
          'details': {
            'tokenName': t.name,
            'collectionId': t.collectionId,
          },
        })
        .toList();
    transactions.addAll(userTokens);

    // Торговые транзакции
    final userOrders = _marketplaceOrders.values
        .where((o) => o.buyerId == userId || o.sellerId == userId)
        .map((o) => {
          'type': o.buyerId == userId ? 'nft_purchase' : 'nft_sale',
          'id': o.id,
          'timestamp': o.createdAt,
          'details': {
            'amount': o.amount,
            'currency': o.currency,
            'tokenId': o.tokenId,
          },
        })
        .toList();
    transactions.addAll(userOrders);

    // Сортировка по времени
    transactions.sort((a, b) => 
        (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    return transactions;
  }

  // ===== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ =====
  
  /// Очистка старых данных
  void cleanupOldData() {
    final now = DateTime.now();
    
    // Удаление истекших листингов
    _marketplaceListings.removeWhere((key, listing) {
      if (listing.expiresAt.isBefore(now) && listing.status == 'active') {
        listing.status = 'expired';
        return false;
      }
      return false;
    });
    
    _logger.i('Очистка старых данных завершена');
  }

  /// Проверка состояния экосистемы
  Map<String, dynamic> checkEcosystemHealth() {
    final issues = <String>[];
    
    // Проверка NFT коллекций
    final inactiveCollections = _nftCollections.values
        .where((c) => c.status != 'active')
        .length;
    if (inactiveCollections > 0) {
      issues.add('$inactiveCollections неактивных NFT коллекций');
    }
    
    // Проверка торговой площадки
    final expiredListings = _marketplaceListings.values
        .where((l) => l.expiresAt.isBefore(DateTime.now()) && l.status == 'active')
        .length;
    if (expiredListings > 0) {
      issues.add('$expiredListings истекших листингов');
    }
    
    // Проверка смарт-контрактов
    final draftContracts = _smartContracts.values
        .where((c) => c.status == 'draft')
        .length;
    if (draftContracts > 0) {
      issues.add('$draftContracts черновиков смарт-контрактов');
    }
    
    return {
      'status': issues.isEmpty ? 'healthy' : 'issues_detected',
      'issues': issues,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

// ===== МОДЕЛИ ДАННЫХ =====

class NFTCollection {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String imageUrl;
  final int totalSupply;
  int currentSupply;
  final double price;
  final String category;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  String status;

  NFTCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.imageUrl,
    required this.totalSupply,
    required this.currentSupply,
    required this.price,
    required this.category,
    required this.metadata,
    required this.createdAt,
    required this.status,
  });
}

class NFTToken {
  final String id;
  final String collectionId;
  String ownerId;
  final String name;
  final String description;
  final String imageUrl;
  final Map<String, dynamic> attributes;
  final DateTime mintedAt;
  String status;
  final String transactionHash;

  NFTToken({
    required this.id,
    required this.collectionId,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.attributes,
    required this.mintedAt,
    required this.status,
    required this.transactionHash,
  });
}

class MarketplaceListing {
  final String id;
  final String tokenId;
  final String sellerId;
  final double price;
  final String currency;
  final String description;
  final DateTime createdAt;
  final DateTime expiresAt;
  String status;

  MarketplaceListing({
    required this.id,
    required this.tokenId,
    required this.sellerId,
    required this.price,
    required this.currency,
    required this.description,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });
}

class MarketplaceOrder {
  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final String tokenId;
  final double amount;
  final String currency;
  final DateTime createdAt;
  String status;
  final String transactionHash;

  MarketplaceOrder({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.tokenId,
    required this.amount,
    required this.currency,
    required this.createdAt,
    required this.status,
    required this.transactionHash,
  });
}

class AuthenticityVerification {
  final String id;
  final String productId;
  final String brandId;
  final String verificationType;
  final Map<String, dynamic> verificationData;
  final String description;
  final DateTime createdAt;
  String status;
  DateTime? verifiedAt;

  AuthenticityVerification({
    required this.id,
    required this.productId,
    required this.brandId,
    required this.verificationType,
    required this.verificationData,
    required this.description,
    required this.createdAt,
    required this.status,
    this.verifiedAt,
  });
}

class BrandToken {
  final String id;
  final String brandId;
  final String brandName;
  final String symbol;
  final int totalSupply;
  int currentSupply;
  final double initialPrice;
  double currentPrice;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  String status;

  BrandToken({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.symbol,
    required this.totalSupply,
    required this.currentSupply,
    required this.initialPrice,
    required this.currentPrice,
    required this.description,
    required this.metadata,
    required this.createdAt,
    required this.status,
  });
}

class SmartContract {
  final String id;
  final String name;
  final String type;
  final String creatorId;
  final Map<String, dynamic> contractData;
  final String description;
  final DateTime createdAt;
  DateTime? deployedAt;
  String status;
  String? address;
  Map<String, dynamic>? abi;

  SmartContract({
    required this.id,
    required this.name,
    required this.type,
    required this.creatorId,
    required this.contractData,
    required this.description,
    required this.createdAt,
    this.deployedAt,
    required this.status,
    this.address,
    this.abi,
  });
}
