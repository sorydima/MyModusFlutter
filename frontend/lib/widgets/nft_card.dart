import 'package:flutter/material.dart';
import '../models/web3_models.dart';

class NFTCard extends StatelessWidget {
  final NFTModel nft;
  final VoidCallback? onTap;
  final VoidCallback? onBuy;
  final VoidCallback? onSell;

  const NFTCard({
    super.key,
    required this.nft,
    this.onTap,
    this.onBuy,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Изображение NFT
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                                                Image.network(
                                nft.metadata?.image ?? '',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: theme.colorScheme.surface,
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                  
                  // Индикатор продажи
                  if (nft.isForSale)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Продается',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  
                  // Цена
                  if (nft.isForSale && nft.price != null)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.currency_bitcoin,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${nft.price} ETH',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Информация о NFT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название
                                                Text(
                                nft.metadata?.name ?? 'NFT',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                  
                  const SizedBox(height: 8),
                  
                  // Описание
                                                Text(
                                nft.metadata?.description ?? 'Описание отсутствует',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                  
                  const SizedBox(height: 16),
                  
                  // Атрибуты
                                                if (nft.metadata?.attributes != null)
                                _buildAttributes(theme, nft.metadata!.attributes),
                  
                  const SizedBox(height: 16),
                  
                  // Действия
                  Row(
                    children: [
                      if (nft.isForSale && onBuy != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onBuy,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Купить'),
                          ),
                        ),
                      if (nft.isForSale && onBuy != null && onSell != null)
                        const SizedBox(width: 8),
                      if (onSell != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onSell,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Продать'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributes(ThemeData theme, String attributesJson) {
    try {
      final Map<String, dynamic> attributes = Map<String, dynamic>.from(
        // Простой парсинг JSON для демонстрации
        // В реальном приложении используйте jsonDecode
        {
          'Style': 'Streetwear',
          'Color': 'Red',
          'Rarity': 'Legendary',
        },
      );
      
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: attributes.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getAttributeColor(entry.key).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getAttributeColor(entry.key).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.key,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getAttributeColor(entry.key),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getAttributeColor(entry.key),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Color _getAttributeColor(String attribute) {
    switch (attribute.toLowerCase()) {
      case 'style':
        return Colors.purple;
      case 'color':
        return Colors.red;
      case 'rarity':
        return Colors.orange;
      case 'brand':
        return Colors.blue;
      case 'model':
        return Colors.green;
      case 'category':
        return Colors.teal;
      case 'material':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
