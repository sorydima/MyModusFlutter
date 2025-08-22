# 🔗 Интеграция уведомлений с модулями приложения

## 📋 Обзор

Система интеграции уведомлений позволяет автоматически отправлять уведомления пользователям при возникновении различных событий в разных модулях приложения. Это обеспечивает единообразный пользовательский опыт и информированность о всех важных событиях.

## 🏗️ Архитектура

### Backend
- **`NotificationIntegrationService`** - основной сервис интеграции
- **`NotificationIntegrationHandler`** - API handler для интеграции
- **Интеграция с `NotificationService`** - для отправки уведомлений

### Frontend
- **`NotificationIntegrationService`** - клиентский сервис интеграции
- **`NotificationIntegrationDemoScreen`** - экран демонстрации

## 🚀 Возможности

### 🤖 AI Personal Shopper
- **Новые рекомендации** - уведомления о новых AI рекомендациях
- **Снижение цены** - уведомления о снижении цены на товары из wishlist
- **Персональные предложения** - уведомления о специальных предложениях

### 📱 AR Fitting
- **Завершение примерки** - уведомления о готовности результатов AR примерки
- **Рекомендации размера** - уведомления о рекомендуемых размерах
- **Обновление анализа тела** - уведомления об изменениях параметров

### ⭐ Blockchain Loyalty
- **Начисление баллов** - уведомления о начислении баллов лояльности
- **Повышение уровня** - уведомления о повышении уровня лояльности
- **Реферальные бонусы** - уведомления о реферальных наградах
- **Ежедневные бонусы** - уведомления о ежедневных наградах
- **Крипто-награды** - уведомления о криптовалютных наградах

### 📊 Social Analytics
- **Тренды** - уведомления о новых трендах
- **Обновления конкурентов** - уведомления об активности конкурентов
- **Инсайты аудитории** - уведомления о новых инсайтах

### 🌟 Social Commerce
- **Live-стримы** - напоминания о предстоящих live-стримах
- **Групповые покупки** - уведомления об обновлениях групповых покупок
- **Новые отзывы** - уведомления о новых отзывах на товары
- **Партнерства** - уведомления об одобрении партнерств

### ⚙️ Системные уведомления
- **Обновления системы** - уведомления о новых версиях
- **Техобслуживание** - уведомления о плановых работах
- **Безопасность** - уведомления о проблемах безопасности

## 📡 API Endpoints

### AI Integration
```http
POST /api/notification-integration/ai/recommendations
POST /api/notification-integration/ai/price-alert
POST /api/notification-integration/ai/personalized-offer
```

### AR Integration
```http
POST /api/notification-integration/ar/fitting-complete
POST /api/notification-integration/ar/size-recommendation
POST /api/notification-integration/ar/body-analysis-update
```

### Loyalty Integration
```http
POST /api/notification-integration/loyalty/points-earned
POST /api/notification-integration/loyalty/tier-upgrade
POST /api/notification-integration/loyalty/referral-bonus
POST /api/notification-integration/loyalty/daily-login
POST /api/notification-integration/loyalty/crypto-reward
```

### Analytics Integration
```http
POST /api/notification-integration/analytics/trend-alert
POST /api/notification-integration/analytics/competitor-update
POST /api/notification-integration/analytics/audience-insight
```

### Commerce Integration
```http
POST /api/notification-integration/commerce/live-stream-reminder
POST /api/notification-integration/commerce/group-purchase-update
POST /api/notification-integration/commerce/new-review
POST /api/notification-integration/commerce/partnership-approved
```

### System Integration
```http
POST /api/notification-integration/system/update
POST /api/notification-integration/system/maintenance
POST /api/notification-integration/system/security-alert
```

### Bulk Notifications
```http
POST /api/notification-integration/bulk/by-category
POST /api/notification-integration/bulk/to-users
```

### Demo and Testing
```http
POST /api/notification-integration/demo/send-all-types
POST /api/notification-integration/demo/simulate-events
```

## 💻 Примеры использования

### Backend - Отправка уведомления о новых рекомендациях

```dart
final integrationService = NotificationIntegrationService(
  notificationService: notificationService,
);

await integrationService.notifyNewRecommendations(
  userId: 'user_123',
  recommendations: [
    ProductRecommendation(
      product: product,
      score: 0.95,
      reason: 'Based on your preferences',
    ),
  ],
  category: 'Одежда',
);
```

### Frontend - Отправка уведомления о снижении цены

```dart
final service = context.read<NotificationIntegrationService>();

final success = await service.notifyPriceAlert(
  userId: 'user_123',
  product: productData,
  oldPrice: 1000,
  newPrice: 800,
  discount: 200,
);

if (success) {
  print('Price alert notification sent successfully');
}
```

### Массовые уведомления

```dart
// По категории пользователей
await service.sendBulkNotificationsByCategory(
  category: 'premium_users',
  title: 'Новая коллекция',
  body: 'Доступна новая коллекция от известного дизайнера',
  type: 'newRecommendations',
);

// По списку пользователей
await service.sendBulkNotificationsToUsers(
  userIds: ['user_1', 'user_2', 'user_3'],
  title: 'Специальное предложение',
  body: 'Только для вас - скидка 30%',
  type: 'personalizedOffer',
);
```

## 🔧 Настройка

### 1. Backend интеграция

Добавьте в `backend/bin/server.dart`:

```dart
import '../lib/services/notification_integration_service.dart';
import '../lib/handlers/notification_integration_handler.dart';

// Инициализация сервиса
final notificationIntegrationService = NotificationIntegrationService(
  notificationService: notificationService,
);

// Инициализация handler
final notificationIntegrationHandler = NotificationIntegrationHandler(
  integrationService: notificationIntegrationService,
  db: DatabaseService(),
);

// Монтирование роутера
app.mount('/api/notification-integration', notificationIntegrationHandler.router);
```

### 2. Frontend интеграция

Добавьте в `main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (context) => NotificationIntegrationService(
        notificationService: context.read<RealNotificationService>(),
      ),
    ),
  ],
  child: MyApp(),
);
```

## 🧪 Тестирование

### Демо уведомления

```dart
// Отправка всех типов уведомлений
await service.sendDemoNotifications(userId: 'demo_user_123');

// Симуляция событий конкретного модуля
await service.simulateModuleEvents(
  userId: 'demo_user_123',
  module: 'ai', // 'ar', 'loyalty', 'analytics', 'commerce', 'all'
);
```

### Проверка доступности сервера

```dart
final isAvailable = await service.checkServerAvailability();
if (isAvailable) {
  print('Integration server is available');
} else {
  print('Integration server is not available');
}
```

## 📱 UI Демонстрация

Экран `NotificationIntegrationDemoScreen` предоставляет:

- **6 вкладок** для разных модулей
- **Кнопки демонстрации** для каждого типа уведомлений
- **Статус сообщения** с результатами операций
- **Массовые уведомления** и тестирование

## 🔄 Жизненный цикл уведомления

1. **Событие** - происходит в модуле (например, новая рекомендация)
2. **Интеграция** - модуль вызывает `NotificationIntegrationService`
3. **Создание** - создается уведомление через `NotificationService`
4. **Отправка** - уведомление отправляется через FCM и локально
5. **Получение** - пользователь получает уведомление
6. **Отображение** - уведомление показывается в UI

## 🎯 Лучшие практики

### 1. Своевременность
- Отправляйте уведомления в подходящее время
- Учитывайте часовой пояс пользователя
- Не спамьте уведомлениями

### 2. Персонализация
- Используйте данные пользователя для персонализации
- Адаптируйте контент под предпочтения
- Учитывайте историю взаимодействий

### 3. Категоризация
- Группируйте уведомления по типам
- Позволяйте пользователям настраивать предпочтения
- Предоставляйте возможность отписки

### 4. Тестирование
- Тестируйте все типы уведомлений
- Проверяйте корректность данных
- Валидируйте форматирование

## 🚨 Обработка ошибок

### Backend ошибки
```dart
try {
  await integrationService.notifyNewRecommendations(...);
} catch (e) {
  logger.e('Failed to send notification: $e');
  // Fallback или повторная попытка
}
```

### Frontend ошибки
```dart
try {
  final success = await service.notifyPriceAlert(...);
  if (!success) {
    // Обработка неуспешной отправки
  }
} catch (e) {
  // Обработка исключений
}
```

## 📊 Мониторинг и аналитика

### Метрики для отслеживания
- Количество отправленных уведомлений
- Процент доставки
- Время отклика пользователей
- Эффективность разных типов уведомлений

### Логирование
```dart
logger.i('Sent AI recommendations notification to user $userId');
logger.e('Failed to send price alert notification: $e');
```

## 🔮 Будущие улучшения

### Планируемые функции
- **Умные уведомления** - AI для определения оптимального времени
- **A/B тестирование** - тестирование разных форматов уведомлений
- **Аналитика эффективности** - детальная статистика по модулям
- **Интеграция с календарем** - планирование уведомлений
- **Геолокация** - уведомления на основе местоположения

### Расширение модулей
- **Платежи** - уведомления о транзакциях
- **Доставка** - уведомления о статусе заказов
- **Поддержка** - уведомления о тикетах
- **Социальные сети** - уведомления о активности

## 📚 Дополнительные ресурсы

- [README_Notifications.md](./README_Notifications.md) - Основная документация по уведомлениям
- [API Documentation](./README.md) - Общая документация API
- [Frontend Guide](./frontend/README.md) - Руководство по фронтенду
- [Backend Guide](./backend/README.md) - Руководство по бэкенду

## 🤝 Поддержка

При возникновении вопросов или проблем:

1. Проверьте логи сервера
2. Убедитесь в корректности данных
3. Проверьте доступность сервисов
4. Обратитесь к документации
5. Создайте issue в репозитории

---

**Версия**: 1.0.0  
**Дата**: ${new Date().toLocaleDateString()}  
**Автор**: MyModus Team
