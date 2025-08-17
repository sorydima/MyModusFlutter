import 'dart:convert';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:bip39/bip39.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';
import '../models.dart';

class Web3Service {
  final Web3Client _client;
  final Logger _logger = Logger();
  
  // Contract addresses (will be set after deployment)
  String? _escrowContractAddress;
  String? _loyaltyTokenAddress;
  String? _nftContractAddress;
  
  // Contract ABIs
  late final ContractAbi _escrowAbi;
  late final ContractAbi _loyaltyTokenAbi;
  late final ContractAbi _nftAbi;
  
  Web3Service(String rpcUrl) : _client = Web3Client(rpcUrl, http.Client());
  
  /// Initialize contracts after deployment
  Future<void> initializeContracts({
    required String escrowAddress,
    required String loyaltyTokenAddress,
    required String nftContractAddress,
  }) async {
    _escrowContractAddress = escrowAddress;
    _loyaltyTokenAddress = loyaltyTokenAddress;
    _nftContractAddress = nftContractAddress;
    
    // Load contract ABIs
    await _loadContractABIs();
    
    _logger.i('Web3 contracts initialized successfully');
  }
  
  /// Load contract ABIs from files
  Future<void> _loadContractABIs() async {
    try {
      // Load ABI files (you'll need to create these)
      // В реальном приложении ABIs будут загружаться из файлов
      // Например: rootBundle.loadString('assets/abis/Escrow.json');
      _escrowAbi = ContractAbi.fromJson(
        jsonDecode(await _loadABIFile('escrow_abi.json')),
        'Escrow',
      );
      
      _loyaltyTokenAbi = ContractAbi.fromJson(
        jsonDecode(await _loadABIFile('loyalty_token_abi.json')),
        'LoyaltyToken',
      );
      
      _nftAbi = ContractAbi.fromJson(
        jsonDecode(await _loadABIFile('nft_abi.json')),
        'MyModusNFT',
      );
    } catch (e) {
      _logger.e('Error loading contract ABIs: $e');
      rethrow;
    }
  }
  
  /// Load ABI file content
  Future<String> _loadABIFile(String filename) async {
    // Временная заглушка, пока нет реальных ABI файлов
    return jsonEncode([
      // Пример минимального ABI для демонстрации
      {
        "inputs": [],
        "stateMutability": "nonpayable",
        "type": "constructor"
      },
      {
        "inputs": [
          {"internalType": "string", "name": "productId", "type": "string"},
          {"internalType": "uint256", "name": "sellerId", "type": "uint256"},
          {"internalType": "uint256", "name": "amount", "type": "uint256"}
        ],
        "name": "createEscrow",
        "outputs": [
          {"internalType": "string", "name": "", "type": "string"}
        ],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "string", "name": "escrowId", "type": "string"}
        ],
        "name": "releaseEscrow",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "to", "type": "address"},
          {"internalType": "uint256", "name": "amount", "type": "uint256"}
        ],
        "name": "mint",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "to", "type": "address"},
          {"internalType": "string", "name": "tokenURI", "type": "string"}
        ],
        "name": "mint",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ]);
  }
  
  /// Create wallet from mnemonic
  Future<EthPrivateKey> createWalletFromMnemonic(String mnemonic) async {
    try {
      if (!bip39.validateMnemonic(mnemonic)) {
        throw ArgumentError('Invalid mnemonic phrase');
      }
      
      final seed = bip39.mnemonicToSeed(mnemonic);
      final master = await ED25519_HD_KEY.getMasterKeyFromSeed(seed);
      final privateKey = master.key;
      
      return EthPrivateKey(privateKey);
    } catch (e) {
      _logger.e('Error creating wallet from mnemonic: $e');
      rethrow;
    }
  }
  
  /// Get wallet balance
  Future<EtherAmount> getBalance(EthereumAddress address) async {
    try {
      return await _client.getBalance(address);
    } catch (e) {
      _logger.e('Error getting balance for $address: $e');
      rethrow;
    }
  }
  
  /// Send transaction
  Future<String> sendTransaction({
    required EthPrivateKey fromKey,
    required EthereumAddress to,
    required EtherAmount amount,
    String? data,
  }) async {
    try {
      final fromAddress = fromKey.address;
      
      // Get current gas price
      final gasPrice = await _client.getGasPrice();
      
      // Estimate gas
      final gas = await _client.estimateGas(
        sender: fromAddress,
        to: to,
        value: amount,
        data: data != null ? Uint8List.fromList(utf8.encode(data)) : null,
      );
      
      // Create transaction
      final transaction = Transaction(
        to: to,
        value: amount,
        gasPrice: gasPrice,
        maxGas: gas.toInt(),
        data: data != null ? Uint8List.fromList(utf8.encode(data)) : null,
      );
      
      // Sign and send transaction
      final signature = await fromKey.signTransaction(transaction);
      final hash = await _client.sendRawTransaction(signature);
      
      _logger.i('Transaction sent: $hash');
      return hash;
    } catch (e) {
      _logger.e('Error sending transaction: $e');
      rethrow;
    }
  }
  
  /// Create escrow for product purchase
  Future<String> createEscrow({
    required EthPrivateKey buyerKey,
    required String productId,
    required EtherAmount amount,
    required int sellerId,
  }) async {
    try {
      if (_escrowContractAddress == null) {
        throw StateError('Escrow contract not initialized');
      }
      
      final escrowContract = DeployedContract(
        _escrowAbi,
        EthereumAddress.fromHex(_escrowContractAddress!),
      );
      
      final createEscrowFunction = escrowContract.function('createEscrow');
      
      final data = createEscrowFunction.encodeCall([
        productId,
        BigInt.from(sellerId),
        amount.getInWei,
      ]);
      
      return await sendTransaction(
        fromKey: buyerKey,
        to: EthereumAddress.fromHex(_escrowContractAddress!),
        amount: EtherAmount.zero(),
        data: data,
      );
    } catch (e) {
      _logger.e('Error creating escrow: $e');
      rethrow;
    }
  }
  
  /// Release escrow funds to seller
  Future<String> releaseEscrow({
    required EthPrivateKey buyerKey,
    required String escrowId,
  }) async {
    try {
      if (_escrowContractAddress == null) {
        throw StateError('Escrow contract not initialized');
      }
      
      final escrowContract = DeployedContract(
        _escrowAbi,
        EthereumAddress.fromHex(_escrowContractAddress!),
      );
      
      final releaseFunction = escrowContract.function('releaseEscrow');
      
      final data = releaseFunction.encodeCall([escrowId]);
      
      return await sendTransaction(
        fromKey: buyerKey,
        to: EthereumAddress.fromHex(_escrowContractAddress!),
        amount: EtherAmount.zero(),
        data: data,
      );
    } catch (e) {
      _logger.e('Error releasing escrow: $e');
      rethrow;
    }
  }
  
  /// Mint loyalty tokens
  Future<String> mintLoyaltyTokens({
    required EthPrivateKey ownerKey,
    required EthereumAddress to,
    required BigInt amount,
  }) async {
    try {
      if (_loyaltyTokenAddress == null) {
        throw StateError('Loyalty token contract not initialized');
      }
      
      final tokenContract = DeployedContract(
        _loyaltyTokenAbi,
        EthereumAddress.fromHex(_loyaltyTokenAddress!),
      );
      
      final mintFunction = tokenContract.function('mint');
      
      final data = mintFunction.encodeCall([to, amount]);
      
      return await sendTransaction(
        fromKey: ownerKey,
        to: EthereumAddress.fromHex(_loyaltyTokenAddress!),
        amount: EtherAmount.zero(),
        data: data,
      );
    } catch (e) {
      _logger.e('Error minting loyalty tokens: $e');
      rethrow;
    }
  }
  
  /// Mint NFT badge
  Future<String> mintNFTBadge({
    required EthPrivateKey ownerKey,
    required EthereumAddress to,
    required String tokenURI,
  }) async {
    try {
      if (_nftContractAddress == null) {
        throw StateError('NFT contract not initialized');
      }
      
      final nftContract = DeployedContract(
        _nftAbi,
        EthereumAddress.fromHex(_nftContractAddress!),
      );
      
      final mintFunction = nftContract.function('mint');
      
      final data = mintFunction.encodeCall([to, tokenURI]);
      
      return await sendTransaction(
        fromKey: ownerKey,
        to: EthereumAddress.fromHex(_nftContractAddress!),
        amount: EtherAmount.zero(),
        data: data,
      );
    } catch (e) {
      _logger.e('Error minting NFT badge: $e');
      rethrow;
    }
  }
  
  /// Get transaction receipt
  Future<TransactionReceipt?> getTransactionReceipt(String hash) async {
    try {
      return await _client.getTransactionReceipt(hash);
    } catch (e) {
      _logger.e('Error getting transaction receipt: $e');
      return null;
    }
  }
  
  /// Get transaction status
  Future<String> getTransactionStatus(String hash) async {
    try {
      final receipt = await getTransactionReceipt(hash);
      if (receipt == null) {
        return 'pending';
      }
      return receipt.status! ? 'success' : 'failed';
    } catch (e) {
      _logger.e('Error getting transaction status: $e');
      return 'unknown';
    }
  }
  
  /// Get token balance
  Future<BigInt> getTokenBalance({
    required String contractAddress,
    required EthereumAddress walletAddress,
  }) async {
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(
          jsonDecode(await _loadABIFile('erc20_abi.json')),
          'ERC20',
        ),
        EthereumAddress.fromHex(contractAddress),
      );
      
      final balanceFunction = contract.function('balanceOf');
      final result = await _client.call(
        contract: contract,
        function: balanceFunction,
        params: [walletAddress],
      );
      
      return result.first as BigInt;
    } catch (e) {
      _logger.e('Error getting token balance: $e');
      rethrow;
    }
  }
  
  /// Get NFT token URI
  Future<String> getNFTTokenURI({
    required String contractAddress,
    required BigInt tokenId,
  }) async {
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(
          jsonDecode(await _loadABIFile('erc721_abi.json')),
          'ERC721',
        ),
        EthereumAddress.fromHex(contractAddress),
      );
      
      final tokenURIFunction = contract.function('tokenURI');
      final result = await _client.call(
        contract: contract,
        function: tokenURIFunction,
        params: [tokenId],
      );
      
      return result.first as String;
    } catch (e) {
      _logger.e('Error getting NFT token URI: $e');
      rethrow;
    }
  }
  
  /// Cleanup resources
  void dispose() {
    _client.dispose();
  }
}
