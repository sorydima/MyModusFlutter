import 'package:flutter/foundation.dart';
import 'auth_provider.dart';
import 'product_provider.dart';
import 'social_provider.dart';
import 'web3_provider.dart';

class AppProvider extends ChangeNotifier {
  // Все провайдеры
  late final AuthProvider authProvider;
  late final ProductProvider productProvider;
  late final SocialProvider socialProvider;
  late final Web3Provider web3Provider;
  
  // Глобальное состояние приложения
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  String _currentTheme = 'light';
  String _currentLanguage = 'ru';

  // Геттеры
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentTheme => _currentTheme;
  String get currentLanguage => _currentLanguage;

  AppProvider() {
    _initializeProviders();
  }

  // Инициализация всех провайдеров
  void _initializeProviders() {
    authProvider = AuthProvider();
    productProvider = ProductProvider();
    socialProvider = SocialProvider();
    web3Provider = Web3Provider();
    
    // Слушаем изменения в провайдерах
    authProvider.addListener(_onAuthChanged);
    productProvider.addListener(_onProductChanged);
    socialProvider.addListener(_onSocialChanged);
    web3Provider.addListener(_onWeb3Changed);
  }

  // Инициализация приложения
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _setLoading(true);
      _error = null;
      
      // Инициализируем провайдеры в правильном порядке
      await Future.wait([
        authProvider.initialize(),
        productProvider.initialize(),
        web3Provider.initialize(),
      ]);
      
      // Инициализируем социальные функции только после аутентификации
      if (authProvider.isAuthenticated) {
        await socialProvider.initialize();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Переинициализация после изменения аутентификации
  Future<void> reinitializeAfterAuth() async {
    try {
      _setLoading(true);
      _error = null;
      
      if (authProvider.isAuthenticated) {
        // Пользователь вошел в систему
        await Future.wait([
          socialProvider.initialize(),
          web3Provider.initialize(),
        ]);
      } else {
        // Пользователь вышел из системы
        // Очищаем данные, которые требуют аутентификации
        // (это уже делается в провайдерах)
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Смена темы
  void changeTheme(String theme) {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      notifyListeners();
      // TODO: Сохранить выбор темы в SharedPreferences
    }
  }

  // Смена языка
  void changeLanguage(String language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
      // TODO: Сохранить выбор языка в SharedPreferences
      // TODO: Обновить локализацию
    }
  }

  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Приватные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Обработчики изменений в провайдерах
  void _onAuthChanged() {
    // Если изменился статус аутентификации, переинициализируем
    if (_isInitialized) {
      reinitializeAfterAuth();
    }
  }

  void _onProductChanged() {
    // Уведомляем об изменениях в продуктах
    notifyListeners();
  }

  void _onSocialChanged() {
    // Уведомляем об изменениях в социальных функциях
    notifyListeners();
  }

  void _onWeb3Changed() {
    // Уведомляем об изменениях в Web3
    notifyListeners();
  }

  // Получение глобальной статистики
  Map<String, dynamic> getGlobalStats() {
    return {
      'auth': {
        'is_authenticated': authProvider.isAuthenticated,
        'user_id': authProvider.userId,
        'user_name': authProvider.userName,
        'is_admin': authProvider.isAdmin,
      },
      'products': productProvider.getProductStats(),
      'social': socialProvider.getSocialStats(),
      'web3': web3Provider.getWeb3Stats(),
      'app': {
        'theme': _currentTheme,
        'language': _currentLanguage,
        'initialized': _isInitialized,
      },
    };
  }

  // Проверка, есть ли активные ошибки
  bool get hasErrors {
    return _error != null ||
           authProvider.error != null ||
           productProvider.error != null ||
           socialProvider.postsError != null ||
           socialProvider.chatsError != null ||
           web3Provider.error != null ||
           web3Provider.nftsError != null ||
           web3Provider.tokensError != null ||
           web3Provider.transactionsError != null;
  }

  // Получение всех ошибок
  List<String> getAllErrors() {
    final errors = <String>[];
    
    if (_error != null) errors.add('App: $_error');
    if (authProvider.error != null) errors.add('Auth: ${authProvider.error}');
    if (productProvider.error != null) errors.add('Products: ${productProvider.error}');
    if (socialProvider.postsError != null) errors.add('Social Posts: ${socialProvider.postsError}');
    if (socialProvider.chatsError != null) errors.add('Social Chats: ${socialProvider.chatsError}');
    if (web3Provider.error != null) errors.add('Web3: ${web3Provider.error}');
    if (web3Provider.nftsError != null) errors.add('Web3 NFTs: ${web3Provider.nftsError}');
    if (web3Provider.tokensError != null) errors.add('Web3 Tokens: ${web3Provider.tokensError}');
    if (web3Provider.transactionsError != null) errors.add('Web3 Transactions: ${web3Provider.transactionsError}');
    
    return errors;
  }

  // Очистка всех ошибок
  void clearAllErrors() {
    _error = null;
    authProvider.clearError();
    productProvider.clearError();
    socialProvider.clearPostsError();
    socialProvider.clearChatsError();
    web3Provider.clearError();
    web3Provider.clearNFTsError();
    web3Provider.clearTokensError();
    web3Provider.clearTransactionsError();
    notifyListeners();
  }

  // Проверка, загружается ли что-то
  bool get isAnythingLoading {
    return _isLoading ||
           authProvider.isLoading ||
           productProvider.isLoading ||
           socialProvider.isLoadingPosts ||
           socialProvider.isLoadingChats ||
           web3Provider.isLoading ||
           web3Provider.isLoadingNFTs ||
           web3Provider.isLoadingTokens ||
           web3Provider.isLoadingTransactions;
  }

  // Получение статуса загрузки для конкретного раздела
  Map<String, bool> getLoadingStatus() {
    return {
      'app': _isLoading,
      'auth': authProvider.isLoading,
      'products': productProvider.isLoading,
      'social_posts': socialProvider.isLoadingPosts,
      'social_chats': socialProvider.isLoadingChats,
      'web3': web3Provider.isLoading,
      'web3_nfts': web3Provider.isLoadingNFTs,
      'web3_tokens': web3Provider.isLoadingTokens,
      'web3_transactions': web3Provider.isLoadingTransactions,
    };
  }

  // Очистка ресурсов
  @override
  void dispose() {
    // Убираем слушателей
    authProvider.removeListener(_onAuthChanged);
    productProvider.removeListener(_onProductChanged);
    socialProvider.removeListener(_onSocialChanged);
    web3Provider.removeListener(_onWeb3Changed);
    
    // Очищаем провайдеры
    authProvider.dispose();
    productProvider.dispose();
    socialProvider.dispose();
    web3Provider.dispose();
    
    super.dispose();
  }
}
