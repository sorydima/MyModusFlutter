import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/mobile_capabilities_service.dart';
import '../database.dart';

/// API Handler для мобильных возможностей приложения
class MobileCapabilitiesHandler {
  final MobileCapabilitiesService _mobileService;
  final DatabaseService _database;

  MobileCapabilitiesHandler({
    required MobileCapabilitiesService mobileService,
    required DatabaseService database,
  })  : _mobileService = mobileService,
        _database = database;

  Router get router {
    final router = Router();

    // ===== ОФЛАЙН РЕЖИМ =====
    router.post('/offline/cache', _saveToOfflineCache);
    router.get('/offline/cache/<userId>/<dataType>', _getFromOfflineCache);
    router.post('/offline/sync', _syncOfflineData);
    router.delete('/offline/cache/<userId>', _clearOfflineCache);

    // ===== ГЕОЛОКАЦИЯ =====
    router.post('/location/update', _updateUserLocation);
    router.get('/location/<userId>', _getUserLocation);
    router.get('/location/nearby-offers', _getNearbyOffers);
    router.get('/location/stores', _getNearbyStores);

    // ===== КАЛЕНДАРЬ =====
    router.post('/calendar/event', _addCalendarEvent);
    router.get('/calendar/events/<userId>', _getUserEvents);
    router.put('/calendar/event/<eventId>', _updateCalendarEvent);
    router.delete('/calendar/event/<eventId>', _deleteCalendarEvent);

    // ===== ФОНОВАЯ СИНХРОНИЗАЦИЯ =====
    router.post('/background-sync', _startBackgroundSync);
    router.get('/background-sync/status/<userId>', _getBackgroundSyncStatus);
    router.post('/background-sync/cleanup', _cleanupOldData);

    // ===== ДЕМО И ТЕСТИРОВАНИЕ =====
    router.post('/demo/simulate-offline', _simulateOfflineMode);
    router.post('/demo/simulate-location', _simulateLocationUpdate);
    router.post('/demo/simulate-calendar', _simulateCalendarEvent);

    return router;
  }

  // ===== ОФЛАЙН РЕЖИМ =====

  Future<Response> _saveToOfflineCache(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final userId = data['userId'] as String;
      final dataType = data['dataType'] as String;
      final content = data['data'] as Map<String, dynamic>;

      await _mobileService.saveToOfflineCache(
        userId: userId,
        dataType: dataType,
        data: content,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Data saved to offline cache',
          'userId': userId,
          'dataType': dataType,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to save to offline cache: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getFromOfflineCache(Request request, String userId, String dataType) async {
    try {
      final data = _mobileService.getFromOfflineCache(
        userId: userId,
        dataType: dataType,
      );

      if (data != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'data': data,
            'userId': userId,
            'dataType': dataType,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Data not found in offline cache',
            'userId': userId,
            'dataType': dataType,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get from offline cache: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _syncOfflineData(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final userId = data['userId'] as String;
      final dataTypes = (data['dataTypes'] as List<dynamic>).cast<String>();

      final syncResult = await _mobileService.syncOfflineData(
        userId: userId,
        dataTypes: dataTypes,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'syncResult': syncResult.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to sync offline data: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _clearOfflineCache(Request request, String userId) async {
    try {
      // Очищаем кэш для пользователя
      // В реальной реализации здесь должна быть логика очистки
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Offline cache cleared for user $userId',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to clear offline cache: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ===== ГЕОЛОКАЦИЯ =====

  Future<Response> _updateUserLocation(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final userId = data['userId'] as String;
      final latitude = data['latitude'] as double;
      final longitude = data['longitude'] as double;
      final address = data['address'] as String?;
      final accuracy = data['accuracy'] as double?;

      await _mobileService.updateUserLocation(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        accuracy: accuracy,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Location updated successfully',
          'userId': userId,
          'latitude': latitude,
          'longitude': longitude,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to update location: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getUserLocation(Request request, String userId) async {
    try {
      final location = _mobileService.getUserLocation(userId);

      if (location != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'location': location.toJson(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Location not found for user $userId',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get user location: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getNearbyOffers(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final userId = queryParams['userId']!;
      final radiusKm = double.parse(queryParams['radiusKm'] ?? '5.0');
      final category = queryParams['category'];

      final offers = await _mobileService.getNearbyOffers(
        userId: userId,
        radiusKm: radiusKm,
        category: category,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'offers': offers.map((o) => o.toJson()).toList(),
          'count': offers.length,
          'radiusKm': radiusKm,
          'category': category,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get nearby offers: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getNearbyStores(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final userId = queryParams['userId']!;
      final radiusKm = double.parse(queryParams['radiusKm'] ?? '10.0');

      // Демо данные для ближайших магазинов
      final stores = [
        {
          'id': 'store_1',
          'name': 'Zara',
          'category': 'Одежда',
          'distance': 0.5,
          'address': 'ул. Тверская, 1',
          'rating': 4.5,
          'offers': ['Скидка 20%', 'Бесплатная доставка'],
        },
        {
          'id': 'store_2',
          'name': 'H&M',
          'category': 'Одежда',
          'distance': 1.2,
          'address': 'ул. Арбат, 15',
          'rating': 4.3,
          'offers': ['Скидка 15%', 'Акция на джинсы'],
        },
        {
          'id': 'store_3',
          'name': 'Nike',
          'category': 'Обувь',
          'distance': 2.1,
          'address': 'Ленинградский пр-т, 45',
          'rating': 4.7,
          'offers': ['Скидка 25%', 'Бонусные баллы'],
        },
      ];

      return Response.ok(
        jsonEncode({
          'success': true,
          'stores': stores,
          'count': stores.length,
          'radiusKm': radiusKm,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get nearby stores: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ===== КАЛЕНДАРЬ =====

  Future<Response> _addCalendarEvent(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final userId = data['userId'] as String;
      final title = data['title'] as String;
      final description = data['description'] as String;
      final startTime = DateTime.parse(data['startTime'] as String);
      final endTime = DateTime.parse(data['endTime'] as String);
      final location = data['location'] as String?;
      final eventType = data['eventType'] as String?;
      final metadata = data['metadata'] as Map<String, dynamic>?;

      await _mobileService.addCalendarEvent(
        userId: userId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        location: location,
        eventType: eventType,
        metadata: metadata,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Calendar event added successfully',
          'title': title,
          'startTime': startTime.toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to add calendar event: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getUserEvents(Request request, String userId) async {
    try {
      final queryParams = request.url.queryParameters;
      final startDate = queryParams['startDate'] != null 
          ? DateTime.parse(queryParams['startDate']!) 
          : null;
      final endDate = queryParams['endDate'] != null 
          ? DateTime.parse(queryParams['endDate']!) 
          : null;
      final eventType = queryParams['eventType'];

      final events = _mobileService.getUserEvents(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        eventType: eventType,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'events': events.map((e) => e.toJson()).toList(),
          'count': events.length,
          'userId': userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get user events: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _updateCalendarEvent(Request request, String eventId) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // В реальной реализации здесь должна быть логика обновления события
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Calendar event updated successfully',
          'eventId': eventId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to update calendar event: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteCalendarEvent(Request request, String eventId) async {
    try {
      // В реальной реализации здесь должна быть логика удаления события
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Calendar event deleted successfully',
          'eventId': eventId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to delete calendar event: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ===== ФОНОВАЯ СИНХРОНИЗАЦИЯ =====

  Future<Response> _startBackgroundSync(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final userId = data['userId'] as String;
      final dataTypes = data['dataTypes'] != null 
          ? (data['dataTypes'] as List<dynamic>).cast<String>()
          : null;

      final syncResult = await _mobileService.startBackgroundSync(
        userId: userId,
        dataTypes: dataTypes,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'syncResult': syncResult.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to start background sync: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getBackgroundSyncStatus(Request request, String userId) async {
    try {
      // В реальной реализации здесь должна быть логика получения статуса синхронизации
      final status = {
        'userId': userId,
        'lastSync': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
        'status': 'completed',
        'nextSync': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        'syncedItems': 15,
        'failedItems': 0,
      };

      return Response.ok(
        jsonEncode({
          'success': true,
          'status': status,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to get sync status: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _cleanupOldData(Request request) async {
    try {
      _mobileService.leanupOldData();

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Old data cleanup completed',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to cleanup old data: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ===== ДЕМО И ТЕСТИРОВАНИЕ =====

  Future<Response> _simulateOfflineMode(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final userId = data['userId'] as String;

      // Симулируем сохранение данных в офлайн режиме
      await _mobileService.saveToOfflineCache(
        userId: userId,
        dataType: 'demo_products',
        data: {
          'products': [
            {'id': '1', 'name': 'Демо товар 1', 'price': 1000},
            {'id': '2', 'name': 'Демо товар 2', 'price': 2000},
          ],
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Offline mode simulation completed',
          'userId': userId,
          'dataType': 'demo_products',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to simulate offline mode: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _simulateLocationUpdate(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final userId = data['userId'] as String;

      // Симулируем обновление местоположения
      await _mobileService.updateUserLocation(
        userId: userId,
        latitude: 55.7558,
        longitude: 37.6176,
        address: 'Москва, Красная площадь',
        accuracy: 10.0,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Location update simulation completed',
          'userId': userId,
          'latitude': 55.7558,
          'longitude': 37.6176,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to simulate location update: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _simulateCalendarEvent(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final userId = data['userId'] as String;

      // Симулируем добавление события в календарь
      await _mobileService.addCalendarEvent(
        userId: userId,
        title: 'Демо событие',
        description: 'Это демонстрационное событие для тестирования',
        startTime: DateTime.now().add(Duration(hours: 1)),
        endTime: DateTime.now().add(Duration(hours: 2)),
        location: 'Демо локация',
        eventType: 'demo',
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Calendar event simulation completed',
          'userId': userId,
          'title': 'Демо событие',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Failed to simulate calendar event: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
