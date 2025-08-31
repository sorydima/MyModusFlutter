import 'package:flutter/material.dart';

class NFTFilterBar extends StatefulWidget {
  final String selectedFilter;
  final String selectedSort;
  final bool showOnlyMyNFTs;
  final Function(String) onFilterChanged;
  final Function(String) onSortChanged;
  final Function(bool) onMyNFTsChanged;

  const NFTFilterBar({
    super.key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.showOnlyMyNFTs,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onMyNFTsChanged,
  });

  @override
  State<NFTFilterBar> createState() => _NFTFilterBarState();
}

class _NFTFilterBarState extends State<NFTFilterBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            'Фильтры и сортировка',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Фильтры по категориям
          _buildFilterSection(theme),
          
          const SizedBox(height: 20),
          
          // Сортировка
          _buildSortSection(theme),
          
          const SizedBox(height: 20),
          
          // Переключатель "Только мои NFT"
          _buildMyNFTsToggle(theme),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    final filters = [
      {'id': 'all', 'label': 'Все', 'icon': Icons.all_inclusive},
      {'id': 'fashion', 'label': 'Мода', 'icon': Icons.style},
      {'id': 'sneakers', 'label': 'Кроссовки', 'icon': Icons.sports_soccer},
      {'id': 'luxury', 'label': 'Люкс', 'icon': Icons.diamond},
      {'id': 'art', 'label': 'Искусство', 'icon': Icons.palette},
      {'id': 'gaming', 'label': 'Игры', 'icon': Icons.games},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Категории',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.map((filter) {
            final isSelected = widget.selectedFilter == filter['id'];
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 6),
                  Text(filter['label'] as String),
                ],
              ),
              onSelected: (selected) {
                widget.onFilterChanged(filter['id'] as String);
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortSection(ThemeData theme) {
    final sortOptions = [
      {'id': 'recent', 'label': 'По дате', 'icon': Icons.schedule},
      {'id': 'price_low', 'label': 'Цена: по возрастанию', 'icon': Icons.trending_up},
      {'id': 'price_high', 'label': 'Цена: по убыванию', 'icon': Icons.trending_down},
      {'id': 'popular', 'label': 'По популярности', 'icon': Icons.favorite},
      {'id': 'rarity', 'label': 'По редкости', 'icon': Icons.star},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сортировка',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: widget.selectedSort,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: sortOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option['id'] as String,
              child: Row(
                children: [
                  Icon(
                    option['icon'] as IconData,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Text(option['label'] as String),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onSortChanged(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMyNFTsToggle(ThemeData theme) {
    return Row(
      children: [
        Switch(
          value: widget.showOnlyMyNFTs,
          onChanged: widget.onMyNFTsChanged,
          activeColor: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Только мои NFT',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Показать только NFT из вашей коллекции',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
