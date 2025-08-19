import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

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
  String _getNetworkName(int chainId) {
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
      
      // TODO: Реализовать подключение через MetaMask
      // Пока что возвращаем ошибку
      throw UnimplementedError('MetaMask подключение в разработке');
      
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
      _balance = await _web3Client!.getBalance(_walletAddress!);
      notifyListeners();
    } catch (e) {
      print('Ошибка получения баланса: $e');
    }
  }
  
  // Отключение кошелька
  Future<void> disconnectWallet() async {
    try {
      _isConnected = false;
      _walletAddress = null;
      _credentials = null;
      _balance = null;
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
      
      // Получаем NFT с backend
      final nfts = await _apiService.getNFTs();
      _nfts = nfts;
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
      
      // Сначала создаем NFT на backend
      final nftData = await _apiService.mintNFT(
        name: name,
        description: description,
        imageUrl: imageUrl,
        tokenType: tokenType,
      );
      
      // TODO: Минтим NFT в блокчейне через смарт-контракт
      if (_nftContract != null && _credentials != null) {
        await _mintNFTOnBlockchain(nftData);
      }
      
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
      
      final tokens = await _apiService.getLoyaltyTokens();
      _loyaltyTokens = tokens;
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
      
      // TODO: Получаем транзакции из блокчейна
      // Пока что используем пустой список
      _transactions = [];
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
      
      // Создаем транзакцию
      final transaction = Transaction(
        to: EthereumAddress.fromHex(toAddress),
        value: amount,
        gasPrice: EtherAmount.fromUnit(EtherUnit.gwei, 20),
        maxGas: 21000,
      );
      
      // Отправляем транзакцию
      final hash = await _web3Client!.sendTransaction(
        _credentials!,
        transaction,
        chainId: 1337, // Ganache chainId
      );
      
      print('Транзакция отправлена: $hash');
      
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
  
  // ===== УТИЛИТЫ =====
  
  // Получение статистики Web3
  Map<String, dynamic> getWeb3Stats() {
    return {
      'is_connected': _isConnected,
      'network_name': _networkName,
      'wallet_address': _walletAddress?.hex,
      'balance_eth': _balance != null ? EtherAmount.fromWei(_balance!) : null,
      'nfts_count': _nfts.length,
      'loyalty_tokens_count': _loyaltyTokens.length,
      'transactions_count': _transactions.length,
    };
  }
  
  // Очистка ошибок
  void clearError() {
    _error = null;
    notifyListeners();
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
    
    final ethAmount = EtherAmount.fromWei(_balance!);
    return ethAmount.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
  }
  
  // Получение сокращенного адреса кошелька
  String getShortWalletAddress() {
    if (_walletAddress == null) return '';
    
    final address = _walletAddress!.hex;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
