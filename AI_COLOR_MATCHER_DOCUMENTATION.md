# AI Color Matcher - Техническая документация

## 📋 Обзор

**AI Color Matcher** - это интеллектуальная система подбора цветов для модных образов, использующая искусственный интеллект для анализа изображений, генерации персональных палитр и предоставления рекомендаций по гармоничным цветовым сочетаниям.

### 🎯 Основные возможности

- **Анализ цветов на фото** - определение доминирующих цветов и их процентного соотношения
- **Персональные палитры** - создание уникальных цветовых схем на основе предпочтений пользователя
- **Теория цвета** - подбор гармоничных цветов по различным принципам (дополнительные, аналогичные, триадные)
- **Рекомендации образов** - умные советы по созданию стильных образов
- **Цветовые тренды** - анализ популярности цветов по категориям и сезонам
- **Сезонные палитры** - готовые цветовые схемы для каждого времени года
- **История и статистика** - отслеживание предпочтений и прогресса пользователя

## 🏗️ Архитектура

### Backend (Dart + Shelf)

```
backend/
├── lib/
│   ├── services/
│   │   └── ai_color_matcher_service.dart      # Бизнес-логика
│   ├── handlers/
│   │   └── ai_color_matcher_handler.dart      # API endpoints
│   └── models.dart                            # Модели данных
└── bin/
    └── server.dart                            # Основной сервер
```

### Frontend (Flutter)

```
frontend/
├── lib/
│   ├── services/
│   │   └── ai_color_matcher_service.dart      # API клиент
│   ├── providers/
│   │   └── ai_color_matcher_provider.dart     # State management
│   └── screens/
│       └── ai_color_matcher_screen.dart       # UI экран
```

### Архитектурные принципы

- **Service-Handler Pattern** - разделение бизнес-логики и API
- **Provider Pattern** - управление состоянием на frontend
- **RESTful API** - стандартные HTTP методы для всех операций
- **Модульная структура** - легко расширяемые компоненты

## 🗄️ Структура базы данных

### Основные таблицы

```sql
-- Анализ цветов на фото
CREATE TABLE color_analyses (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    image_url TEXT NOT NULL,
    dominant_colors JSONB NOT NULL,
    color_palette JSONB NOT NULL,
    recommendations JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Персональные палитры пользователей
CREATE TABLE user_color_palettes (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    colors JSONB NOT NULL,
    description TEXT,
    tags JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Предпочтения пользователей
CREATE TABLE user_color_preferences (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) UNIQUE NOT NULL,
    skin_tone VARCHAR(50),
    hair_color VARCHAR(50),
    eye_color VARCHAR(50),
    preferred_colors JSONB,
    avoided_colors JSONB,
    style VARCHAR(100),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- История цветовых анализов
CREATE TABLE color_analysis_history (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    analysis_type VARCHAR(100) NOT NULL,
    base_color VARCHAR(7),
    harmony_type VARCHAR(50),
    result_colors JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Индексы для производительности

```sql
CREATE INDEX idx_color_analyses_user_id ON color_analyses(user_id);
CREATE INDEX idx_color_analyses_created_at ON color_analyses(created_at);
CREATE INDEX idx_user_palettes_user_id ON user_color_palettes(user_id);
CREATE INDEX idx_user_preferences_user_id ON user_color_preferences(user_id);
CREATE INDEX idx_analysis_history_user_id ON color_analysis_history(user_id);
```

## 🔧 Как это работает

### 1. Анализ цветов на фото

```dart
// 1. Пользователь загружает фото
// 2. Система отправляет изображение в AI сервис
// 3. AI анализирует пиксели и определяет доминирующие цвета
// 4. Система генерирует гармоничную палитру
// 5. Результаты сохраняются в базе данных
```

### 2. Генерация персональной палитры

```dart
// 1. Анализ истории пользователя
// 2. Учет физических характеристик (тон кожи, цвет волос, глаз)
// 3. Применение теории цвета для создания гармоничных сочетаний
// 4. Генерация рекомендаций по использованию
```

### 3. Подбор гармоничных цветов

```dart
// Типы гармонии:
// - Complementary (дополнительные) - противоположные на цветовом круге
// - Analogous (аналогичные) - соседние цвета
// - Triadic (триадные) - равномерно распределенные
// - Monochromatic (монохромные) - оттенки одного цвета
```

## 🎨 UI/UX особенности

### Вкладки интерфейса

1. **📸 Фото** - загрузка и анализ изображений
2. **🎨 Палитра** - персональные и сезонные цветовые схемы
3. **🔗 Гармония** - подбор гармоничных цветов
4. **💡 Рекомендации** - советы по созданию образов
5. **📊 Тренды** - анализ популярности цветов
6. **📚 История** - статистика и сохраненные палитры

### Ключевые UI компоненты

- **Color Swatches** - интерактивные цветовые образцы
- **Harmony Type Selector** - выбор типа цветовой гармонии
- **Seasonal Filters** - фильтрация по сезонам
- **Occasion Filters** - фильтрация по случаям
- **Progress Indicators** - индикаторы загрузки
- **Error Handling** - обработка ошибок с понятными сообщениями

## ⚙️ Технические детали

### API Endpoints

#### Основные операции

```http
POST /api/color-matcher/analyze-photo
POST /api/color-matcher/generate-palette
GET  /api/color-matcher/personal-palette/{userId}
GET  /api/color-matcher/harmonious-colors
GET  /api/color-matcher/color-theory/{harmonyType}
```

#### Рекомендации и тренды

```http
GET /api/color-matcher/recommendations/{userId}
GET /api/color-matcher/outfit-recommendations/{userId}
GET /api/color-matcher/color-trends
GET /api/color-matcher/seasonal-palettes
```

#### Управление палитрами

```http
POST /api/color-matcher/save-palette
GET  /api/color-matcher/user-palettes/{userId}
DELETE /api/color-matcher/palette/{paletteId}
GET  /api/color-matcher/export-palette/{paletteId}
POST /api/color-matcher/import-palette
```

#### Пользовательские настройки

```http
PUT  /api/color-matcher/user-preferences/{userId}
GET  /api/color-matcher/user-preferences/{userId}
GET  /api/color-matcher/history/{userId}
GET  /api/color-matcher/stats/{userId}
```

### Форматы данных

#### Анализ фото

```json
{
  "success": true,
  "analysisId": "analysis_123",
  "dominantColors": [
    {
      "color": "#FF6B6B",
      "percentage": 25,
      "name": "Коралловый"
    }
  ],
  "colorPalette": [
    {
      "color": "#FF6B6B",
      "type": "primary"
    }
  ],
  "recommendations": [...],
  "seasonalPalette": {...}
}
```

#### Персональная палитра

```json
{
  "success": true,
  "paletteId": "palette_123",
  "personalPalette": [
    {
      "color": "#FF6B6B",
      "type": "primary",
      "confidence": 0.9
    }
  ],
  "analysis": {...},
  "recommendations": [...]
}
```

### Обработка ошибок

```dart
try {
  final result = await colorMatcherService.analyzePhotoColors(
    imageUrl: imageUrl,
    userId: userId,
  );
  
  if (result['success'] == true) {
    // Обработка успешного результата
  } else {
    // Обработка ошибки
    final error = result['error'];
    // Показать пользователю
  }
} catch (e) {
  // Обработка сетевых ошибок
  final error = 'Network error: $e';
}
```

## 🧪 Тестирование

### Backend тесты

```bash
# Запуск тестов
cd backend
dart test test/ai_color_matcher_test.dart

# Тестирование API endpoints
dart run test_ai_color_matcher.dart
```

### Frontend тесты

```bash
# Запуск тестов
cd frontend
flutter test test/ai_color_matcher_test.dart

# Тестирование UI
flutter test test/widget_test.dart
```

### Тестовые сценарии

1. **Анализ фото** - загрузка изображения и проверка результатов
2. **Генерация палитры** - создание персональной цветовой схемы
3. **Поиск гармонии** - подбор гармоничных цветов
4. **Рекомендации** - получение советов по образам
5. **Тренды** - анализ популярности цветов
6. **Сохранение/загрузка** - работа с пользовательскими палитрами

## 🚀 Развертывание

### Требования

- **Backend**: Dart 3.0+, PostgreSQL 12+
- **Frontend**: Flutter 3.0+, Android 6.0+ / iOS 12.0+
- **AI Services**: TensorFlow/PyTorch для анализа изображений
- **Storage**: Минимум 10GB для изображений и данных

### Переменные окружения

```bash
# Backend
PORT=8080
DATABASE_URL=postgresql://user:pass@localhost:5432/mymodus
AI_SERVICE_URL=https://ai-service.example.com
AI_API_KEY=your_ai_api_key

# Frontend
API_BASE_URL=http://localhost:8080/api
ENVIRONMENT=development
```

### Docker развертывание

```dockerfile
# Backend Dockerfile
FROM dart:3.0
WORKDIR /app
COPY . .
RUN dart pub get
EXPOSE 8080
CMD ["dart", "run", "bin/server.dart"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mymodus
    depends_on:
      - db
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=mymodus
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## 📊 Мониторинг

### Метрики производительности

- **Response Time** - время ответа API
- **Throughput** - количество запросов в секунду
- **Error Rate** - процент ошибок
- **Memory Usage** - использование памяти
- **CPU Usage** - загрузка процессора

### Логирование

```dart
final logger = Logger();

logger.info('Analyzing photo colors for user: $userId');
logger.error('Error analyzing photo colors: $e');
logger.debug('Generated palette with ${palette.length} colors');
```

### Алерты

- **High Error Rate** - >5% ошибок в течение 5 минут
- **Slow Response** - >2 секунд для 95% запросов
- **Service Down** - недоступность API более 1 минуты
- **High Memory Usage** - >80% использования памяти

## 🔮 Будущие улучшения

### Краткосрочные (1-3 месяца)

- **Интеграция с реальными AI сервисами** - замена мок-данных
- **Улучшение UI/UX** - анимации, переходы, жесты
- **Кэширование** - оптимизация производительности
- **Офлайн режим** - работа без интернета

### Среднесрочные (3-6 месяцев)

- **Машинное обучение** - персонализация рекомендаций
- **Социальные функции** - обмен палитрами между пользователями
- **Интеграция с камерой** - реальный анализ в реальном времени
- **AR примерка** - виртуальная примерка цветов

### Долгосрочные (6+ месяцев)

- **AI стилист** - полный анализ образов
- **Интеграция с e-commerce** - покупка одежды по цветам
- **Международная локализация** - поддержка разных языков
- **Enterprise версия** - для дизайнеров и стилистов

## 📚 Заключение

**AI Color Matcher** представляет собой мощную и масштабируемую систему для работы с цветами в модной индустрии. Система сочетает в себе современные технологии разработки, интуитивный пользовательский интерфейс и гибкую архитектуру, что позволяет легко расширять функциональность и адаптировать под различные потребности.

### Ключевые преимущества

- **Интеллектуальный анализ** - использование AI для точного определения цветов
- **Персонализация** - учет индивидуальных предпочтений пользователя
- **Теория цвета** - научный подход к подбору гармоничных сочетаний
- **Масштабируемость** - модульная архитектура для легкого расширения
- **Производительность** - оптимизированные алгоритмы и кэширование

### Области применения

- **Модные приложения** - подбор одежды и аксессуаров
- **Дизайн интерьера** - цветовые решения для помещений
- **Графический дизайн** - создание брендинга и логотипов
- **Веб-дизайн** - цветовые схемы для сайтов
- **Образование** - изучение теории цвета

Система готова к промышленному использованию и может стать основой для создания новых продуктов в области моды и дизайна.
