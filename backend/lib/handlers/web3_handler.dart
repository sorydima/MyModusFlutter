import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/web3_service.dart';
import '../database.dart';

class Web3Handler {
  final Web3Service _web3Service;
  final DatabaseService _database;

  Web3Handler(this._web3Service, this._database);

  Router get router {
    final router = Router();

    // NFT операции
    router.post('/nfts/mint', _mintNFT);
    router.get('/nfts', _getNFTs);
    router.get('/nfts/<id>', _getNFT);
    router.get('/users/<userId>/nfts', _getUserNFTs);
    
    // Лояльность токены
    router.post('/loyalty/create', _createLoyaltyToken);
    router.post('/loyalty/transfer', _transferLoyaltyTokens);
    router.get('/loyalty/balance/<userId>', _getLoyaltyTokenBalance);
    
    // IPFS
    router.post('/ipfs/upload', _uploadToIPFS);
    router.get('/ipfs/<hash>', _getFromIPFS);
    
    // Кошельки
    router.post('/wallets/connect', _connectWallet);
    router.get('/wallets/<userId>', _getUserWallets);
    router.put('/wallets/set-primary', _setPrimaryWallet);
    
    // Смарт-контракты
    router.get('/contracts', _getSmartContracts);
    router.get('/contracts/<address>', _getSmartContract);
    
    // Блокчейн транзакции
    router.get('/transactions', _getTransactions);
    router.get('/transactions/<hash>', _getTransaction);
    
    // Статистика Web3
    router.get('/stats', _getWeb3Stats);

    return router;
  }

  Future<Response> _mintNFT(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final name = data['name'];
      final description = data['description'];
      final imageUrl = data['imageUrl'];
      final metadata = data['metadata'];

      if (userId == null || name == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID and name are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _web3Service.mintNFT(
        userId: userId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        metadata: metadata,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'NFT minted successfully',
            'nft': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to mint NFT',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
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

  Future<Response> _getNFTs(Request request) async {
    try {
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT n.*, u.name as owner_name, u.avatar_url as owner_avatar
        FROM nfts n
        LEFT JOIN users u ON n.owner_id = u.id
        ORDER BY n.created_at DESC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query('SELECT COUNT(*) as total FROM nfts');
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'nfts': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
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

  Future<Response> _getNFT(Request request) async {
    try {
      final nftId = request.params['id'];
      if (nftId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'NFT ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _database.query(
        '''
        SELECT n.*, u.name as owner_name, u.avatar_url as owner_avatar
        FROM nfts n
        LEFT JOIN users u ON n.owner_id = u.id
        WHERE n.id = @id
        ''',
        substitutionValues: {'id': nftId},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'NFT not found',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'nft': result.first,
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

  Future<Response> _getUserNFTs(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT n.*, u.name as owner_name, u.avatar_url as owner_avatar
        FROM nfts n
        LEFT JOIN users u ON n.owner_id = u.id
        WHERE n.owner_id = @userId
        ORDER BY n.created_at DESC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'userId': userId,
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query(
        'SELECT COUNT(*) as total FROM nfts WHERE owner_id = @userId',
        substitutionValues: {'userId': userId},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'nfts': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
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

  Future<Response> _createLoyaltyToken(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final amount = data['amount'];
      final reason = data['reason'];

      if (userId == null || amount == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID and amount are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _web3Service.createLoyaltyToken(
        userId: userId,
        amount: amount,
        reason: reason,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Loyalty tokens created successfully',
            'tokens': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to create loyalty tokens',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
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

  Future<Response> _transferLoyaltyTokens(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final fromUserId = data['fromUserId'];
      final toUserId = data['toUserId'];
      final amount = data['amount'];

      if (fromUserId == null || toUserId == null || amount == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'From user ID, to user ID, and amount are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _web3Service.transferLoyaltyTokens(
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Loyalty tokens transferred successfully',
            'transaction': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to transfer loyalty tokens',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
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

  Future<Response> _getLoyaltyTokenBalance(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final balance = await _web3Service.getLoyaltyTokenBalance(userId);

      return Response.ok(
        jsonEncode({
          'success': true,
          'userId': userId,
          'balance': balance,
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

  Future<Response> _uploadToIPFS(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final fileData = data['fileData'];
      final fileName = data['fileName'];
      final fileType = data['fileType'];

      if (fileData == null || fileName == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'File data and file name are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _web3Service.uploadToIPFS(
        fileData: fileData,
        fileName: fileName,
        fileType: fileType,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'File uploaded to IPFS successfully',
            'ipfsHash': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to upload file to IPFS',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
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

  Future<Response> _getFromIPFS(Request request) async {
    try {
      final hash = request.params['hash'];
      if (hash == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'IPFS hash is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _web3Service.getFromIPFS(hash);

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'fileData': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'File not found in IPFS',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
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

  Future<Response> _connectWallet(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final walletAddress = data['walletAddress'];
      final signature = data['signature'];
      final message = data['message'];

      if (userId == null || walletAddress == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID and wallet address are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _web3Service.connectWallet(
        userId: userId,
        walletAddress: walletAddress,
        signature: signature,
        message: message,
      );

      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Wallet connected successfully',
            'wallet': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'error': 'Failed to connect wallet',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
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

  Future<Response> _getUserWallets(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _database.query(
        'SELECT * FROM user_wallets WHERE user_id = @userId ORDER BY is_primary DESC, created_at DESC',
        substitutionValues: {'userId': userId},
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'wallets': result,
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

  Future<Response> _setPrimaryWallet(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final walletId = data['walletId'];

      if (userId == null || walletId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID and wallet ID are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Сначала сбрасываем все кошельки пользователя как не основные
      await _database.execute(
        'UPDATE user_wallets SET is_primary = false WHERE user_id = @userId',
        substitutionValues: {'userId': userId},
      );

      // Устанавливаем указанный кошелек как основной
      await _database.execute(
        'UPDATE user_wallets SET is_primary = true WHERE id = @walletId AND user_id = @userId',
        substitutionValues: {
          'walletId': walletId,
          'userId': userId,
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Primary wallet set successfully',
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
      final result = await _database.query(
        'SELECT * FROM smart_contracts ORDER BY created_at DESC',
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'contracts': result,
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
      final address = request.params['address'];
      if (address == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Contract address is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _database.query(
        'SELECT * FROM smart_contracts WHERE address = @address',
        substitutionValues: {'address': address},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Smart contract not found',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'contract': result.first,
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

  Future<Response> _getTransactions(Request request) async {
    try {
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT t.*, u.name as user_name
        FROM blockchain_transactions t
        LEFT JOIN users u ON t.user_id = u.id
        ORDER BY t.created_at DESC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query('SELECT COUNT(*) as total FROM blockchain_transactions');
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'transactions': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
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

  Future<Response> _getTransaction(Request request) async {
    try {
      final hash = request.params['hash'];
      if (hash == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Transaction hash is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _database.query(
        '''
        SELECT t.*, u.name as user_name
        FROM blockchain_transactions t
        LEFT JOIN users u ON t.user_id = u.id
        WHERE t.hash = @hash
        ''',
        substitutionValues: {'hash': hash},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Transaction not found',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'transaction': result.first,
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

  Future<Response> _getWeb3Stats(Request request) async {
    try {
      final stats = await _web3Service.getWeb3Stats();

      return Response.ok(
        jsonEncode({
          'success': true,
          'stats': stats,
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
