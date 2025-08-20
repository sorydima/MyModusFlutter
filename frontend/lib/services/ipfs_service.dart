import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/web3_models.dart';

/// Сервис для интеграции с IPFS
/// Обрабатывает загрузку, получение и кэширование данных в IPFS
class IPFSService {
  // IPFS Gateway URLs для различных провайдеров
  static const List<String> _ipfsGateways = [
    'https://ipfs.io/ipfs/',
    'https://gateway.pinata.cloud/ipfs/',
    'https://cloudflare-ipfs.com/ipfs/',
    'https://dweb.link/ipfs/',
    'https://gateway.ipfs.io/ipfs/',
  ];
  
  // Кэш для IPFS данных
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 24);
  
  // Текущий активный gateway
  int _currentGatewayIndex = 0;
  
  /// Получить текущий активный gateway
  String get currentGateway => _ipfsGateways[_currentGatewayIndex];
  
  /// Получить список всех доступных gateways
  List<String> get availableGateways => List.from(_ipfsGateways);
  
  /// Переключить на следующий gateway
  void switchToNextGateway() {
    _currentGatewayIndex = (_currentGatewayIndex + 1) % _ipfsGateways.length;
  }
  
  /// Переключить на конкретный gateway по индексу
  void switchToGateway(int index) {
    if (index >= 0 && index < _ipfsGateways.length) {
      _currentGatewayIndex = index;
    }
  }
  
  /// Загрузить файл в IPFS (через Pinata или другой сервис)
  Future<String?> uploadFile({
    required Uint8List fileData,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      // В реальном приложении здесь будет загрузка через Pinata API
      // Пока что используем mock загрузку для демонстрации
      
      // Генерируем mock IPFS hash на основе содержимого файла
      final hash = _generateMockIPFSHash(fileData);
      
      // Сохраняем в кэш
      _cache[hash] = {
        'data': fileData,
        'fileName': fileName,
        'mimeType': mimeType ?? 'application/octet-stream',
        'size': fileData.length,
        'uploadedAt': DateTime.now().toIso8601String(),
      };
      _cacheTimestamps[hash] = DateTime.now();
      
      print('File uploaded to IPFS: $hash');
      return hash;
      
    } catch (e) {
      print('Error uploading file to IPFS: $e');
      return null;
    }
  }
  
  /// Загрузить JSON метаданные в IPFS
  Future<String?> uploadMetadata({
    required Map<String, dynamic> metadata,
    String? fileName,
  }) async {
    try {
      // Конвертируем метаданные в JSON
      final jsonString = jsonEncode(metadata);
      final jsonBytes = utf8.encode(jsonString);
      
      // Загружаем JSON как файл
      return await uploadFile(
        fileData: Uint8List.fromList(jsonBytes),
        fileName: fileName ?? 'metadata.json',
        mimeType: 'application/json',
      );
      
    } catch (e) {
      print('Error uploading metadata to IPFS: $fs');
      return null;
    }
  }
  
  /// Загрузить NFT метаданные в IPFS
  Future<String?> uploadNFTMetadata({
    required String name,
    required String description,
    required String imageUrl,
    required String category,
    required Map<String, String> attributes,
    String? externalUrl,
    String? animationUrl,
  }) async {
    try {
      final metadata = {
        'name': name,
        'description': description,
        'image': imageUrl,
        'category': category,
        'attributes': attributes.entries.map((e) => {
          'trait_type': e.key,
          'value': e.value,
        }).toList(),
        'external_url': externalUrl,
        'animation_url': animationUrl,
        'created_at': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
      
      return await uploadMetadata(
        metadata: metadata,
        fileName: '${name.replaceAll(' ', '_')}_metadata.json',
      );
      
    } catch (e) {
      print('Error uploading NFT metadata to IPFS: $e');
      return null;
    }
  }
  
  /// Получить файл из IPFS
  Future<Uint8List?> getFile(String ipfsHash) async {
    try {
      // Проверяем кэш
      if (_cache.containsKey(ipfsHash)) {
        final cacheEntry = _cache[ipfsHash];
        final timestamp = _cacheTimestamps[ipfsHash];
        
        if (timestamp != null && 
            DateTime.now().difference(timestamp) < _cacheExpiry) {
          print('File retrieved from cache: $ipfsHash');
          return cacheEntry['data'];
        } else {
          // Удаляем устаревший кэш
          _cache.remove(ipfsHash);
          _cacheTimestamps.remove(ipfsHash);
        }
      }
      
      // Пытаемся получить файл из IPFS
      final response = await _fetchFromIPFS(ipfsHash);
      if (response != null) {
        // Сохраняем в кэш
        _cache[ipfsHash] = {
          'data': response,
          'fileName': 'unknown',
          'mimeType': 'application/octet-stream',
          'size': response.length,
          'retrievedAt': DateTime.now().toIso8601String(),
        };
        _cacheTimestamps[ipfsHash] = DateTime.now();
        
        return response;
      }
      
      return null;
      
    } catch (e) {
      print('Error getting file from IPFS: $e');
      return null;
    }
  }
  
  /// Получить JSON метаданные из IPFS
  Future<Map<String, dynamic>?> getMetadata(String ipfsHash) async {
    try {
      final fileData = await getFile(ipfsHash);
      if (fileData != null) {
        final jsonString = utf8.decode(fileData);
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting metadata from IPFS: $e');
      return null;
    }
  }
  
  /// Получить NFT метаданные из IPFS
  Future<NFTMetadata?> getNFTMetadata(String ipfsHash) async {
    try {
      final metadata = await getMetadata(ipfsHash);
      if (metadata != null) {
        return NFTMetadata.fromJson(metadata);
      }
      return null;
    } catch (e) {
      print('Error getting NFT metadata from IPFS: $e');
      return null;
    }
  }
  
  /// Получить изображение из IPFS
  Future<Uint8List?> getImage(String ipfsHash) async {
    try {
      return await getFile(ipfsHash);
    } catch (e) {
      print('Error getting image from IPFS: $e');
      return null;
    }
  }
  
  /// Получить URL для IPFS hash
  String getIPFSURL(String ipfsHash) {
    if (ipfsHash.startsWith('ipfs://')) {
      ipfsHash = ipfsHash.replaceFirst('ipfs://', '');
    }
    return '$currentGateway$ipfsHash';
  }
  
  /// Получить URL для IPFS hash с конкретным gateway
  String getIPFSURLWithGateway(String ipfsHash, int gatewayIndex) {
    if (ipfsHash.startsWith('ipfs://')) {
      ipfsHash = ipfsHash.replaceFirst('ipfs://', '');
    }
    if (gatewayIndex >= 0 && gatewayIndex < _ipfsGateways.length) {
      return '${_ipfsGateways[gatewayIndex]}$ipfsHash';
    }
    return getIPFSURL(ipfsHash);
  }
  
  /// Проверить доступность IPFS gateway
  Future<bool> isGatewayAvailable(String gateway) async {
    try {
      final response = await http.get(
        Uri.parse('${gateway}QmTest'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 5));
      
      // Если получаем ответ (даже ошибку), значит gateway доступен
      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }
  
  /// Найти доступный gateway
  Future<String?> findAvailableGateway() async {
    for (int i = 0; i < _ipfsGateways.length; i++) {
      if (await isGatewayAvailable(_ipfsGateways[i])) {
        _currentGatewayIndex = i;
        return _ipfsGateways[i];
      }
    }
    return null;
  }
  
  /// Получить статистику кэша
  Map<String, dynamic> getCacheStats() {
    return {
      'totalEntries': _cache.length,
      'totalSize': _cache.values.fold<int>(0, (sum, entry) => sum + (entry['size'] ?? 0)),
      'oldestEntry': _cacheTimestamps.values.isNotEmpty 
          ? _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String()
          : null,
      'newestEntry': _cacheTimestamps.values.isNotEmpty 
          ? _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
          : null,
      'expiredEntries': _cacheTimestamps.entries
          .where((entry) => DateTime.now().difference(entry.value) >= _cacheExpiry)
          .length,
    };
  }
  
  /// Очистить кэш
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
  
  /// Очистить устаревшие записи кэша
  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) >= _cacheExpiry)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    print('Cleared ${expiredKeys.length} expired cache entries');
  }
  
  /// Попытаться получить файл из IPFS через различные gateways
  Future<Uint8List?> _fetchFromIPFS(String ipfsHash) async {
    // Пытаемся через текущий gateway
    try {
      final response = await http.get(
        Uri.parse(getIPFSURL(ipfsHash)),
        headers: {'Accept': '*/*'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Error fetching from current gateway: $e');
    }
    
    // Если не получилось, пробуем другие gateways
    for (int i = 0; i < _ipfsGateways.length; i++) {
      if (i == _currentGatewayIndex) continue;
      
      try {
        final response = await http.get(
          Uri.parse('${_ipfsGateways[i]}$ipfsHash'),
          headers: {'Accept': '*/*'},
        ).timeout(Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          // Переключаемся на рабочий gateway
          _currentGatewayIndex = i;
          print('Switched to working gateway: ${_ipfsGateways[i]}');
          return response.bodyBytes;
        }
      } catch (e) {
        print('Error fetching from gateway ${_ipfsGateways[i]}: $e');
      }
    }
    
    return null;
  }
  
  /// Генерировать mock IPFS hash для демонстрации
  String _generateMockIPFSHash(Uint8List data) {
    final hash = sha256.convert(data);
    return 'Qm${hash.toString().substring(0, 44)}';
  }
}

/// Модель для NFT метаданных
class NFTMetadata {
  final String name;
  final String description;
  final String image;
  final String category;
  final List<Map<String, dynamic>> attributes;
  final String? externalUrl;
  final String? animationUrl;
  final String createdAt;
  final String version;
  
  NFTMetadata({
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.attributes,
    this.externalUrl,
    this.animationUrl,
    required this.createdAt,
    required this.version,
  });
  
  factory NFTMetadata.fromJson(Map<String, dynamic> json) {
    return NFTMetadata(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      attributes: List<Map<String, dynamic>>.from(json['attributes'] ?? []),
      externalUrl: json['external_url'],
      animationUrl: json['animation_url'],
      createdAt: json['created_at'] ?? '',
      version: json['version'] ?? '1.0.0',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'category': category,
      'attributes': attributes,
      'external_url': externalUrl,
      'animation_url': animationUrl,
      'created_at': createdAt,
      'version': version,
    };
  }
}
