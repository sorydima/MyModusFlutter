import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Типы уведомлений
enum NotificationType {
  newRecommendations,
  priceAlert,
  trendingItem,
  personalShopper,
  wishlistUpdate,
  saleNotification,
  newCollection,
  backInStock,
}

/// Сервис для управления уведомлениями
/// Обрабатывает локальные и push уведомления
class NotificationService extends ChangeNotifier {
  static const String _channelId = 'personal_shopper_channel';
  static const String _channelName = 'Personal Shopper';
  static const String _channelDescription = 'Уведомления от AI персонального шоппера';
  
  // Состояние
  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  final List<Map<String, dynamic>> _notifications_list = [];
  
  // Геттеры
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications_list);
  List<Map<String, dynamic>> get unreadNotifications => _notifications_list.where((n) => !(n['isRead'] ?? false)).toList();
  int get unreadCount => unreadNotifications.length;
  
  /// Инициализация сервиса уведомлений
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Запрашиваем разрешения
    await _requestPermissions();

    _isInitialized = true;
    notifyListeners();
  }

  /// Запрос разрешений на уведомления
  Future<void> _requestPermissions() async {
    // В реальном приложении запрашиваем разрешения
    await Future.delayed(Duration(milliseconds: 100));
  }

  /// Обработка нажатия на уведомление
  void _onNotificationTap(Map<String, dynamic> response) {
    final payload = response['payload'];
    if (payload != null) {
      // Парсим payload и выполняем соответствующее действие
      // Например, открываем экран товара или рекомендаций
      debugPrint('Notification tapped with payload: $payload');
    }
  }

  /// Показ локального уведомления
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.newRecommendations,
  }) async {
    if (!_notificationsEnabled || !_isInitialized) return;

    // В реальном приложении показываем уведомление
    await Future.delayed(Duration(milliseconds: 100));
    
    // Добавляем в список
    _addNotification({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'type': type.toString(),
      'timestamp': DateTime.now(),
      'isRead': false,
    });
  }

  /// Добавление уведомления в локальный список
  void _addNotification(Map<String, dynamic> notification) {
    _notifications_list.insert(0, notification); // Добавляем в начало списка
    
    // Ограничиваем количество уведомлений
    if (_notifications_list.length > 100) {
      _notifications_list.removeRange(100, _notifications_list.length);
    }
    
    notifyListeners();
  }

  /// Уведомление о новых рекомендациях
  Future<void> notifyNewRecommendations(String userId, List<Map<String, dynamic>> recommendations) async {
    if (!_notificationsEnabled) return;

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'Новые рекомендации',
      'body': 'У нас есть ${recommendations.length} новых рекомендаций для вас!',
      'payload': {
        'type': 'recommendations',
        'userId': userId,
        'recommendations': recommendations.map((r) => r['id'] ?? '').toList(),
      },
      'type': NotificationType.newRecommendations.toString(),
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _addNotification(notification);
  }

  /// Уведомление об изменении цены
  Future<void> notifyPriceAlert(String userId, Map<String, dynamic> item, int oldPrice, int newPrice) async {
    if (!_notificationsEnabled) return;

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'Изменение цены',
      'body': 'Цена на ${item['name'] ?? 'товар'} изменилась с $oldPrice₽ на $newPrice₽',
      'payload': {
        'type': 'price_alert',
        'userId': userId,
        'itemId': item['id'],
        'oldPrice': oldPrice,
        'newPrice': newPrice,
      },
      'type': NotificationType.priceAlert.toString(),
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _addNotification(notification);
  }

  /// Уведомление о трендовом товаре
  Future<void> notifyTrendingItem(String userId, Map<String, dynamic> recommendation) async {
    if (!_notificationsEnabled) return;

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'Трендовый товар',
      'body': '${recommendation['name'] ?? 'Товар'} сейчас в тренде!',
      'payload': {
        'type': 'trending_item',
        'userId': userId,
        'itemId': recommendation['id'],
      },
      'type': NotificationType.trendingItem.toString(),
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _addNotification(notification);
  }

  /// Уведомление о персональном шоппере
  Future<void> notifyPersonalShopper(String userId, String message) async {
    if (!_notificationsEnabled) return;

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'AI Персональный шоппер',
      'body': message,
      'payload': {
        'type': 'personal_shopper',
        'userId': userId,
      },
      'type': NotificationType.personalShopper.toString(),
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _addNotification(notification);
  }

  /// Уведомление об обновлении избранного
  Future<void> notifyWishlistUpdate(String userId, String itemName, String action) async {
    if (!_notificationsEnabled) return;

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'Обновление избранного',
      'body': '$itemName $action в вашем избранном',
      'payload': {
        'type': 'wishlist_update',
        'userId': userId,
        'action': action,
      },
      'type': NotificationType.wishlistUpdate.toString(),
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _addNotification(notification);
  }

  /// Уведомление о распродаже
  Future<void> notifySale(String userId, String collectionName, int discount) async {
    if (!_notificationsEnabled) return;

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'Распродажа!',
      'body': 'Коллекция $collectionName со скидкой $discount%',
      'payload': {
        'type': 'sale',
        'userId': userId,
        'collection': collectionName,
        'discount': discount,
      },
      'type': NotificationType.saleNotification.toString(),
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _addNotification(notification);
  }

  /// Уведомление о новой коллекции
  Future<void> notifyNewCollection(String userId, String collectionName) async {
    if (!_notificationsEnabled) return;

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'Новая коллекция',
      'body': 'Доступна новая коллекция $collectionName',
      'payload': {
        'type': 'new_collection',
        'userId': userId,
        'collection': collectionName,
      },
      'type': NotificationType.newCollection.toString(),
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _addNotification(notification);
  }

  /// Уведомление о возвращении в наличии
  Future<void> notifyBackInStock(String userId, String itemName) async {
    if (!_notificationsEnabled) return;

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'Товар в наличии',
      'body': '$itemName снова доступен для покупки',
      'payload': {
        'type': 'back_in_stock',
        'userId': userId,
        'itemName': itemName,
      },
      'type': NotificationType.backInStock.toString(),
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _addNotification(notification);
  }

  /// Отметить уведомление как прочитанное
  void markAsRead(int notificationId) {
    final index = _notifications_list.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications_list[index]['isRead'] = true;
      notifyListeners();
    }
  }

  /// Отметить все уведомления как прочитанные
  void markAllAsRead() {
    for (var notification in _notifications_list) {
      notification['isRead'] = true;
    }
    notifyListeners();
  }

  /// Удалить уведомление
  void removeNotification(int notificationId) {
    _notifications_list.removeWhere((n) => n['id'] == notificationId);
    notifyListeners();
  }

  /// Очистить все уведомления
  void clearAllNotifications() {
    _notifications_list.clear();
    notifyListeners();
  }

  /// Включить/выключить уведомления
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  /// Получить уведомления по типу
  List<Map<String, dynamic>> getNotificationsByType(NotificationType type) {
    return _notifications_list
        .where((n) => n['type'] == type.toString())
        .toList();
  }

  /// Получить уведомления за период
  List<Map<String, dynamic>> getNotificationsForPeriod(DateTime start, DateTime end) {
    return _notifications_list
        .where((n) {
          final timestamp = n['timestamp'] as DateTime;
          return timestamp.isAfter(start) && timestamp.isBefore(end);
        })
        .toList();
  }

  /// Получить статистику уведомлений
  Map<String, int> getNotificationStats() {
    final stats = <String, int>{};
    
    for (var notification in _notifications_list) {
      final type = notification['type'] as String;
      stats[type] = (stats[type] ?? 0) + 1;
    }
    
    return stats;
  }

  /// Получить персональные рекомендации (заглушка)
  Future<List<Map<String, dynamic>>> getPersonalRecommendations(String userId, {int limit = 5}) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    return List.generate(limit, (index) => {
      'id': 'rec_$index',
      'name': 'Рекомендация ${index + 1}',
      'description': 'Описание рекомендации ${index + 1}',
      'confidence': 0.8 + (index * 0.05),
    });
  }

  /// Получить список желаний (заглушка)
  Future<List<Map<String, dynamic>>> getWishlist(String userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    return [
      {
        'id': 'item_1',
        'name': 'Стильная куртка',
        'price': 15000,
        'oldPrice': 18000,
        'image': 'https://example.com/jacket.jpg',
      },
      {
        'id': 'item_2',
        'name': 'Джинсы премиум',
        'price': 8000,
        'oldPrice': 12000,
        'image': 'https://example.com/jeans.jpg',
      },
    ];
  }

  /// Получить количество непрочитанных уведомлений
  int getUnreadCount() {
    final unread = unreadCount;
    return unread;
  }

  /// Проверить, есть ли непрочитанные уведомления
  bool hasUnreadNotifications() {
    return unreadCount > 0;
  }

  /// Получить последнее уведомление
  Map<String, dynamic>? getLastNotification() {
    if (_notifications_list.isEmpty) return null;
    return _notifications_list.first;
  }

  /// Получить уведомления для конкретного пользователя
  List<Map<String, dynamic>> getUserNotifications(String userId) {
    return _notifications_list
        .where((n) {
          final payload = n['payload'] as Map<String, dynamic>?;
          return payload?['userId'] == userId;
        })
        .toList();
  }

  /// Фильтровать уведомления по тексту
  List<Map<String, dynamic>> searchNotifications(String query) {
    if (query.isEmpty) return _notifications_list;
    
    return _notifications_list
        .where((n) {
          final title = (n['title'] as String?)?.toLowerCase() ?? '';
          final body = (n['body'] as String?)?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return title.contains(searchQuery) || body.contains(searchQuery);
        })
        .toList();
  }

  /// Сортировать уведомления по дате
  List<Map<String, dynamic>> getSortedNotifications({bool ascending = false}) {
    final sorted = List<Map<String, dynamic>>.from(_notifications_list);
    
    if (ascending) {
      sorted.sort((a, b) => (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime));
    } else {
      sorted.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    }
    
    return sorted;
  }

  /// Экспорт уведомлений в JSON
  String exportNotificationsToJson() {
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalNotifications': _notifications_list.length,
      'unreadCount': unreadCount,
      'notifications': _notifications_list.map((n) => {
        'id': n['id'],
        'title': n['title'],
        'body': n['body'],
        'type': n['type'],
        'timestamp': (n['timestamp'] as DateTime).toIso8601String(),
        'isRead': n['isRead'],
        'payload': n['payload'],
      }).toList(),
    };
    
    return jsonEncode(exportData);
  }

  /// Импорт уведомлений из JSON
  Future<bool> importNotificationsFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final notifications = data['notifications'] as List<dynamic>;
      
      for (var notification in notifications) {
        final notificationMap = Map<String, dynamic>.from(notification);
        notificationMap['timestamp'] = DateTime.parse(notificationMap['timestamp']);
        _notifications_list.add(notificationMap);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing notifications: $e');
      return false;
    }
  }

  /// Освободить ресурсы
  @override
  void dispose() {
    super.dispose();
  }
}
