// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title MyModus Loyalty Token
 * @dev ERC20 token for loyalty rewards
 */
contract LoyaltyToken is ERC20, Ownable, Pausable {
    
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; // 1 million tokens
    uint256 public constant MAX_SUPPLY = 10000000 * 10**18; // 10 million tokens
    
    mapping(address => bool) public minters;
    mapping(address => uint256) public lastRewardTime;
    
    uint256 public rewardRate = 100 * 10**18; // 100 tokens per day
    uint256 public constant REWARD_INTERVAL = 1 days;
    
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    event RewardRateUpdated(uint256 newRate);
    event LoyaltyReward(address indexed user, uint256 amount, uint256 timestamp);
    
    constructor() ERC20("MyModus Loyalty", "MML") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
        minters[msg.sender] = true;
    }
    
    modifier onlyMinter() {
        require(minters[msg.sender], "Only minters can call this function");
        _;
    }
    
    /**
     * @dev Mint new tokens (only minters)
     * @param to Recipient address
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) external onlyMinter whenNotPaused {
        require(to != address(0), "Cannot mint to zero address");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        
        _mint(to, amount);
    }
    
    /**
     * @dev Mint loyalty rewards for users
     * @param user User address
     * @param amount Reward amount
     */
    function mintLoyaltyReward(address user, uint256 amount) external onlyMinter whenNotPaused {
        require(user != address(0), "Invalid user address");
        require(amount > 0, "Amount must be greater than 0");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        
        _mint(user, amount);
        lastRewardTime[user] = block.timestamp;
        
        emit LoyaltyReward(user, amount, block.timestamp);
    }
    
    /**
     * @dev Calculate daily loyalty reward for user
     * @param user User address
     * @return rewardAmount Calculated reward amount
     */
    function calculateDailyReward(address user) external view returns (uint256 rewardAmount) {
        if (lastRewardTime[user] == 0) {
            return rewardRate;
        }
        
        uint256 timeSinceLastReward = block.timestamp - lastRewardTime[user];
        if (timeSinceLastReward >= REWARD_INTERVAL) {
            uint256 daysSinceLastReward = timeSinceLastReward / REWARD_INTERVAL;
            return rewardRate * daysSinceLastReward;
        }
        
        return 0;
    }
    
    /**
     * @dev Claim daily loyalty reward
     */
    function claimDailyReward() external whenNotPaused {
        uint256 reward = this.calculateDailyReward(msg.sender);
        require(reward > 0, "No reward available");
        
        require(totalSupply() + reward <= MAX_SUPPLY, "Exceeds max supply");
        
        _mint(msg.sender, reward);
        lastRewardTime[msg.sender] = block.timestamp;
        
        emit LoyaltyReward(msg.sender, reward, block.timestamp);
    }
    
    /**
     * @dev Add minter address (owner only)
     * @param minter Address to add as minter
     */
    function addMinter(address minter) external onlyOwner {
        require(minter != address(0), "Invalid minter address");
        minters[minter] = true;
        emit MinterAdded(minter);
    }
    
    /**
     * @dev Remove minter address (owner only)
     * @param minter Address to remove as minter
     */
    function removeMinter(address minter) external onlyOwner {
        require(minter != address(0), "Invalid minter address");
        minters[minter] = false;
        emit MinterRemoved(minter);
    }
    
    /**
     * @dev Update reward rate (owner only)
     * @param newRate New reward rate
     */
    function updateRewardRate(uint256 newRate) external onlyOwner {
        require(newRate > 0, "Rate must be greater than 0");
        rewardRate = newRate;
        emit RewardRateUpdated(newRate);
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
     * @dev Burn tokens from caller
     * @param amount Amount to burn
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev Burn tokens from specific address (only minters)
     * @param from Address to burn from
     * @param amount Amount to burn
     */
    function burnFrom(address from, uint256 amount) external onlyMinter {
        _burn(from, amount);
    }
    
    /**
     * @dev Get user's loyalty statistics
     * @param user User address
     * @return balance Current balance
     * @return lastReward Last reward time
     * @return nextRewardTime Next available reward time
     */
    function getUserLoyaltyStats(address user) external view returns (
        uint256 balance,
        uint256 lastReward,
        uint256 nextRewardTime
    ) {
        balance = balanceOf(user);
        lastReward = lastRewardTime[user];
        
        if (lastReward == 0) {
            nextRewardTime = block.timestamp;
        } else {
            nextRewardTime = lastReward + REWARD_INTERVAL;
        }
    }
}
