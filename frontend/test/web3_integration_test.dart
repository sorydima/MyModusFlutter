import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:mymodus/providers/web3_provider.dart';
import 'package:mymodus/providers/auth_provider.dart';
import 'package:mymodus/config/web3_config.dart';
import 'package:mymodus/models/web3_models.dart';

void main() {
  group('Web3 Integration Tests', () {
    late Web3Provider web3Provider;
    late AuthProvider authProvider;

    setUp(() {
      web3Provider = Web3Provider();
      authProvider = AuthProvider();
    });

    tearDown(() {
      web3Provider.dispose();
      authProvider.dispose();
    });

    testWidgets('Web3Provider initializes with correct default state', (WidgetTester tester) {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Web3Provider>.value(value: web3Provider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<Web3Provider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Text('Connected: ${provider.isConnected}'),
                      Text('Wallet: ${provider.walletAddress ?? "None"}'),
                      Text('Network: ${provider.currentNetwork}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Connected: false'), findsOneWidget);
      expect(find.text('Wallet: None'), findsOneWidget);
      expect(find.text('Network: sepolia'), findsOneWidget);
    });

    testWidgets('Web3Provider can connect wallet', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Web3Provider>.value(value: web3Provider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<Web3Provider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Text('Connected: ${provider.isConnected}'),
                      Text('Wallet: ${provider.walletAddress ?? "None"}'),
                      ElevatedButton(
                        onPressed: () => provider.connectWallet('test_private_key'),
                        child: Text('Connect Wallet'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Connected: false'), findsOneWidget);
      expect(find.text('Wallet: None'), findsOneWidget);

      // Connect wallet
      await tester.tap(find.text('Connect Wallet'));
      await tester.pumpAndSettle();

      // Verify connection
      expect(find.text('Connected: true'), findsOneWidget);
      expect(find.text('Wallet: None'), findsNothing);
    });

    testWidgets('Web3Provider can mint NFT', (WidgetTester tester) async {
      // Connect wallet first
      await web3Provider.connectWallet('test_private_key');
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Web3Provider>.value(value: web3Provider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<Web3Provider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Text('NFTs: ${provider.userNFTs.length}'),
                      ElevatedButton(
                        onPressed: () => provider.mintNFT(
                          name: 'Test NFT',
                          description: 'Test Description',
                          image: 'https://test.com/image.jpg',
                          attributes: [{'trait_type': 'Type', 'value': 'Test'}],
                        ),
                        child: Text('Mint NFT'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('NFTs: 0'), findsOneWidget);

      // Mint NFT
      await tester.tap(find.text('Mint NFT'));
      await tester.pumpAndSettle();

      // Verify NFT was minted
      expect(find.text('NFTs: 1'), findsOneWidget);
    });

    testWidgets('Web3Provider can create loyalty tokens', (WidgetTester tester) async {
      // Connect wallet first
      await web3Provider.connectWallet('test_private_key');
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Web3Provider>.value(value: web3Provider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<Web3Provider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Text('Balance: ${provider.loyaltyTokenBalance}'),
                      ElevatedButton(
                        onPressed: () => provider.createLoyaltyTokens('1000000000000000000000'),
                        child: Text('Create Tokens'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Balance: 0'), findsOneWidget);

      // Create tokens
      await tester.tap(find.text('Create Tokens'));
      await tester.pumpAndSettle();

      // Verify tokens were created
      expect(find.text('Balance: 1000000000000000000000'), findsOneWidget);
    });

    testWidgets('Web3Provider handles network switching', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Web3Provider>.value(value: web3Provider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<Web3Provider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Text('Network: ${provider.currentNetwork}'),
                      ElevatedButton(
                        onPressed: () => provider.switchNetwork('mumbai'),
                        child: Text('Switch to Mumbai'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initial network
      expect(find.text('Network: sepolia'), findsOneWidget);

      // Switch network
      await tester.tap(find.text('Switch to Mumbai'));
      await tester.pumpAndSettle();

      // Verify network switched
      expect(find.text('Network: mumbai'), findsOneWidget);
    });

    testWidgets('Web3Provider shows loading states', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Web3Provider>.value(value: web3Provider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<Web3Provider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return CircularProgressIndicator();
                  }
                  return Text('Loaded');
                },
              ),
            ),
          ),
        ),
      );

      // Initially loaded
      expect(find.text('Loaded'), findsOneWidget);

      // Start loading operation
      web3Provider.setLoading(true);
      await tester.pumpAndSettle();

      // Show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Web3Provider handles errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Web3Provider>.value(value: web3Provider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<Web3Provider>(
                builder: (context, provider, child) {
                  if (provider.error != null) {
                    return Text('Error: ${provider.error}');
                  }
                  return Text('No Error');
                },
              ),
            ),
          ),
        ),
      );

      // Initially no error
      expect(find.text('No Error'), findsOneWidget);

      // Set error
      web3Provider.setError('Test error message');
      await tester.pumpAndSettle();

      // Show error
      expect(find.text('Error: Test error message'), findsOneWidget);
    });
  });

  group('Web3Config Tests', () {
    test('getContractAddress returns correct address for network', () {
      final nftAddress = Web3Config.getContractAddress('MyModusNFT', 'sepolia');
      expect(nftAddress, equals('0x1234567890123456789012345678901234567890'));

      final loyaltyAddress = Web3Config.getContractAddress('MyModusLoyalty', 'mumbai');
      expect(loyaltyAddress, equals('0x0987654321098765432109876543210987654321'));
    });

    test('getCurrentNetworkConfig returns correct config', () {
      final sepoliaConfig = Web3Config.getCurrentNetworkConfig('sepolia');
      expect(sepoliaConfig.name, equals('Sepolia Testnet'));
      expect(sepoliaConfig.chainId, equals(11155111));
      expect(sepoliaConfig.isTestnet, isTrue);

      final mainnetConfig = Web3Config.getCurrentNetworkConfig('mainnet');
      expect(mainnetConfig.name, equals('Ethereum Mainnet'));
      expect(mainnetConfig.chainId, equals(1));
      expect(mainnetConfig.isTestnet, isFalse);
    });

    test('isTestnet returns correct value', () {
      expect(Web3Config.isTestnet('sepolia'), isTrue);
      expect(Web3Config.isTestnet('mumbai'), isTrue);
      expect(Web3Config.isTestnet('mainnet'), isFalse);
      expect(Web3Config.isTestnet('polygon'), isFalse);
    });

    test('getSupportedChainIds returns all chain IDs', () {
      final chainIds = Web3Config.getSupportedChainIds();
      expect(chainIds, contains(11155111)); // Sepolia
      expect(chainIds, contains(80001)); // Mumbai
      expect(chainIds, contains(1)); // Mainnet
      expect(chainIds, contains(137)); // Polygon
    });

    test('isValidNetwork validates networks correctly', () {
      expect(Web3Config.isValidNetwork('sepolia'), isTrue);
      expect(Web3Config.isValidNetwork('mumbai'), isTrue);
      expect(Web3Config.isValidNetwork('mainnet'), isTrue);
      expect(Web3Config.isValidNetwork('polygon'), isTrue);
      expect(Web3Config.isValidNetwork('invalid'), isFalse);
    });
  });

  group('Web3 Models Tests', () {
    test('NFTModel creates correctly', () {
      final nft = NFTModel(
        tokenId: 1,
        name: 'Test NFT',
        description: 'Test Description',
        image: 'https://test.com/image.jpg',
        attributes: [{'trait_type': 'Type', 'value': 'Test'}],
        owner: '0x1234567890123456789012345678901234567890',
        mintDate: DateTime.now(),
        price: '1000000000000000000',
        isForSale: true,
      );

      expect(nft.tokenId, equals(1));
      expect(nft.name, equals('Test NFT'));
      expect(nft.owner, equals('0x1234567890123456789012345678901234567890'));
      expect(nft.isForSale, isTrue);
    });

    test('LoyaltyTokenModel creates correctly', () {
      final token = LoyaltyTokenModel(
        name: 'Test Token',
        symbol: 'TEST',
        decimals: 18,
        totalSupply: '1000000000000000000000000',
        userBalance: '100000000000000000000',
        userAddress: '0x1234567890123456789012345678901234567890',
      );

      expect(token.name, equals('Test Token'));
      expect(token.symbol, equals('TEST'));
      expect(token.decimals, equals(18));
      expect(token.userBalance, equals('100000000000000000000'));
    });

    test('UserWalletModel creates correctly', () {
      final wallet = UserWalletModel(
        address: '0x1234567890123456789012345678901234567890',
        chainId: 11155111,
        network: 'sepolia',
        isConnected: true,
        balance: '1000000000000000000000',
      );

      expect(wallet.address, equals('0x1234567890123456789012345678901234567890'));
      expect(wallet.chainId, equals(11155111));
      expect(wallet.network, equals('sepolia'));
      expect(wallet.isConnected, isTrue);
    });

    test('BlockchainTransactionModel creates correctly', () {
      final tx = BlockchainTransactionModel(
        hash: '0x1234567890123456789012345678901234567890',
        fromAddress: '0x1234567890123456789012345678901234567890',
        toAddress: '0x0987654321098765432109876543210987654321',
        value: '1000000000000000000',
        gasUsed: 150000,
        gasPrice: '20000000000',
        blockNumber: 1000000,
        timestamp: DateTime.now(),
        status: 'success',
        contractAddress: '0x1234567890123456789012345678901234567890',
        method: 'mint',
      );

      expect(tx.hash, equals('0x1234567890123456789012345678901234567890'));
      expect(tx.fromAddress, equals('0x1234567890123456789012345678901234567890'));
      expect(tx.status, equals('success'));
      expect(tx.method, equals('mint'));
    });
  });
}
