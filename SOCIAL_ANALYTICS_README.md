# 📊 Social Analytics - Руководство пользователя

## Описание

**Social Analytics** - это мощная система аналитики и трендов для платформы MyModus, которая помогает бизнесу понимать поведение аудитории, отслеживать тренды и принимать обоснованные решения на основе данных.

## 🚀 Быстрый старт

### Backend

```bash
# 1. Перейти в директорию backend
cd backend

# 2. Установить зависимости
dart pub get

# 3. Запустить сервер
dart run bin/server.dart

# 4. Проверить доступность
curl http://localhost:8080/health
```

### Frontend

```bash
# 1. Перейти в директорию frontend
cd frontend

# 2. Установить зависимости
flutter pub get

# 3. Запустить приложение
flutter run

# 4. Открыть Social Analytics экран
# Навигация: Главное меню → Социальная аналитика
```

### Тестирование API

```bash
# Запустить тесты
dart run test_social_analytics.dart

# Результат: 12 тестов для проверки функциональности
```

## 🎯 Ключевые возможности

### 📈 Анализ трендов
- **Категорийные тренды** - отслеживание популярности товаров
- **Временные тренды** - анализ изменений по периодам
- **Трендовые счеты** - алгоритмическая оценка популярности
- **Топ категории** - ранжирование по метрикам

### 👥 Анализ аудитории
- **Демографический анализ** - возраст, пол, география
- **Интересы и предпочтения** - категории, стили, бренды
- **Поведенческие паттерны** - время на сайте, глубина просмотра
- **Сегментация** - активные, новые, возвращающиеся пользователи

### 🏢 Анализ конкурентов
- **Ценовой анализ** - сравнение цен, средние значения
- **Ассортиментный анализ** - количество товаров, разнообразие
- **Маркетинговые стратегии** - активность в соцсетях
- **Рейтинг конкурентов** - оценка конкурентной позиции

### 🔮 Предиктивная аналитика
- **Прогнозы трендов** - предсказание будущей популярности
- **Машинное обучение** - анализ исторических данных
- **Уровень уверенности** - оценка точности прогнозов
- **Стратегические рекомендации** - советы на основе прогнозов

### 📋 Отчетность и экспорт
- **Типы отчетов** - тренды, аудитория, конкуренты, комплексные
- **Форматы экспорта** - JSON, CSV, XML
- **Сравнение периодов** - анализ изменений
- **Автоматическая генерация** - по расписанию

## 🏗️ Архитектура

### Backend
- **SocialAnalyticsService** - основная логика анализа
- **SocialAnalyticsHandler** - API endpoints
- **Database Layer** - хранение и агрегация данных
- **Performance Optimization** - кэширование, индексы

### Frontend
- **SocialAnalyticsScreen** - основной экран с 6 вкладками
- **SocialAnalyticsProvider** - управление состоянием
- **SocialAnalyticsService** - взаимодействие с API
- **Responsive Design** - адаптация под устройства

## 🎨 UI/UX особенности

### Tab-based Navigation
```
📊 Тренды      👥 Аудитория    🏢 Конкуренты
🔮 Прогнозы    📋 Отчеты       📊 Сравнение
```

### Интерактивные фильтры
- **Период**: День, Неделя, Месяц, Год
- **Категория**: Все категории или конкретная
- **Динамическое обновление** данных

### Визуализация данных
- **Карточки сводки** - ключевые метрики
- **Цветовое кодирование** - интуитивное понимание трендов
- **Responsive дизайн** - оптимизация для всех устройств

## 🔌 API Endpoints

### Основные endpoints

| Метод | Endpoint | Описание |
|-------|----------|----------|
| `GET` | `/api/social-analytics/trends` | Получить тренды по категориям |
| `GET` | `/api/social-analytics/social-metrics/{productId}` | Социальные метрики продукта |
| `GET` | `/api/social-analytics/audience/{category}` | Анализ аудитории |
| `GET` | `/api/social-analytics/predictions/{category}` | Прогнозы трендов |
| `GET` | `/api/social-analytics/competitors/{category}` | Анализ конкурентов |
| `POST` | `/api/social-analytics/reports` | Генерировать отчеты |
| `GET` | `/api/social-analytics/report-types` | Типы отчетов |
| `GET` | `/api/social-analytics/stats/{period}` | Статистика по периодам |
| `GET` | `/api/social-analytics/export/{dataType}` | Экспорт данных |
| `GET` | `/api/social-analytics/top-products/{category}` | Топ продукты |
| `GET` | `/api/social-analytics/seasonality/{category}` | Анализ сезонности |
| `POST` | `/api/social-analytics/compare-periods` | Сравнение периодов |

### Примеры запросов

#### Получить тренды по категориям
```bash
curl "http://localhost:8080/api/social-analytics/trends?period=month&limit=10"
```

#### Получить социальные метрики продукта
```bash
curl "http://localhost:8080/api/social-analytics/social-metrics/product_123?period=week"
```

#### Сгенерировать отчет
```bash
curl -X POST "http://localhost:8080/api/social-analytics/reports" \
  -H "Content-Type: application/json" \
  -d '{
    "reportType": "trends",
    "parameters": {
      "period": "month",
      "limit": 20
    }
  }'
```

#### Сравнить периоды
```bash
curl -X POST "http://localhost:8080/api/social-analytics/compare-periods" \
  -H "Content-Type: application/json" \
  -d '{
    "period1": "month",
    "period2": "week",
    "metrics": ["sales", "views", "rating"]
  }'
```

## 💡 Примеры использования

### 1. Анализ трендов моды
```dart
// Получить тренды для категории "мода" за месяц
final trends = await socialAnalyticsService.getCategoryTrends(
  period: 'month',
  limit: 20,
);

// Анализ топ категорий
for (final category in trends['topCategories']) {
  print('${category['categoryName']}: ${category['trend']}');
}
```

### 2. Анализ аудитории
```dart
// Получить анализ аудитории для категории "электроника"
final audience = await socialAnalyticsService.getAudienceAnalysis(
  category: 'electronics',
  period: 'month',
);

// Демографические данные
final demographics = audience['demographics'];
print('Средний возраст: ${demographics['averageAge']}');
```

### 3. Прогнозы трендов
```dart
// Получить прогноз на 30 дней для категории "спорт"
final predictions = await socialAnalyticsService.getTrendPredictions(
  category: 'sports',
  daysAhead: 30,
);

// Рекомендации
final recommendations = predictions['recommendations']['recommendations'];
for (final rec in recommendations) {
  print('💡 $rec');
}
```

### 4. Генерация отчетов
```dart
// Создать комплексный отчет
final report = await socialAnalyticsService.generateReport(
  reportType: 'comprehensive',
  parameters: {},
);

// Экспорт в CSV
final csvData = await socialAnalyticsService.exportAnalyticsData(
  dataType: 'trends',
  format: 'csv',
  period: 'month',
);
```

## 🧪 Тестирование

### Backend тесты
```bash
# Unit тесты
dart test test/social_analytics_test.dart

# API тесты
dart run test_social_analytics.dart

# Coverage
dart test --coverage=coverage
genhtml coverage/lcov.info -o coverage/html
```

### Frontend тесты
```bash
# Unit тесты
flutter test test/social_analytics_test.dart

# Widget тесты
flutter test test/social_analytics_screen_test.dart

# Integration тесты
flutter test test/integration/social_analytics_integration_test.dart
```

### Тестирование производительности
```bash
# Load testing
ab -n 1000 -c 10 http://localhost:8080/api/social-analytics/trends

# Memory profiling
dart run --observe bin/server.dart
```

## 🚀 Развертывание

### Требования
- **Dart SDK**: 3.0+
- **Flutter**: 3.10+
- **PostgreSQL**: 12+
- **Memory**: 2GB+ RAM
- **Storage**: 10GB+ свободного места

### Backend развертывание
```bash
# 1. Сборка
cd backend
dart pub get
dart compile exe bin/server.dart

# 2. Настройка окружения
cp .env.example .env
# Отредактировать .env файл

# 3. Запуск
./bin/server.exe
```

### Frontend развертывание
```bash
# 1. Android APK
cd frontend
flutter build apk --release

# 2. iOS
flutter build ios --release

# 3. Web
flutter build web --release
```

### Docker развертывание
```dockerfile
# Dockerfile для backend
FROM dart:stable
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/server.dart
EXPOSE 8080
CMD ["./bin/server.exe"]
```

```bash
# Сборка и запуск
docker build -t social-analytics-backend .
docker run -p 8080:8080 social-analytics-backend
```

## 📊 Мониторинг

### Health Checks
```bash
# Проверка состояния API
curl http://localhost:8080/health

# Проверка endpoints
curl http://localhost:8080/api/social-analytics/trends
```

### Метрики
- **Request volume** - количество запросов
- **Response times** - время ответа
- **Error rates** - частота ошибок
- **Cache hit rates** - эффективность кэширования

### Логирование
```dart
// Уровни логирования
_logger.d('Debug information');
_logger.i('Info message');
_logger.w('Warning message');
_logger.e('Error message');
```

## 🔮 Будущие улучшения

### Краткосрочные (1-3 месяца)
- [ ] Интерактивные графики и диаграммы
- [ ] Real-time обновления данных
- [ ] Расширенные фильтры
- [ ] Mobile-first оптимизация

### Среднесрочные (3-6 месяцев)
- [ ] Продвинутые ML алгоритмы
- [ ] Интеграция с внешними API
- [ ] Автоматические отчеты
- [ ] A/B testing платформа

### Долгосрочные (6+ месяцев)
- [ ] AI-powered рекомендации
- [ ] Predictive scoring
- [ ] Advanced segmentation
- [ ] Cross-platform analytics

## 🤝 Руководство по вкладу

### Структура проекта
```
social-analytics/
├── backend/
│   ├── lib/services/social_analytics_service.dart
│   ├── lib/handlers/social_analytics_handler.dart
│   └── test/
├── frontend/
│   ├── lib/services/social_analytics_service.dart
│   ├── lib/providers/social_analytics_provider.dart
│   ├── lib/screens/social_analytics_screen.dart
│   └── test/
└── docs/
    ├── SOCIAL_ANALYTICS_DOCUMENTATION.md
    └── SOCIAL_ANALYTICS_README.md
```

### Процесс разработки
1. **Fork** репозитория
2. **Создать** feature branch
3. **Реализовать** функциональность
4. **Добавить** тесты
5. **Обновить** документацию
6. **Создать** Pull Request

### Стандарты кода
- **Dart**: `dart format` и `dart analyze`
- **Flutter**: `flutter analyze` и `flutter test`
- **Документация**: Markdown с примерами
- **Тесты**: покрытие >80%

## 🆘 Поддержка

### Документация
- **Техническая документация**: `SOCIAL_ANALYTICS_DOCUMENTATION.md`
- **API Reference**: встроенная документация в `/api/docs`
- **Примеры кода**: в этом README

### Сообщество
- **Issues**: GitHub Issues для багов и feature requests
- **Discussions**: GitHub Discussions для вопросов
- **Wiki**: дополнительная документация

### Контакты
- **Email**: support@mymodus.com
- **Telegram**: @MyModusSupport
- **Discord**: MyModus Community

## 📝 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 🙏 Благодарности

- **Flutter Team** - за отличную платформу
- **Dart Team** - за быстрый и безопасный язык
- **PostgreSQL Team** - за надежную базу данных
- **Open Source Community** - за вдохновение и поддержку

---

**Social Analytics** - это результат совместной работы команды MyModus и open source сообщества. Мы приветствуем любой вклад и обратную связь! 🚀
