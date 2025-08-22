import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/ipfs_models.dart';
import '../services/ipfs_service.dart';

/// Provider для управления IPFS сервисами во фронтенде
class IPFSProvider extends ChangeNotifier {
  final IPFSService _ipfsService;
  final Logger _logger;
  
  // Состояние
  bool _isLoading = false;
  String? _error;
  List<IPFSFileMetadata> _uploadedFiles = [];
  List<String> _pinnedFiles = [];
  IPFSCacheStats? _cacheStats;
  
  // Геттеры
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<IPFSFileMetadata> get uploadedFiles => List.unmodifiable(_uploadedFiles);
  List<String> get pinnedFiles => List.unmodifiable(_pinnedFiles);
  IPFSCacheStats? get cacheStats => _cacheStats;
  
  IPFSProvider({
    required IPFSService ipfsService,
    Logger? logger,
  }) : _ipfsService = ipfsService,
       _logger = logger ?? Logger();

  /// Загрузка файла в IPFS
  Future<IPFSUploadResult?> uploadFile({
    required Uint8List fileData,
    required String fileName,
    String? contentType,
    Map<String, dynamic>? metadata,
    bool pinFile = true,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.info('Загрузка файла $fileName в IPFS...');
      
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
      
      // Добавляем в список загруженных файлов
      _uploadedFiles.add(IPFSFileMetadata(
        hash: hash,
        fileName: fileName,
        contentType: contentType,
        size: fileData.length,
        metadata: metadata,
        timestamp: DateTime.now(),
        isPinned: pinFile,
      ));
      
      // Закрепляем файл если требуется
      if (pinFile) {
        await _ipfsService.pinFile(hash);
        _pinnedFiles.add(hash);
      }
      
      _logger.info('Файл $fileName успешно загружен в IPFS: $hash');
      notifyListeners();
      
      return result;
    } catch (e) {
      _setError('Ошибка загрузки файла: $e');
      _logger.error('Ошибка загрузки файла в IPFS: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Загрузка метаданных в IPFS
  Future<IPFSUploadResult?> uploadMetadata({
    required Map<String, dynamic> metadata,
    String? fileName,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.info('Загрузка метаданных в IPFS...');
      
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
      
      // Добавляем в список загруженных файлов
      _uploadedFiles.add(IPFSFileMetadata(
        hash: hash,
        fileName: fileName ?? 'metadata.json',
        contentType: 'application/json',
        size: utf8.encode(jsonEncode(metadata)).length,
        metadata: {'type': 'metadata'},
        timestamp: DateTime.now(),
        isPinned: true,
      ));
      
      // Закрепляем метаданные
      await _ipfsService.pinFile(hash);
      _pinnedFiles.add(hash);
      
      _logger.info('Метаданные успешно загружены в IPFS: $hash');
      notifyListeners();
      
      return result;
    } catch (e) {
      _setError('Ошибка загрузки метаданных: $e');
      _logger.error('Ошибка загрузки метаданных в IPFS: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Загрузка NFT метаданных в IPFS
  Future<IPFSUploadResult?> uploadNFTMetadata({
    required String name,
    required String description,
    required String imageUrl,
    required List<NFTAttribute> attributes,
    String? externalUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.info('Загрузка NFT метаданных: $name');
      
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
        size: utf8.encode(jsonEncode({
          'name': name,
          'description': description,
          'image': imageUrl,
          'attributes': attributes.map((attr) => attr.toJson()).toList(),
          if (externalUrl != null) 'external_url': externalUrl,
          if (additionalData != null) ...additionalData,
        })).length,
        gatewayUrl: _ipfsService.getGatewayUrl(hash),
      );
      
      // Добавляем в список загруженных файлов
      _uploadedFiles.add(IPFSFileMetadata(
        hash: hash,
        fileName: 'nft_${name.toLowerCase().replaceAll(' ', '_')}.json',
        contentType: 'application/json',
        size: result.size,
        metadata: {
          'type': 'nft_metadata',
          'name': name,
          'description': description,
        },
        timestamp: DateTime.now(),
        isPinned: true,
      ));
      
      // Закрепляем NFT метаданные
      await _ipfsService.pinFile(hash);
      _pinnedFiles.add(hash);
      
      _logger.info('NFT метаданные успешно загружены в IPFS: $hash');
      notifyListeners();
      
      return result;
    } catch (e) {
      _setError('Ошибка загрузки NFT метаданных: $e');
      _logger.error('Ошибка загрузки NFT метаданных в IPFS: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение файла из IPFS
  Future<Uint8List?> getFile(String hash) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.info('Получение файла из IPFS: $hash');
      
      final fileData = await _ipfsService.getFile(hash);
      
      _logger.info('Файл успешно получен из IPFS: $hash');
      return fileData;
    } catch (e) {
      _setError('Ошибка получения файла: $e');
      _logger.error('Ошибка получения файла из IPFS: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение метаданных из IPFS
  Future<Map<String, dynamic>?> getMetadata(String hash) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.info('Получение метаданных из IPFS: $hash');
      
      final metadata = await _ipfsService.getMetadata(hash);
      
      _logger.info('Метаданные успешно получены: $hash');
      return metadata;
    } catch (e) {
      _setError('Ошибка получения метаданных: $e');
      _logger.error('Ошибка получения метаданных из IPFS: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Получение NFT метаданных из IPFS
  Future<NFTMetadata?> getNFTMetadata(String hash) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.info('Получение NFT метаданных: $hash');
      
      final metadata = await _ipfsService.getNFTMetadata(hash);
      
      // Конвертируем в NFTMetadata модель
      final nftMetadata = NFTMetadata.fromJson(metadata);
      
      _logger.info('NFT метаданные получены: ${nftMetadata.name}');
      return nftMetadata;
    } catch (e) {
      _setError('Ошибка получения NFT метаданных: $e');
      _logger.error('Ошибка получения NFT метаданных из IPFS: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Проверка доступности файла
  Future<bool> checkFileAvailability(String hash) async {
    try {
      _clearError();
      
      final isAvailable = await _ipfsService.isFileAvailable(hash);
      
      _logger.info('Файл $hash доступен: $isAvailable');
      return isAvailable;
    } catch (e) {
      _setError('Ошибка проверки доступности файла: $e');
      _logger.error('Ошибка проверки доступности файла: $e');
      return false;
    }
  }

  /// Получение информации о файле
  Future<IPFSFileInfo?> getFileInfo(String hash) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.info('Получение информации о файле: $hash');
      
      final fileInfo = await _ipfsService.getFileInfo(hash);
      
      _logger.info('Информация о файле получена: $hash');
      return fileInfo;
    } catch (e) {
      _setError('Ошибка получения информации о файле: $e');
      _logger.error('Ошибка получения информации о файле: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Закрепление файла
  Future<bool> pinFile(String hash) async {
    try {
      _clearError();
      
      _logger.info('Закрепление файла: $hash');
      
      final isPinned = await _ipfsService.pinFile(hash);
      
      if (isPinned && !_pinnedFiles.contains(hash)) {
        _pinnedFiles.add(hash);
        notifyListeners();
      }
      
      _logger.info('Файл $hash закреплен: $isPinned');
      return isPinned;
    } catch (e) {
      _setError('Ошибка закрепления файла: $e');
      _logger.error('Ошибка закрепления файла: $e');
      return false;
    }
  }

  /// Открепление файла
  Future<bool> unpinFile(String hash) async {
    try {
      _clearError();
      
      _logger.info('Открепление файла: $hash');
      
      final isUnpinned = await _ipfsService.unpinFile(hash);
      
      if (isUnpinned) {
        _pinnedFiles.remove(hash);
        notifyListeners();
      }
      
      _logger.info('Файл $hash откреплен: $isUnpinned');
      return isUnpinned;
    } catch (e) {
      _setError('Ошибка открепления файла: $e');
      _logger.error('Ошибка открепления файла: $e');
      return false;
    }
  }

  /// Обновление списка закрепленных файлов
  Future<void> refreshPinnedFiles() async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.info('Обновление списка закрепленных файлов...');
      
      final pinnedFiles = await _ipfsService.getPinnedFiles();
      _pinnedFiles = pinnedFiles;
      
      _logger.info('Получено ${pinnedFiles.length} закрепленных файлов');
      notifyListeners();
    } catch (e) {
      _setError('Ошибка обновления списка закрепленных файлов: $e');
      _logger.error('Ошибка обновления списка закрепленных файлов: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Обновление статистики кэша
  Future<void> refreshCacheStats() async {
    try {
      _clearError();
      
      _logger.info('Обновление статистики кэша...');
      
      final stats = _ipfsService.getCacheStats();
      _cacheStats = IPFSCacheStats.fromJson(stats);
      
      _logger.info('Статистика кэша обновлена');
      notifyListeners();
    } catch (e) {
      _setError('Ошибка обновления статистики кэша: $e');
      _logger.error('Ошибка обновления статистики кэша: $e');
    }
  }

  /// Очистка кэша
  Future<void> clearCache() async {
    try {
      _clearError();
      
      _logger.info('Очистка кэша...');
      
      _ipfsService.clearCache();
      
      // Обновляем статистику
      await refreshCacheStats();
      
      _logger.info('Кэш очищен');
      notifyListeners();
    } catch (e) {
      _setError('Ошибка очистки кэша: $e');
      _logger.error('Ошибка очистки кэша: $e');
    }
  }

  /// Очистка устаревших записей кэша
  Future<void> cleanExpiredCache() async {
    try {
      _clearError();
      
      _logger.info('Очистка устаревших записей кэша...');
      
      _ipfsService.cleanExpiredCache();
      
      // Обновляем статистику
      await refreshCacheStats();
      
      _logger.info('Устаревшие записи кэша очищены');
      notifyListeners();
    } catch (e) {
      _setError('Ошибка очистки устаревших записей кэша: $e');
      _logger.error('Ошибка очистки устаревших записей кэша: $e');
    }
  }

  /// Поиск файлов по имени или метаданным
  List<IPFSFileMetadata> searchFiles(String query) {
    if (query.isEmpty) return _uploadedFiles;
    
    return _uploadedFiles.where((file) {
      final fileName = file.fileName.toLowerCase();
      final searchQuery = query.toLowerCase();
      
      // Поиск по имени файла
      if (fileName.contains(searchQuery)) return true;
      
      // Поиск по метаданным
      if (file.metadata != null) {
        final metadataStr = jsonEncode(file.metadata).toLowerCase();
        if (metadataStr.contains(searchQuery)) return true;
      }
      
      return false;
    }).toList();
  }

  /// Фильтрация файлов по типу
  List<IPFSFileMetadata> filterFilesByType(String? contentType) {
    if (contentType == null) return _uploadedFiles;
    
    return _uploadedFiles.where((file) {
      return file.contentType?.contains(contentType) ?? false;
    }).toList();
  }

  /// Фильтрация файлов по размеру
  List<IPFSFileMetadata> filterFilesBySize({
    int? minSize,
    int? maxSize,
  }) {
    return _uploadedFiles.where((file) {
      if (minSize != null && file.size < minSize) return false;
      if (maxSize != null && file.size > maxSize) return false;
      return true;
    }).toList();
  }

  /// Фильтрация файлов по дате
  List<IPFSFileMetadata> filterFilesByDate({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _uploadedFiles.where((file) {
      if (fromDate != null && file.timestamp.isBefore(fromDate)) return false;
      if (toDate != null && file.timestamp.isAfter(toDate)) return false;
      return true;
    }).toList();
  }

  /// Получение файлов по хешу
  IPFSFileMetadata? getFileByHash(String hash) {
    try {
      return _uploadedFiles.firstWhere((file) => file.hash == hash);
    } catch (e) {
      return null;
    }
  }

  /// Удаление файла из локального списка
  void removeFileFromList(String hash) {
    _uploadedFiles.removeWhere((file) => file.hash == hash);
    _pinnedFiles.remove(hash);
    notifyListeners();
  }

  /// Очистка всех данных
  void clearAllData() {
    _uploadedFiles.clear();
    _pinnedFiles.clear();
    _cacheStats = null;
    _clearError();
    notifyListeners();
  }

  /// Установка состояния загрузки
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Установка ошибки
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Очистка ошибки
  void _clearError() {
    _error = null;
  }

  /// Инициализация провайдера
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.info('Инициализация IPFS провайдера...');
      
      // Загружаем закрепленные файлы
      await refreshPinnedFiles();
      
      // Загружаем статистику кэша
      await refreshCacheStats();
      
      _logger.info('IPFS провайдер инициализирован');
    } catch (e) {
      _setError('Ошибка инициализации IPFS провайдера: $e');
      _logger.error('Ошибка инициализации IPFS провайдера: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _ipfsService.dispose();
    super.dispose();
  }
}
