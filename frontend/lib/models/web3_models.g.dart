// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web3_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NFTMetadata _$NFTMetadataFromJson(Map<String, dynamic> json) => NFTMetadata(
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      attributes: json['attributes'] as String,
    );

Map<String, dynamic> _$NFTMetadataToJson(NFTMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'attributes': instance.attributes,
    };

NFTModel _$NFTModelFromJson(Map<String, dynamic> json) => NFTModel(
      id: json['id'] as String,
      tokenId: (json['tokenId'] as num).toInt(),
      contractAddress: json['contractAddress'] as String,
      owner: json['owner'] as String,
      metadata: json['metadata'] == null
          ? null
          : NFTMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      price: (json['price'] as num?)?.toDouble(),
      isForSale: json['isForSale'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      rarity: (json['rarity'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$NFTModelToJson(NFTModel instance) => <String, dynamic>{
      'id': instance.id,
      'tokenId': instance.tokenId,
      'contractAddress': instance.contractAddress,
      'owner': instance.owner,
      'metadata': instance.metadata,
      'price': instance.price,
      'isForSale': instance.isForSale,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'rarity': instance.rarity,
    };

LoyaltyTokenModel _$LoyaltyTokenModelFromJson(Map<String, dynamic> json) =>
    LoyaltyTokenModel(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      decimals: (json['decimals'] as num).toInt(),
      totalSupply: json['totalSupply'] as String,
      maxSupply: json['maxSupply'] as String,
      mintPrice: json['mintPrice'] as String,
      mintingEnabled: json['mintingEnabled'] as bool,
      burningEnabled: json['burningEnabled'] as bool,
      paused: json['paused'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LoyaltyTokenModelToJson(LoyaltyTokenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'name': instance.name,
      'decimals': instance.decimals,
      'totalSupply': instance.totalSupply,
      'maxSupply': instance.maxSupply,
      'mintPrice': instance.mintPrice,
      'mintingEnabled': instance.mintingEnabled,
      'burningEnabled': instance.burningEnabled,
      'paused': instance.paused,
      'createdAt': instance.createdAt.toIso8601String(),
    };

UserWalletInfo _$UserWalletInfoFromJson(Map<String, dynamic> json) =>
    UserWalletInfo(
      address: json['address'] as String,
      balance: json['balance'] as String,
      networkName: json['networkName'] as String,
      chainId: (json['chainId'] as num).toInt(),
      isConnected: json['isConnected'] as bool,
      lastActivity: json['lastActivity'] == null
          ? null
          : DateTime.parse(json['lastActivity'] as String),
    );

Map<String, dynamic> _$UserWalletInfoToJson(UserWalletInfo instance) =>
    <String, dynamic>{
      'address': instance.address,
      'balance': instance.balance,
      'networkName': instance.networkName,
      'chainId': instance.chainId,
      'isConnected': instance.isConnected,
      'lastActivity': instance.lastActivity?.toIso8601String(),
    };

BlockchainTransaction _$BlockchainTransactionFromJson(
        Map<String, dynamic> json) =>
    BlockchainTransaction(
      hash: json['hash'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      value: json['value'] as String,
      gasUsed: json['gasUsed'] as String,
      gasPrice: json['gasPrice'] as String,
      blockNumber: (json['blockNumber'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$BlockchainTransactionToJson(
        BlockchainTransaction instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'from': instance.from,
      'to': instance.to,
      'value': instance.value,
      'gasUsed': instance.gasUsed,
      'gasPrice': instance.gasPrice,
      'blockNumber': instance.blockNumber,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': instance.status,
      'error': instance.error,
    };

SmartContractInfo _$SmartContractInfoFromJson(Map<String, dynamic> json) =>
    SmartContractInfo(
      address: json['address'] as String,
      name: json['name'] as String,
      network: json['network'] as String,
      chainId: (json['chainId'] as num).toInt(),
      abi: json['abi'] as String,
      deployedAt: DateTime.parse(json['deployedAt'] as String),
      deployer: json['deployer'] as String,
      verified: json['verified'] as bool,
    );

Map<String, dynamic> _$SmartContractInfoToJson(SmartContractInfo instance) =>
    <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'network': instance.network,
      'chainId': instance.chainId,
      'abi': instance.abi,
      'deployedAt': instance.deployedAt.toIso8601String(),
      'deployer': instance.deployer,
      'verified': instance.verified,
    };

Web3Stats _$Web3StatsFromJson(Map<String, dynamic> json) => Web3Stats(
      totalNFTs: (json['totalNFTs'] as num).toInt(),
      totalLoyaltyTokens: (json['totalLoyaltyTokens'] as num).toInt(),
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      totalUsers: (json['totalUsers'] as num).toInt(),
      totalVolume: json['totalVolume'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$Web3StatsToJson(Web3Stats instance) => <String, dynamic>{
      'totalNFTs': instance.totalNFTs,
      'totalLoyaltyTokens': instance.totalLoyaltyTokens,
      'totalTransactions': instance.totalTransactions,
      'totalUsers': instance.totalUsers,
      'totalVolume': instance.totalVolume,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

NetworkInfo _$NetworkInfoFromJson(Map<String, dynamic> json) => NetworkInfo(
      name: json['name'] as String,
      chainId: (json['chainId'] as num).toInt(),
      rpcUrl: json['rpcUrl'] as String,
      explorerUrl: json['explorerUrl'] as String?,
      nativeCurrency: json['nativeCurrency'] as String,
      decimals: (json['decimals'] as num).toInt(),
      isTestnet: json['isTestnet'] as bool,
    );

Map<String, dynamic> _$NetworkInfoToJson(NetworkInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'chainId': instance.chainId,
      'rpcUrl': instance.rpcUrl,
      'explorerUrl': instance.explorerUrl,
      'nativeCurrency': instance.nativeCurrency,
      'decimals': instance.decimals,
      'isTestnet': instance.isTestnet,
    };

MintNFTRequest _$MintNFTRequestFromJson(Map<String, dynamic> json) =>
    MintNFTRequest(
      to: json['to'] as String,
      tokenURI: json['tokenURI'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      externalUrl: json['externalUrl'] as String?,
      attributes: json['attributes'] as String?,
    );

Map<String, dynamic> _$MintNFTRequestToJson(MintNFTRequest instance) =>
    <String, dynamic>{
      'to': instance.to,
      'tokenURI': instance.tokenURI,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'externalUrl': instance.externalUrl,
      'attributes': instance.attributes,
    };

CreateLoyaltyTokenRequest _$CreateLoyaltyTokenRequestFromJson(
        Map<String, dynamic> json) =>
    CreateLoyaltyTokenRequest(
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      decimals: (json['decimals'] as num).toInt(),
      initialSupply: json['initialSupply'] as String,
      mintPrice: json['mintPrice'] as String,
      maxSupply: json['maxSupply'] as String,
    );

Map<String, dynamic> _$CreateLoyaltyTokenRequestToJson(
        CreateLoyaltyTokenRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'decimals': instance.decimals,
      'initialSupply': instance.initialSupply,
      'mintPrice': instance.mintPrice,
      'maxSupply': instance.maxSupply,
    };

TransferRequest _$TransferRequestFromJson(Map<String, dynamic> json) =>
    TransferRequest(
      to: json['to'] as String,
      amount: json['amount'] as String,
      tokenId: json['tokenId'] as String?,
    );

Map<String, dynamic> _$TransferRequestToJson(TransferRequest instance) =>
    <String, dynamic>{
      'to': instance.to,
      'amount': instance.amount,
      'tokenId': instance.tokenId,
    };

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      hash: json['hash'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      value: json['value'] as String,
      gasUsed: json['gasUsed'] as String,
      gasPrice: json['gasPrice'] as String,
      blockNumber: (json['blockNumber'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      error: json['error'] as String?,
      network: json['network'] as String,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'from': instance.from,
      'to': instance.to,
      'value': instance.value,
      'gasUsed': instance.gasUsed,
      'gasPrice': instance.gasPrice,
      'blockNumber': instance.blockNumber,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'error': instance.error,
      'network': instance.network,
    };

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.confirmed: 'confirmed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.cancelled: 'cancelled',
};

const _$TransactionTypeEnumMap = {
  TransactionType.transfer: 'transfer',
  TransactionType.mint: 'mint',
  TransactionType.burn: 'burn',
  TransactionType.swap: 'swap',
  TransactionType.stake: 'stake',
  TransactionType.unstake: 'unstake',
};
