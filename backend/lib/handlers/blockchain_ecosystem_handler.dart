import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/blockchain_ecosystem_service.dart';
import '../database.dart';

/// API Handler для блокчейн-экосистемы приложения
class BlockchainEcosystemHandler {
  final BlockchainEcosystemService _blockchainService;
  final DatabaseService _database;

  BlockchainEcosystemHandler({
    required BlockchainEcosystemService blockchainService,
    required DatabaseService database,
  })  : _blockchainService = blockchainService,
        _database = database;

  Router get router {
    final router = Router();

    // ===== NFT КОЛЛЕКЦИИ =====
    router.post('/nft/collections', _createNFTCollection);
    router.get('/nft/collections', _getNFTCollections);
    router.get('/nft/collections/<collectionId>', _getNFTCollection);
    router.put('/nft/collections/<collectionId>', _updateNFTCollection);
    router.delete('/nft/collections/<collectionId>', _deleteNFTCollection);

    // ===== NFT ТОКЕНЫ =====
    router.post('/nft/tokens/mint', _mintNFTToken);
    router.get('/nft/tokens/user/<userId>', _getUserNFTTokens);
    router.get('/nft/tokens/<tokenId>', _getNFTToken);
    router.put('/nft/tokens/<tokenId>', _updateNFTToken);
    router.delete('/nft/tokens/<tokenId>', _deleteNFTToken);

    // ===== ТОРГОВАЯ ПЛОЩАДКА =====
    router.post('/marketplace/listings', _createMarketplaceListing);
    router.get('/marketplace/listings', _getActiveListings);
    router.get('/marketplace/listings/<listingId>', _getMarketplaceListing);
    router.put('/marketplace/listings/<listingId>', _updateMarketplaceListing);
    router.delete('/marketplace/listings/<listingId>', _deleteMarketplaceListing);

    // ===== ПОКУПКИ И ПРОДАЖИ =====
    router.post('/marketplace/purchase', _purchaseNFT);
    router.get('/marketplace/orders/user/<userId>', _getUserOrders);
    router.get('/marketplace/orders/<orderId>', _getMarketplaceOrder);

    // ===== ВЕРИФИКАЦИЯ ПОДЛИННОСТИ =====
    router.post('/verification/authenticity', _createAuthenticityVerification);
    router.put('/verification/authenticity/<verificationId>/approve', _approveVerification);
    router.get('/verification/authenticity/brand/<brandId>', _getBrandVerifications);
    router.get('/verification/authenticity/<verificationId>', _getVerification);

    // ===== ТОКЕНИЗАЦИЯ БРЕНДОВ =====
    router.post('/brands/tokens', _createBrandToken);
    router.post('/brands/tokens/<tokenId>/mint', _mintBrandTokens);
    router.get('/brands/tokens', _getBrandTokens);
    router.get('/brands/tokens/<tokenId>', _getBrandToken);
    router.put('/brands/tokens/<tokenId>', _updateBrandToken);

    // ===== СМАРТ-КОНТРАКТЫ =====
    router.post('/smart-contracts', _createSmartContract);
    router.post('/smart-contracts/<contractId>/deploy', _deploySmartContract);
    router.get('/smart-contracts', _getSmartContracts);
    router.get('/smart-contracts/<contractId>', _getSmartContract);
    router.put('/smart-contracts/<contractId>', _updateSmartContract);

    // ===== АНАЛИТИКА И СТАТИСТИКА =====
    router.get('/analytics/ecosystem-stats', _getEcosystemStats);
    router.get('/analytics/user-transactions/<userId>', _getUserTransactionHistory);
    router.get('/analytics/ecosystem-health', _checkEcosystemHealth);

    // ===== ДЕМО И ТЕСТИРОВАНИЕ =====
    router.post('/demo/create-sample-data', _createSampleData);
    router.post('/demo/simulate-nft-trade', _simulateNFTTrade);
    router.post('/demo/simulate-verification', _simulateVerification);

    return router;
  }

  // ===== NFT КОЛЛЕКЦИИ =====

  Future<Response> _createNFTCollection(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final collection = await _blockchainService.createNFTCollection(
        name: data['name'],
        description: data['description'],
        creatorId: data['creatorId'],
        imageUrl: data['imageUrl'],
        totalSupply: data['totalSupply'],
        price: data['price'].toDouble(),
        category: data['category'],
        metadata: data['metadata'],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': collection.id,
            'name': collection.name,
            'description': collection.description,
            'creatorId': collection.creatorId,
            'imageUrl': collection.imageUrl,
            'totalSupply': collection.totalSupply,
            'currentSupply': collection.currentSupply,
            'price': collection.price,
            'category': collection.category,
            'metadata': collection.metadata,
            'createdAt': collection.createdAt.toIso8601String(),
            'status': collection.status,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getNFTCollections(Request request) async {
    try {
      final category = request.url.queryParameters['category'];
      final creatorId = request.url.queryParameters['creatorId'];
      final status = request.url.queryParameters['status'];

      final collections = _blockchainService.getNFTCollections(
        category: category,
        creatorId: creatorId,
        status: status,
      );

      final collectionsData = collections.map((c) => {
        'id': c.id,
        'name': c.name,
        'description': c.description,
        'creatorId': c.creatorId,
        'imageUrl': c.imageUrl,
        'totalSupply': c.totalSupply,
        'currentSupply': c.currentSupply,
        'price': c.price,
        'category': c.category,
        'metadata': c.metadata,
        'createdAt': c.createdAt.toIso8601String(),
        'status': c.status,
      }).toList();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': collectionsData,
          'count': collectionsData.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getNFTCollection(Request request) async {
    try {
      final collectionId = request.params['collectionId'];
      final collections = _blockchainService.getNFTCollections();
      final collection = collections.firstWhere(
        (c) => c.id == collectionId,
        orElse: () => throw Exception('Коллекция не найдена'),
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': collection.id,
            'name': collection.name,
            'description': collection.description,
            'creatorId': collection.creatorId,
            'imageUrl': collection.imageUrl,
            'totalSupply': collection.totalSupply,
            'currentSupply': collection.currentSupply,
            'price': collection.price,
            'category': collection.category,
            'metadata': collection.metadata,
            'createdAt': collection.createdAt.toIso8601String(),
            'status': collection.status,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.notFound(
        jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _updateNFTCollection(Request request) async {
    try {
      final collectionId = request.params['collectionId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // В реальной реализации здесь была бы логика обновления
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Коллекция обновлена',
          'collectionId': collectionId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteNFTCollection(Request request) async {
    try {
      final collectionId = request.params['collectionId'];

      // В реальной реализации здесь была бы логика удаления
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Коллекция удалена',
          'collectionId': collectionId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== NFT ТОКЕНЫ =====

  Future<Response> _mintNFTToken(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final token = await _blockchainService.mintNFTToken(
        collectionId: data['collectionId'],
        ownerId: data['ownerId'],
        tokenName: data['tokenName'],
        tokenDescription: data['tokenDescription'],
        tokenImageUrl: data['tokenImageUrl'],
        attributes: data['attributes'],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': token.id,
            'collectionId': token.collectionId,
            'ownerId': token.ownerId,
            'name': token.name,
            'description': token.description,
            'imageUrl': token.imageUrl,
            'attributes': token.attributes,
            'mintedAt': token.mintedAt.toIso8601String(),
            'status': token.status,
            'transactionHash': token.transactionHash,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getUserNFTTokens(Request request) async {
    try {
      final userId = request.params['userId'];
      final tokens = _blockchainService.getUserNFTTokens(userId);

      final tokensData = tokens.map((t) => {
        'id': t.id,
        'collectionId': t.collectionId,
        'ownerId': t.ownerId,
        'name': t.name,
        'description': t.description,
        'imageUrl': t.imageUrl,
        'attributes': t.attributes,
        'mintedAt': t.mintedAt.toIso8601String(),
        'status': t.status,
        'transactionHash': t.transactionHash,
      }).toList();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': tokensData,
          'count': tokensData.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getNFTToken(Request request) async {
    try {
      final tokenId = request.params['tokenId'];
      final tokens = _blockchainService.getUserNFTTokens('any'); // Временное решение
      final token = tokens.firstWhere(
        (t) => t.id == tokenId,
        orElse: () => throw Exception('Токен не найден'),
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': token.id,
            'collectionId': token.collectionId,
            'ownerId': token.ownerId,
            'name': token.name,
            'description': token.description,
            'imageUrl': token.imageUrl,
            'attributes': token.attributes,
            'mintedAt': token.mintedAt.toIso8601String(),
            'status': token.status,
            'transactionHash': token.transactionHash,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.notFound(
        jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _updateNFTToken(Request request) async {
    try {
      final tokenId = request.params['tokenId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Токен обновлен',
          'tokenId': tokenId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteNFTToken(Request request) async {
    try {
      final tokenId = request.params['tokenId'];

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Токен удален',
          'tokenId': tokenId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== ТОРГОВАЯ ПЛОЩАДКА =====

  Future<Response> _createMarketplaceListing(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final listing = await _blockchainService.createMarketplaceListing(
        tokenId: data['tokenId'],
        sellerId: data['sellerId'],
        price: data['price'].toDouble(),
        currency: data['currency'],
        description: data['description'],
        duration: data['duration'] != null 
            ? Duration(days: data['duration'])
            : null,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': listing.id,
            'tokenId': listing.tokenId,
            'sellerId': listing.sellerId,
            'price': listing.price,
            'currency': listing.currency,
            'description': listing.description,
            'createdAt': listing.createdAt.toIso8601String(),
            'expiresAt': listing.expiresAt.toIso8601String(),
            'status': listing.status,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getActiveListings(Request request) async {
    try {
      final category = request.url.queryParameters['category'];
      final minPrice = request.url.queryParameters['minPrice'] != null 
          ? double.parse(request.url.queryParameters['minPrice']!)
          : null;
      final maxPrice = request.url.queryParameters['maxPrice'] != null 
          ? double.parse(request.url.queryParameters['maxPrice']!)
          : null;
      final currency = request.url.queryParameters['currency'];

      final listings = _blockchainService.getActiveListings(
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        currency: currency,
      );

      final listingsData = listings.map((l) => {
        'id': l.id,
        'tokenId': l.tokenId,
        'sellerId': l.sellerId,
        'price': l.price,
        'currency': l.currency,
        'description': l.description,
        'createdAt': l.createdAt.toIso8601String(),
        'expiresAt': l.expiresAt.toIso8601String(),
        'status': l.status,
      }).toList();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': listingsData,
          'count': listingsData.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getMarketplaceListing(Request request) async {
    try {
      final listingId = request.params['listingId'];
      
      // В реальной реализации здесь была бы логика получения листинга
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Листинг получен',
          'listingId': listingId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.notFound(
        jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _updateMarketplaceListing(Request request) async {
    try {
      final listingId = request.params['listingId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Листинг обновлен',
          'listingId': listingId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteMarketplaceListing(Request request) async {
    try {
      final listingId = request.params['listingId'];

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Листинг удален',
          'listingId': listingId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== ПОКУПКИ И ПРОДАЖИ =====

  Future<Response> _purchaseNFT(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final order = await _blockchainService.purchaseNFT(
        listingId: data['listingId'],
        buyerId: data['buyerId'],
        amount: data['amount'].toDouble(),
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': order.id,
            'listingId': order.listingId,
            'buyerId': order.buyerId,
            'sellerId': order.sellerId,
            'tokenId': order.tokenId,
            'amount': order.amount,
            'currency': order.currency,
            'createdAt': order.createdAt.toIso8601String(),
            'status': order.status,
            'transactionHash': order.transactionHash,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getUserOrders(Request request) async {
    try {
      final userId = request.params['userId'];
      
      // В реальной реализации здесь была бы логика получения заказов
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Заказы пользователя получены',
          'userId': userId,
          'data': [],
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getMarketplaceOrder(Request request) async {
    try {
      final orderId = request.params['orderId'];
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Заказ получен',
          'orderId': orderId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.notFound(
        jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== ВЕРИФИКАЦИЯ ПОДЛИННОСТИ =====

  Future<Response> _createAuthenticityVerification(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final verification = await _blockchainService.createAuthenticityVerification(
        productId: data['productId'],
        brandId: data['brandId'],
        verificationType: data['verificationType'],
        verificationData: data['verificationData'],
        description: data['description'],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': verification.id,
            'productId': verification.productId,
            'brandId': verification.brandId,
            'verificationType': verification.verificationType,
            'verificationData': verification.verificationData,
            'description': verification.description,
            'createdAt': verification.createdAt.toIso8601String(),
            'status': verification.status,
            'verifiedAt': verification.verifiedAt?.toIso8601String(),
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _approveVerification(Request request) async {
    try {
      final verificationId = request.params['verificationId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      await _blockchainService.approveVerification(
        verificationId: verificationId,
        approverId: data['approverId'],
        notes: data['notes'],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Верификация подтверждена',
          'verificationId': verificationId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getBrandVerifications(Request request) async {
    try {
      final brandId = request.params['brandId'];
      final verifications = _blockchainService.getBrandVerifications(brandId);

      final verificationsData = verifications.map((v) => {
        'id': v.id,
        'productId': v.productId,
        'brandId': v.brandId,
        'verificationType': v.verificationType,
        'verificationData': v.verificationData,
        'description': v.description,
        'createdAt': v.createdAt.toIso8601String(),
        'status': v.status,
        'verifiedAt': v.verifiedAt?.toIso8601String(),
      }).toList();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': verificationsData,
          'count': verificationsData.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getVerification(Request request) async {
    try {
      final verificationId = request.params['verificationId'];
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Верификация получена',
          'verificationId': verificationId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.notFound(
        jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== ТОКЕНИЗАЦИЯ БРЕНДОВ =====

  Future<Response> _createBrandToken(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final token = await _blockchainService.createBrandToken(
        brandId: data['brandId'],
        brandName: data['brandName'],
        symbol: data['symbol'],
        totalSupply: data['totalSupply'],
        initialPrice: data['initialPrice'].toDouble(),
        description: data['description'],
        metadata: data['metadata'],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': token.id,
            'brandId': token.brandId,
            'brandName': token.brandName,
            'symbol': token.symbol,
            'totalSupply': token.totalSupply,
            'currentSupply': token.currentSupply,
            'initialPrice': token.initialPrice,
            'currentPrice': token.currentPrice,
            'description': token.description,
            'metadata': token.metadata,
            'createdAt': token.createdAt.toIso8601String(),
            'status': token.status,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _mintBrandTokens(Request request) async {
    try {
      final brandTokenId = request.params['tokenId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      await _blockchainService.mintBrandTokens(
        brandTokenId: brandTokenId,
        amount: data['amount'],
        recipientId: data['recipientId'],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Токены бренда заминчены',
          'brandTokenId': brandTokenId,
          'amount': data['amount'],
          'recipientId': data['recipientId'],
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getBrandTokens(Request request) async {
    try {
      final status = request.url.queryParameters['status'];
      final tokens = _blockchainService.getBrandTokens(status: status);

      final tokensData = tokens.map((t) => {
        'id': t.id,
        'brandId': t.brandId,
        'brandName': t.brandName,
        'symbol': t.symbol,
        'totalSupply': t.totalSupply,
        'currentSupply': t.currentSupply,
        'initialPrice': t.initialPrice,
        'currentPrice': t.currentPrice,
        'description': t.description,
        'metadata': t.metadata,
        'createdAt': t.createdAt.toIso8601String(),
        'status': t.status,
      }).toList();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': tokensData,
          'count': tokensData.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getBrandToken(Request request) async {
    try {
      final tokenId = request.params['tokenId'];
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Токен бренда получен',
          'tokenId': tokenId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.notFound(
        jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _updateBrandToken(Request request) async {
    try {
      final tokenId = request.params['tokenId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Токен бренда обновлен',
          'tokenId': tokenId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== СМАРТ-КОНТРАКТЫ =====

  Future<Response> _createSmartContract(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final contract = await _blockchainService.createSmartContract(
        name: data['name'],
        type: data['type'],
        creatorId: data['creatorId'],
        contractData: data['contractData'],
        description: data['description'],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': contract.id,
            'name': contract.name,
            'type': contract.type,
            'creatorId': contract.creatorId,
            'contractData': contract.contractData,
            'description': contract.description,
            'createdAt': contract.createdAt.toIso8601String(),
            'deployedAt': contract.deployedAt?.toIso8601String(),
            'status': contract.status,
            'address': contract.address,
            'abi': contract.abi,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _deploySmartContract(Request request) async {
    try {
      final contractId = request.params['contractId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      await _blockchainService.deploySmartContract(
        contractId: contractId,
        address: data['address'],
        abi: data['abi'],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Смарт-контракт деплоен',
          'contractId': contractId,
          'address': data['address'],
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getSmartContracts(Request request) async {
    try {
      final type = request.url.queryParameters['type'];
      final status = request.url.queryParameters['status'];
      final contracts = _blockchainService.getSmartContracts(type: type, status: status);

      final contractsData = contracts.map((c) => {
        'id': c.id,
        'name': c.name,
        'type': c.type,
        'creatorId': c.creatorId,
        'contractData': c.contractData,
        'description': c.description,
        'createdAt': c.createdAt.toIso8601String(),
        'deployedAt': c.deployedAt?.toIso8601String(),
        'status': c.status,
        'address': c.address,
        'abi': c.abi,
      }).toList();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': contractsData,
          'count': contractsData.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getSmartContract(Request request) async {
    try {
      final contractId = request.params['contractId'];
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Смарт-контракт получен',
          'contractId': contractId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.notFound(
        jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _updateSmartContract(Request request) async {
    try {
      final contractId = request.params['contractId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Смарт-контракт обновлен',
          'contractId': contractId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== АНАЛИТИКА И СТАТИСТИКА =====

  Future<Response> _getEcosystemStats(Request request) async {
    try {
      final stats = _blockchainService.getEcosystemStats();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': stats,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getUserTransactionHistory(Request request) async {
    try {
      final userId = request.params['userId'];
      final transactions = _blockchainService.getUserTransactionHistory(userId);

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': transactions,
          'count': transactions.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _checkEcosystemHealth(Request request) async {
    try {
      final health = _blockchainService.checkEcosystemHealth();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': health,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== ДЕМО И ТЕСТИРОВАНИЕ =====

  Future<Response> _createSampleData(Request request) async {
    try {
      // Создание демо-данных для тестирования
      final userId = 'demo_user_${DateTime.now().millisecondsSinceEpoch}';
      
      // Создание NFT коллекции
      final collection = await _blockchainService.createNFTCollection(
        name: 'Демо Коллекция',
        description: 'Коллекция для демонстрации возможностей',
        creatorId: userId,
        imageUrl: 'https://example.com/demo.jpg',
        totalSupply: 100,
        price: 0.1,
        category: 'fashion',
        metadata: {'demo': true},
      );

      // Минтинг NFT токена
      final token = await _blockchainService.mintNFTToken(
        collectionId: collection.id,
        ownerId: userId,
        tokenName: 'Демо Токен #1',
        tokenDescription: 'Первый токен в демо коллекции',
        tokenImageUrl: 'https://example.com/token1.jpg',
        attributes: {'rarity': 'common', 'demo': true},
      );

      // Создание листинга
      final listing = await _blockchainService.createMarketplaceListing(
        tokenId: token.id,
        sellerId: userId,
        price: 0.15,
        currency: 'ETH',
        description: 'Продаю демо токен',
      );

      // Создание токена бренда
      final brandToken = await _blockchainService.createBrandToken(
        brandId: 'demo_brand',
        brandName: 'Демо Бренд',
        symbol: 'DEMO',
        totalSupply: 1000000,
        initialPrice: 0.01,
        description: 'Демо токен бренда',
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Демо-данные созданы',
          'data': {
            'collection': {
              'id': collection.id,
              'name': collection.name,
            },
            'token': {
              'id': token.id,
              'name': token.name,
            },
            'listing': {
              'id': listing.id,
              'price': listing.price,
            },
            'brandToken': {
              'id': brandToken.id,
              'symbol': brandToken.symbol,
            },
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _simulateNFTTrade(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final buyerId = data['buyerId'] ?? 'demo_buyer_${DateTime.now().millisecondsSinceEpoch}';
      final listingId = data['listingId'];

      if (listingId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'listingId обязателен',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final order = await _blockchainService.purchaseNFT(
        listingId: listingId,
        buyerId: buyerId,
        amount: 0.2, // Демо сумма
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Демо-торговля NFT завершена',
          'data': {
            'orderId': order.id,
            'buyerId': order.buyerId,
            'amount': order.amount,
            'currency': order.currency,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _simulateVerification(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final verification = await _blockchainService.createAuthenticityVerification(
        productId: data['productId'] ?? 'demo_product_${DateTime.now().millisecondsSinceEpoch}',
        brandId: data['brandId'] ?? 'demo_brand',
        verificationType: data['verificationType'] ?? 'blockchain',
        verificationData: data['verificationData'] ?? {'demo': true, 'timestamp': DateTime.now().toIso8601String()},
        description: data['description'] ?? 'Демо-верификация подлинности',
      );

      // Автоматическое подтверждение для демо
      await _blockchainService.approveVerification(
        verificationId: verification.id,
        approverId: 'demo_approver',
        notes: 'Автоматическое подтверждение для демо',
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Демо-верификация создана и подтверждена',
          'data': {
            'verificationId': verification.id,
            'status': 'approved',
            'verifiedAt': verification.verifiedAt?.toIso8601String(),
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
