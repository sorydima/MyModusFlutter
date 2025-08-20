import 'package:flutter/material.dart';

class Web3Config {
  // Supported Networks
  static const Map<String, NetworkConfig> supportedNetworks = {
    'sepolia': NetworkConfig(
      name: 'Sepolia Testnet',
      chainId: 11155111,
      rpcUrl: 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://sepolia.etherscan.io',
      currencySymbol: 'ETH',
      isTestnet: true,
    ),
    'mumbai': NetworkConfig(
      name: 'Mumbai Testnet',
      chainId: 80001,
      rpcUrl: 'https://polygon-mumbai.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://mumbai.polygonscan.com',
      currencySymbol: 'MATIC',
      isTestnet: true,
    ),
    'mainnet': NetworkConfig(
      name: 'Ethereum Mainnet',
      chainId: 1,
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://etherscan.io',
      currencySymbol: 'ETH',
      isTestnet: false,
    ),
    'polygon': NetworkConfig(
      name: 'Polygon Mainnet',
      chainId: 137,
      rpcUrl: 'https://polygon-mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://polygonscan.com',
      currencySymbol: 'MATIC',
      isTestnet: false,
    ),
  };

  // Default network
  static const String defaultNetwork = 'sepolia';

  // Contract Addresses (Mock addresses for testing)
  static const Map<String, Map<String, String>> contractAddresses = {
    'sepolia': {
      'MyModusNFT': '0x1234567890123456789012345678901234567890', // Mock address
      'MyModusLoyalty': '0x0987654321098765432109876543210987654321', // Mock address
    },
    'mumbai': {
      'MyModusNFT': '0x1234567890123456789012345678901234567890', // Mock address
      'MyModusLoyalty': '0x0987654321098765432109876543210987654321', // Mock address
    },
    'mainnet': {
      'MyModusNFT': '0x1234567890123456789012345678901234567890', // Mock address
      'MyModusLoyalty': '0x0987654321098765432109876543210987654321', // Mock address
    },
    'polygon': {
      'MyModusNFT': '0x1234567890123456789012345678901234567890', // Mock address
      'MyModusLoyalty': '0x0987654321098765432109876543210987654321', // Mock address
    },
  };

  // Gas Settings
  static const Map<String, int> gasSettings = {
    'defaultGasLimit': 300000,
    'maxGasLimit': 5000000,
    'defaultGasPrice': 20000000000, // 20 Gwei
  };

  // IPFS Configuration
  static const Map<String, String> ipfsConfig = {
    'gateway': 'https://ipfs.io/ipfs/',
    'apiUrl': 'https://ipfs.infura.io:5001/api/v0',
    'pinataApiUrl': 'https://api.pinata.cloud',
    'pinataGateway': 'https://gateway.pinata.cloud/ipfs/',
  };

  // MetaMask Configuration
  static const Map<String, dynamic> metaMaskConfig = {
    'supportedChains': [11155111, 80001, 1, 137], // Sepolia, Mumbai, Mainnet, Polygon
    'chainNames': {
      11155111: 'Sepolia Testnet',
      80001: 'Mumbai Testnet',
      1: 'Ethereum Mainnet',
      137: 'Polygon Mainnet',
    },
    'rpcUrls': {
      11155111: 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      80001: 'https://polygon-mumbai.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      1: 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      137: 'https://polygon-mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
    },
    'explorerUrls': {
      11155111: 'https://sepolia.etherscan.io',
      80001: 'https://mumbai.polygonscan.com',
      1: 'https://etherscan.io',
      137: 'https://polygonscan.com',
    },
  };

  // Default NFT Parameters
  static const Map<String, dynamic> defaultNFTParams = {
    'name': 'MyModus NFT',
    'description': 'Unique digital asset from MyModus platform',
    'image': 'https://via.placeholder.com/400x400/6366f1/ffffff?text=MyModus+NFT',
    'attributes': [
      {'trait_type': 'Platform', 'value': 'MyModus'},
      {'trait_type': 'Type', 'value': 'Digital Asset'},
      {'trait_type': 'Rarity', 'value': 'Common'},
    ],
  };

  // Default Loyalty Token Parameters
  static const Map<String, dynamic> defaultLoyaltyParams = {
    'name': 'MyModus Loyalty Token',
    'symbol': 'MMLT',
    'decimals': 18,
    'initialSupply': '1000000000000000000000000', // 1,000,000 tokens
    'mintPrice': '100000000000000000', // 0.1 ETH
  };

  // Get contract address for current network
  static String getContractAddress(String contractName, String network) {
    return contractAddresses[network]?[contractName] ?? 
           contractAddresses[defaultNetwork]?[contractName] ?? 
           '0x0000000000000000000000000000000000000000';
  }

  // Get current network config
  static NetworkConfig getCurrentNetworkConfig(String network) {
    return supportedNetworks[network] ?? supportedNetworks[defaultNetwork]!;
  }

  // Check if network is testnet
  static bool isTestnet(String network) {
    return supportedNetworks[network]?.isTestnet ?? true;
  }

  // Get supported chain IDs
  static List<int> getSupportedChainIds() {
    return supportedNetworks.values.map((n) => n.chainId).toList();
  }

  // Validate network
  static bool isValidNetwork(String network) {
    return supportedNetworks.containsKey(network);
  }
}

class NetworkConfig {
  final String name;
  final int chainId;
  final String rpcUrl;
  final String explorerUrl;
  final String currencySymbol;
  final bool isTestnet;

  const NetworkConfig({
    required this.name,
    required this.chainId,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.currencySymbol,
    required this.isTestnet,
  });

  @override
  String toString() {
    return 'NetworkConfig(name: $name, chainId: $chainId, currencySymbol: $currencySymbol, isTestnet: $isTestnet)';
  }
}
