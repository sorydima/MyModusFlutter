import 'dart:convert';
import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Типы уведомлений
enum NotificationType {
  // AI Personal Shopper
  newRecommendations,
  priceAlert,
  personalizedOffer,
  trendingItem,
  wishlistUpdate,
  monthlyInsights,
  
  // AR Fitting
  arFittingComplete,
  sizeRecommendation,
  bodyAnalysisUpdate,
  
  // Blockchain Loyalty
  loyaltyPointsEarned,
  tierUpgrade,
  referralBonus,
  dailyLoginReward,
  cryptoReward,
  
  // Social Analytics
  trendAlert,
  competitorUpdate,
  audienceInsight,
  
  // Social Commerce
  liveStreamReminder,
  groupPurchaseUpdate,
  newReview,
  partnershipApproved,
  
  // General
  systemUpdate,
  maintenance,
  securityAlert,
}

/// Модель уведомления
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final bool isRead;
  final bool isSent;
  final String? fcmToken;
  final String? errorMessage;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.createdAt,
    this.scheduledFor,
    this.isRead = false,
    this.isSent = false,
    this.fcmToken,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'scheduled_for': scheduledFor?.toIso8601String(),
      'is_read': isRead,
      'is_sent': isSent,
      'fcm_token': fcmToken,
      'error_message': errorMessage,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      data: json['data'],
      createdAt: DateTime.parse(json['created_at']),
      scheduledFor: json['scheduled_for'] != null ? DateTime.parse(json['scheduled_for']) : null,
      isRead: json['is_read'] ?? false,
      isSent: json['is_sent'] ?? false,
      fcmToken: json['fcm_token'],
      errorMessage: json['error_message'],
    );
  }
}

/// Сервис для управления уведомлениями
class NotificationService {
  final Logger _logger = Logger();
  final String _fcmServerKey;
  final Timer? _schedulerTimer;
  
  // In-memory storage для демонстрации (в production - база данных)
  final List<NotificationModel> _notifications = [];
  final Map<String, String> _userFcmTokens = {}; // userId -> fcmToken

  NotificationService({String? fcmServerKey}) 
      : _fcmServerKey = fcmServerKey ?? const String.fromEnvironment('FCM_SERVER_KEY', defaultValue: '') {
    _startScheduler();
  }

  /// Запуск планировщика уведомлений
  void _startScheduler() {
    // Проверяем запланированные уведомления каждую минуту
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _processScheduledNotifications();
    });
  }

  /// Обработка запланированных уведомлений
  Future<void> _processScheduledNotifications() async {
    final now = DateTime.now();
    final scheduledNotifications = _notifications.where((n) => 
      n.scheduledFor != null && 
      n.scheduledFor!.isBefore(now) && 
      !n.isSent
    ).toList();

    for (final notification in scheduledNotifications) {
      await _sendNotification(notification);
    }
  }

  /// Регистрация FCM токена пользователя
  Future<bool> registerFcmToken(String userId, String fcmToken) async {
    try {
      _userFcmTokens[userId] = fcmToken;
      _logger.i('FCM token registered for user $userId');
      return true;
    } catch (e) {
      _logger.e('Failed to register FCM token: $e');
      return false;
    }
  }

  /// Отправка push-уведомления через FCM
  Future<bool> _sendFcmNotification(NotificationModel notification) async {
    if (_fcmServerKey.isEmpty) {
      _logger.w('FCM server key not configured');
      return false;
    }

    final fcmToken = _userFcmTokens[notification.userId];
    if (fcmToken == null) {
      _logger.w('No FCM token found for user ${notification.userId}');
      return false;
    }

    try {
      final fcmUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');
      final response = await http.post(
        fcmUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_fcmServerKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': notification.title,
            'body': notification.body,
            'sound': 'default',
            'badge': '1',
          },
          'data': {
            'notification_id': notification.id,
            'type': notification.type.toString().split('.').last,
            'user_id': notification.userId,
            ...?notification.data,
          },
          'priority': 'high',
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'mymodus_channel',
              'priority': 'high',
              'default_sound': true,
              'default_vibrate_timings': true,
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'sound': 'default',
                'badge': 1,
                'category': 'mymodus_notification',
              },
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final success = responseData['success'] == 1;
        if (success) {
          _logger.i('FCM notification sent successfully: ${notification.id}');
          return true;
        } else {
          _logger.w('FCM notification failed: ${responseData['results']?[0]?['error']}');
          return false;
        }
      } else {
        _logger.e('FCM request failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Error sending FCM notification: $e');
      return false;
    }
  }

  /// Отправка уведомления
  Future<bool> _sendNotification(NotificationModel notification) async {
    try {
      // Отправляем через FCM
      final fcmSuccess = await _sendFcmNotification(notification);
      
      // Обновляем статус
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          body: notification.body,
          type: notification.type,
          data: notification.data,
          createdAt: notification.createdAt,
          scheduledFor: notification.scheduledFor,
          isRead: notification.isRead,
          isSent: true,
          fcmToken: notification.fcmToken,
          errorMessage: fcmSuccess ? null : 'FCM sending failed',
        );
      }

      return fcmSuccess;
    } catch (e) {
      _logger.e('Error sending notification: $e');
      return false;
    }
  }

  /// Создание и отправка уведомления
  Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    DateTime? scheduledFor,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: DateTime.now(),
      scheduledFor: scheduledFor,
    );

    _notifications.add(notification);

    // Если уведомление не запланировано, отправляем сразу
    if (scheduledFor == null) {
      await _sendNotification(notification);
    }

    _logger.i('Notification created: ${notification.id} for user $userId');
    return notification;
  }

  /// Создание уведомления о новых рекомендациях
  Future<NotificationModel> notifyNewRecommendations(String userId, List<Map<String, dynamic>> recommendations) async {
    final title = 'Новые рекомендации!';
    final body = recommendations.length == 1
        ? 'Найден идеальный товар: ${recommendations.first['title']}'
        : 'Найдено ${recommendations.length} товаров, которые могут вам понравиться';

    return await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.newRecommendations,
      data: {
        'recommendations': recommendations.map((r) => r['id']).toList(),
        'count': recommendations.length,
      },
    );
  }

  /// Создание уведомления о снижении цены
  Future<NotificationModel> notifyPriceAlert(String userId, Map<String, dynamic> product, int oldPrice, int newPrice) async {
    final discount = ((oldPrice - newPrice) / oldPrice * 100).round();
    
    final title = 'Скидка на товар из избранного!';
    final body = '${product['title']} подешевел на $discount% (${newPrice} ₽)';

    return await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.priceAlert,
      data: {
        'product_id': product['id'],
        'old_price': oldPrice,
        'new_price': newPrice,
        'discount': discount,
      },
    );
  }

  /// Создание уведомления о начислении лояльности
  Future<NotificationModel> notifyLoyaltyPointsEarned(String userId, int points, String reason) async {
    final title = 'Начислены баллы лояльности!';
    final body = '+$points баллов за $reason';

    return await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.loyaltyPointsEarned,
      data: {
        'points': points,
        'reason': reason,
      },
    );
  }

  /// Создание уведомления о live-стриме
  Future<NotificationModel> notifyLiveStreamReminder(String userId, Map<String, dynamic> stream) async {
    final title = 'Напоминание о live-стриме';
    final body = '${stream['title']} начинается через 30 минут';

    return await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.liveStreamReminder,
      data: {
        'stream_id': stream['id'],
        'title': stream['title'],
        'scheduled_time': stream['scheduled_time'],
      },
      scheduledFor: DateTime.parse(stream['scheduled_time']).subtract(const Duration(minutes: 30)),
    );
  }

  /// Создание уведомления о групповой покупке
  Future<NotificationModel> notifyGroupPurchaseUpdate(String userId, Map<String, dynamic> group, String message) async {
    final title = 'Обновление групповой покупки';
    final body = message;

    return await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.groupPurchaseUpdate,
      data: {
        'group_id': group['id'],
        'product_id': group['product_id'],
        'status': group['status'],
      },
    );
  }

  /// Получение уведомлений пользователя
  List<NotificationModel> getUserNotifications(String userId, {
    bool? isRead,
    NotificationType? type,
    int limit = 50,
  }) {
    var notifications = _notifications.where((n) => n.userId == userId).toList();

    if (isRead != null) {
      notifications = notifications.where((n) => n.isRead == isRead).toList();
    }

    if (type != null) {
      notifications = notifications.where((n) => n.type == type).toList();
    }

    // Сортируем по дате создания (новые сначала)
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return notifications.take(limit).toList();
  }

  /// Отметка уведомления как прочитанного
  bool markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        body: _notifications[index].body,
        type: _notifications[index].type,
        data: _notifications[index].data,
        createdAt: _notifications[index].createdAt,
        scheduledFor: _notifications[index].scheduledFor,
        isRead: true,
        isSent: _notifications[index].isSent,
        fcmToken: _notifications[index].fcmToken,
        errorMessage: _notifications[index].errorMessage,
      );
      return true;
    }
    return false;
  }

  /// Отметка всех уведомлений пользователя как прочитанных
  int markAllAsRead(String userId) {
    int count = 0;
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          userId: _notifications[i].userId,
          title: _notifications[i].title,
          body: _notifications[i].body,
          type: _notifications[i].type,
          data: _notifications[i].data,
          createdAt: _notifications[i].createdAt,
          scheduledFor: _notifications[i].scheduledFor,
          isRead: true,
          isSent: _notifications[i].isSent,
          fcmToken: _notifications[i].fcmToken,
          errorMessage: _notifications[i].errorMessage,
        );
        count++;
      }
    }
    return count;
  }

  /// Удаление уведомления
  bool deleteNotification(String notificationId) {
    final initialLength = _notifications.length;
    _notifications.removeWhere((n) => n.id == notificationId);
    return _notifications.length < initialLength;
  }

  /// Очистка старых уведомлений
  int cleanupOldNotifications({int daysOld = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final initialLength = _notifications.length;
    _notifications.removeWhere((n) => n.createdAt.isBefore(cutoffDate));
    final removedCount = initialLength - _notifications.length;
    _logger.i('Cleaned up $removedCount old notifications');
    return removedCount;
  }

  /// Получение статистики уведомлений
  Map<String, dynamic> getNotificationStats(String userId) {
    final userNotifications = _notifications.where((n) => n.userId == userId).toList();
    final total = userNotifications.length;
    final unread = userNotifications.where((n) => !n.isRead).length;
    final sent = userNotifications.where((n) => n.isSent).length;
    final failed = userNotifications.where((n) => n.errorMessage != null).length;

    final byType = <String, int>{};
    for (final notification in userNotifications) {
      final typeName = notification.type.toString().split('.').last;
      byType[typeName] = (byType[typeName] ?? 0) + 1;
    }

    return {
      'total': total,
      'unread': unread,
      'read': total - unread,
      'sent': sent,
      'failed': failed,
      'by_type': byType,
    };
  }

  /// Массовая отправка уведомлений
  Future<Map<String, int>> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    DateTime? scheduledFor,
  }) async {
    int successCount = 0;
    int failureCount = 0;

    for (final userId in userIds) {
      try {
        await createNotification(
          userId: userId,
          title: title,
          body: body,
          type: type,
          data: data,
          scheduledFor: scheduledFor,
        );
        successCount++;
      } catch (e) {
        _logger.e('Failed to create notification for user $userId: $e');
        failureCount++;
      }
    }

    _logger.i('Bulk notification sent: $successCount success, $failureCount failures');
    return {
      'success': successCount,
      'failure': failureCount,
    };
  }

  /// Тестовая отправка уведомления
  Future<NotificationModel> sendTestNotification(String userId) async {
    return await createNotification(
      userId: userId,
      title: 'Тестовое уведомление',
      body: 'Уведомления работают корректно! Время: ${DateTime.now().toString()}',
      type: NotificationType.systemUpdate,
      data: {
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
