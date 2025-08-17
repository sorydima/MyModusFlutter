// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title MyModus NFT Collection
 * @dev ERC721 NFT contract for badges, achievements, and collectibles
 */
contract MyModusNFT is ERC721, ERC721URIStorage, Ownable, Pausable {
    
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;
    
    struct NFTMetadata {
        string name;
        string description;
        string imageURI;
        string category;
        uint256 rarity;
        uint256 level;
        bool isTradeable;
        uint256 createdAt;
    }
    
    mapping(uint256 => NFTMetadata) public nftMetadata;
    mapping(string => uint256) public categoryCounts;
    mapping(address => uint256[]) public userNFTs;
    
    uint256 public mintPrice = 0.01 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxPerWallet = 100;
    
    event NFTMinted(uint256 indexed tokenId, address indexed owner, string category);
    event NFTMetadataUpdated(uint256 indexed tokenId);
    event MintPriceUpdated(uint256 newPrice);
    event MaxSupplyUpdated(uint256 newMaxSupply);
    
    constructor() ERC721("MyModus NFT Collection", "MMNFT") Ownable(msg.sender) {}
    
    /**
     * @dev Mint new NFT
     * @param to Recipient address
     * @param name NFT name
     * @param description NFT description
     * @param imageURI Image URI
     * @param category NFT category
     * @param rarity Rarity level (1-5)
     * @param level Achievement level
     * @param isTradeable Whether NFT can be traded
     */
    function mint(
        address to,
        string memory name,
        string memory description,
        string memory imageURI,
        string memory category,
        uint256 rarity,
        uint256 level,
        bool isTradeable
    ) external payable whenNotPaused {
        require(msg.value >= mintPrice, "Insufficient payment");
        require(to != address(0), "Invalid recipient address");
        require(_tokenIds.current() < maxSupply, "Max supply reached");
        require(balanceOf(to) < maxPerWallet, "Max per wallet reached");
        require(rarity >= 1 && rarity <= 5, "Invalid rarity level");
        require(level >= 1, "Invalid level");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, "");
        
        nftMetadata[newTokenId] = NFTMetadata({
            name: name,
            description: description,
            imageURI: imageURI,
            category: category,
            rarity: rarity,
            level: level,
            isTradeable: isTradeable,
            createdAt: block.timestamp
        });
        
        categoryCounts[category]++;
        userNFTs[to].push(newTokenId);
        
        emit NFTMinted(newTokenId, to, category);
    }
    
    /**
     * @dev Mint achievement NFT (free, owner only)
     * @param to Recipient address
     * @param name Achievement name
     * @param description Achievement description
     * @param imageURI Achievement image
     * @param category Achievement category
     * @param rarity Achievement rarity
     * @param level Achievement level
     */
    function mintAchievement(
        address to,
        string memory name,
        string memory description,
        string memory imageURI,
        string memory category,
        uint256 rarity,
        uint256 level
    ) external onlyOwner whenNotPaused {
        require(to != address(0), "Invalid recipient address");
        require(_tokenIds.current() < maxSupply, "Max supply reached");
        require(rarity >= 1 && rarity <= 5, "Invalid rarity level");
        require(level >= 1, "Invalid level");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, "");
        
        nftMetadata[newTokenId] = NFTMetadata({
            name: name,
            description: description,
            imageURI: imageURI,
            category: category,
            rarity: rarity,
            level: level,
            isTradeable: false, // Achievements are not tradeable
            createdAt: block.timestamp
        });
        
        categoryCounts[category]++;
        userNFTs[to].push(newTokenId);
        
        emit NFTMinted(newTokenId, to, category);
    }
    
    /**
     * @dev Update NFT metadata (owner only)
     * @param tokenId Token ID
     * @param name New name
     * @param description New description
     * @param imageURI New image URI
     * @param category New category
     * @param rarity New rarity
     * @param level New level
     * @param isTradeable New tradeable status
     */
    function updateNFTMetadata(
        uint256 tokenId,
        string memory name,
        string memory description,
        string memory imageURI,
        string memory category,
        uint256 rarity,
        uint256 level,
        bool isTradeable
    ) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        require(rarity >= 1 && rarity <= 5, "Invalid rarity level");
        require(level >= 1, "Invalid level");
        
        string memory oldCategory = nftMetadata[tokenId].category;
        if (keccak256(bytes(oldCategory)) != keccak256(bytes(category))) {
            categoryCounts[oldCategory]--;
            categoryCounts[category]++;
        }
        
        nftMetadata[tokenId] = NFTMetadata({
            name: name,
            description: description,
            imageURI: imageURI,
            category: category,
            rarity: rarity,
            level: level,
            isTradeable: isTradeable,
            createdAt: nftMetadata[tokenId].createdAt
        });
        
        emit NFTMetadataUpdated(tokenId);
    }
    
    /**
     * @dev Get NFT metadata
     * @param tokenId Token ID
     * @return NFTMetadata struct
     */
    function getNFTMetadata(uint256 tokenId) external view returns (NFTMetadata memory) {
        require(_exists(tokenId), "Token does not exist");
        return nftMetadata[tokenId];
    }
    
    /**
     * @dev Get user's NFTs
     * @param user User address
     * @return Array of token IDs
     */
    function getUserNFTs(address user) external view returns (uint256[] memory) {
        return userNFTs[user];
    }
    
    /**
     * @dev Get NFTs by category
     * @param category Category name
     * @return count Number of NFTs in category
     */
    function getCategoryCount(string memory category) external view returns (uint256) {
        return categoryCounts[category];
    }
    
    /**
     * @dev Get total supply
     * @return Total number of minted NFTs
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIds.current();
    }
    
    /**
     * @dev Update mint price (owner only)
     * @param newPrice New mint price
     */
    function updateMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
        emit MintPriceUpdated(newPrice);
    }
    
    /**
     * @dev Update max supply (owner only)
     * @param newMaxSupply New max supply
     */
    function updateMaxSupply(uint256 newMaxSupply) external onlyOwner {
        require(newMaxSupply >= _tokenIds.current(), "Cannot decrease below current supply");
        maxSupply = newMaxSupply;
        emit MaxSupplyUpdated(newMaxSupply);
    }
    
    /**
     * @dev Pause contract (owner only)
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause contract (owner only)
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Withdraw contract balance (owner only)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        
        payable(owner()).transfer(balance);
    }
    
    /**
     * @dev Override required functions
     */
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
        
        // Remove from user's NFT list
        uint256[] storage userNFTList = userNFTs[ownerOf(tokenId)];
        for (uint256 i = 0; i < userNFTList.length; i++) {
            if (userNFTList[i] == tokenId) {
                userNFTList[i] = userNFTList[userNFTList.length - 1];
                userNFTList.pop();
                break;
            }
        }
        
        // Decrease category count
        string memory category = nftMetadata[tokenId].category;
        if (categoryCounts[category] > 0) {
            categoryCounts[category]--;
        }
        
        // Delete metadata
        delete nftMetadata[tokenId];
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    /**
     * @dev Override transfer functions to check tradeable status
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        
        if (from != address(0) && to != address(0)) {
            require(nftMetadata[firstTokenId].isTradeable, "NFT is not tradeable");
        }
    }
}
