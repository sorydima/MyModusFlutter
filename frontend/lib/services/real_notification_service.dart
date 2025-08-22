import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
class AppNotification {
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

  AppNotification({
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

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
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
      case NotificationType.arFittingComplete:
        return Icons.camera_alt;
      case NotificationType.sizeRecommendation:
        return Icons.straighten;
      case NotificationType.bodyAnalysisUpdate:
        return Icons.analytics;
      case NotificationType.loyaltyPointsEarned:
        return Icons.stars;
      case NotificationType.tierUpgrade:
        return Icons.trending_up;
      case NotificationType.referralBonus:
        return Icons.share;
      case NotificationType.dailyLoginReward:
        return Icons.login;
      case NotificationType.cryptoReward:
        return Icons.currency_bitcoin;
      case NotificationType.trendAlert:
        return Icons.trending_up;
      case NotificationType.competitorUpdate:
        return Icons.business;
      case NotificationType.audienceInsight:
        return Icons.people;
      case NotificationType.liveStreamReminder:
        return Icons.live_tv;
      case NotificationType.groupPurchaseUpdate:
        return Icons.group;
      case NotificationType.newReview:
        return Icons.rate_review;
      case NotificationType.partnershipApproved:
        return Icons.handshake;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      case NotificationType.maintenance:
        return Icons.build;
      case NotificationType.securityAlert:
        return Icons.security;
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
      case NotificationType.arFittingComplete:
        return Colors.teal;
      case NotificationType.sizeRecommendation:
        return Colors.cyan;
      case NotificationType.bodyAnalysisUpdate:
        return Colors.deepPurple;
      case NotificationType.loyaltyPointsEarned:
        return Colors.amber;
      case NotificationType.tierUpgrade:
        return Colors.lime;
      case NotificationType.referralBonus:
        return Colors.pink;
      case NotificationType.dailyLoginReward:
        return Colors.lightBlue;
      case NotificationType.cryptoReward:
        return Colors.yellow;
      case NotificationType.trendAlert:
        return Colors.deepOrange;
      case NotificationType.competitorUpdate:
        return Colors.brown;
      case NotificationType.audienceInsight:
        return Colors.blueGrey;
      case NotificationType.liveStreamReminder:
        return Colors.red;
      case NotificationType.groupPurchaseUpdate:
        return Colors.green;
      case NotificationType.newReview:
        return Colors.blue;
      case NotificationType.partnershipApproved:
        return Colors.green;
      case NotificationType.systemUpdate:
        return Colors.grey;
      case NotificationType.maintenance:
        return Colors.orange;
      case NotificationType.securityAlert:
        return Colors.red;
    }
  }
}

/// Сервис для управления реальными уведомлениями
class RealNotificationService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api/notifications';
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  final List<AppNotification> _notifications = [];
  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  String? _currentUserId;
  String? _fcmToken;

  // Геттеры
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<AppNotification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Инициализация сервиса уведомлений
  Future<void> initialize({required String userId}) async {
    if (_isInitialized) return;

    _currentUserId = userId;

    try {
      // Инициализация Firebase
      await Firebase.initializeApp();
      
      // Запрос разрешений
      if (Platform.isIOS) {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Настройка локальных уведомлений
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      final iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Создание каналов для Android
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      // Получение FCM токена
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        await _registerFcmToken(userId, _fcmToken!);
      }

      // Обработка сообщений
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

      // Загрузка существующих уведомлений
      await _loadNotifications();

      _isInitialized = true;
      notifyListeners();

      debugPrint('RealNotificationService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize RealNotificationService: $e');
    }
  }

  /// Создание каналов уведомлений для Android
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      const androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        // Основной канал
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'mymodus_channel',
            'MyModus Notifications',
            description: 'Основные уведомления приложения',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );

        // Канал для рекомендаций
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'recommendations_channel',
            'AI Recommendations',
            description: 'Уведомления о новых рекомендациях',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );

        // Канал для ценовых оповещений
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'price_alerts_channel',
            'Price Alerts',
            description: 'Уведомления об изменении цен',
            importance: Importance.medium,
            playSound: true,
            enableVibration: false,
          ),
        );

        // Канал для лояльности
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'loyalty_channel',
            'Loyalty Program',
            description: 'Уведомления о программе лояльности',
            importance: Importance.medium,
            playSound: true,
            enableVibration: false,
          ),
        );
      }
    }
  }

  /// Регистрация FCM токена на backend
  Future<void> _registerFcmToken(String userId, String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'fcm_token': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          debugPrint('FCM token registered successfully');
        } else {
          debugPrint('Failed to register FCM token: ${result['message']}');
        }
      } else {
        debugPrint('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
    }
  }

  /// Обработка сообщений в foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');
    
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? 'MyModus',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }

    // Добавляем уведомление в локальный список
    final appNotification = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId ?? 'unknown',
      title: notification?.title ?? 'MyModus',
      body: notification?.body ?? '',
      type: _parseNotificationType(message.data['type']),
      data: message.data,
      createdAt: DateTime.now(),
    );

    _addNotification(appNotification);
  }

  /// Обработка сообщений в background
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Background message opened: ${message.messageId}');
    // Здесь можно добавить логику для открытия соответствующего экрана
  }

  /// Парсинг типа уведомления
  NotificationType _parseNotificationType(String? typeString) {
    if (typeString == null) return NotificationType.systemUpdate;
    
    try {
      return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
        orElse: () => NotificationType.systemUpdate,
      );
    } catch (e) {
      return NotificationType.systemUpdate;
    }
  }

  /// Показ локального уведомления
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_notificationsEnabled) return;

    String channelId = 'mymodus_channel';
    String channelName = 'MyModus Notifications';
    String channelDescription = 'Основные уведомления приложения';

    // Определяем канал в зависимости от типа уведомления
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        final type = data['type'];
        
        switch (type) {
          case 'newRecommendations':
            channelId = 'recommendations_channel';
            channelName = 'AI Recommendations';
            channelDescription = 'Уведомления о новых рекомендациях';
            break;
          case 'priceAlert':
            channelId = 'price_alerts_channel';
            channelName = 'Price Alerts';
            channelDescription = 'Уведомления об изменении цен';
            break;
          case 'loyaltyPointsEarned':
          case 'tierUpgrade':
          case 'referralBonus':
            channelId = 'loyalty_channel';
            channelName = 'Loyalty Program';
            channelDescription = 'Уведомления о программе лояльности';
            break;
        }
      } catch (e) {
        // Игнорируем ошибки парсинга
      }
    }

    const androidDetails = AndroidNotificationDetails(
      'mymodus_channel',
      'MyModus Notifications',
      channelDescription: 'Основные уведомления приложения',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Обработка нажатия на уведомление
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        debugPrint('Notification tapped with payload: $data');
        
        // Здесь можно добавить логику для навигации к соответствующему экрану
        // Например, открыть экран товара, рекомендаций и т.д.
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Загрузка уведомлений с backend
  Future<void> _loadNotifications() async {
    if (_currentUserId == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$_currentUserId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          final notifications = (result['notifications'] as List)
              .map((n) => AppNotification.fromJson(n))
              .toList();
          
          _notifications.clear();
          _notifications.addAll(notifications);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  /// Добавление уведомления в локальный список
  void _addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    
    // Ограничиваем количество уведомлений
    if (_notifications.length > 100) {
      _notifications.removeRange(100, _notifications.length);
    }
    
    notifyListeners();
  }

  /// Получение уведомлений с backend
  Future<void> getNotifications({
    bool? isRead,
    NotificationType? type,
    int limit = 50,
  }) async {
    if (_currentUserId == null) return;

    try {
      final queryParams = <String, String>{};
      if (isRead != null) queryParams['is_read'] = isRead.toString();
      if (type != null) queryParams['type'] = type.toString().split('.').last;
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/$_currentUserId').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          final notifications = (result['notifications'] as List)
              .map((n) => AppNotification.fromJson(n))
              .toList();
          
          _notifications.clear();
          _notifications.addAll(notifications);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error getting notifications: $e');
    }
  }

  /// Создание уведомления
  Future<AppNotification?> createNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    DateTime? scheduledFor,
  }) async {
    if (_currentUserId == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _currentUserId,
          'title': title,
          'body': body,
          'type': type.toString().split('.').last,
          'data': data,
          'scheduled_for': scheduledFor?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          final notification = AppNotification.fromJson(result['notification']);
          _addNotification(notification);
          return notification;
        }
      }
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
    return null;
  }

  /// Отметка уведомления как прочитанного
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = AppNotification(
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
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Отметка всех уведомлений как прочитанных
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$_currentUserId/read-all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        for (int i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = AppNotification(
              id: _notifications[i].id,
              userId: _notifications[i].userId,
              title: _notifications[i].id,
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
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Удаление уведомления
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$notificationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Получение статистики уведомлений
  Future<Map<String, dynamic>?> getNotificationStats() async {
    if (_currentUserId == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$_currentUserId/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return result['stats'];
        }
      }
    } catch (e) {
      debugPrint('Error getting notification stats: $e');
    }
    return null;
  }

  /// Отправка тестового уведомления
  Future<void> sendTestNotification() async {
    if (_currentUserId == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$_currentUserId/test'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          final notification = AppNotification.fromJson(result['notification']);
          _addNotification(notification);
        }
      }
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  /// Включение/выключение уведомлений
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  /// Получение уведомлений по типу
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Очистка всех уведомлений
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Очистка прочитанных уведомлений
  void clearRead() {
    _notifications.removeWhere((n) => n.isRead);
    notifyListeners();
  }
}

// Top-level функция для обработки background сообщений
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  // Здесь можно добавить логику для обработки background сообщений
}
