import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../models/web3_models.dart';

class Web3Service {
  static const String _nftContractAbiPath = 'assets/abi/MyModusNFT.json';
  static const String _loyaltyContractAbiPath = 'assets/abi/MyModusLoyalty.json';
  
  late Web3Client _client;
  late DeployedContract _nftContract;
  late DeployedContract _loyaltyContract;
  
  String? _nftContractAddress;
  String? _loyaltyContractAddress;
  Credentials? _credentials;
  
  bool _isInitialized = false;
  
  // Supported networks
  static const Map<int, NetworkInfo> _supportedNetworks = {
    1: NetworkInfo(
      name: 'Ethereum Mainnet',
      chainId: 1,
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://etherscan.io',
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: false,
    ),
    11155111: NetworkInfo(
      name: 'Sepolia Testnet',
      chainId: 11155111,
      rpcUrl: 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://sepolia.etherscan.io',
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: true,
    ),
    80001: NetworkInfo(
      name: 'Mumbai Testnet',
      chainId: 80001,
      rpcUrl: 'https://polygon-mumbai.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://mumbai.polygonscan.com',
      nativeCurrency: 'MATIC',
      decimals: 18,
      isTestnet: true,
    ),
    1337: NetworkInfo(
      name: 'Local Ganache',
      chainId: 1337,
      rpcUrl: 'http://127.0.0.1:7545',
      explorerUrl: null,
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: true,
    ),
  };

  Future<void> initialize({
    required String rpcUrl,
    String? nftContractAddress,
    String? loyaltyContractAddress,
  }) async {
    try {
      _client = Web3Client(rpcUrl, http.Client());
      
      if (nftContractAddress != null) {
        _nftContractAddress = nftContractAddress;
        await _loadNFTContract();
      }
      
      if (loyaltyContractAddress != null) {
        _loyaltyContractAddress = loyaltyContractAddress;
        await _loadLoyaltyContract();
      }
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Web3Service: $e');
    }
  }

  Future<void> _loadNFTContract() async {
    try {
      final abiString = await rootBundle.loadString(_nftContractAbiPath);
      final abi = jsonDecode(abiString) as List<dynamic>;
      _nftContract = DeployedContract(
        ContractAbi.fromJson(abi, 'MyModusNFT'),
        EthereumAddress.fromHex(_nftContractAddress!),
      );
    } catch (e) {
      throw Exception('Failed to load NFT contract: $e');
    }
  }

  Future<void> _loadLoyaltyContract() async {
    try {
      final abiString = await rootBundle.loadString(_loyaltyContractAbiPath);
      final abi = jsonDecode(abiString) as List<dynamic>;
      _loyaltyContract = DeployedContract(
        ContractAbi.fromJson(abi, 'MyModusLoyalty'),
        EthereumAddress.fromHex(_loyaltyContractAddress!),
      );
    } catch (e) {
      throw Exception('Failed to load Loyalty contract: $e');
    }
  }

  Future<void> connectWallet(String privateKey) async {
    try {
      _credentials = EthPrivateKey.fromHex(privateKey);
    } catch (e) {
      throw Exception('Invalid private key: $e');
    }
  }

  Future<void> disconnectWallet() async {
    _credentials = null;
  }

  Future<String> getWalletAddress() async {
    if (_credentials == null) {
      throw Exception('Wallet not connected');
    }
    return _credentials!.address.hex;
  }

  Future<String> getBalance() async {
    if (_credentials == null) {
      throw Exception('Wallet not connected');
    }
    
    final balance = await _client.getBalance(_credentials!.address);
    return balance.getValueInUnit(EtherUnit.ether).toString();
  }

  Future<NetworkInfo> getCurrentNetwork() async {
    final chainId = await _client.getChainId();
    return _supportedNetworks[chainId] ?? 
           NetworkInfo(
             name: 'Unknown Network',
             chainId: chainId,
             rpcUrl: '',
             nativeCurrency: 'ETH',
             decimals: 18,
             isTestnet: false,
           );
  }

  // NFT Functions
  Future<String> mintNFT(MintNFTRequest request) async {
    if (_credentials == null) {
      throw Exception('Wallet not connected');
    }
    if (_nftContractAddress == null) {
      throw Exception('NFT contract not loaded');
    }

    try {
      final mintFunction = _nftContract.function('mintNFT');
      final toAddress = EthereumAddress.fromHex(request.to);
      
      final result = await _client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _nftContract,
          function: mintFunction,
          params: [toAddress, request.tokenURI],
        ),
        chainId: await _client.getChainId(),
      );
      
      return result;
    } catch (e) {
      throw Exception('Failed to mint NFT: $e');
    }
  }

  Future<List<String>> getUserNFTs(String userAddress) async {
    if (_nftContractAddress == null) {
      throw Exception('NFT contract not loaded');
    }

    try {
      final getUserNFTsFunction = _nftContract.function('getUserNFTs');
      final address = EthereumAddress.fromHex(userAddress);
      
      final result = await _client.call(
        contract: _nftContract,
        function: getUserNFTsFunction,
        params: [address],
      );
      
      return (result.first as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    } catch (e) {
      throw Exception('Failed to get user NFTs: $e');
    }
  }

  Future<NFTMetadata?> getNFTMetadata(String tokenId) async {
    if (_nftContractAddress == null) {
      throw Exception('NFT contract not loaded');
    }

    try {
      final getMetadataFunction = _nftContract.function('getNFTMetadata');
      final tokenIdBigInt = BigInt.parse(tokenId);
      
      final result = await _client.call(
        contract: _nftContract,
        function: getMetadataFunction,
        params: [tokenIdBigInt],
      );
      
      if (result.first != null) {
        final metadata = result.first as List<dynamic>;
        return NFTMetadata(
          name: metadata[0] as String,
          description: metadata[1] as String,
          image: metadata[2] as String,
          externalUrl: metadata[3] as String,
          attributes: metadata[4] as String,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get NFT metadata: $e');
    }
  }

  Future<void> putNFTForSale(String tokenId, String price) async {
    if (_credentials == null) {
      throw Exception('Wallet not connected');
    }
    if (_nftContractAddress == null) {
      throw Exception('NFT contract not loaded');
    }

    try {
      final putForSaleFunction = _nftContract.function('putForSale');
      final tokenIdBigInt = BigInt.parse(tokenId);
      final priceWei = BigInt.parse(price);
      
      await _client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _nftContract,
          function: putForSaleFunction,
          params: [tokenIdBigInt, priceWei],
        ),
        chainId: await _client.getChainId(),
      );
    } catch (e) {
      throw Exception('Failed to put NFT for sale: $e');
    }
  }

  Future<void> buyNFT(String tokenId, String price) async {
    if (_credentials == null) {
      throw Exception('Wallet not connected');
    }
    if (_nftContractAddress == null) {
      throw Exception('NFT contract not loaded');
    }

    try {
      final buyNFTFunction = _nftContract.function('buyNFT');
      final tokenIdBigInt = BigInt.parse(tokenId);
      final priceWei = BigInt.parse(price);
      
      await _client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _nftContract,
          function: buyNFTFunction,
          params: [tokenIdBigInt],
          value: EtherAmount.fromWei(priceWei, EtherUnit.wei),
        ),
        chainId: await _client.getChainId(),
      );
    } catch (e) {
      throw Exception('Failed to buy NFT: $e');
    }
  }

  // Loyalty Token Functions
  Future<String> createLoyaltyToken(CreateLoyaltyTokenRequest request) async {
    if (_credentials == null) {
      throw Exception('Wallet not connected');
    }
    if (_loyaltyContractAddress == null) {
      throw Exception('Loyalty contract not loaded');
    }

    try {
      final createFunction = _loyaltyContract.function('createLoyaltyToken');
      final initialSupply = BigInt.parse(request.initialSupply);
      final mintPrice = BigInt.parse(request.mintPrice);
      final maxSupply = BigInt.parse(request.maxSupply);
      
      final result = await _client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _loyaltyContract,
          function: createFunction,
          params: [
            request.name,
            request.symbol,
            request.decimals,
            initialSupply,
            mintPrice,
            maxSupply,
          ],
        ),
        chainId: await _client.getChainId(),
      );
      
      return result;
    } catch (e) {
      throw Exception('Failed to create loyalty token: $e');
    }
  }

  Future<String> mintLoyaltyTokens(String amount) async {
    if (_credentials == null) {
      throw Exception('Wallet not connected');
    }
    if (_loyaltyContractAddress == null) {
      throw Exception('Loyalty contract not loaded');
    }

    try {
      final mintFunction = _loyaltyContract.function('mintWithETH');
      final amountBigInt = BigInt.parse(amount);
      final address = _credentials!.address;
      
      final result = await _client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _loyaltyContract,
          function: mintFunction,
          params: [address, amountBigInt],
        ),
        chainId: await _client.getChainId(),
      );
      
      return result;
    } catch (e) {
      throw Exception('Failed to mint loyalty tokens: $e');
    }
  }

  Future<String> getLoyaltyTokenBalance(String userAddress) async {
    if (_loyaltyContractAddress == null) {
      throw Exception('Loyalty contract not loaded');
    }

    try {
      final balanceFunction = _loyaltyContract.function('balanceOf');
      final address = EthereumAddress.fromHex(userAddress);
      
      final result = await _client.call(
        contract: _loyaltyContract,
        function: balanceFunction,
        params: [address],
      );
      
      return result.first.toString();
    } catch (e) {
      throw Exception('Failed to get loyalty token balance: $e');
    }
  }

  Future<void> transferLoyaltyTokens(TransferRequest request) async {
    if (_credentials == null) {
      throw Exception('Wallet not connected');
    }
    if (_loyaltyContractAddress == null) {
      throw Exception('Loyalty contract not loaded');
    }

    try {
      final transferFunction = _loyaltyContract.function('transfer');
      final toAddress = EthereumAddress.fromHex(request.to);
      final amountBigInt = BigInt.parse(request.amount);
      
      await _client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _loyaltyContract,
          function: transferFunction,
          params: [toAddress, amountBigInt],
        ),
        chainId: await _client.getChainId(),
      );
    } catch (e) {
      throw Exception('Failed to transfer loyalty tokens: $e');
    }
  }

  // Utility Functions
  Future<BlockchainTransaction> getTransaction(String hash) async {
    try {
      final transaction = await _client.getTransactionByHash(hash);
      final receipt = await _client.getTransactionReceipt(hash);
      
      if (transaction == null) {
        throw Exception('Transaction not found');
      }
      
      return BlockchainTransaction(
        hash: hash,
        from: transaction.from?.hex ?? '',
        to: transaction.to?.hex ?? '',
        value: transaction.value?.getValueInUnit(EtherUnit.ether).toString() ?? '0',
        gasUsed: receipt?.gasUsed.toString() ?? '0',
        gasPrice: transaction.gasPrice?.getValueInUnit(EtherUnit.gwei).toString() ?? '0',
        blockNumber: receipt?.blockNumber ?? 0,
        timestamp: DateTime.now(), // Note: This would need a separate call to get actual timestamp
        status: receipt?.status == 1 ? 'success' : 'failed',
        error: receipt?.status == 0 ? 'Transaction failed' : null,
      );
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  Future<Web3Stats> getWeb3Stats() async {
    try {
      int totalNFTs = 0;
      int totalLoyaltyTokens = 0;
      int totalTransactions = 0;
      int totalUsers = 0;
      String totalVolume = '0';

      if (_nftContractAddress != null) {
        try {
          final statsFunction = _nftContract.function('getStats');
          final nftStats = await _client.call(
            contract: _nftContract,
            function: statsFunction,
            params: [],
          );
          totalNFTs = (nftStats.first as List<dynamic>)[0].toInt();
        } catch (e) {
          // Contract might not have getStats function
        }
      }

      if (_loyaltyContractAddress != null) {
        try {
          final statsFunction = _loyaltyContract.function('getStats');
          final loyaltyStats = await _client.call(
            contract: _loyaltyContract,
            function: statsFunction,
            params: [],
          );
          totalLoyaltyTokens = (loyaltyStats.first as List<dynamic>)[0].toInt();
        } catch (e) {
          // Contract might not have getStats function
        }
      }

      return Web3Stats(
        totalNFTs: totalNFTs,
        totalLoyaltyTokens: totalLoyaltyTokens,
        totalTransactions: totalTransactions,
        totalUsers: totalUsers,
        totalVolume: totalVolume,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get Web3 stats: $e');
    }
  }

  bool get isInitialized => _isInitialized;
  bool get isConnected => _credentials != null;
  String? get nftContractAddress => _nftContractAddress;
  String? get loyaltyContractAddress => _loyaltyContractAddress;
  
  static Map<int, NetworkInfo> get supportedNetworks => _supportedNetworks;

  void dispose() {
    _client.dispose();
  }
}
