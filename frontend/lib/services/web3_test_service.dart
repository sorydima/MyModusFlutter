import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/web3_models.dart';

// Временные типы для совместимости
enum TransactionStatus { pending, confirmed, failed }
enum TransactionType { transfer, mint, burn, swap, stake, unstake }

class BlockchainTransactionModel {
  final String hash;
  final String from;
  final String to;
  final String value;
  final String gasUsed;
  final String gasPrice;
  final int blockNumber;
  final DateTime timestamp;
  final TransactionStatus status;
  final TransactionType type;
  final String? error;
  final String network;

  BlockchainTransactionModel({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.gasUsed,
    required this.gasPrice,
    required this.blockNumber,
    required this.timestamp,
    required this.status,
    required this.type,
    this.error,
    required this.network,
  });

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'from': from,
      'to': to,
      'value': value,
      'gasUsed': gasUsed,
      'gasPrice': gasPrice,
      'blockNumber': blockNumber,
      'status': status.name,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
      'network': network,
    };
  }
}

class WalletInfo {
  final String address;
  final String balance;
  final String network;
  final bool isConnected;

  WalletInfo({
    required this.address,
    required this.balance,
    required this.network,
    required this.isConnected,
  });
}

/// Тестовый сервис для Web3 интеграции
/// Использует mock данные для разработки и тестирования
class Web3TestService {
  static const String _baseUrl = 'http://localhost:8080'; // Backend URL
  
  // Mock данные для разработки
  static final List<NFTModel> _mockNFTs = [
    NFTModel(
      id: '1',
      tokenId: 1,
      contractAddress: '0x1234567890123456789012345678901234567890',
      owner: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      metadata: NFTMetadata(
        name: 'NFT #1',
        description: 'Описание NFT #1',
        image: 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=NFT+1',
        attributes: 'fashion',
      ),
      isForSale: true,
      price: 0.1,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
      viewCount: 10,
      likeCount: 5,
      rarity: 0.8,
    ),
    NFTModel(
      id: '2',
      tokenId: 2,
      contractAddress: '0x1234567890123456789012345678901234567890',
      owner: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      metadata: NFTMetadata(
        name: 'NFT #2',
        description: 'Описание NFT #2',
        image: 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=NFT+2',
        attributes: 'sneakers',
      ),
      isForSale: true,
      price: 0.5,
      createdAt: DateTime.now().subtract(Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(Duration(hours: 12)),
      viewCount: 15,
      likeCount: 8,
      rarity: 0.7,
    ),
    NFTModel(
      id: '3',
      tokenId: 3,
      contractAddress: '0x1234567890123456789012345678901234567890',
      owner: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      metadata: NFTMetadata(
        name: 'NFT #3',
        description: 'Описание NFT #3',
        image: 'https://via.placeholder.com/300x300/45B7D1/FFFFFF?text=NFT+3',
        attributes: 'luxury',
      ),
      isForSale: false,
      price: 0.3,
      createdAt: DateTime.now().subtract(Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(Duration(hours: 6)),
      viewCount: 8,
      likeCount: 3,
      rarity: 0.6,
    ),
  ];

  static final List<LoyaltyTokenModel> _mockLoyaltyTokens = [
    LoyaltyTokenModel(
      id: '1',
      symbol: 'MMLT',
      name: 'MyModus Loyalty Token',
      decimals: 18,
      totalSupply: '1000000.0',
      maxSupply: '1000000.0',
      mintPrice: '0.001',
      mintingEnabled: true,
      burningEnabled: false,
      paused: false,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
    ),
    LoyaltyTokenModel(
      id: '2',
      symbol: 'MMPT',
      name: 'MyModus Premium Token',
      decimals: 18,
      totalSupply: '100000.0',
      maxSupply: '100000.0',
      mintPrice: '0.01',
      mintingEnabled: true,
      burningEnabled: true,
      paused: false,
      createdAt: DateTime.now().subtract(Duration(days: 15)),
    ),
  ];

  static final List<BlockchainTransactionModel> _mockTransactions = [
    BlockchainTransactionModel(
      hash: '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      from: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      to: '0x1234567890123456789012345678901234567890',
      value: '0.1',
      gasUsed: '21000',
      gasPrice: '20000000000',
      blockNumber: 12345678,
      status: TransactionStatus.confirmed,
      type: TransactionType.mint,
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      network: 'Ethereum',
    ),
    BlockchainTransactionModel(
      hash: '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
      from: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      to: '0x0987654321098765432109876543210987654321',
      value: '0.001',
      gasUsed: '65000',
      gasPrice: '20000000000',
      blockNumber: 12345679,
      status: TransactionStatus.confirmed,
      type: TransactionType.mint,
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      network: 'Ethereum',
    ),
  ];

  /// Получить список NFT пользователя
  Future<List<NFTModel>> getUserNFTs(String walletAddress) async {
    try {
      // В реальном приложении здесь будет API вызов
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/web3/nfts?wallet=$walletAddress'),
      // );
      
      // Пока возвращаем mock данные
      await Future.delayed(Duration(milliseconds: 500)); // Имитация задержки
      return _mockNFTs;
    } catch (e) {
      print('Error getting user NFTs: $e');
      return [];
    }
  }

  /// Получить все доступные NFT
  Future<List<NFTModel>> getAllNFTs() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      return _mockNFTs;
    } catch (e) {
      print('Error getting all NFTs: $e');
      return [];
    }
  }

  /// Получить токены лояльности пользователя
  Future<List<LoyaltyTokenModel>> getUserLoyaltyTokens(String walletAddress) async {
    try {
      await Future.delayed(Duration(milliseconds: 400));
      return _mockLoyaltyTokens;
    } catch (e) {
      print('Error getting loyalty tokens: $e');
      return [];
    }
  }

  /// Получить историю транзакций
  Future<List<BlockchainTransactionModel>> getTransactionHistory(String walletAddress) async {
    try {
      await Future.delayed(Duration(milliseconds: 600));
      return _mockTransactions;
    } catch (e) {
      print('Error getting transaction history: $e');
      return [];
    }
  }

  /// Минт нового NFT
  Future<bool> mintNFT({
    required String name,
    required String description,
    required String imageUrl,
    required String category,
    required Map<String, String> attributes,
  }) async {
    try {
      // Имитация процесса минтинга
      await Future.delayed(Duration(seconds: 2));
      
      // В реальном приложении здесь будет вызов смарт-контракта
      print('NFT minted successfully: $name');
      return true;
    } catch (e) {
      print('Error minting NFT: $e');
      return false;
    }
  }

  /// Минт токенов лояльности
  Future<bool> mintLoyaltyTokens({
    required String contractAddress,
    required String amount,
  }) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      print('Loyalty tokens minted: $amount');
      return true;
    } catch (e) {
      print('Error minting loyalty tokens: $e');
      return false;
    }
  }

  /// Проверить баланс кошелька
  Future<String> getWalletBalance(String walletAddress) async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      return '2.5'; // Mock баланс в ETH
    } catch (e) {
      print('Error getting wallet balance: $e');
      return '0.0';
    }
  }

  /// Получить информацию о сети
  Future<NetworkInfo> getCurrentNetwork() async {
    try {
      await Future.delayed(Duration(milliseconds: 100));
      return NetworkInfo(
        name: 'Sepolia Testnet',
        chainId: 11155111,
        rpcUrl: 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID',
        explorerUrl: 'https://sepolia.etherscan.io',
        nativeCurrency: 'ETH',
        decimals: 18,
        isTestnet: true,
      );
    } catch (e) {
      print('Error getting network info: $e');
      return NetworkInfo(
        name: 'Unknown',
        chainId: 0,
        rpcUrl: '',
        explorerUrl: '',
        nativeCurrency: 'ETH',
        decimals: 18,
        isTestnet: false,
      );
    }
  }

  /// Подключить кошелек
  Future<WalletInfo?> connectWallet() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      
      return WalletInfo(
        address: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
        balance: '2.5',
        network: 'Sepolia Testnet',
        isConnected: true,

      );
    } catch (e) {
      print('Error connecting wallet: $e');
      return null;
    }
  }

  /// Отключить кошелек
  Future<bool> disconnectWallet() async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      return true;
    } catch (e) {
      print('Error disconnecting wallet: $e');
      return false;
    }
  }
}
