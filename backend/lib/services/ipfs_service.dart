import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';

/// IPFS сервис для децентрализованного хранения
class IPFSService {
  final String _ipfsNodeUrl;
  final String _ipfsGatewayUrl;
  final http.Client _httpClient;
  final Logger _logger;
  
  // Кэш для IPFS данных
  final Map<String, dynamic> _cache = {};
  final Duration _cacheExpiry = Duration(hours: 24);

  IPFSService({
    required String ipfsNodeUrl,
    required String ipfsGatewayUrl,
    http.Client? httpClient,
    Logger? logger,
  }) : _ipfsNodeUrl = ipfsNodeUrl,
       _ipfsGatewayUrl = ipfsGatewayUrl,
       _httpClient = httpClient ?? http.Client(),
       _logger = logger ?? Logger();

  /// Загрузка файла в IPFS
  Future<String> uploadFile({
    required Uint8List fileData,
    required String fileName,
    String? contentType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.info('Загрузка файла $fileName в IPFS...');

      // Создаем multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_ipfsNodeUrl/api/v0/add'),
      );

      // Добавляем файл
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileData,
          filename: fileName,
          contentType: contentType != null 
            ? ContentType.parse(contentType) 
            : null,
        ),
      );

      // Добавляем опции
      request.fields['pin'] = 'true';
      if (metadata != null) {
        request.fields['metadata'] = jsonEncode(metadata);
      }

      final response = await _httpClient.send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception('Ошибка загрузки в IPFS: ${response.statusCode} - $responseBody');
      }

      final result = jsonDecode(responseBody);
      final hash = result['Hash'] as String;

      _logger.info('Файл $fileName успешно загружен в IPFS: $hash');

      // Кэшируем результат
      _cache[hash] = {
        'fileName': fileName,
        'contentType': contentType,
        'metadata': metadata,
        'timestamp': DateTime.now(),
        'size': fileData.length,
      };

      return hash;
    } catch (e) {
      _logger.error('Ошибка загрузки файла в IPFS: $e');
      rethrow;
    }
  }

  /// Загрузка JSON метаданных в IPFS
  Future<String> uploadMetadata({
    required Map<String, dynamic> metadata,
    String? fileName,
  }) async {
    try {
      _logger.info('Загрузка метаданных в IPFS...');

      final jsonString = jsonEncode(metadata);
      final jsonBytes = utf8.encode(jsonString);

      return await uploadFile(
        fileData: Uint8List.fromList(jsonBytes),
        fileName: fileName ?? 'metadata.json',
        contentType: 'application/json',
        metadata: {'type': 'metadata'},
      );
    } catch (e) {
      _logger.error('Ошибка загрузки метаданных в IPFS: $e');
      rethrow;
    }
  }

  /// Загрузка NFT метаданных в IPFS
  Future<String> uploadNFTMetadata({
    required String name,
    required String description,
    required String imageUrl,
    required List<Map<String, dynamic>> attributes,
    String? externalUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logger.info('Загрузка NFT метаданных: $name');

      final metadata = {
        'name': name,
        'description': description,
        'image': imageUrl,
        'attributes': attributes,
        if (externalUrl != null) 'external_url': externalUrl,
        if (additionalData != null) ...additionalData,
        'created_at': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      return await uploadMetadata(
        metadata: metadata,
        fileName: 'nft_${name.toLowerCase().replaceAll(' ', '_')}.json',
      );
    } catch (e) {
      _logger.error('Ошибка загрузки NFT метаданных: $e');
      rethrow;
    }
  }

  /// Получение файла из IPFS по хешу
  Future<Uint8List> getFile(String hash) async {
    try {
      _logger.info('Получение файла из IPFS: $hash');

      // Проверяем кэш
      if (_cache.containsKey(hash)) {
        _logger.info('Файл найден в кэше: $hash');
      }

      final response = await _httpClient.get(
        Uri.parse('$_ipfsGatewayUrl/ipfs/$hash'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка получения файла из IPFS: ${response.statusCode}');
      }

      _logger.info('Файл успешно получен из IPFS: $hash (${response.bodyBytes.length} байт)');
      return response.bodyBytes;
    } catch (e) {
      _logger.error('Ошибка получения файла из IPFS: $e');
      rethrow;
    }
  }

  /// Получение JSON метаданных из IPFS
  Future<Map<String, dynamic>> getMetadata(String hash) async {
    try {
      _logger.info('Получение метаданных из IPFS: $hash');

      final fileData = await getFile(hash);
      final jsonString = utf8.decode(fileData);
      final metadata = jsonDecode(jsonString) as Map<String, dynamic>;

      _logger.info('Метаданные успешно получены: $hash');
      return metadata;
    } catch (e) {
      _logger.error('Ошибка получения метаданных из IPFS: $e');
      rethrow;
    }
  }

  /// Получение NFT метаданных из IPFS
  Future<Map<String, dynamic>> getNFTMetadata(String hash) async {
    try {
      _logger.info('Получение NFT метаданных: $hash');

      final metadata = await getMetadata(hash);
      
      // Валидируем NFT метаданные
      if (!metadata.containsKey('name') || !metadata.containsKey('image')) {
        throw Exception('Неверный формат NFT метаданных');
      }

      _logger.info('NFT метаданные получены: ${metadata['name']}');
      return metadata;
    } catch (e) {
      _logger.error('Ошибка получения NFT метаданных: $e');
      rethrow;
    }
  }

  /// Проверка доступности файла в IPFS
  Future<bool> isFileAvailable(String hash) async {
    try {
      _logger.info('Проверка доступности файла: $hash');

      final response = await _httpClient.head(
        Uri.parse('$_ipfsGatewayUrl/ipfs/$hash'),
      );

      final isAvailable = response.statusCode == 200;
      _logger.info('Файл $hash доступен: $isAvailable');
      
      return isAvailable;
    } catch (e) {
      _logger.error('Ошибка проверки доступности файла: $e');
      return false;
    }
  }

  /// Получение информации о файле в IPFS
  Future<Map<String, dynamic>> getFileInfo(String hash) async {
    try {
      _logger.info('Получение информации о файле: $hash');

      final response = await _httpClient.post(
        Uri.parse('$_ipfsNodeUrl/api/v0/files/stat'),
        body: {'arg': hash},
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка получения информации о файле: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      
      final fileInfo = {
        'hash': hash,
        'size': result['Size'],
        'cumulativeSize': result['CumulativeSize'],
        'type': result['Type'],
        'blocks': result['Blocks'],
        'withLocality': result['WithLocality'] ?? false,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _logger.info('Информация о файле получена: $hash');
      return fileInfo;
    } catch (e) {
      _logger.error('Ошибка получения информации о файле: $e');
      rethrow;
    }
  }

  /// Закрепление файла в IPFS (pin)
  Future<bool> pinFile(String hash) async {
    try {
      _logger.info('Закрепление файла в IPFS: $hash');

      final response = await _httpClient.post(
        Uri.parse('$_ipfsNodeUrl/api/v0/pin/add'),
        body: {'arg': hash},
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка закрепления файла: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      final isPinned = result['Pins']?.contains(hash) ?? false;

      _logger.info('Файл $hash закреплен: $isPinned');
      return isPinned;
    } catch (e) {
      _logger.error('Ошибка закрепления файла: $e');
      return false;
    }
  }

  /// Открепление файла в IPFS (unpin)
  Future<bool> unpinFile(String hash) async {
    try {
      _logger.info('Открепление файла в IPFS: $hash');

      final response = await _httpClient.post(
        Uri.parse('$_ipfsNodeUrl/api/v0/pin/rm'),
        body: {'arg': hash},
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка открепления файла: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      final isUnpinned = result['Pins']?.contains(hash) == false;

      _logger.info('Файл $hash откреплен: $isUnpinned');
      return isUnpinned;
    } catch (e) {
      _logger.error('Ошибка открепления файла: $e');
      return false;
    }
  }

  /// Получение списка закрепленных файлов
  Future<List<String>> getPinnedFiles() async {
    try {
      _logger.info('Получение списка закрепленных файлов...');

      final response = await _httpClient.post(
        Uri.parse('$_ipfsNodeUrl/api/v0/pin/ls'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка получения списка закрепленных файлов: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      final pinnedFiles = <String>[];

      if (result['Keys'] != null) {
        for (final entry in result['Keys'].entries) {
          pinnedFiles.add(entry.key);
        }
      }

      _logger.info('Получено ${pinnedFiles.length} закрепленных файлов');
      return pinnedFiles;
    } catch (e) {
      _logger.error('Ошибка получения списка закрепленных файлов: $e');
      return [];
    }
  }

  /// Очистка кэша
  void clearCache() {
    _logger.info('Очистка кэша IPFS...');
    _cache.clear();
  }

  /// Очистка устаревших записей кэша
  void cleanExpiredCache() {
    _logger.info('Очистка устаревших записей кэша...');
    
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      final timestamp = entry.value['timestamp'] as DateTime;
      if (now.difference(timestamp) > _cacheExpiry) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    _logger.info('Удалено ${expiredKeys.length} устаревших записей кэша');
  }

  /// Получение статистики кэша
  Map<String, dynamic> getCacheStats() {
    return {
      'totalEntries': _cache.length,
      'cacheExpiry': _cacheExpiry.inHours,
      'cacheSize': _cache.values.fold<int>(
        0, 
        (sum, entry) => sum + (entry['size'] as int? ?? 0)
      ),
    };
  }

  /// Генерация IPFS хеша для данных
  String generateHash(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }

  /// Проверка валидности IPFS хеша
  bool isValidHash(String hash) {
    // IPFS хеши обычно имеют длину 46 символов и начинаются с Qm
    return hash.length == 46 && hash.startsWith('Qm');
  }

  /// Получение URL для просмотра файла в IPFS Gateway
  String getGatewayUrl(String hash) {
    return '$_ipfsGatewayUrl/ipfs/$hash';
  }

  /// Получение URL для IPFS Node API
  String getNodeUrl() {
    return _ipfsNodeUrl;
  }

  /// Получение URL для IPFS Gateway
  String getGatewayUrlBase() {
    return _ipfsGatewayUrl;
  }

  /// Закрытие HTTP клиента
  void dispose() {
    _httpClient.close();
    _logger.info('IPFS сервис закрыт');
  }
}
