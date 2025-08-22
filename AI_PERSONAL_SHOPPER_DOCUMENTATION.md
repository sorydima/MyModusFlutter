# AI-Персональный Шоппер - Документация

## 📋 Обзор

AI-Персональный Шоппер - это интеллектуальная система рекомендаций, которая анализирует поведение пользователей и предоставляет персонализированные рекомендации товаров. Система использует машинное обучение для понимания предпочтений пользователей и создания наиболее релевантных предложений.

## 🚀 Функциональные возможности

### ✨ Основные функции

1. **Анализ пользовательских предпочтений**
   - Автоматический анализ истории просмотров
   - Анализ истории покупок
   - Изучение вишлиста пользователя
   - Динамическое обновление предпочтений

2. **Персональные рекомендации**
   - AI-рекомендации на основе предпочтений
   - Различные типы рекомендаций (личные, трендовые, похожие, скидки)
   - Скоринг рекомендаций (0-1)
   - Объяснение причин рекомендации

3. **Умный вишлист**
   - Приоритизация товаров
   - Ценовые оповещения
   - Заметки пользователя
   - Автоматические уведомления

4. **Аналитика и инсайты**
   - Анализ эволюции стиля
   - Анализ паттернов трат
   - Сезонные тренды
   - Персональная статистика

5. **Push-уведомления**
   - Новые рекомендации
   - Ценовые оповещения
   - Персонализированные предложения
   - Трендовые товары

## 🏗️ Архитектура системы

### Backend компоненты

```
backend/
├── lib/
│   ├── models.dart                          # Модели данных
│   ├── services/
│   │   └── ai_personal_shopper_service.dart # Основной AI-сервис
│   └── handlers/
│       └── ai_personal_shopper_handler.dart # API endpoints
├── migrations/
│   └── 008_ai_personal_shopper.sql         # База данных
└── bin/
    └── server.dart                         # Интеграция в сервер
```

### Frontend компоненты

```
frontend/
├── lib/
│   ├── services/
│   │   ├── personal_shopper_service.dart   # API клиент
│   │   └── notification_service.dart       # Уведомления
│   ├── providers/
│   │   └── personal_shopper_provider.dart  # Управление состоянием
│   └── screens/
│       ├── personal_shopper_screen.dart    # Основной экран
│       └── notifications_screen.dart       # Экран уведомлений
└── pubspec.yaml                           # Зависимости
```

## 🗄️ Структура базы данных

### Основные таблицы

1. **user_preferences** - Пользовательские предпочтения
2. **user_product_views** - История просмотров товаров
3. **user_purchases** - История покупок
4. **user_wishlist** - Список избранного
5. **ai_recommendations** - AI-рекомендации
6. **user_trend_analysis** - Анализ трендов пользователя

### Ключевые поля

#### user_preferences
```sql
- category_preferences: JSONB    # Предпочтения по категориям с весами
- brand_preferences: JSONB       # Предпочитаемые бренды
- price_range: JSONB            # Диапазон цен
- preferred_marketplaces: TEXT[] # Предпочитаемые площадки
- budget_monthly: INTEGER        # Месячный бюджет
```

#### ai_recommendations
```sql
- recommendation_score: DECIMAL   # Скор рекомендации (0-1)
- recommendation_reasons: JSONB   # Причины рекомендации
- recommendation_type: TEXT       # Тип ('personal', 'trending', etc.)
- expires_at: TIMESTAMP          # Когда истекает
```

## 🔧 API Endpoints

### Базовый URL: `/api/personal-shopper`

#### Предпочтения пользователя
- `GET /preferences/{userId}` - Получить предпочтения
- `POST /preferences/{userId}` - Обновить предпочтения
- `POST /preferences/{userId}/analyze` - Анализировать предпочтения

#### Рекомендации
- `GET /recommendations/{userId}` - Получить рекомендации
- `POST /recommendations/{userId}/generate` - Сгенерировать новые
- `POST /recommendations/{recId}/viewed` - Отметить как просмотренную
- `POST /recommendations/{recId}/clicked` - Отметить как нажатую
- `POST /recommendations/{recId}/purchased` - Отметить как купленную

#### Вишлист
- `GET /wishlist/{userId}` - Получить вишлист
- `POST /wishlist/{userId}` - Добавить товар
- `DELETE /wishlist/{userId}/{productId}` - Удалить товар
- `PUT /wishlist/{userId}/{productId}` - Обновить товар

#### Активность
- `POST /activity/view` - Записать просмотр товара
- `POST /activity/purchase` - Записать покупку

#### Аналитика
- `GET /trends/{userId}/{analysisType}` - Получить анализ трендов
- `POST /trends/{userId}/{analysisType}/analyze` - Проанализировать тренды
- `GET /stats/{userId}` - Получить статистику
- `GET /insights/{userId}` - Получить инсайты

## 🤖 Алгоритм рекомендаций

### Вычисление скора рекомендации

```dart
double score = 0.0;

// 30% - предпочтения по категориям
score += categoryPreferenceWeight * 0.3;

// 25% - предпочтения по брендам
score += brandPreferenceWeight * 0.25;

// 20% - соответствие ценовому диапазону
score += priceRangeMatch * 0.2;

// 15% - рейтинг товара
score += (productRating / 5.0) * 0.15;

// 10% - скидка товара
score += min(productDiscount / 100.0, 0.1);

// Бонус за новизну (до 5%)
if (daysSinceCreated <= 7) score += 0.05;

return min(score, 1.0);
```

### Типы рекомендаций

1. **personal** - На основе личных предпочтений
2. **trending** - Трендовые товары
3. **similar** - Похожие на просмотренные
4. **price_drop** - Товары со скидками

## 📱 Использование во Frontend

### Инициализация

```dart
// Инициализация провайдера
final personalShopperProvider = PersonalShopperProvider();
await personalShopperProvider.initializeForUser(userId);

// Инициализация уведомлений
final notificationService = NotificationService();
await notificationService.initialize();
```

### Получение рекомендаций

```dart
// Получение существующих рекомендаций
final recommendations = await personalShopperService.getPersonalRecommendations(
  userId,
  category: 'Одежда',
  limit: 20,
);

// Генерация новых рекомендаций
final newRecommendations = await personalShopperService.generateRecommendations(
  userId,
  limit: 20,
);
```

### Работа с вишлистом

```dart
// Добавление в вишлист
await personalShopperService.addToWishlist(
  userId,
  product,
  priority: 5,
  priceAlertThreshold: 5000,
  notes: 'Хочу купить к Новому году',
);

// Получение вишлиста
final wishlist = await personalShopperService.getWishlist(userId);
```

### Отправка уведомлений

```dart
// Уведомление о новых рекомендациях
await notificationService.notifyNewRecommendations(userId, recommendations);

// Ценовое оповещение
await notificationService.notifyPriceAlert(userId, item, oldPrice, newPrice);
```

## ⚙️ Настройка и конфигурация

### Backend конфигурация

1. **Миграции базы данных**
   ```bash
   dart run backend/bin/migrate.dart
   ```

2. **Переменные окружения**
   ```env
   AI_API_KEY=your_ai_api_key
   DATABASE_URL=postgresql://...
   ```

### Frontend конфигурация

1. **Зависимости**
   ```yaml
   dependencies:
     flutter_local_notifications: ^16.3.0
     http: ^1.1.0
     provider: ^6.1.1
   ```

2. **Разрешения (Android)**
   ```xml
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
   <uses-permission android:name="android.permission.VIBRATE" />
   ```

## 🔄 Интеграция с существующими компонентами

### Интеграция с ProductCard

```dart
ProductCard(
  product: recommendation.toProduct(),
  onTap: () {
    // Отмечаем рекомендацию как просмотренную
    personalShopperService.markRecommendationViewed(recommendation.id);
    
    // Записываем просмотр товара
    personalShopperService.recordProductView(userId, product);
  },
  onFavorite: () {
    // Добавляем в вишлист
    personalShopperService.addToWishlist(userId, product);
  },
)
```

### Интеграция с навигацией

```dart
// Добавление экрана в роутер
GoRoute(
  path: '/personal-shopper',
  builder: (context, state) => const PersonalShopperScreen(),
),

GoRoute(
  path: '/notifications',
  builder: (context, state) => const NotificationsScreen(),
),
```

## 📊 Мониторинг и аналитика

### Ключевые метрики

1. **Эффективность рекомендаций**
   - CTR (Click Through Rate)
   - Конверсия в покупки
   - Время просмотра

2. **Качество предпочтений**
   - Точность анализа
   - Обновление весов
   - Пользовательская удовлетворенность

3. **Уведомления**
   - Открываемость
   - Время отклика
   - Отписки

### Логирование

```dart
// Логирование рекомендаций
logger.i('Generated ${recommendations.length} recommendations for user: $userId');

// Логирование ошибок
logger.e('Error generating recommendations: $e', error: e, stackTrace: stackTrace);
```

## 🚦 Тестирование

### Unit тесты

```dart
// Тестирование сервиса
test('should generate personal recommendations', () async {
  final service = AIPersonalShopperService(db: mockDb, aiService: mockAi);
  final recommendations = await service.generatePersonalRecommendations('user123');
  expect(recommendations.length, greaterThan(0));
});
```

### Integration тесты

```dart
// Тестирование API
testWidgets('should display recommendations', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('Персональный шоппер'));
  await tester.pumpAndSettle();
  expect(find.byType(ProductCard), findsWidgets);
});
```

## 🔮 Планы развития

### Фаза 2: Расширенные функции
- [ ] Анализ изображений товаров
- [ ] Голосовой поиск
- [ ] AR-примерка
- [ ] Социальные рекомендации

### Фаза 3: ML улучшения
- [ ] Глубокое обучение
- [ ] Коллаборативная фильтрация
- [ ] Анализ настроения
- [ ] Предсказание трендов

### Фаза 4: Интеграции
- [ ] Интеграция с календарем
- [ ] Погодные рекомендации
- [ ] Интеграция с соцсетями
- [ ] Кроссплатформенная синхронизация

## 📞 Поддержка

При возникновении проблем или вопросов:

1. Проверьте логи сервера
2. Убедитесь в правильности миграций БД
3. Проверьте конфигурацию уведомлений
4. Обратитесь к документации API

## 📄 Лицензия

Этот модуль является частью проекта MyModus и подчиняется общей лицензии проекта.

---

*Последнее обновление: $(date)*
