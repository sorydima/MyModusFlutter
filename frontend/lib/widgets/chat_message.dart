import 'package:flutter/material.dart';
import '../models/ai_models.dart';

class ChatMessage extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onImageTap;
  final VoidCallback? onCopy;
  final VoidCallback? onRegenerate;

  const ChatMessage({
    super.key,
    required this.message,
    this.onImageTap,
    this.onCopy,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == MessageRole.user;
    final isAssistant = message.role == MessageRole.assistant;
    final isSystem = message.role == MessageRole.system;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватар
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getAvatarColor(theme, message.role),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAvatarIcon(message.role),
              color: Colors.white,
              size: 18,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Содержимое сообщения
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок сообщения
                Row(
                  children: [
                    Text(
                      _getMessageTitle(message.role),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getAvatarColor(theme, message.role),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(message.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    if (message.status == MessageStatus.failed)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ошибка',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Основной контент
                _buildMessageContent(theme),
                
                // Дополнительная информация
                if (isAssistant && message.tokenCount != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${message.tokenCount} токенов',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                        if (message.cost != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${message.cost!.toStringAsFixed(4)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                
                // Действия для сообщений AI
                if (isAssistant && message.status != MessageStatus.failed)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        if (onCopy != null)
                          _buildActionButton(
                            theme,
                            Icons.copy,
                            'Копировать',
                            onCopy!,
                          ),
                        if (onRegenerate != null) ...[
                          const SizedBox(width: 12),
                          _buildActionButton(
                            theme,
                            Icons.refresh,
                            'Регенерировать',
                            onRegenerate!,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    switch (message.contentType) {
      case MessageContentType.text:
        return _buildTextContent(theme);
      case MessageContentType.image:
        return _buildImageContent(theme);
      case MessageContentType.voice:
        return _buildVoiceContent(theme);
      case MessageContentType.file:
        return _buildFileContent(theme);
      default:
        return _buildTextContent(theme);
    }
  }

  Widget _buildTextContent(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getMessageBackgroundColor(theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getMessageBorderColor(theme),
          width: 1,
        ),
      ),
      child: Text(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: _getMessageTextColor(theme),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImageContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.imageUrl != null)
          GestureDetector(
            onTap: onImageTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.broken_image,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildTextContent(theme),
        ],
      ],
    );
  }

  Widget _buildVoiceContent(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getMessageBackgroundColor(theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getMessageBorderColor(theme),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: _getAvatarColor(theme, message.role),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Голосовое сообщение',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _getMessageTextColor(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileContent(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getMessageBackgroundColor(theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getMessageBorderColor(theme),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_file,
            color: _getAvatarColor(theme, message.role),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Файл',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _getMessageTextColor(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(ThemeData theme, MessageRole role) {
    switch (role) {
      case MessageRole.user:
        return theme.colorScheme.primary;
      case MessageRole.assistant:
        return theme.colorScheme.secondary;
      case MessageRole.system:
        return Colors.grey;
    }
  }

  IconData _getAvatarIcon(MessageRole role) {
    switch (role) {
      case MessageRole.user:
        return Icons.person;
      case MessageRole.assistant:
        return Icons.psychology;
      case MessageRole.system:
        return Icons.settings;
    }
  }

  String _getMessageTitle(MessageRole role) {
    switch (role) {
      case MessageRole.user:
        return 'Вы';
      case MessageRole.assistant:
        return 'AI Ассистент';
      case MessageRole.system:
        return 'Система';
    }
  }

  Color _getMessageBackgroundColor(ThemeData theme) {
    final isUser = message.role == MessageRole.user;
    return isUser
        ? theme.colorScheme.primary.withOpacity(0.1)
        : theme.colorScheme.surface;
  }

  Color _getMessageBorderColor(ThemeData theme) {
    final isUser = message.role == MessageRole.user;
    return isUser
        ? theme.colorScheme.primary.withOpacity(0.2)
        : theme.colorScheme.outline.withOpacity(0.1);
  }

  Color _getMessageTextColor(ThemeData theme) {
    final isUser = message.role == MessageRole.user;
    return isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ч назад';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
    }
  }
}
