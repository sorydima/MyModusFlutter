import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import '../providers/ipfs_provider.dart';
import '../models/ipfs_models.dart';

/// Диалог для загрузки файлов в IPFS
class IPFSUploadDialog extends StatefulWidget {
  const IPFSUploadDialog({super.key});

  @override
  State<IPFSUploadDialog> createState() => _IPFSUploadDialogState();
}

class _IPFSUploadDialogState extends State<IPFSUploadDialog> {
  final List<IPFSUploadRequest> _uploadQueue = [];
  final TextEditingController _metadataController = TextEditingController();
  bool _isUploading = false;
  String? _error;
  String? _successMessage;

  @override
  void dispose() {
    _metadataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                const Icon(Icons.upload_file, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Загрузка файлов в IPFS',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Область загрузки файлов
            Expanded(
              child: _buildUploadArea(),
            ),
            
            const SizedBox(height: 20),
            
            // Кнопки действий
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Построение области загрузки
  Widget _buildUploadArea() {
    return Column(
      children: [
        // Кнопки выбора файлов
        _buildFileSelectionButtons(),
        const SizedBox(height: 20),
        
        // Область перетаскивания
        Expanded(
          child: _buildDragAndDropArea(),
        ),
        
        // Метаданные
        if (_uploadQueue.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildMetadataSection(),
        ],
      ],
    );
  }

  /// Кнопки выбора файлов
  Widget _buildFileSelectionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text('Изображение'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickDocument,
            icon: const Icon(Icons.description),
            label: const Text('Документ'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickVideo,
            icon: const Icon(Icons.video_library),
            label: const Text('Видео'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickMultipleFiles,
            icon: const Icon(Icons.folder_open),
            label: const Text('Множественно'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// Область перетаскивания
  Widget _buildDragAndDropArea() {
    if (_uploadQueue.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: _pickMultipleFiles,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Перетащите файлы сюда или нажмите для выбора',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Поддерживаются изображения, документы, видео и аудио',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Заголовок списка
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.queue, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Очередь загрузки (${_uploadQueue.length} файлов)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearQueue,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Очистить'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Список файлов
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _uploadQueue.length,
              itemBuilder: (context, index) {
                final file = _uploadQueue[index];
                return _buildFileItem(file, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Элемент файла в очереди
  Widget _buildFileItem(IPFSUploadRequest file, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _buildFileIcon(file),
        title: Text(
          file.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatFileSize(file.fileData.length),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: file.pinFile,
              onChanged: (value) => _togglePinFile(index, value),
            ),
            IconButton(
              onPressed: () => _removeFile(index),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              tooltip: 'Удалить из очереди',
            ),
          ],
        ),
      ),
    );
  }

  /// Иконка файла
  Widget _buildFileIcon(IPFSUploadRequest file) {
    final isImage = _isImageFile(file.contentType);
    final isVideo = _isVideoFile(file.contentType);
    final isAudio = _isAudioFile(file.contentType);
    final isDocument = _isDocumentFile(file.contentType);
    
    IconData iconData;
    Color iconColor;
    
    if (isImage) {
      iconData = Icons.image;
      iconColor = Colors.green[600]!;
    } else if (isVideo) {
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  /// Секция метаданных
  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Метаданные (опционально)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _metadataController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Введите JSON метаданные...',
            border: const OutlineInputBorder(),
            helperText: 'Например: {"category": "fashion", "tags": ["summer", "casual"]}',
          ),
        ),
      ],
    );
  }

  /// Кнопки действий
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isUploading || _uploadQueue.isEmpty ? null : _startUpload,
            child: _isUploading
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Загрузка...'),
                    ],
                  )
                : const Text('Начать загрузку'),
          ),
        ),
      ],
    );
  }

  /// Выбор изображения
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      _addFileToQueue(
        bytes,
        pickedFile.name,
        'image/${pickedFile.name.split('.').last}',
      );
    }
  }

  /// Выбор документа
  void _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      final file = result.files.first;
      if (file.bytes != null) {
        _addFileToQueue(
          file.bytes!,
          file.name,
          file.extension,
        );
      }
    }
  }

  /// Выбор видео
  void _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      _addFileToQueue(
        bytes,
        pickedFile.name,
        'video/${pickedFile.name.split('.').last}',
      );
    }
  }

  /// Выбор множественных файлов
  void _pickMultipleFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    
    if (result != null) {
      for (final file in result.files) {
        if (file.bytes != null) {
          _addFileToQueue(
            file.bytes!,
            file.name,
            file.extension,
          );
        }
      }
    }
  }

  /// Добавление файла в очередь
  void _addFileToQueue(Uint8List bytes, String fileName, String contentType) {
    setState(() {
      _uploadQueue.add(IPFSUploadRequest(
        fileData: bytes,
        fileName: fileName,
        contentType: contentType,
        pinFile: true,
      ));
    });
  }

  /// Удаление файла из очереди
  void _removeFile(int index) {
    setState(() {
      _uploadQueue.removeAt(index);
    });
  }

  /// Очистка очереди
  void _clearQueue() {
    setState(() {
      _uploadQueue.clear();
      _metadataController.clear();
    });
  }

  /// Переключение закрепления файла
  void _togglePinFile(int index, bool value) {
    setState(() {
      final file = _uploadQueue[index];
      _uploadQueue[index] = IPFSUploadRequest(
        fileData: file.fileData,
        fileName: file.fileName,
        contentType: file.contentType,
        metadata: file.metadata,
        pinFile: value,
      );
    });
  }

  /// Начало загрузки
  void _startUpload() async {
    if (_uploadQueue.isEmpty) return;

    setState(() {
      _isUploading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      final provider = context.read<IPFSProvider>();
      Map<String, dynamic>? metadata;
      
      // Парсим метаданные если они введены
      if (_metadataController.text.isNotEmpty) {
        try {
          metadata = jsonDecode(_metadataController.text);
        } catch (e) {
          setState(() {
            _error = 'Неверный формат JSON метаданных: $e';
          });
          return;
        }
      }

      int successCount = 0;
      int errorCount = 0;

      // Загружаем файлы по очереди
      for (final file in _uploadQueue) {
        try {
          final result = await provider.uploadFile(
            fileData: file.fileData,
            fileName: file.fileName,
            contentType: file.contentType,
            metadata: metadata,
            pinFile: file.pinFile,
          );

          if (result != null && result.success) {
            successCount++;
          } else {
            errorCount++;
          }
        } catch (e) {
          errorCount++;
        }
      }

      setState(() {
        if (errorCount == 0) {
          _successMessage = 'Все файлы успешно загружены!';
        } else if (successCount > 0) {
          _successMessage = 'Загружено $successCount из ${_uploadQueue.length} файлов';
        } else {
          _error = 'Ошибка загрузки всех файлов';
        }
      });

      // Очищаем очередь после успешной загрузки
      if (errorCount == 0) {
        _clearQueue();
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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

  /// Форматирование размера файла
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
