# 💰 Блокчейн-Лояльность MyModus

Инновационная система лояльности с криптовалютными наградами, которая превращает ваши покупки и активность в токены MODUS.

## 🚀 Быстрый старт

### Backend
```bash
# 1. Применить миграцию базы данных
psql -d your_database -f migrations/009_blockchain_loyalty.sql

# 2. Запустить сервер
cd backend
dart run bin/server.dart

# 3. Проверить API
curl http://localhost:8080/api/loyalty/rewards
```

### Frontend
```bash
# 1. Добавить зависимости в pubspec.yaml
flutter pub add http provider

# 2. Запустить приложение
flutter run

# 3. Открыть экран лояльности
# Навигация: BlockchainLoyaltyScreen
```

### Тестирование API
```bash
# Запустить тесты
dart test_blockchain_loyalty.dart

# Или протестировать отдельные endpoints
curl -X POST http://localhost:8080/api/loyalty/profile \
  -H "Content-Type: application/json" \
  -d '{"userId": "1", "walletAddress": "0x123..."}'
```

## ✨ Основные возможности

### 🎯 Система уровней
- **Bronze** → **Silver** → **Gold** → **Platinum** → **Diamond**
- Автоматическое повышение при достижении целей
- Множители наград от 1.0x до 3.0x

### 💎 Крипто-награды
- **Токен MODUS**: нативная валюта платформы
- **Источники**: покупки, рефералы, ежедневные входы
- **Обмен**: баллы → криптовалюта по выгодному курсу

### 🏆 Достижения и геймификация
- Автоматические достижения за активность
- Бонусные баллы за выполнение целей
- Система серий для ежедневных входов

### 👥 Реферальная программа
- Уникальные коды для каждого пользователя
- Двойные награды: баллы + криптовалюта
- Статистика и отслеживание рефералов

## 🏗️ Архитектура

### Backend (Dart)
```
backend/lib/
├── services/
│   └── blockchain_loyalty_service.dart    # Основная логика
├── handlers/
│   └── blockchain_loyalty_handler.dart    # API endpoints
└── models.dart                            # Модели данных
```

### Frontend (Flutter)
```
frontend/lib/
├── services/
│   └── blockchain_loyalty_service.dart    # API взаимодействие
├── providers/
│   └── blockchain_loyalty_provider.dart   # State management
└── screens/
    └── blockchain_loyalty_screen.dart     # UI экран
```

### База данных
```
migrations/
└── 009_blockchain_loyalty.sql             # Схема БД
```

## 📱 UI/UX особенности

### 5 основных вкладок:
1. **Профиль** - уровень, баллы, прогресс
2. **Награды** - доступные награды, ежедневные бонусы
3. **Транзакции** - история всех операций
4. **Рефералы** - коды, статистика, приглашения
5. **Кошелек** - управление адресом кошелька

### Дизайн:
- Deep Purple цветовая схема
- Material Design иконки
- Адаптивный интерфейс
- Плавные анимации

## 🔧 API Endpoints

### Основные операции
```http
GET    /api/loyalty/profile/{userId}        # Получить профиль
POST   /api/loyalty/profile                 # Создать/обновить профиль
GET    /api/loyalty/stats/{userId}          # Статистика
GET    /api/loyalty/transactions/{userId}   # История транзакций
GET    /api/loyalty/rewards                 # Доступные награды
POST   /api/loyalty/exchange                # Обмен баллов на крипто
```

### Награды и активность
```http
POST   /api/loyalty/award-purchase          # Награда за покупку
POST   /api/loyalty/daily-login             # Ежедневная награда
POST   /api/loyalty/referral                # Создать реферала
GET    /api/loyalty/referrals/{userId}      # Статистика рефералов
```

### Управление кошельком
```http
GET    /api/loyalty/wallet/{userId}         # Информация о кошельке
PUT    /api/loyalty/wallet                  # Обновить адрес кошелька
GET    /api/loyalty/tiers                   # Уровни лояльности
GET    /api/loyalty/achievements/{userId}   # Достижения пользователя
```

## 💡 Примеры использования

### Начисление баллов за покупку
```dart
await loyaltyService.awardPointsForPurchase(
  userId: 'user123',
  purchaseAmount: 2500.0,
  productId: 'product_456',
);
// Результат: 250 базовых баллов * множитель уровня
```

### Ежедневная награда
```dart
await loyaltyService.awardDailyLoginReward('user123');
// Результат: 50 базовых баллов + бонус за серию
```

### Обмен баллов на крипто
```dart
final result = await loyaltyService.exchangePointsForCrypto(
  userId: 'user123',
  pointsAmount: 100,
  rewardType: 'purchase',
);
// Результат: 0.1 MODUS токенов
```

### Создание реферала
```dart
await loyaltyService.createReferral(
  referrerId: 'user123',
  referredId: 'user456',
  referralCode: 'REF123456789',
);
// Результат: 500 баллов + 0.5 MODUS для реферера
```

## 🧪 Тестирование

### Backend тесты
```bash
# Запуск всех тестов
dart test_blockchain_loyalty.dart

# Тестируемые функции:
# ✅ Создание/обновление профиля
# ✅ Начисление баллов
# ✅ Ежедневные награды
# ✅ Обмен баллов на крипто
# ✅ Реферальная система
# ✅ Управление кошельком
```

### Frontend тесты
```bash
# Flutter тесты
flutter test

# Покрытие:
# ✅ UI компоненты
# ✅ State management
# ✅ API взаимодействие
# ✅ Валидация данных
```

## 🚀 Развертывание

### Требования
- Dart SDK 3.0+
- PostgreSQL 13+
- Flutter 3.10+
- HTTP сервер

### Конфигурация
```bash
# .env файл
PORT=8080
DATABASE_URL=postgresql://user:password@localhost:5432/mymodus
JWT_SECRET=your_secret_key
BLOCKCHAIN_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
```

### Docker
```dockerfile
FROM dart:stable
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server
EXPOSE 8080
CMD ["bin/server"]
```

## 📊 Мониторинг

### Метрики
- Количество пользователей по уровням
- Активность: входы, покупки
- Конверсия: баллы → криптовалюта
- Эффективность реферальной программы

### Логирование
```dart
final logger = Logger();
logger.i('User $userId earned $points points');
logger.e('Transaction failed: $error');
logger.w('Daily reward already claimed');
```

## 🔮 Будущие улучшения

### Краткосрочные (1-3 месяца)
- Push уведомления
- Gamification элементы
- Социальные функции
- Персонализация наград

### Среднесрочные (3-6 месяцев)
- AI рекомендации
- Прогнозирование поведения
- A/B тестирование
- CRM интеграция

### Долгосрочные (6+ месяцев)
- NFT интеграция
- DAO управление
- Multi-chain поддержка
- DeFi интеграция

## 🤝 Вклад в проект

### Как помочь
1. **Тестирование**: Запустите тесты и сообщите о багах
2. **Документация**: Улучшите существующую документацию
3. **Новые функции**: Предложите идеи для развития
4. **Код**: Отправьте pull request с улучшениями

### Стандарты кода
- Dart: `dart format` и `dart analyze`
- Flutter: `flutter analyze` и `flutter test`
- Комментарии: Документируйте сложную логику
- Тесты: Покрывайте новые функции тестами

## 📞 Поддержка

### Полезные ссылки
- [Полная документация](BLOCKCHAIN_LOYALTY_DOCUMENTATION.md)
- [API документация](http://localhost:8080/api/docs)
- [Тестовый скрипт](test_blockchain_loyalty.dart)

### Контакты
- **Issues**: GitHub Issues для багов и предложений
- **Discussions**: GitHub Discussions для вопросов
- **Wiki**: Дополнительная документация

## 📄 Лицензия

Проект распространяется под лицензией MIT. См. файл LICENSE для деталей.

---

**MyModus Blockchain Loyalty** - Инновационная система лояльности будущего! 🚀💰
