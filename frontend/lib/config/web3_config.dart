class Web3Config {
  // Network configurations
  static const Map<String, NetworkConfig> networks = {
    'hardhat': NetworkConfig(
      name: 'Hardhat Local',
      chainId: 31337,
      rpcUrl: 'http://127.0.0.1:8545',
      explorerUrl: null,
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: true,
    ),
    'ganache': NetworkConfig(
      name: 'Ganache Local',
      chainId: 1337,
      rpcUrl: 'http://127.0.0.1:7545',
      explorerUrl: null,
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: true,
    ),
    'sepolia': NetworkConfig(
      name: 'Sepolia Testnet',
      chainId: 11155111,
      rpcUrl: 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://sepolia.etherscan.io',
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: true,
    ),
    'mumbai': NetworkConfig(
      name: 'Mumbai Testnet',
      chainId: 80001,
      rpcUrl: 'https://polygon-mumbai.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://mumbai.polygonscan.com',
      nativeCurrency: 'MATIC',
      decimals: 18,
      isTestnet: true,
    ),
    'mainnet': NetworkConfig(
      name: 'Ethereum Mainnet',
      chainId: 1,
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://etherscan.io',
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: false,
    ),
    'polygon': NetworkConfig(
      name: 'Polygon Mainnet',
      chainId: 137,
      rpcUrl: 'https://polygon-rpc.com',
      explorerUrl: 'https://polygonscan.com',
      nativeCurrency: 'MATIC',
      decimals: 18,
      isTestnet: false,
    ),
  };

  // Default network for development
  static const String defaultNetwork = 'hardhat';

  // Contract addresses (will be updated after deployment)
  static const Map<String, Map<String, String>> contractAddresses = {
    'hardhat': {
      'MyModusNFT': '0x0000000000000000000000000000000000000000',
      'MyModusLoyalty': '0x0000000000000000000000000000000000000000',
    },
    'ganache': {
      'MyModusNFT': '0x0000000000000000000000000000000000000000',
      'MyModusLoyalty': '0x0000000000000000000000000000000000000000',
    },
    'sepolia': {
      'MyModusNFT': '0x0000000000000000000000000000000000000000',
      'MyModusLoyalty': '0x0000000000000000000000000000000000000000',
    },
    'mumbai': {
      'MyModusNFT': '0x0000000000000000000000000000000000000000',
      'MyModusLoyalty': '0x0000000000000000000000000000000000000000',
    },
  };

  // Gas settings
  static const Map<String, GasConfig> gasConfigs = {
    'hardhat': GasConfig(
      gasLimit: 5000000,
      gasPrice: '20000000000', // 20 gwei
      maxFeePerGas: '20000000000',
      maxPriorityFeePerGas: '2000000000',
    ),
    'ganache': GasConfig(
      gasLimit: 5000000,
      gasPrice: '20000000000',
      maxFeePerGas: '20000000000',
      maxPriorityFeePerGas: '2000000000',
    ),
    'sepolia': GasConfig(
      gasLimit: 5000000,
      gasPrice: '20000000000',
      maxFeePerGas: '20000000000',
      maxPriorityFeePerGas: '2000000000',
    ),
    'mumbai': GasConfig(
      gasLimit: 5000000,
      gasPrice: '30000000000', // 30 gwei
      maxFeePerGas: '30000000000',
      maxPriorityFeePerGas: '3000000000',
    ),
  };

  // IPFS configuration
  static const IPFSConfig ipfsConfig = IPFSConfig(
    gateway: 'https://ipfs.io/ipfs/',
    apiUrl: 'https://ipfs.infura.io:5001/api/v0',
    projectId: 'YOUR_IPFS_PROJECT_ID',
    projectSecret: 'YOUR_IPFS_PROJECT_SECRET',
  );

  // MetaMask configuration
  static const MetaMaskConfig metaMaskConfig = MetaMaskConfig(
    appName: 'MyModus',
    appUrl: 'https://mymodus.com',
    appIcon: 'https://mymodus.com/icon.png',
    appDescription: 'MyModus - Fashion Social Commerce App',
  );

  // NFT configuration
  static const NFTConfig nftConfig = NFTConfig(
    name: 'MyModus NFT Collection',
    symbol: 'MMNFT',
    baseURI: 'ipfs://',
    maxSupply: 10000,
    mintPrice: '100000000000000000', // 0.1 ETH
  );

  // Loyalty token configuration
  static const LoyaltyTokenConfig loyaltyConfig = LoyaltyTokenConfig(
    name: 'MyModus Loyalty Token',
    symbol: 'MMLT',
    decimals: 18,
    initialSupply: '1000000000000000000000000', // 1,000,000 tokens
    mintPrice: '100000000000000000', // 0.1 ETH
    maxSupply: '10000000000000000000000000', // 10,000,000 tokens
  );

  // Get network config by chain ID
  static NetworkConfig? getNetworkByChainId(int chainId) {
    for (final network in networks.values) {
      if (network.chainId == chainId) {
        return network;
      }
    }
    return null;
  }

  // Get contract address for network and contract
  static String? getContractAddress(String network, String contract) {
    return contractAddresses[network]?[contract];
  }

  // Get gas config for network
  static GasConfig? getGasConfig(String network) {
    return gasConfigs[network];
  }
}

class NetworkConfig {
  final String name;
  final int chainId;
  final String rpcUrl;
  final String? explorerUrl;
  final String nativeCurrency;
  final int decimals;
  final bool isTestnet;

  const NetworkConfig({
    required this.name,
    required this.chainId,
    required this.rpcUrl,
    this.explorerUrl,
    required this.nativeCurrency,
    required this.decimals,
    required this.isTestnet,
  });
}

class GasConfig {
  final int gasLimit;
  final String gasPrice;
  final String maxFeePerGas;
  final String maxPriorityFeePerGas;

  const GasConfig({
    required this.gasLimit,
    required this.gasPrice,
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
  });
}

class IPFSConfig {
  final String gateway;
  final String apiUrl;
  final String projectId;
  final String projectSecret;

  const IPFSConfig({
    required this.gateway,
    required this.apiUrl,
    required this.projectId,
    required this.projectSecret,
  });
}

class MetaMaskConfig {
  final String appName;
  final String appUrl;
  final String appIcon;
  final String appDescription;

  const MetaMaskConfig({
    required this.appName,
    required this.appUrl,
    required this.appIcon,
    required this.appDescription,
  });
}

class NFTConfig {
  final String name;
  final String symbol;
  final String baseURI;
  final int maxSupply;
  final String mintPrice;

  const NFTConfig({
    required this.name,
    required this.symbol,
    required this.baseURI,
    required this.maxSupply,
    required this.mintPrice,
  });
}

class LoyaltyTokenConfig {
  final String name;
  final String symbol;
  final int decimals;
  final String initialSupply;
  final String mintPrice;
  final String maxSupply;

  const LoyaltyTokenConfig({
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.initialSupply,
    required this.mintPrice,
    required this.maxSupply,
  });
}
