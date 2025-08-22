# 🎨 AI Color Matcher

**AI Color Matcher** - это умная система подбора цветов для создания стильных модных образов! Используйте искусственный интеллект для анализа фотографий, создания персональных палитр и получения профессиональных рекомендаций по цветовым сочетаниям.

## ✨ Что это такое?

AI Color Matcher помогает пользователям:
- 🎯 **Анализировать цвета** на фотографиях и определять доминирующие оттенки
- 🎨 **Создавать персональные палитры** на основе индивидуальных предпочтений
- 🔗 **Подбирать гармоничные цвета** по принципам теории цвета
- 💡 **Получать рекомендации** по созданию стильных образов
- 📊 **Отслеживать тренды** в мире моды и цветов
- 📚 **Сохранять историю** анализов и любимых палитр

## 🚀 Быстрый старт

### Требования

- **Backend**: Dart 3.0+, PostgreSQL 12+
- **Frontend**: Flutter 3.0+
- **AI Services**: TensorFlow/PyTorch (опционально)

### Установка

1. **Клонируйте репозиторий**
```bash
git clone https://github.com/your-username/MyModusFlutter.git
cd MyModusFlutter
```

2. **Настройте backend**
```bash
cd backend
dart pub get
# Настройте переменные окружения
cp .env.example .env
# Запустите сервер
dart run bin/server.dart
```

3. **Настройте frontend**
```bash
cd frontend
flutter pub get
# Запустите приложение
flutter run
```

4. **Протестируйте API**
```bash
# Запустите тесты
dart run test_ai_color_matcher.dart
```

## 🎯 Ключевые возможности

### 📸 Анализ цветов на фото
- Загрузка изображений из галереи или камеры
- AI-анализ для определения доминирующих цветов
- Генерация гармоничных цветовых палитр
- Персональные рекомендации по использованию

### 🎨 Персональные палитры
- Создание уникальных цветовых схем
- Учет физических характеристик (тон кожи, цвет волос, глаз)
- Адаптация под сезон и случай
- Сохранение и управление палитрами

### 🔗 Теория цвета
- **Дополнительные цвета** - яркие контрасты
- **Аналогичные цвета** - гармоничные сочетания
- **Триадная схема** - сбалансированные комбинации
- **Монохромные** - элегантные оттенки

### 💡 Умные рекомендации
- Советы по созданию образов
- Учет текущих трендов
- Персонализация под стиль пользователя
- Рекомендации по аксессуарам

### 📊 Цветовые тренды
- Анализ популярности цветов
- Сезонные тренды
- Категорийная аналитика
- Прогнозирование трендов

## 🏗️ Архитектура

### Backend (Dart + Shelf)
```
backend/
├── services/ai_color_matcher_service.dart    # Бизнес-логика
├── handlers/ai_color_matcher_handler.dart    # API endpoints
└── models.dart                               # Модели данных
```

### Frontend (Flutter)
```
frontend/
├── services/ai_color_matcher_service.dart    # API клиент
├── providers/ai_color_matcher_provider.dart  # State management
└── screens/ai_color_matcher_screen.dart      # UI экран
```

### Принципы архитектуры
- **Service-Handler Pattern** - разделение логики и API
- **Provider Pattern** - управление состоянием
- **RESTful API** - стандартные HTTP методы
- **Модульная структура** - легко расширяемые компоненты

## 🎨 UI/UX особенности

### Вкладки интерфейса

1. **📸 Фото** - анализ изображений
2. **🎨 Палитра** - персональные и сезонные схемы
3. **🔗 Гармония** - подбор гармоничных цветов
4. **💡 Рекомендации** - советы по образам
5. **📊 Тренды** - анализ популярности
6. **📚 История** - статистика и палитры

### Ключевые компоненты
- **Color Swatches** - интерактивные цветовые образцы
- **Harmony Selector** - выбор типа гармонии
- **Seasonal Filters** - фильтрация по сезонам
- **Progress Indicators** - индикаторы загрузки
- **Error Handling** - понятные сообщения об ошибках

## 🔌 API Endpoints

### Основные операции
```http
POST /api/color-matcher/analyze-photo          # Анализ фото
POST /api/color-matcher/generate-palette      # Генерация палитры
GET  /api/color-matcher/personal-palette/{id} # Получение палитры
GET  /api/color-matcher/harmonious-colors     # Гармоничные цвета
```

### Рекомендации и тренды
```http
GET /api/color-matcher/recommendations/{id}   # Рекомендации
GET /api/color-matcher/color-trends          # Цветовые тренды
GET /api/color-matcher/seasonal-palettes     # Сезонные палитры
```

### Управление палитрами
```http
POST /api/color-matcher/save-palette         # Сохранение палитры
GET  /api/color-matcher/user-palettes/{id}   # Палитры пользователя
DELETE /api/color-matcher/palette/{id}       # Удаление палитры
```

## 💡 Примеры использования

### Анализ фото
```dart
final result = await colorMatcherService.analyzePhotoColors(
  imageUrl: 'https://example.com/photo.jpg',
  userId: 'user123',
);

if (result['success']) {
  final dominantColors = result['dominantColors'];
  final recommendations = result['recommendations'];
  // Обработка результатов
}
```

### Генерация палитры
```dart
final palette = await colorMatcherService.generatePersonalPalette(
  userId: 'user123',
  preferredColors: ['#FF6B6B', '#4ECDC4'],
  skinTone: 'warm',
  hairColor: 'brown',
  eyeColor: 'brown',
);
```

### Поиск гармоничных цветов
```dart
final colors = await colorMatcherService.findHarmoniousColors(
  baseColor: '#FF6B6B',
  harmonyType: 'complementary',
  count: 5,
);
```

## 🧪 Тестирование

### Backend тесты
```bash
cd backend
dart test test/ai_color_matcher_test.dart
dart run test_ai_color_matcher.dart
```

### Frontend тесты
```bash
cd frontend
flutter test test/ai_color_matcher_test.dart
```

### Тестовые сценарии
1. **Анализ фото** - загрузка и проверка результатов
2. **Генерация палитры** - создание персональной схемы
3. **Поиск гармонии** - подбор гармоничных цветов
4. **Рекомендации** - получение советов по образам
5. **Тренды** - анализ популярности цветов

## 🚀 Развертывание

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
```

### Алерты
- **High Error Rate** - >5% ошибок в течение 5 минут
- **Slow Response** - >2 секунд для 95% запросов
- **Service Down** - недоступность API более 1 минуты

## 🔮 Будущие улучшения

### Краткосрочные (1-3 месяца)
- ✅ Интеграция с реальными AI сервисами
- ✅ Улучшение UI/UX с анимациями
- ✅ Кэширование для оптимизации
- ✅ Офлайн режим работы

### Среднесрочные (3-6 месяцев)
- 🔄 Машинное обучение для персонализации
- 🔄 Социальные функции и обмен палитрами
- 🔄 Интеграция с камерой в реальном времени
- 🔄 AR примерка цветов

### Долгосрочные (6+ месяцев)
- 🚀 AI стилист для полного анализа образов
- 🚀 Интеграция с e-commerce платформами
- 🚀 Международная локализация
- 🚀 Enterprise версия для профессионалов

## 🤝 Вклад в проект

### Как помочь
1. **Fork** репозиторий
2. **Создайте** feature branch (`git checkout -b feature/amazing-feature`)
3. **Сделайте** commit изменений (`git commit -m 'Add amazing feature'`)
4. **Push** в branch (`git push origin feature/amazing-feature`)
5. **Откройте** Pull Request

### Требования к коду
- Следуйте существующему стилю кода
- Добавляйте комментарии для сложной логики
- Пишите тесты для новых функций
- Обновляйте документацию при необходимости

### Структура коммитов
```
feat: add new color harmony type
fix: resolve photo analysis error
docs: update API documentation
test: add unit tests for color service
style: format code according to guidelines
```

## 📚 Документация

### Техническая документация
- [AI Color Matcher - Technical Documentation](AI_COLOR_MATCHER_DOCUMENTATION.md)
- [API Reference](API_REFERENCE.md)
- [Database Schema](DATABASE_SCHEMA.md)

### Полезные ссылки
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Shelf Package](https://pub.dev/packages/shelf)
- [Color Theory Basics](https://en.wikipedia.org/wiki/Color_theory)

## 🆘 Поддержка

### Получение помощи
- 📧 **Email**: support@mymodus.com
- 💬 **Discord**: [MyModus Community](https://discord.gg/mymodus)
- 📱 **Telegram**: [@MyModusSupport](https://t.me/MyModusSupport)
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-username/MyModusFlutter/issues)

### Часто задаваемые вопросы

**Q: Как работает анализ цветов на фото?**
A: Система использует AI для анализа пикселей изображения, определения доминирующих цветов и их процентного соотношения.

**Q: Можно ли создать персональную палитру без фото?**
A: Да! Вы можете указать предпочтения, физические характеристики и получить персональную палитру.

**Q: Как часто обновляются цветовые тренды?**
A: Тренды обновляются еженедельно на основе анализа модных показов и социальных сетей.

**Q: Можно ли экспортировать палитры?**
A: Да! Поддерживается экспорт в JSON, PNG и другие популярные форматы.

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 🙏 Благодарности

- **Flutter Team** - за потрясающий фреймворк
- **Dart Team** - за современный язык программирования
- **Open Source Community** - за вдохновение и поддержку
- **Fashion Industry** - за понимание важности цвета в моде

---

**AI Color Matcher** - создавайте стильные образы с помощью искусственного интеллекта! 🎨✨

*Сделано с ❤️ командой MyModus*
