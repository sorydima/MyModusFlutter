import 'package:json_annotation/json_annotation.dart';

part 'web3_models.g.dart';

/// Режим подключения кошелька
enum WalletConnectionMode {
  test,      // Тестовый режим
  metamask,  // MetaMask
  walletconnect, // WalletConnect
  privatekey, // Приватный ключ
}

@JsonSerializable()
class NFTMetadata {
  final String name;
  final String description;
  final String image;
  final String externalUrl;
  final String attributes;

  NFTMetadata({
    required this.name,
    required this.description,
    required this.image,
    required this.externalUrl,
    required this.attributes,
  });

  factory NFTMetadata.fromJson(Map<String, dynamic> json) => _$NFTMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$NFTMetadataToJson(this);
}

@JsonSerializable()
class NFTModel {
  final String id;
  final String tokenId;
  final String owner;
  final String creator;
  final String tokenURI;
  final NFTMetadata? metadata;
  final bool isForSale;
  final String? price;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NFTModel({
    required this.id,
    required this.tokenId,
    required this.owner,
    required this.creator,
    required this.tokenURI,
    this.metadata,
    this.isForSale = false,
    this.price,
    required this.createdAt,
    this.updatedAt,
  });

  factory NFTModel.fromJson(Map<String, dynamic> json) => _$NFTModelFromJson(json);
  Map<String, dynamic> toJson() => _$NFTModelToJson(this);
}

@JsonSerializable()
class LoyaltyTokenModel {
  final String id;
  final String symbol;
  final String name;
  final int decimals;
  final String totalSupply;
  final String maxSupply;
  final String mintPrice;
  final bool mintingEnabled;
  final bool burningEnabled;
  final bool paused;
  final DateTime createdAt;

  LoyaltyTokenModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.totalSupply,
    required this.maxSupply,
    required this.mintPrice,
    required this.mintingEnabled,
    required this.burningEnabled,
    required this.paused,
    required this.createdAt,
  });

  factory LoyaltyTokenModel.fromJson(Map<String, dynamic> json) => _$LoyaltyTokenModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoyaltyTokenModelToJson(this);
}

@JsonSerializable()
class UserWalletInfo {
  final String address;
  final String balance;
  final String networkName;
  final int chainId;
  final bool isConnected;
  final DateTime? lastActivity;

  UserWalletInfo({
    required this.address,
    required this.balance,
    required this.networkName,
    required this.chainId,
    required this.isConnected,
    this.lastActivity,
  });

  factory UserWalletInfo.fromJson(Map<String, dynamic> json) => _$UserWalletInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserWalletInfoToJson(this);
}

@JsonSerializable()
class BlockchainTransaction {
  final String hash;
  final String from;
  final String to;
  final String value;
  final String gasUsed;
  final String gasPrice;
  final int blockNumber;
  final DateTime timestamp;
  final String status;
  final String? error;

  BlockchainTransaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.gasUsed,
    required this.gasPrice,
    required this.blockNumber,
    required this.timestamp,
    required this.status,
    this.error,
  });

  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) => _$BlockchainTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$BlockchainTransactionToJson(this);
}

@JsonSerializable()
class SmartContractInfo {
  final String address;
  final String name;
  final String network;
  final int chainId;
  final String abi;
  final DateTime deployedAt;
  final String deployer;
  final bool verified;

  SmartContractInfo({
    required this.address,
    required this.name,
    required this.network,
    required this.chainId,
    required this.abi,
    required this.deployedAt,
    required this.deployer,
    required this.verified,
  });

  factory SmartContractInfo.fromJson(Map<String, dynamic> json) => _$SmartContractInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SmartContractInfoToJson(this);
}

@JsonSerializable()
class Web3Stats {
  final int totalNFTs;
  final int totalLoyaltyTokens;
  final int totalTransactions;
  final int totalUsers;
  final String totalVolume;
  final DateTime lastUpdated;

  Web3Stats({
    required this.totalNFTs,
    required this.totalLoyaltyTokens,
    required this.totalTransactions,
    required this.totalUsers,
    required this.totalVolume,
    required this.lastUpdated,
  });

  factory Web3Stats.fromJson(Map<String, dynamic> json) => _$Web3StatsFromJson(json);
  Map<String, dynamic> toJson() => _$Web3StatsToJson(this);
}

@JsonSerializable()
class NetworkInfo {
  final String name;
  final int chainId;
  final String rpcUrl;
  final String? explorerUrl;
  final String nativeCurrency;
  final int decimals;
  final bool isTestnet;

  NetworkInfo({
    required this.name,
    required this.chainId,
    required this.rpcUrl,
    this.explorerUrl,
    required this.nativeCurrency,
    required this.decimals,
    required this.isTestnet,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) => _$NetworkInfoFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkInfoToJson(this);
}

@JsonSerializable()
class MintNFTRequest {
  final String to;
  final String tokenURI;
  final String? name;
  final String? description;
  final String? image;
  final String? externalUrl;
  final String? attributes;

  MintNFTRequest({
    required this.to,
    required this.tokenURI,
    this.name,
    this.description,
    this.image,
    this.externalUrl,
    this.attributes,
  });

  factory MintNFTRequest.fromJson(Map<String, dynamic> json) => _$MintNFTRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MintNFTRequestToJson(this);
}

@JsonSerializable()
class CreateLoyaltyTokenRequest {
  final String name;
  final String symbol;
  final int decimals;
  final String initialSupply;
  final String mintPrice;
  final String maxSupply;

  CreateLoyaltyTokenRequest({
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.initialSupply,
    required this.mintPrice,
    required this.maxSupply,
  });

  factory CreateLoyaltyTokenRequest.fromJson(Map<String, dynamic> json) => _$CreateLoyaltyTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateLoyaltyTokenRequestToJson(this);
}

@JsonSerializable()
class TransferRequest {
  final String to;
  final String amount;
  final String? tokenId; // For NFTs

  TransferRequest({
    required this.to,
    required this.amount,
    this.tokenId,
  });

  factory TransferRequest.fromJson(Map<String, dynamic> json) => _$TransferRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TransferRequestToJson(this);
}
