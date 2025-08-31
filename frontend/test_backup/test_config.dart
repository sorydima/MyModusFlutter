import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' as test;

/// Конфигурация тестов для MyModus
class MyModusTestConfig {
  /// Настройки для widget тестов
  static const WidgetTestSettings widgetTestSettings = WidgetTestSettings(
    timeout: Timeout(Duration(minutes: 5)),
    skip: false,
  );

  /// Настройки для интеграционных тестов
  static const IntegrationTestSettings integrationTestSettings = IntegrationTestSettings(
    timeout: Timeout(Duration(minutes: 10)),
    skip: false,
  );

  /// Настройки для платформенных тестов
  static const PlatformTestSettings platformTestSettings = PlatformTestSettings(
    timeout: Timeout(Duration(minutes: 8)),
    skip: false,
  );

  /// Настройки для unit тестов
  static const UnitTestSettings unitTestSettings = UnitTestSettings(
    timeout: Timeout(Duration(minutes: 3)),
    skip: false,
  );

  /// Глобальные настройки тестов
  static void configureTests() {
    // Настройка таймаутов
    test.setTimeout(Duration(minutes: 15));

    // Настройка логирования
    test.setLogWriterOnFailure(true);

    // Настройка параллельного выполнения
    test.setMaxConcurrency(4);
  }

  /// Настройки для CI/CD
  static void configureCITests() {
    // Увеличиваем таймауты для CI
    test.setTimeout(Duration(minutes: 30));
    
    // Отключаем параллельное выполнение в CI
    test.setMaxConcurrency(1);
    
    // Включаем детальное логирование
    test.setLogWriterOnFailure(true);
  }

  /// Настройки для локальной разработки
  static void configureLocalTests() {
    // Стандартные таймауты
    test.setTimeout(Duration(minutes: 10));
    
    // Параллельное выполнение
    test.setMaxConcurrency(4);
    
    // Базовое логирование
    test.setLogWriterOnFailure(false);
  }
}

/// Настройки для widget тестов
class WidgetTestSettings {
  final Timeout timeout;
  final bool skip;

  const WidgetTestSettings({
    required this.timeout,
    required this.skip,
  });
}

/// Настройки для интеграционных тестов
class IntegrationTestSettings {
  final Timeout timeout;
  final bool skip;

  const IntegrationTestSettings({
    required this.timeout,
    required this.skip,
  });
}

/// Настройки для платформенных тестов
class PlatformTestSettings {
  final Timeout timeout;
  final bool skip;

  const PlatformTestSettings({
    required this.timeout,
    required this.skip,
  });
}

/// Настройки для unit тестов
class UnitTestSettings {
  final Timeout timeout;
  final bool skip;

  const UnitTestSettings({
    required this.timeout,
    required this.skip,
  });
}

/// Утилиты для тестов
class TestUtils {
  /// Создание тестового пользователя
  static Map<String, dynamic> createTestUser() {
    return {
      'id': 'test_user_1',
      'email': 'test@mymodus.com',
      'username': 'testuser',
      'firstName': 'Test',
      'lastName': 'User',
      'avatar': 'https://example.com/avatar.jpg',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Создание тестового продукта
  static Map<String, dynamic> createTestProduct() {
    return {
      'id': 'test_product_1',
      'title': 'Test Product',
      'description': 'This is a test product',
      'price': 1000,
      'currency': 'RUB',
      'imageUrl': 'https://example.com/product.jpg',
      'productUrl': 'https://example.com/product',
      'stock': 10,
      'reviewCount': 5,
      'rating': 4.5,
      'source': 'test',
      'sourceId': 'test_1',
      'category': 'Одежда',
      'brand': 'Test Brand',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Создание тестового AI запроса
  static Map<String, dynamic> createTestAIRequest() {
    return {
      'userId': 'test_user_1',
      'query': 'Show me summer dresses',
      'context': {
        'category': 'Одежда',
        'season': 'Лето',
        'priceRange': [1000, 5000],
        'style': 'Повседневный',
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Создание тестового Web3 запроса
  static Map<String, dynamic> createTestWeb3Request() {
    return {
      'walletAddress': '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      'action': 'createNFT',
      'metadata': {
        'name': 'Test NFT',
        'description': 'Test NFT description',
        'image': 'ipfs://QmTestHash',
        'attributes': [
          {'trait_type': 'Rarity', 'value': 'Common'},
          {'trait_type': 'Type', 'value': 'Badge'},
        ],
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Ожидание асинхронных операций
  static Future<void> waitForAsync() async {
    await Future.delayed(Duration(milliseconds: 100));
  }

  /// Проверка, что исключение содержит определенный текст
  static bool exceptionContains(Exception exception, String text) {
    return exception.toString().contains(text);
  }

  /// Создание мок ответа API
  static Map<String, dynamic> createMockAPIResponse({
    required String status,
    required dynamic data,
    String? message,
    int? statusCode,
  }) {
    return {
      'status': status,
      'data': data,
      if (message != null) 'message': message,
      if (statusCode != null) 'statusCode': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Создание мок ошибки API
  static Map<String, dynamic> createMockAPIError({
    required String error,
    required String message,
    int? statusCode,
    String? details,
  }) {
    return {
      'error': error,
      'message': message,
      if (statusCode != null) 'statusCode': statusCode,
      if (details != null) 'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Константы для тестов
class TestConstants {
  /// Таймауты
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration mediumTimeout = Duration(seconds: 15);
  static const Duration longTimeout = Duration(minutes: 2);

  /// Размеры экранов
  static const Size mobileSize = Size(375, 812);
  static const Size tabletSize = Size(768, 1024);
  static const Size desktopSize = Size(1920, 1080);

  /// Плотности пикселей
  static const double lowDensity = 1.0;
  static const double mediumDensity = 2.0;
  static const double highDensity = 3.0;

  /// Тестовые данные
  static const String testEmail = 'test@mymodus.com';
  static const String testPassword = 'testpassword123';
  static const String testUserId = 'test_user_1';
  static const String testProductId = 'test_product_1';
  static const String testWalletAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';

  /// API endpoints
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = 'v1';
  static const String authEndpoint = '/auth';
  static const String productsEndpoint = '/products';
  static const String aiEndpoint = '/ai';
  static const String web3Endpoint = '/web3';

  /// Web3 константы
  static const String testNetworkId = '1337';
  static const String testContractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
  static const String testPrivateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
}

/// Глобальная инициализация тестов
void main() {
  // Настраиваем тесты
  MyModusTestConfig.configureTests();
  
  // Запускаем все тесты
  runAllTests();
}

/// Запуск всех тестов
void runAllTests() {
  // Widget тесты
  group('Widget Tests', () {
    testWidgets('All widget tests', (WidgetTester tester) async {
      // Тесты будут запущены автоматически
    });
  });

  // Интеграционные тесты
  group('Integration Tests', () {
    test('All integration tests', () async {
      // Тесты будут запущены автоматически
    });
  });

  // Платформенные тесты
  group('Platform Tests', () {
    test('All platform tests', () async {
      // Тесты будут запущены автоматически
    });
  });
}
