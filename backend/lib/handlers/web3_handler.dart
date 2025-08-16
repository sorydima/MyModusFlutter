import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:web3dart/web3dart.dart';
import '../services/web3_service.dart';

class Web3Handler {
  final Web3Service _web3Service;
  
  Web3Handler(this._web3Service);
  
  Router get router {
    final router = Router();
    
    // Создание кошелька
    router.post('/wallet/create', _createWallet);
    
    // Получение баланса
    router.get('/balance/<address>', _getBalance);
    
    // Создание escrow
    router.post('/escrow/create', _createEscrow);
    
    // Освобождение escrow
    router.post('/escrow/release', _releaseEscrow);
    
    // Минтинг токенов лояльности
    router.post('/tokens/mint', _mintLoyaltyTokens);
    
    // Минтинг NFT
    router.post('/nft/mint', _mintNFT);
    
    // Статус транзакции
    router.get('/transaction/<hash>/status', _getTransactionStatus);
    
    return router;
  }
  
  /// Создание кошелька
  Future<Response> _createWallet(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final mnemonic = data['mnemonic'] as String?;
      
      if (mnemonic == null || mnemonic.isEmpty) {
        return Response(400,
          body: jsonEncode({'error': 'Mnemonic is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final privateKey = await _web3Service.createWalletFromMnemonic(mnemonic);
      final address = privateKey.address;
      
      return Response.ok(
        jsonEncode({
          'message': 'Wallet created successfully',
          'address': address.hex,
          'private_key': privateKey.privateKey.toHex(), // В продакшене не возвращать!
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create wallet: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Получение баланса
  Future<Response> _getBalance(Request request, String address) async {
    try {
      final balance = await _web3Service.getBalance(
        EthereumAddress.fromHex(address),
      );
      
      return Response.ok(
        jsonEncode({
          'address': address,
          'balance_wei': balance.getInWei.toString(),
          'balance_ether': balance.getInEther.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get balance: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Создание escrow
  Future<Response> _createEscrow(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final buyerPrivateKey = data['buyer_private_key'] as String?;
      final productId = data['product_id'] as String?;
      final amount = data['amount'] as int?;
      final sellerId = data['seller_id'] as int?;
      
      if (buyerPrivateKey == null || productId == null || amount == null || sellerId == null) {
        return Response(400,
          body: jsonEncode({'error': 'All fields are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Создание приватного ключа из hex строки
      final privateKey = EthPrivateKey.fromHex(buyerPrivateKey);
      final etherAmount = EtherAmount.fromUnit(EtherUnit.wei, BigInt.from(amount));
      
      final txHash = await _web3Service.createEscrow(
        buyerKey: privateKey,
        productId: productId,
        amount: etherAmount,
        sellerId: sellerId,
      );
      
      return Response.ok(
        jsonEncode({
          'message': 'Escrow created successfully',
          'transaction_hash': txHash,
          'product_id': productId,
          'amount': amount,
          'seller_id': sellerId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create escrow: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Освобождение escrow
  Future<Response> _releaseEscrow(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final buyerPrivateKey = data['buyer_private_key'] as String?;
      final escrowId = data['escrow_id'] as String?;
      
      if (buyerPrivateKey == null || escrowId == null) {
        return Response(400,
          body: jsonEncode({'error': 'All fields are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final privateKey = EthPrivateKey.fromHex(buyerPrivateKey);
      
      final txHash = await _web3Service.releaseEscrow(
        buyerKey: privateKey,
        escrowId: escrowId,
      );
      
      return Response.ok(
        jsonEncode({
          'message': 'Escrow released successfully',
          'transaction_hash': txHash,
          'escrow_id': escrowId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to release escrow: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Минтинг токенов лояльности
  Future<Response> _mintLoyaltyTokens(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final ownerPrivateKey = data['owner_private_key'] as String?;
      final toAddress = data['to_address'] as String?;
      final amount = data['amount'] as int?;
      
      if (ownerPrivateKey == null || toAddress == null || amount == null) {
        return Response(400,
          body: jsonEncode({'error': 'All fields are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final privateKey = EthPrivateKey.fromHex(ownerPrivateKey);
      final address = EthereumAddress.fromHex(toAddress);
      
      final txHash = await _web3Service.mintLoyaltyTokens(
        ownerKey: privateKey,
        to: address,
        amount: BigInt.from(amount),
      );
      
      return Response.ok(
        jsonEncode({
          'message': 'Loyalty tokens minted successfully',
          'transaction_hash': txHash,
          'to_address': toAddress,
          'amount': amount,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to mint loyalty tokens: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Минтинг NFT
  Future<Response> _mintNFT(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final ownerPrivateKey = data['owner_private_key'] as String?;
      final toAddress = data['to_address'] as String?;
      final tokenURI = data['token_uri'] as String?;
      
      if (ownerPrivateKey == null || toAddress == null || tokenURI == null) {
        return Response(400,
          body: jsonEncode({'error': 'All fields are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final privateKey = EthPrivateKey.fromHex(ownerPrivateKey);
      final address = EthereumAddress.fromHex(toAddress);
      
      final txHash = await _web3Service.mintNFTBadge(
        ownerKey: privateKey,
        to: address,
        tokenURI: tokenURI,
      );
      
      return Response.ok(
        jsonEncode({
          'message': 'NFT minted successfully',
          'transaction_hash': txHash,
          'to_address': toAddress,
          'token_uri': tokenURI,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to mint NFT: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Получение статуса транзакции
  Future<Response> _getTransactionStatus(Request request, String hash) async {
    try {
      final status = await _web3Service.getTransactionStatus(hash);
      
      return Response.ok(
        jsonEncode({
          'transaction_hash': hash,
          'status': status,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get transaction status: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
