import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../database.dart';
import '../models.dart';

class Web3Service {
  final DatabaseService _db;
  late final Web3Client _client;
  late final Credentials _credentials;
  
  // Network configuration
  static const String _ethereumRpcUrl = 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY';
  static const String _polygonRpcUrl = 'https://polygon-rpc.com';
  static const String _testnetRpcUrl = 'https://goerli.infura.io/v3/YOUR_INFURA_KEY';
  
  // Contract addresses (deploy these first)
  static const String _nftContractAddress = '0x...'; // Your NFT contract
  static const String _loyaltyContractAddress = '0x...'; // Your loyalty contract
  
  // IPFS configuration
  static const String _ipfsGateway = 'https://ipfs.io/ipfs/';
  static const String _ipfsApiUrl = 'https://ipfs.infura.io:5001/api/v0';
  
  Web3Service(this._db) {
    _initializeWeb3();
  }

  /// Инициализация Web3 клиента
  Future<void> _initializeWeb3() async {
    try {
      // Подключаемся к Ethereum mainnet
      _client = Web3Client(_ethereumRpcUrl, http.Client());
      
      // Создаем тестовые учетные данные (в продакшене используйте реальные ключи)
      _credentials = EthPrivateKey.fromHex('0x...'); // Your private key
      
      print('Web3 service initialized successfully');
    } catch (e) {
      print('Error initializing Web3 service: $e');
      rethrow;
    }
  }

  /// Создание NFT токена
  Future<NFT> mintNFT({
    required String userId,
    required String name,
    required String description,
    required String imageUrl,
    required Map<String, dynamic> attributes,
  }) async {
    try {
      // Загружаем метаданные в IPFS
      final metadata = {
        'name': name,
        'description': description,
        'image': imageUrl,
        'attributes': attributes,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final ipfsHash = await uploadToIPFS(jsonEncode(metadata));
      
      // Создаем NFT в базе данных
      final nft = NFT(
        id: const Uuid().v4(),
        tokenId: const Uuid().v4(),
        contractAddress: _nftContractAddress,
        ownerWalletId: '', // Will be set after wallet creation
        tokenURI: 'ipfs://$ipfsHash',
        name: name,
        description: description,
        imageUrl: imageUrl,
        attributes: attributes,
        type: 'collectible',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Сохраняем в базу данных
      await _saveNFT(nft);
      
      // TODO: Вызвать смарт-контракт для минтинга
      // await _mintNFTOnChain(nft, ipfsHash);
      
      return nft;
    } catch (e) {
      print('Error minting NFT: $e');
      rethrow;
    }
  }

  /// Загрузка файла в IPFS
  Future<String> uploadToIPFS(String content, {String? fileName}) async {
    try {
      final uri = Uri.parse('$_ipfsApiUrl/add');
      
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          utf8.encode(content),
          filename: fileName ?? 'file.txt',
        ),
      );
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      
      if (response.statusCode == 200) {
        final hash = jsonResponse['Hash'] as String;
        
        // Сохраняем информацию о файле в базу данных
        await _saveIPFSFile(hash, fileName ?? 'file.txt', content.length);
        
        return hash;
      } else {
        throw Exception('Failed to upload to IPFS: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to IPFS: $e');
      rethrow;
    }
  }

  /// Получение файла из IPFS
  Future<String> getFromIPFS(String hash) async {
    try {
      final response = await http.get(Uri.parse('$_ipfsGateway$hash'));
      
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to get from IPFS: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting from IPFS: $e');
      rethrow;
    }
  }

  /// Создание токена лояльности
  Future<LoyaltyToken> createLoyaltyToken({
    required String userId,
    required String initialBalance,
  }) async {
    try {
      // Создаем токен в базе данных
      final loyaltyToken = LoyaltyToken(
        id: const Uuid().v4(),
        userId: userId,
        contractAddress: _loyaltyContractAddress,
        balance: initialBalance,
        totalEarned: initialBalance,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Сохраняем в базу данных
      await _saveLoyaltyToken(loyaltyToken);
      
      // TODO: Вызвать смарт-контракт для создания токена
      // await _createLoyaltyTokenOnChain(loyaltyToken);
      
      return loyaltyToken;
    } catch (e) {
      print('Error creating loyalty token: $e');
      rethrow;
    }
  }

  /// Передача токенов лояльности
  Future<void> transferLoyaltyTokens({
    required String fromUserId,
    required String toUserId,
    required String amount,
  }) async {
    try {
      // Обновляем балансы в базе данных
      await _updateLoyaltyTokenBalance(fromUserId, amount, isSubtract: true);
      await _updateLoyaltyTokenBalance(toUserId, amount, isSubtract: false);
      
      // TODO: Вызвать смарт-контракт для передачи токенов
      // await _transferLoyaltyTokensOnChain(fromUserId, toUserId, amount);
      
      print('Loyalty tokens transferred successfully');
    } catch (e) {
      print('Error transferring loyalty tokens: $e');
      rethrow;
    }
  }

  /// Получение баланса токенов лояльности
  Future<String> getLoyaltyTokenBalance(String userId) async {
    try {
      final conn = await _db.getConnection();
      
      final result = await conn.execute('''
        SELECT balance FROM loyalty_tokens 
        WHERE user_id = @userId
      ''', substitutionValues: {'userId': userId});
      
      await conn.close();
      
      if (result.isNotEmpty) {
        return result.first[0] as String;
      }
      
      return '0';
    } catch (e) {
      print('Error getting loyalty token balance: $e');
      return '0';
    }
  }

  /// Подключение кошелька пользователя
  Future<void> connectWallet({
    required String userId,
    required String walletAddress,
    String walletType = 'ethereum',
  }) async {
    try {
      final conn = await _db.getConnection();
      
      // Проверяем, есть ли уже кошелек у пользователя
      final existingWallet = await conn.execute('''
        SELECT id FROM user_wallets 
        WHERE user_id = @userId
      ''', substitutionValues: {'userId': userId});
      
      if (existingWallet.isNotEmpty) {
        // Обновляем существующий кошелек
        await conn.execute('''
          UPDATE user_wallets 
          SET wallet_address = @address, wallet_type = @type, updated_at = CURRENT_TIMESTAMP
          WHERE user_id = @userId
        ''', substitutionValues: {
          'address': walletAddress,
          'type': walletType,
          'userId': userId,
        });
      } else {
        // Создаем новый кошелек
        await conn.execute('''
          INSERT INTO user_wallets (id, user_id, wallet_address, wallet_type, is_primary)
          VALUES (@id, @userId, @address, @type, true)
        ''', substitutionValues: {
          'id': const Uuid().v4(),
          'userId': userId,
          'address': walletAddress,
          'type': walletType,
        });
      }
      
      await conn.close();
      
      print('Wallet connected successfully for user $userId');
    } catch (e) {
      print('Error connecting wallet: $e');
      rethrow;
    }
  }

  /// Получение NFT пользователя
  Future<List<NFT>> getUserNFTs(String userId) async {
    try {
      final conn = await _db.getConnection();
      
      final result = await conn.execute('''
        SELECT n.* FROM nfts n
        JOIN user_wallets w ON n.owner_wallet_id = w.id
        WHERE w.user_id = @userId
      ''', substitutionValues: {'userId': userId});
      
      await conn.close();
      
      return result.map((row) => NFT.fromRow(row)).toList();
    } catch (e) {
      print('Error getting user NFTs: $e');
      return [];
    }
  }

  /// Получение статистики Web3
  Future<Map<String, dynamic>> getWeb3Stats() async {
    try {
      final conn = await _db.getConnection();
      
      // Статистика NFT
      final nftStats = await conn.execute('''
        SELECT 
          COUNT(*) as total_nfts,
          COUNT(CASE WHEN is_minted = true THEN 1 END) as minted_nfts,
          COUNT(CASE WHEN type = 'badge' THEN 1 END) as badge_nfts,
          COUNT(CASE WHEN type = 'coupon' THEN 1 END) as coupon_nfts
        FROM nfts
      ''');
      
      // Статистика токенов лояльности
      final loyaltyStats = await conn.execute('''
        SELECT 
          COUNT(*) as total_users,
          SUM(CAST(balance AS DECIMAL)) as total_balance,
          AVG(CAST(balance AS DECIMAL)) as avg_balance
        FROM loyalty_tokens
      ''');
      
      // Статистика IPFS
      final ipfsStats = await conn.execute('''
        SELECT 
          COUNT(*) as total_files,
          SUM(file_size) as total_size,
          COUNT(CASE WHEN is_pinned = true THEN 1 END) as pinned_files
        FROM ipfs_files
      ''');
      
      await conn.close();
      
      return {
        'nft_stats': nftStats.isNotEmpty ? nftStats.first : {},
        'loyalty_stats': loyaltyStats.isNotEmpty ? loyaltyStats.first : {},
        'ipfs_stats': ipfsStats.isNotEmpty ? ipfsStats.first : {},
        'network_info': {
          'ethereum_rpc': _ethereumRpcUrl,
          'polygon_rpc': _polygonRpcUrl,
          'testnet_rpc': _testnetRpcUrl,
        },
      };
      
    } catch (e) {
      print('Error getting Web3 stats: $e');
      return {};
    }
  }

  /// Сохранение NFT в базу данных
  Future<void> _saveNFT(NFT nft) async {
    try {
      final conn = await _db.getConnection();
      
      await conn.execute('''
        INSERT INTO nfts (
          id, token_id, contract_id, owner_wallet_id, token_uri,
          name, description, image_url, attributes, type
        ) VALUES (
          @id, @tokenId, @contractId, @ownerWalletId, @tokenUri,
          @name, @description, @imageUrl, @attributes, @type
        )
      ''', substitutionValues: {
        'id': nft.id,
        'tokenId': nft.tokenId,
        'contractId': nft.contractId,
        'ownerWalletId': nft.ownerWalletId,
        'tokenUri': nft.tokenURI,
        'name': nft.name,
        'description': nft.description,
        'imageUrl': nft.imageUrl,
        'attributes': nft.attributes != null ? jsonEncode(nft.attributes) : null,
        'type': nft.type,
      });
      
      await conn.close();
    } catch (e) {
      print('Error saving NFT: $e');
      rethrow;
    }
  }

  /// Сохранение информации об IPFS файле
  Future<void> _saveIPFSFile(String hash, String fileName, int fileSize) async {
    try {
      final conn = await _db.getConnection();
      
      await conn.execute('''
        INSERT INTO ipfs_files (ipfs_hash, file_name, file_size, file_type)
        VALUES (@hash, @fileName, @fileSize, 'metadata')
        ON CONFLICT (ipfs_hash) DO NOTHING
      ''', substitutionValues: {
        'hash': hash,
        'fileName': fileName,
        'fileSize': fileSize,
      });
      
      await conn.close();
    } catch (e) {
      print('Error saving IPFS file info: $e');
    }
  }

  /// Сохранение токена лояльности
  Future<void> _saveLoyaltyToken(LoyaltyToken token) async {
    try {
      final conn = await _db.getConnection();
      
      await conn.execute('''
        INSERT INTO loyalty_tokens (
          id, user_id, contract_id, balance, total_earned
        ) VALUES (
          @id, @userId, @contractId, @balance, @totalEarned
        )
      ''', substitutionValues: {
        'id': token.id,
        'userId': token.userId,
        'contractId': token.contractId,
        'balance': token.balance,
        'totalEarned': token.totalEarned,
      });
      
      await conn.close();
    } catch (e) {
      print('Error saving loyalty token: $e');
      rethrow;
    }
  }

  /// Обновление баланса токенов лояльности
  Future<void> _updateLoyaltyTokenBalance(String userId, String amount, {required bool isSubtract}) async {
    try {
      final conn = await _db.getConnection();
      
      if (isSubtract) {
        await conn.execute('''
          UPDATE loyalty_tokens 
          SET balance = CAST(balance AS DECIMAL) - CAST(@amount AS DECIMAL)
          WHERE user_id = @userId
        ''', substitutionValues: {
          'amount': amount,
          'userId': userId,
        });
      } else {
        await conn.execute('''
          UPDATE loyalty_tokens 
          SET balance = CAST(balance AS DECIMAL) + CAST(@amount AS DECIMAL),
              total_earned = CAST(total_earned AS DECIMAL) + CAST(@amount AS DECIMAL)
          WHERE user_id = @userId
        ''', substitutionValues: {
          'amount': amount,
          'userId': userId,
        });
      }
      
      await conn.close();
    } catch (e) {
      print('Error updating loyalty token balance: $e');
      rethrow;
    }
  }

  /// Закрытие соединений
  Future<void> dispose() async {
    await _client.dispose();
  }
}
