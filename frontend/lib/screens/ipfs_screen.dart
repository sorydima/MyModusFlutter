import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';  // Временно отключаем
import 'package:shimmer/shimmer.dart';

import '../providers/ipfs_provider.dart';
import '../models/ipfs_models.dart';
import '../widgets/ipfs_file_card.dart';
import '../widgets/ipfs_upload_dialog.dart';
import '../widgets/ipfs_nft_dialog.dart';

/// Основной экран для управления IPFS
class IPFSScreen extends StatefulWidget {
  const IPFSScreen({super.key});

  @override
  State<IPFSScreen> createState() => _IPFSScreenState();
}

class _IPFSScreenState extends State<IPFSScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFileType;
  String? _selectedSizeRange;
  String? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Инициализируем IPFS провайдер
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IPFSProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPFS Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
            tooltip: 'Обновить данные',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(),
            tooltip: 'Настройки',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.upload), text: 'Загрузка'),
            Tab(icon: Icon(Icons.folder), text: 'Файлы'),
            Tab(icon: Icon(Icons.push_pin), text: 'Закрепленные'),
            Tab(icon: Icon(Icons.analytics), text: 'Статистика'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadTab(),
          _buildFilesTab(),
          _buildPinnedTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Загрузить файл',
      ),
    );
  }

  /// Вкладка загрузки
  Widget _buildUploadTab() {
    return Consumer<IPFSProvider>(
      builder: (context, ipfsProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Быстрые действия
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Быстрые действия',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(),
                              icon: const Icon(Icons.image),
                              label: const Text('Изображение'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickDocument(),
                              icon: const Icon(Icons.description),
                              label: const Text('Документ'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickVideo(),
                              icon: const Icon(Icons.video_library),
                              label: const Text('Видео'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showNFTDialog(),
                              icon: const Icon(Icons.image),
                              label: const Text('NFT'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Последние загрузки
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Последние загрузки',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (ipfsProvider.uploadedFiles.isEmpty)
                        const Center(
                          child: Text(
                            'Нет загруженных файлов',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ipfsProvider.uploadedFiles.take(5).length,
                          itemBuilder: (context, index) {
                            final file = ipfsProvider.uploadedFiles[index];
                            return IPFSFileCard(
                              file: file,
                              onTap: () => _showFileDetails(file),
                              onPin: () => _togglePin(file),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Вкладка файлов
  Widget _buildFilesTab() {
    return Consumer<IPFSProvider>(
      builder: (context, ipfsProvider, child) {
        final filteredFiles = _getFilteredFiles(ipfsProvider.uploadedFiles);
        
        return Column(
          children: [
            // Фильтры и поиск
            _buildFiltersAndSearch(),
            
            // Список файлов
            Expanded(
              child: filteredFiles.isEmpty
                  ? const Center(
                      child: Text(
                        'Файлы не найдены',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredFiles.length,
                      itemBuilder: (context, index) {
                        final file = filteredFiles[index];
                        return IPFSFileCard(
                          file: file,
                          onTap: () => _showFileDetails(file),
                          onPin: () => _togglePin(file),
                          onDelete: () => _deleteFile(file),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Вкладка закрепленных файлов
  Widget _buildPinnedTab() {
    return Consumer<IPFSProvider>(
      builder: (context, ipfsProvider, child) {
        final pinnedFiles = ipfsProvider.uploadedFiles
            .where((file) => ipfsProvider.pinnedFiles.contains(file.hash))
            .toList();
        
        return Column(
          children: [
            // Статистика закрепленных файлов
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Всего закреплено',
                      '${pinnedFiles.length}',
                      Icons.push_pin,
                    ),
                    _buildStatItem(
                      'Общий размер',
                      '${_formatTotalSize(pinnedFiles)}',
                      Icons.storage,
                    ),
                    _buildStatItem(
                      'Последнее обновление',
                      _formatLastUpdate(pinnedFiles),
                      Icons.update,
                    ),
                  ],
                ),
              ),
            ),
            
            // Список закрепленных файлов
            Expanded(
              child: pinnedFiles.isEmpty
                  ? const Center(
                      child: Text(
                        'Нет закрепленных файлов',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pinnedFiles.length,
                      itemBuilder: (context, index) {
                        final file = pinnedFiles[index];
                        return IPFSFileCard(
                          file: file,
                          onTap: () => _showFileDetails(file),
                          onPin: () => _togglePin(file),
                          showPinStatus: true,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Вкладка статистики
  Widget _buildStatsTab() {
    return Consumer<IPFSProvider>(
      builder: (context, ipfsProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Общая статистика
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Общая статистика',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Всего файлов',
                              '${ipfsProvider.uploadedFiles.length}',
                              Icons.folder,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Закреплено',
                              '${ipfsProvider.pinnedFiles.length}',
                              Icons.push_pin,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Общий размер',
                              _formatTotalSize(ipfsProvider.uploadedFiles),
                              Icons.storage,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Статистика по типам файлов
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'По типам файлов',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildFileTypeStats(ipfsProvider.uploadedFiles),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Статистика кэша
              if (ipfsProvider.cacheStats != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Статистика кэша',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildCacheStats(ipfsProvider.cacheStats!),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Фильтры и поиск
  Widget _buildFiltersAndSearch() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Поиск
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск файлов...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            
            // Фильтры
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFileType,
                    decoration: const InputDecoration(
                      labelText: 'Тип файла',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все типы')),
                      const DropdownMenuItem(value: 'image', child: Text('Изображения')),
                      const DropdownMenuItem(value: 'video', child: Text('Видео')),
                      const DropdownMenuItem(value: 'audio', child: Text('Аудио')),
                      const DropdownMenuItem(value: 'document', child: Text('Документы')),
                      const DropdownMenuItem(value: 'application', child: Text('Приложения')),
                    ],
                    onChanged: (value) => setState(() => _selectedFileType = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSizeRange,
                    decoration: const InputDecoration(
                      labelText: 'Размер',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Любой размер')),
                      const DropdownMenuItem(value: 'small', child: Text('< 1 MB')),
                      const DropdownMenuItem(value: 'medium', child: Text('1-10 MB')),
                      const DropdownMenuItem(value: 'large', child: Text('> 10 MB')),
                    ],
                    onChanged: (value) => setState(() => _selectedSizeRange = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Элемент статистики
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Статистика по типам файлов
  Widget _buildFileTypeStats(List<IPFSFileMetadata> files) {
    final typeStats = <String, int>{};
    final typeSizes = <String, int>{};
    
    for (final file in files) {
      final type = _getFileType(file.contentType);
      typeStats[type] = (typeStats[type] ?? 0) + 1;
      typeSizes[type] = (typeSizes[type] ?? 0) + file.size;
    }
    
    return Column(
      children: typeStats.entries.map((entry) {
        final type = entry.key;
        final count = entry.value;
        final size = typeSizes[type] ?? 0;
        
        return ListTile(
          leading: Icon(_getFileTypeIcon(type)),
          title: Text(type),
          subtitle: Text('$count файлов'),
          trailing: Text(_formatFileSize(size)),
        );
      }).toList(),
    );
  }

  /// Статистика кэша
  Widget _buildCacheStats(IPFSCacheStats stats) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('Всего записей'),
          trailing: Text('${stats.totalEntries}'),
        ),
        ListTile(
          leading: const Icon(Icons.timer),
          title: const Text('Время жизни кэша'),
          trailing: Text('${stats.cacheExpiryHours} ч'),
        ),
        ListTile(
          leading: const Icon(Icons.data_usage),
          title: const Text('Размер кэша'),
          trailing: Text('${stats.cacheSizeMB.toStringAsFixed(2)} MB'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _clearCache(),
                icon: const Icon(Icons.clear_all),
                label: const Text('Очистить кэш'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _cleanExpiredCache(),
                icon: const Icon(Icons.cleaning_services),
                label: const Text('Очистить устаревшие'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Получение отфильтрованных файлов
  List<IPFSFileMetadata> _getFilteredFiles(List<IPFSFileMetadata> files) {
    var filtered = files;
    
    // Поиск
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((file) {
        final fileName = file.fileName.toLowerCase();
        final searchQuery = _searchQuery.toLowerCase();
        return fileName.contains(searchQuery);
      }).toList();
    }
    
    // Фильтр по типу
    if (_selectedFileType != null) {
      filtered = filtered.where((file) {
        return _getFileType(file.contentType) == _selectedFileType;
      }).toList();
    }
    
    // Фильтр по размеру
    if (_selectedSizeRange != null) {
      filtered = filtered.where((file) {
        final sizeMB = file.size / (1024 * 1024);
        switch (_selectedSizeRange) {
          case 'small':
            return sizeMB < 1;
          case 'medium':
            return sizeMB >= 1 && sizeMB <= 10;
          case 'large':
            return sizeMB > 10;
          default:
            return true;
        }
      }).toList();
    }
    
    return filtered;
  }

  /// Получение типа файла
  String _getFileType(String? contentType) {
    if (contentType == null) return 'Unknown';
    
    if (contentType.startsWith('image/')) return 'Image';
    if (contentType.startsWith('video/')) return 'Video';
    if (contentType.startsWith('audio/')) return 'Audio';
    if (contentType.startsWith('text/') || contentType.contains('document')) return 'Document';
    if (contentType.startsWith('application/')) return 'Application';
    
    return 'Other';
  }

  /// Получение иконки для типа файла
  IconData _getFileTypeIcon(String type) {
    switch (type) {
      case 'Image':
        return Icons.image;
      case 'Video':
        return Icons.video_library;
      case 'Audio':
        return Icons.audiotrack;
      case 'Document':
        return Icons.description;
      case 'Application':
        return Icons.apps;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Форматирование размера файла
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Форматирование общего размера
  String _formatTotalSize(List<IPFSFileMetadata> files) {
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.size);
    return _formatFileSize(totalBytes);
  }

  /// Форматирование последнего обновления
  String _formatLastUpdate(List<IPFSFileMetadata> files) {
    if (files.isEmpty) return 'Нет данных';
    
    final latest = files.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
    final now = DateTime.now();
    final difference = now.difference(latest.timestamp);
    
    if (difference.inDays > 0) return '${difference.inDays} дн. назад';
    if (difference.inHours > 0) return '${difference.inHours} ч. назад';
    if (difference.inMinutes > 0) return '${difference.inMinutes} мин. назад';
    return 'Только что';
  }

  /// Обновление данных
  void _refreshData() {
    final provider = context.read<IPFSProvider>();
    provider.refreshPinnedFiles();
    provider.refreshCacheStats();
  }

  /// Показать настройки
  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки IPFS'),
        content: const Text('Настройки будут добавлены позже'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Показать диалог загрузки
  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => const IPFSUploadDialog(),
    );
  }

  /// Показать диалог NFT
  void _showNFTDialog() {
    showDialog(
      context: context,
      builder: (context) => const IPFSNFTDialog(),
    );
  }

  /// Выбор изображения
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      _uploadFile(bytes, pickedFile.name, 'image/${pickedFile.name.split('.').last}');
    }
  }

  /// Выбор документа
  void _pickDocument() async {
          // final result = await FilePicker.platform.pickFiles();  // Временно отключаем
      // TODO: Реализовать выбор файлов без file_picker
      return;
    
    if (result != null) {
      final file = result.files.first;
      if (file.bytes != null) {
        _uploadFile(file.bytes!, file.name, file.extension);
      }
    }
  }

  /// Выбор видео
  void _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      _uploadFile(bytes, pickedFile.name, 'video/${pickedFile.name.split('.').last}');
    }
  }

  /// Загрузка файла
  void _uploadFile(Uint8List bytes, String fileName, String contentType) {
    final provider = context.read<IPFSProvider>();
    provider.uploadFile(
      fileData: bytes,
      fileName: fileName,
      contentType: contentType,
    );
  }

  /// Показать детали файла
  void _showFileDetails(IPFSFileMetadata file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.fileName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Хеш: ${file.hash}'),
            Text('Размер: ${_formatFileSize(file.size)}'),
            Text('Тип: ${file.contentType ?? 'Неизвестно'}'),
            Text('Дата: ${file.timestamp.toString()}'),
            Text('Закреплен: ${file.isPinned ? 'Да' : 'Нет'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  /// Переключение закрепления
  void _togglePin(IPFSFileMetadata file) {
    final provider = context.read<IPFSProvider>();
    if (file.isPinned) {
      provider.unpinFile(file.hash);
    } else {
      provider.pinFile(file.hash);
    }
  }

  /// Удаление файла
  void _deleteFile(IPFSFileMetadata file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить файл?'),
        content: Text('Файл "${file.fileName}" будет удален из списка.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<IPFSProvider>().removeFileFromList(file.hash);
              Navigator.of(context).pop();
            },
            child: const Text('Удалить'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  /// Очистка кэша
  void _clearCache() {
    context.read<IPFSProvider>().clearCache();
  }

  /// Очистка устаревших записей кэша
  void _cleanExpiredCache() {
    context.read<IPFSProvider>().cleanExpiredCache();
  }
}
