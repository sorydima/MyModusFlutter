const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Начинаем деплой смарт-контрактов MyModus...");
  
  // Получаем аккаунт для деплоя
  const [deployer] = await ethers.getSigners();
  console.log(`📝 Деплой с аккаунта: ${deployer.address}`);
  console.log(`💰 Баланс аккаунта: ${ethers.formatEther(await deployer.provider.getBalance(deployer.address))} ETH`);
  
  // Деплой NFT контракта
  console.log("\n🎨 Деплой NFT контракта...");
  const MyModusNFT = await ethers.getContractFactory("MyModusNFT");
  const nftContract = await MyModusNFT.deploy();
  await nftContract.waitForDeployment();
  
  const nftAddress = await nftContract.getAddress();
  console.log(`✅ NFT контракт развернут по адресу: ${nftAddress}`);
  
  // Деплой токена лояльности
  console.log("\n🪙 Деплой токена лояльности...");
  const MyModusLoyalty = await ethers.getContractFactory("MyModusLoyalty");
  const loyaltyContract = await MyModusLoyalty.deploy(
    "MyModus Loyalty Token", // Название
    "MMLT",                   // Символ
    18,                       // Десятичные знаки
    ethers.parseEther("1000000"), // Максимальное предложение: 1M токенов
    ethers.parseEther("0.001")   // Цена минтинга: 0.001 ETH за токен
  );
  await loyaltyContract.waitForDeployment();
  
  const loyaltyAddress = await loyaltyContract.getAddress();
  console.log(`✅ Токен лояльности развернут по адресу: ${loyaltyAddress}`);
  
  // Получаем информацию о развернутых контрактах
  console.log("\n📊 Информация о развернутых контрактах:");
  
  const nftName = await nftContract.name();
  const nftSymbol = await nftContract.symbol();
  console.log(`🎨 NFT: ${nftName} (${nftSymbol})`);
  
  const loyaltyName = await loyaltyContract.name();
  const loyaltySymbol = await loyaltyContract.symbol();
  const loyaltyDecimals = await loyaltyContract.decimals();
  const loyaltyMaxSupply = await loyaltyContract.maxSupply();
  const loyaltyMintPrice = await loyaltyContract.mintPrice();
  
  console.log(`🪙 Токен лояльности: ${loyaltyName} (${loyaltySymbol})`);
  console.log(`   Десятичные знаки: ${loyaltyDecimals}`);
  console.log(`   Максимальное предложение: ${ethers.formatEther(loyaltyMaxSupply)} ${loyaltySymbol}`);
  console.log(`   Цена минтинга: ${ethers.formatEther(loyaltyMintPrice)} ETH`);
  
  // Проверяем права владельца
  console.log("\n🔐 Проверка прав доступа:");
  
  const nftOwner = await nftContract.owner();
  const loyaltyOwner = await loyaltyContract.owner();
  
  console.log(`NFT владелец: ${nftOwner}`);
  console.log(`Токен владелец: ${loyaltyOwner}`);
  console.log(`Деплойщик: ${deployer.address}`);
  
  if (nftOwner === deployer.address && loyaltyOwner === deployer.address) {
    console.log("✅ Права владельца корректно установлены");
  } else {
    console.log("❌ Ошибка: права владельца установлены некорректно");
  }
  
  // Проверяем минтеров и бёрнеров
  const isNFTMinter = await nftContract.isMinter(deployer.address);
  const isLoyaltyMinter = await loyaltyContract.isMinter(deployer.address);
  const isLoyaltyBurner = await loyaltyContract.isBurner(deployer.address);
  
  console.log(`\n🔑 Права доступа:`);
  console.log(`NFT минтер: ${isNFTMinter ? "✅" : "❌"}`);
  console.log(`Токен минтер: ${isLoyaltyMinter ? "✅" : "❌"}`);
  console.log(`Токен бёрнер: ${isLoyaltyBurner ? "✅" : "❌"}`);
  
  // Тестируем базовую функциональность
  console.log("\n🧪 Тестирование базовой функциональности...");
  
  try {
    // Тест минтинга NFT
    console.log("Тестируем минтинг NFT...");
    const testTokenURI = "ipfs://QmTestNFTMetadata";
    const testName = "Test NFT";
    const testDescription = "Test NFT description";
    const testImageURI = "ipfs://QmTestImage";
    const testCategory = "Test";
    
    const mintTx = await nftContract.mintNFT(
      deployer.address,
      testTokenURI,
      testName,
      testDescription,
      testImageURI,
      testCategory
    );
    
    await mintTx.wait();
    console.log("✅ NFT успешно отминчен");
    
    // Проверяем метаданные
    const metadata = await nftContract.getNFTMetadata(1);
    console.log(`   Название: ${metadata.name}`);
    console.log(`   Описание: ${metadata.description}`);
    console.log(`   Категория: ${metadata.category}`);
    
    // Тест минтинга токенов лояльности
    console.log("\nТестируем минтинг токенов лояльности...");
    const testAmount = ethers.parseEther("100");
    
    const mintLoyaltyTx = await loyaltyContract.mint(deployer.address, testAmount);
    await mintLoyaltyTx.wait();
    
    console.log("✅ Токены лояльности успешно отминчены");
    
    // Проверяем баланс
    const balance = await loyaltyContract.balanceOf(deployer.address);
    console.log(`   Баланс: ${ethers.formatEther(balance)} ${loyaltySymbol}`);
    
    // Получаем статистику
    const nftStats = await nftContract.getStats();
    const loyaltyStats = await loyaltyContract.getStats();
    
    console.log("\n📈 Статистика контрактов:");
    console.log(`NFT:`);
    console.log(`   Всего токенов: ${nftStats.totalNFTs}`);
    console.log(`   Создателей: ${nftStats.totalCreators}`);
    console.log(`   На продаже: ${nftStats.nftsForSale}`);
    
    console.log(`Токен лояльности:`);
    console.log(`   Всего пользователей: ${loyaltyStats.totalUsers}`);
    console.log(`   Активных пользователей: ${loyaltyStats.activeUsers}`);
    console.log(`   Минтеров: ${loyaltyStats.totalMinters}`);
    console.log(`   Бёрнеров: ${loyaltyStats.totalBurners}`);
    
  } catch (error) {
    console.log("❌ Ошибка при тестировании:", error.message);
  }
  
  // Сохраняем адреса контрактов
  console.log("\n💾 Сохранение адресов контрактов...");
  
  const contractAddresses = {
    network: network.name,
    nftContract: nftAddress,
    loyaltyContract: loyaltyAddress,
    deployer: deployer.address,
    deploymentTime: new Date().toISOString()
  };
  
  // Выводим адреса для копирования
  console.log("\n📋 Адреса контрактов для копирования:");
  console.log(`NFT_CONTRACT_ADDRESS=${nftAddress}`);
  console.log(`LOYALTY_CONTRACT_ADDRESS=${loyaltyAddress}`);
  console.log(`DEPLOYER_ADDRESS=${deployer.address}`);
  
  // Сохраняем в файл
  const fs = require('fs');
  const path = require('path');
  
  const addressesPath = path.join(__dirname, '..', 'deployed-addresses.json');
  fs.writeFileSync(addressesPath, JSON.stringify(contractAddresses, null, 2));
  
  console.log(`\n💾 Адреса сохранены в файл: ${addressesPath}`);
  
  console.log("\n🎉 Деплой завершен успешно!");
  console.log("\n📝 Следующие шаги:");
  console.log("1. Скопируйте адреса контрактов в .env файл");
  console.log("2. Обновите ABI в frontend");
  console.log("3. Протестируйте функциональность");
  console.log("4. Настройте мониторинг контрактов");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Ошибка при деплое:", error);
    process.exit(1);
  });
