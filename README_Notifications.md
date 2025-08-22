# 🔔 Система реальных уведомлений - MyModus

## 📋 Обзор

**Система реальных уведомлений** - это полноценная платформа для отправки и получения push-уведомлений, интегрированная с Firebase Cloud Messaging (FCM) и поддерживающая все модули приложения MyModus.

## 🚀 Основные возможности

### 🔥 Push-уведомления
- **Firebase Cloud Messaging** - надежная доставка уведомлений
- **Автоматическая регистрация** FCM токенов
- **Поддержка Android и iOS** с нативными каналами
- **Background и foreground** обработка сообщений

### 📱 Локальные уведомления
- **Flutter Local Notifications** для in-app уведомлений
- **Кастомные каналы** для разных типов уведомлений
- **Звуки и вибрация** для Android
- **Badge счетчики** для iOS

### 🎯 Типы уведомлений
- **AI Personal Shopper** - рекомендации, ценовые оповещения
- **AR Fitting** - завершение примерки, рекомендации размеров
- **Blockchain Loyalty** - начисление баллов, повышение уровня
- **Social Analytics** - тренды, конкурентный анализ
- **Social Commerce** - напоминания о стримах, обновления покупок
- **Системные** - обновления, обслуживание, безопасность

### ⏰ Планировщик уведомлений
- **Отложенная отправка** по расписанию
- **Автоматические напоминания** о live-стримах
- **Периодические уведомления** (ежедневные, еженедельные)
- **Умная группировка** и приоритизация

## 🏗️ Архитектура

### Backend (Dart + Shelf)
```
backend/lib/
├── services/
│   └── notification_service.dart      # Основной сервис уведомлений
├── handlers/
│   └── notification_handler.dart      # API endpoints
└── bin/
    └── server.dart                    # Интеграция в основной сервер
```

### Frontend (Flutter)
```
frontend/lib/
├── services/
│   └── real_notification_service.dart # Сервис уведомлений
├── screens/
│   └── real_notifications_screen.dart # Экран уведомлений
└── widgets/
    └── notification_card.dart         # Виджеты карточек
```

## 🔧 API Endpoints

### Основные операции
- `POST /api/notifications/register-token` - Регистрация FCM токена
- `GET /api/notifications/{userId}` - Получение уведомлений пользователя
- `POST /api/notifications/create` - Создание уведомления
- `PUT /api/notifications/{id}/read` - Отметка как прочитанного
- `DELETE /api/notifications/{id}` - Удаление уведомления

### Специальные уведомления
- `POST /api/notifications/recommendations` - AI рекомендации
- `POST /api/notifications/price-alert` - Ценовые оповещения
- `POST /api/notifications/loyalty-points` - Баллы лояльности
- `POST /api/notifications/live-stream-reminder` - Напоминания о стримах
- `POST /api/notifications/group-purchase-update` - Обновления групповых покупок

### Массовые операции
- `POST /api/notifications/bulk` - Массовая отправка
- `GET /api/notifications/{userId}/stats` - Статистика
- `POST /api/notifications/cleanup` - Очистка старых

## 📱 Настройка Firebase

### 1. Создание проекта Firebase
```bash
# Перейти на https://console.firebase.google.com
# Создать новый проект или использовать существующий
# Добавить Android и iOS приложения
```

### 2. Android настройка
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    
    <application>
        <!-- Firebase конфигурация -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="mymodus_channel" />
    </application>
</manifest>
```

### 3. iOS настройка
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 4. Конфигурация
```dart
// frontend/lib/main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

## 🚀 Использование

### 1. Инициализация сервиса
```dart
final notificationService = RealNotificationService();

// Инициализация с userId
await notificationService.initialize(userId: 'user_123');
```

### 2. Отправка уведомления
```dart
// Простое уведомление
await notificationService.createNotification(
  title: 'Новые рекомендации!',
  body: 'Найдено 5 товаров для вас',
  type: NotificationType.newRecommendations,
);

// Уведомление с данными
await notificationService.createNotification(
  title: 'Скидка на товар',
  body: 'Товар подешевел на 20%',
  type: NotificationType.priceAlert,
  data: {
    'product_id': 'prod_123',
    'old_price': 1000,
    'new_price': 800,
  },
);

// Запланированное уведомление
await notificationService.createNotification(
  title: 'Напоминание о стриме',
  body: 'Live-стрим начинается через 30 минут',
  type: NotificationType.liveStreamReminder,
  scheduledFor: DateTime.now().add(Duration(minutes: 30)),
);
```

### 3. Получение уведомлений
```dart
// Все уведомления
final allNotifications = notificationService.notifications;

// Только непрочитанные
final unreadNotifications = notificationService.unreadNotifications;

// По типу
final recommendations = notificationService.getNotificationsByType(
  NotificationType.newRecommendations,
);

// С backend
await notificationService.getNotifications(
  isRead: false,
  type: NotificationType.priceAlert,
  limit: 20,
);
```

### 4. Управление уведомлениями
```dart
// Отметить как прочитанное
await notificationService.markAsRead('notification_id');

// Отметить все как прочитанные
await notificationService.markAllAsRead();

// Удалить уведомление
await notificationService.deleteNotification('notification_id');

// Очистить прочитанные
notificationService.clearRead();
```

## 🎨 Каналы уведомлений (Android)

### Основные каналы
- **mymodus_channel** - Основные уведомления (высокий приоритет)
- **recommendations_channel** - AI рекомендации (высокий приоритет)
- **price_alerts_channel** - Ценовые оповещения (средний приоритет)
- **loyalty_channel** - Программа лояльности (средний приоритет)

### Настройка каналов
```dart
await androidImplementation.createNotificationChannel(
  const AndroidNotificationChannel(
    'mymodus_channel',
    'MyModus Notifications',
    description: 'Основные уведомления приложения',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  ),
);
```

## 📊 Статистика и аналитика

### Метрики уведомлений
- **Общее количество** отправленных уведомлений
- **Прочитанные/непрочитанные** уведомления
- **Успешные/неуспешные** отправки
- **Распределение по типам** уведомлений
- **Время доставки** и открытия

### Получение статистики
```dart
final stats = await notificationService.getNotificationStats();

print('Всего: ${stats['total']}');
print('Непрочитанных: ${stats['unread']}');
print('По типам: ${stats['by_type']}');
```

## 🔒 Безопасность

### FCM токены
- **Автоматическая регистрация** при инициализации
- **Привязка к пользователю** для персонализации
- **Обновление токенов** при изменении устройства

### Разрешения
- **Запрос разрешений** для iOS (alert, badge, sound)
- **Android разрешения** для уведомлений и вибрации
- **Graceful fallback** при отключении уведомлений

## 🧪 Тестирование

### Тестовые уведомления
```dart
// Отправить тестовое уведомление
await notificationService.sendTestNotification();

// Создать уведомление определенного типа
await notificationService.createNotification(
  title: 'Тест',
  body: 'Тестовое уведомление',
  type: NotificationType.systemUpdate,
  data: {'test': true},
);
```

### Отладка
```dart
// Включить логирование
debugPrint('FCM token: ${notificationService.fcmToken}');
debugPrint('Initialized: ${notificationService.isInitialized}');
debugPrint('Notifications enabled: ${notificationService.notificationsEnabled}');
```

## 🚀 Развертывание

### 1. Backend
```bash
cd backend

# Установить зависимости
dart pub get

# Настроить переменные окружения
export FCM_SERVER_KEY="your_fcm_server_key"

# Запустить сервер
dart run bin/server.dart
```

### 2. Frontend
```bash
cd frontend

# Установить зависимости
flutter pub get

# Настроить Firebase
# Добавить google-services.json (Android)
# Добавить GoogleService-Info.plist (iOS)

# Запустить приложение
flutter run
```

## 📋 Переменные окружения

### Backend
```env
# Firebase Cloud Messaging
FCM_SERVER_KEY=your_fcm_server_key_here

# Порт сервера
PORT=8080
```

### Frontend
```env
# Backend URL
BACKEND_URL=http://localhost:8080

# Firebase конфигурация (автоматически из google-services.json)
```

## 🔮 Будущие улучшения

### Планируемые функции
- **Web Push уведомления** для веб-версии
- **Email уведомления** как альтернатива push
- **SMS уведомления** для критически важных сообщений
- **In-app уведомления** с rich content
- **Геолокационные уведомления** на основе местоположения
- **A/B тестирование** уведомлений
- **Машинное обучение** для оптимизации времени отправки

### Технические улучшения
- **WebSocket** для real-time уведомлений
- **GraphQL** для гибких запросов
- **Redis** для кэширования и очередей
- **Kafka** для масштабируемости
- **Микросервисная архитектура** для уведомлений

## 🐛 Известные проблемы

### Ограничения
- **iOS background** - ограничения на background обработку
- **Android Doze Mode** - задержки в режиме экономии энергии
- **FCM квоты** - лимиты на количество сообщений
- **Размер payload** - ограничение 4KB для FCM

### Решения
- **Foreground обработка** для критически важных уведомлений
- **Battery optimization** исключения для Android
- **Payload оптимизация** и сжатие данных
- **Fallback механизмы** при недоступности FCM

## 📚 Дополнительные ресурсы

### Документация
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Shelf Framework](https://pub.dev/packages/shelf)

### Примеры кода
- [FCM Flutter примеры](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_messaging/firebase_messaging/example)
- [Local Notifications примеры](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example)

## 🤝 Поддержка

### Сообщество
- **GitHub Issues** - баги и предложения
- **Stack Overflow** - вопросы по реализации
- **Discord** - обсуждение и помощь

### Контакты
- **Email**: support@mymodus.com
- **Telegram**: @mymodus_support
- **Documentation**: https://docs.mymodus.com

---

**Система реальных уведомлений MyModus** - мощная платформа для создания интерактивного пользовательского опыта с помощью push-уведомлений, интегрированная со всеми модулями приложения и поддерживающая масштабируемость для миллионов пользователей. 🚀✨
