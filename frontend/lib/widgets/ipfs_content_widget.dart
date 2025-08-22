import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/ipfs_provider.dart';
import '../models/ipfs_models.dart';

/// Виджет для отображения IPFS контента в различных частях приложения
class IPFSContentWidget extends StatelessWidget {
  final String hash;
  final String? fileName;
  final String? contentType;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool showMetadata;
  final VoidCallback? onTap;
  final Widget? placeholder;
  final Widget? errorWidget;

  const IPFSContentWidget({
    super.key,
    required this.hash,
    this.fileName,
    this.contentType,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.showMetadata = false,
    this.onTap,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<IPFSProvider>(
      builder: (context, ipfsProvider, child) {
        // Получаем информацию о файле из провайдера
        final fileInfo = ipfsProvider.getFileByHash(hash);
        
        if (fileInfo != null) {
          return _buildContentFromFileInfo(context, fileInfo);
        } else {
          // Если файл не найден в провайдере, показываем базовую информацию
          return _buildBasicContent(context);
        }
      },
    );
  }

  /// Построение контента на основе информации о файле
  Widget _buildContentFromFileInfo(BuildContext context, IPFSFileMetadata fileInfo) {
    if (_isImageFile(fileInfo.contentType)) {
      return _buildImageContent(context, fileInfo);
    } else if (_isVideoFile(fileInfo.contentType)) {
      return _buildVideoContent(context, fileInfo);
    } else if (_isAudioFile(fileInfo.contentType)) {
      return _buildAudioContent(context, fileInfo);
    } else if (_isDocumentFile(fileInfo.contentType)) {
      return _buildDocumentContent(context, fileInfo);
    } else {
      return _buildGenericContent(context, fileInfo);
    }
  }

  /// Построение изображения
  Widget _buildImageContent(BuildContext context, IPFSFileMetadata fileInfo) {
    final content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CachedNetworkImage(
          imageUrl: _getGatewayUrl(hash),
          fit: fit,
          placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  /// Построение видео контента
  Widget _buildVideoContent(BuildContext context, IPFSFileMetadata fileInfo) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Превью видео (можно добавить thumbnail)
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.video_library,
              size: 48,
              color: Colors.white,
            ),
          ),
          // Кнопка воспроизведения
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              size: 32,
              color: Colors.white,
            ),
          ),
          // Индикатор типа файла
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Построение аудио контента
  Widget _buildAudioContent(BuildContext context, IPFSFileMetadata fileInfo) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.audiotrack,
            size: 32,
            color: Colors.orange[700],
          ),
          const SizedBox(height: 8),
          Text(
            fileName ?? 'Аудио файл',
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Построение документа
  Widget _buildDocumentContent(BuildContext context, IPFSFileMetadata fileInfo) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 32,
            color: Colors.blue[700],
          ),
          const SizedBox(height: 8),
          Text(
            fileName ?? 'Документ',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Построение общего контента
  Widget _buildGenericContent(BuildContext context, IPFSFileMetadata fileInfo) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 32,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            fileName ?? 'Файл',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Построение базового контента (когда файл не найден в провайдере)
  Widget _buildBasicContent(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_download,
            size: 32,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 8),
          Text(
            'IPFS контент',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Построение shimmer placeholder
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  /// Построение error widget
  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 24,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 4),
          Text(
            'Ошибка загрузки',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Проверка типа файла
  bool _isImageFile(String? contentType) {
    return contentType?.startsWith('image/') ?? false;
  }

  bool _isVideoFile(String? contentType) {
    return contentType?.startsWith('video/') ?? false;
  }

  bool _isAudioFile(String? contentType) {
    return contentType?.startsWith('audio/') ?? false;
  }

  bool _isDocumentFile(String? contentType) {
    return contentType?.startsWith('text/') || 
           contentType?.contains('document') ||
           contentType?.startsWith('application/pdf') ||
           contentType?.startsWith('application/msword') ||
           contentType?.startsWith('application/vnd.openxmlformats-officedocument') ??
           false;
  }

  /// Получение URL для IPFS Gateway
  String _getGatewayUrl(String hash) {
    // В реальном приложении здесь должен быть URL вашего IPFS Gateway
    return 'http://localhost:8080/ipfs/$hash';
  }
}

/// Виджет для отображения IPFS изображения с оптимизацией
class IPFSImageWidget extends StatelessWidget {
  final String hash;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Widget? placeholder;
  final Widget? errorWidget;

  const IPFSImageWidget({
    super.key,
    required this.hash,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onTap,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(7),
        child: CachedNetworkImage(
          imageUrl: _getGatewayUrl(hash),
          fit: fit,
          placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 24,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 4),
          Text(
            'Ошибка загрузки',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getGatewayUrl(String hash) {
    return 'http://localhost:8080/ipfs/$hash';
  }
}
