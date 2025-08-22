import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  NotificationType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Уведомления'),
            elevation: 0,
            actions: [
              if (notificationService.unreadCount > 0)
                TextButton(
                  onPressed: () => notificationService.markAllAsRead(),
                  child: const Text('Прочитать все'),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear_read',
                    child: Row(
                      children: [
                        Icon(Icons.clear),
                        SizedBox(width: 8),
                        Text('Очистить прочитанные'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Очистить все', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Настройки'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'test',
                    child: Row(
                      children: [
                        Icon(Icons.bug_report),
                        SizedBox(width: 8),
                        Text('Тест уведомления'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'clear_read':
                      notificationService.clearRead();
                      break;
                    case 'clear_all':
                      _showClearAllDialog(notificationService);
                      break;
                    case 'settings':
                      _showSettingsDialog(notificationService);
                      break;
                    case 'test':
                      notificationService.sendTestNotification();
                      break;
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Все'),
                      if (notificationService.notifications.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${notificationService.notifications.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Непрочитанные'),
                      if (notificationService.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${notificationService.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              _buildSearchAndFilter(notificationService),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationsList(
                      notificationService.notifications,
                      notificationService,
                    ),
                    _buildNotificationsList(
                      notificationService.unreadNotifications,
                      notificationService,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter(NotificationService notificationService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Поиск уведомлений...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Все',
                  _selectedType == null,
                  () => setState(() => _selectedType = null),
                ),
                const SizedBox(width: 8),
                ...NotificationType.values.map((type) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      _getTypeDisplayName(type),
                      _selectedType == type,
                      () => setState(() => _selectedType = type),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.newRecommendations:
        return 'Рекомендации';
      case NotificationType.priceAlert:
        return 'Цены';
      case NotificationType.personalizedOffer:
        return 'Предложения';
      case NotificationType.trendingItem:
        return 'Тренды';
      case NotificationType.wishlistUpdate:
        return 'Избранное';
      case NotificationType.monthlyInsights:
        return 'Аналитика';
    }
  }

  Widget _buildNotificationsList(
    List<AppNotification> notifications,
    NotificationService notificationService,
  ) {
    // Фильтруем уведомления
    var filteredNotifications = notifications;

    if (_searchQuery.isNotEmpty) {
      filteredNotifications = filteredNotifications.where((notification) =>
        notification.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        notification.body.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_selectedType != null) {
      filteredNotifications = filteredNotifications.where((notification) =>
        notification.type == _selectedType
      ).toList();
    }

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationCard(notification, notificationService);
      },
    );
  }

  Widget _buildEmptyState() {
    String message = 'Нет уведомлений';
    IconData icon = Icons.notifications_none;

    if (_searchQuery.isNotEmpty) {
      message = 'Ничего не найдено';
      icon = Icons.search_off;
    } else if (_selectedType != null) {
      message = 'Нет уведомлений этого типа';
      icon = Icons.filter_list_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedType != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedType = null;
                });
              },
              child: const Text('Сбросить фильтры'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    AppNotification notification,
    NotificationService notificationService,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            notificationService.markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: !notification.isRead 
                ? Border.all(color: notification.color.withOpacity(0.3), width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: notification.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: notification.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(notification.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read, size: 18),
                              SizedBox(width: 8),
                              Text('Отметить как прочитанное'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Удалить', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_read':
                          notificationService.markAsRead(notification.id);
                          break;
                        case 'delete':
                          notificationService.removeNotification(notification.id);
                          break;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.body,
                style: TextStyle(
                  fontSize: 14,
                  color: notification.isRead ? Colors.grey[700] : Colors.black87,
                ),
              ),
              if (notification.data != null && notification.data!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Нажмите для подробностей',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${dateTime.day}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // Обработка нажатия на уведомление в зависимости от типа
    switch (notification.type) {
      case NotificationType.newRecommendations:
        Navigator.pushNamed(context, '/personal-shopper');
        break;
      case NotificationType.priceAlert:
        if (notification.data?['product_id'] != null) {
          // Переход к странице товара
          Navigator.pushNamed(
            context,
            '/product',
            arguments: notification.data!['product_id'],
          );
        }
        break;
      case NotificationType.personalizedOffer:
        // Показать детали предложения
        _showOfferDetails(notification);
        break;
      case NotificationType.trendingItem:
        if (notification.data?['product_id'] != null) {
          Navigator.pushNamed(
            context,
            '/product',
            arguments: notification.data!['product_id'],
          );
        }
        break;
      case NotificationType.wishlistUpdate:
        Navigator.pushNamed(context, '/personal-shopper');
        // Переключиться на вкладку избранного
        break;
      case NotificationType.monthlyInsights:
        Navigator.pushNamed(context, '/personal-shopper');
        // Переключиться на вкладку аналитики
        break;
    }
  }

  void _showOfferDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(notification.icon, color: notification.color),
            const SizedBox(width: 8),
            const Text('Персональное предложение'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(notification.body),
            if (notification.data?['offer_data'] != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Детали предложения:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...((notification.data!['offer_data'] as Map<String, dynamic>).entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('${entry.key}: '),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          if (notification.data?['product_id'] != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/product',
                  arguments: notification.data!['product_id'],
                );
              },
              child: const Text('Посмотреть товар'),
            ),
        ],
      ),
    );
  }

  void _showClearAllDialog(NotificationService notificationService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все уведомления'),
        content: const Text(
          'Вы уверены, что хотите удалить все уведомления? Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              notificationService.clearAll();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить все'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(NotificationService notificationService) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Настройки уведомлений'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Включить уведомления'),
                subtitle: const Text('Получать push-уведомления'),
                value: notificationService.notificationsEnabled,
                onChanged: (value) {
                  notificationService.setNotificationsEnabled(value);
                  setDialogState(() {});
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('Отправить тестовое уведомление'),
                subtitle: const Text('Проверить работу уведомлений'),
                onTap: () {
                  notificationService.sendTestNotification();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Тестовое уведомление отправлено'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Статистика уведомлений'),
                subtitle: const Text('Посмотреть статистику'),
                onTap: () {
                  Navigator.pop(context);
                  _showStatsDialog(notificationService);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog(NotificationService notificationService) {
    final stats = notificationService.getNotificationStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Статистика уведомлений'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Всего уведомлений:', stats['total'].toString()),
            _buildStatRow('Непрочитанных:', stats['unread'].toString()),
            _buildStatRow('Прочитанных:', stats['read'].toString()),
            const SizedBox(height: 16),
            const Text(
              'По типам:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(stats['by_type'] as Map<String, int>).entries.map(
              (entry) => _buildStatRow(
                '${entry.key}:',
                entry.value.toString(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}