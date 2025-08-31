
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';  // Временно отключаем

class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Инициализация Firebase должна быть вызвана ранее в main()
    if (Platform.isIOS) {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    }

    // Настройка локальных уведомлений для foreground
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings();
    final initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings);

    // Обработка сообщений в фоне (требуется top-level функция в реальном приложении)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Токен устройства
    String? token = await _messaging.getToken();
    print('[PushService] FCM token: \$token');
    // TODO: отправить токен на backend для привязки к пользователю
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null) {
      final androidDetails = AndroidNotificationDetails(
        'default_channel', 'Default', importance: Importance.max, priority: Priority.high,
      );
      final platformDetails = NotificationDetails(android: androidDetails);
      _localNotifications.show(notification.hashCode, notification.title, notification.body, platformDetails);
    }
  }
}
