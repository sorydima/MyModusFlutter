import 'package:flutter/material.dart';
import '../models/ai_models.dart';

class ChatSuggestions extends StatelessWidget {
  final Function(ChatSuggestion) onSuggestionSelected;

  const ChatSuggestions({
    super.key,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = PresetChatSuggestions.getAll();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Популярные вопросы',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return _buildSuggestionCard(theme, suggestion);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ThemeData theme, ChatSuggestion suggestion) {
    return GestureDetector(
      onTap: () => onSuggestionSelected(suggestion),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCategoryColor(suggestion.category).withOpacity(0.1),
              _getCategoryColor(suggestion.category).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getCategoryColor(suggestion.category).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getCategoryColor(suggestion.category).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Иконка категории
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(suggestion.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(suggestion.category),
                  color: _getCategoryColor(suggestion.category),
                  size: 20,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Текст предложения
              Expanded(
                child: Text(
                  suggestion.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Описание
              if (suggestion.description != null)
                Text(
                  suggestion.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 8),
              
              // Индикатор категории
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(suggestion.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getCategoryLabel(suggestion.category),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getCategoryColor(suggestion.category),
                    fontWeight: FontWeight.w600,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'style':
        return Colors.purple;
      case 'outfit':
        return Colors.blue;
      case 'analysis':
        return Colors.green;
      case 'trends':
        return Colors.orange;
      case 'shopping':
        return Colors.pink;
      case 'care':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'style':
        return Icons.style;
      case 'outfit':
        return Icons.checkroom;
      case 'analysis':
        return Icons.analytics;
      case 'trends':
        return Icons.trending_up;
      case 'shopping':
        return Icons.shopping_bag;
      case 'care':
        return Icons.cleaning_services;
      default:
        return Icons.help_outline;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'style':
        return 'СТИЛЬ';
      case 'outfit':
        return 'ОБРАЗ';
      case 'analysis':
        return 'АНАЛИЗ';
      case 'trends':
        return 'ТРЕНДЫ';
      case 'shopping':
        return 'ПОКУПКИ';
      case 'care':
        return 'УХОД';
      default:
        return 'ОБЩЕЕ';
    }
  }
}
