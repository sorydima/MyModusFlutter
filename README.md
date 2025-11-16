https://api.codemagic.io/apps/6915f86fd5eae7e63717446c/6915f86fd5eae7e63717446b/status_badge.svg

[![Codemagic build status](https://api.codemagic.io/apps/6915f86fd5eae7e63717446c/6915f86fd5eae7e63717446b/status_badge.svg)](https://codemagic.io/app/6915f86fd5eae7e63717446c/6915f86fd5eae7e63717446b/latest_build)

# 🚀 MyModus - Полная платформа моды и стиля

**MyModus** - это инновационная платформа, объединяющая парсинг маркетплейсов, социальную сеть в стиле Instagram, Web3 интеграцию и AI-рекомендации для создания уникального опыта покупок модной одежды.

## ✨ Основные возможности

### 🛍 **Магазин и парсинг**
- **Автоматический парсинг** товаров с Ozon, Wildberries, Lamoda
- **Агрегация цен** и скидок в реальном времени
- **История цен** и уведомления об изменениях
- **AI-рекомендации** на основе предпочтений пользователя

### 📱 **Социальная сеть**
- **Лента постов** в стиле Instagram
- **Сторис** и временный контент
- **Лайки, комментарии, репосты**
- **Внутренний чат** между пользователями
- **Хештеги** и поиск по контенту

### 🌐 **Web3 интеграция**
- **NFT токены** для бейджей и купонов
- **Токены лояльности** на блокчейне
- **IPFS хранилище** для медиафайлов
- **Поддержка Ethereum, Polygon, BSC**
- **Кошельки пользователей**

### 🤖 **AI функциональность**
- **Генерация описаний** товаров
- **Персональные рекомендации**
- **Модерация контента**
- **Анализ настроения**
- **Автогенерация хештегов**

## 🏗 Архитектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter       │    │   Web3          │    │   AI Service    │
│   Frontend      │◄──►│   Integration   │◄──►│   OpenAI        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx         │    │   IPFS Node     │    │   Monitoring    │
│   Reverse Proxy │    │   File Storage  │    │   Stack         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Dart Backend  │    │   PostgreSQL    │    │   Redis Cache   │
│   API Server    │◄──►│   Database      │◄──►│   Session Store │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐
│   Scrapers      │
│   Ozon/WB/Lamoda│
└─────────────────┘
```

## 🚀 Быстрый старт

### Предварительные требования

- **Docker** и **Docker Compose**
- **Node.js** 18+ (для смарт-контрактов)
- **Flutter** 3.0+ (для frontend)
- **Git**

### 1. Клонирование репозитория

```bash
git clone https://github.com/your-username/MyModusFlutter.git
cd MyModusFlutter
```

### 2. Автоматическая настройка

```bash
# Делаем скрипт исполняемым
chmod +x scripts/setup_full.sh

# Запускаем полную настройку
./scripts/setup_full.sh
```

Скрипт автоматически:
- ✅ Проверит зависимости
- ✅ Создаст конфигурационные файлы
- ✅ Настроит смарт-контракты
- ✅ Соберет Flutter frontend
- ✅ Запустит все сервисы
- ✅ Проверит работоспособность

### 3. Ручная настройка (альтернатива)

```bash
# Создание .env файла
cp .env.example .env
# Отредактируйте .env с вашими настройками

# Запуск сервисов
docker-compose -f docker-compose.full.yml up -d

# Проверка статуса
docker-compose -f docker-compose.full.yml ps
```

## 🌐 Доступные сервисы

После запуска будут доступны:

| Сервис | URL | Описание |
|--------|-----|----------|
| **Frontend** | http://localhost:3000 | Flutter web приложение |
| **Backend API** | http://localhost:8080 | Dart API сервер |
| **Prometheus** | http://localhost:9090 | Мониторинг метрик |
| **Grafana** | http://localhost:3001 | Дашборды (admin/admin) |
| **Elasticsearch** | http://localhost:9200 | Поиск и логи |
| **Kibana** | http://localhost:5601 | Анализ логов |

## 📊 API Endpoints

### Аутентификация
```
POST /api/v1/auth/register    - Регистрация
POST /api/v1/auth/login       - Вход
POST /api/v1/auth/refresh     - Обновление токена
GET  /api/v1/auth/profile     - Профиль пользователя
```

### Товары
```
GET  /api/v1/products         - Список товаров
GET  /api/v1/products/{id}    - Детали товара
GET  /api/v1/products/search  - Поиск товаров
GET  /api/v1/products/categories - Категории
```

### Социальная сеть
```
GET  /api/v1/posts            - Лента постов
POST /api/v1/posts            - Создание поста
GET  /api/v1/feed             - Персональная лента
GET  /api/v1/stories          - Сторис
```

### Web3
```
POST /api/v1/web3/connect-wallet - Подключение кошелька
GET  /api/v1/web3/nfts        - NFT пользователя
POST /api/v1/web3/mint-nft    - Создание NFT
GET  /api/v1/web3/loyalty-tokens - Токены лояльности
```

### AI
```
GET  /api/v1/ai/recommendations - AI рекомендации
POST /api/v1/ai/generate-description - Генерация описания
POST /api/v1/ai/moderate-content - Модерация контента
```

## 🔧 Конфигурация

### Переменные окружения (.env)

```bash
# База данных
DATABASE_URL=postgresql://user:pass@localhost:5432/mymodus
POSTGRES_USER=mymodus_user
POSTGRES_PASSWORD=mymodus_password

# Redis
REDIS_URL=redis://:password@localhost:6379
REDIS_PASSWORD=mymodus_redis_password

# JWT
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=7d

# OpenAI
OPENAI_API_KEY=your_openai_api_key

# Web3
ETHEREUM_RPC_URL=http://localhost:8545
IPFS_API_URL=http://localhost:5001
```

### Настройка смарт-контрактов

```bash
cd smart-contracts

# Установка зависимостей
npm install

# Компиляция
npx hardhat compile

# Деплой в локальную сеть
npx hardhat run scripts/deploy.js --network localhost
```

## 📁 Структура проекта

```
MyModusFlutter/
├── backend/                 # Dart backend
│   ├── lib/
│   │   ├── scrapers/       # Парсеры маркетплейсов
│   │   ├── services/       # Бизнес-логика
│   │   ├── handlers/       # API обработчики
│   │   └── models/         # Модели данных
│   ├── migrations/         # SQL миграции
│   └── pubspec.yaml        # Dart зависимости
├── frontend/               # Flutter приложение
│   ├── lib/
│   │   ├── screens/        # Экраны приложения
│   │   ├── widgets/        # Переиспользуемые виджеты
│   │   ├── services/       # API клиент
│   │   └── models/         # Модели данных
│   └── pubspec.yaml        # Flutter зависимости
├── smart-contracts/        # Solidity смарт-контракты
│   ├── contracts/          # Контракты
│   ├── scripts/            # Скрипты деплоя
│   └── hardhat.config.js   # Hardhat конфигурация
├── docker-compose.full.yml # Docker Compose
├── scripts/                # Скрипты настройки
└── monitoring/             # Конфигурации мониторинга
```

## 🧪 Тестирование

### Backend тесты

```bash
cd backend
dart test
```

### Frontend тесты

```bash
cd frontend
flutter test
```

### Интеграционные тесты

```bash
# Запуск тестов с Docker
docker-compose -f docker-compose.full.yml exec backend dart test
```

## 📈 Мониторинг и логи

### Prometheus метрики

- **Backend метрики**: http://localhost:8080/metrics
- **База данных**: PostgreSQL exporter
- **Redis**: Redis exporter
- **Системные**: Node exporter

### Логи

```bash
# Просмотр логов всех сервисов
docker-compose -f docker-compose.full.yml logs -f

# Логи конкретного сервиса
docker-compose -f docker-compose.full.yml logs -f backend

# Kibana для анализа логов
# http://localhost:5601
```

## 🔒 Безопасность

- **JWT токены** для аутентификации
- **Rate limiting** на API endpoints
- **CORS** настройки
- **SQL injection** защита
- **XSS** защита
- **HTTPS** в продакшене

## 🚀 Развертывание в продакшене

### 1. Подготовка сервера

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Настройка SSL

```bash
# Получение Let's Encrypt сертификата
sudo apt install certbot
sudo certbot certonly --standalone -d yourdomain.com

# Копирование сертификатов
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
```

### 3. Запуск в продакшене

```bash
# Создание .env.prod
cp .env .env.prod
# Отредактируйте .env.prod

# Запуск продакшен версии
docker-compose -f docker-compose.full.yml --env-file .env.prod up -d
```

## 📊 Project Progress

### ✅ Completed Features
- **Backend**: 100% ✅ - Full Dart backend with API, scrapers, and services
- **Frontend Core**: 100% ✅ - Complete Flutter UI with navigation and state management
- **Web3 Integration**: 100% ✅ - Full Web3 functionality with wallet connection
- **Smart Contracts**: 100% ✅ - NFT and loyalty token contracts deployed
- **Smart Contracts Integration**: 100% ✅ - Frontend integration with test mode
- **MetaMask & IPFS Integration**: 100% ✅ - Real wallet and decentralized storage

### 🚧 In Progress
- **Testing**: 50% 🚧 - Unit tests for providers, widget tests for UI
- **AI Services**: 0% 📋 - Recommendations, content generation, moderation

### 📋 Planned
- **Production Features**: CI/CD, monitoring, security, HTTPS
- **Documentation**: API docs, user guides, deployment guides

**Overall Progress**: ~85% of planned functionality

## 🤝 Разработка

### Добавление нового парсера

1. Создайте класс в `backend/lib/scrapers/`
2. Наследуйтесь от `BaseScraper`
3. Реализуйте методы парсинга
4. Добавьте в `ScrapingService`

### Добавление нового API endpoint

1. Создайте handler в `backend/lib/handlers/`
2. Добавьте роут в `backend/lib/server.dart`
3. Обновите документацию API

### Добавление нового экрана

1. Создайте screen в `frontend/lib/screens/`
2. Добавьте роут в `frontend/lib/router.dart`
3. Обновите навигацию

## 📚 Документация

- [API Reference](docs/API.md)
- [Database Schema](docs/DATABASE.md)
- [Web3 Integration](docs/WEB3.md)
- [AI Features](docs/AI.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

## 🐛 Устранение неполадок

### Проблемы с парсингом

```bash
# Проверка логов парсера
docker-compose -f docker-compose.full.yml logs -f backend | grep scraper

# Перезапуск парсинга
curl -X POST http://localhost:8080/api/v1/scraping/start
```

### Проблемы с базой данных

```bash
# Проверка подключения
docker-compose -f docker-compose.full.yml exec postgres psql -U mymodus_user -d mymodus -c "SELECT 1"

# Сброс базы данных
docker-compose -f docker-compose.full.yml down -v
docker-compose -f docker-compose.full.yml up -d
```

### Проблемы с Web3

```bash
# Проверка Ethereum узла
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8545

# Проверка IPFS
curl http://localhost:5001/api/v0/version
```

## 📞 Поддержка

- **Issues**: [GitHub Issues](https://github.com/your-username/MyModusFlutter/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/MyModusFlutter/discussions)
- **Wiki**: [GitHub Wiki](https://github.com/your-username/MyModusFlutter/wiki)

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 🙏 Благодарности

- **Flutter** команде за отличный фреймворк
- **Dart** команде за язык программирования
- **Ethereum** сообществу за Web3 технологии
- **OpenAI** за AI API

---

**MyModus** - будущее модной индустрии уже здесь! 🎉
