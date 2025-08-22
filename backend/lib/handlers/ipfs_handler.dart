import 'dart:convert';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logger/logger.dart';

import '../services/ipfs_service.dart';
import '../models/ipfs_models.dart';

/// API хендлер для IPFS сервиса
class IPFSHandler {
  final IPFSService _ipfsService;
  final Logger _logger;

  IPFSHandler({
    required IPFSService ipfsService,
    Logger? logger,
  }) : _ipfsService = ipfsService,
       _logger = logger ?? Logger();

  /// Роутер для IPFS API
  Router get router {
    final router = Router();

    // Загрузка файла в IPFS
    router.post('/upload', _uploadFile);
    
    // Загрузка метаданных в IPFS
    router.post('/upload/metadata', _uploadMetadata);
    
    // Загрузка NFT метаданных в IPFS
    router.post('/upload/nft', _uploadNFTMetadata);
    
    // Получение файла по хешу
    router.get('/file/<hash>', _getFile);
    
    // Получение метаданных по хешу
    router.get('/metadata/<hash>', _getMetadata);
    
    // Получение NFT метаданных по хешу
    router.get('/nft/<hash>', _getNFTMetadata);
    
    // Проверка доступности файла
    router.head('/file/<hash>/status', _checkFileStatus);
    
    // Получение информации о файле
    router.get('/file/<hash>/info', _getFileInfo);
    
    // Закрепление файла
    router.post('/pin/<hash>', _pinFile);
    
    // Открепление файла
    router.delete('/pin/<hash>', _unpinFile);
    
    // Получение списка закрепленных файлов
    router.get('/pins', _getPinnedFiles);
    
    // Статистика кэша
    router.get('/cache/stats', _getCacheStats);
    
    // Очистка кэша
    router.delete('/cache', _clearCache);
    
    // Очистка устаревших записей кэша
    router.post('/cache/clean', _cleanExpiredCache);

    return router;
  }

  /// Загрузка файла в IPFS
  Future<Response> _uploadFile(Request request) async {
    try {
      _logger.info('Запрос на загрузку файла в IPFS');

      // Парсим multipart данные
      final multipart = await request.readAsString();
      final parts = multipart.split('--');
      
      String? fileName;
      Uint8List? fileData;
      String? contentType;
      Map<String, dynamic>? metadata;

      for (final part in parts) {
        if (part.contains('Content-Disposition: form-data')) {
          if (part.contains('name="file"')) {
            // Извлекаем имя файла
            final nameMatch = RegExp(r'filename="([^"]+)"').firstMatch(part);
            if (nameMatch != null) {
              fileName = nameMatch.group(1);
            }
            
            // Извлекаем тип контента
            final contentTypeMatch = RegExp(r'Content-Type: ([^\r\n]+)').firstMatch(part);
            if (contentTypeMatch != null) {
              contentType = contentTypeMatch.group(1);
            }
            
            // Извлекаем данные файла
            final dataStart = part.indexOf('\r\n\r\n') + 4;
            if (dataStart < part.length) {
              final dataString = part.substring(dataStart);
              fileData = Uint8List.fromList(dataString.codeUnits);
            }
          } else if (part.contains('name="metadata"')) {
            // Извлекаем метаданные
            final dataStart = part.indexOf('\r\n\r\n') + 4;
            if (dataStart < part.length) {
              final metadataString = part.substring(dataStart);
              metadata = jsonDecode(metadataString);
            }
          }
        }
      }

      if (fileName == null || fileData == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Missing file data or filename',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Загружаем файл в IPFS
      final hash = await _ipfsService.uploadFile(
        fileData: fileData,
        fileName: fileName,
        contentType: contentType,
        metadata: metadata,
      );

      final result = IPFSUploadResult.success(
        hash: hash,
        fileName: fileName,
        size: fileData.length,
        gatewayUrl: _ipfsService.getGatewayUrl(hash),
      );

      _logger.info('Файл $fileName успешно загружен в IPFS: $hash');

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка загрузки файла в IPFS: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Загрузка метаданных в IPFS
  Future<Response> _uploadMetadata(Request request) async {
    try {
      _logger.info('Запрос на загрузку метаданных в IPFS');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final metadata = data['metadata'] as Map<String, dynamic>;
      final fileName = data['fileName'] as String?;

      final hash = await _ipfsService.uploadMetadata(
        metadata: metadata,
        fileName: fileName,
      );

      final result = IPFSUploadResult.success(
        hash: hash,
        fileName: fileName ?? 'metadata.json',
        size: utf8.encode(jsonEncode(metadata)).length,
        gatewayUrl: _ipfsService.getGatewayUrl(hash),
      );

      _logger.info('Метаданные успешно загружены в IPFS: $hash');

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка загрузки метаданных в IPFS: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Загрузка NFT метаданных в IPFS
  Future<Response> _uploadNFTMetadata(Request request) async {
    try {
      _logger.info('Запрос на загрузку NFT метаданных в IPFS');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final name = data['name'] as String;
      final description = data['description'] as String;
      final imageUrl = data['imageUrl'] as String;
      final attributes = (data['attributes'] as List)
          .map((attr) => NFTAttribute.fromJson(attr))
          .toList();
      final externalUrl = data['externalUrl'] as String?;
      final additionalData = data['additionalData'] as Map<String, dynamic>?;

      final hash = await _ipfsService.uploadNFTMetadata(
        name: name,
        description: description,
        imageUrl: imageUrl,
        attributes: attributes,
        externalUrl: externalUrl,
        additionalData: additionalData,
      );

      final result = IPFSUploadResult.success(
        hash: hash,
        fileName: 'nft_${name.toLowerCase().replaceAll(' ', '_')}.json',
        size: utf8.encode(jsonEncode(data)).length,
        gatewayUrl: _ipfsService.getGatewayUrl(hash),
      );

      _logger.info('NFT метаданные успешно загружены в IPFS: $hash');

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка загрузки NFT метаданных в IPFS: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение файла по хешу
  Future<Response> _getFile(Request request) async {
    try {
      final hash = request.params['hash'];
      if (hash == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Missing hash parameter',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      _logger.info('Запрос на получение файла: $hash');

      final fileData = await _ipfsService.getFile(hash);

      return Response.ok(
        fileData,
        headers: {
          'content-type': 'application/octet-stream',
          'content-length': fileData.length.toString(),
          'x-ipfs-hash': hash,
        },
      );
    } catch (e) {
      _logger.error('Ошибка получения файла: $e');
      
      return Response.notFound(
        body: jsonEncode({
          'error': 'File not found',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение метаданных по хешу
  Future<Response> _getMetadata(Request request) async {
    try {
      final hash = request.params['hash'];
      if (hash == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Missing hash parameter',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      _logger.info('Запрос на получение метаданных: $hash');

      final metadata = await _ipfsService.getMetadata(hash);

      return Response.ok(
        jsonEncode(metadata),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка получения метаданных: $e');
      
      return Response.notFound(
        body: jsonEncode({
          'error': 'Metadata not found',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение NFT метаданных по хешу
  Future<Response> _getNFTMetadata(Request request) async {
    try {
      final hash = request.params['hash'];
      if (hash == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Missing hash parameter',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      _logger.info('Запрос на получение NFT метаданных: $hash');

      final metadata = await _ipfsService.getNFTMetadata(hash);

      return Response.ok(
        jsonEncode(metadata),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка получения NFT метаданных: $e');
      
      return Response.notFound(
        body: jsonEncode({
          'error': 'NFT metadata not found',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Проверка статуса файла
  Future<Response> _checkFileStatus(Request request) async {
    try {
      final hash = request.params['hash'];
      if (hash == null) {
        return Response.badRequest();
      }

      _logger.info('Проверка статуса файла: $hash');

      final isAvailable = await _ipfsService.isFileAvailable(hash);

      if (isAvailable) {
        return Response.ok('', headers: {'x-ipfs-status': 'available'});
      } else {
        return Response.notFound('', headers: {'x-ipfs-status': 'not_found'});
      }
    } catch (e) {
      _logger.error('Ошибка проверки статуса файла: $e');
      return Response.internalServerError();
    }
  }

  /// Получение информации о файле
  Future<Response> _getFileInfo(Request request) async {
    try {
      final hash = request.params['hash'];
      if (hash == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Missing hash parameter',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      _logger.info('Запрос на получение информации о файле: $hash');

      final fileInfo = await _ipfsService.getFileInfo(hash);

      return Response.ok(
        jsonEncode(fileInfo),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка получения информации о файле: $e');
      
      return Response.notFound(
        body: jsonEncode({
          'error': 'File info not found',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Закрепление файла
  Future<Response> _pinFile(Request request) async {
    try {
      final hash = request.params['hash'];
      if (hash == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Missing hash parameter',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      _logger.info('Запрос на закрепление файла: $hash');

      final isPinned = await _ipfsService.pinFile(hash);

      return Response.ok(
        jsonEncode({
          'hash': hash,
          'pinned': isPinned,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка закрепления файла: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Открепление файла
  Future<Response> _unpinFile(Request request) async {
    try {
      final hash = request.params['hash'];
      if (hash == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Missing hash parameter',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      _logger.info('Запрос на открепление файла: $hash');

      final isUnpinned = await _ipfsService.unpinFile(hash);

      return Response.ok(
        jsonEncode({
          'hash': hash,
          'unpinned': isUnpinned,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка открепления файла: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение списка закрепленных файлов
  Future<Response> _getPinnedFiles(Request request) async {
    try {
      _logger.info('Запрос на получение списка закрепленных файлов');

      final pinnedFiles = await _ipfsService.getPinnedFiles();

      return Response.ok(
        jsonEncode({
          'pinnedFiles': pinnedFiles,
          'count': pinnedFiles.length,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка получения списка закрепленных файлов: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение статистики кэша
  Future<Response> _getCacheStats(Request request) async {
    try {
      _logger.info('Запрос на получение статистики кэша');

      final stats = _ipfsService.getCacheStats();

      return Response.ok(
        jsonEncode(stats),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка получения статистики кэша: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Очистка кэша
  Future<Response> _clearCache(Request request) async {
    try {
      _logger.info('Запрос на очистку кэша');

      _ipfsService.clearCache();

      return Response.ok(
        jsonEncode({
          'message': 'Cache cleared successfully',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка очистки кэша: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Очистка устаревших записей кэша
  Future<Response> _cleanExpiredCache(Request request) async {
    try {
      _logger.info('Запрос на очистку устаревших записей кэша');

      _ipfsService.cleanExpiredCache();

      return Response.ok(
        jsonEncode({
          'message': 'Expired cache entries cleaned successfully',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.error('Ошибка очистки устаревших записей кэша: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
