import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database.dart';
import '../services/web3_service.dart';

class Web3Handler {
  final DatabaseService _db;
  final Web3Service _web3Service;

  Web3Handler(this._db, this._web3Service);

  Router get router {
    final router = Router();

    // NFT операции
    router.post('/nfts/mint', _mintNFT);
    router.get('/nfts', _getNFTs);
    router.get('/nfts/<id>', _getNFT);
    router.get('/users/<userId>/nfts', _getUserNFTs);
    
    // Токены лояльности
    router.post('/loyalty/create', _createLoyaltyToken);
    router.post('/loyalty/transfer', _transferLoyaltyTokens);
    router.get('/loyalty/balance/<userId>', _getLoyaltyBalance);
    
    // IPFS операции
    router.post('/ipfs/upload', _uploadToIPFS);
    router.get('/ipfs/<hash>', _getFromIPFS);
    
    // Кошельки
    router.post('/wallets/connect', _connectWallet);
    router.get('/wallets/<userId>', _getUserWallets);
    router.post('/wallets/set-primary', _setPrimaryWallet);
    
    // Смарт-контракты
    router.get('/contracts', _getContracts);
    router.get('/contracts/<address>', _getContract);
    
    // Блокчейн транзакции
    router.get('/transactions', _getTransactions);
    router.get('/transactions/<hash>', _getTransaction);
    
    // Статистика Web3
    router.get('/stats', _getWeb3Stats);

    return router;
  }

  // Минтинг NFT
  Future<Response> _mintNFT(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final userId = data['userId'] as String?;
      final name = data['name'] as String?;
      final description = data['description'] as String?;
      final imageUrl = data['imageUrl'] as String?;
      final metadata = data['metadata'] as Map<String, dynamic>?;

      if (userId == null || name == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя и название обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка существования пользователя
      final users = await _db.query(
        'SELECT id FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId}
      );

      if (users.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Пользователь не найден'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Загрузка метаданных в IPFS
      final ipfsHash = await _web3Service.uploadToIPFS({
        'name': name,
        'description': description,
        'image': imageUrl,
        'attributes': metadata ?? {},
        'created_at': DateTime.now().toIso8601String(),
        'creator': userId,
      });

      // Создание NFT в базе данных
      final result = await _db.execute(
        '''
        INSERT INTO nfts (user_id, name, description, image_url, metadata_hash, 
                         token_id, contract_address, is_active)
        VALUES (@userId, @name, @description, @imageUrl, @ipfsHash, 
                @tokenId, @contractAddress, true)
        RETURNING id
        ''',
        substitutionValues: {
          'userId': userId,
          'name': name,
          'description': description,
          'imageUrl': imageUrl,
          'ipfsHash': ipfsHash,
          'tokenId': '0', // TODO: Получить от смарт-контракта
          'contractAddress': '0x0', // TODO: Адрес контракта
        }
      );

      final nftId = result.first['id'];

      return Response(201, 
        body: json.encode({
          'message': 'NFT успешно создан',
          'nftId': nftId,
          'ipfsHash': ipfsHash,
          'metadata': {
            'name': name,
            'description': description,
            'image': imageUrl,
            'attributes': metadata
          }
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение NFT пользователя
  Future<Response> _getUserNFTs(Request request) async {
    try {
      final userId = request.params['userId'];
      
      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final nfts = await _db.query(
        '''
        SELECT n.*, u.name as owner_name, u.avatar_url as owner_avatar
        FROM nfts n
        JOIN users u ON n.user_id = u.id
        WHERE n.user_id = @userId AND n.is_active = true
        ORDER BY n.created_at DESC
        ''',
        substitutionValues: {'userId': userId}
      );

      return Response(200, 
        body: json.encode({
          'nfts': nfts.map((nft) => {
            'id': nft['id'],
            'name': nft['name'],
            'description': nft['description'],
            'imageUrl': nft['image_url'],
            'metadataHash': nft['metadata_hash'],
            'tokenId': nft['token_id'],
            'contractAddress': nft['contract_address'],
            'ownerName': nft['owner_name'],
            'ownerAvatar': nft['owner_avatar'],
            'isActive': nft['is_active'],
            'createdAt': nft['created_at'].toString(),
            'updatedAt': nft['updated_at'].toString()
          }).toList()
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Создание токена лояльности
  Future<Response> _createLoyaltyToken(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final userId = data['userId'] as String?;
      final amount = data['amount'] as int?;
      final reason = data['reason'] as String?;

      if (userId == null || amount == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя и количество обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка существования пользователя
      final users = await _db.query(
        'SELECT id FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId}
      );

      if (users.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Пользователь не найден'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Создание токена лояльности
      await _db.execute(
        '''
        INSERT INTO loyalty_tokens (user_id, amount, reason, is_active)
        VALUES (@userId, @amount, @reason, true)
        ''',
        substitutionValues: {
          'userId': userId,
          'amount': amount,
          'reason': reason ?? 'Награда за активность',
        }
      );

      return Response(201, 
        body: json.encode({
          'message': 'Токены лояльности созданы',
          'userId': userId,
          'amount': amount,
          'reason': reason
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение баланса лояльности
  Future<Response> _getLoyaltyBalance(Request request) async {
    try {
      final userId = request.params['userId'];
      
      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final result = await _db.query(
        '''
        SELECT COALESCE(SUM(amount), 0) as total_balance
        FROM loyalty_tokens
        WHERE user_id = @userId AND is_active = true
        ''',
        substitutionValues: {'userId': userId}
      );

      final balance = result.first['total_balance'] as int;

      return Response(200, 
        body: json.encode({
          'userId': userId,
          'balance': balance,
          'currency': 'LOYALTY'
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Загрузка в IPFS
  Future<Response> _uploadToIPFS(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final content = data['content'];
      final metadata = data['metadata'];

      if (content == null) {
        return Response(400, 
          body: json.encode({'error': 'Контент обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Загрузка в IPFS
      final ipfsHash = await _web3Service.uploadToIPFS(content);

      // Сохранение метаданных файла
      await _db.execute(
        '''
        INSERT INTO ipfs_files (hash, content_type, size, metadata, is_active)
        VALUES (@hash, @contentType, @size, @metadata, true)
        ''',
        substitutionValues: {
          'hash': ipfsHash,
          'contentType': 'application/json',
          'size': content.toString().length,
          'metadata': json.encode(metadata ?? {}),
        }
      );

      return Response(200, 
        body: json.encode({
          'message': 'Файл загружен в IPFS',
          'ipfsHash': ipfsHash,
          'gateway': 'https://ipfs.io/ipfs/$ipfsHash'
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Подключение кошелька
  Future<Response> _connectWallet(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final userId = data['userId'] as String?;
      final walletAddress = data['walletAddress'] as String?;
      final walletType = data['walletType'] as String?; // MetaMask, WalletConnect, etc.

      if (userId == null || walletAddress == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя и адрес кошелька обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка существования пользователя
      final users = await _db.query(
        'SELECT id FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId}
      );

      if (users.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Пользователь не найден'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка, что кошелек не занят
      final existingWallet = await _db.query(
        'SELECT id FROM user_wallets WHERE wallet_address = @walletAddress',
        substitutionValues: {'walletAddress': walletAddress}
      );

      if (existingWallet.isNotEmpty) {
        return Response(409, 
          body: json.encode({'error': 'Кошелек уже подключен к другому аккаунту'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Подключение кошелька
      await _db.execute(
        '''
        INSERT INTO user_wallets (user_id, wallet_address, wallet_type, is_primary, is_active)
        VALUES (@userId, @walletAddress, @walletType, false, true)
        ''',
        substitutionValues: {
          'userId': userId,
          'walletAddress': walletAddress,
          'walletType': walletType ?? 'unknown',
        }
      );

      return Response(200, 
        body: json.encode({
          'message': 'Кошелек успешно подключен',
          'walletAddress': walletAddress,
          'walletType': walletType
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение кошельков пользователя
  Future<Response> _getUserWallets(Request request) async {
    try {
      final userId = request.params['userId'];
      
      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final wallets = await _db.query(
        '''
        SELECT * FROM user_wallets
        WHERE user_id = @userId AND is_active = true
        ORDER BY is_primary DESC, created_at DESC
        ''',
        substitutionValues: {'userId': userId}
      );

      return Response(200, 
        body: json.encode({
          'wallets': wallets.map((wallet) => {
            'id': wallet['id'],
            'walletAddress': wallet['wallet_address'],
            'walletType': wallet['wallet_type'],
            'isPrimary': wallet['is_primary'],
            'isActive': wallet['is_active'],
            'createdAt': wallet['created_at'].toString(),
            'updatedAt': wallet['updated_at'].toString()
          }).toList()
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение статистики Web3
  Future<Response> _getWeb3Stats(Request request) async {
    try {
      // Статистика NFT
      final nftStats = await _db.query(
        'SELECT COUNT(*) as total, COUNT(DISTINCT user_id) as unique_owners FROM nfts WHERE is_active = true'
      );

      // Статистика токенов лояльности
      final loyaltyStats = await _db.query(
        'SELECT COUNT(*) as total_transactions, SUM(amount) as total_tokens FROM loyalty_tokens WHERE is_active = true'
      );

      // Статистика кошельков
      final walletStats = await _db.query(
        'SELECT COUNT(*) as total_wallets, COUNT(DISTINCT user_id) as users_with_wallets FROM user_wallets WHERE is_active = true'
      );

      // Статистика IPFS
      final ipfsStats = await _db.query(
        'SELECT COUNT(*) as total_files, SUM(size) as total_size FROM ipfs_files WHERE is_active = true'
      );

      return Response(200, 
        body: json.encode({
          'nft': {
            'total': nftStats.first['total'],
            'uniqueOwners': nftStats.first['unique_owners']
          },
          'loyalty': {
            'totalTransactions': loyaltyStats.first['total_transactions'],
            'totalTokens': loyaltyStats.first['total_tokens']
          },
          'wallets': {
            'totalWallets': walletStats.first['total_wallets'],
            'usersWithWallets': walletStats.first['users_with_wallets']
          },
          'ipfs': {
            'totalFiles': ipfsStats.first['total_files'],
            'totalSize': ipfsStats.first['total_size']
          }
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Остальные методы для полноты API
  Future<Response> _getNFTs(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getNFT(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _transferLoyaltyTokens(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getFromIPFS(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _setPrimaryWallet(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getContracts(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getContract(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getTransactions(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getTransaction(Request request) async => Response(501, body: 'Not implemented');
}
