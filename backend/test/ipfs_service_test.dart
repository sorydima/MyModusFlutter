import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import '../lib/services/ipfs_service.dart';
import '../lib/models/ipfs_models.dart';

// Генерируем моки
@GenerateMocks([http.Client])
import 'ipfs_service_test.mocks.dart';

void main() {
  group('IPFSService Tests', () {
    late IPFSService ipfsService;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      ipfsService = IPFSService(
        ipfsNodeUrl: 'http://localhost:5001',
        ipfsGatewayUrl: 'http://localhost:8080/ipfs',
        httpClient: mockHttpClient,
      );
    });

    group('uploadFile', () {
      test('should upload file successfully', () async {
        // Arrange
        final fileData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final fileName = 'test.jpg';
        final mockResponse = http.Response(
          '{"Hash": "QmTestHash123", "Size": 5}',
          200,
        );

        when(mockHttpClient.send(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.uploadFile(
          fileData: fileData,
          fileName: fileName,
          contentType: 'image/jpeg',
        );

        // Assert
        expect(result, equals('QmTestHash123'));
        verify(mockHttpClient.send(any)).called(1);
      });

      test('should handle upload error', () async {
        // Arrange
        final fileData = Uint8List.fromList([1, 2, 3]);
        final fileName = 'test.jpg';
        final mockResponse = http.Response('{"error": "Upload failed"}', 500);

        when(mockHttpClient.send(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => ipfsService.uploadFile(
            fileData: fileData,
            fileName: fileName,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('uploadMetadata', () {
      test('should upload metadata successfully', () async {
        // Arrange
        final metadata = {'name': 'Test', 'description': 'Test description'};
        final mockResponse = http.Response(
          '{"Hash": "QmMetadataHash123", "Size": 50}',
          200,
        );

        when(mockHttpClient.send(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.uploadMetadata(
          metadata: metadata,
          fileName: 'metadata.json',
        );

        // Assert
        expect(result, equals('QmMetadataHash123'));
        verify(mockHttpClient.send(any)).called(1);
      });
    });

    group('uploadNFTMetadata', () {
      test('should upload NFT metadata successfully', () async {
        // Arrange
        final attributes = [
          {'trait_type': 'Rarity', 'value': 'Common'},
          {'trait_type': 'Type', 'value': 'Badge'},
        ];
        final mockResponse = http.Response(
          '{"Hash": "QmNFTHash123", "Size": 100}',
          200,
        );

        when(mockHttpClient.send(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.uploadNFTMetadata(
          name: 'Test NFT',
          description: 'Test NFT description',
          imageUrl: 'ipfs://QmImageHash',
          attributes: attributes,
        );

        // Assert
        expect(result, equals('QmNFTHash123'));
        verify(mockHttpClient.send(any)).called(1);
      });
    });

    group('getFile', () {
      test('should get file successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          'file content',
          200,
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.getFile('QmTestHash');

        // Assert
        expect(result, equals(mockResponse.bodyBytes));
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should handle file not found', () async {
        // Arrange
        final mockResponse = http.Response('Not found', 404);

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => ipfsService.getFile('QmInvalidHash'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getMetadata', () {
      test('should get metadata successfully', () async {
        // Arrange
        final metadata = {'name': 'Test', 'description': 'Test description'};
        final mockResponse = http.Response(
          '{"name": "Test", "description": "Test description"}',
          200,
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.getMetadata('QmMetadataHash');

        // Assert
        expect(result, equals(metadata));
        verify(mockHttpClient.get(any)).called(1);
      });
    });

    group('getNFTMetadata', () {
      test('should get NFT metadata successfully', () async {
        // Arrange
        final metadata = {
          'name': 'Test NFT',
          'description': 'Test description',
          'image': 'ipfs://QmImageHash',
          'attributes': [
            {'trait_type': 'Rarity', 'value': 'Common'},
          ],
        };
        final mockResponse = http.Response(
          '{"name": "Test NFT", "description": "Test description", "image": "ipfs://QmImageHash", "attributes": [{"trait_type": "Rarity", "value": "Common"}]}',
          200,
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.getNFTMetadata('QmNFTHash');

        // Assert
        expect(result['name'], equals('Test NFT'));
        expect(result['image'], equals('ipfs://QmImageHash'));
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should validate NFT metadata format', () async {
        // Arrange
        final invalidMetadata = {
          'description': 'Test description',
          // Missing 'name' and 'image'
        };
        final mockResponse = http.Response(
          '{"description": "Test description"}',
          200,
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => ipfsService.getNFTMetadata('QmInvalidHash'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('isFileAvailable', () {
      test('should return true for available file', () async {
        // Arrange
        final mockResponse = http.Response('', 200);

        when(mockHttpClient.head(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.isFileAvailable('QmTestHash');

        // Assert
        expect(result, isTrue);
        verify(mockHttpClient.head(any)).called(1);
      });

      test('should return false for unavailable file', () async {
        // Arrange
        final mockResponse = http.Response('', 404);

        when(mockHttpClient.head(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.isFileAvailable('QmInvalidHash');

        // Assert
        expect(result, isFalse);
        verify(mockHttpClient.head(any)).called(1);
      });
    });

    group('getFileInfo', () {
      test('should get file info successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"Size": 100, "CumulativeSize": 150, "Type": "file", "Blocks": 1, "WithLocality": false}',
          200,
        );

        when(mockHttpClient.post(any, body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.getFileInfo('QmTestHash');

        // Assert
        expect(result['hash'], equals('QmTestHash'));
        expect(result['size'], equals(100));
        expect(result['type'], equals('file'));
        verify(mockHttpClient.post(any, body: anyNamed('body'))).called(1);
      });
    });

    group('pinFile', () {
      test('should pin file successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"Pins": ["QmTestHash"]}',
          200,
        );

        when(mockHttpClient.post(any, body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.pinFile('QmTestHash');

        // Assert
        expect(result, isTrue);
        verify(mockHttpClient.post(any, body: anyNamed('body'))).called(1);
      });

      test('should return false when pin fails', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"Pins": []}',
          200,
        );

        when(mockHttpClient.post(any, body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.pinFile('QmTestHash');

        // Assert
        expect(result, isFalse);
      });
    });

    group('unpinFile', () {
      test('should unpin file successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"Pins": []}',
          200,
        );

        when(mockHttpClient.post(any, body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.unpinFile('QmTestHash');

        // Assert
        expect(result, isTrue);
        verify(mockHttpClient.post(any, body: anyNamed('body'))).called(1);
      });
    });

    group('getPinnedFiles', () {
      test('should get pinned files successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"Keys": {"QmHash1": {}, "QmHash2": {}}}',
          200,
        );

        when(mockHttpClient.post(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.getPinnedFiles();

        // Assert
        expect(result, containsAll(['QmHash1', 'QmHash2']));
        expect(result.length, equals(2));
        verify(mockHttpClient.post(any)).called(1);
      });

      test('should return empty list when no pinned files', () async {
        // Arrange
        final mockResponse = http.Response('{"Keys": {}}', 200);

        when(mockHttpClient.post(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await ipfsService.getPinnedFiles();

        // Assert
        expect(result, isEmpty);
        verify(mockHttpClient.post(any)).called(1);
      });
    });

    group('Cache Management', () {
      test('should clear cache', () {
        // Act
        ipfsService.clearCache();

        // Assert
        final stats = ipfsService.getCacheStats();
        expect(stats['totalEntries'], equals(0));
      });

      test('should clean expired cache entries', () {
        // Act
        ipfsService.cleanExpiredCache();

        // Assert
        // Cache should be empty after cleaning
        final stats = ipfsService.getCacheStats();
        expect(stats['totalEntries'], equals(0));
      });

      test('should get cache statistics', () {
        // Act
        final stats = ipfsService.getCacheStats();

        // Assert
        expect(stats, contains('totalEntries'));
        expect(stats, contains('cacheExpiry'));
        expect(stats, contains('cacheSize'));
      });
    });

    group('Utility Methods', () {
      test('should generate hash for data', () {
        // Arrange
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);

        // Act
        final hash = ipfsService.generateHash(data);

        // Assert
        expect(hash, isNotEmpty);
        expect(hash.length, equals(64)); // SHA-256 hash length
      });

      test('should validate IPFS hash format', () {
        // Valid hash
        expect(ipfsService.isValidHash('QmTestHash1234567890123456789012345678901234567890123456'), isTrue);
        
        // Invalid hash (too short)
        expect(ipfsService.isValidHash('QmShort'), isFalse);
        
        // Invalid hash (wrong prefix)
        expect(ipfsService.isValidHash('InvalidHash1234567890123456789012345678901234567890123456'), isFalse);
      });

      test('should get gateway URL', () {
        // Act
        final url = ipfsService.getGatewayUrl('QmTestHash');

        // Assert
        expect(url, equals('http://localhost:8080/ipfs/QmTestHash'));
      });

      test('should get node URL', () {
        // Act
        final url = ipfsService.getNodeUrl();

        // Assert
        expect(url, equals('http://localhost:5001'));
      });

      test('should get gateway base URL', () {
        // Act
        final url = ipfsService.getGatewayUrlBase();

        // Assert
        expect(url, equals('http://localhost:8080/ipfs'));
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => ipfsService.getFile('QmTestHash'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle invalid JSON responses', () async {
        // Arrange
        final mockResponse = http.Response('Invalid JSON', 200);

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => ipfsService.getMetadata('QmTestHash'),
          throwsA(isA<Exception>()),
        );
      });
    });

    tearDown(() {
      ipfsService.dispose();
    });
  });
}
