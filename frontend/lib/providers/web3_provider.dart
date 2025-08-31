import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/web3_test_service.dart';
import '../services/metamask_service.dart';
import '../services/ipfs_service.dart';
import '../models/web3_models.dart';

class Web3Provider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Web3 клиент и кошелек
  Web3Client? _web3Client;
  Credentials? _credentials;
  EthereumAddress? _walletAddress;
  
  // Состояние подключения
  bool _isConnected = false;
  bool _isLoading = false;
  String? _error;
  String? _networkName;
  BigInt? _balance;
  
  // Состояние NFT
  List<Map<String, dynamic>> _nfts = [];
  bool _isLoadingNFTs = false;
  String? _nftsError;
  
  // Состояние токенов лояльности
  List<Map<String, dynamic>> _loyaltyTokens = [];
  bool _isLoadingTokens = false;
  String? _tokensError;
  
  // Состояние транзакций
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoadingTransactions = false;
  String? _transactionsError;
  
  // Контракты
  DeployedContract? _nftContract;
  DeployedContract? _loyaltyContract;
  
  // Тестовый режим
  bool _isTestMode = true; // По умолчанию включен для разработки
  final Web3TestService _testService = Web3TestService();
  
  // MetaMask и IPFS сервисы
  final MetaMaskService _metaMaskService = MetaMaskService();
  final IPFSService _ipfsService = IPFSService(baseUrl: 'http://localhost:3000');
  
  // Режим подключения
  WalletConnectionMode _connectionMode = WalletConnectionMode.test;
  
  // Геттеры для Web3
  bool get isConnected => _isConnected;
  EthereumAddress? get walletAddress => _walletAddress;
  String? get networkName => _networkName;
  BigInt? get balance => _balance;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Геттеры для NFT
  List<Map<String, dynamic>> get nfts => _nfts;
  bool get isLoadingNFTs => _isLoadingNFTs;
  String? get nftsError => _nftsError;
  
  // Геттеры для токенов лояльности
  List<Map<String, dynamic>> get loyaltyTokens => _loyaltyTokens;
  bool get isLoadingTokens => _isLoadingTokens;
  String? get tokensError => _tokensError;
  
  // Геттеры для транзакций
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get transactionsError => _transactionsError;
  
  // Геттер для тестового режима
  bool get isTestMode => _isTestMode;
  
  // Геттеры для MetaMask и IPFS
  MetaMaskService get metaMaskService => _metaMaskService;
  IPFSService get ipfsService => _ipfsService;
  WalletConnectionMode get connectionMode => _connectionMode;
  
  // Инициализация
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _error = null;
      
      // Инициализируем Web3 клиент для локальной сети (Ganache)
      _web3Client = Web3Client(
        'http://localhost:8545', // Ganache RPC URL
        http.Client(),
      );
      
      // Проверяем подключение к сети
      await _checkNetworkConnection();
      
      // Проверяем, есть ли уже подключенный кошелек
      await _checkExistingWallet();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  // Проверка подключения к сети
  Future<void> _checkNetworkConnection() async {
    try {
      final chainId = await _web3Client!.getChainId();
      _networkName = _getNetworkName(chainId);
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка подключения к сети: $e';
      notifyListeners();
    }
  }
  
  // Получение названия сети по chainId
  String _getNetworkName(BigInt chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 3:
        return 'Ropsten Testnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goerli Testnet';
      case 42:
        return 'Kovan Testnet';
      case 1337:
        return 'Local Ganache';
      case 80001:
        return 'Mumbai Testnet';
      case 137:
        return 'Polygon Mainnet';
      default:
        return 'Unknown Network ($chainId)';
    }
  }
  
  // Проверка существующего кошелька
  Future<void> _checkExistingWallet() async {
    try {
      // TODO: Проверяем сохраненный кошелек в secure storage
      // Пока что считаем, что кошелек не подключен
      _isConnected = false;
      _walletAddress = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // ===== КОШЕЛЬКИ =====
  
  // Подключение кошелька через приватный ключ (для разработки)
  Future<bool> connectWalletWithPrivateKey(String privateKey) async {
    try {
      _setLoading(true);
      _error = null;
      
      if (_connectionMode == WalletConnectionMode.test) {
        // В тестовом режиме игнорируем приватный ключ и используем тестовый кошелек
        final walletInfo = await _testService.connectWallet();
        if (walletInfo != null) {
          _walletAddress = EthereumAddress.fromHex(walletInfo.address);
          _balance = BigInt.from(double.parse(walletInfo.balance) * 1e18);
          _networkName = walletInfo.network;
          _isConnected = true;
          
          // Загружаем данные после подключения
          await Future.wait([
            _loadNFTs(),
            _loadLoyaltyTokens(),
            _loadTransactions(),
          ]);
          
          notifyListeners();
          return true;
        } else {
          throw Exception('Не удалось подключить тестовый кошелек');
        }
      } else if (_connectionMode == WalletConnectionMode.privatekey) {
        // Создаем credentials из приватного ключа
        _credentials = EthPrivateKey.fromHex(privateKey);
        _walletAddress = await _credentials!.extractAddress();
        
        // Получаем баланс
        await _updateBalance();
        
        // Загружаем данные после подключения
        await Future.wait([
          _loadNFTs(),
          _loadLoyaltyTokens(),
          _loadTransactions(),
        ]);
        
        _isConnected = true;
        notifyListeners();
        return true;
      }
      
      return false; // Добавляем возврат false для случая, когда не подошли ни к одному условию
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Подключение кошелька через MetaMask (для продакшена)
  Future<bool> connectWalletWithMetaMask() async {
    try {
      _setLoading(true);
      _error = null;
      
      // Проверяем доступность MetaMask
      if (!await _metaMaskService.isMetaMaskAvailable()) {
        throw Exception('MetaMask не доступен. Установите расширение MetaMask.');
      }
      
      // Подключаемся к MetaMask
      final walletInfo = await _metaMaskService.connectWallet();
      if (walletInfo != null) {
        _walletAddress = EthereumAddress.fromHex(walletInfo.address);
        _balance = BigInt.from(double.parse(walletInfo.balance) * 1e18);
        _networkName = walletInfo.network;
        _isConnected = true;
        _connectionMode = WalletConnectionMode.metamask;
        
        // Подписываемся на события MetaMask
        _subscribeToMetaMaskEvents();
        
        // Загружаем данные после подключения
        await Future.wait([
          _loadNFTs(),
          _loadLoyaltyTokens(),
          _loadTransactions(),
        ]);
        
        notifyListeners();
        return true;
      } else {
        throw Exception('Не удалось подключиться к MetaMask');
      }
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Обновление баланса
  Future<void> _updateBalance() async {
    if (_walletAddress == null) return;
    
    try {
      final balance = await _web3Client!.getBalance(_walletAddress!);
      _balance = balance.getInWei;
      notifyListeners();
    } catch (e) {
      print('Ошибка получения баланса: $e');
    }
  }
  
  // Отключение кошелька
  Future<void> disconnectWallet() async {
    try {
      if (_connectionMode == WalletConnectionMode.test) {
        // В тестовом режиме используем тестовый сервис
        await _testService.disconnectWallet();
      } else if (_connectionMode == WalletConnectionMode.metamask) {
        // В MetaMask режиме используем MetaMask сервис
        await _metaMaskService.disconnectWallet();
      }
      
      _isConnected = false;
      _walletAddress = null;
      _credentials = null;
      _balance = null;
      _connectionMode = WalletConnectionMode.test;
      _nfts.clear();
      _loyaltyTokens.clear();
      _transactions.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // ===== NFT =====
  
  // Загрузка NFT пользователя
  Future<void> _loadNFTs() async {
    if (_walletAddress == null) return;
    
    try {
      _setNFTsLoading(true);
      _nftsError = null;
      
      if (_connectionMode == WalletConnectionMode.test) {
        // Используем тестовые данные
        final nfts = await _testService.getUserNFTs(_walletAddress!.hex);
        _nfts = nfts.map((nft) => nft.toJson()).toList();
      } else if (_connectionMode == WalletConnectionMode.metamask) {
        // В MetaMask режиме получаем данные из блокчейна
        // TODO: Реализовать получение NFT из блокчейна
        _nfts = [];
      } else {
        // Получаем NFT с backend
        // TODO: Реализовать API сервис для NFT
        _nfts = [];
      }
      
      notifyListeners();
      
    } catch (e) {
      _nftsError = e.toString();
      notifyListeners();
    } finally {
      _setNFTsLoading(false);
    }
  }
  
  // Минтинг нового NFT
  Future<bool> mintNFT({
    required String name,
    required String description,
    required String imageUrl,
    required String tokenType,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      
      if (_connectionMode == WalletConnectionMode.test) {
        // Используем тестовый сервис для минтинга
        final success = await _testService.mintNFT(
          name: name,
          description: description,
          imageUrl: imageUrl,
          category: tokenType,
          attributes: {
            'type': tokenType,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
        
        if (success) {
          // Обновляем список NFT
          await _loadNFTs();
          return true;
        } else {
          throw Exception('Ошибка минтинга NFT в тестовом режиме');
        }
      } else if (_connectionMode == WalletConnectionMode.metamask) {
        // В MetaMask режиме загружаем метаданные в IPFS
        final ipfsHash = await uploadNFTMetadataToIPFS(
          name: name,
          description: description,
          imageUrl: imageUrl,
          category: tokenType,
          attributes: {
            'type': tokenType,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
        
        if (ipfsHash != null) {
          print('NFT metadata uploaded to IPFS: $ipfsHash');
          
          // TODO: Минтим NFT в блокчейне через MetaMask
          // Пока что просто обновляем список
          await _loadNFTs();
          return true;
        } else {
          throw Exception('Ошибка загрузки метаданных в IPFS');
        }
      } else {
        // Сначала создаем NFT на backend
        // TODO: Реализовать API сервис для NFT
        // final nftData = await _apiService.mintNFT(
        //   name: name,
        //   description: description,
        //   imageUrl: imageUrl,
        //   tokenType: tokenType,
        // );
        
        // TODO: Минтим NFT в блокчейне через смарт-контракт
        // if (_nftContract != null && _credentials != null) {
        //   await _mintNFTOnBlockchain(nftData);
        // }
        
        // Обновляем список NFT
        await _loadNFTs();
        
        return true;
      }
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Минтинг NFT в блокчейне
  Future<void> _mintNFTOnBlockchain(Map<String, dynamic> nftData) async {
    if (_nftContract == null || _credentials == null) return;
    
    try {
      // TODO: Реализовать вызов функции mint в смарт-контракте
      // Это требует компиляции и деплоя смарт-контракта
      print('Минтинг NFT в блокчейне: ${nftData['name']}');
      
    } catch (e) {
      throw Exception('Ошибка минтинга в блокчейне: $e');
    }
  }
  
  // Передача NFT другому пользователю
  Future<bool> transferNFT(String tokenId, String toAddress) async {
    try {
      _setLoading(true);
      _error = null;
      
      // TODO: Реализовать transfer через смарт-контракт
      print('Передача NFT $tokenId на адрес $toAddress');
      
      // Обновляем список NFT
      await _loadNFTs();
      
      return true;
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== ТОКЕНЫ ЛОЯЛЬНОСТИ =====
  
  // Загрузка токенов лояльности
  Future<void> _loadLoyaltyTokens() async {
    if (_walletAddress == null) return;
    
    try {
      _setTokensLoading(true);
      _tokensError = null;
      
      if (_connectionMode == WalletConnectionMode.test) {
        // Используем тестовые данные
        final tokens = await _testService.getUserLoyaltyTokens(_walletAddress!.hex);
        _loyaltyTokens = tokens.map((token) => token.toJson()).toList();
      } else if (_connectionMode == WalletConnectionMode.metamask) {
        // В MetaMask режиме получаем данные из блокчейна
        // TODO: Реализовать получение токенов из блокчейна
        _loyaltyTokens = [];
      } else {
        // TODO: Реализовать API сервис для токенов лояльности
        _loyaltyTokens = [];
      }
      
      notifyListeners();
      
    } catch (e) {
      _tokensError = e.toString();
      notifyListeners();
    } finally {
      _setTokensLoading(false);
    }
  }
  
  // Создание токена лояльности
  Future<bool> createLoyaltyToken({
    required String name,
    required String symbol,
    required int totalSupply,
    required int decimals,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      
      // TODO: Создаем токен в блокчейне через смарт-контракт
      print('Создание токена лояльности: $name ($symbol)');
      
      // Обновляем список токенов
      await _loadLoyaltyTokens();
      
      return true;
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Передача токенов лояльности
  Future<bool> transferLoyaltyTokens(
    String tokenAddress,
    String toAddress,
    BigInt amount,
  ) async {
    try {
      _setLoading(true);
      _error = null;
      
      // TODO: Реализовать transfer через смарт-контракт
      print('Передача $amount токенов на адрес $toAddress');
      
      // Обновляем баланс
      await _updateBalance();
      
      return true;
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== ТРАНЗАКЦИИ =====
  
  // Загрузка истории транзакций
  Future<void> _loadTransactions() async {
    if (_walletAddress == null) return;
    
    try {
      _setTransactionsLoading(true);
      _transactionsError = null;
      
      if (_connectionMode == WalletConnectionMode.test) {
        // Используем тестовые данные
        final transactions = await _testService.getTransactionHistory(_walletAddress!.hex);
        _transactions = transactions.map((tx) => tx.toJson() as Map<String, dynamic>).toList();
      } else if (_connectionMode == WalletConnectionMode.metamask) {
        // В MetaMask режиме получаем данные из блокчейна
        // TODO: Реализовать получение транзакций из блокчейна
        _transactions = [];
      } else {
        // TODO: Получаем транзакции из блокчейна
        // Пока что используем пустой список
        _transactions = [];
      }
      
      notifyListeners();
      
    } catch (e) {
      _transactionsError = e.toString();
      notifyListeners();
    } finally {
      _setTransactionsLoading(false);
    }
  }
  
  // Отправка ETH
  Future<bool> sendETH(String toAddress, BigInt amount) async {
    try {
      _setLoading(true);
      _error = null;
      
      if (_credentials == null || _walletAddress == null) {
        throw Exception('Кошелек не подключен');
      }
      
      // TODO: Реализовать отправку транзакции через web3dart
      // Временная заглушка
      print('Отправка транзакции временно отключена');
      
      // Обновляем баланс
      await _updateBalance();
      
      // Обновляем историю транзакций
      await _loadTransactions();
      
      return true;
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== СМАРТ-КОНТРАКТЫ =====
  
  // Загрузка смарт-контрактов
  Future<void> loadSmartContracts() async {
    try {
      // TODO: Загружаем ABI и адреса смарт-контрактов
      // Пока что оставляем пустыми
      _nftContract = null;
      _loyaltyContract = null;
      
    } catch (e) {
      print('Ошибка загрузки смарт-контрактов: $e');
    }
  }
  
  // ===== META MASK СОБЫТИЯ =====
  
  /// Подписаться на события MetaMask
  void _subscribeToMetaMaskEvents() {
    // Подписка на подключение кошелька
    _metaMaskService.walletConnected.listen((walletInfo) {
      _walletAddress = EthereumAddress.fromHex(walletInfo.address);
      _balance = BigInt.from(double.parse(walletInfo.balance) * 1e18);
      _networkName = walletInfo.network;
      _isConnected = true;
      notifyListeners();
    });
    
    // Подписка на отключение кошелька
    _metaMaskService.walletDisconnected.listen((address) {
      _isConnected = false;
      _walletAddress = null;
      _balance = null;
      _networkName = null;
      notifyListeners();
    });
    
    // Подписка на смену сети
    _metaMaskService.networkChanged.listen((network) {
      _networkName = network.name;
      notifyListeners();
    });
    
    // Подписка на смену аккаунтов
    _metaMaskService.accountsChanged.listen((address) {
      _walletAddress = EthereumAddress.fromHex(address);
      _updateBalance();
      notifyListeners();
    });
  }
  
  // ===== IPFS ФУНКЦИИ =====
  
  /// Загрузить NFT метаданные в IPFS
  Future<String?> uploadNFTMetadataToIPFS({
    required String name,
    required String description,
    required String imageUrl,
    required String category,
    required Map<String, String> attributes,
  }) async {
    try {
      return await _ipfsService.uploadNFTMetadata(
        name: name,
        description: description,
        imageUrl: imageUrl,
        category: category,
        attributes: attributes,
      );
    } catch (e) {
      print('Error uploading NFT metadata to IPFS: $e');
      return null;
    }
  }
  
  /// Получить NFT метаданные из IPFS
  Future<Map<String, dynamic>?> getNFTMetadataFromIPFS(String ipfsHash) async {
    try {
      return await _ipfsService.getNFTMetadata(ipfsHash);
    } catch (e) {
      print('Error getting NFT metadata from IPFS: $e');
      return null;
    }
  }
  
  /// Получить изображение из IPFS
  Future<Uint8List?> getImageFromIPFS(String ipfsHash) async {
    try {
      return await _ipfsService.getImage(ipfsHash);
    } catch (e) {
      print('Error getting image from IPFS: $e');
      return null;
    }
  }
  
  /// Получить статистику IPFS кэша
  Map<String, dynamic> getIPFSCacheStats() {
    return _ipfsService.getCacheStats();
  }

  /// Очистить IPFS кэш
  void clearIPFSCache() {
    _ipfsService.clearCache();
  }

  /// Переключить IPFS Gateway
  void switchIPFSGateway() {
    _ipfsService.switchToNextGateway();
    notifyListeners();
  }
  
  // ===== УТИЛИТЫ =====
  
  // Получение статистики Web3
  Map<String, dynamic> getWeb3Stats() {
    return {
      'is_connected': _isConnected,
      'network_name': _networkName,
      'wallet_address': _walletAddress?.hex,
      'balance_eth': _balance != null ? _balance! : null,
      'nfts_count': _nfts.length,
      'loyalty_tokens_count': _loyaltyTokens.length,
      'transactions_count': _transactions.length,
      'connection_mode': _connectionMode.name,
      'is_test_mode': _isTestMode,
      'ipfs_gateway': _ipfsService.currentGateway,
      'ipfs_cache_stats': _ipfsService.getCacheStats(),
    };
  }
  
  // Очистка ошибок
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Переключение тестового режима
  void toggleTestMode() {
    _isTestMode = !_isTestMode;
    print('Тестовый режим: ${_isTestMode ? "включен" : "выключен"}');
    
    // Перезагружаем данные при смене режима
    if (_walletAddress != null) {
      _loadNFTs();
      _loadLoyaltyTokens();
      _loadTransactions();
    }
    
    notifyListeners();
  }
  
  /// Переключить режим подключения
  void switchConnectionMode(WalletConnectionMode mode) {
    if (_connectionMode != mode) {
      _connectionMode = mode;
      print('Режим подключения изменен на: ${mode.name}');
      
      // Если кошелек подключен, переподключаемся
      if (_isConnected) {
        disconnectWallet();
      }
      
      notifyListeners();
    }
  }
  
  /// Переключить на MetaMask режим
  void switchToMetaMask() {
    switchConnectionMode(WalletConnectionMode.metamask);
  }
  
  /// Переключить на тестовый режим
  void switchToTestMode() {
    switchConnectionMode(WalletConnectionMode.test);
  }
  
  /// Переключить на режим приватного ключа
  void switchToPrivateKeyMode() {
    switchConnectionMode(WalletConnectionMode.privatekey);
  }
  
  void clearNFTsError() {
    _nftsError = null;
    notifyListeners();
  }
  
  void clearTokensError() {
    _tokensError = null;
    notifyListeners();
  }
  
  void clearTransactionsError() {
    _transactionsError = null;
    notifyListeners();
  }
  
  // Приватные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setNFTsLoading(bool loading) {
    _isLoadingNFTs = loading;
    notifyListeners();
  }
  
  void _setTokensLoading(bool loading) {
    _isLoadingTokens = loading;
    notifyListeners();
  }
  
  void _setTransactionsLoading(bool loading) {
    _isLoadingTransactions = loading;
    notifyListeners();
  }
  
  // Получение баланса в читаемом формате
  String getBalanceInETH() {
    if (_balance == null) return '0.0';
    
    // Конвертируем wei в ETH (1 ETH = 10^18 wei)
    final ethValue = _balance! / BigInt.from(10).pow(18);
    final ethDecimal = (_balance! % BigInt.from(10).pow(18)) / BigInt.from(10).pow(14);
    return '${ethValue}.${ethDecimal.toString().padLeft(4, '0')}';
  }
  
  // Получение сокращенного адреса кошелька
  String getShortWalletAddress() {
    if (_walletAddress == null) return '';
    
    final address = _walletAddress!.hex;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
