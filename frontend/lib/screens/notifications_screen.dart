import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _searchQuery = '';
  NotificationType? _selectedType;
  bool _showOnlyUnread = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Уведомления'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Кнопка очистки прочитанных
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              final notificationService = Provider.of<NotificationService>(context, listen: false);
              notificationService.markAllAsRead();
            },
            tooltip: 'Отметить все как прочитанные',
          ),
          // Кнопка тестового уведомления
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: () {
              final notificationService = Provider.of<NotificationService>(context, listen: false);
              notificationService.notifyPersonalShopper('user_123', 'Это тестовое уведомление!');
            },
            tooltip: 'Отправить тестовое уведомление',
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтры и поиск
          _buildFiltersAndSearch(),
          
          // Список уведомлений
          Expanded(
            child: Consumer<NotificationService>(
              builder: (context, notificationService, child) {
                if (notificationService.notifications.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredNotifications = _getFilteredNotifications(notificationService.notifications);
                
                if (filteredNotifications.isEmpty) {
                  return _buildNoResultsState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = filteredNotifications[index];
                    return _buildNotificationCard(
                      context,
                      notification,
                      notificationService,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Поиск
          TextField(
            decoration: InputDecoration(
              hintText: 'Поиск уведомлений...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Фильтры
          Row(
            children: [
              // Фильтр по типу
              Expanded(
                child: DropdownButtonFormField<NotificationType?>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Тип уведомления',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Все типы'),
                    ),
                    ...NotificationType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getNotificationTypeText(type)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Переключатель "Только непрочитанные"
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _showOnlyUnread,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyUnread = value ?? false;
                      });
                    },
                  ),
                  const Text('Только непрочитанные'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Уведомлений пока нет',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь будут появляться уведомления о новых рекомендациях, скидках и обновлениях',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Ничего не найдено',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить параметры поиска или фильтры',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> notification,
    NotificationService notificationService,
  ) {
    final theme = Theme.of(context);
    final isRead = notification['isRead'] ?? false;
    final timestamp = notification['timestamp'] as DateTime;
    final type = _parseNotificationType(notification['type']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRead 
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Иконка типа уведомления
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationTypeColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationTypeIcon(type),
                  color: _getNotificationTypeColor(type),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Содержимое уведомления
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                              color: isRead 
                                  ? theme.colorScheme.onSurface.withOpacity(0.7)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      notification['body'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Действия
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isRead)
                              TextButton(
                                onPressed: () {
                                  final id = notification['id'] as int;
                                  notificationService.markAsRead(id);
                                },
                                child: const Text('Прочитано'),
                              ),
                            IconButton(
                              onPressed: () {
                                final id = notification['id'] as int;
                                notificationService.removeNotification(id);
                              },
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Удалить',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotifications(List<Map<String, dynamic>> notifications) {
    return notifications.where((notification) {
      // Фильтр по поиску
      if (_searchQuery.isNotEmpty) {
        final title = (notification['title'] as String?)?.toLowerCase() ?? '';
        final body = (notification['body'] as String?)?.toLowerCase() ?? '';
        final searchQuery = _searchQuery.toLowerCase();
        
        if (!title.contains(searchQuery) && !body.contains(searchQuery)) {
          return false;
        }
      }
      
      // Фильтр по типу
      if (_selectedType != null) {
        final type = _parseNotificationType(notification['type']);
        if (type != _selectedType) {
          return false;
        }
      }
      
      // Фильтр по статусу прочтения
      if (_showOnlyUnread) {
        final isRead = notification['isRead'] ?? false;
        if (isRead) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  NotificationType _parseNotificationType(String typeString) {
    try {
      return NotificationType.values.firstWhere(
        (type) => type.toString() == typeString,
        orElse: () => NotificationType.newRecommendations,
      );
    } catch (e) {
      return NotificationType.newRecommendations;
    }
  }

  String _getNotificationTypeText(NotificationType type) {
    switch (type) {
      case NotificationType.newRecommendations:
        return 'Новые рекомендации';
      case NotificationType.priceAlert:
        return 'Изменение цены';
      case NotificationType.trendingItem:
        return 'Трендовые товары';
      case NotificationType.personalShopper:
        return 'AI Шоппер';
      case NotificationType.wishlistUpdate:
        return 'Обновление избранного';
      case NotificationType.saleNotification:
        return 'Распродажи';
      case NotificationType.newCollection:
        return 'Новые коллекции';
      case NotificationType.backInStock:
        return 'Возвращение в наличии';
    }
  }

  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.newRecommendations:
        return Colors.blue;
      case NotificationType.priceAlert:
        return Colors.orange;
      case NotificationType.trendingItem:
        return Colors.purple;
      case NotificationType.personalShopper:
        return Colors.green;
      case NotificationType.wishlistUpdate:
        return Colors.red;
      case NotificationType.saleNotification:
        return Colors.pink;
      case NotificationType.newCollection:
        return Colors.indigo;
      case NotificationType.backInStock:
        return Colors.teal;
    }
  }

  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newRecommendations:
        return Icons.recommend;
      case NotificationType.priceAlert:
        return Icons.price_change;
      case NotificationType.trendingItem:
        return Icons.trending_up;
      case NotificationType.personalShopper:
        return Icons.person;
      case NotificationType.wishlistUpdate:
        return Icons.favorite;
      case NotificationType.saleNotification:
        return Icons.local_offer;
      case NotificationType.newCollection:
        return Icons.collections;
      case NotificationType.backInStock:
        return Icons.inventory;
    }
  }

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

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = _parseNotificationType(notification['type']);
    final payload = notification['payload'] as Map<String, dynamic>?;
    
    switch (type) {
      case NotificationType.newRecommendations:
        _showRecommendationsDetails(notification);
        break;
      case NotificationType.priceAlert:
        _showPriceAlertDetails(notification);
        break;
      case NotificationType.trendingItem:
        _showTrendingItemDetails(notification);
        break;
      case NotificationType.personalShopper:
        _showPersonalShopperDetails(notification);
        break;
      case NotificationType.wishlistUpdate:
        _showWishlistUpdateDetails(notification);
        break;
      case NotificationType.saleNotification:
        _showSaleDetails(notification);
        break;
      case NotificationType.newCollection:
        _showNewCollectionDetails(notification);
        break;
      case NotificationType.backInStock:
        _showBackInStockDetails(notification);
        break;
    }
    
    // Отмечаем как прочитанное
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final id = notification['id'] as int;
    notificationService.markAsRead(id);
  }

  void _showRecommendationsDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? ''),
        content: Text(notification['body'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Переход к рекомендациям
            },
            child: const Text('Посмотреть'),
          ),
        ],
      ),
    );
  }

  void _showPriceAlertDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? ''),
        content: Text(notification['body'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Переход к товару
            },
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }

  void _showTrendingItemDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? ''),
        content: Text(notification['body'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Переход к трендовому товару
            },
            child: const Text('Посмотреть'),
          ),
        ],
      ),
    );
  }

  void _showPersonalShopperDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? ''),
        content: Text(notification['body'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Переход к AI шопперу
            },
            child: const Text('Открыть'),
          ),
        ],
      ),
    );
  }

  void _showWishlistUpdateDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? ''),
        content: Text(notification['body'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Переход к избранному
            },
            child: const Text('Открыть'),
          ),
        ],
      ),
    );
  }

  void _showSaleDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? ''),
        content: Text(notification['body'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Переход к распродаже
            },
            child: const Text('Посмотреть'),
          ),
        ],
      ),
    );
  }

  void _showNewCollectionDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? ''),
        content: Text(notification['body'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Переход к новой коллекции
            },
            child: const Text('Посмотреть'),
          ),
        ],
      ),
    );
  }

  void _showBackInStockDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? ''),
        content: Text(notification['body'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Переход к товару
            },
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }
}