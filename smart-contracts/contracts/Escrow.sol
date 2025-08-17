// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Escrow Contract for MyModus
 * @dev Handles escrow payments for product purchases
 */
contract Escrow is ReentrancyGuard, Ownable {
    
    struct EscrowInfo {
        string productId;
        address buyer;
        address seller;
        uint256 amount;
        uint256 createdAt;
        bool isReleased;
        bool isRefunded;
    }
    
    mapping(string => EscrowInfo) public escrows;
    mapping(address => string[]) public userEscrows;
    
    uint256 public escrowFee = 25; // 0.25% fee
    uint256 public constant FEE_DENOMINATOR = 10000;
    
    event EscrowCreated(string indexed escrowId, address indexed buyer, address indexed seller, uint256 amount);
    event EscrowReleased(string indexed escrowId, address indexed seller, uint256 amount);
    event EscrowRefunded(string indexed escrowId, address indexed buyer, uint256 amount);
    event FeeUpdated(uint256 newFee);
    
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Create a new escrow
     * @param escrowId Unique identifier for the escrow
     * @param productId Product identifier
     * @param seller Seller's address
     */
    function createEscrow(
        string memory escrowId,
        string memory productId,
        address seller
    ) external payable nonReentrant {
        require(msg.value > 0, "Amount must be greater than 0");
        require(seller != address(0), "Invalid seller address");
        require(seller != msg.sender, "Buyer cannot be seller");
        require(escrows[escrowId].buyer == address(0), "Escrow ID already exists");
        
        escrows[escrowId] = EscrowInfo({
            productId: productId,
            buyer: msg.sender,
            seller: seller,
            amount: msg.value,
            createdAt: block.timestamp,
            isReleased: false,
            isRefunded: false
        });
        
        userEscrows[msg.sender].push(escrowId);
        userEscrows[seller].push(escrowId);
        
        emit EscrowCreated(escrowId, msg.sender, seller, msg.value);
    }
    
    /**
     * @dev Release escrow funds to seller
     * @param escrowId Escrow identifier
     */
    function releaseEscrow(string memory escrowId) external nonReentrant {
        EscrowInfo storage escrow = escrows[escrowId];
        require(escrow.buyer != address(0), "Escrow does not exist");
        require(escrow.buyer == msg.sender, "Only buyer can release escrow");
        require(!escrow.isReleased, "Escrow already released");
        require(!escrow.isRefunded, "Escrow already refunded");
        
        escrow.isReleased = true;
        
        uint256 fee = (escrow.amount * escrowFee) / FEE_DENOMINATOR;
        uint256 sellerAmount = escrow.amount - fee;
        
        payable(escrow.seller).transfer(sellerAmount);
        payable(owner()).transfer(fee);
        
        emit EscrowReleased(escrowId, escrow.seller, sellerAmount);
    }
    
    /**
     * @dev Refund escrow funds to buyer
     * @param escrowId Escrow identifier
     */
    function refundEscrow(string memory escrowId) external nonReentrant {
        EscrowInfo storage escrow = escrows[escrowId];
        require(escrow.buyer != address(0), "Escrow does not exist");
        require(escrow.buyer == msg.sender, "Only buyer can refund escrow");
        require(!escrow.isReleased, "Escrow already released");
        require(!escrow.isRefunded, "Escrow already refunded");
        
        escrow.isRefunded = true;
        
        payable(escrow.buyer).transfer(escrow.amount);
        
        emit EscrowRefunded(escrowId, escrow.buyer, escrow.amount);
    }
    
    /**
     * @dev Get escrow information
     * @param escrowId Escrow identifier
     * @return EscrowInfo struct
     */
    function getEscrow(string memory escrowId) external view returns (EscrowInfo memory) {
        return escrows[escrowId];
    }
    
    /**
     * @dev Get user's escrows
     * @param user User address
     * @return Array of escrow IDs
     */
    function getUserEscrows(address user) external view returns (string[] memory) {
        return userEscrows[user];
    }
    
    /**
     * @dev Update escrow fee (owner only)
     * @param newFee New fee in basis points
     */
    function updateEscrowFee(uint256 newFee) external onlyOwner {
        require(newFee <= 1000, "Fee cannot exceed 10%");
        escrowFee = newFee;
        emit FeeUpdated(newFee);
    }
    
    /**
     * @dev Withdraw accumulated fees (owner only)
     */
    function withdrawFees() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");
        
        payable(owner()).transfer(balance);
    }
    
    /**
     * @dev Emergency function to recover stuck ETH (owner only)
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        
        payable(owner()).transfer(balance);
    }
    
    receive() external payable {
        revert("Direct deposits not allowed");
    }
}
