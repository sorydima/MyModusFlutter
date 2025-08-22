# 🧪 MyModus Testing Documentation

## 📋 Обзор

MyModus использует комплексную систему тестирования для обеспечения качества кода, стабильности приложения и корректной работы всех компонентов. Документация описывает структуру тестов, их запуск и интерпретацию результатов.

## 🏗️ Архитектура тестирования

```
┌─────────────────────────────────────────────────────────────┐
│                    Testing Architecture                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Unit Tests    │  │  Widget Tests   │  │Integration │ │
│  │                 │  │                 │  │   Tests    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │ Platform Tests  │  │ Coverage Tests  │  │Performance │ │
│  │                 │  │                 │  │   Tests    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                    Test Runners                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Bash Script   │  │PowerShell Script│  │Flutter CLI │ │
│  │   (Linux/Mac)   │  │   (Windows)     │  │   Tests    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Структура тестов

### Frontend Tests (`frontend/test/`)

```
test/
├── widget_tests.dart           # Widget тесты UI компонентов
├── integration_tests.dart      # Интеграционные тесты API/Web3
├── platform_tests.dart         # Тесты для разных платформ
├── test_config.dart            # Конфигурация тестов
├── unit/                       # Unit тесты (будущие)
│   ├── providers/              # Тесты провайдеров
│   ├── services/               # Тесты сервисов
│   └── models/                 # Тесты моделей
└── mocks/                      # Автогенерируемые моки
    ├── widget_tests.mocks.dart
    └── integration_tests.mocks.dart
```

### Backend Tests (`backend/test/`)

```
test/
├── ai_services_test.dart       # Тесты AI сервисов
├── auth_service_test.dart      # Тесты аутентификации
├── product_service_test.dart   # Тесты продуктов
├── web3_service_test.dart      # Тесты Web3
└── integration/                # Интеграционные тесты
    ├── api_test.dart           # Тесты API endpoints
    └── database_test.dart      # Тесты базы данных
```

## 🚀 Запуск тестов

### 1. Автоматический запуск (рекомендуется)

#### Linux/Mac
```bash
cd frontend
chmod +x scripts/run_tests.sh
./scripts/run_tests.sh [команда]
```

#### Windows
```powershell
cd frontend
.\scripts\run_tests.ps1 [команда]
```

### 2. Ручной запуск через Flutter CLI

```bash
# Все тесты
flutter test

# Конкретный файл тестов
flutter test test/widget_tests.dart

# Тесты с покрытием
flutter test --coverage

# Тесты в watch режиме
flutter test --watch

# Тесты для конкретной платформы
flutter test --platform=android
flutter test --platform=ios
flutter test --platform=web
```

### 3. Доступные команды

| Команда | Описание |
|---------|----------|
| `all` | Запустить все тесты (по умолчанию) |
| `unit` | Только unit тесты |
| `widget` | Только widget тесты |
| `integration` | Только интеграционные тесты |
| `platform` | Только платформенные тесты |
| `coverage` | Тесты с покрытием |
| `watch` | Тесты в watch режиме |
| `android` | Тесты для Android |
| `ios` | Тесты для iOS |
| `web` | Тесты для Web |
| `analyze` | Анализ качества кода |
| `help` | Показать справку |

## 🧩 Типы тестов

### 1. Unit Tests (Модульные тесты)

Тестируют отдельные функции, методы и классы в изоляции.

```dart
test('should calculate total price correctly', () {
  final cart = ShoppingCart();
  cart.addItem(Product(price: 100));
  cart.addItem(Product(price: 200));
  
  expect(cart.totalPrice, equals(300));
});
```

**Покрытие:** Логика бизнес-функций, вычисления, валидация.

### 2. Widget Tests (Тесты виджетов)

Тестируют UI компоненты и их поведение.

```dart
testWidgets('should display product information correctly', (WidgetTester tester) async {
  final product = Product(title: 'Test Product', price: 1000);
  
  await tester.pumpWidget(ProductCard(product: product));
  
  expect(find.text('Test Product'), findsOneWidget);
  expect(find.text('1000 ₽'), findsOneWidget);
});
```

**Покрытие:** UI компоненты, навигация, пользовательские взаимодействия.

### 3. Integration Tests (Интеграционные тесты)

Тестируют взаимодействие между компонентами системы.

```dart
test('should fetch products from API successfully', () async {
  final apiService = ApiService();
  final products = await apiService.getProducts();
  
  expect(products, isA<List<Product>>());
  expect(products.isNotEmpty, true);
});
```

**Покрытие:** API интеграция, Web3 операции, работа с базой данных.

### 4. Platform Tests (Платформенные тесты)

Тестируют поведение на разных платформах и устройствах.

```dart
testWidgets('should adapt to different screen sizes', (WidgetTester tester) async {
  // Тестируем мобильное устройство
  tester.binding.window.physicalSizeTestValue = Size(375, 812);
  
  await tester.pumpWidget(HomePage());
  
  // Проверяем мобильную компоновку
  expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
});
```

**Покрытие:** Адаптивность, платформо-специфичные функции, жесты.

## 🔧 Конфигурация тестов

### Test Configuration (`test_config.dart`)

```dart
class MyModusTestConfig {
  // Настройки таймаутов
  static const WidgetTestSettings widgetTestSettings = WidgetTestSettings(
    timeout: Timeout(Duration(minutes: 5)),
    skip: false,
  );
  
  // Настройки для CI/CD
  static void configureCITests() {
    test.setTimeout(Duration(minutes: 30));
    test.setMaxConcurrency(1);
    test.setLogWriterOnFailure(true);
  }
}
```

### Environment Variables

```bash
# .env.test
FLUTTER_TEST=true
API_BASE_URL=http://localhost:8080
WEB3_NETWORK_ID=1337
OPENAI_API_KEY=test_key
```

## 📊 Покрытие тестами

### Генерация отчета о покрытии

```bash
# Запуск тестов с покрытием
flutter test --coverage

# Генерация HTML отчета (требует lcov)
genhtml coverage/lcov.info -o coverage/html
```

### Анализ покрытия

- **Цель:** Минимум 80% покрытия кода
- **Критические компоненты:** 90%+ покрытия
- **UI компоненты:** 70%+ покрытия

### Отчет о покрытии

```
coverage/
├── lcov.info                  # LCOV формат
├── html/                      # HTML отчет
│   ├── index.html            # Главная страница
│   ├── dart/                 # Детали по файлам
│   └── css/                  # Стили отчета
└── summary.txt               # Краткий отчет
```

## 🧪 Тестовые данные

### Test Utils (`test_config.dart`)

```dart
class TestUtils {
  // Создание тестового пользователя
  static Map<String, dynamic> createTestUser() {
    return {
      'id': 'test_user_1',
      'email': 'test@mymodus.com',
      'username': 'testuser',
      // ... другие поля
    };
  }
  
  // Создание тестового продукта
  static Map<String, dynamic> createTestProduct() {
    return {
      'id': 'test_product_1',
      'title': 'Test Product',
      'price': 1000,
      // ... другие поля
    };
  }
}
```

### Mock Data

```dart
// Создание моков для API
final mockResponse = http.Response(
  '{"products": [{"id": "1", "title": "Test Product"}]}',
  200,
);

when(mockHttpClient.get(any, headers: anyNamed('headers')))
    .thenAnswer((_) async => mockResponse);
```

## 🔍 Анализ качества кода

### Flutter Analyze

```bash
# Анализ Dart кода
flutter analyze

# Анализ с исправлением ошибок
flutter analyze --fix
```

### Code Formatting

```bash
# Проверка форматирования
flutter format --dry-run .

# Автоматическое форматирование
flutter format .
```

### Linting Rules

```yaml
# analysis_options.yaml
analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  
  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
```

## 🚨 Обработка ошибок в тестах

### Exception Testing

```dart
test('should handle API errors gracefully', () {
  when(mockHttpClient.get(any))
      .thenThrow(Exception('Network error'));
  
  expect(
    () => apiService.getProducts(),
    throwsA(isA<Exception>()),
  );
});
```

### Error State Testing

```dart
testWidgets('should display error messages', (WidgetTester tester) async {
  // Устанавливаем ошибку
  aiProvider.setError('Произошла ошибка при загрузке');
  
  await tester.pumpWidget(AIRecommendationsScreen());
  
  // Проверяем отображение ошибки
  expect(find.text('Произошла ошибка при загрузке'), findsOneWidget);
  expect(find.text('Повторить'), findsOneWidget);
});
```

## 📱 Тестирование на разных платформах

### Mobile Testing

```dart
group('Mobile Platform Tests', () {
  testWidgets('should display mobile-optimized layout', (WidgetTester tester) async {
    // Симулируем мобильное устройство
    tester.binding.window.physicalSizeTestValue = Size(375, 812);
    tester.binding.window.devicePixelRatioTestValue = 3.0;
    
    // Тестируем мобильную компоновку
    await tester.pumpWidget(HomePage());
    
    expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
  });
});
```

### Web Testing

```dart
group('Web Platform Tests', () {
  testWidgets('should handle web keyboard navigation', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = Size(1920, 1080);
    
    await tester.pumpWidget(WebForm());
    
    // Тестируем навигацию по Tab
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
  });
});
```

## ⚡ Performance Testing

### Memory Usage Testing

```dart
testWidgets('should handle memory pressure', (WidgetTester tester) async {
  await tester.pumpWidget(
    ListView.builder(
      itemCount: 1000,
      itemBuilder: (context, index) => ListTile(
        title: Text('Item $index'),
      ),
    ),
  );
  
  // Скролл для проверки производительности
  await tester.drag(find.byType(ListView), Offset(0, -500));
  await tester.pump();
});
```

### Response Time Testing

```dart
test('should handle large data sets efficiently', () async {
  final stopwatch = Stopwatch()..start();
  
  final products = await apiService.getProducts();
  
  stopwatch.stop();
  
  expect(products.length, equals(1000));
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
});
```

## 🔒 Security Testing

### JWT Token Validation

```dart
test('should validate JWT tokens properly', () async {
  final validToken = 'valid.jwt.token';
  final invalidToken = 'invalid.token';
  
  expect(
    () => apiService.validateToken(validToken),
    returnsNormally,
  );
  
  expect(
    () => apiService.validateToken(invalidToken),
    throwsA(isA<Exception>()),
  );
});
```

### Web3 Signature Verification

```dart
test('should handle Web3 signature verification', () async {
  when(mockWeb3Service.verifySignature(any, any, any))
      .thenAnswer((_) async => true);
  
  final isValid = await mockWeb3Service.verifySignature(
    '0x123...',
    'message',
    'signature',
  );
  
  expect(isValid, isTrue);
});
```

## 📈 CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
      - run: flutter analyze
```

### Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running tests..."
flutter test

echo "Running code analysis..."
flutter analyze

echo "Checking code formatting..."
flutter format --dry-run .
```

## 🐛 Debugging Tests

### Verbose Output

```bash
# Подробный вывод тестов
flutter test --reporter=expanded

# Вывод с таймаутами
flutter test --timeout=60s
```

### Debug Mode

```dart
test('debug test', () {
  debugPrint('Debug information');
  
  // Устанавливаем breakpoint
  debugger();
  
  expect(true, isTrue);
});
```

### Test Isolation

```dart
setUp(() {
  // Инициализация перед каждым тестом
  mockApiService = MockApiService();
  authProvider = AuthProvider(mockApiService);
});

tearDown(() {
  // Очистка после каждого теста
  authProvider.dispose();
});
```

## 📚 Best Practices

### 1. Test Organization

- Группируйте связанные тесты в `group()`
- Используйте описательные названия тестов
- Следуйте паттерну AAA (Arrange, Act, Assert)

### 2. Mocking

- Мокайте внешние зависимости
- Используйте `@GenerateMocks` для автоматической генерации
- Создавайте реалистичные тестовые данные

### 3. Test Data

- Используйте фабрики для создания тестовых объектов
- Избегайте хардкода в тестах
- Создавайте переиспользуемые тестовые утилиты

### 4. Assertions

- Используйте специфичные матчеры
- Проверяйте как позитивные, так и негативные сценарии
- Тестируйте граничные случаи

### 5. Performance

- Не делайте тесты слишком медленными
- Используйте `setUp` и `tearDown` для оптимизации
- Группируйте быстрые и медленные тесты

## 🎯 Метрики качества

### Code Coverage

- **Общее покрытие:** 80%+
- **Критические компоненты:** 90%+
- **UI компоненты:** 70%+

### Test Execution Time

- **Unit тесты:** < 1 секунды
- **Widget тесты:** < 5 секунд
- **Интеграционные тесты:** < 30 секунд
- **Все тесты:** < 2 минут

### Test Reliability

- **Flaky тесты:** 0%
- **False positives:** < 1%
- **False negatives:** 0%

## 🔮 Future Improvements

### Planned Features

1. **Visual Regression Testing**
   - Сравнение скриншотов
   - Автоматическое обнаружение изменений UI

2. **Load Testing**
   - Тестирование производительности под нагрузкой
   - Стресс-тестирование API

3. **Accessibility Testing**
   - Автоматическая проверка доступности
   - Тестирование screen readers

4. **Internationalization Testing**
   - Тестирование локализации
   - Проверка RTL языков

### Tools Integration

1. **SonarQube**
   - Анализ качества кода
   - Метрики технического долга

2. **Allure Reports**
   - Красивые отчеты о тестах
   - Интеграция с CI/CD

3. **TestCafe**
   - E2E тестирование
   - Кроссплатформенное тестирование

## 📞 Поддержка

### Troubleshooting

Если у вас возникли проблемы с тестами:

1. Проверьте зависимости: `flutter doctor`
2. Очистите проект: `flutter clean`
3. Перегенерируйте моки: `flutter packages pub run build_runner build`
4. Проверьте логи: `flutter test --verbose`

### Useful Commands

```bash
# Проверка здоровья Flutter
flutter doctor

# Очистка проекта
flutter clean

# Установка зависимостей
flutter pub get

# Генерация моков
flutter packages pub run build_runner build

# Запуск тестов с детальным выводом
flutter test --reporter=expanded --verbose

# Анализ кода
flutter analyze

# Форматирование кода
flutter format .
```

---

**Дата последнего обновления:** ${DateTime.now().toIso8601String()}  
**Версия документации:** 1.0.0  
**Статус:** ✅ Актуально
