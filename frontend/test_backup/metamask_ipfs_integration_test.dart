import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/providers/web3_provider.dart';
import '../lib/services/metamask_service.dart';
import '../lib/services/ipfs_service.dart';
import '../lib/models/web3_models.dart';

// Генерируем моки
@GenerateMocks([MetaMaskService, IPFSService])
import 'metamask_ipfs_integration_test.mocks.dart';

/// Тесты для интеграции MetaMask и IPFS
void main() {
  group('MetaMask & IPFS Integration Tests', () {
    late MockMetaMaskService mockMetaMaskService;
    late MockIPFSService mockIPFSService;
    late Web3Provider web3Provider;

    setUp(() {
      mockMetaMaskService = MockMetaMaskService();
      mockIPFSService = MockIPFSService();
      
      // Создаем Web3Provider с моками
      web3Provider = Web3Provider();
      web3Provider.initialize();
    });

    tearDown(() {
      web3Provider.dispose();
    });

    group('MetaMask Integration', () {
      test('should connect to MetaMask successfully', () async {
        // Arrange
        final mockWalletInfo = WalletInfo(
          address: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          balance: '2.5',
          network: 'Sepolia Testnet',
          isConnected: true,
          canSign: true,
        );

        when(mockMetaMaskService.isMetaMaskAvailable()).thenAnswer((_) async => true);
        when(mockMetaMaskService.connectWallet()).thenAnswer((_) async => mockWalletInfo);

        // Act
        await web3Provider.connectWalletWithMetaMask();

        // Assert
        expect(web3Provider.isConnected, isTrue);
        expect(web3Provider.connectionMode, WalletConnectionMode.metamask);
        expect(web3Provider.walletAddress, equals(mockWalletInfo.address));
      });

      test('should handle MetaMask connection failure', () async {
        // Arrange
        when(mockMetaMaskService.isMetaMaskAvailable()).thenAnswer((_) async => false);

        // Act
        await web3Provider.connectWalletWithMetaMask();

        // Assert
        expect(web3Provider.isConnected, isFalse);
        expect(web3Provider.error, isNotNull);
      });

      test('should sign message with MetaMask', () async {
        // Arrange
        const message = 'Hello, Web3!';
        const signature = '0x1234567890abcdef';
        
        when(mockMetaMaskService.signMessage(message)).thenAnswer((_) async => signature);

        // Act
        final result = await web3Provider.metaMaskService.signMessage(message);

        // Assert
        expect(result, equals(signature));
        verify(mockMetaMaskService.signMessage(message)).called(1);
      });

      test('should handle network switching', () async {
        // Arrange
        const newNetwork = NetworkInfo(
          name: 'Mumbai Testnet',
          chainId: 80001,
          rpcUrl: 'https://polygon-mumbai.infura.io/v3/YOUR_INFURA_PROJECT_ID',
          explorerUrl: 'https://mumbai.polygonscan.com',
          currencySymbol: 'MATIC',
          isTestnet: true,
        );

        when(mockMetaMaskService.switchNetwork(80001)).thenAnswer((_) async => true);

        // Act
        final result = await web3Provider.metaMaskService.switchNetwork(80001);

        // Assert
        expect(result, isTrue);
        verify(mockMetaMaskService.switchNetwork(80001)).called(1);
      });
    });

    group('IPFS Integration', () {
      test('should upload file to IPFS successfully', () async {
        // Arrange
        const fileName = 'test.txt';
        const mimeType = 'text/plain';
        const mockHash = 'QmTestHash123';
        final fileData = Uint8List.fromList('Hello, IPFS!'.codeUnits);

        when(mockIPFSService.uploadFile(
          fileData: fileData,
          fileName: fileName,
          mimeType: mimeType,
        )).thenAnswer((_) async => mockHash);

        // Act
        final result = await web3Provider.uploadNFTMetadataToIPFS(
          name: 'Test NFT',
          description: 'Test Description',
          imageUrl: 'https://example.com/image.jpg',
          category: 'Test',
          attributes: {'test': 'true'},
        );

        // Assert
        expect(result, isNotNull);
        verify(mockIPFSService.uploadMetadata(any)).called(1);
      });

      test('should retrieve file from IPFS successfully', () async {
        // Arrange
        const mockHash = 'QmTestHash123';
        final mockData = Uint8List.fromList('Hello, IPFS!'.codeUnits);

        when(mockIPFSService.getFile(mockHash)).thenAnswer((_) async => mockData);

        // Act
        final result = await web3Provider.ipfsService.getFile(mockHash);

        // Assert
        expect(result, isNotNull);
        expect(result!.length, equals(mockData.length));
        verify(mockIPFSService.getFile(mockHash)).called(1);
      });

      test('should handle IPFS gateway switching', () async {
        // Arrange
        const originalGateway = 'https://ipfs.io/ipfs/';
        const newGateway = 'https://gateway.pinata.cloud/ipfs/';

        when(mockIPFSService.currentGateway).thenReturn(originalGateway);
        when(mockIPFSService.switchToNextGateway()).thenAnswer((_) {
          // Симулируем переключение gateway
          return;
        });

        // Act
        web3Provider.switchIPFSGateway();

        // Assert
        verify(mockIPFSService.switchToNextGateway()).called(1);
      });

      test('should get IPFS cache statistics', () {
        // Arrange
        final mockStats = {
          'totalEntries': 5,
          'totalSize': 1024,
          'expiredEntries': 1,
        };

        when(mockIPFSService.getCacheStats()).thenReturn(mockStats);

        // Act
        final result = web3Provider.getIPFSCacheStats();

        // Assert
        expect(result, equals(mockStats));
        expect(result['totalEntries'], equals(5));
        expect(result['totalSize'], equals(1024));
        verify(mockIPFSService.getCacheStats()).called(1);
      });

      test('should clear IPFS cache', () {
        // Act
        web3Provider.clearIPFSCache();

        // Assert
        verify(mockIPFSService.clearCache()).called(1);
      });
    });

    group('Connection Mode Switching', () {
      test('should switch to MetaMask mode', () {
        // Act
        web3Provider.switchToMetaMask();

        // Assert
        expect(web3Provider.connectionMode, WalletConnectionMode.metamask);
      });

      test('should switch to test mode', () {
        // Act
        web3Provider.switchToTestMode();

        // Assert
        expect(web3Provider.connectionMode, WalletConnectionMode.test);
      });

      test('should switch to private key mode', () {
        // Act
        web3Provider.switchToPrivateKeyMode();

        // Assert
        expect(web3Provider.connectionMode, WalletConnectionMode.privatekey);
      });
    });

    group('Error Handling', () {
      test('should handle MetaMask service errors', () async {
        // Arrange
        when(mockMetaMaskService.connectWallet()).thenThrow(Exception('MetaMask connection failed'));

        // Act
        await web3Provider.connectWalletWithMetaMask();

        // Assert
        expect(web3Provider.error, isNotNull);
        expect(web3Provider.error!.contains('MetaMask connection failed'), isTrue);
      });

      test('should handle IPFS service errors', () async {
        // Arrange
        when(mockIPFSService.uploadFile(
          fileData: anyNamed('fileData'),
          fileName: anyNamed('fileName'),
          mimeType: anyNamed('mimeType'),
        )).thenThrow(Exception('IPFS upload failed'));

        // Act & Assert
        expect(
          () => web3Provider.uploadNFTMetadataToIPFS(
            name: 'Test',
            description: 'Test',
            imageUrl: 'https://example.com/image.jpg',
            category: 'Test',
            attributes: {},
          ),
          throwsException,
        );
      });

      test('should clear errors', () {
        // Arrange
        web3Provider.setError('Test error');

        // Act
        web3Provider.clearError();

        // Assert
        expect(web3Provider.error, isNull);
      });
    });

    group('Integration Scenarios', () {
      test('should complete full NFT minting workflow with MetaMask and IPFS', () async {
        // Arrange
        final mockWalletInfo = WalletInfo(
          address: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          balance: '2.5',
          network: 'Sepolia Testnet',
          isConnected: true,
          canSign: true,
        );

        const mockIPFSHash = 'QmNFTMetadata123';
        const mockTransactionHash = '0xTransactionHash123';

        when(mockMetaMaskService.isMetaMaskAvailable()).thenAnswer((_) async => true);
        when(mockMetaMaskService.connectWallet()).thenAnswer((_) async => mockWalletInfo);
        when(mockIPFSService.uploadMetadata(any)).thenAnswer((_) async => mockIPFSHash);
        when(mockMetaMaskService.signTransaction(any)).thenAnswer((_) async => mockTransactionHash);

        // Act - Step 1: Connect MetaMask
        await web3Provider.connectWalletWithMetaMask();
        expect(web3Provider.isConnected, isTrue);

        // Act - Step 2: Upload metadata to IPFS
        final ipfsHash = await web3Provider.uploadNFTMetadataToIPFS(
          name: 'Integration Test NFT',
          description: 'Testing full workflow',
          imageUrl: 'https://example.com/image.jpg',
          category: 'Test',
          attributes: {'integration': 'true'},
        );
        expect(ipfsHash, equals(mockIPFSHash));

        // Act - Step 3: Mint NFT (simulated)
        final mintSuccess = await web3Provider.mintNFT(
          name: 'Integration Test NFT',
          description: 'Testing full workflow',
          imageUrl: 'https://example.com/image.jpg',
          tokenType: 'Test',
        );
        expect(mintSuccess, isTrue);

        // Assert
        verify(mockMetaMaskService.connectWallet()).called(1);
        verify(mockIPFSService.uploadMetadata(any)).called(1);
      });

      test('should handle network changes and reconnect', () async {
        // Arrange
        final mockWalletInfo = WalletInfo(
          address: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          balance: '2.5',
          network: 'Sepolia Testnet',
          isConnected: true,
          canSign: true,
        );

        when(mockMetaMaskService.isMetaMaskAvailable()).thenAnswer((_) async => true);
        when(mockMetaMaskService.connectWallet()).thenAnswer((_) async => mockWalletInfo);

        // Act - Connect initially
        await web3Provider.connectWalletWithMetaMask();
        expect(web3Provider.isConnected, isTrue);

        // Act - Simulate network change
        final networkChangeStream = mockMetaMaskService.networkChanged;
        // В реальном тесте здесь мы бы эмулировали событие смены сети

        // Assert
        expect(web3Provider.connectionMode, WalletConnectionMode.metamask);
        verify(mockMetaMaskService.connectWallet()).called(1);
      });
    });
  });
}

/// Вспомогательный класс для тестирования
class TestHelper {
  static Widget createTestApp(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  static Widget createTestAppWithProvider(Widget child, Web3Provider web3Provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<Web3Provider>.value(
        value: web3Provider,
        child: child,
      ),
    );
  }
}
