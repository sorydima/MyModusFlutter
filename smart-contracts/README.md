# MyModus Smart Contracts

Смарт-контракты для платформы MyModus, включающие NFT коллекции и токены лояльности.

## 📋 Содержание

- [Обзор](#обзор)
- [Архитектура](#архитектура)
- [Контракты](#контракты)
- [Установка](#установка)
- [Деплой](#деплой)
- [Тестирование](#тестирование)
- [Безопасность](#безопасность)
- [API](#api)
- [Примеры использования](#примеры-использования)

## 🎯 Обзор

MyModus Smart Contracts предоставляет полную инфраструктуру для:

- **NFT коллекций** - создание, минтинг, торговля цифровыми активами
- **Токенов лояльности** - система вознаграждений и геймификации
- **Управления правами** - ролевая система для минтеров и бёрнеров
- **Безопасности** - защита от атак и пауза контрактов

## 🏗️ Архитектура

```
MyModus Smart Contracts
├── MyModusNFT.sol          # NFT контракт (ERC-721)
├── MyModusLoyalty.sol      # Токен лояльности (ERC-20)
├── scripts/                 # Скрипты деплоя
├── test/                    # Тесты
└── hardhat.config.js        # Конфигурация Hardhat
```

### Технологический стек

- **Solidity** 0.8.20
- **Hardhat** - фреймворк разработки
- **OpenZeppelin** - библиотека безопасных контрактов
- **Chai** + **Mocha** - тестирование
- **Ethers.js** - взаимодействие с блокчейном

## 📜 Контракты

### 1. MyModusNFT.sol

**Описание**: ERC-721 контракт для NFT коллекций с расширенной функциональностью.

**Основные возможности**:
- Минтинг NFT с метаданными
- Управление продажами
- Система категорий
- Торговля между пользователями
- Статистика и аналитика

**Структура метаданных**:
```solidity
struct NFTMetadata {
    string name;           // Название NFT
    string description;    // Описание
    string imageURI;       // URI изображения
    string category;       // Категория
    uint256 price;         // Цена продажи
    bool isForSale;        // Статус продажи
    address creator;       // Создатель
    uint256 createdAt;     // Время создания
}
```

**События**:
- `NFTMinted` - NFT отминчен
- `NFTMetadataUpdated` - Метаданные обновлены
- `NFTPutForSale` - NFT выставлен на продажу
- `NFTRemovedFromSale` - NFT убран с продажи
- `NFTPriceUpdated` - Цена обновлена

### 2. MyModusLoyalty.sol

**Описание**: ERC-20 контракт для токенов лояльности с гибкой системой управления.

**Основные возможности**:
- Минтинг токенов (авторизованными пользователями)
- Минтинг за ETH
- Сжигание токенов
- Управление пользователями
- Ролевая система (минтеры, бёрнеры)
- Пауза контракта

**Структура пользователя**:
```solidity
struct UserInfo {
    uint256 balance;       // Текущий баланс
    uint256 totalEarned;   // Всего заработано
    uint256 totalSpent;    // Всего потрачено
    uint256 lastActivity;  // Последняя активность
    bool isActive;         // Статус активности
}
```

**События**:
- `TokensMinted` - Токены отминчены
- `TokensBurned` - Токены сожжены
- `UserRegistered` - Пользователь зарегистрирован
- `UserDeactivated` - Пользователь деактивирован
- `MinterAdded/Removed` - Минтер добавлен/удален
- `BurnerAdded/Removed` - Бёрнер добавлен/удален

## 🚀 Установка

### Требования

- Node.js 18+
- npm или yarn
- Git

### Шаги установки

1. **Клонирование репозитория**
```bash
git clone <repository-url>
cd smart-contracts
```

2. **Установка зависимостей**
```bash
npm install
```

3. **Настройка окружения**
```bash
cp env.example .env
# Отредактируйте .env файл с вашими значениями
```

4. **Компиляция контрактов**
```bash
npx hardhat compile
```

## 🚀 Деплой

### Подготовка

1. **Настройка сети**
   - Убедитесь, что у вас есть ETH в выбранной сети
   - Проверьте настройки в `hardhat.config.js`

2. **Настройка переменных окружения**
```bash
# В .env файле
PRIVATE_KEY=your_private_key_here
INFURA_PROJECT_ID=your_infura_project_id
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### Деплой в локальную сеть

```bash
# Запуск локальной сети
npx hardhat node

# В новом терминале - деплой
npx hardhat run scripts/deploy.js --network localhost
```

### Деплой в тестнет

```bash
# Sepolia
npx hardhat run scripts/deploy.js --network sepolia

# Mumbai (Polygon)
npx hardhat run scripts/deploy.js --network mumbai
```

### Деплой в mainnet

```bash
# Ethereum Mainnet
npx hardhat run scripts/deploy.js --network mainnet

# Polygon Mainnet
npx hardhat run scripts/deploy.js --network polygon
```

### Верификация контрактов

```bash
# Верификация NFT контракта
npx hardhat verify --network sepolia <NFT_CONTRACT_ADDRESS>

# Верификация токена лояльности
npx hardhat verify --network sepolia <LOYALTY_CONTRACT_ADDRESS> \
  "MyModus Loyalty Token" \
  "MMLT" \
  18 \
  "1000000000000000000000000" \
  "1000000000000000"
```

## 🧪 Тестирование

### Запуск всех тестов

```bash
npx hardhat test
```

### Запуск конкретного теста

```bash
# Тесты NFT
npx hardhat test test/MyModusNFT.test.js

# Тесты токена лояльности
npx hardhat test test/MyModusLoyalty.test.js
```

### Тестирование с покрытием

```bash
npx hardhat coverage
```

### Тестирование газа

```bash
REPORT_GAS=true npx hardhat test
```

### Тестирование в конкретной сети

```bash
npx hardhat test --network sepolia
```

## 🔒 Безопасность

### Встроенные меры защиты

- **Ownable** - контроль доступа к административным функциям
- **Pausable** - возможность приостановки контракта
- **ReentrancyGuard** - защита от reentrancy атак
- **Валидация входных данных** - проверка параметров
- **Ограничения** - максимальное предложение, цены

### Аудит безопасности

- [ ] Внешний аудит
- [ ] Тестирование на уязвимости
- [ ] Формальная верификация
- [ ] Пентестинг

### Рекомендации по безопасности

1. **Приватные ключи**
   - Никогда не коммитьте приватные ключи в git
   - Используйте переменные окружения
   - Регулярно ротируйте ключи

2. **Доступ**
   - Ограничьте количество минтеров
   - Мониторьте активность контрактов
   - Используйте мультисиг кошельки

3. **Обновления**
   - Тестируйте в тестнетах
   - Используйте upgradeable контракты
   - Планируйте миграции

## 📚 API

### MyModusNFT

#### Основные функции

```solidity
// Минтинг NFT
function mintNFT(
    address to,
    string memory tokenURI,
    string memory name,
    string memory description,
    string memory imageURI,
    string memory category
) public returns (uint256)

// Обновление метаданных
function updateMetadata(
    uint256 tokenId,
    string memory name,
    string memory description
) public

// Выставление на продажу
function putForSale(uint256 tokenId, uint256 price) public

// Покупка NFT
function buyNFT(uint256 tokenId) public payable

// Получение метаданных
function getNFTMetadata(uint256 tokenId) public view returns (NFTMetadata memory)

// Получение NFT пользователя
function getUserNFTs(address user) public view returns (uint256[] memory)

// Получение статистики
function getStats() public view returns (uint256, uint256, uint256)
```

#### События

```solidity
event NFTMinted(uint256 indexed tokenId, address indexed creator, string tokenURI);
event NFTMetadataUpdated(uint256 indexed tokenId, string name, string description);
event NFTPutForSale(uint256 indexed tokenId, uint256 price);
event NFTRemovedFromSale(uint256 indexed tokenId);
event NFTPriceUpdated(uint256 indexed tokenId, uint256 newPrice);
```

### MyModusLoyalty

#### Основные функции

```solidity
// Минтинг токенов
function mint(address to, uint256 amount) public

// Минтинг за ETH
function mintWithETH(uint256 amount) public payable

// Сжигание токенов
function burn(uint256 amount) public override

// Принудительное сжигание
function burnFrom(address from, uint256 amount) public override

// Регистрация пользователя
function registerUser(address user) public

// Добавление минтера
function addMinter(address minter) public

// Получение информации о токене
function getTokenInfo() public view returns (TokenInfo memory)

// Получение информации о пользователе
function getUserInfo(address user) public view returns (UserInfo memory)

// Получение статистики
function getStats() public view returns (uint256, uint256, uint256, uint256)
```

#### События

```solidity
event TokensMinted(address indexed to, uint256 amount, uint256 cost);
event TokensBurned(address indexed from, uint256 amount);
event UserRegistered(address indexed user);
event UserDeactivated(address indexed user);
event MinterAdded(address indexed minter);
event MinterRemoved(address indexed minter);
event BurnerAdded(address indexed burner);
event BurnerRemoved(address indexed burner);
```

## 💡 Примеры использования

### Минтинг NFT

```javascript
const { ethers } = require("hardhat");

async function mintNFT() {
  const MyModusNFT = await ethers.getContractFactory("MyModusNFT");
  const nftContract = await MyModusNFT.attach("NFT_CONTRACT_ADDRESS");
  
  const tokenURI = "ipfs://QmYourMetadata";
  const name = "My First NFT";
  const description = "This is my first NFT on MyModus";
  const imageURI = "ipfs://QmYourImage";
  const category = "Art";
  
  const tx = await nftContract.mintNFT(
    "USER_ADDRESS",
    tokenURI,
    name,
    description,
    imageURI,
    category
  );
  
  await tx.wait();
  console.log("NFT minted successfully!");
}
```

### Минтинг токенов лояльности

```javascript
async function mintLoyaltyTokens() {
  const MyModusLoyalty = await ethers.getContractFactory("MyModusLoyalty");
  const loyaltyContract = await MyModusLoyalty.attach("LOYALTY_CONTRACT_ADDRESS");
  
  const amount = ethers.parseEther("100");
  const payment = await loyaltyContract.mintPrice() * amount;
  
  const tx = await loyaltyContract.mintWithETH(amount, { value: payment });
  await tx.wait();
  
  console.log("Loyalty tokens minted successfully!");
}
```

### Выставление NFT на продажу

```javascript
async function putNFTForSale() {
  const nftContract = await ethers.getContractFactory("MyModusNFT");
  const contract = await nftContract.attach("NFT_CONTRACT_ADDRESS");
  
  const tokenId = 1;
  const price = ethers.parseEther("0.1"); // 0.1 ETH
  
  const tx = await contract.putForSale(tokenId, price);
  await tx.wait();
  
  console.log("NFT put for sale!");
}
```

### Покупка NFT

```javascript
async function buyNFT() {
  const nftContract = await ethers.getContractFactory("MyModusNFT");
  const contract = await nftContract.attach("NFT_CONTRACT_ADDRESS");
  
  const tokenId = 1;
  const price = ethers.parseEther("0.1");
  
  const tx = await contract.buyNFT(tokenId, { value: price });
  await tx.wait();
  
  console.log("NFT purchased successfully!");
}
```

## 🔧 Разработка

### Добавление новых функций

1. **Создание feature branch**
```bash
git checkout -b feature/new-functionality
```

2. **Реализация в контракте**
3. **Написание тестов**
4. **Обновление документации**
5. **Создание Pull Request**

### Структура тестов

```javascript
describe("Новая функциональность", function () {
  beforeEach(async function () {
    // Подготовка тестового окружения
  });
  
  it("Должен корректно работать", async function () {
    // Тест функциональности
  });
  
  it("Должен обрабатывать ошибки", async function () {
    // Тест обработки ошибок
  });
});
```

### Линтинг и форматирование

```bash
# Проверка линтером
npx hardhat lint

# Форматирование кода
npx hardhat format
```

## 📊 Мониторинг

### События для отслеживания

- Минтинг NFT и токенов
- Продажи и покупки
- Изменения метаданных
- Управление ролями
- Административные действия

### Метрики

- Количество NFT
- Объем торгов
- Активные пользователи
- Газовые расходы
- Время выполнения транзакций

### Инструменты мониторинга

- Etherscan/Polygonscan
- The Graph
- Covalent
- Alchemy
- QuickNode

## 🤝 Вклад в проект

### Как внести вклад

1. Форкните репозиторий
2. Создайте feature branch
3. Внесите изменения
4. Напишите тесты
5. Обновите документацию
6. Создайте Pull Request

### Стандарты кода

- Следуйте Solidity Style Guide
- Используйте NatSpec комментарии
- Пишите comprehensive тесты
- Обновляйте документацию

### Процесс ревью

- Все изменения проходят code review
- Тесты должны проходить
- Покрытие кода не менее 80%
- Соответствие стандартам безопасности

## 📞 Поддержка

### Контакты

- **GitHub Issues**: [Создать issue](https://github.com/your-repo/issues)
- **Discord**: [Присоединиться к серверу](https://discord.gg/your-server)
- **Telegram**: [Группа разработчиков](https://t.me/your-group)

### Ресурсы

- [Документация Solidity](https://docs.soliditylang.org/)
- [OpenZeppelin Docs](https://docs.openzeppelin.com/)
- [Hardhat Docs](https://hardhat.org/docs/)
- [Ethereum Developer Resources](https://ethereum.org/developers/)

## 📄 Лицензия

Этот проект лицензирован под MIT License. См. файл [LICENSE](LICENSE) для деталей.

## 🙏 Благодарности

- OpenZeppelin за безопасные контракты
- Hardhat команде за отличный фреймворк
- Ethereum сообществу за вдохновение
- Всем контрибьюторам проекта

---

**Внимание**: Этот код предназначен для образовательных целей. Перед использованием в продакшене проведите тщательный аудит безопасности.
