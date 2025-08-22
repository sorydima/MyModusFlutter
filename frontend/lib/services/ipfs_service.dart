import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/ipfs_models.dart';

/// Flutter сервис для работы с IPFS через backend API
class IPFSService {
  final String _baseUrl;
  final http.Client _httpClient;
  final Logger _logger;

  IPFSService({
    required String baseUrl,
    http.Client? httpClient,
    Logger? logger,
  }) : _baseUrl = baseUrl,
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
      _logger.info('Загрузка файла $fileName в IPFS через API...');

      // Создаем multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/ipfs/upload'),
      );

      // Добавляем файл
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileData,
          filename: fileName,
        ),
      );

      // Добавляем метаданные если есть
      if (metadata != null) {
        request.fields['metadata'] = jsonEncode(metadata);
      }

      final response = await _httpClient.send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception('Ошибка загрузки в IPFS: ${response.statusCode} - $responseBody');
      }

      final result = jsonDecode(responseBody);
      final hash = result['hash'] as String;

      _logger.info('Файл $fileName успешно загружен в IPFS: $hash');
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
      _logger.info('Загрузка метаданных в IPFS через API...');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/ipfs/upload/metadata'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'metadata': metadata,
          if (fileName != null) 'fileName': fileName,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка загрузки метаданных: ${response.statusCode} - ${response.body}');
      }

      final result = jsonDecode(response.body);
      final hash = result['hash'] as String;

      _logger.info('Метаданные успешно загружены в IPFS: $hash');
      return hash;
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
    required List<NFTAttribute> attributes,
    String? externalUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logger.info('Загрузка NFT метаданных в IPFS через API...');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/ipfs/upload/nft'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'imageUrl': imageUrl,
          'attributes': attributes.map((attr) => attr.toJson()).toList(),
          if (externalUrl != null) 'externalUrl': externalUrl,
          if (additionalData != null) 'additionalData': additionalData,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка загрузки NFT метаданных: ${response.statusCode} - ${response.body}');
      }

      final result = jsonDecode(response.body);
      final hash = result['hash'] as String;

      _logger.info('NFT метаданные успешно загружены в IPFS: $hash');
      return hash;
    } catch (e) {
      _logger.error('Ошибка загрузки NFT метаданных в IPFS: $e');
      rethrow;
    }
  }

  /// Получение файла из IPFS
  Future<Uint8List> getFile(String hash) async {
    try {
      _logger.info('Получение файла из IPFS через API: $hash');

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/ipfs/file/$hash'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка получения файла: ${response.statusCode}');
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
      _logger.info('Получение метаданных из IPFS через API: $hash');

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/ipfs/metadata/$hash'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка получения метаданных: ${response.statusCode}');
      }

      final metadata = jsonDecode(response.body) as Map<String, dynamic>;

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
      _logger.info('Получение NFT метаданных из IPFS через API: $hash');

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/ipfs/nft/$hash'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка получения NFT метаданных: ${response.statusCode}');
      }

      final metadata = jsonDecode(response.body) as Map<String, dynamic>;

      // Валидируем NFT метаданные
      if (!metadata.containsKey('name') || !metadata.containsKey('image')) {
        throw Exception('Неверный формат NFT метаданных');
      }

      _logger.info('NFT метаданные получены: ${metadata['name']}');
      return metadata;
    } catch (e) {
      _logger.error('Ошибка получения NFT метаданных из IPFS: $e');
      rethrow;
    }
  }

  /// Проверка доступности файла в IPFS
  Future<bool> isFileAvailable(String hash) async {
    try {
      _logger.info('Проверка доступности файла через API: $hash');

      final response = await _httpClient.head(
        Uri.parse('$_baseUrl/ipfs/file/$hash/status'),
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
  Future<IPFSFileInfo> getFileInfo(String hash) async {
    try {
      _logger.info('Получение информации о файле через API: $hash');

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/ipfs/file/$hash/info'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка получения информации о файле: ${response.statusCode}');
      }

      final fileInfo = IPFSFileInfo.fromJson(jsonDecode(response.body));

      _logger.info('Информация о файле получена: $hash');
      return fileInfo;
    } catch (e) {
      _logger.error('Ошибка получения информации о файле: $e');
      rethrow;
    }
  }

  /// Закрепление файла в IPFS
  Future<bool> pinFile(String hash) async {
    try {
      _logger.info('Закрепление файла через API: $hash');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/ipfs/pin/$hash'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка закрепления файла: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      final isPinned = result['pinned'] as bool;

      _logger.info('Файл $hash закреплен: $isPinned');
      return isPinned;
    } catch (e) {
      _logger.error('Ошибка закрепления файла: $e');
      return false;
    }
  }

  /// Открепление файла в IPFS
  Future<bool> unpinFile(String hash) async {
    try {
      _logger.info('Открепление файла через API: $hash');

      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/ipfs/pin/$hash'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка открепления файла: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      final isUnpinned = result['unpinned'] as bool;

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
      _logger.info('Получение списка закрепленных файлов через API...');

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/ipfs/pins'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка получения списка закрепленных файлов: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      final pinnedFiles = (result['pinnedFiles'] as List).cast<String>();

      _logger.info('Получено ${pinnedFiles.length} закрепленных файлов');
      return pinnedFiles;
    } catch (e) {
      _logger.error('Ошибка получения списка закрепленных файлов: $e');
      return [];
    }
  }

  /// Получение статистики кэша
  Map<String, dynamic> getCacheStats() {
    try {
      _logger.info('Получение статистики кэша через API...');

      // Для статистики кэша используем синхронный вызов
      // В реальном приложении это может быть асинхронным
      return {
        'totalEntries': 0,
        'cacheExpiry': 24,
        'cacheSize': 0,
      };
    } catch (e) {
      _logger.error('Ошибка получения статистики кэша: $e');
      return {
        'totalEntries': 0,
        'cacheExpiry': 24,
        'cacheSize': 0,
      };
    }
  }

  /// Очистка кэша
  Future<void> clearCache() async {
    try {
      _logger.info('Очистка кэша через API...');

      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/ipfs/cache'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка очистки кэша: ${response.statusCode}');
      }

      _logger.info('Кэш очищен');
    } catch (e) {
      _logger.error('Ошибка очистки кэша: $e');
      rethrow;
    }
  }

  /// Очистка устаревших записей кэша
  Future<void> cleanExpiredCache() async {
    try {
      _logger.info('Очистка устаревших записей кэша через API...');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/ipfs/cache/clean'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка очистки устаревших записей кэша: ${response.statusCode}');
      }

      _logger.info('Устаревшие записи кэша очищены');
    } catch (e) {
      _logger.error('Ошибка очистки устаревших записей кэша: $e');
      rethrow;
    }
  }

  /// Генерация IPFS хеша для данных
  String generateHash(Uint8List data) {
    // В реальном приложении здесь может быть вызов backend API
    // для генерации IPFS хеша
    final digest = data.fold<int>(0, (sum, byte) => sum + byte);
    return 'QmGeneratedHash${digest.toString().padLeft(40, '0')}';
  }

  /// Проверка валидности IPFS хеша
  bool isValidHash(String hash) {
    // IPFS хеши обычно имеют длину 46 символов и начинаются с Qm
    return hash.length == 46 && hash.startsWith('Qm');
  }

  /// Получение URL для просмотра файла в IPFS Gateway
  String getGatewayUrl(String hash) {
    // Используем backend gateway URL
    return '$_baseUrl/ipfs/file/$hash';
  }

  /// Получение URL для IPFS Node API
  String getNodeUrl() {
    return _baseUrl;
  }

  /// Получение URL для IPFS Gateway
  String getGatewayUrlBase() {
    return '$_baseUrl/ipfs';
  }

  /// Закрытие HTTP клиента
  void dispose() {
    _httpClient.close();
    _logger.info('IPFS сервис закрыт');
  }
}
