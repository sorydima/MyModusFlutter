# MyModus - Fashion Social Commerce Platform

MyModus - это инновационная платформа, объединяющая социальную сеть в стиле Instagram с e-commerce функциональностью, интегрированной с Web3 технологиями.

## 🚀 Возможности

### 📱 Основной функционал
- **Социальная сеть**: Лента постов, сторис, лайки, комментарии
- **Магазин**: Каталог товаров с парсингом Ozon, Wildberries, Lamoda
- **Web3 интеграция**: Ethereum кошельки, NFT бейджи, токены лояльности
- **AI рекомендации**: Персонализированные предложения на основе предпочтений
- **Web4 хранилище**: IPFS для децентрализованного хранения медиа

### 🔧 Технические особенности
- **Frontend**: Flutter (мобильные + веб)
- **Backend**: Dart + Shelf framework
- **База данных**: PostgreSQL + Redis кэширование
- **Блокчейн**: Ethereum + Hardhat + смарт-контракты
- **CI/CD**: GitHub Actions + Docker

## 📋 Требования

- **Flutter**: 3.19.0+
- **Dart**: 3.2.0+
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **PostgreSQL**: 15+
- **Redis**: 7+
- **Node.js**: 18+ (для Hardhat)

## 🛠 Установка и запуск

### 1. Клонирование репозитория

```bash
git clone https://github.com/yourusername/MyModusFlutter.git
cd MyModusFlutter
```

### 2. Настройка окружения

Создайте файл `.env` в корне проекта:

```bash
# Backend
PORT=8080
DATABASE_URL=postgres://mymodus:mymodus123@localhost:5432/mymodus
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_super_secret_jwt_key_here

# OpenAI API
OPENAI_API_KEY=your_openai_api_key_here

# Ethereum
ETHEREUM_RPC_URL=http://localhost:8545
ESCROW_CONTRACT_ADDRESS=0x...
LOYALTY_TOKEN_ADDRESS=0x...
NFT_CONTRACT_ADDRESS=0x...

# Docker Hub (для CI/CD)
DOCKER_USERNAME=your_dockerhub_username
DOCKER_PASSWORD=your_dockerhub_password
```

### 3. Запуск с Docker Compose

```bash
# Запуск всех сервисов
docker-compose up -d

# Просмотр логов
docker-compose logs -f

# Остановка
docker-compose down
```

### 4. Локальная разработка

#### Backend
```bash
cd backend
dart pub get
dart run bin/server.dart
```

#### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## 🏗 Архитектура проекта

```
MyModusFlutter/
├── frontend/                 # Flutter приложение
│   ├── lib/
│   │   ├── screens/         # Экраны приложения
│   │   ├── components/      # Переиспользуемые компоненты
│   │   ├── services/        # API сервисы
│   │   ├── models/          # Модели данных
│   │   └── providers/       # State management
│   └── assets/              # Изображения, шрифты, анимации
├── backend/                  # Dart backend
│   ├── lib/
│   │   ├── services/        # Бизнес-логика
│   │   ├── handlers/        # HTTP обработчики
│   │   ├── scrapers/        # Парсеры маркетплейсов
│   │   └── models/          # Модели данных
│   └── bin/                 # Точки входа
├── smart-contracts/          # Ethereum смарт-контракты
├── bot_service/              # Python сервис для парсинга
└── docker-compose.yml        # Docker окружение
```

## 🔍 API Endpoints

### Аутентификация
- `POST /api/auth/register` - Регистрация пользователя
- `POST /api/auth/login` - Вход в систему
- `POST /api/auth/refresh` - Обновление токена

### Товары
- `GET /api/products` - Список товаров
- `GET /api/products/{id}` - Детали товара
- `GET /api/products/recommendations` - AI рекомендации

### Скрапинг
- `GET /api/scraping/stats` - Статистика скрапинга
- `POST /api/scraping/trigger` - Запуск скрапинга

### Web3
- `POST /api/web3/wallet/create` - Создание кошелька
- `POST /api/web3/escrow/create` - Создание escrow
- `GET /api/web3/balance/{address}` - Баланс кошелька

## 🤖 AI Интеграция

### OpenAI API
- Генерация описаний товаров
- AI модерация контента
- Персонализированные рекомендации

### Рекомендательная система
- Анализ предпочтений пользователя
- Машинное обучение на основе истории покупок
- Семантический анализ товаров

## ⛓ Web3 Функции

### Смарт-контракты
- **Escrow**: Безопасные покупки
- **LoyaltyToken**: Токены лояльности
- **MyModusNFT**: NFT бейджи и купоны

### Кошельки
- Поддержка MetaMask
- WalletConnect интеграция
- Создание HD кошельков

## 📊 Мониторинг и аналитика

### Метрики
- Статистика скрапинга по платформам
- Количество пользователей и товаров
- Web3 транзакции и NFT

### Логирование
- Структурированные логи с уровнем детализации
- Мониторинг производительности API
- Трассировка ошибок

## 🚀 CI/CD Pipeline

### GitHub Actions
1. **Flutter Tests**: Анализ кода, тесты, сборка
2. **Backend Tests**: Dart тесты и сборка
3. **Docker Build**: Сборка и публикация образов
4. **Security Scan**: Сканирование уязвимостей
5. **Deploy**: Автоматический деплой в production

### Docker
- Многоэтапная сборка для оптимизации размера
- Health checks для всех сервисов
- Автоматическое масштабирование

## 🔒 Безопасность

- JWT аутентификация
- CORS настройки
- Валидация входных данных
- Rate limiting
- Безопасное хранение приватных ключей

## 📱 Мобильная разработка

### Flutter
- Кроссплатформенная разработка
- Material Design 3
- Адаптивный UI
- PWA поддержка для веб

### Платформы
- Android (APK)
- iOS (IPA)
- Web (PWA)
- Desktop (Windows, macOS, Linux)

## 🌐 Развертывание

### Production
```bash
# Сборка production образов
docker-compose -f docker-compose.prod.yml build

# Запуск
docker-compose -f docker-compose.prod.yml up -d

# Мониторинг
docker-compose -f docker-compose.prod.yml logs -f
```

### Kubernetes
```bash
# Применение манифестов
kubectl apply -f k8s/

# Проверка статуса
kubectl get pods -n mymodus
```

## 🧪 Тестирование

### Unit Tests
```bash
# Backend
cd backend && dart test

# Frontend
cd frontend && flutter test
```

### Integration Tests
```bash
# API тесты
cd backend && dart test test/integration/

# Widget тесты
cd frontend && flutter test test/widget_test.dart
```

## 📈 Производительность

### Оптимизации
- Redis кэширование
- Lazy loading изображений
- Сжатие API ответов
- CDN для статических файлов

### Мониторинг
- Response time метрики
- Memory usage
- Database query performance
- Web3 transaction latency

## 🤝 Вклад в проект

1. Fork репозитория
2. Создайте feature branch (`git checkout -b feature/amazing-feature`)
3. Commit изменения (`git commit -m 'Add amazing feature'`)
4. Push в branch (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 📞 Поддержка

- **Issues**: [GitHub Issues](https://github.com/yourusername/MyModusFlutter/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/MyModusFlutter/discussions)
- **Telegram**: [@MyModusSupport](https://t.me/MyModusSupport)

## 🎯 Roadmap

### Этап 1: MVP (Q1 2024)
- ✅ Базовая архитектура
- ✅ Парсинг маркетплейсов
- ✅ API endpoints
- 🔄 UI/UX дизайн

### Этап 2: Соцсеть (Q2 2024)
- 🔄 Профили пользователей
- 🔄 Лента постов
- 🔄 Лайки и комментарии

### Этап 3: Web3 (Q3 2024)
- 🔄 Смарт-контракты
- 🔄 NFT функционал
- 🔄 Кошельки

### Этап 4: AI (Q4 2024)
- 🔄 Рекомендации
- 🔄 Модерация контента
- 🔄 Аналитика

---

**MyModus** - будущее fashion e-commerce уже здесь! 🚀✨
