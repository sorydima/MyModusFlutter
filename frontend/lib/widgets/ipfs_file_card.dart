import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../models/ipfs_models.dart';

/// Виджет для отображения информации о файле IPFS
class IPFSFileCard extends StatelessWidget {
  final IPFSFileMetadata file;
  final VoidCallback? onTap;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;
  final bool showPinStatus;

  const IPFSFileCard({
    super.key,
    required this.file,
    this.onTap,
    this.onPin,
    this.onDelete,
    this.showPinStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Иконка файла
              _buildFileIcon(context),
              const SizedBox(width: 12),
              
              // Информация о файле
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFileSize(file.size),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(file.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        if (showPinStatus && file.isPinned) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.push_pin,
                            size: 14,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Закреплен',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Действия
              if (onPin != null || onDelete != null)
                Column(
                  children: [
                    if (onPin != null)
                      IconButton(
                        onPressed: onPin,
                        icon: Icon(
                          file.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: file.isPinned ? Colors.blue[600] : Colors.grey[600],
                        ),
                        tooltip: file.isPinned ? 'Открепить' : 'Закрепить',
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'Удалить',
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Построение иконки файла
  Widget _buildFileIcon(BuildContext context) {
    final isImage = _isImageFile(file.contentType);
    final isVideo = _isVideoFile(file.contentType);
    final isAudio = _isAudioFile(file.contentType);
    final isDocument = _isDocumentFile(file.contentType);
    
    if (isImage) {
      return _buildImagePreview(context);
    }
    
    IconData iconData;
    Color iconColor;
    
    if (isVideo) {
      iconData = Icons.video_library;
      iconColor = Colors.red[600]!;
    } else if (isAudio) {
      iconData = Icons.audiotrack;
      iconColor = Colors.orange[600]!;
    } else if (isDocument) {
      iconData = Icons.description;
      iconColor = Colors.blue[600]!;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.grey[600]!;
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  /// Построение превью изображения
  Widget _buildImagePreview(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CachedNetworkImage(
          imageUrl: _getGatewayUrl(file.hash),
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// Проверка, является ли файл изображением
  bool _isImageFile(String? contentType) {
    return contentType?.startsWith('image/') ?? false;
  }

  /// Проверка, является ли файл видео
  bool _isVideoFile(String? contentType) {
    return contentType?.startsWith('video/') ?? false;
  }

  /// Проверка, является ли файл аудио
  bool _isAudioFile(String? contentType) {
    return contentType?.startsWith('audio/') ?? false;
  }

  /// Проверка, является ли файл документом
  bool _isDocumentFile(String? contentType) {
    return contentType?.startsWith('text/') || 
           contentType?.contains('document') ||
           contentType?.startsWith('application/pdf') ||
           contentType?.startsWith('application/msword') ||
           contentType?.startsWith('application/vnd.openxmlformats-officedocument') ??
           false;
  }

  /// Форматирование размера файла
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Форматирование временной метки
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'Только что';
    }
  }

  /// Получение URL для IPFS Gateway
  String _getGatewayUrl(String hash) {
    // В реальном приложении здесь должен быть URL вашего IPFS Gateway
    return 'http://localhost:8080/ipfs/$hash';
  }
}
