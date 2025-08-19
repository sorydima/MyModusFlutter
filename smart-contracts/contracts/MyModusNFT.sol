// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title MyModusNFT
 * @dev NFT контракт для платформы MyModus
 * Поддерживает минтинг, передачу и метаданные
 */
contract MyModusNFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;
    
    // Структура для метаданных NFT
    struct NFTMetadata {
        string name;
        string description;
        string imageURI;
        string category;
        uint256 price;
        bool isForSale;
        address creator;
        uint256 createdAt;
    }
    
    // Маппинг токен ID -> метаданные
    mapping(uint256 => NFTMetadata) public tokenMetadata;
    
    // Маппинг адрес -> количество созданных NFT
    mapping(address => uint256) public creatorNFTCount;
    
    // События
    event NFTMinted(uint256 indexed tokenId, address indexed creator, string tokenURI);
    event NFTMetadataUpdated(uint256 indexed tokenId, string name, string description);
    event NFTPutForSale(uint256 indexed tokenId, uint256 price);
    event NFTRemovedFromSale(uint256 indexed tokenId);
    event NFTPriceUpdated(uint256 indexed tokenId, uint256 newPrice);
    
    // Конструктор
    constructor() ERC721("MyModus NFT", "MMNFT") Ownable(msg.sender) {}
    
    /**
     * @dev Минтинг нового NFT
     * @param to Адрес получателя
     * @param tokenURI URI метаданных
     * @param name Название NFT
     * @param description Описание NFT
     * @param imageURI URI изображения
     * @param category Категория NFT
     */
    function mintNFT(
        address to,
        string memory tokenURI,
        string memory name,
        string memory description,
        string memory imageURI,
        string memory category
    ) public returns (uint256) {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(bytes(imageURI).length > 0, "Image URI cannot be empty");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        
        // Сохраняем метаданные
        tokenMetadata[newTokenId] = NFTMetadata({
            name: name,
            description: description,
            imageURI: imageURI,
            category: category,
            price: 0,
            isForSale: false,
            creator: msg.sender,
            createdAt: block.timestamp
        });
        
        creatorNFTCount[msg.sender]++;
        
        emit NFTMinted(newTokenId, msg.sender, tokenURI);
        
        return newTokenId;
    }
    
    /**
     * @dev Обновление метаданных NFT
     * @param tokenId ID токена
     * @param name Новое название
     * @param description Новое описание
     */
    function updateMetadata(
        uint256 tokenId,
        string memory name,
        string memory description
    ) public {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        
        tokenMetadata[tokenId].name = name;
        tokenMetadata[tokenId].description = description;
        
        emit NFTMetadataUpdated(tokenId, name, description);
    }
    
    /**
     * @dev Выставить NFT на продажу
     * @param tokenId ID токена
     * @param price Цена в ETH
     */
    function putForSale(uint256 tokenId, uint256 price) public {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        require(price > 0, "Price must be greater than 0");
        
        tokenMetadata[tokenId].isForSale = true;
        tokenMetadata[tokenId].price = price;
        
        emit NFTPutForSale(tokenId, price);
    }
    
    /**
     * @dev Убрать NFT с продажи
     * @param tokenId ID токена
     */
    function removeFromSale(uint256 tokenId) public {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        
        tokenMetadata[tokenId].isForSale = false;
        tokenMetadata[tokenId].price = 0;
        
        emit NFTRemovedFromSale(tokenId);
    }
    
    /**
     * @dev Обновить цену NFT
     * @param tokenId ID токена
     * @param newPrice Новая цена
     */
    function updatePrice(uint256 tokenId, uint256 newPrice) public {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        require(newPrice > 0, "Price must be greater than 0");
        require(tokenMetadata[tokenId].isForSale, "Token is not for sale");
        
        tokenMetadata[tokenId].price = newPrice;
        
        emit NFTPriceUpdated(tokenId, newPrice);
    }
    
    /**
     * @dev Покупка NFT
     * @param tokenId ID токена
     */
    function buyNFT(uint256 tokenId) public payable {
        require(_exists(tokenId), "Token does not exist");
        require(tokenMetadata[tokenId].isForSale, "Token is not for sale");
        require(msg.value >= tokenMetadata[tokenId].price, "Insufficient payment");
        require(ownerOf(tokenId) != msg.sender, "Cannot buy your own token");
        
        address seller = ownerOf(tokenId);
        uint256 price = tokenMetadata[tokenId].price;
        
        // Переводим токен покупателю
        _transfer(seller, msg.sender, tokenId);
        
        // Переводим ETH продавцу
        payable(seller).transfer(price);
        
        // Возвращаем излишки
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
        
        // Убираем с продажи
        tokenMetadata[tokenId].isForSale = false;
        tokenMetadata[tokenId].price = 0;
    }
    
    /**
     * @dev Получение метаданных NFT
     * @param tokenId ID токена
     * @return Метаданные NFT
     */
    function getNFTMetadata(uint256 tokenId) public view returns (NFTMetadata memory) {
        require(_exists(tokenId), "Token does not exist");
        return tokenMetadata[tokenId];
    }
    
    /**
     * @dev Получение всех NFT пользователя
     * @param user Адрес пользователя
     * @return Массив ID токенов
     */
    function getUserNFTs(address user) public view returns (uint256[] memory) {
        uint256[] memory userTokens = new uint256[](balanceOf(user));
        uint256 counter = 0;
        
        for (uint256 i = 1; i <= _tokenIds.current(); i++) {
            if (_exists(i) && ownerOf(i) == user) {
                userTokens[counter] = i;
                counter++;
            }
        }
        
        return userTokens;
    }
    
    /**
     * @dev Получение NFT на продаже
     * @return Массив ID токенов на продаже
     */
    function getNFTsForSale() public view returns (uint256[] memory) {
        uint256[] memory forSaleTokens = new uint256[](0);
        uint256 counter = 0;
        
        for (uint256 i = 1; i <= _tokenIds.current(); i++) {
            if (_exists(i) && tokenMetadata[i].isForSale) {
                // Расширяем массив
                uint256[] memory temp = new uint256[](counter + 1);
                for (uint256 j = 0; j < counter; j++) {
                    temp[j] = forSaleTokens[j];
                }
                temp[counter] = i;
                forSaleTokens = temp;
                counter++;
            }
        }
        
        return forSaleTokens;
    }
    
    /**
     * @dev Получение статистики
     * @return totalNFTs Общее количество NFT
     * @return totalCreators Общее количество создателей
     * @return nftsForSale Количество NFT на продаже
     */
    function getStats() public view returns (
        uint256 totalNFTs,
        uint256 totalCreators,
        uint256 nftsForSale
    ) {
        totalNFTs = _tokenIds.current();
        
        uint256 creators = 0;
        uint256 forSale = 0;
        
        for (uint256 i = 1; i <= totalNFTs; i++) {
            if (_exists(i)) {
                if (tokenMetadata[i].isForSale) {
                    forSale++;
                }
            }
        }
        
        // Подсчитываем уникальных создателей
        address[] memory allCreators = new address[](totalNFTs);
        uint256 uniqueCreators = 0;
        
        for (uint256 i = 1; i <= totalNFTs; i++) {
            if (_exists(i)) {
                address creator = tokenMetadata[i].creator;
                bool isUnique = true;
                
                for (uint256 j = 0; j < uniqueCreators; j++) {
                    if (allCreators[j] == creator) {
                        isUnique = false;
                        break;
                    }
                }
                
                if (isUnique) {
                    allCreators[uniqueCreators] = creator;
                    uniqueCreators++;
                }
            }
        }
        
        totalCreators = uniqueCreators;
        nftsForSale = forSale;
    }
    
    // Override функций для совместимости
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
        
        // Удаляем метаданные
        delete tokenMetadata[tokenId];
        
        // Уменьшаем счетчик создателя
        if (creatorNFTCount[tokenMetadata[tokenId].creator] > 0) {
            creatorNFTCount[tokenMetadata[tokenId].creator]--;
        }
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
