import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/web3_models.dart';

/// Тестовый сервис для Web3 интеграции
/// Использует mock данные для разработки и тестирования
class Web3TestService {
  static const String _baseUrl = 'http://localhost:8080'; // Backend URL
  
  // Mock данные для разработки
  static final List<NFTModel> _mockNFTs = [
    NFTModel(
      id: '1',
      name: 'MyModus Fashion NFT #1',
      description: 'Эксклюзивный NFT из коллекции MyModus',
      imageUrl: 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=NFT+1',
      tokenId: '1',
      contractAddress: '0x1234567890123456789012345678901234567890',
      owner: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      price: '0.1',
      isForSale: true,
      creator: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      category: 'Fashion',
      attributes: {
        'rarity': 'Common',
        'style': 'Casual',
        'season': 'All Year'
      },
    ),
    NFTModel(
      id: '2',
      name: 'MyModus Luxury NFT #2',
      description: 'Премиум NFT с уникальными характеристиками',
      imageUrl: 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=NFT+2',
      tokenId: '2',
      contractAddress: '0x1234567890123456789012345678901234567890',
      owner: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      price: '0.5',
      isForSale: true,
      creator: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      createdAt: DateTime.now().subtract(Duration(hours: 12)),
      category: 'Luxury',
      attributes: {
        'rarity': 'Rare',
        'style': 'Premium',
        'season': 'Spring'
      },
    ),
    NFTModel(
      id: '3',
      name: 'MyModus Streetwear NFT #3',
      description: 'Уличная мода в стиле MyModus',
      imageUrl: 'https://via.placeholder.com/300x300/45B7D1/FFFFFF?text=NFT+3',
      tokenId: '3',
      contractAddress: '0x1234567890123456789012345678901234567890',
      owner: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      price: '0.3',
      isForSale: false,
      creator: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      createdAt: DateTime.now().subtract(Duration(hours: 6)),
      category: 'Streetwear',
      attributes: {
        'rarity': 'Uncommon',
        'style': 'Urban',
        'season': 'Summer'
      },
    ),
  ];

  static final List<LoyaltyTokenModel> _mockLoyaltyTokens = [
    LoyaltyTokenModel(
      id: '1',
      name: 'MyModus Loyalty Token',
      symbol: 'MMLT',
      balance: '1000.0',
      decimals: 18,
      contractAddress: '0x0987654321098765432109876543210987654321',
      totalSupply: '1000000.0',
      userBalance: '1000.0',
      canMint: true,
      canBurn: false,
      mintPrice: '0.001',
    ),
    LoyaltyTokenModel(
      id: '2',
      name: 'MyModus Premium Token',
      symbol: 'MMPT',
      balance: '500.0',
      decimals: 18,
      contractAddress: '0x0987654321098765432109876543210987654321',
      totalSupply: '100000.0',
      userBalance: '500.0',
      canMint: true,
      canBurn: true,
      mintPrice: '0.01',
    ),
  ];

  static final List<BlockchainTransactionModel> _mockTransactions = [
    BlockchainTransactionModel(
      id: '1',
      hash: '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      from: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      to: '0x1234567890123456789012345678901234567890',
      value: '0.1',
      gasUsed: '21000',
      gasPrice: '20000000000',
      status: TransactionStatus.confirmed,
      blockNumber: '12345678',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      type: TransactionType.nftMint,
      metadata: {
        'tokenId': '1',
        'contractAddress': '0x1234567890123456789012345678901234567890'
      },
    ),
    BlockchainTransactionModel(
      id: '2',
      hash: '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
      from: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      to: '0x0987654321098765432109876543210987654321',
      value: '0.001',
      gasUsed: '65000',
      gasPrice: '20000000000',
      status: TransactionStatus.confirmed,
      blockNumber: '12345679',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      type: TransactionType.tokenMint,
      metadata: {
        'amount': '100',
        'contractAddress': '0x0987654321098765432109876543210987654321'
      },
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
        currencySymbol: 'ETH',
        isTestnet: true,
      );
    } catch (e) {
      print('Error getting network info: $e');
      return NetworkInfo(
        name: 'Unknown',
        chainId: 0,
        rpcUrl: '',
        explorerUrl: '',
        currencySymbol: 'ETH',
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
        canSign: true,
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
