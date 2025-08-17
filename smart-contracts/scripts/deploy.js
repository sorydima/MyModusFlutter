const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting deployment of MyModus smart contracts...");
  
  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log("📝 Deploying contracts with account:", deployer.address);
  console.log("💰 Account balance:", (await deployer.getBalance()).toString());
  
  try {
    // Deploy Escrow contract
    console.log("\n📦 Deploying Escrow contract...");
    const Escrow = await ethers.getContractFactory("Escrow");
    const escrow = await Escrow.deploy();
    await escrow.deployed();
    console.log("✅ Escrow deployed to:", escrow.address);
    
    // Deploy LoyaltyToken contract
    console.log("\n🎯 Deploying LoyaltyToken contract...");
    const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
    const loyaltyToken = await LoyaltyToken.deploy();
    await loyaltyToken.deployed();
    console.log("✅ LoyaltyToken deployed to:", loyaltyToken.address);
    
    // Deploy MyModusNFT contract
    console.log("\n🖼️ Deploying MyModusNFT contract...");
    const MyModusNFT = await ethers.getContractFactory("MyModusNFT");
    const myModusNFT = await MyModusNFT.deploy();
    await myModusNFT.deployed();
    console.log("✅ MyModusNFT deployed to:", myModusNFT.address);
    
    // Add deployer as minter for LoyaltyToken
    console.log("\n🔑 Setting up minter permissions...");
    await loyaltyToken.addMinter(deployer.address);
    console.log("✅ Deployer added as minter for LoyaltyToken");
    
    // Add deployer as minter for MyModusNFT (owner is automatically minter)
    console.log("✅ Deployer is owner of MyModusNFT");
    
    // Deploy some initial NFTs for testing
    console.log("\n🎨 Minting initial test NFTs...");
    
    // Mint a test achievement NFT
    await myModusNFT.mintAchievement(
      deployer.address,
      "Early Adopter",
      "One of the first users of MyModus platform",
      "ipfs://QmTestAchievement1",
      "Achievement",
      3, // Rarity
      1  // Level
    );
    console.log("✅ Minted 'Early Adopter' achievement NFT");
    
    // Mint a test collectible NFT
    await myModusNFT.mint(
      deployer.address,
      "Fashion Pioneer",
      "Exclusive fashion collectible for platform pioneers",
      "ipfs://QmTestCollectible1",
      "Collectible",
      4, // Rarity
      1, // Level
      true // Tradeable
    );
    console.log("✅ Minted 'Fashion Pioneer' collectible NFT");
    
    // Mint some initial loyalty tokens
    console.log("\n💎 Minting initial loyalty tokens...");
    await loyaltyToken.mintLoyaltyReward(deployer.address, ethers.utils.parseEther("1000"));
    console.log("✅ Minted 1000 loyalty tokens for deployer");
    
    // Print deployment summary
    console.log("\n🎉 Deployment completed successfully!");
    console.log("=" .repeat(60));
    console.log("📋 Contract Addresses:");
    console.log("Escrow:", escrow.address);
    console.log("LoyaltyToken:", loyaltyToken.address);
    console.log("MyModusNFT:", myModusNFT.address);
    console.log("=" .repeat(60));
    console.log("🔑 Deployer:", deployer.address);
    console.log("💰 Deployer balance:", (await deployer.getBalance()).toString());
    
    // Save deployment info to file
    const deploymentInfo = {
      network: network.name,
      deployer: deployer.address,
      contracts: {
        escrow: escrow.address,
        loyaltyToken: loyaltyToken.address,
        myModusNFT: myModusNFT.address
      },
      timestamp: new Date().toISOString(),
      blockNumber: await ethers.provider.getBlockNumber()
    };
    
    const fs = require('fs');
    fs.writeFileSync(
      `deployment-${network.name}.json`,
      JSON.stringify(deploymentInfo, null, 2)
    );
    console.log("\n💾 Deployment info saved to deployment-" + network.name + ".json");
    
    // Instructions for next steps
    console.log("\n📝 Next steps:");
    console.log("1. Update your .env file with the contract addresses");
    console.log("2. Verify contracts on Etherscan (if deploying to testnet/mainnet)");
    console.log("3. Update frontend configuration with new addresses");
    console.log("4. Test the contracts with your dApp");
    
  } catch (error) {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  }
}

// Handle errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
