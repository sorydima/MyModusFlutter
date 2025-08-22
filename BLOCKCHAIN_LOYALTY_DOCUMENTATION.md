# Блокчейн-Лояльность - Криптовалютные бонусы

## Обзор

Система блокчейн-лояльности MyModus - это инновационная программа лояльности, которая объединяет традиционные баллы лояльности с криптовалютными наградами. Пользователи получают баллы за различные действия и могут обменивать их на токены MODUS, которые отправляются на их блокчейн-кошельки.

## Ключевые возможности

### 🎯 Система уровней лояльности
- **5 уровней**: Bronze, Silver, Gold, Platinum, Diamond
- **Множители наград**: от 1.0x до 3.0x в зависимости от уровня
- **Автоматическое повышение**: при достижении минимальных баллов и трат

### 💰 Криптовалютные награды
- **Токен MODUS**: нативная криптовалюта платформы
- **Множественные источники**: покупки, рефералы, ежедневные входы, достижения
- **Гибкий обмен**: баллы на криптовалюту по выгодному курсу

### 🏆 Система достижений
- **Автоматические достижения**: за различные действия пользователя
- **Бонусные баллы**: за выполнение целей и задач
- **Прогресс-трекинг**: отслеживание достижений и наград

### 👥 Реферальная программа
- **Уникальные коды**: для каждого пользователя
- **Двойные награды**: баллы и криптовалюта за приглашения
- **Статистика рефералов**: отслеживание приглашенных пользователей

### 📱 Ежедневные награды
- **Система серий**: бонусы за последовательные входы
- **Увеличение наград**: с ростом количества дней подряд
- **Автоматическое начисление**: при каждом входе в приложение

## Архитектура

### Backend (Dart)

#### Модели данных
```dart
// Профиль лояльности пользователя
class UserLoyaltyProfile {
  final String id;
  final String userId;
  final String? walletAddress;
  final double loyaltyPoints;
  final String loyaltyTier;
  final double totalSpent;
  final double totalRewardsEarned;
  // ... другие поля
}

// Уровень лояльности
class LoyaltyTier {
  final String tierName;
  final int minPoints;
  final double minSpent;
  final double rewardMultiplier;
  final Map<String, dynamic> benefits;
  // ... другие поля
}

// Транзакция лояльности
class LoyaltyTransaction {
  final String userId;
  final String transactionType;
  final double pointsAmount;
  final double? cryptoAmount;
  final String? blockchainTxHash;
  final String status;
  // ... другие поля
}
```

#### Сервис лояльности
```dart
class BlockchainLoyaltyService {
  // Основные методы
  Future<UserLoyaltyProfile> getOrCreateLoyaltyProfile(String userId);
  Future<void> awardPointsForPurchase({required String userId, required double purchaseAmount});
  Future<void> awardDailyLoginReward(String userId);
  Future<Map<String, dynamic>> exchangePointsForCrypto({required String userId, required int pointsAmount});
  Future<void> createReferral({required String referrerId, required String referredId});
  
  // Вспомогательные методы
  Future<void> _checkAndUpdateTier(String userId);
  int _calculateStreakBonus(int streakDays);
  String generateReferralCode(String userId);
}
```

#### API Handler
```dart
class BlockchainLoyaltyHandler {
  // Основные endpoints
  GET /api/loyalty/profile/{userId}           // Получить профиль
  POST /api/loyalty/profile                   // Создать/обновить профиль
  GET /api/loyalty/stats/{userId}             // Статистика лояльности
  GET /api/loyalty/transactions/{userId}      // История транзакций
  GET /api/loyalty/rewards                    // Доступные награды
  POST /api/loyalty/exchange                  // Обмен баллов на крипто
  POST /api/loyalty/award-purchase            // Награда за покупку
  POST /api/loyalty/daily-login               // Ежедневная награда
  POST /api/loyalty/referral                  // Создать реферала
  GET /api/loyalty/referrals/{userId}         // Статистика рефералов
  GET /api/loyalty/tiers                      // Уровни лояльности
  GET /api/loyalty/achievements/{userId}      // Достижения пользователя
  GET /api/loyalty/wallet/{userId}            // Информация о кошельке
  PUT /api/loyalty/wallet                     // Обновить адрес кошелька
}
```

### Frontend (Flutter)

#### Сервис лояльности
```dart
class BlockchainLoyaltyService {
  // API взаимодействие
  Future<Map<String, dynamic>> getLoyaltyProfile(String userId);
  Future<Map<String, dynamic>> exchangePointsForCrypto({required String userId, required int pointsAmount});
  Future<Map<String, dynamic>> awardDailyLoginReward(String userId);
  
  // Утилиты
  String generateReferralCode(String userId);
  bool isValidWalletAddress(String address);
  String formatCryptoAmount(double amount, String symbol);
  String formatPoints(int points);
}
```

#### Provider состояния
```dart
class BlockchainLoyaltyProvider extends ChangeNotifier {
  // Состояние
  Map<String, dynamic>? _loyaltyProfile;
  List<Map<String, dynamic>> _transactions;
  List<Map<String, dynamic>> _rewards;
  List<Map<String, dynamic>> _tiers;
  
  // Методы
  Future<void> loadAllUserData(String userId);
  Future<Map<String, dynamic>> exchangePointsForCrypto({required String userId, required int pointsAmount});
  Future<void> awardDailyLoginReward(String userId);
  Future<void> updateWalletAddress({required String userId, required String walletAddress});
}
```

#### UI экраны
```dart
class BlockchainLoyaltyScreen extends StatefulWidget {
  // 5 основных вкладок:
  // 1. Профиль - информация о пользователе, уровне, прогрессе
  // 2. Награды - доступные награды, ежедневные бонусы
  // 3. Транзакции - история всех операций
  // 4. Рефералы - реферальные коды и статистика
  // 5. Кошелек - управление адресом кошелька
}
```

## База данных

### Основные таблицы

#### user_loyalty_profiles
```sql
CREATE TABLE user_loyalty_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    wallet_address VARCHAR(255) UNIQUE,
    loyalty_points DECIMAL(20,8) DEFAULT 0,
    loyalty_tier VARCHAR(50) DEFAULT 'bronze',
    total_spent DECIMAL(10,2) DEFAULT 0,
    total_rewards_earned DECIMAL(20,8) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### loyalty_tiers
```sql
CREATE TABLE loyalty_tiers (
    id SERIAL PRIMARY KEY,
    tier_name VARCHAR(50) UNIQUE NOT NULL,
    min_points INTEGER NOT NULL,
    min_spent DECIMAL(10,2) NOT NULL,
    reward_multiplier DECIMAL(5,4) DEFAULT 1.0,
    benefits JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### loyalty_transactions
```sql
CREATE TABLE loyalty_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    transaction_type VARCHAR(50) NOT NULL,
    points_amount DECIMAL(20,8) NOT NULL,
    crypto_amount DECIMAL(20,8),
    description TEXT,
    metadata JSONB,
    blockchain_tx_hash VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP
);
```

#### crypto_rewards
```sql
CREATE TABLE crypto_rewards (
    id SERIAL PRIMARY KEY,
    reward_type VARCHAR(50) NOT NULL,
    points_required INTEGER NOT NULL,
    crypto_amount DECIMAL(20,8) NOT NULL,
    token_symbol VARCHAR(10) DEFAULT 'MODUS',
    is_active BOOLEAN DEFAULT true,
    max_daily_claims INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Индексы для производительности
```sql
CREATE INDEX idx_user_loyalty_profiles_user_id ON user_loyalty_profiles(user_id);
CREATE INDEX idx_user_loyalty_profiles_wallet ON user_loyalty_profiles(wallet_address);
CREATE INDEX idx_loyalty_transactions_user_id ON loyalty_transactions(user_id);
CREATE INDEX idx_loyalty_transactions_type ON loyalty_transactions(transaction_type);
CREATE INDEX idx_loyalty_transactions_status ON loyalty_transactions(status);
```

## Как это работает

### 1. Начисление баллов за покупки
```dart
// При покупке товара
await loyaltyService.awardPointsForPurchase(
  userId: userId,
  purchaseAmount: 1500.0,
  productId: 'product_123',
);

// Алгоритм расчета:
// 1. Базовые баллы = purchaseAmount / 10 (1 балл за каждые 10 рублей)
// 2. Применение множителя уровня (например, Gold = 1.5x)
// 3. Финальные баллы = базовые_баллы * множитель
// 4. Проверка повышения уровня
```

### 2. Ежедневные награды
```dart
// При входе пользователя
await loyaltyService.awardDailyLoginReward(userId);

// Алгоритм:
// 1. Проверка, не получена ли уже награда сегодня
// 2. Получение базовой награды (50 баллов)
// 3. Расчет бонуса за серию:
//    - 3+ дня: +20 баллов
//    - 7+ дней: +50 баллов
//    - 30+ дней: +100 баллов
// 4. Обновление счетчика серии
```

### 3. Обмен баллов на криптовалюту
```dart
// Обмен баллов
final result = await loyaltyService.exchangePointsForCrypto(
  userId: userId,
  pointsAmount: 100,
  rewardType: 'purchase',
);

// Алгоритм:
// 1. Проверка достаточности баллов
// 2. Валидация минимального количества
// 3. Проверка дневного лимита
// 4. Расчет криптовалюты: (points / required) * crypto_amount
// 5. Списание баллов
// 6. Создание транзакции
// 7. TODO: Отправка токенов на блокчейн
```

### 4. Реферальная система
```dart
// Создание реферальной связи
await loyaltyService.createReferral(
  referrerId: 'user1',
  referredId: 'user2',
  referralCode: 'REF123456789',
);

// Награждение реферера
await loyaltyService.awardPointsForReferral(
  referrerId: 'user1',
  referredId: 'user2',
);

// Алгоритм:
// 1. Проверка валидности реферала
// 2. Начисление баллов рефереру (500 баллов)
// 3. Начисление криптовалюты (0.5 MODUS)
// 4. Обновление статуса реферала
```

## UI/UX особенности

### Дизайн-система
- **Цветовая схема**: Deep Purple (#673AB7) как основной цвет
- **Иконки**: Material Design Icons для всех элементов
- **Карточки**: Elevation и тени для глубины интерфейса
- **Анимации**: Плавные переходы между вкладками

### Адаптивность
- **Мобильный-first**: Оптимизация для смартфонов
- **Горизонтальная прокрутка**: Для широких экранов
- **Touch-friendly**: Большие кнопки и области нажатия

### Интерактивность
- **Real-time обновления**: Автоматическое обновление данных
- **Pull-to-refresh**: Обновление при свайпе вниз
- **Skeleton loading**: Показ загрузки для лучшего UX

## Технические детали

### Производительность
- **Кэширование**: Кэширование часто запрашиваемых данных
- **Пагинация**: Загрузка транзакций по частям
- **Lazy loading**: Загрузка данных только при необходимости
- **Оптимизация запросов**: Минимизация количества SQL запросов

### Безопасность
- **Валидация данных**: Проверка всех входящих данных
- **SQL injection protection**: Использование параметризованных запросов
- **Rate limiting**: Ограничение частоты запросов
- **Аутентификация**: Проверка прав доступа пользователя

### Масштабируемость
- **Микросервисная архитектура**: Разделение на независимые сервисы
- **База данных**: PostgreSQL для надежности и производительности
- **API Gateway**: Единая точка входа для всех запросов
- **Мониторинг**: Логирование и отслеживание производительности

## Интеграция с блокчейном

### Текущее состояние
- **Mock интеграция**: Симуляция блокчейн-операций
- **Подготовка к реальной интеграции**: Структура для будущего развития

### Планы развития
- **Ethereum интеграция**: Поддержка Ethereum и совместимых сетей
- **Smart contracts**: Автоматизация операций через смарт-контракты
- **Multi-chain**: Поддержка нескольких блокчейн-сетей
- **DeFi интеграция**: Интеграция с DeFi протоколами

### Технические требования
- **Web3 библиотеки**: Интеграция с Web3.js или ethers.js
- **Wallet connectivity**: Поддержка MetaMask и других кошельков
- **Gas optimization**: Оптимизация комиссий за транзакции
- **Transaction monitoring**: Отслеживание статуса транзакций

## Тестирование

### Backend тесты
```bash
# Запуск тестов
dart test_blockchain_loyalty.dart

# Тестируемые функции:
# - Создание/обновление профиля
# - Начисление баллов
# - Ежедневные награды
# - Обмен баллов на крипто
# - Реферальная система
# - Управление кошельком
```

### Frontend тесты
```bash
# Запуск Flutter тестов
flutter test

# Покрытие тестами:
# - UI компоненты
# - State management
# - API взаимодействие
# - Валидация данных
```

### Интеграционные тесты
- **End-to-end тесты**: Полный цикл пользовательских сценариев
- **API тесты**: Проверка всех endpoints
- **Database тесты**: Валидация схемы и данных
- **Performance тесты**: Нагрузочное тестирование

## Развертывание

### Требования
- **Dart SDK**: Версия 3.0+
- **PostgreSQL**: Версия 13+
- **Flutter**: Версия 3.10+
- **HTTP сервер**: Для API endpoints

### Конфигурация
```bash
# Переменные окружения
PORT=8080
DATABASE_URL=postgresql://user:password@localhost:5432/mymodus
JWT_SECRET=your_jwt_secret_key
BLOCKCHAIN_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
```

### Docker развертывание
```dockerfile
# Backend
FROM dart:stable
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server
EXPOSE 8080
CMD ["bin/server"]
```

## Мониторинг и аналитика

### Метрики
- **Количество пользователей**: По уровням лояльности
- **Активность**: Ежедневные входы, покупки
- **Конверсия**: Баллы → криптовалюта
- **Реферальная эффективность**: Количество приглашенных пользователей

### Логирование
```dart
// Структурированное логирование
final logger = Logger();
logger.i('User $userId earned $points points for purchase');
logger.e('Failed to process transaction: $error');
logger.w('Daily login reward already claimed for user: $userId');
```

### Алерты
- **Ошибки API**: При сбоях в работе системы
- **Высокая нагрузка**: При превышении лимитов
- **Проблемы с блокчейном**: При ошибках транзакций
- **База данных**: При проблемах с подключением

## Будущие улучшения

### Краткосрочные (1-3 месяца)
- **Push уведомления**: О новых наградах и достижениях
- **Gamification**: Достижения и бейджи
- **Социальные функции**: Поделиться достижениями
- **Персонализация**: Индивидуальные награды

### Среднесрочные (3-6 месяцев)
- **AI рекомендации**: Персональные предложения
- **Прогнозирование**: Предсказание поведения пользователей
- **A/B тестирование**: Оптимизация наград
- **Интеграция с CRM**: Связь с системами управления клиентами

### Долгосрочные (6+ месяцев)
- **NFT интеграция**: Уникальные цифровые активы
- **DAO управление**: Децентрализованное управление системой
- **Cross-chain**: Поддержка множественных блокчейнов
- **DeFi интеграция**: Yield farming и стейкинг

## Заключение

Система блокчейн-лояльности MyModus представляет собой инновационное решение, которое объединяет традиционные программы лояльности с современными блокчейн-технологиями. Она обеспечивает прозрачность, безопасность и инновационность в управлении наградами пользователей.

Система готова к развертыванию и дальнейшему развитию, с четким планом интеграции с реальными блокчейн-сетями и расширения функциональности.
