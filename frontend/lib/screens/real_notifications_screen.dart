import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/real_notification_service.dart';
import '../widgets/notification_card.dart';

class RealNotificationsScreen extends StatefulWidget {
  const RealNotificationsScreen({super.key});

  @override
  State<RealNotificationsScreen> createState() => _RealNotificationsScreenState();
}

class _RealNotificationsScreenState extends State<RealNotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  NotificationType? _selectedType;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Инициализируем сервис уведомлений
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = context.read<RealNotificationService>();
      // В реальном приложении userId должен приходить из аутентификации
      notificationService.initialize(userId: 'demo_user_123');
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
    return Consumer<RealNotificationService>(
      builder: (context, notificationService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Уведомления'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (notificationService.unreadCount > 0)
                TextButton(
                  onPressed: () => notificationService.markAllAsRead(),
                  child: const Text(
                    'Прочитать все',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
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
                  const PopupMenuItem(
                    value: 'stats',
                    child: Row(
                      children: [
                        Icon(Icons.analytics),
                        SizedBox(width: 8),
                        Text('Статистика'),
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
                    case 'stats':
                      _showStatsDialog(notificationService);
                      break;
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${notificationService.notifications.length}',
                            style: const TextStyle(
                              color: Colors.deepPurple,
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
                const Tab(text: 'Настройки'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAllNotificationsTab(notificationService),
              _buildUnreadNotificationsTab(notificationService),
              _buildSettingsTab(notificationService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllNotificationsTab(RealNotificationService notificationService) {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _buildNotificationsList(
            notificationService.notifications,
            notificationService,
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadNotificationsTab(RealNotificationService notificationService) {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _buildNotificationsList(
            notificationService.unreadNotifications,
            notificationService,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab(RealNotificationService notificationService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Общие настройки',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Уведомления включены'),
                    subtitle: const Text('Получать push-уведомления'),
                    value: notificationService.notificationsEnabled,
                    onChanged: (value) {
                      notificationService.setNotificationsEnabled(value);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Статус FCM'),
                    subtitle: Text(
                      notificationService.isInitialized 
                          ? 'Подключено к Firebase' 
                          : 'Не подключено',
                    ),
                    leading: Icon(
                      notificationService.isInitialized 
                          ? Icons.check_circle 
                          : Icons.error,
                      color: notificationService.isInitialized 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Каналы уведомлений',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChannelInfo('Основные уведомления', 'mymodus_channel', Colors.blue),
                  _buildChannelInfo('AI рекомендации', 'recommendations_channel', Colors.green),
                  _buildChannelInfo('Ценовые оповещения', 'price_alerts_channel', Colors.orange),
                  _buildChannelInfo('Программа лояльности', 'loyalty_channel', Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Действия',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Отправить тестовое уведомление'),
                    subtitle: const Text('Проверить работу уведомлений'),
                    leading: const Icon(Icons.bug_report),
                    onTap: () => notificationService.sendTestNotification(),
                  ),
                  ListTile(
                    title: const Text('Обновить уведомления'),
                    subtitle: const Text('Загрузить с сервера'),
                    leading: const Icon(Icons.refresh),
                    onTap: () => notificationService.getNotifications(),
                  ),
                  ListTile(
                    title: const Text('Очистить все'),
                    subtitle: const Text('Удалить все уведомления'),
                    leading: const Icon(Icons.clear_all, color: Colors.red),
                    onTap: () => _showClearAllDialog(notificationService),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelInfo(String title, String channelId, Color color) {
    return ListTile(
      title: Text(title),
      subtitle: Text('ID: $channelId'),
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      trailing: const Icon(Icons.notifications),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск уведомлений...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
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
      case NotificationType.arFittingComplete:
        return 'AR примерка';
      case NotificationType.sizeRecommendation:
        return 'Размеры';
      case NotificationType.bodyAnalysisUpdate:
        return 'Анализ тела';
      case NotificationType.loyaltyPointsEarned:
        return 'Лояльность';
      case NotificationType.tierUpgrade:
        return 'Уровень';
      case NotificationType.referralBonus:
        return 'Рефералы';
      case NotificationType.dailyLoginReward:
        return 'Ежедневный вход';
      case NotificationType.cryptoReward:
        return 'Крипто награды';
      case NotificationType.trendAlert:
        return 'Тренды';
      case NotificationType.competitorUpdate:
        return 'Конкуренты';
      case NotificationType.audienceInsight:
        return 'Аудитория';
      case NotificationType.liveStreamReminder:
        return 'Live-стримы';
      case NotificationType.groupPurchaseUpdate:
        return 'Групповые покупки';
      case NotificationType.newReview:
        return 'Отзывы';
      case NotificationType.partnershipApproved:
        return 'Партнерства';
      case NotificationType.systemUpdate:
        return 'Система';
      case NotificationType.maintenance:
        return 'Обслуживание';
      case NotificationType.securityAlert:
        return 'Безопасность';
    }
  }

  Widget _buildNotificationsList(
    List<AppNotification> notifications,
    RealNotificationService notificationService,
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

    return RefreshIndicator(
      onRefresh: () => notificationService.getNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () {
              if (!notification.isRead) {
                notificationService.markAsRead(notification.id);
              }
              _handleNotificationTap(notification);
            },
            onDelete: () => notificationService.deleteNotification(notification.id),
          );
        },
      ),
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
                  _searchController.clear();
                });
              },
              child: const Text('Сбросить фильтры'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Здесь можно добавить логику для навигации к соответствующему экрану
    // в зависимости от типа уведомления и данных
    debugPrint('Notification tapped: ${notification.type}');
    
    // Пример навигации для разных типов уведомлений
    switch (notification.type) {
      case NotificationType.newRecommendations:
        // Навигация к экрану рекомендаций
        break;
      case NotificationType.priceAlert:
        // Навигация к экрану товара
        break;
      case NotificationType.liveStreamReminder:
        // Навигация к экрану live-стрима
        break;
      default:
        // Показать детали уведомления
        _showNotificationDetails(notification);
        break;
    }
  }

  void _showNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Text(
              'Тип: ${_getTypeDisplayName(notification.type)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              'Дата: ${_formatDate(notification.createdAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (notification.data != null && notification.data!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Данные:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                notification.data.toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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

  void _showClearAllDialog(RealNotificationService notificationService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все уведомления'),
        content: const Text('Вы уверены, что хотите удалить все уведомления? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              notificationService.clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить все'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(RealNotificationService notificationService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки уведомлений'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Push-уведомления'),
              subtitle: const Text('Получать уведомления от сервера'),
              value: notificationService.notificationsEnabled,
              onChanged: (value) {
                notificationService.setNotificationsEnabled(value);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Статус FCM'),
              subtitle: Text(
                notificationService.isInitialized 
                    ? 'Подключено к Firebase' 
                    : 'Не подключено',
              ),
              leading: Icon(
                notificationService.isInitialized 
                    ? Icons.check_circle 
                    : Icons.error,
                color: notificationService.isInitialized 
                    ? Colors.green 
                    : Colors.red,
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

  void _showStatsDialog(RealNotificationService notificationService) async {
    final stats = await notificationService.getNotificationStats();
    
    if (stats != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Статистика уведомлений'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Всего', stats['total']?.toString() ?? '0'),
              _buildStatRow('Непрочитанных', stats['unread']?.toString() ?? '0'),
              _buildStatRow('Прочитанных', stats['read']?.toString() ?? '0'),
              _buildStatRow('Отправлено', stats['sent']?.toString() ?? '0'),
              _buildStatRow('Ошибок', stats['failed']?.toString() ?? '0'),
              const Divider(),
              const Text(
                'По типам:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(stats['by_type'] as Map<String, dynamic>? ?? {}).entries.map(
                (entry) => _buildStatRow(
                  _getTypeDisplayName(_parseTypeFromString(entry.key)),
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
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  NotificationType _parseTypeFromString(String typeString) {
    try {
      return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
        orElse: () => NotificationType.systemUpdate,
      );
    } catch (e) {
      return NotificationType.systemUpdate;
    }
  }
}
