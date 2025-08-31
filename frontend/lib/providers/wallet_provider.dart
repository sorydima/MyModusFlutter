import 'package:flutter/foundation.dart';
import '../models/web3_models.dart';
import '../services/metamask_service.dart';

class WalletProvider extends ChangeNotifier {
  final MetaMaskService _metaMaskService = MetaMaskService();
  
  // Состояние кошелька
  bool _isConnected = false;
  String? _currentAddress;
  NetworkInfo? _currentNetwork;
  String _balance = '0.0';
  List<TransactionModel> _transactions = [];
  
  // Состояние загрузки
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  bool get isConnected => _isConnected;
  String? get currentAddress => _currentAddress;
  NetworkInfo? get currentNetwork => _currentNetwork;
  String get balance => _balance;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Инициализация
  WalletProvider() {
    _initializeWallet();
  }
  
  Future<void> _initializeWallet() async {
    try {
      _setLoading(true);
      
      // Проверяем доступность MetaMask
      final isAvailable = await _metaMaskService.isMetaMaskAvailable();
      if (!isAvailable) {
        _setError('MetaMask не доступен');
        return;
      }
      
      // Подписываемся на события кошелька
      _metaMaskService.walletConnected.listen(_onWalletConnected);
      _metaMaskService.walletDisconnected.listen(_onWalletDisconnected);
      _metaMaskService.networkChanged.listen(_onNetworkChanged);
      _metaMaskService.accountsChanged.listen(_onAccountsChanged);
      
      // Проверяем текущее состояние подключения
      await _checkConnectionStatus();
      
    } catch (e) {
      _setError('Ошибка инициализации кошелька: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Подключение к кошельку
  Future<void> connectWallet() async {
    try {
      _setLoading(true);
      _clearError();
      
      final walletInfo = await _metaMaskService.connectWallet();
      if (walletInfo != null) {
        _onWalletConnected(walletInfo);
      } else {
        _setError('Не удалось подключиться к кошельку');
      }
      
    } catch (e) {
      _setError('Ошибка подключения: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Отключение от кошелька
  Future<void> disconnectWallet() async {
    try {
      _setLoading(true);
      
      await _metaMaskService.disconnectWallet();
      _onWalletDisconnected('');
      
    } catch (e) {
      _setError('Ошибка отключения: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Переключение сети
  Future<void> switchNetwork(NetworkInfo network) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _metaMaskService.switchNetwork(network.chainId);
      if (success) {
        _currentNetwork = network;
        notifyListeners();
        
        // Обновляем баланс для новой сети
        await _updateBalance();
      } else {
        _setError('Не удалось переключить сеть');
      }
      
    } catch (e) {
      _setError('Ошибка переключения сети: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Обновление баланса
  Future<void> _updateBalance() async {
    if (!_isConnected || _currentAddress == null) return;
    
    try {
      final balance = await _metaMaskService.getBalance(_currentAddress!);
      _balance = balance;
      notifyListeners();
    } catch (e) {
      print('Ошибка обновления баланса: $e');
    }
  }
  
  // Загрузка транзакций
  Future<void> loadTransactions() async {
    if (!_isConnected || _currentAddress == null) return;
    
    try {
      _setLoading(true);
      _clearError();
      
      final transactions = await _metaMaskService.getTransactionHistory(_currentAddress!);
      _transactions = transactions;
      notifyListeners();
      
    } catch (e) {
      _setError('Ошибка загрузки транзакций: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Отправка транзакции
  Future<String?> sendTransaction({
    required String to,
    required String amount,
    String? data,
  }) async {
    if (!_isConnected || _currentAddress == null) {
      _setError('Кошелек не подключен');
      return null;
    }
    
    try {
      _setLoading(true);
      _clearError();
      
      final txHash = await _metaMaskService.sendTransaction(
        from: _currentAddress!,
        to: to,
        value: amount,
        data: data,
      );
      
      if (txHash != null) {
        // Обновляем баланс и транзакции
        await _updateBalance();
        await loadTransactions();
        
        return txHash;
      } else {
        _setError('Не удалось отправить транзакцию');
        return null;
      }
      
    } catch (e) {
      _setError('Ошибка отправки транзакции: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Проверка статуса подключения
  Future<void> _checkConnectionStatus() async {
    try {
      final isConnected = await _metaMaskService.isConnected;
      if (isConnected) {
        final address = _metaMaskService.currentAddress;
        final network = _metaMaskService.currentNetwork;
        
        if (address != null && network != null) {
          _onWalletConnected(WalletInfo(
            address: address,
            balance: '0.0',
            network: network.name,
            isConnected: true,
          ));
        }
      }
    } catch (e) {
      print('Ошибка проверки статуса подключения: $e');
    }
  }
  
  // Обработчики событий
  void _onWalletConnected(WalletInfo walletInfo) {
    _isConnected = true;
    _currentAddress = walletInfo.address;
    _currentNetwork = NetworkInfo(
      name: walletInfo.network,
      chainId: 1, // TODO: Получить реальный chainId
      rpcUrl: '',
      explorerUrl: '',
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: false,
    );
    
    // Обновляем баланс и загружаем транзакции
    _updateBalance();
    loadTransactions();
    
    notifyListeners();
  }
  
  void _onWalletDisconnected(String address) {
    _isConnected = false;
    _currentAddress = null;
    _currentNetwork = null;
    _balance = '0.0';
    _transactions.clear();
    
    notifyListeners();
  }
  
  void _onNetworkChanged(NetworkInfo network) {
    _currentNetwork = network;
    notifyListeners();
    
    // Обновляем баланс для новой сети
    _updateBalance();
  }
  
  void _onAccountsChanged(String address) {
    if (address != _currentAddress) {
      _currentAddress = address;
      notifyListeners();
      
      // Обновляем баланс и транзакции для нового адреса
      _updateBalance();
      loadTransactions();
    }
  }
  
  // Вспомогательные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Очистка ресурсов
  @override
  void dispose() {
    super.dispose();
  }
}
