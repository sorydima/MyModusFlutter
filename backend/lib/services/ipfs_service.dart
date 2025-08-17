import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';

class IPFSService {
  final Logger _logger = Logger();
  late final String _ipfsApiUrl;

  IPFSService() {
    final env = DotEnv()..load();
    _ipfsApiUrl = env['IPFS_API_URL'] ?? 'http://localhost:5001';
    _logger.i('IPFS Service initialized with API URL: $_ipfsApiUrl');
  }

  /// Загрузка файла в IPFS
  /// Возвращает CID (Content Identifier) файла
  Future<String> uploadFile(File file) async {
    try {
      final uri = Uri.parse('$_ipfsApiUrl/api/v0/add');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        final cid = jsonResponse['Hash'];
        _logger.i('File uploaded to IPFS: $cid');
        return cid;
      } else {
        _logger.e('Failed to upload file to IPFS: ${response.statusCode} - $responseBody');
        throw Exception('Failed to upload file to IPFS: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      _logger.e('Error uploading file to IPFS: $e');
      rethrow;
    }
  }

  /// Получение URL для доступа к файлу по CID
  String getFileUrl(String cid) {
    final env = DotEnv()..load();
    final ipfsGatewayUrl = env['IPFS_GATEWAY_URL'] ?? 'http://localhost:8080/ipfs';
    return '$ipfsGatewayUrl/$cid';
  }

  /// Получение содержимого файла из IPFS по CID
  Future<List<int>> getFile(String cid) async {
    try {
      final uri = Uri.parse('$_ipfsApiUrl/api/v0/cat?arg=$cid');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        _logger.i('File retrieved from IPFS: $cid');
        return response.bodyBytes;
      } else {
        _logger.e('Failed to retrieve file from IPFS: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to retrieve file from IPFS: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('Error retrieving file from IPFS: $e');
      rethrow;
    }
  }

  /// Загрузка JSON метаданных в IPFS
  Future<String> uploadMetadata(Map<String, dynamic> metadata) async {
    try {
      final jsonString = jsonEncode(metadata);
      final tempDir = Directory.systemTemp.createTempSync('ipfs_metadata_');
      final tempFile = File('${tempDir.path}/metadata.json');
      await tempFile.writeAsString(jsonString);

      final cid = await uploadFile(tempFile);
      await tempDir.delete(recursive: true);
      
      return cid;
    } catch (e) {
      _logger.e('Error uploading metadata to IPFS: $e');
      rethrow;
    }
  }

  /// Получение метаданных из IPFS по CID
  Future<Map<String, dynamic>> getMetadata(String cid) async {
    try {
      final fileBytes = await getFile(cid);
      final jsonString = utf8.decode(fileBytes);
      return jsonDecode(jsonString);
    } catch (e) {
      _logger.e('Error retrieving metadata from IPFS: $e');
      rethrow;
    }
  }

  /// Загрузка изображения товара в IPFS
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      // Создаем метаданные для изображения
      final metadata = {
        'name': 'Product Image',
        'description': 'Product image for $productId',
        'image': 'ipfs://', // Будет заполнено после загрузки
        'attributes': {
          'product_id': productId,
          'type': 'product_image',
          'uploaded_at': DateTime.now().toIso8601String(),
        }
      };

      // Загружаем изображение
      final imageCid = await uploadFile(imageFile);
      
      // Обновляем метаданные с CID изображения
      metadata['image'] = 'ipfs://$imageCid';
      
      // Загружаем метаданные
      final metadataCid = await uploadMetadata(metadata);
      
      _logger.i('Product image uploaded to IPFS: $imageCid, metadata: $metadataCid');
      return metadataCid;
    } catch (e) {
      _logger.e('Error uploading product image to IPFS: $e');
      rethrow;
    }
  }

  /// Загрузка NFT метаданных в IPFS
  Future<String> uploadNFTMetadata({
    required String name,
    required String description,
    required String imageCid,
    required Map<String, dynamic> attributes,
    required String collection,
  }) async {
    try {
      final metadata = {
        'name': name,
        'description': description,
        'image': 'ipfs://$imageCid',
        'attributes': attributes,
        'collection': collection,
        'created_at': DateTime.now().toIso8601String(),
      };

      final metadataCid = await uploadMetadata(metadata);
      _logger.i('NFT metadata uploaded to IPFS: $metadataCid');
      return metadataCid;
    } catch (e) {
      _logger.e('Error uploading NFT metadata to IPFS: $e');
      rethrow;
    }
  }

  /// Проверка доступности IPFS узла
  Future<bool> isNodeAvailable() async {
    try {
      final uri = Uri.parse('$_ipfsApiUrl/api/v0/version');
      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (e) {
      _logger.w('IPFS node is not available: $e');
      return false;
    }
  }

  /// Получение статистики IPFS узла
  Future<Map<String, dynamic>> getNodeStats() async {
    try {
      final uri = Uri.parse('$_ipfsApiUrl/api/v0/stats/repo');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get IPFS stats: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error getting IPFS node stats: $e');
      rethrow;
    }
  }
}
