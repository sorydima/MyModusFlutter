/// Модели данных для IPFS сервиса во фронтенде

/// Метаданные файла в IPFS
class IPFSFileMetadata {
  final String hash;
  final String fileName;
  final String? contentType;
  final int size;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final bool isPinned;

  IPFSFileMetadata({
    required this.hash,
    required this.fileName,
    this.contentType,
    required this.size,
    this.metadata,
    required this.timestamp,
    this.isPinned = false,
  });

  factory IPFSFileMetadata.fromJson(Map<String, dynamic> json) {
    return IPFSFileMetadata(
      hash: json['hash'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String?,
      size: json['size'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'fileName': fileName,
      'contentType': contentType,
      'size': size,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'isPinned': isPinned,
    };
  }

  IPFSFileMetadata copyWith({
    String? hash,
    String? fileName,
    String? contentType,
    int? size,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    bool? isPinned,
  }) {
    return IPFSFileMetadata(
      hash: hash ?? this.hash,
      fileName: fileName ?? this.fileName,
      contentType: contentType ?? this.contentType,
      size: size ?? this.size,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  String toString() {
    return 'IPFSFileMetadata(hash: $hash, fileName: $fileName, size: $size, isPinned: $isPinned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IPFSFileMetadata && other.hash == hash;
  }

  @override
  int get hashCode => hash.hashCode;
}

/// NFT метаданные для IPFS
class NFTMetadata {
  final String name;
  final String description;
  final String imageUrl;
  final List<NFTAttribute> attributes;
  final String? externalUrl;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final String version;

  NFTMetadata({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.attributes,
    this.externalUrl,
    this.additionalData,
    required this.createdAt,
    this.version = '1.0.0',
  });

  factory NFTMetadata.fromJson(Map<String, dynamic> json) {
    return NFTMetadata(
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image'] as String,
      attributes: (json['attributes'] as List)
          .map((attr) => NFTAttribute.fromJson(attr))
          .toList(),
      externalUrl: json['external_url'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      version: json['version'] as String? ?? '1.0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': imageUrl,
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
      if (externalUrl != null) 'external_url': externalUrl,
      if (additionalData != null) 'additionalData': additionalData,
      'created_at': createdAt.toIso8601String(),
      'version': version,
    };
  }

  NFTMetadata copyWith({
    String? name,
    String? description,
    String? imageUrl,
    List<NFTAttribute>? attributes,
    String? externalUrl,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    String? version,
  }) {
    return NFTMetadata(
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      attributes: attributes ?? this.attributes,
      externalUrl: externalUrl ?? this.externalUrl,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      version: version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'NFTMetadata(name: $name, description: $description, imageUrl: $imageUrl)';
  }
}

/// Атрибут NFT
class NFTAttribute {
  final String traitType;
  final String value;
  final String? displayType;
  final int? maxValue;

  NFTAttribute({
    required this.traitType,
    required this.value,
    this.displayType,
    this.maxValue,
  });

  factory NFTAttribute.fromJson(Map<String, dynamic> json) {
    return NFTAttribute(
      traitType: json['trait_type'] as String,
      value: json['value'] as String,
      displayType: json['display_type'] as String?,
      maxValue: json['max_value'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trait_type': traitType,
      'value': value,
      if (displayType != null) 'display_type': displayType,
      if (maxValue != null) 'max_value': maxValue,
    };
  }

  NFTAttribute copyWith({
    String? traitType,
    String? value,
    String? displayType,
    int? maxValue,
  }) {
    return NFTAttribute(
      traitType: traitType ?? this.traitType,
      value: value ?? this.value,
      displayType: displayType ?? this.displayType,
      maxValue: maxValue ?? this.maxValue,
    );
  }

  @override
  String toString() {
    return 'NFTAttribute(traitType: $traitType, value: $value)';
  }
}

/// Информация о файле в IPFS
class IPFSFileInfo {
  final String hash;
  final int size;
  final int cumulativeSize;
  final String type;
  final int blocks;
  final bool withLocality;
  final DateTime timestamp;

  IPFSFileInfo({
    required this.hash,
    required this.size,
    required this.cumulativeSize,
    required this.type,
    required this.blocks,
    required this.withLocality,
    required this.timestamp,
  });

  factory IPFSFileInfo.fromJson(Map<String, dynamic> json) {
    return IPFSFileInfo(
      hash: json['hash'] as String,
      size: json['size'] as int,
      cumulativeSize: json['cumulativeSize'] as int,
      type: json['type'] as String,
      blocks: json['blocks'] as int,
      withLocality: json['withLocality'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'size': size,
      'cumulativeSize': cumulativeSize,
      'type': type,
      'blocks': blocks,
      'withLocality': withLocality,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'IPFSFileInfo(hash: $hash, size: $size, type: $type, blocks: $blocks)';
  }
}

/// Статистика IPFS кэша
class IPFSCacheStats {
  final int totalEntries;
  final int cacheExpiryHours;
  final int cacheSizeBytes;

  IPFSCacheStats({
    required this.totalEntries,
    required this.cacheExpiryHours,
    required this.cacheSizeBytes,
  });

  factory IPFSCacheStats.fromJson(Map<String, dynamic> json) {
    return IPFSCacheStats(
      totalEntries: json['totalEntries'] as int,
      cacheExpiryHours: json['cacheExpiry'] as int,
      cacheSizeBytes: json['cacheSize'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'cacheExpiry': cacheExpiryHours,
      'cacheSize': cacheSizeBytes,
    };
  }

  /// Размер кэша в мегабайтах
  double get cacheSizeMB => cacheSizeBytes / (1024 * 1024);

  /// Размер кэша в килобайтах
  double get cacheSizeKB => cacheSizeBytes / 1024;

  @override
  String toString() {
    return 'IPFSCacheStats(totalEntries: $totalEntries, cacheSize: ${cacheSizeMB.toStringAsFixed(2)} MB)';
  }
}

/// Результат загрузки файла в IPFS
class IPFSUploadResult {
  final String hash;
  final String fileName;
  final int size;
  final String gatewayUrl;
  final DateTime timestamp;
  final bool success;
  final String? error;

  IPFSUploadResult({
    required this.hash,
    required this.fileName,
    required this.size,
    required this.gatewayUrl,
    required this.timestamp,
    required this.success,
    this.error,
  });

  factory IPFSUploadResult.success({
    required String hash,
    required String fileName,
    required int size,
    required String gatewayUrl,
  }) {
    return IPFSUploadResult(
      hash: hash,
      fileName: fileName,
      size: size,
      gatewayUrl: gatewayUrl,
      timestamp: DateTime.now(),
      success: true,
    );
  }

  factory IPFSUploadResult.error({
    required String fileName,
    required String error,
  }) {
    return IPFSUploadResult(
      hash: '',
      fileName: fileName,
      size: 0,
      gatewayUrl: '',
      timestamp: DateTime.now(),
      success: false,
      error: error,
    );
  }

  factory IPFSUploadResult.fromJson(Map<String, dynamic> json) {
    return IPFSUploadResult(
      hash: json['hash'] as String,
      fileName: json['fileName'] as String,
      size: json['size'] as int,
      gatewayUrl: json['gatewayUrl'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'fileName': fileName,
      'size': size,
      'gatewayUrl': gatewayUrl,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'error': error,
    };
  }

  @override
  String toString() {
    if (success) {
      return 'IPFSUploadResult.success(hash: $hash, fileName: $fileName, size: $size)';
    } else {
      return 'IPFSUploadResult.error(fileName: $fileName, error: $error)';
    }
  }
}

/// Запрос на загрузку файла в IPFS
class IPFSUploadRequest {
  final List<int> fileData;
  final String fileName;
  final String? contentType;
  final Map<String, dynamic>? metadata;
  final bool pinFile;

  IPFSUploadRequest({
    required this.fileData,
    required this.fileName,
    this.contentType,
    this.metadata,
    this.pinFile = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'contentType': contentType,
      'metadata': metadata,
      'pinFile': pinFile,
      'fileSize': fileData.length,
    };
  }

  @override
  String toString() {
    return 'IPFSUploadRequest(fileName: $fileName, size: ${fileData.length}, pinFile: $pinFile)';
  }
}

/// Ответ IPFS API
class IPFSAPIResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  final DateTime timestamp;

  IPFSAPIResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    required this.timestamp,
  });

  factory IPFSAPIResponse.success(T data) {
    return IPFSAPIResponse<T>(
      success: true,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  factory IPFSAPIResponse.error(String error, {int? statusCode}) {
    return IPFSAPIResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }

  factory IPFSAPIResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return IPFSAPIResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'] as String?,
      statusCode: json['statusCode'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
      'statusCode': statusCode,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    if (success) {
      return 'IPFSAPIResponse.success(data: $data)';
    } else {
      return 'IPFSAPIResponse.error(error: $error, statusCode: $statusCode)';
    }
  }
}
