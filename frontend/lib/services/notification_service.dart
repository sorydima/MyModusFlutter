import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'personal_shopper_service.dart';

/// Типы уведомлений
enum NotificationType {
  newRecommendations,
  priceAlert,
  personalizedOffer,
  trendingItem,
  wishlistUpdate,
  monthlyInsights,
}

/// Модель уведомления
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.newRecommendations:
        return Icons.recommend;
      case NotificationType.priceAlert:
        return Icons.price_change;
      case NotificationType.personalizedOffer:
        return Icons.local_offer;
      case NotificationType.trendingItem:
        return Icons.trending_up;
      case NotificationType.wishlistUpdate:
        return Icons.favorite;
      case NotificationType.monthlyInsights:
        return Icons.insights;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.newRecommendations:
        return Colors.blue;
      case NotificationType.priceAlert:
        return Colors.orange;
      case NotificationType.personalizedOffer:
        return Colors.green;
      case NotificationType.trendingItem:
        return Colors.purple;
      case NotificationType.wishlistUpdate:
        return Colors.red;
      case NotificationType.monthlyInsights:
        return Colors.indigo;
    }
  }
}

/// Сервис для управления уведомлениями
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final PersonalShopperService _personalShopperService = PersonalShopperService();
  
  final List<AppNotification> _notifications_list = [];
  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  // Геттеры
  List<AppNotification> get notifications => List.unmodifiable(_notifications_list);
  List<AppNotification> get unreadNotifications => _notifications_list.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Инициализация сервиса уведомлений
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Запрашиваем разрешения
    await _requestPermissions();

    _isInitialized = true;
    notifyListeners();
  }

  /// Запрос разрешений на уведомления
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Обработка нажатия на уведомление
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
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

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'personal_shopper_channel',
      'Personal Shopper',
      channelDescription: 'Уведомления от AI персонального шоппера',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Добавление уведомления в локальный список
  void _addNotification(AppNotification notification) {
    _notifications_list.insert(0, notification); // Добавляем в начало списка
    
    // Ограничиваем количество уведомлений
    if (_notifications_list.length > 100) {
      _notifications_list.removeRange(100, _notifications_list.length);
    }
    
    notifyListeners();
  }

  /// Создание уведомления о новых рекомендациях
  Future<void> notifyNewRecommendations(String userId, List<AIRecommendation> recommendations) async {
    if (recommendations.isEmpty) return;

    final title = 'Новые рекомендации!';
    final body = recommendations.length == 1
        ? 'Найден идеальный товар: ${recommendations.first.productTitle}'
        : 'Найдено ${recommendations.length} товаров, которые могут вам понравиться';

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: NotificationType.newRecommendations,
      data: {
        'user_id': userId,
        'recommendations': recommendations.map((r) => r.id).toList(),
      },
      createdAt: DateTime.now(),
    );

    _addNotification(notification);

    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      type: NotificationType.newRecommendations,
      payload: 'recommendations',
    );
  }

  /// Создание уведомления о снижении цены
  Future<void> notifyPriceAlert(String userId, WishlistItem item, int oldPrice, int newPrice) async {
    final discount = ((oldPrice - newPrice) / oldPrice * 100).round();
    
    final title = 'Скидка на товар из избранного!';
    final body = '${item.productTitle} подешевел на $discount% (${newPrice} ₽)';

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: NotificationType.priceAlert,
      data: {
        'user_id': userId,
        'product_id': item.productId,
        'old_price': oldPrice,
        'new_price': newPrice,
        'discount': discount,
      },
      createdAt: DateTime.now(),
    );

    _addNotification(notification);

    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      type: NotificationType.priceAlert,
      payload: 'price_alert:${item.productId}',
    );
  }

  /// Создание уведомления о персонализированном предложении
  Future<void> notifyPersonalizedOffer(String userId, String title, String description, {
    String? productId,
    Map<String, dynamic>? offerData,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: description,
      type: NotificationType.personalizedOffer,
      data: {
        'user_id': userId,
        'product_id': productId,
        'offer_data': offerData,
      },
      createdAt: DateTime.now(),
    );

    _addNotification(notification);

    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: description,
      type: NotificationType.personalizedOffer,
      payload: 'offer:${productId ?? 'general'}',
    );
  }

  /// Создание уведомления о трендовом товаре
  Future<void> notifyTrendingItem(String userId, AIRecommendation recommendation) async {
    final title = 'Товар в тренде!';
    final body = '${recommendation.productTitle} набирает популярность в вашей любимой категории';

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: NotificationType.trendingItem,
      data: {
        'user_id': userId,
        'recommendation_id': recommendation.id,
        'product_id': recommendation.productId,
      },
      createdAt: DateTime.now(),
    );

    _addNotification(notification);

    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      type: NotificationType.trendingItem,
      payload: 'trending:${recommendation.productId}',
    );
  }

  /// Создание уведомления об обновлении вишлиста
  Future<void> notifyWishlistUpdate(String userId, String message, {String? productId}) async {
    final title = 'Обновление избранного';

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: message,
      type: NotificationType.wishlistUpdate,
      data: {
        'user_id': userId,
        'product_id': productId,
      },
      createdAt: DateTime.now(),
    );

    _addNotification(notification);

    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: message,
      type: NotificationType.wishlistUpdate,
      payload: 'wishlist:${productId ?? 'general'}',
    );
  }

  /// Создание уведомления с месячными инсайтами
  Future<void> notifyMonthlyInsights(String userId, Map<String, dynamic> insights) async {
    final title = 'Ваши покупательские инсайты';
    final body = 'Посмотрите анализ ваших предпочтений за прошлый месяц';

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: NotificationType.monthlyInsights,
      data: {
        'user_id': userId,
        'insights': insights,
      },
      createdAt: DateTime.now(),
    );

    _addNotification(notification);

    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      type: NotificationType.monthlyInsights,
      payload: 'insights',
    );
  }

  /// Отметка уведомления как прочитанного
  void markAsRead(String notificationId) {
    final index = _notifications_list.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications_list[index] = _notifications_list[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Отметка всех уведомлений как прочитанных
  void markAllAsRead() {
    for (int i = 0; i < _notifications_list.length; i++) {
      if (!_notifications_list[i].isRead) {
        _notifications_list[i] = _notifications_list[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  /// Удаление уведомления
  void removeNotification(String notificationId) {
    _notifications_list.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Очистка всех уведомлений
  void clearAll() {
    _notifications_list.clear();
    notifyListeners();
  }

  /// Очистка прочитанных уведомлений
  void clearRead() {
    _notifications_list.removeWhere((n) => n.isRead);
    notifyListeners();
  }

  /// Включение/выключение уведомлений
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  /// Получение уведомлений по типу
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications_list.where((n) => n.type == type).toList();
  }

  /// Автоматическая проверка новых рекомендаций
  Future<void> checkForNewRecommendations(String userId) async {
    if (!_notificationsEnabled) return;

    try {
      // Получаем последние рекомендации
      final recommendations = await _personalShopperService.getPersonalRecommendations(userId, limit: 5);
      
      // Фильтруем новые рекомендации (созданные за последние 24 часа)
      final newRecommendations = recommendations.where((rec) {
        final hoursSinceCreated = DateTime.now().difference(rec.createdAt).inHours;
        return hoursSinceCreated <= 24 && !rec.isViewed;
      }).toList();

      if (newRecommendations.isNotEmpty) {
        await notifyNewRecommendations(userId, newRecommendations);
      }
    } catch (e) {
      debugPrint('Error checking for new recommendations: $e');
    }
  }

  /// Автоматическая проверка ценовых оповещений
  Future<void> checkPriceAlerts(String userId) async {
    if (!_notificationsEnabled) return;

    try {
      final wishlist = await _personalShopperService.getWishlist(userId);
      
      for (final item in wishlist) {
        if (item.priceAlertThreshold != null && item.productPrice <= item.priceAlertThreshold!) {
          // В реальном приложении здесь нужно было бы сравнить с предыдущей ценой
          // Для демонстрации просто отправляем уведомление
          await notifyPriceAlert(userId, item, item.priceAlertThreshold!, item.productPrice);
        }
      }
    } catch (e) {
      debugPrint('Error checking price alerts: $e');
    }
  }

  /// Планирование регулярных проверок
  void scheduleRegularChecks(String userId) {
    // Проверяем новые рекомендации каждые 6 часов
    Future.delayed(const Duration(hours: 6), () {
      checkForNewRecommendations(userId);
      scheduleRegularChecks(userId); // Повторяем
    });

    // Проверяем ценовые оповещения каждые 2 часа
    Future.delayed(const Duration(hours: 2), () {
      checkPriceAlerts(userId);
    });
  }

  /// Создание тестового уведомления
  Future<void> sendTestNotification() async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Тестовое уведомление',
      body: 'Уведомления работают корректно!',
      type: NotificationType.newRecommendations,
      createdAt: DateTime.now(),
    );

    _addNotification(notification);

    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: notification.title,
      body: notification.body,
      payload: 'test',
    );
  }

  /// Получение статистики уведомлений
  Map<String, dynamic> getNotificationStats() {
    final total = _notifications_list.length;
    final unread = unreadCount;
    final byType = <String, int>{};

    for (final notification in _notifications_list) {
      final typeName = notification.type.toString().split('.').last;
      byType[typeName] = (byType[typeName] ?? 0) + 1;
    }

    return {
      'total': total,
      'unread': unread,
      'read': total - unread,
      'by_type': byType,
    };
  }
}
