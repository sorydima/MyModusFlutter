import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'Все';
  
  final List<String> _filters = ['Все', 'Скидки', 'Новинки', 'Заказы', 'Социальные'];

  // Тестовые данные уведомлений
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'Скидки',
      'title': 'Скидка 20% на Nike!',
      'message': 'На всю обувь Nike действует скидка 20%. Успейте купить!',
      'imageUrl': 'https://via.placeholder.com/60x60/FF6B6B/FFFFFF?text=Nike',
      'timeAgo': '5 минут назад',
      'isRead': false,
      'action': 'Перейти к товарам',
    },
    {
      'id': '2',
      'type': 'Новинки',
      'title': 'Новая коллекция Adidas',
      'message': 'В продаже новая коллекция Adidas Ultraboost 22',
      'imageUrl': 'https://via.placeholder.com/60x60/4ECDC4/FFFFFF?text=Adidas',
      'timeAgo': '1 час назад',
      'isRead': false,
      'action': 'Посмотреть',
    },
    {
      'id': '3',
      'type': 'Заказы',
      'title': 'Заказ отправлен',
      'message': 'Ваш заказ #12345 отправлен и будет доставлен завтра',
      'imageUrl': 'https://via.placeholder.com/60x60/45B7D1/FFFFFF?text=Order',
      'timeAgo': '2 часа назад',
      'isRead': true,
      'action': 'Отследить',
    },
    {
      'id': '4',
      'type': 'Социальные',
      'title': 'Новый подписчик',
      'message': 'Пользователь @fashion_lover подписался на вас',
      'imageUrl': 'https://via.placeholder.com/60x60/96CEB4/FFFFFF?text=User',
      'timeAgo': '3 часа назад',
      'isRead': true,
      'action': 'Посмотреть профиль',
    },
    {
      'id': '5',
      'type': 'Скидки',
      'title': 'Черная пятница!',
      'message': 'Скидки до 70% на все товары. Только сегодня!',
      'imageUrl': 'https://via.placeholder.com/60x60/FFE66D/000000?text=Sale',
      'timeAgo': '1 день назад',
      'isRead': true,
      'action': 'Перейти к скидкам',
    },
    {
      'id': '6',
      'type': 'Новинки',
      'title': 'Apple Watch Series 8',
      'message': 'Новые часы Apple Watch Series 8 уже в продаже',
      'imageUrl': 'https://via.placeholder.com/60x60/96CEB4/FFFFFF?text=Apple',
      'timeAgo': '2 дня назад',
      'isRead': true,
      'action': 'Купить',
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'Все') {
      return _notifications;
    }
    return _notifications.where((notification) {
      return notification['type'] == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // App Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Кнопка назад
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Заголовок
                Expanded(
                  child: Text(
                    'Уведомления',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Кнопка настроек
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to notification settings
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Фильтры
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Список уведомлений
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Уведомлений нет',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'У вас пока нет уведомлений\nпо выбранному фильтру',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification['isRead'] 
              ? Colors.grey.shade200 
              : Colors.blue.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Иконка уведомления
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _getNotificationColor(notification['type']).withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: notification['imageUrl'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.error,
                      size: 24,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Содержимое уведомления
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Text(
                    notification['title'],
                    style: TextStyle(
                      fontWeight: notification['isRead'] 
                          ? FontWeight.w500 
                          : FontWeight.w600,
                      fontSize: 16,
                      color: notification['isRead'] 
                          ? Colors.grey.shade700 
                          : Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Сообщение
                  Text(
                    notification['message'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Время и действие
                  Row(
                    children: [
                      Text(
                        notification['timeAgo'],
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Handle notification action
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          notification['action'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Индикатор непрочитанного
            if (!notification['isRead'])
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'Скидки':
        return Colors.red;
      case 'Новинки':
        return Colors.green;
      case 'Заказы':
        return Colors.blue;
      case 'Социальные':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
