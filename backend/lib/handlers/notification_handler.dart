import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';

class NotificationHandler {
  final NotificationService _notificationService;
  final DatabaseService _database;

  NotificationHandler({
    required NotificationService notificationService,
    required DatabaseService database,
  })  : _notificationService = notificationService,
        _database = database;

  Router get router {
    final router = Router();

    // Регистрация FCM токена
    router.post('/register-token', _registerFcmToken);
    
    // Управление уведомлениями
    router.get('/<userId>', _getUserNotifications);
    router.post('/create', _createNotification);
    router.put('/<notificationId>/read', _markAsRead);
    router.put('/<userId>/read-all', _markAllAsRead);
    router.delete('/<notificationId>', _deleteNotification);
    
    // Специальные уведомления
    router.post('/recommendations', _notifyRecommendations);
    router.post('/price-alert', _notifyPriceAlert);
    router.post('/loyalty-points', _notifyLoyaltyPoints);
    router.post('/live-stream-reminder', _notifyLiveStreamReminder);
    router.post('/group-purchase-update', _notifyGroupPurchaseUpdate);
    
    // Массовые уведомления
    router.post('/bulk', _sendBulkNotifications);
    
    // Статистика и управление
    router.get('/<userId>/stats', _getNotificationStats);
    router.post('/<userId>/test', _sendTestNotification);
    router.post('/cleanup', _cleanupOldNotifications);

    return router;
  }

  /// Регистрация FCM токена пользователя
  Future<Response> _registerFcmToken(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final userId = data['user_id'];
      final fcmToken = data['fcm_token'];
      
      if (userId == null || fcmToken == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'user_id and fcm_token are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final success = await _notificationService.registerFcmToken(userId, fcmToken);
      
      return Response.ok(
        jsonEncode({
          'success': success,
          'message': success ? 'FCM token registered successfully' : 'Failed to register FCM token',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение уведомлений пользователя
  Future<Response> _getUserNotifications(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final queryParams = request.url.queryParameters;
      final isRead = queryParams['is_read'] != null ? bool.parse(queryParams['is_read']!) : null;
      final type = queryParams['type'];
      final limit = int.tryParse(queryParams['limit'] ?? '50') ?? 50;

      NotificationType? notificationType;
      if (type != null) {
        try {
          notificationType = NotificationType.values.firstWhere(
            (e) => e.toString().split('.').last == type,
          );
        } catch (e) {
          // Игнорируем неверный тип
        }
      }

      final notifications = _notificationService.getUserNotifications(
        userId,
        isRead: isRead,
        type: notificationType,
        limit: limit,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'notifications': notifications.map((n) => n.toJson()).toList(),
          'count': notifications.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Создание уведомления
  Future<Response> _createNotification(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final userId = data['user_id'];
      final title = data['title'];
      final bodyText = data['body'];
      final type = data['type'];
      final notificationData = data['data'];
      final scheduledFor = data['scheduled_for'] != null 
          ? DateTime.parse(data['scheduled_for']) 
          : null;

      if (userId == null || title == null || bodyText == null || type == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'user_id, title, body, and type are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      NotificationType notificationType;
      try {
        notificationType = NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == type,
        );
      } catch (e) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid notification type: $type',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final notification = await _notificationService.createNotification(
        userId: userId,
        title: title,
        body: bodyText,
        type: notificationType,
        data: notificationData,
        scheduledFor: scheduledFor,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'notification': notification.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Отметка уведомления как прочитанного
  Future<Response> _markAsRead(Request request) async {
    try {
      final notificationId = request.params['notificationId'];
      if (notificationId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Notification ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final success = _notificationService.markAsRead(notificationId);
      
      return Response.ok(
        jsonEncode({
          'success': success,
          'message': success ? 'Notification marked as read' : 'Notification not found',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Отметка всех уведомлений пользователя как прочитанных
  Future<Response> _markAllAsRead(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final count = _notificationService.markAllAsRead(userId);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Marked $count notifications as read',
          'count': count,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Удаление уведомления
  Future<Response> _deleteNotification(Request request) async {
    try {
      final notificationId = request.params['notificationId'];
      if (notificationId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Notification ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final success = _notificationService.deleteNotification(notificationId);
      
      return Response.ok(
        jsonEncode({
          'success': success,
          'message': success ? 'Notification deleted' : 'Notification not found',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Уведомление о новых рекомендациях
  Future<Response> _notifyRecommendations(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final userId = data['user_id'];
      final recommendations = data['recommendations'];

      if (userId == null || recommendations == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'user_id and recommendations are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final notification = await _notificationService.notifyNewRecommendations(
        userId,
        List<Map<String, dynamic>>.from(recommendations),
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'notification': notification.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Уведомление о снижении цены
  Future<Response> _notifyPriceAlert(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final userId = data['user_id'];
      final product = data['product'];
      final oldPrice = data['old_price'];
      final newPrice = data['new_price'];

      if (userId == null || product == null || oldPrice == null || newPrice == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'user_id, product, old_price, and new_price are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final notification = await _notificationService.notifyPriceAlert(
        userId,
        Map<String, dynamic>.from(product),
        oldPrice,
        newPrice,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'notification': notification.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Уведомление о начислении лояльности
  Future<Response> _notifyLoyaltyPoints(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final userId = data['user_id'];
      final points = data['points'];
      final reason = data['reason'];

      if (userId == null || points == null || reason == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'user_id, points, and reason are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final notification = await _notificationService.notifyLoyaltyPointsEarned(
        userId,
        points,
        reason,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'notification': notification.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Уведомление о напоминании live-стрима
  Future<Response> _notifyLiveStreamReminder(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final userId = data['user_id'];
      final stream = data['stream'];

      if (userId == null || stream == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'user_id and stream are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final notification = await _notificationService.notifyLiveStreamReminder(
        userId,
        Map<String, dynamic>.from(stream),
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'notification': notification.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Уведомление об обновлении групповой покупки
  Future<Response> _notifyGroupPurchaseUpdate(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final userId = data['user_id'];
      final group = data['group'];
      final message = data['message'];

      if (userId == null || group == null || message == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'user_id, group, and message are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final notification = await _notificationService.notifyGroupPurchaseUpdate(
        userId,
        Map<String, dynamic>.from(group),
        message,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'notification': notification.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Массовая отправка уведомлений
  Future<Response> _sendBulkNotifications(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final userIds = data['user_ids'];
      final title = data['title'];
      final bodyText = data['body'];
      final type = data['type'];
      final notificationData = data['data'];
      final scheduledFor = data['scheduled_for'] != null 
          ? DateTime.parse(data['scheduled_for']) 
          : null;

      if (userIds == null || title == null || bodyText == null || type == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'user_ids, title, body, and type are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      NotificationType notificationType;
      try {
        notificationType = NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == type,
        );
      } catch (e) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid notification type: $type',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _notificationService.sendBulkNotifications(
        userIds: List<String>.from(userIds),
        title: title,
        body: bodyText,
        type: notificationType,
        data: notificationData,
        scheduledFor: scheduledFor,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'result': result,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получение статистики уведомлений
  Future<Response> _getNotificationStats(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final stats = _notificationService.getNotificationStats(userId);

      return Response.ok(
        jsonEncode({
          'success': true,
          'stats': stats,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Отправка тестового уведомления
  Future<Response> _sendTestNotification(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final notification = await _notificationService.sendTestNotification(userId);

      return Response.ok(
        jsonEncode({
          'success': true,
          'notification': notification.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Очистка старых уведомлений
  Future<Response> _cleanupOldNotifications(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final daysOld = data['days_old'] ?? 30;

      final removedCount = _notificationService.cleanupOldNotifications(daysOld: daysOld);

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Cleaned up $removedCount old notifications',
          'removed_count': removedCount,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
