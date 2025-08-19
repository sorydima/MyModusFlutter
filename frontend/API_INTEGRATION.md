# 🔌 API Integration Guide - Flutter Frontend

Этот документ описывает интеграцию Flutter frontend с backend API MyModus.

## 📋 Содержание

- [Обзор архитектуры](#обзор-архитектуры)
- [API Service](#api-service)
- [State Management](#state-management)
- [Использование в UI](#использование-в-ui)
- [Обработка ошибок](#обработка-ошибок)
- [Примеры использования](#примеры-использования)

## 🏗 Обзор архитектуры

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Widgets    │◄──►│   Providers     │◄──►│   API Service   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Screens       │    │   State         │    │   HTTP Client   │
│   & Widgets     │    │   Management    │    │   & Storage     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Компоненты:

1. **API Service** - слой для HTTP запросов к backend
2. **Providers** - управление состоянием с помощью Provider pattern
3. **UI Widgets** - Flutter виджеты, использующие провайдеры

## 🔧 API Service

### Основные возможности

- **HTTP клиент** с поддержкой GET, POST, PUT, DELETE
- **Автоматическое обновление токенов** (refresh token)
- **Безопасное хранение** токенов в FlutterSecureStorage
- **Обработка ошибок** и статус кодов
- **CORS поддержка** для web платформы

### Конфигурация

```dart
class ApiService {
  static const String _baseUrl = 'http://localhost:8080';
  static const String _apiVersion = '/api/v1';
  
  // Для production измените на ваш домен
  // static const String _baseUrl = 'https://api.mymodus.com';
}
```

### Методы аутентификации

```dart
// Регистрация
Future<Map<String, dynamic>> register({
  required String email,
  required String password,
  required String name,
  String? phone,
})

// Вход в систему
Future<Map<String, dynamic>> login(String email, String password)

// Выход из системы
Future<void> logout()

// Получение профиля
Future<Map<String, dynamic>> getProfile()

// Обновление профиля
Future<Map<String, dynamic>> updateProfile({
  String? name,
  String? phone,
  String? bio,
  String? avatarUrl,
})
```

### Методы для продуктов

```dart
// Получение списка продуктов
Future<List<ProductModel>> getProducts({
  int limit = 50,
  int offset = 0,
  String? category,
  String? search,
  Encrypt? sortBy,
  String? sortOrder,
})

// Получение продукта по ID
Future<ProductModel> getProduct(String productId)

// Получение категорий
Future<List<Map<String, dynamic>>> getCategories()

// История цен продукта
Future<List<Map<String, dynamic>>> getPriceHistory(String productId)
```

### Методы для социальных функций

```dart
// Получение постов
Future<List<Map<String, dynamic>>> getPosts({
  int limit = 20,
  int offset = 0,
  String? userId,
})

// Создание поста
Future<Map<String, dynamic>> createPost({
  required String caption,
  List<String>? imageUrls,
  List<String>? hashtags,
})

// Лайк/анлайк поста
Future<void> likePost(String postId)
Future<void> unlikePost(String postId)

// Добавление комментария
Future<Map<String, dynamic>> addComment({
  required String postId,
  required String content,
})
```

### Методы для Web3

```dart
// Подключение кошелька
Future<Map<String, dynamic>> connectWallet(String walletAddress)

// Получение NFT
Future<List<Map<String, dynamic>>> getNFTs()

// Создание NFT
Future<Map<String, dynamic>> mintNFT({
  required String name,
  required String description,
  required String imageUrl,
  required String tokenType,
})

// Токены лояльности
Future<List<Map<String, dynamic>>> getLoyaltyTokens()
```

## 🎯 State Management

### Архитектура провайдеров

```
AppProvider (главный)
├── AuthProvider (аутентификация)
├── ProductProvider (продукты)
├── SocialProvider (социальные функции)
└── Web3Provider (Web3 функции)
```

### AppProvider

Главный провайдер, который:
- Управляет жизненным циклом всех провайдеров
- Обрабатывает глобальные ошибки
- Управляет темой и языком
- Координирует инициализацию

```dart
class AppProvider extends ChangeNotifier {
  late final AuthProvider authProvider;
  late final ProductProvider productProvider;
  late final SocialProvider socialProvider;
  late final Web3Provider web3Provider;
  
  // Глобальное состояние
  bool _isInitialized = false;
  String _currentTheme = 'light';
  String _currentLanguage = 'ru';
}
```

### AuthProvider

Управляет состоянием аутентификации:

```dart
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _error;
  
  // Методы
  Future<bool> login(String email, String password)
  Future<bool> register({...})
  Future<void> logout()
  Future<bool> updateProfile({...})
}
```

### ProductProvider

Управляет состоянием продуктов:

```dart
class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  
  // Методы
  Future<void> loadProducts({bool refresh = false})
  Future<void> updateFilters({...})
  Future<void> searchProducts(String query)
}
```

### SocialProvider

Управляет социальными функциями:

```dart
class SocialProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _chats = [];
  
  // Методы
  Future<void> loadPosts({bool refresh = false})
  Future<bool> createPost({...})
  Future<void> likePost(String postId)
  Future<bool> sendMessage({...})
}
```

### Web3Provider

Управляет Web3 функциями:

```dart
class Web3Provider extends ChangeNotifier {
  bool _isConnected = false;
  String? _walletAddress;
  List<Map<String, dynamic>> _nfts = [];
  
  // Методы
  Future<bool> connectWallet(String walletAddress)
  Future<void> loadNFTs()
  Future<bool> mintNFT({...})
}
```

## 🎨 Использование в UI

### Подключение провайдера

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Text('Привет, ${appProvider.authProvider.userName}!');
      },
    );
  }
}
```

### Доступ к конкретному провайдеру

```dart
class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final productProvider = appProvider.productProvider;
        
        if (productProvider.isLoading) {
          return CircularProgressIndicator();
        }
        
        return ListView.builder(
          itemCount: productProvider.products.length,
          itemBuilder: (context, index) {
            final product = productProvider.products[index];
            return ProductCard(product: product);
          },
        );
      },
    );
  }
}
```

### Вызов методов провайдера

```dart
class LoginForm extends StatelessWidget {
  Future<void> _handleLogin(BuildContext context) async {
    final appProvider = context.read<AppProvider>();
    
    final success = await appProvider.authProvider.login(
      'user@example.com',
      'password123',
    );
    
    if (success) {
      // Вход успешен
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Добро пожаловать!')),
      );
    }
  }
}
```

## ⚠️ Обработка ошибок

### Автоматическая обработка

API Service автоматически:
- Обрабатывает HTTP статус коды
- Обновляет токены при 401 ошибке
- Логирует сетевые ошибки

### Обработка в UI

```dart
Consumer<AppProvider>(
  builder: (context, appProvider, child) {
    if (appProvider.hasErrors) {
      return ErrorWidget(
        errors: appProvider.getAllErrors(),
        onRetry: () => appProvider.clearAllErrors(),
      );
    }
    
    return YourContent();
  },
)
```

### Показ ошибок конкретного провайдера

```dart
Consumer<AppProvider>(
  builder: (context, appProvider, child) {
    final authProvider = appProvider.authProvider;
    
    if (authProvider.error != null) {
      return Container(
        padding: EdgeInsets.all(16),
        color: Colors.red.shade100,
        child: Text(authProvider.error!),
      );
    }
    
    return YourContent();
  },
)
```

## 📱 Примеры использования

### Экран входа

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final authProvider = appProvider.authProvider;
        
        return Scaffold(
          body: Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  child: authProvider.isLoading 
                    ? CircularProgressIndicator()
                    : Text('Войти'),
                ),
                if (authProvider.error != null)
                  Text(authProvider.error!, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### Список продуктов

```dart
class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final productProvider = appProvider.productProvider;
        
        return Scaffold(
          appBar: AppBar(title: Text('Продукты')),
          body: RefreshIndicator(
            onRefresh: () => productProvider.loadProducts(refresh: true),
            child: productProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
                    return ProductCard(product: product);
                  },
                ),
          ),
        );
      },
    );
  }
}
```

### Создание поста

```dart
class CreatePostScreen extends StatelessWidget {
  Future<void> _createPost(BuildContext context, String caption) async {
    final appProvider = context.read<AppProvider>();
    
    final success = await appProvider.socialProvider.createPost(
      caption: caption,
      hashtags: ['мода', 'стиль'],
    );
    
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пост создан!')),
      );
    }
  }
}
```

## 🔒 Безопасность

### Токены

- Access token хранится в памяти
- Refresh token хранится в FlutterSecureStorage
- Автоматическое обновление при истечении

### Валидация

- Валидация email формата
- Проверка минимальной длины пароля
- Санитизация пользовательского ввода

### HTTPS

- В production используйте HTTPS
- Обновите `_baseUrl` в ApiService

## 🚀 Производительность

### Кэширование

- Продукты кэшируются в памяти
- Категории загружаются один раз
- Пагинация для больших списков

### Оптимизация

- Lazy loading для изображений
- Debounced поиск
- Виртуализация длинных списков

## 🧪 Тестирование

### Mock API Service

```dart
class MockApiService extends ApiService {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    return {'success': true, 'user': {'id': '1', 'name': 'Test User'}};
  }
}
```

### Тестирование провайдеров

```dart
test('AuthProvider should authenticate user on successful login', () async {
  final mockApi = MockApiService();
  final provider = AuthProvider();
  
  final result = await provider.login('test@example.com', 'password');
  
  expect(result, true);
  expect(provider.isAuthenticated, true);
});
```

## 📚 Дополнительные ресурсы

- [Provider документация](https://pub.dev/packages/provider)
- [HTTP пакет](https://pub.dev/packages/http)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Flutter тестирование](https://docs.flutter.dev/testing)

## 🤝 Поддержка

При возникновении проблем:

1. Проверьте консоль на наличие ошибок
2. Убедитесь, что backend запущен
3. Проверьте настройки сети
4. Обратитесь к документации backend API

---

**Версия документации:** 1.0.0  
**Последнее обновление:** ${new Date().toLocaleDateString()}
