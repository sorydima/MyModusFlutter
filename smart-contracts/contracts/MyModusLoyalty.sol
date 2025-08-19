// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title MyModusLoyalty
 * @dev Токен лояльности для платформы MyModus
 * Поддерживает минтинг, сжигание, паузу и управление
 */
contract MyModusLoyalty is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ReentrancyGuard {
    
    // Структура для информации о токене
    struct TokenInfo {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 maxSupply;
        bool isActive;
        uint256 createdAt;
        address creator;
    }
    
    // Структура для пользователя
    struct UserInfo {
        uint256 balance;
        uint256 totalEarned;
        uint256 totalSpent;
        uint256 lastActivity;
        bool isActive;
    }
    
    // Маппинги
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public minters;
    mapping(address => bool) public burners;
    
    // Переменные состояния
    uint256 public maxSupply;
    uint256 public mintPrice;
    bool public mintingEnabled;
    bool public burningEnabled;
    
    // События
    event TokensMinted(address indexed to, uint256 amount, uint256 cost);
    event TokensBurned(address indexed from, uint256 amount);
    event UserRegistered(address indexed user);
    event UserDeactivated(address indexed user);
    event MintPriceUpdated(uint256 newPrice);
    event MaxSupplyUpdated(uint256 newMaxSupply);
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    event BurnerAdded(address indexed burner);
    event BurnerRemoved(address indexed burner);
    
    // Модификаторы
    modifier onlyMinter() {
        require(minters[msg.sender] || msg.sender == owner(), "Not authorized to mint");
        _;
    }
    
    modifier onlyBurner() {
        require(burners[msg.sender] || msg.sender == owner(), "Not authorized to burn");
        _;
    }
    
    modifier mintingAllowed() {
        require(mintingEnabled, "Minting is disabled");
        _;
    }
    
    modifier burningAllowed() {
        require(burningEnabled, "Burning is disabled");
        _;
    }
    
    // Конструктор
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _maxSupply,
        uint256 _mintPrice
    ) ERC20(_name, _symbol) Ownable(msg.sender) {
        require(_maxSupply > 0, "Max supply must be greater than 0");
        require(_decimals <= 18, "Decimals cannot exceed 18");
        
        maxSupply = _maxSupply;
        mintPrice = _mintPrice;
        mintingEnabled = true;
        burningEnabled = true;
        
        // Добавляем владельца как минтера и бёрнера
        minters[msg.sender] = true;
        burners[msg.sender] = true;
        
        emit MinterAdded(msg.sender);
        emit BurnerAdded(msg.sender);
    }
    
    /**
     * @dev Минтинг токенов (только для авторизованных)
     * @param to Адрес получателя
     * @param amount Количество токенов
     */
    function mint(address to, uint256 amount) public onlyMinter mintingAllowed {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than 0");
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        
        _mint(to, amount);
        
        // Обновляем информацию о пользователе
        _updateUserInfo(to, amount, 0);
        
        emit TokensMinted(to, amount, 0);
    }
    
    /**
     * @dev Минтинг токенов за ETH
     * @param amount Количество токенов
     */
    function mintWithETH(uint256 amount) public payable mintingAllowed nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(msg.value >= mintPrice * amount, "Insufficient payment");
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        
        _mint(msg.sender, amount);
        
        // Обновляем информацию о пользователе
        _updateUserInfo(msg.sender, amount, msg.value);
        
        // Возвращаем излишки
        if (msg.value > mintPrice * amount) {
            payable(msg.sender).transfer(msg.value - (mintPrice * amount));
        }
        
        emit TokensMinted(msg.sender, amount, msg.value);
    }
    
    /**
     * @dev Сжигание токенов
     * @param amount Количество токенов для сжигания
     */
    function burn(uint256 amount) public override burningAllowed {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        _burn(msg.sender, amount);
        
        // Обновляем информацию о пользователе
        _updateUserInfo(msg.sender, 0, 0);
        
        emit TokensBurned(msg.sender, amount);
    }
    
    /**
     * @dev Принудительное сжигание токенов (только для авторизованных)
     * @param from Адрес пользователя
     * @param amount Количество токенов
     */
    function burnFrom(address from, uint256 amount) public override onlyBurner burningAllowed {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(from) >= amount, "Insufficient balance");
        
        _burn(from, amount);
        
        // Обновляем информацию о пользователе
        _updateUserInfo(from, 0, 0);
        
        emit TokensBurned(from, amount);
    }
    
    /**
     * @dev Регистрация нового пользователя
     * @param user Адрес пользователя
     */
    function registerUser(address user) public onlyOwner {
        require(user != address(0), "Invalid user address");
        require(!userInfo[user].isActive, "User already registered");
        
        userInfo[user] = UserInfo({
            balance: balanceOf(user),
            totalEarned: 0,
            totalSpent: 0,
            lastActivity: block.timestamp,
            isActive: true
        });
        
        emit UserRegistered(user);
    }
    
    /**
     * @dev Деактивация пользователя
     * @param user Адрес пользователя
     */
    function deactivateUser(address user) public onlyOwner {
        require(user != address(0), "Invalid user address");
        require(userInfo[user].isActive, "User not registered");
        
        userInfo[user].isActive = false;
        
        emit UserDeactivated(user);
    }
    
    /**
     * @dev Добавление минтера
     * @param minter Адрес минтера
     */
    function addMinter(address minter) public onlyOwner {
        require(minter != address(0), "Invalid minter address");
        require(!minters[minter], "Already a minter");
        
        minters[minter] = true;
        
        emit MinterAdded(minter);
    }
    
    /**
     * @dev Удаление минтера
     * @param minter Адрес минтера
     */
    function removeMinter(address minter) public onlyOwner {
        require(minter != address(0), "Invalid minter address");
        require(minters[minter], "Not a minter");
        require(minter != owner(), "Cannot remove owner as minter");
        
        minters[minter] = false;
        
        emit MinterRemoved(minter);
    }
    
    /**
     * @dev Добавление бёрнера
     * @param burner Адрес бёрнера
     */
    function addBurner(address burner) public onlyOwner {
        require(burner != address(0), "Invalid burner address");
        require(!burners[burner], "Already a burner");
        
        burners[burner] = true;
        
        emit BurnerAdded(burner);
    }
    
    /**
     * @dev Удаление бёрнера
     * @param burner Адрес бёрнера
     */
    function removeBurner(address burner) public onlyOwner {
        require(burner != address(0), "Invalid burner address");
        require(burners[burner], "Not a burner");
        require(burner != owner(), "Cannot remove owner as burner");
        
        burners[burner] = false;
        
        emit BurnerRemoved(burner);
    }
    
    /**
     * @dev Обновление цены минтинга
     * @param newPrice Новая цена
     */
    function updateMintPrice(uint256 newPrice) public onlyOwner {
        require(newPrice >= 0, "Price cannot be negative");
        
        mintPrice = newPrice;
        
        emit MintPriceUpdated(newPrice);
    }
    
    /**
     * @dev Обновление максимального предложения
     * @param newMaxSupply Новое максимальное предложение
     */
    function updateMaxSupply(uint256 newMaxSupply) public onlyOwner {
        require(newMaxSupply >= totalSupply(), "Cannot decrease below current supply");
        require(newMaxSupply > 0, "Max supply must be greater than 0");
        
        maxSupply = newMaxSupply;
        
        emit MaxSupplyUpdated(newMaxSupply);
    }
    
    /**
     * @dev Включение/выключение минтинга
     * @param enabled Статус минтинга
     */
    function setMintingEnabled(bool enabled) public onlyOwner {
        mintingEnabled = enabled;
    }
    
    /**
     * @dev Включение/выключение сжигания
     * @param enabled Статус сжигания
     */
    function setBurningEnabled(bool enabled) public onlyOwner {
        burningEnabled = enabled;
    }
    
    /**
     * @dev Пауза контракта
     */
    function pause() public onlyOwner {
        _pause();
    }
    
    /**
     * @dev Возобновление контракта
     */
    function unpause() public onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Получение информации о токене
     * @return Информация о токене
     */
    function getTokenInfo() public view returns (TokenInfo memory) {
        return TokenInfo({
            name: name(),
            symbol: symbol(),
            decimals: decimals(),
            totalSupply: totalSupply(),
            maxSupply: maxSupply,
            isActive: !paused(),
            createdAt: block.timestamp,
            creator: owner()
        });
    }
    
    /**
     * @dev Получение информации о пользователе
     * @param user Адрес пользователя
     * @return Информация о пользователе
     */
    function getUserInfo(address user) public view returns (UserInfo memory) {
        return userInfo[user];
    }
    
    /**
     * @dev Проверка, является ли адрес минтером
     * @param account Адрес для проверки
     * @return true, если адрес является минтером
     */
    function isMinter(address account) public view returns (bool) {
        return minters[account] || account == owner();
    }
    
    /**
     * @dev Проверка, является ли адрес бёрнером
     * @param account Адрес для проверки
     * @return true, если адрес является бёрнером
     */
    function isBurner(address account) public view returns (bool) {
        return burners[account] || account == owner();
    }
    
    /**
     * @dev Получение статистики
     * @return totalUsers Общее количество пользователей
     * @return activeUsers Количество активных пользователей
     * @return totalMinters Количество минтеров
     * @return totalBurners Количество бёрнеров
     */
    function getStats() public view returns (
        uint256 totalUsers,
        uint256 activeUsers,
        uint256 totalMinters,
        uint256 totalBurners
    ) {
        // Подсчитываем пользователей (упрощенно)
        totalUsers = 0;
        activeUsers = 0;
        
        // Подсчитываем минтеров и бёрнеров
        totalMinters = 0;
        totalBurners = 0;
        
        // В реальном контракте здесь была бы логика подсчета
        // Для демонстрации возвращаем базовые значения
        totalMinters = 1; // owner
        totalBurners = 1; // owner
    }
    
    /**
     * @dev Вывод ETH из контракта (только для владельца)
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        
        payable(owner()).transfer(balance);
    }
    
    // Внутренние функции
    
    /**
     * @dev Обновление информации о пользователе
     * @param user Адрес пользователя
     * @param earned Заработано токенов
     * @param spent Потрачено ETH
     */
    function _updateUserInfo(address user, uint256 earned, uint256 spent) internal {
        if (userInfo[user].isActive) {
            userInfo[user].balance = balanceOf(user);
            userInfo[user].totalEarned += earned;
            userInfo[user].totalSpent += spent;
            userInfo[user].lastActivity = block.timestamp;
        } else {
            // Регистрируем пользователя автоматически
            userInfo[user] = UserInfo({
                balance: balanceOf(user),
                totalEarned: earned,
                totalSpent: spent,
                lastActivity: block.timestamp,
                isActive: true
            });
        }
    }
    
    // Override функций для совместимости
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
        
        // Обновляем информацию о пользователях при переводах
        if (from != address(0)) {
            _updateUserInfo(from, 0, 0);
        }
        if (to != address(0)) {
            _updateUserInfo(to, 0, 0);
        }
    }
}
