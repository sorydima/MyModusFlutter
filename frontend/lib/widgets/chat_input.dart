import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final Function(String)? onImageSelected;
  final VoidCallback? onVoiceMessage;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.onImageSelected,
    this.onVoiceMessage,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _isRecording = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Основная строка ввода
          Row(
            children: [
              // Кнопка расширения
              IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              
              // Поле ввода
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        widget.onSendMessage(text.trim());
                        widget.controller.clear();
                      }
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Кнопка отправки
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    final text = widget.controller.text.trim();
                    if (text.isNotEmpty) {
                      widget.onSendMessage(text);
                      widget.controller.clear();
                    }
                  },
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          // Дополнительные опции
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildAdditionalOptions(theme),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOptionButton(
            theme,
            Icons.camera_alt,
            'Камера',
            () => _showImageSourceDialog(context, ImageSource.camera),
          ),
          _buildOptionButton(
            theme,
            Icons.photo_library,
            'Галерея',
            () => _showImageSourceDialog(context, ImageSource.gallery),
          ),
          _buildOptionButton(
            theme,
            Icons.mic,
            'Голос',
            () => _toggleVoiceRecording(),
            isActive: _isRecording,
          ),
          _buildOptionButton(
            theme,
            Icons.attach_file,
            'Файл',
            () => _showFilePicker(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, ImageSource source) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              source == ImageSource.camera ? 'Сделать фото' : 'Выбрать из галереи',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceButton(
                  context,
                  Icons.camera_alt,
                  'Камера',
                  () {
                    Navigator.of(context).pop();
                    _handleImageSelection(source);
                  },
                ),
                _buildImageSourceButton(
                  context,
                  Icons.photo_library,
                  'Галерея',
                  () {
                    Navigator.of(context).pop();
                    _handleImageSelection(source);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleImageSelection(ImageSource source) {
    // TODO: Реализовать выбор изображения
    final imageUrl = source == ImageSource.camera
        ? 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=Photo+from+Camera'
        : 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=Photo+from+Gallery';
    
    if (widget.onImageSelected != null) {
      widget.onImageSelected!(imageUrl);
    }
  }

  void _toggleVoiceRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      // TODO: Начать запись голоса
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись голоса началась...')),
      );
    } else {
      // TODO: Остановить запись голоса
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись голоса остановлена')),
      );
    }
  }

  void _showFilePicker() {
    // TODO: Реализовать выбор файла
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выбор файла...')),
    );
  }
}

enum ImageSource {
  camera,
  gallery,
}
