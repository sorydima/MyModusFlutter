import 'dart:convert';
import 'package:http/http.dart' as http;

class AIColorMatcherService {
  static const String baseUrl = 'http://localhost:8080/api/color-matcher';

  /// Анализ цветов на фото
  Future<Map<String, dynamic>> analyzePhotoColors({
    required String imageUrl,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-photo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'imageUrl': imageUrl,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze photo colors: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Получение персональной палитры
  Future<Map<String, dynamic>> getPersonalPalette(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personal-palette/$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get personal palette: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Генерация персональной палитры
  Future<Map<String, dynamic>> generatePersonalPalette({
    required String userId,
    List<String>? preferredColors,
    String? skinTone,
    String? hairColor,
    String? eyeColor,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-palette'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'preferredColors': preferredColors,
          'skinTone': skinTone,
          'hairColor': hairColor,
          'eyeColor': eyeColor,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate personal palette: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Поиск гармоничных цветов
  Future<Map<String, dynamic>> findHarmoniousColors({
    required String baseColor,
    String harmonyType = 'complementary',
    int count = 5,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/harmonious-colors?baseColor=$baseColor&harmonyType=$harmonyType&count=$count'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to find harmonious colors: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Получение теории цвета
  Future<Map<String, dynamic>> getColorTheory(String harmonyType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/color-theory/$harmonyType'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get color theory: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Получение цветовых рекомендаций
  Future<Map<String, dynamic>> getColorRecommendations({
    required String userId,
    String? occasion,
    String? season,
    List<String>? existingColors,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (occasion != null) queryParams['occasion'] = occasion;
      if (season != null) queryParams['season'] = season;
      if (existingColors != null) queryParams['existingColors'] = existingColors.join(',');

      final uri = Uri.parse('$baseUrl/recommendations/$userId').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get color recommendations: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Получение рекомендаций для образов
  Future<Map<String, dynamic>> getOutfitRecommendations({
    required String userId,
    String? occasion,
    String? season,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (occasion != null) queryParams['occasion'] = occasion;
      if (season != null) queryParams['season'] = season;

      final uri = Uri.parse('$baseUrl/outfit-recommendations/$userId').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get outfit recommendations: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Анализ цветовых трендов
  Future<Map<String, dynamic>> analyzeColorTrends({
    String? category,
    String? season,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (season != null) queryParams['season'] = season;
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/color-trends').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze color trends: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Получение сезонных палитр
  Future<Map<String, dynamic>> getSeasonalPalettes({String? season}) async {
    try {
      final queryParams = <String, String>{};
      if (season != null) queryParams['season'] = season;

      final uri = Uri.parse('$baseUrl/seasonal-palettes').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get seasonal palettes: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Сохранение цветовой палитры
  Future<Map<String, dynamic>> saveColorPalette({
    required String userId,
    required String name,
    required List<String> colors,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save-palette'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'name': name,
          'colors': colors,
          'description': description,
          'tags': tags,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to save color palette: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Получение палитр пользователя
  Future<Map<String, dynamic>> getUserPalettes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-palettes/$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user palettes: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Удаление цветовой палитры
  Future<Map<String, dynamic>> deleteColorPalette(String paletteId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/palette/$paletteId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete color palette: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Получение истории цветовых анализов
  Future<Map<String, dynamic>> getUserColorHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/$userId?limit=$limit'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user color history: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Получение статистики пользователя
  Future<Map<String, dynamic>> getUserColorStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user color stats: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Экспорт цветовой палитры
  Future<Map<String, dynamic>> exportColorPalette(String paletteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/export-palette/$paletteId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to export color palette: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Импорт цветовой палитры
  Future<Map<String, dynamic>> importColorPalette({
    required String userId,
    required Map<String, dynamic> palette,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/import-palette'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'palette': palette,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to import color palette: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Обновление предпочтений пользователя
  Future<Map<String, dynamic>> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user-preferences/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(preferences),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user preferences: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Получение предпочтений пользователя
  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-preferences/$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user preferences: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Утилитарные методы

  /// Получение доступных типов гармонии
  List<String> getAvailableHarmonyTypes() {
    return ['complementary', 'analogous', 'triadic', 'monochromatic'];
  }

  /// Получение доступных сезонов
  List<String> getAvailableSeasons() {
    return ['spring', 'summer', 'autumn', 'winter'];
  }

  /// Получение доступных случаев
  List<String> getAvailableOccasions() {
    return ['casual', 'business', 'formal', 'party', 'sport'];
  }

  /// Получение доступных тонов кожи
  List<String> getAvailableSkinTones() {
    return ['warm', 'cool', 'neutral', 'olive', 'dark'];
  }

  /// Получение доступных цветов волос
  List<String> getAvailableHairColors() {
    return ['black', 'brown', 'blonde', 'red', 'gray', 'white'];
  }

  /// Получение доступных цветов глаз
  List<String> getAvailableEyeColors() {
    return ['brown', 'blue', 'green', 'hazel', 'gray'];
  }

  /// Форматирование цвета для отображения
  String formatColor(String hexColor) {
    return hexColor.toUpperCase();
  }

  /// Получение названия цвета
  String getColorName(String hexColor) {
    final colorNames = {
      '#FF6B6B': 'Коралловый',
      '#4ECDC4': 'Бирюзовый',
      '#45B7D1': 'Голубой',
      '#96CEB4': 'Мятный',
      '#FFEAA7': 'Кремовый',
      '#DDA0DD': 'Лавандовый',
      '#FF0000': 'Красный',
      '#00FF00': 'Зеленый',
      '#0000FF': 'Синий',
      '#FFFF00': 'Желтый',
      '#FF00FF': 'Пурпурный',
      '#00FFFF': 'Голубой',
    };
    
    return colorNames[hexColor.toUpperCase()] ?? 'Неизвестный цвет';
  }

  /// Получение типа гармонии на русском
  String getHarmonyTypeName(String harmonyType) {
    final names = {
      'complementary': 'Дополнительные',
      'analogous': 'Аналогичные',
      'triadic': 'Триадная',
      'monochromatic': 'Монохромная',
    };
    
    return names[harmonyType] ?? harmonyType;
  }

  /// Получение сезона на русском
  String getSeasonName(String season) {
    final names = {
      'spring': 'Весна',
      'summer': 'Лето',
      'autumn': 'Осень',
      'winter': 'Зима',
    };
    
    return names[season] ?? season;
  }

  /// Получение случая на русском
  String getOccasionName(String occasion) {
    final names = {
      'casual': 'Повседневный',
      'business': 'Деловой',
      'formal': 'Формальный',
      'party': 'Праздничный',
      'sport': 'Спортивный',
    };
    
    return names[occasion] ?? occasion;
  }
}
