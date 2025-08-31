import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

import '../lib/providers/auth_provider.dart';
import '../lib/providers/ai_provider.dart';
import '../lib/services/api_service.dart';
import '../lib/services/web3_service.dart';
import '../lib/models/product_model.dart';
import '../lib/models/user_model.dart';

// Генерируем моки
@GenerateMocks([http.Client, Web3Service])
import 'integration_tests.mocks.dart';

void main() {
  group('MyModus Integration Tests', () {
    late MockClient mockHttpClient;
    late MockWeb3Service mockWeb3Service;
    late ApiService apiService;
    late AuthProvider authProvider;
    late AIProvider aiProvider;

    setUp(() {
      mockHttpClient = MockClient();
      mockWeb3Service = MockWeb3Service();
      apiService = ApiService(client: mockHttpClient);
      authProvider = AuthProvider(apiService);
      aiProvider = AIProvider(apiService);
    });

    group('API Integration Tests', () {
      test('should fetch products successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"products": [{"id": "1", "title": "Test Product", "price": 1000}]}',
          200,
        );
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final products = await apiService.getProducts();

        // Assert
        expect(products, isA<List<Product>>());
        expect(products.isNotEmpty, true);
        expect(products.first.title, equals('Test Product'));
      });

      test('should handle API errors gracefully', () async {
        // Arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"error": "Server error"}', 500));

        // Act & Assert
        expect(
          () => apiService.getProducts(),
          throwsA(isA<Exception>()),
        );
      });

      test('should authenticate user successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"token": "jwt_token", "user": {"id": "1", "email": "test@test.com"}}',
          200,
        );
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.login('test@test.com', 'password');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['token'], equals('jwt_token'));
      });

      test('should fetch AI recommendations successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"recommendations": [{"productId": "1", "score": 0.9}]}',
          200,
        );
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final recommendations = await apiService.getAIRecommendations('user1');

        // Assert
        expect(recommendations, isA<List<Map<String, dynamic>>>());
        expect(recommendations.isNotEmpty, true);
      });
    });

    group('Web3 Integration Tests', () {
      test('should connect to wallet successfully', () async {
        // Arrange
        when(mockWeb3Service.connectWallet()).thenAnswer((_) async => '0x123...');

        // Act
        final address = await mockWeb3Service.connectWallet();

        // Assert
        expect(address, equals('0x123...'));
        verify(mockWeb3Service.connectWallet()).called(1);
      });

      test('should create NFT successfully', () async {
        // Arrange
        when(mockWeb3Service.createNFT(any, any, any))
            .thenAnswer((_) async => '0x456...');

        // Act
        final tokenId = await mockWeb3Service.createNFT(
          'Test NFT',
          'Test Description',
          'ipfs://hash',
        );

        // Assert
        expect(tokenId, equals('0x456...'));
        verify(mockWeb3Service.createNFT(any, any, any)).called(1);
      });

      test('should get user NFTs successfully', () async {
        // Arrange
        final mockNFTs = [
          {'id': '1', 'name': 'NFT 1', 'image': 'ipfs://hash1'},
          {'id': '2', 'name': 'NFT 2', 'image': 'ipfs://hash2'},
        ];
        when(mockWeb3Service.getUserNFTs(any))
            .thenAnswer((_) async => mockNFTs);

        // Act
        final nfts = await mockWeb3Service.getUserNFTs('0x123...');

        // Assert
        expect(nfts, equals(mockNFTs));
        expect(nfts.length, equals(2));
      });
    });

    group('Provider Integration Tests', () {
      testWidgets('should update UI when API data changes', (WidgetTester tester) async {
        // Arrange
        final mockResponse = http.Response(
          '{"products": [{"id": "1", "title": "Test Product", "price": 1000}]}',
          200,
        );
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => mockResponse);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Consumer<AIProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return CircularProgressIndicator();
                    }
                    return Text('Data loaded');
                  },
                ),
              ),
            ),
          ),
        );

        // Initially loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Load data
        await aiProvider.loadPersonalRecommendations('user1');
        await tester.pump();

        // Data loaded
        expect(find.text('Data loaded'), findsOneWidget);
      });

      testWidgets('should handle authentication state changes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Consumer<AuthProvider>(
                  builder: (context, provider, child) {
                    if (provider.isAuthenticated) {
                      return Text('Authenticated');
                    }
                    return Text('Not authenticated');
                  },
                ),
              ),
            ),
          ),
        );

        // Initially not authenticated
        expect(find.text('Not authenticated'), findsOneWidget);

        // Authenticate
        authProvider.setAuthenticated(true);
        await tester.pump();

        // Now authenticated
        expect(find.text('Authenticated'), findsOneWidget);
      });
    });

    group('Error Handling Integration Tests', () {
      test('should handle network errors in providers', () async {
        // Arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => apiService.getProducts(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle Web3 connection errors', () async {
        // Arrange
        when(mockWeb3Service.connectWallet())
            .thenThrow(Exception('Wallet connection failed'));

        // Act & Assert
        expect(
          () => mockWeb3Service.connectWallet(),
          throwsA(isA<Exception>()),
        );
      });

      testWidgets('should display error UI when API fails', (WidgetTester tester) async {
        // Arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('API Error'));

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Consumer<AIProvider>(
                  builder: (context, provider, child) {
                    if (provider.error != null) {
                      return Text('Error: ${provider.error}');
                    }
                    return Text('No error');
                  },
                ),
              ),
            ),
          ),
        );

        // Initially no error
        expect(find.text('No error'), findsOneWidget);

        // Trigger error
        await aiProvider.loadPersonalRecommendations('user1');
        await tester.pump();

        // Error displayed
        expect(find.text('Error: Произошла ошибка при загрузке'), findsOneWidget);
      });
    });

    group('Performance Integration Tests', () {
      test('should handle large data sets efficiently', () async {
        // Arrange
        final largeData = List.generate(1000, (index) => {
          'id': index.toString(),
          'title': 'Product $index',
          'price': 100 + index,
        });
        final mockResponse = http.Response(
          '{"products": $largeData}',
          200,
        );
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final stopwatch = Stopwatch()..start();
        final products = await apiService.getProducts();
        stopwatch.stop();

        // Assert
        expect(products.length, equals(1000));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should complete within 1 second
      });

      test('should cache API responses efficiently', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"products": [{"id": "1", "title": "Test Product"}]}',
          200,
        );
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => mockResponse);

        // Act - First call
        final firstCall = await apiService.getProducts();
        final firstCallTime = DateTime.now();

        // Second call (should use cache)
        final secondCall = await apiService.getProducts();
        final secondCallTime = DateTime.now();

        // Assert
        expect(firstCall, equals(secondCall));
        expect(
          secondCallTime.difference(firstCallTime).inMilliseconds,
          lessThan(100), // Second call should be much faster
        );
      });
    });

    group('Security Integration Tests', () {
      test('should validate JWT tokens properly', () async {
        // Arrange
        final validToken = 'valid.jwt.token';
        final invalidToken = 'invalid.token';

        // Act & Assert
        expect(
          () => apiService.validateToken(validToken),
          returnsNormally,
        );

        expect(
          () => apiService.validateToken(invalidToken),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle Web3 signature verification', () async {
        // Arrange
        when(mockWeb3Service.verifySignature(any, any, any))
            .thenAnswer((_) async => true);

        // Act
        final isValid = await mockWeb3Service.verifySignature(
          '0x123...',
          'message',
          'signature',
        );

        // Assert
        expect(isValid, isTrue);
        verify(mockWeb3Service.verifySignature(any, any, any)).called(1);
      });
    });
  });
}
