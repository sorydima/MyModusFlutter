# MyModus Smart Contracts

Смарт-контракты для платформы MyModus - социальной коммерции в сфере моды с Web3 функциональностью.

## 📋 Описание

Этот репозиторий содержит смарт-контракты для:
- **Escrow** - безопасные покупки с эскроу
- **LoyaltyToken** - токены лояльности ERC20
- **MyModusNFT** - NFT коллекция для достижений и коллекционных предметов

## 🚀 Быстрый старт

### Предварительные требования

- Node.js 18+
- npm или yarn
- Hardhat

### Установка

```bash
# Клонирование репозитория
git clone <repository-url>
cd smart-contracts

# Установка зависимостей
npm install

# Компиляция контрактов
npm run compile
```

### Локальное развертывание

```bash
# Запуск локального узла Hardhat
npm run node

# В новом терминале - развертывание контрактов
npm run deploy:local
```

### Развертывание в тестнете

```bash
# Настройка переменных окружения
cp .env.example .env
# Отредактируйте .env файл с вашими ключами

# Развертывание в тестнете (например, Sepolia)
npm run deploy:testnet
```

## 📜 Контракты

### 1. Escrow Contract

**Адрес**: `0x...` (после развертывания)

**Функции**:
- `createEscrow()` - создание эскроу для покупки
- `releaseEscrow()` - освобождение средств продавцу
- `refundEscrow()` - возврат средств покупателю

**Особенности**:
- Комиссия 0.25% от суммы сделки
- Защита от повторного входа
- События для отслеживания транзакций

### 2. LoyaltyToken Contract

**Адрес**: `0x...` (после развертывания)

**Функции**:
- `mint()` - минтинг токенов (только для минтеров)
- `mintLoyaltyReward()` - минтинг наград лояльности
- `claimDailyReward()` - получение ежедневной награды

**Особенности**:
- Максимальное предложение: 10,000,000 токенов
- Ежедневные награды: 100 токенов
- Пауза/возобновление контракта

### 3. MyModusNFT Contract

**Адрес**: `0x...` (после развертывания)

**Функции**:
- `mint()` - минтинг NFT (платно)
- `mintAchievement()` - минтинг достижений (бесплатно)
- `updateNFTMetadata()` - обновление метаданных

**Особенности**:
- Максимальное предложение: 10,000 NFT
- Редкость от 1 до 5
- Уровни достижений
- Торгуемые и неторгуемые NFT

## 🔧 Конфигурация

### Переменные окружения

Создайте `.env` файл на основе `.env.example`:

```env
# Ethereum Configuration
PRIVATE_KEY=your_private_key_here
INFURA_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
ETHERSCAN_API_KEY=your_etherscan_api_key

# Contract Configuration
ESCROW_CONTRACT_ADDRESS=0x...
LOYALTY_TOKEN_ADDRESS=0x...
NFT_CONTRACT_ADDRESS=0x...
```

### Hardhat Configuration

Файл `hardhat.config.js` настроен для:
- Локальной сети (localhost)
- Тестнета Sepolia
- Основной сети Ethereum

## 📊 Тестирование

```bash
# Запуск тестов
npm test

# Запуск тестов с покрытием
npx hardhat coverage
```

## 🚀 Развертывание

### 1. Локальная сеть

```bash
npm run deploy:local
```

### 2. Тестнет (Sepolia)

```bash
npm run deploy:testnet
```

### 3. Основная сеть

```bash
npm run deploy:mainnet
```

## 🔍 Верификация

После развертывания верифицируйте контракты на Etherscan:

```bash
# Верификация в тестнете
npm run verify:testnet

# Верификация в основной сети
npm run verify:mainnet
```

## 📱 Интеграция с Frontend

После развертывания обновите конфигурацию frontend:

```dart
// backend/.env
ESCROW_CONTRACT_ADDRESS=0x...
LOYALTY_TOKEN_ADDRESS=0x...
NFT_CONTRACT_ADDRESS=0x...
```

## 🛡️ Безопасность

### Аудит

- Контракты используют OpenZeppelin библиотеки
- Включена защита от повторного входа
- Проверки доступа для критических функций
- Возможность паузы контрактов

### Рекомендации

- Всегда тестируйте в тестнете перед основным развертыванием
- Используйте мультисиг кошельки для владения контрактами
- Регулярно обновляйте зависимости
- Мониторьте события контрактов

## 📈 Мониторинг

### События для отслеживания

- `EscrowCreated` - создание эскроу
- `EscrowReleased` - освобождение эскроу
- `EscrowRefunded` - возврат эскроу
- `LoyaltyReward` - награды лояльности
- `NFTMinted` - минтинг NFT

### Инструменты

- Etherscan для просмотра транзакций
- Hardhat для локального тестирования
- OpenZeppelin Defender для мониторинга

## 🤝 Вклад в проект

1. Форкните репозиторий
2. Создайте ветку для новой функции
3. Внесите изменения
4. Добавьте тесты
5. Создайте Pull Request

## 📄 Лицензия

MIT License - см. файл [LICENSE](LICENSE)

## 🆘 Поддержка

- Создайте Issue в GitHub
- Обратитесь к команде разработки
- Проверьте документацию

## 🔗 Полезные ссылки

- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Hardhat Documentation](https://hardhat.org/docs/)
- [Ethereum Development](https://ethereum.org/developers/)
- [IPFS Documentation](https://docs.ipfs.io/)
