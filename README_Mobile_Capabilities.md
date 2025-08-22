# 📱 Мобильные возможности - MyModus

## Обзор

Модуль **Мобильные возможности** предоставляет комплексные функции для мобильных приложений, включая офлайн режим, геолокацию, интеграцию с календарем и фоновую синхронизацию данных.

## 🚀 Основные возможности

### 1. **Офлайн режим**
- 📱 Локальное кэширование данных
- 🔄 Автоматическая синхронизация при подключении
- 💾 Управление версиями кэшированных данных
- 🧹 Автоматическая очистка устаревших данных

### 2. **Геолокация**
- 📍 Получение текущего местоположения
- 🗺️ Поиск ближайших предложений и магазинов
- 🎯 Фильтрация по категориям и радиусу
- 📍 Обратное геокодирование (адрес по координатам)

### 3. **Интеграция с календарем**
- 📅 Создание и управление событиями
- 🔔 Уведомления о событиях
- 📍 Привязка событий к локациям
- 🏷️ Категоризация событий по типам

### 4. **Фоновая синхронизация**
- ⚡ Автоматическая синхронизация в фоне
- 🔋 Оптимизация по уровню заряда батареи
- 📶 Умная синхронизация по типу подключения
- 📊 Мониторинг статуса синхронизации

## 🏗️ Архитектура

### Backend (Dart + Shelf)

```
backend/
├── lib/
│   ├── services/
│   │   └── mobile_capabilities_service.dart    # Основной сервис
│   └── handlers/
│       └── mobile_capabilities_handler.dart    # API endpoints
└── bin/
    └── server.dart                             # Интеграция в сервер
```

### Frontend (Flutter)

```
frontend/
├── lib/
│   ├── services/
│   │   └── mobile_capabilities_service.dart    # Фронтенд сервис
│   ├── screens/
│   │   └── mobile_capabilities_screen.dart     # Главный экран
│   └── widgets/
│       ├── offline_mode_tab.dart               # Вкладка офлайн режима
│       ├── geolocation_tab.dart                # Вкладка геолокации
│       ├── calendar_tab.dart                   # Вкладка календаря
│       └── background_sync_tab.dart            # Вкладка синхронизации
```

## 🔌 API Endpoints

### Офлайн режим
```
POST   /api/mobile/offline/cache              # Сохранить данные в кэш
GET    /api/mobile/offline/cache/{userId}/{dataType}  # Получить данные из кэша
POST   /api/mobile/offline/sync               # Синхронизировать офлайн данные
DELETE /api/mobile/offline/cache/{userId}     # Очистить кэш пользователя
```

### Геолокация
```
POST   /api/mobile/location/update            # Обновить местоположение
GET    /api/mobile/location/{userId}          # Получить местоположение
GET    /api/mobile/location/nearby-offers     # Найти ближайшие предложения
GET    /api/mobile/location/stores            # Найти ближайшие магазины
```

### Календарь
```
POST   /api/mobile/calendar/event             # Добавить событие
GET    /api/mobile/calendar/events/{userId}   # Получить события пользователя
PUT    /api/mobile/calendar/event/{eventId}   # Обновить событие
DELETE /api/mobile/calendar/event/{eventId}   # Удалить событие
```

### Фоновая синхронизация
```
POST   /api/mobile/background-sync            # Запустить фоновую синхронизацию
GET    /api/mobile/background-sync/status/{userId}  # Статус синхронизации
POST   /api/mobile/background-sync/cleanup    # Очистить старые данные
```

### Демо и тестирование
```
POST   /api/mobile/demo/simulate-offline      # Симуляция офлайн режима
POST   /api/mobile/demo/simulate-location     # Симуляция обновления геолокации
POST   /api/mobile/demo/simulate-calendar     # Симуляция события календаря
```

## 📱 Использование

### 1. Инициализация сервиса

```dart
// Backend
final mobileService = MobileCapabilitiesService(
  notificationService: notificationService,
);

// Frontend
final mobileService = MobileCapabilitiesService();
```

### 2. Офлайн режим

```dart
// Сохранение данных в кэш
await mobileService.saveToLocalCache(
  userId: 'user123',
  dataType: 'products',
  data: {'id': 1, 'name': 'Товар', 'price': 1000},
);

// Получение данных из кэша
final data = mobileService.getFromLocalCache(
  userId: 'user123',
  dataType: 'products',
);

// Синхронизация с сервером
final success = await mobileService.syncLocalData(
  userId: 'user123',
  dataTypes: ['products', 'notifications'],
);
```

### 3. Геолокация

```dart
// Получение текущего местоположения
final position = await mobileService.getCurrentLocation();

// Поиск ближайших предложений
final offers = await mobileService.getNearbyOffers(
  userId: 'user123',
  radiusKm: 5.0,
  category: 'Одежда',
);

// Поиск ближайших магазинов
final stores = await mobileService.getNearbyStores(
  userId: 'user123',
  radiusKm: 10.0,
);
```

### 4. Календарь

```dart
// Добавление события
final success = await mobileService.addCalendarEvent(
  userId: 'user123',
  title: 'Встреча',
  description: 'Важная встреча',
  startTime: DateTime.now().add(Duration(hours: 1)),
  endTime: DateTime.now().add(Duration(hours: 2)),
  location: 'Офис',
  eventType: 'meeting',
);

// Получение событий
final events = await mobileService.getCalendarEvents(
  userId: 'user123',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 7)),
);
```

### 5. Фоновая синхронизация

```dart
// Установка пользователя
mobileService.setCurrentUser('user123');

// Принудительная синхронизация
await mobileService.forceSync();

// Проверка подключения
await mobileService.checkConnectivity();
```

## 🔧 Настройка

### 1. Зависимости

#### Backend (pubspec.yaml)
```yaml
dependencies:
  shelf: ^1.4.1
  shelf_router: ^1.1.4
  logger: ^2.0.2+1
```

#### Frontend (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
  geolocator: ^10.1.0
  permission_handler: ^11.0.1
  provider: ^6.1.1
```

### 2. Разрешения

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Приложению необходим доступ к геолокации для поиска ближайших предложений</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Приложению необходим доступ к геолокации в фоне для уведомлений о предложениях</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>background-processing</string>
</array>
```

### 3. Интеграция в приложение

#### Backend
```dart
// server.dart
import '../lib/services/mobile_capabilities_service.dart';
import '../lib/handlers/mobile_capabilities_handler.dart';

// Инициализация
final mobileCapabilitiesService = MobileCapabilitiesService(
  notificationService: notificationService,
);

final mobileCapabilitiesHandler = MobileCapabilitiesHandler(
  mobileService: mobileCapabilitiesService,
  db: DatabaseService(),
);

// Маршрутизация
app.mount('/api/mobile', mobileCapabilitiesHandler.router);
```

#### Frontend
```dart
// main.dart
import 'package:provider/provider.dart';
import 'services/mobile_capabilities_service.dart';

// Провайдер
ChangeNotifierProvider(
  create: (context) => MobileCapabilitiesService(),
  child: MyApp(),
),

// Навигация
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MobileCapabilitiesScreen(),
  ),
);
```

## 🧪 Тестирование

### 1. Демо функции

Модуль включает демо функции для тестирования:

```dart
// Симуляция офлайн режима
POST /api/mobile/demo/simulate-offline
{
  "userId": "demo_user_123"
}

// Симуляция геолокации
POST /api/mobile/demo/simulate-location
{
  "userId": "demo_user_123"
}

// Симуляция календаря
POST /api/mobile/demo/simulate-calendar
{
  "userId": "demo_user_123"
}
```

### 2. Тестовые данные

- **Пользователь**: `demo_user_123`
- **Радиус поиска**: 5-10 км
- **Категории**: Одежда, Обувь, Аксессуары
- **Магазины**: Zara, H&M, Nike

## 📊 Мониторинг и логирование

### 1. Логирование

```dart
// Backend
final logger = Logger();
logger.i('Mobile capabilities service initialized');
logger.e('Failed to sync offline data: $e');

// Frontend
debugPrint('Mobile capabilities service initialized');
debugPrint('Failed to get location: $e');
```

### 2. Метрики

- Время синхронизации
- Количество синхронизированных элементов
- Ошибки синхронизации
- Размер кэша
- Статус подключения

## 🔒 Безопасность

### 1. Разрешения

- Запрос разрешений на геолокацию
- Проверка статуса разрешений
- Graceful fallback при отказе

### 2. Данные

- Шифрование локального кэша
- Валидация входных данных
- Очистка чувствительной информации

## 🚀 Производительность

### 1. Оптимизация

- Ленивая загрузка данных
- Кэширование результатов
- Фоновая синхронизация
- Умная очистка кэша

### 2. Мониторинг

- Отслеживание использования памяти
- Мониторинг времени ответа
- Анализ паттернов использования

## 🔮 Будущие улучшения

### 1. Расширенные возможности

- [ ] Push-уведомления о распродажах
- [ ] Интеграция с календарем устройства
- [ ] Офлайн карты и навигация
- [ ] Умные напоминания

### 2. Интеграции

- [ ] Google Maps API
- [ ] Apple Maps
- [ ] Календарь устройства
- [ ] Контакты

### 3. AI и ML

- [ ] Предсказание местоположения
- [ ] Умные рекомендации по времени
- [ ] Анализ паттернов перемещения
- [ ] Персонализированные уведомления

## 📚 Дополнительные ресурсы

### 1. Документация

- [Flutter Geolocation](https://pub.dev/packages/geolocator)
- [Permission Handler](https://pub.dev/packages/permission_handler)
- [Shared Preferences](https://pub.dev/packages/shared_preferences)

### 2. Примеры использования

- [Офлайн режим в Flutter](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)
- [Геолокация в мобильных приложениях](https://developer.android.com/training/location)
- [Фоновая синхронизация](https://developer.android.com/training/sync-adapters)

### 3. Лучшие практики

- [Material Design Guidelines](https://material.io/design)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Android Design Guidelines](https://developer.android.com/guide/topics/ui)

## 🤝 Поддержка

Для получения поддержки или сообщения об ошибках:

1. Создайте issue в репозитории
2. Опишите проблему подробно
3. Приложите логи и скриншоты
4. Укажите версию Flutter и платформу

---

**Модуль мобильных возможностей** - это мощный инструмент для создания современных мобильных приложений с поддержкой офлайн режима, геолокации и умной синхронизацией данных.
