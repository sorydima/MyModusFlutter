require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
  
  networks: {
    // Локальная сеть для разработки
    hardhat: {
      chainId: 1337,
      accounts: {
        mnemonic: "test test test test test test test test test test test test junk",
        count: 10,
      },
    },
    
    // Локальная сеть Ganache
    ganache: {
      url: "http://127.0.0.1:8545",
      chainId: 1337,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    
    // Ethereum Sepolia тестнет
    sepolia: {
      url: process.env.SEPOLIA_URL || "https://sepolia.infura.io/v3/" + process.env.INFURA_PROJECT_ID,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
      gasPrice: 20000000000, // 20 gwei
    },
    
    // Polygon Mumbai тестнет
    mumbai: {
      url: process.env.MUMBAI_URL || "https://polygon-mumbai.infura.io/v3/" + process.env.INFURA_PROJECT_ID,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 80001,
      gasPrice: 30000000000, // 30 gwei
    },
    
    // Ethereum Mainnet (только для продакшена)
    mainnet: {
      url: process.env.MAINNET_URL || "https://mainnet.infura.io/v3/" + process.env.INFURA_PROJECT_ID,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 1,
      gasPrice: 20000000000, // 20 gwei
    },
    
    // Polygon Mainnet (только для продакшена)
    polygon: {
      url: process.env.POLYGON_URL || "https://polygon-mainnet.infura.io/v3/" + process.env.INFURA_PROJECT_ID,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 137,
      gasPrice: 30000000000, // 30 gwei
    },
  },
  
  // Настройки для верификации контрактов
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY,
      mainnet: process.env.ETHERSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
      mumbai: process.env.POLYGONSCAN_API_KEY,
    },
  },
  
  // Настройки для газовых отчетов
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    token: "ETH",
    gasPrice: 20,
  },
  
  // Настройки для покрытия кода
  coverage: {
    enabled: process.env.REPORT_COVERAGE !== undefined,
    exclude: [
      "test/",
      "scripts/",
      "hardhat.config.js",
      "coverage/",
      ".coverage/",
    ],
  },
  
  // Настройки для тестирования
  mocha: {
    timeout: 60000, // 60 секунд
  },
  
  // Настройки для компиляции
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  
  // Настройки для деплоя
  namedAccounts: {
    deployer: {
      default: 0,
      1: 0, // mainnet
      11155111: 0, // sepolia
      137: 0, // polygon
      80001: 0, // mumbai
    },
    treasury: {
      default: 1,
      1: "0x...", // mainnet treasury address
      11155111: "0x...", // sepolia treasury address
    },
    admin: {
      default: 2,
      1: "0x...", // mainnet admin address
      11155111: "0x...", // sepolia admin address
    },
  },
  
  // Настройки для форка
  forking: {
    url: process.env.FORK_URL,
    blockNumber: process.env.FORK_BLOCK_NUMBER ? parseInt(process.env.FORK_BLOCK_NUMBER) : undefined,
  },
  
  // Настройки для автоматизации
  automation: {
    enabled: process.env.AUTOMATION_ENABLED === "true",
    interval: process.env.AUTOMATION_INTERVAL || 300, // 5 минут
  },
};
