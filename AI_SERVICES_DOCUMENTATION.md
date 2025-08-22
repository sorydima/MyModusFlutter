# 🤖 MyModus AI Services Documentation

## 📋 Обзор

MyModus использует передовые AI технологии для создания персонализированного опыта покупок, генерации контента и анализа стиля пользователей. Все сервисы интегрированы с OpenAI GPT-4 для максимальной эффективности.

## 🏗️ Архитектура AI сервисов

```
┌─────────────────────────────────────────────────────────────┐
│                    AI Services Layer                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │Recommendations  │  │Content Gen      │  │Style       │ │
│  │Service          │  │Service          │  │Analysis    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                    OpenAI GPT-4 API                        │
├─────────────────────────────────────────────────────────────┤
│                    Database Layer                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │Products     │  │Users        │  │User Preferences    │ │
│  │             │  │             │  │                     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 1. AI Product Recommendations Service

### Описание
Сервис для генерации персональных рекомендаций товаров на основе предпочтений пользователя, истории покупок и анализа поведения.

### Основные возможности

#### 🔍 Персональные рекомендации
```dart
Future<List<ProductRecommendation>> generatePersonalRecommendations({
  required String userId,
  required List<Product> userHistory,
  required List<Product> availableProducts,
  required List<Product> recentlyViewed,
  int limit = 10,
})
```

**Параметры:**
- `userId` - ID пользователя
- `userHistory` - история покупок
- `availableProducts` - доступные товары
- `recentlyViewed` - недавно просмотренные
- `limit` - максимальное количество рекомендаций

**Возвращает:** Список рекомендаций с оценкой и объяснением

#### 🔄 Рекомендации похожих товаров
```dart
Future<List<ProductRecommendation>> generateSimilarProductRecommendations({
  required Product baseProduct,
  required List<Product> availableProducts,
  int limit = 8,
})
```

**Параметры:**
- `baseProduct` - базовый товар для сравнения
- `availableProducts` - доступные товары
- `limit` - максимальное количество рекомендаций

#### 🆕 Рекомендации для новых пользователей
```dart
Future<List<ProductRecommendation>> generateNewUserRecommendations({
  required List<Product> availableProducts,
  required String? userLocation,
  int limit = 10,
})
```

### Алгоритм рекомендаций

1. **Анализ предпочтений пользователя:**
   - Категории товаров
   - Бренды
   - Стили
   - Цвета
   - Ценовой диапазон

2. **Scoring система:**
   - Категория: +4.0 балла
   - Бренд: +3.5 балла
   - Стиль: +3.0 балла
   - Цвет: +2.5 балла
   - Цена: +2.0 балла
   - Рейтинг: +0.8 × рейтинг
   - Скидка: +1.5 балла
   - Новизна: +1.0 балла

3. **AI-улучшение объяснений:**
   - Персонализированные объяснения
   - Контекстные рекомендации
   - Эмоциональная привязка

### API Endpoints

```
GET /api/v1/ai/recommendations/personal/{userId}
GET /api/v1/ai/recommendations/similar/{productId}
GET /api/v1/ai/recommendations/new-user
GET /api/v1/ai/recommendations/preferences/{userId}
POST /api/v1/ai/recommendations/preferences/{userId}
GET /api/v1/ai/recommendations/stats
```

## ✍️ 2. AI Content Generation Service

### Описание
Сервис для автоматической генерации контента: описаний товаров, хештегов, постов для соцсетей, SEO-заголовков и отзывов.

### Основные возможности

#### 📝 Генерация описаний товаров
```dart
Future<ProductDescription> generateProductDescription({
  required String productName,
  required String category,
  required Map<String, dynamic> specifications,
  String? brand,
  String? style,
  String? targetAudience,
  int? price,
  String? language = 'ru',
})
```

**Возвращает:**
```dart
class ProductDescription {
  final String content;        // Сгенерированное описание
  final String language;       // Язык контента
  final DateTime generatedAt;  // Время генерации
  final int wordCount;         // Количество слов
}
```

#### 🏷️ Генерация хештегов
```dart
Future<List<String>> generateProductHashtags({
  required String productName,
  required String category,
  String? brand,
  String? style,
  String? targetAudience,
  int hashtagCount = 8,
  String? language = 'ru',
})
```

**Особенности:**
- Автоматическое добавление #MyModusLook
- Трендовые хештеги
- Категорийные хештеги
- Брендовые хештеги

#### 📱 Генерация постов для соцсетей
```dart
Future<SocialMediaPost> generateSocialMediaPost({
  required String productName,
  required String category,
  required String productDescription,
  String? brand,
  String? style,
  String? targetAudience,
  String? platform = 'instagram',
  String? tone = 'casual',
  String? language = 'ru',
})
```

**Поддерживаемые платформы:**
- Instagram
- Facebook
- Twitter
- TikTok

**Тоны:**
- Casual (повседневный)
- Business (деловой)
- Elegant (элегантный)
- Sporty (спортивный)

#### 🔍 SEO-оптимизированные заголовки
```dart
Future<String> generateSEOOptimizedTitle({
  required String productName,
  required String category,
  String? brand,
  String? style,
  String? keyFeatures,
  String? language = 'ru',
})
```

**Требования:**
- Длина: 50-60 символов
- Включение ключевых слов
- Привлекательность для кликов
- SEO-оптимизация

#### ⭐ Генерация отзывов
```dart
Future<ProductReview> generateProductReview({
  required String productName,
  required String category,
  required int rating,
  String? brand,
  String? style,
  String? pros,
  String? cons,
  String? language = 'ru',
})
```

### Промпты и настройки

#### Системные промпты
- **Копирайтинг:** Эксперт по маркетингу и продажам
- **Хештеги:** Эксперт по социальным сетям
- **Соцсети:** Эксперт по контент-маркетингу
- **SEO:** SEO-эксперт
- **Отзывы:** Эксперт по анализу товаров

#### Параметры генерации
- **Model:** GPT-4
- **Max Tokens:** 100-500 (в зависимости от типа контента)
- **Temperature:** 0.6-0.8 (баланс креативности и точности)

## 👗 3. AI Style Analysis Service

### Описание
Сервис для анализа стиля пользователя, создания персональных рекомендаций по стилю и анализа модных трендов.

### Основные возможности

#### 🎨 Анализ стиля пользователя
```dart
Future<UserStyleProfile> analyzeUserStyle({
  required String userId,
  required List<Product> purchaseHistory,
  required List<Product> wishlist,
  required List<Product> recentlyViewed,
  String? userPreferences,
  String? language = 'ru',
})
```

**Возвращает профиль стиля:**
```dart
class UserStyleProfile {
  final String primaryStyle;           // Основной стиль
  final List<String> secondaryStyles;  // Дополнительные стили
  final List<String> colorPalette;     // Цветовая палитра
  final List<String> brandPreferences; // Предпочтения по брендам
  final PriceRange priceRange;         // Ценовой диапазон
  final List<String> occasionPreferences; // Предпочтения по поводам
  final List<String> seasonPreferences;   // Предпочтения по сезонам
  final double styleConfidence;        // Уверенность в стиле (0.0-1.0)
  final String aiInsights;             // AI-анализ и советы
  final DateTime lastUpdated;          // Время последнего обновления
}
```

#### 🔄 Анализ совместимости стилей
```dart
Future<StyleCompatibility> analyzeStyleCompatibility({
  required String userStyle,
  required String productStyle,
  required Map<String, dynamic> productAttributes,
  String? language = 'ru',
})
```

**Возвращает:**
```dart
class StyleCompatibility {
  final String userStyle;           // Стиль пользователя
  final String productStyle;        // Стиль товара
  final double score;               // Оценка совместимости (0.0-1.0)
  final String reason;              // Объяснение совместимости
  final List<String> styleTips;     // Советы по стилю
}
```

#### 💡 Рекомендации по стилю
```dart
Future<List<StyleRecommendation>> generateStyleRecommendations({
  required UserStyleProfile userStyleProfile,
  required List<Product> availableProducts,
  required String occasion,
  required String season,
  int limit = 10,
  String? language = 'ru',
})
```

#### 📊 Анализ трендов
```dart
Future<StyleTrends> analyzeStyleTrends({
  required String category,
  required String season,
  String? location,
  String? language = 'ru',
})
```

**Возвращает:**
```dart
class StyleTrends {
  final String category;           // Категория товаров
  final String season;             // Сезон
  final String trends;             // Описание трендов
  final List<String> colors;       // Популярные цвета
  final List<String> materials;    // Популярные материалы
  final List<String> styles;       // Популярные стили
  final List<String> recommendations; // Рекомендации по покупкам
  final DateTime analyzedAt;       // Время анализа
}
```

#### 🎒 Капсульный гардероб
```dart
Future<CapsuleWardrobe> createCapsuleWardrobe({
  required UserStyleProfile userStyleProfile,
  required String occasion,
  required String season,
  required int itemCount,
  String? language = 'ru',
})
```

**Возвращает:**
```dart
class CapsuleWardrobe {
  final String userId;             // ID пользователя
  final String occasion;           // Повод
  final String season;             // Сезон
  final List<WardrobeItem> items; // Список вещей
  final String description;        // Описание гардероба
  final DateTime createdAt;        // Время создания
}
```

### Определение стилей

#### Поддерживаемые стили
- **Casual** - повседневный, комфортный
- **Business** - деловой, офисный
- **Sport** - спортивный, активный
- **Elegant** - элегантный, изысканный
- **Street** - уличный, городской
- **Vintage** - винтажный, ретро
- **Modern** - современный, трендовый
- **Bohemian** - богемный, творческий
- **Minimalist** - минималистичный, простой

#### Определение стиля
Сервис анализирует:
- Название товара
- Описание
- Категорию
- Бренд
- Цену
- Отзывы

### Алгоритм анализа

1. **Сбор данных:**
   - История покупок
   - Wishlist
   - Недавно просмотренные

2. **Анализ паттернов:**
   - Частота стилей
   - Цветовые предпочтения
   - Брендовые предпочтения
   - Ценовые предпочтения

3. **AI-анализ:**
   - Генерация инсайтов
   - Рекомендации по улучшению
   - Персонализированные советы

## 🔧 Конфигурация

### Переменные окружения

```bash
# OpenAI API
OPENAI_API_KEY=your_openai_api_key
OPENAI_BASE_URL=https://api.openai.com/v1

# Логирование
LOG_LEVEL=info
```

### Настройки сервисов

```dart
// Рекомендации
final recommendationsService = AIRecommendationsService(
  apiKey: 'your_key',
  baseUrl: 'https://api.openai.com/v1',
);

// Генерация контента
final contentService = AIContentGenerationService(
  apiKey: 'your_key',
  baseUrl: 'https://api.openai.com/v1',
);

// Анализ стиля
final styleService = AIStyleAnalysisService(
  apiKey: 'your_key',
  baseUrl: 'https://api.openai.com/v1',
);
```

## 📊 Мониторинг и логирование

### Логирование
Все сервисы используют структурированное логирование с уровнями:
- **INFO** - успешные операции
- **WARNING** - предупреждения
- **ERROR** - ошибки
- **DEBUG** - отладочная информация

### Метрики
- Количество сгенерированных рекомендаций
- Время ответа API
- Успешность операций
- Использование токенов OpenAI

## 🧪 Тестирование

### Unit тесты
```bash
# Запуск всех тестов
dart test

# Запуск тестов AI сервисов
dart test test/ai_services_test.dart

# Запуск с покрытием
dart test --coverage=coverage
```

### Тестовые данные
Все сервисы включают fallback генерацию для тестирования без OpenAI API.

## 🚀 Развертывание

### Docker
```bash
# Сборка образа
docker build -t mymodus-ai .

# Запуск контейнера
docker run -p 8080:8080 \
  -e OPENAI_API_KEY=your_key \
  mymodus-ai
```

### Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mymodus-ai
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mymodus-ai
  template:
    metadata:
      labels:
        app: mymodus-ai
    spec:
      containers:
      - name: mymodus-ai
        image: mymodus-ai:latest
        env:
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: openai-secret
              key: api-key
        ports:
        - containerPort: 8080
```

## 🔒 Безопасность

### API ключи
- Хранение в переменных окружения
- Шифрование в Kubernetes secrets
- Ротация ключей

### Rate limiting
- Ограничение запросов к OpenAI API
- Защита от злоупотреблений
- Мониторинг использования

### Валидация данных
- Проверка входных параметров
- Санитизация пользовательского ввода
- Защита от инъекций

## 📈 Производительность

### Кэширование
- Redis для кэширования рекомендаций
- TTL для обновления данных
- Инвалидация при изменении предпочтений

### Асинхронность
- Неблокирующие операции
- Очереди для тяжелых задач
- Пул соединений с OpenAI

### Масштабирование
- Горизонтальное масштабирование
- Load balancing
- Автоскейлинг на основе нагрузки

## 🔮 Планы развития

### Краткосрочные (1-3 месяца)
- [ ] Интеграция с другими AI провайдерами
- [ ] Улучшение алгоритмов рекомендаций
- [ ] Добавление новых типов контента

### Среднесрочные (3-6 месяцев)
- [ ] Машинное обучение на основе пользовательских данных
- [ ] Компьютерное зрение для анализа стиля
- [ ] Голосовые ассистенты

### Долгосрочные (6+ месяцев)
- [ ] AR/VR для примерки одежды
- [ ] Персонализированные дизайны
- [ ] AI-стилисты

## 📞 Поддержка

### Документация
- [API Reference](API_REFERENCE.md)
- [Examples](EXAMPLES.md)
- [Troubleshooting](TROUBLESHOOTING.md)

### Контакты
- **Email:** ai-support@mymodus.com
- **Slack:** #ai-services
- **GitHub:** [Issues](https://github.com/mymodus/ai-services/issues)

---

*Документация обновлена: ${DateTime.now().toIso8601String()}*
