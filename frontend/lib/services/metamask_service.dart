import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import '../models/web3_models.dart';

// Временный класс WalletInfo для совместимости
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

/// Сервис для интеграции с MetaMask кошельком
/// Обрабатывает подключение, события и взаимодействие с кошельком
class MetaMaskService {
  static const String _ethereumProvider = 'ethereum';
  
  // Stream контроллеры для событий
  final StreamController<WalletInfo> _walletConnectedController = StreamController<WalletInfo>.broadcast();
  final StreamController<String> _walletDisconnectedController = StreamController<String>.broadcast();
  final StreamController<NetworkInfo> _networkChangedController = StreamController<NetworkInfo>.broadcast();
  final StreamController<String> _accountsChangedController = StreamController<String>.broadcast();
  
  // Состояние подключения
  bool _isConnected = false;
  String? _currentAddress;
  NetworkInfo? _currentNetwork;
  
  // Геттеры
  bool get isConnected => _isConnected;
  String? get currentAddress => _currentAddress;
  NetworkInfo? get currentNetwork => _currentNetwork;
  
  // Streams для событий
  Stream<WalletInfo> get walletConnected => _walletConnectedController.stream;
  Stream<String> get walletDisconnected => _walletDisconnectedController.stream;
  Stream<NetworkInfo> get networkChanged => _networkChangedController.stream;
  Stream<String> get accountsChanged => _accountsChangedController.stream;
  
  /// Проверить доступность MetaMask
  Future<bool> isMetaMaskAvailable() async {
    try {
      // В Flutter Web проверяем доступность ethereum объекта
      // В мобильном приложении используем WebView или deep linking
      if (kIsWeb) {
        // Проверка для веб-версии
        return _checkWebProvider();
      } else {
        // Для мобильной версии проверяем возможность deep linking
        return await _checkMobileProvider();
      }
    } catch (e) {
      print('Error checking MetaMask availability: $e');
      return false;
    }
  }
  
  /// Проверить веб-провайдер
  bool _checkWebProvider() {
    try {
      // Проверяем наличие ethereum объекта в window
      // Это будет работать только в веб-версии
      return true; // Пока возвращаем true для демонстрации
    } catch (e) {
      return false;
    }
  }
  
  /// Проверить мобильный провайдер
  Future<bool> _checkMobileProvider() async {
    try {
      // Для мобильной версии проверяем возможность открытия MetaMask
      // или использования WalletConnect
      return true; // Пока возвращаем true для демонстрации
    } catch (e) {
      return false;
    }
  }
  
  /// Подключиться к MetaMask
  Future<WalletInfo?> connectWallet() async {
    try {
      if (!await isMetaMaskAvailable()) {
        throw Exception('MetaMask не доступен');
      }
      
      // Запрашиваем подключение к кошельку
      final accounts = await _requestAccounts();
      if (accounts.isEmpty) {
        throw Exception('Не удалось получить аккаунты');
      }
      
      final address = accounts.first;
      final network = await _getCurrentNetwork();
      
      // Обновляем состояние
      _isConnected = true;
      _currentAddress = address;
      _currentNetwork = network;
      
      // Создаем информацию о кошельке
      final walletInfo = WalletInfo(
        address: address,
        balance: await getBalance(address),
        network: network.name,
        isConnected: true,

      );
      
      // Отправляем событие подключения
      _walletConnectedController.add(walletInfo);
      
      // Подписываемся на события
      _subscribeToEvents();
      
      return walletInfo;
      
    } catch (e) {
      print('Error connecting to MetaMask: $e');
      return null;
    }
  }
  
  /// Запросить аккаунты у пользователя
  Future<List<String>> _requestAccounts() async {
    try {
      // В реальном приложении здесь будет вызов ethereum.request
      // Пока что используем mock данные для демонстрации
      await Future.delayed(Duration(seconds: 1));
      return ['0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6'];
    } catch (e) {
      print('Error requesting accounts: $e');
      return [];
    }
  }
  
  /// Получить текущую сеть
  Future<NetworkInfo> _getCurrentNetwork() async {
    try {
      // В реальном приложении получаем chainId и определяем сеть
      await Future.delayed(Duration(milliseconds: 500));
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
      print('Error getting current network: $e');
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
  
  /// Получить баланс кошелька
  Future<String> getBalance(String address) async {
    try {
      // В реальном приложении получаем баланс через RPC
      await Future.delayed(Duration(milliseconds: 300));
      return '2.5'; // Mock баланс
    } catch (e) {
      print('Error getting balance: $e');
      return '0.0';
    }
  }

  /// Получить историю транзакций
  Future<List<TransactionModel>> getTransactionHistory(String address) async {
    try {
      // В реальном приложении получаем транзакции через RPC
      await Future.delayed(Duration(milliseconds: 500));
      
      // Mock транзакции для демонстрации
      return [
        TransactionModel(
          hash: '0x1234...5678',
          from: address,
          to: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          value: '0.1',
          gasUsed: '21000',
          gasPrice: '20000000000',
          blockNumber: 12345678,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          status: TransactionStatus.confirmed,
          type: TransactionType.transfer,
          network: 'Ethereum Mainnet',
        ),
        TransactionModel(
          hash: '0x8765...4321',
          from: address,
          to: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          value: '0.05',
          gasUsed: '65000',
          gasPrice: '25000000000',
          blockNumber: 12345677,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: TransactionStatus.confirmed,
          type: TransactionType.swap,
          network: 'Ethereum Mainnet',
        ),
      ];
    } catch (e) {
      print('Error getting transaction history: $e');
      return [];
    }
  }

  /// Отправить транзакцию
  Future<String?> sendTransaction({
    required String from,
    required String to,
    required String value,
    String? data,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Кошелек не подключен');
      }
      
      // В реальном приложении отправляем транзакцию через RPC
      await Future.delayed(Duration(seconds: 3));
      
      // Возвращаем mock хеш транзакции
      return '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16).padLeft(64, '0')}';
    } catch (e) {
      print('Error sending transaction: $e');
      return null;
    }
  }
  
  /// Подписаться на события MetaMask
  void _subscribeToEvents() {
    // В реальном приложении подписываемся на события ethereum
    // Пока что используем mock события для демонстрации
    
    // Событие смены сети
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _simulateNetworkChange();
      } else {
        timer.cancel();
      }
    });
    
    // Событие смены аккаунтов
    Timer.periodic(Duration(seconds: 45), (timer) {
      if (_isConnected) {
        _simulateAccountsChange();
      } else {
        timer.cancel();
      }
    });
  }
  
  /// Симуляция смены сети (для демонстрации)
  void _simulateNetworkChange() {
    if (_currentNetwork != null) {
      final newNetwork = NetworkInfo(
        name: 'Mumbai Testnet',
        chainId: 80001,
        rpcUrl: 'https://polygon-mumbai.infura.io/v3/YOUR_INFURA_PROJECT_ID',
        explorerUrl: 'https://mumbai.polygonscan.com',
        nativeCurrency: 'MATIC',
        decimals: 18,
        isTestnet: true,
      );
      
      _currentNetwork = newNetwork;
      _networkChangedController.add(newNetwork);
    }
  }
  
  /// Симуляция смены аккаунтов (для демонстрации)
  void _simulateAccountsChange() {
    if (_currentAddress != null) {
      final newAddress = '0x9876543210987654321098765432109876543210';
      _currentAddress = newAddress;
      _accountsChangedController.add(newAddress);
    }
  }
  
  /// Отключиться от MetaMask
  Future<bool> disconnectWallet() async {
    try {
      // В реальном приложении очищаем состояние и отписываемся от событий
      _isConnected = false;
      final oldAddress = _currentAddress;
      _currentAddress = null;
      _currentNetwork = null;
      
      // Отправляем событие отключения
      if (oldAddress != null) {
        _walletDisconnectedController.add(oldAddress);
      }
      
      return true;
    } catch (e) {
      print('Error disconnecting from MetaMask: $e');
      return false;
    }
  }
  
  /// Подписать сообщение
  Future<String?> signMessage(String message) async {
    try {
      if (!_isConnected || _currentAddress == null) {
        throw Exception('Кошелек не подключен');
      }
      
      // В реальном приложении вызываем ethereum.request для подписи
      await Future.delayed(Duration(seconds: 2));
      
      // Возвращаем mock подпись
      return '0x${message.hashCode.toRadixString(16).padLeft(64, '0')}';
      
    } catch (e) {
      print('Error signing message: $e');
      return null;
    }
  }
  
  /// Подписать транзакцию
  Future<String?> signTransaction(Map<String, dynamic> transaction) async {
    try {
      if (!_isConnected || _currentAddress == null) {
        throw Exception('Кошелек не подключен');
      }
      
      // В реальном приложении вызываем ethereum.request для подписи транзакции
      await Future.delayed(Duration(seconds: 3));
      
      // Возвращаем mock hash транзакции
      return '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16).padLeft(64, '0')}';
      
    } catch (e) {
      print('Error signing transaction: $e');
      return null;
    }
  }
  
  /// Переключить сеть
  Future<bool> switchNetwork(int chainId) async {
    try {
      if (!_isConnected) {
        throw Exception('Кошелек не подключен');
      }
      
      // В реальном приложении вызываем wallet_switchEthereumChain
      await Future.delayed(Duration(seconds: 2));
      
      // Обновляем текущую сеть
      final newNetwork = _getNetworkByChainId(chainId);
      if (newNetwork != null) {
        _currentNetwork = newNetwork;
        _networkChangedController.add(newNetwork);
        return true;
      }
      
      return false;
      
    } catch (e) {
      print('Error switching network: $e');
      return false;
    }
  }
  
  /// Добавить сеть
  Future<bool> addNetwork(NetworkInfo network) async {
    try {
      if (!_isConnected) {
        throw Exception('Кошелек не подключен');
      }
      
      // В реальном приложении вызываем wallet_addEthereumChain
      await Future.delayed(Duration(seconds: 2));
      
      return true;
      
    } catch (e) {
      print('Error adding network: $e');
      return false;
    }
  }
  
  /// Получить сеть по chainId
  NetworkInfo? _getNetworkByChainId(int chainId) {
    switch (chainId) {
      case 1:
        return NetworkInfo(
          name: 'Ethereum Mainnet',
          chainId: 1,
          rpcUrl: 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
          explorerUrl: 'https://etherscan.io',
          nativeCurrency: 'ETH',
          decimals: 18,
          isTestnet: false,
        );
      case 11155111:
        return NetworkInfo(
          name: 'Sepolia Testnet',
          chainId: 11155111,
          rpcUrl: 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID',
          explorerUrl: 'https://sepolia.etherscan.io',
          nativeCurrency: 'ETH',
          decimals: 18,
          isTestnet: true,
        );
      case 80001:
        return NetworkInfo(
          name: 'Mumbai Testnet',
          chainId: 80001,
          rpcUrl: 'https://polygon-mumbai.infura.io/v3/YOUR_INFURA_PROJECT_ID',
          explorerUrl: 'https://mumbai.polygonscan.com',
          nativeCurrency: 'MATIC',
          decimals: 18,
          isTestnet: true,
        );
      case 137:
        return NetworkInfo(
          name: 'Polygon Mainnet',
          chainId: 137,
          rpcUrl: 'https://polygon-rpc.com',
          explorerUrl: 'https://polygonscan.com',
          nativeCurrency: 'MATIC',
          decimals: 18,
          isTestnet: false,
        );
      default:
        return null;
    }
  }
  
  /// Получить список поддерживаемых сетей
  List<NetworkInfo> getSupportedNetworks() {
    return [
      NetworkInfo(
        name: 'Ethereum Mainnet',
        chainId: 1,
        rpcUrl: 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
        explorerUrl: 'https://etherscan.io',
        nativeCurrency: 'ETH',
        decimals: 18,
        isTestnet: false,
      ),
      NetworkInfo(
        name: 'Sepolia Testnet',
        chainId: 11155111,
        rpcUrl: 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID',
        explorerUrl: 'https://sepolia.etherscan.io',
        nativeCurrency: 'ETH',
        decimals: 18,
        isTestnet: true,
      ),
      NetworkInfo(
        name: 'Mumbai Testnet',
        chainId: 80001,
        rpcUrl: 'https://polygon-mumbai.infura.io/v3/YOUR_INFURA_PROJECT_ID',
        explorerUrl: 'https://mumbai.polygonscan.com',
        nativeCurrency: 'MATIC',
        decimals: 18,
        isTestnet: true,
      ),
      NetworkInfo(
        name: 'Polygon Mainnet',
        chainId: 137,
        rpcUrl: 'https://polygon-rpc.com',
        explorerUrl: 'https://polygonscan.com',
        nativeCurrency: 'MATIC',
        decimals: 18,
        isTestnet: false,
      ),
    ];
  }
  
  /// Освободить ресурсы
  void dispose() {
    _walletConnectedController.close();
    _walletDisconnectedController.close();
    _networkChangedController.close();
    _accountsChangedController.close();
  }
}
