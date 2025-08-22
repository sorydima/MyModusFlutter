import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Фронтенд сервис для мобильных возможностей приложения
class MobileCapabilitiesService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api/mobile';
  
  final http.Client _httpClient = http.Client();
  
  // Состояние сервиса
  bool _isOnline = true;
  bool _isLocationEnabled = false;
  bool _isBackgroundSyncEnabled = false;
  String? _currentUserId;
  
  // Кэш для офлайн данных
  final Map<String, Map<String, dynamic>> _localCache = {};
  
  // Геолокационные данные
  Position? _currentPosition;
  String? _currentAddress;
  
  // Календарные события
  final List<CalendarEvent> _localEvents = [];
  
  // Геттеры
  bool get isOnline => _isOnline;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isBackgroundSyncEnabled => _isBackgroundSyncEnabled;
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  List<CalendarEvent> get localEvents => List.unmodifiable(_localEvents);

  MobileCapabilitiesService() {
    _initializeService();
  }

  // ===== ИНИЦИАЛИЗАЦИЯ =====

  Future<void> _initializeService() async {
    try {
      // Проверяем разрешения
      await _checkPermissions();
      
      // Загружаем локальные данные
      await _loadLocalData();
      
      // Проверяем подключение к интернету
      await _checkConnectivity();
      
      // Запускаем фоновую синхронизацию
      if (_isBackgroundSyncEnabled) {
        _startBackgroundSync();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize mobile capabilities service: $e');
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Проверяем разрешение на геолокацию
      final locationStatus = await Permission.location.status;
      _isLocationEnabled = locationStatus.isGranted;
      
      if (!_isLocationEnabled) {
        final result = await Permission.location.request();
        _isLocationEnabled = result.isGranted;
      }
      
      // Проверяем разрешение на фоновую синхронизацию
      final backgroundStatus = await Permission.ignoreBatteryOptimizations.status;
      _isBackgroundSyncEnabled = backgroundStatus.isGranted;
      
      if (!_isBackgroundSyncEnabled) {
        final result = await Permission.ignoreBatteryOptimizations.request();
        _isBackgroundSyncEnabled = result.isGranted;
      }
    } catch (e) {
      debugPrint('Failed to check permissions: $e');
    }
  }

  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString('mobile_cache');
      if (cacheData != null) {
        _localCache.addAll(Map<String, Map<String, dynamic>>.from(
          jsonDecode(cacheData),
        ));
      }
      
      final eventsData = prefs.getString('mobile_events');
      if (eventsData != null) {
        final eventsList = jsonDecode(eventsData) as List<dynamic>;
        _localEvents.addAll(
          eventsList.map((e) => CalendarEvent.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Failed to load local data: $e');
    }
  }

  Future<void> _saveLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mobile_cache', jsonEncode(_localCache));
      await prefs.setString('mobile_events', jsonEncode(
        _localEvents.map((e) => e.toJson()).toList(),
      ));
    } catch (e) {
      debugPrint('Failed to save local data: $e');
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final response = await _httpClient.get(Uri.parse('$baseUrl/health')).timeout(
        Duration(seconds: 5),
      );
      _isOnline = response.statusCode == 200;
    } catch (e) {
      _isOnline = false;
    }
    notifyListeners();
  }

  // ===== ОФЛАЙН РЕЖИМ =====

  /// Сохранение данных в локальный кэш
  Future<void> saveToLocalCache({
    required String userId,
    required String dataType,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (!_localCache.containsKey(userId)) {
        _localCache[userId] = {};
      }
      
      _localCache[userId]![dataType] = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      
      await _saveLocalData();
      
      // Если онлайн, пытаемся синхронизировать
      if (_isOnline) {
        await _syncToServer(userId: userId, dataType: dataType, data: data);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save to local cache: $e');
    }
  }

  /// Получение данных из локального кэша
  Map<String, dynamic>? getFromLocalCache({
    required String userId,
    required String dataType,
  }) {
    try {
      final cache = _localCache[userId];
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
      debugPrint('Failed to get from local cache: $e');
      return null;
    }
  }

  /// Синхронизация локальных данных с сервером
  Future<bool> syncLocalData({
    required String userId,
    List<String>? dataTypes,
  }) async {
    try {
      if (!_isOnline) return false;
      
      final types = dataTypes ?? _localCache[userId]?.keys.toList() ?? [];
      if (types.isEmpty) return true;
      
      for (final dataType in types) {
        final localData = getFromLocalCache(userId: userId, dataType: dataType);
        if (localData != null) {
          final success = await _syncToServer(
            userId: userId,
            dataType: dataType,
            data: localData,
          );
          
          if (success) {
            // Удаляем успешно синхронизированные данные
            _localCache[userId]?.remove(dataType);
          }
        }
      }
      
      await _saveLocalData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to sync local data: $e');
      return false;
    }
  }

  Future<bool> _syncToServer({
    required String userId,
    required String dataType,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/offline/cache'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'dataType': dataType,
          'data': data,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to sync to server: $e');
      return false;
    }
  }

  // ===== ГЕОЛОКАЦИЯ =====

  /// Получение текущего местоположения
  Future<Position?> getCurrentLocation() async {
    try {
      if (!_isLocationEnabled) {
        debugPrint('Location permission not granted');
        return null;
      }
      
      // Проверяем, включена ли геолокация
      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        debugPrint('Location service is disabled');
        return null;
      }
      
      // Получаем текущее местоположение
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      
      _currentPosition = position;
      
      // Получаем адрес по координатам
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      
      // Если онлайн, отправляем на сервер
      if (_isOnline && _currentUserId != null) {
        await _updateLocationOnServer(
          userId: _currentUserId!,
          latitude: position.latitude,
          longitude: position.longitude,
          address: _currentAddress,
          accuracy: position.accuracy,
        );
      }
      
      notifyListeners();
      return position;
    } catch (e) {
      debugPrint('Failed to get current location: $e');
      return null;
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await Geolocator.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentAddress = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      }
    } catch (e) {
      debugPrint('Failed to get address from coordinates: $e');
    }
  }

  Future<bool> _updateLocationOnServer({
    required String userId,
    required double latitude,
    required double longitude,
    String? address,
    double? accuracy,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/location/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'accuracy': accuracy,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to update location on server: $e');
      return false;
    }
  }

  /// Получение ближайших предложений по геолокации
  Future<List<GeolocationOffer>> getNearbyOffers({
    required String userId,
    required double radiusKm,
    String? category,
  }) async {
    try {
      if (!_isOnline) return [];
      
      final queryParams = <String, String>{
        'userId': userId,
        'radiusKm': radiusKm.toString(),
      };
      
      if (category != null) {
        queryParams['category'] = category;
      }
      
      final uri = Uri.parse('$baseUrl/location/nearby-offers').replace(
        queryParameters: queryParams,
      );
      
      final response = await _httpClient.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final offersList = data['offers'] as List<dynamic>;
        
        return offersList.map((o) => GeolocationOffer.fromJson(o)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get nearby offers: $e');
      return [];
    }
  }

  /// Получение ближайших магазинов
  Future<List<StoreInfo>> getNearbyStores({
    required String userId,
    required double radiusKm,
  }) async {
    try {
      if (!_isOnline) return [];
      
      final uri = Uri.parse('$baseUrl/location/stores').replace(
        queryParameters: {
          'userId': userId,
          'radiusKm': radiusKm.toString(),
        },
      );
      
      final response = await _httpClient.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final storesList = data['stores'] as List<dynamic>;
        
        return storesList.map((s) => StoreInfo.fromJson(s)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get nearby stores: $e');
      return [];
    }
  }

  // ===== КАЛЕНДАРЬ =====

  /// Добавление события в календарь
  Future<bool> addCalendarEvent({
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
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
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
      
      // Добавляем локально
      _localEvents.add(event);
      await _saveLocalData();
      
      // Если онлайн, отправляем на сервер
      if (_isOnline) {
        final success = await _addEventToServer(event);
        if (success) {
          // Обновляем ID события
          event.id = 'server_${event.id}';
          await _saveLocalData();
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to add calendar event: $e');
      return false;
    }
  }

  Future<bool> _addEventToServer(CalendarEvent event) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/calendar/event'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toJson()),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to add event to server: $e');
      return false;
    }
  }

  /// Получение событий календаря
  Future<List<CalendarEvent>> getCalendarEvents({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  }) async {
    try {
      // Сначала возвращаем локальные события
      var events = List<CalendarEvent>.from(_localEvents);
      
      // Фильтруем по пользователю
      events = events.where((e) => e.userId == userId).toList();
      
      // Фильтруем по датам
      if (startDate != null) {
        events = events.where((e) => e.startTime.isAfter(startDate)).toList();
      }
      
      if (endDate != null) {
        events = events.where((e) => e.endTime.isBefore(endDate)).toList();
      }
      
      // Фильтруем по типу
      if (eventType != null) {
        events = events.where((e) => e.eventType == eventType).toList();
      }
      
      // Сортируем по времени начала
      events.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      // Если онлайн, пытаемся получить с сервера
      if (_isOnline) {
        final serverEvents = await _getEventsFromServer(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
          eventType: eventType,
        );
        
        // Объединяем с локальными событиями
        for (final serverEvent in serverEvents) {
          if (!events.any((e) => e.id == serverEvent.id)) {
            events.add(serverEvent);
            _localEvents.add(serverEvent);
          }
        }
        
        await _saveLocalData();
      }
      
      return events;
    } catch (e) {
      debugPrint('Failed to get calendar events: $e');
      return _localEvents.where((e) => e.userId == userId).toList();
    }
  }

  Future<List<CalendarEvent>> _getEventsFromServer({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  }) async {
    try {
      final queryParams = <String, String>{
        'userId': userId,
      };
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      
      if (eventType != null) {
        queryParams['eventType'] = eventType;
      }
      
      final uri = Uri.parse('$baseUrl/calendar/events/$userId').replace(
        queryParameters: queryParams,
      );
      
      final response = await _httpClient.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final eventsList = data['events'] as List<dynamic>;
        
        return eventsList.map((e) => CalendarEvent.fromJson(e)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get events from server: $e');
      return [];
    }
  }

  // ===== ФОНОВАЯ СИНХРОНИЗАЦИЯ =====

  /// Запуск фоновой синхронизации
  Future<void> _startBackgroundSync() async {
    if (!_isBackgroundSyncEnabled || _currentUserId == null) return;
    
    try {
      // Синхронизируем локальные данные
      await syncLocalData(userId: _currentUserId!);
      
      // Получаем новые данные с сервера
      await _refreshFromServer(userId: _currentUserId!);
      
      debugPrint('Background sync completed');
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }

  Future<void> _refreshFromServer(String userId) async {
    try {
      // Обновляем события календаря
      final events = await _getEventsFromServer(userId: userId);
      for (final event in events) {
        if (!_localEvents.any((e) => e.id == event.id)) {
          _localEvents.add(event);
        }
      }
      
      await _saveLocalData();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh from server: $e');
    }
  }

  // ===== УПРАВЛЕНИЕ СОСТОЯНИЕМ =====

  /// Установка текущего пользователя
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  /// Очистка данных пользователя
  void clearUserData() {
    _currentUserId = null;
    _localCache.clear();
    _localEvents.clear();
    _saveLocalData();
    notifyListeners();
  }

  /// Проверка подключения к интернету
  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }

  /// Принудительная синхронизация
  Future<void> forceSync() async {
    if (_currentUserId != null) {
      await syncLocalData(userId: _currentUserId!);
      await _refreshFromServer(_currentUserId!);
    }
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}

// ===== МОДЕЛИ ДАННЫХ =====

class CalendarEvent {
  String id;
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

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    description: json['description'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    location: json['location'],
    eventType: json['eventType'],
    metadata: json['metadata'],
    createdAt: DateTime.parse(json['createdAt']),
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

  factory GeolocationOffer.fromJson(Map<String, dynamic> json) => GeolocationOffer(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    distance: json['distance'].toDouble(),
    latitude: json['latitude'].toDouble(),
    longitude: json['longitude'].toDouble(),
    offers: List<Map<String, String>>.from(json['offers']),
  );
}

class StoreInfo {
  final String id;
  final String name;
  final String category;
  final double distance;
  final String address;
  final double rating;
  final List<String> offers;

  StoreInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.address,
    required this.rating,
    required this.offers,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'distance': distance,
    'address': address,
    'rating': rating,
    'offers': offers,
  };

  factory StoreInfo.fromJson(Map<String, dynamic> json) => StoreInfo(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    distance: json['distance'].toDouble(),
    address: json['address'],
    rating: json['rating'].toDouble(),
    offers: List<String>.from(json['offers']),
  );
}
