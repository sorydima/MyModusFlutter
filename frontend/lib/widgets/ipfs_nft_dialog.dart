import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/ipfs_provider.dart';
import '../models/ipfs_models.dart';

/// Диалог для создания и загрузки NFT метаданных в IPFS
class IPFSNFTDialog extends StatefulWidget {
  const IPFSNFTDialog({super.key});

  @override
  State<IPFSNFTDialog> createState() => _IPFSNFTDialogState();
}

class _IPFSNFTDialogState extends State<IPFSNFTDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _externalUrlController = TextEditingController();
  
  final List<NFTAttribute> _attributes = [];
  final List<TextEditingController> _attributeControllers = [];
  
  String? _imageUrl;
  bool _isUploading = false;
  String? _error;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _externalUrlController.dispose();
    for (final controller in _attributeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                const Icon(Icons.nft, size: 28, color: Colors.purple),
                const SizedBox(width: 12),
                Text(
                  'Создание NFT метаданных',
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
            
            // Форма
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Основная информация
                      _buildBasicInfoSection(),
                      const SizedBox(height: 20),
                      
                      // Изображение
                      _buildImageSection(),
                      const SizedBox(height: 20),
                      
                      // Атрибуты
                      _buildAttributesSection(),
                      const SizedBox(height: 20),
                      
                      // Дополнительная информация
                      _buildAdditionalInfoSection(),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Кнопки действий
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Секция основной информации
  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Основная информация',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название NFT *',
                hintText: 'Введите название вашего NFT',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите название';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Описание *',
                hintText: 'Опишите ваш NFT',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите описание';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Секция изображения
  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Изображение',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            if (_imageUrl != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Выбрать изображение'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_imageUrl != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _removeImage,
                      icon: const Icon(Icons.delete),
                      label: const Text('Убрать'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            if (_imageUrl == null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нажмите для выбора изображения',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Секция атрибутов
  Widget _buildAttributesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Атрибуты',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addAttribute,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_attributes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.category,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Нет атрибутов',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Добавьте атрибуты для вашего NFT',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _attributes.length,
                itemBuilder: (context, index) {
                  return _buildAttributeItem(index);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Элемент атрибута
  Widget _buildAttributeItem(int index) {
    final attribute = _attributes[index];
    final controller = _attributeControllers[index];
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Атрибут ${index + 1}',
                  hintText: 'Например: Редкость, Тип, Цвет',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _attributes[index] = NFTAttribute(
                    traitType: value,
                    value: attribute.value,
                    displayType: attribute.displayType,
                    maxValue: attribute.maxValue,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: attribute.value,
                decoration: const InputDecoration(
                  labelText: 'Значение',
                  hintText: 'Например: Легендарный, Меч, Синий',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _attributes[index] = NFTAttribute(
                    traitType: attribute.traitType,
                    value: value,
                    displayType: attribute.displayType,
                    maxValue: attribute.maxValue,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _removeAttribute(index),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              tooltip: 'Удалить атрибут',
            ),
          ],
        ),
      ),
    );
  }

  /// Секция дополнительной информации
  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дополнительная информация',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _externalUrlController,
              decoration: const InputDecoration(
                labelText: 'Внешняя ссылка (опционально)',
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
          ],
        ),
      ),
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
            onPressed: _isUploading || !_isFormValid() ? null : _uploadNFT,
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
                : const Text('Создать NFT'),
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
      setState(() {
        _imageUrl = pickedFile.path;
      });
    }
  }

  /// Убрать изображение
  void _removeImage() {
    setState(() {
      _imageUrl = null;
    });
  }

  /// Добавить атрибут
  void _addAttribute() {
    setState(() {
      final newAttribute = NFTAttribute(
        traitType: '',
        value: '',
      );
      _attributes.add(newAttribute);
      _attributeControllers.add(TextEditingController());
    });
  }

  /// Удалить атрибут
  void _removeAttribute(int index) {
    setState(() {
      _attributes.removeAt(index);
      _attributeControllers[index].dispose();
      _attributeControllers.removeAt(index);
    });
  }

  /// Проверка валидности формы
  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
           _descriptionController.text.isNotEmpty &&
           _imageUrl != null &&
           _attributes.isNotEmpty &&
           _attributes.every((attr) => attr.traitType.isNotEmpty && attr.value.isNotEmpty);
  }

  /// Загрузка NFT
  void _uploadNFT() async {
    if (!_isFormValid()) return;

    setState(() {
      _isUploading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      final provider = context.read<IPFSProvider>();
      
      // В реальном приложении здесь нужно сначала загрузить изображение в IPFS
      // и получить его хеш для использования в метаданных
      final imageUrl = _imageUrl!; // Временно используем локальный путь
      
      final result = await provider.uploadNFTMetadata(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: imageUrl,
        attributes: _attributes,
        externalUrl: _externalUrlController.text.isNotEmpty 
            ? _externalUrlController.text 
            : null,
      );

      if (result != null && result.success) {
        setState(() {
          _successMessage = 'NFT метаданные успешно созданы! Хеш: ${result.hash}';
        });
        
        // Очищаем форму после успешной загрузки
        _clearForm();
      } else {
        setState(() {
          _error = 'Ошибка создания NFT: ${result?.error ?? 'Неизвестная ошибка'}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка создания NFT: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// Очистка формы
  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _externalUrlController.clear();
    setState(() {
      _imageUrl = null;
      _attributes.clear();
      for (final controller in _attributeControllers) {
        controller.dispose();
      }
      _attributeControllers.clear();
    });
  }
}
