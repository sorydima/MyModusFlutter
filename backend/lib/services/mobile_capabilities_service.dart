import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../models.dart';
import 'notification_service.dart';

/// Сервис мобильных возможностей приложения
class MobileCapabilitiesService {
  final NotificationService _notificationService;
  final Logger _logger = Logger();

  // Кэш для офлайн данных
  final Map<String, Map<String, dynamic>> _offlineCache = {};
  
  // Геолокационные данные пользователей
  final Map<String, UserLocation> _userLocations = {};
  
  // Календарные события
  final Map<String, List<CalendarEvent>> _userEvents = {};

  MobileCapabilitiesService({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;

  // ===== ОФЛАЙН РЕЖИМ =====

  /// Сохранение данных в офлайн кэш
  Future<void> saveToOfflineCache({
    required String userId,
    required String dataType,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (!_offlineCache.containsKey(userId)) {
        _offlineCache[userId] = {};
      }
      
      _offlineCache[userId]![dataType] = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      _logger.i('Saved $dataType to offline cache for user $userId');
    } catch (e) {
      _logger.e('Failed to save to offline cache: $e');
    }
  }

  /// Получение данных из офлайн кэша
  Map<String, dynamic>? getFromOfflineCache({
    required String userId,
    required String dataType,
  }) {
    try {
      final cache = _offlineCache[userId];
      if (cache != null && cache.containsKey(dataType)) {
        final cachedData = cache[dataType]!;
        final timestamp = DateTime.parse(cachedData['timestamp']);
        
        // Проверяем актуальность кэша (24 часа)
        if (DateTime.now().difference(timestamp).inHours < 24) {
          return cachedData['data'];
        }
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get from offline cache: $e');
      return null;
    }
  }

  /// Синхронизация офлайн данных с сервером
  Future<SyncResult> syncOfflineData({
    required String userId,
    required List<String> dataTypes,
  }) async {
    try {
      final syncResult = SyncResult(
        userId: userId,
        timestamp: DateTime.now(),
        syncedTypes: [],
        failedTypes: [],
        conflicts: [],
      );

      for (final dataType in dataTypes) {
        final offlineData = getFromOfflineCache(userId: userId, dataType: dataType);
        if (offlineData != null) {
          try {
            // Здесь должна быть логика синхронизации с основными сервисами
            await _syncDataType(userId: userId, dataType: dataType, data: offlineData);
            syncResult.syncedTypes.add(dataType);
            
            // Очищаем успешно синхронизированные данные
            _offlineCache[userId]?.remove(dataType);
          } catch (e) {
            syncResult.failedTypes.add(dataType);
            _logger.e('Failed to sync $dataType: $e');
          }
        }
      }

      _logger.i('Sync completed for user $userId: ${syncResult.syncedTypes.length} synced, ${syncResult.failedTypes.length} failed');
      return syncResult;
    } catch (e) {
      _logger.e('Failed to sync offline data: $e');
      rethrow;
    }
  }

  // ===== ГЕОЛОКАЦИЯ =====

  /// Обновление местоположения пользователя
  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? address,
    double? accuracy,
  }) async {
    try {
      final location = UserLocation(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        accuracy: accuracy,
        timestamp: DateTime.now(),
      );

      _userLocations[userId] = location;
      _logger.i('Updated location for user $userId: $latitude, $longitude');
    } catch (e) {
      _logger.e('Failed to update user location: $e');
    }
  }

  /// Получение местоположения пользователя
  UserLocation? getUserLocation(String userId) {
    return _userLocations[userId];
  }

  /// Поиск ближайших предложений по геолокации
  Future<List<GeolocationOffer>> getNearbyOffers({
    required String userId,
    required double radiusKm,
    String? category,
  }) async {
    try {
      final userLocation = getUserLocation(userId);
      if (userLocation == null) {
        return [];
      }

      // Здесь должна быть логика поиска предложений по координатам
      // Пока возвращаем демо данные
      final offers = <GeolocationOffer>[];
      
      // Демо: магазины в радиусе
      final nearbyStores = [
        {'name': 'Zara', 'distance': 0.5, 'category': 'Одежда'},
        {'name': 'H&M', 'distance': 1.2, 'category': 'Одежда'},
        {'name': 'Nike', 'distance': 2.1, 'category': 'Обувь'},
      ];

      for (final store in nearbyStores) {
        if (category == null || store['category'] == category) {
          offers.add(GeolocationOffer(
            id: 'store_${store['name']}',
            name: store['name'] as String,
            category: store['category'] as String,
            distance: store['distance'] as double,
            latitude: userLocation.latitude + (store['distance'] as double) * 0.01,
            longitude: userLocation.longitude + (store['distance'] as double) * 0.01,
            offers: [
              {'type': 'Скидка 20%', 'description': 'На все товары'},
              {'type': 'Бесплатная доставка', 'description': 'При заказе от 5000₽'},
            ],
          ));
        }
      }

      // Сортируем по расстоянию
      offers.sort((a, b) => a.distance.compareTo(b.distance));
      
      return offers;
    } catch (e) {
      _logger.e('Failed to get nearby offers: $e');
      return [];
    }
  }

  // ===== КАЛЕНДАРЬ =====

  /// Добавление события в календарь пользователя
  Future<void> addCalendarEvent({
    required String userId,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? eventType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final event = CalendarEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        location: location,
        eventType: eventType,
        metadata: metadata,
        createdAt: DateTime.now(),
      );

      if (!_userEvents.containsKey(userId)) {
        _userEvents[userId] = [];
      }
      
      _userEvents[userId]!.add(event);
      
      // Отправляем уведомление о событии
      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.calendarEvent,
        title: '📅 Новое событие: $title',
        body: 'Напоминание о событии $startTime',
        data: {
          'event_id': event.id,
          'event_type': eventType,
          'start_time': startTime.toIso8601String(),
        },
      );

      _logger.i('Added calendar event for user $userId: $title');
    } catch (e) {
      _logger.e('Failed to add calendar event: $e');
    }
  }

  /// Получение событий календаря пользователя
  List<CalendarEvent> getUserEvents({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  }) {
    try {
      final events = _userEvents[userId] ?? [];
      
      var filteredEvents = events;
      
      if (startDate != null) {
        filteredEvents = filteredEvents.where((e) => e.startTime.isAfter(startDate)).toList();
      }
      
      if (endDate != null) {
        filteredEvents = filteredEvents.where((e) => e.endTime.isBefore(endDate)).toList();
      }
      
      if (eventType != null) {
        filteredEvents = filteredEvents.where((e) => e.eventType == eventType).toList();
      }
      
      // Сортируем по времени начала
      filteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      return filteredEvents;
    } catch (e) {
      _logger.e('Failed to get user events: $e');
      return [];
    }
  }

  // ===== ФОНОВАЯ СИНХРОНИЗАЦИЯ =====

  /// Запуск фоновой синхронизации
  Future<BackgroundSyncResult> startBackgroundSync({
    required String userId,
    List<String>? dataTypes,
  }) async {
    try {
      _logger.i('Starting background sync for user $userId');
      
      final syncResult = await syncOfflineData(
        userId: userId,
        dataTypes: dataTypes ?? ['products', 'notifications', 'preferences'],
      );

      // Проверяем новые уведомления
      final hasNewNotifications = await _checkNewNotifications(userId);
      
      // Проверяем обновления геолокации
      final locationUpdates = await _checkLocationUpdates(userId);
      
      return BackgroundSyncResult(
        userId: userId,
        timestamp: DateTime.now(),
        syncResult: syncResult,
        hasNewNotifications: hasNewNotifications,
        locationUpdates: locationUpdates,
        success: true,
      );
    } catch (e) {
      _logger.e('Background sync failed: $e');
      return BackgroundSyncResult(
        userId: userId,
        timestamp: DateTime.now(),
        syncResult: null,
        hasNewNotifications: false,
        locationUpdates: [],
        success: false,
        error: e.toString(),
      );
    }
  }

  // ===== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ =====

  Future<void> _syncDataType({
    required String userId,
    required String dataType,
    required Map<String, dynamic> data,
  }) async {
    // Здесь должна быть логика синхронизации с основными сервисами
    await Future.delayed(Duration(milliseconds: 100)); // Имитация
  }

  Future<bool> _checkNewNotifications(String userId) async {
    // Проверка новых уведомлений
    return false; // Имитация
  }

  Future<List<LocationUpdate>> _checkLocationUpdates(String userId) async {
    // Проверка обновлений геолокации
    return []; // Имитация
  }

  /// Очистка старых данных
  void cleanupOldData() {
    try {
      final now = DateTime.now();
      
      // Очищаем старый кэш (старше 7 дней)
      _offlineCache.forEach((userId, userCache) {
        userCache.removeWhere((key, value) {
          final timestamp = DateTime.parse(value['timestamp']);
          return now.difference(timestamp).inDays > 7;
        });
      });
      
      // Очищаем пустые записи пользователей
      _offlineCache.removeWhere((userId, userCache) => userCache.isEmpty);
      
      _logger.i('Cleanup completed');
    } catch (e) {
      _logger.e('Cleanup failed: $e');
    }
  }
}

// ===== МОДЕЛИ ДАННЫХ =====

class UserLocation {
  final String userId;
  final double latitude;
  final double longitude;
  final String? address;
  final double? accuracy;
  final DateTime timestamp;

  UserLocation({
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.address,
    this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'accuracy': accuracy,
    'timestamp': timestamp.toIso8601String(),
  };

  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
    userId: json['userId'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    address: json['address'],
    accuracy: json['accuracy'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class GeolocationOffer {
  final String id;
  final String name;
  final String category;
  final double distance;
  final double latitude;
  final double longitude;
  final List<Map<String, String>> offers;

  GeolocationOffer({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.offers,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'distance': distance,
    'latitude': latitude,
    'longitude': longitude,
    'offers': offers,
  };
}

class CalendarEvent {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String? eventType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.eventType,
    this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'location': location,
    'eventType': eventType,
    'metadata': metadata,
    'createdAt': createdAt.toIso8601String(),
  };
}

class SyncResult {
  final String userId;
  final DateTime timestamp;
  final List<String> syncedTypes;
  final List<String> failedTypes;
  final List<String> conflicts;

  SyncResult({
    required this.userId,
    required this.timestamp,
    required this.syncedTypes,
    required this.failedTypes,
    required this.conflicts,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'timestamp': timestamp.toIso8601String(),
    'syncedTypes': syncedTypes,
    'failedTypes': failedTypes,
    'conflicts': conflicts,
  };
}

class BackgroundSyncResult {
  final String userId;
  final DateTime timestamp;
  final SyncResult? syncResult;
  final bool hasNewNotifications;
  final List<LocationUpdate> locationUpdates;
  final bool success;
  final String? error;

  BackgroundSyncResult({
    required this.userId,
    required this.timestamp,
    this.syncResult,
    required this.hasNewNotifications,
    required this.locationUpdates,
    required this.success,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'timestamp': timestamp.toIso8601String(),
    'syncResult': syncResult?.toJson(),
    'hasNewNotifications': hasNewNotifications,
    'locationUpdates': locationUpdates.map((u) => u.toJson()).toList(),
    'success': success,
    'error': error,
  };
}

class LocationUpdate {
  final String type;
  final String description;
  final DateTime timestamp;

  LocationUpdate({
    required this.type,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
  };
}
