import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logger/logger.dart';
import '../services/ai_color_matcher_service.dart';
import '../database.dart';
import '../models.dart';

class AIColorMatcherHandler {
  final AIColorMatcherService _colorMatcherService;
  final DatabaseService _db;
  final Logger _logger = Logger();

  AIColorMatcherHandler({
    required AIColorMatcherService colorMatcherService,
    required DatabaseService db,
  })  : _colorMatcherService = colorMatcherService,
        _db = db;

  Router get router {
    final router = Router();

    // Основные эндпоинты для анализа цветов
    router.post('/analyze-photo', _analyzePhotoColors);
    router.get('/personal-palette/<userId>', _getPersonalPalette);
    router.post('/generate-palette', _generatePersonalPalette);
    
    // Подбор гармоничных цветов
    router.get('/harmonious-colors', _findHarmoniousColors);
    router.get('/color-theory/<harmonyType>', _getColorTheory);
    
    // Рекомендации
    router.get('/recommendations/<userId>', _getColorRecommendations);
    router.get('/outfit-recommendations/<userId>', _getOutfitRecommendations);
    
    // Тренды и аналитика
    router.get('/color-trends', _analyzeColorTrends);
    router.get('/seasonal-palettes', _getSeasonalPalettes);
    
    // Управление палитрами
    router.post('/save-palette', _saveColorPalette);
    router.get('/user-palettes/<userId>', _getUserPalettes);
    router.delete('/palette/<paletteId>', _deleteColorPalette);
    
    // История и статистика
    router.get('/history/<userId>', _getUserColorHistory);
    router.get('/stats/<userId>', _getUserColorStats);
    
    // Экспорт и импорт
    router.get('/export-palette/<paletteId>', _exportColorPalette);
    router.post('/import-palette', _importColorPalette);
    
    // Настройки пользователя
    router.put('/user-preferences/<userId>', _updateUserPreferences);
    router.get('/user-preferences/<userId>', _getUserPreferences);

    return router;
  }

  // Анализ цветов на фото
  Future<Response> _analyzePhotoColors(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      
      final imageUrl = data['imageUrl'] as String?;
      final userId = data['userId'] as String?;
      
      if (imageUrl == null || userId == null) {
        return Response(400,
            body: json.encode({
              'success': false,
              'error': 'Missing required fields: imageUrl, userId',
            }),
            headers: {'content-type': 'application/json'});
      }

      final result = await _colorMatcherService.analyzePhotoColors(
        imageUrl: imageUrl,
        userId: userId,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _analyzePhotoColors: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Получение персональной палитры
  Future<Response> _getPersonalPalette(Request request, String userId) async {
    try {
      final result = await _colorMatcherService.getUserColorHistory(
        userId: userId,
        limit: 1,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _getPersonalPalette: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Генерация персональной палитры
  Future<Response> _generatePersonalPalette(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as String?;
      final preferredColors = data['preferredColors'] as List<String>?;
      final skinTone = data['skinTone'] as String?;
      final hairColor = data['hairColor'] as String?;
      final eyeColor = data['eyeColor'] as String?;
      
      if (userId == null) {
        return Response(400,
            body: json.encode({
              'success': false,
              'error': 'Missing required field: userId',
            }),
            headers: {'content-type': 'application/json'});
      }

      final result = await _colorMatcherService.generatePersonalPalette(
        userId: userId,
        preferredColors: preferredColors,
        skinTone: skinTone,
        hairColor: hairColor,
        eyeColor: eyeColor,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _generatePersonalPalette: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Поиск гармоничных цветов
  Future<Response> _findHarmoniousColors(Request request) async {
    try {
      final baseColor = request.url.queryParameters['baseColor'];
      final harmonyType = request.url.queryParameters['harmonyType'] ?? 'complementary';
      final count = int.tryParse(request.url.queryParameters['count'] ?? '5') ?? 5;
      
      if (baseColor == null) {
        return Response(400,
            body: json.encode({
              'success': false,
              'error': 'Missing required parameter: baseColor',
            }),
            headers: {'content-type': 'application/json'});
      }

      final result = await _colorMatcherService.findHarmoniousColors(
        baseColor: baseColor,
        harmonyType: harmonyType,
        count: count,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _findHarmoniousColors: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Получение теории цвета
  Future<Response> _getColorTheory(Request request, String harmonyType) async {
    try {
      final result = {
        'success': true,
        'harmonyType': harmonyType,
        'theory': _getTheoryInfo(harmonyType),
      };

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _getColorTheory: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Получение цветовых рекомендаций
  Future<Response> _getColorRecommendations(Request request, String userId) async {
    try {
      final occasion = request.url.queryParameters['occasion'];
      final season = request.url.queryParameters['season'];
      final existingColors = request.url.queryParameters['existingColors']?.split(',');
      
      final result = await _colorMatcherService.getColorRecommendations(
        userId: userId,
        occasion: occasion,
        season: season,
        existingColors: existingColors,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _getColorRecommendations: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Получение рекомендаций для образов
  Future<Response> _getOutfitRecommendations(Request request, String userId) async {
    try {
      final occasion = request.url.queryParameters['occasion'];
      final season = request.url.queryParameters['season'];
      
      final result = await _colorMatcherService.getColorRecommendations(
        userId: userId,
        occasion: occasion,
        season: season,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _getOutfitRecommendations: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Анализ цветовых трендов
  Future<Response> _analyzeColorTrends(Request request) async {
    try {
      final category = request.url.queryParameters['category'];
      final season = request.url.queryParameters['season'];
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;
      
      final result = await _colorMatcherService.analyzeColorTrends(
        category: category,
        season: season,
        limit: limit,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _analyzeColorTrends: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Получение сезонных палитр
  Future<Response> _getSeasonalPalettes(Request request) async {
    try {
      final season = request.url.queryParameters['season'];
      
      final seasonalPalettes = {
        'spring': ['#FFB3BA', '#BAFFC9', '#BAE1FF', '#FFFFBA'],
        'summer': ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4'],
        'autumn': ['#D2691E', '#CD853F', '#8B4513', '#A0522D'],
        'winter': ['#000080', '#800080', '#008080', '#800000'],
      };
      
      final result = {
        'success': true,
        'seasonalPalettes': seasonalPalettes,
        'currentSeason': season ?? 'all',
      };

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _getSeasonalPalettes: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Сохранение цветовой палитры
  Future<Response> _saveColorPalette(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as String?;
      final name = data['name'] as String?;
      final colors = data['colors'] as List<String>?;
      final description = data['description'] as String?;
      final tags = data['tags'] as List<String>?;
      
      if (userId == null || name == null || colors == null) {
        return Response(400,
            body: json.encode({
              'success': false,
              'error': 'Missing required fields: userId, name, colors',
            }),
            headers: {'content-type': 'application/json'});
      }

      final result = await _colorMatcherService.saveColorPalette(
        userId: userId,
        name: name,
        colors: colors,
        description: description,
        tags: tags,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _saveColorPalette: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Получение палитр пользователя
  Future<Response> _getUserPalettes(Request request, String userId) async {
    try {
      final result = await _colorMatcherService.getUserColorHistory(
        userId: userId,
        limit: 50,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _getUserPalettes: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Удаление цветовой палитры
  Future<Response> _deleteColorPalette(Request request, String paletteId) async {
    try {
      // TODO: Реализовать удаление палитры
      final result = {
        'success': true,
        'message': 'Color palette deleted successfully',
        'paletteId': paletteId,
      };

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _deleteColorPalette: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Получение истории цветовых анализов
  Future<Response> _getUserColorHistory(Request request, String userId) async {
    try {
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      
      final result = await _colorMatcherService.getUserColorHistory(
        userId: userId,
        limit: limit,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _getUserColorHistory: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Получение статистики пользователя
  Future<Response> _getUserColorStats(Request request, String userId) async {
    try {
      final result = await _colorMatcherService.getUserColorHistory(
        userId: userId,
        limit: 100,
      );

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _getUserColorStats: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Экспорт цветовой палитры
  Future<Response> _exportColorPalette(Request request, String paletteId) async {
    try {
      // TODO: Реализовать экспорт палитры
      final result = {
        'success': true,
        'paletteId': paletteId,
        'exportFormat': 'json',
        'data': {
          'name': 'Exported Palette',
          'colors': ['#FF6B6B', '#4ECDC4', '#45B7D1'],
          'createdAt': DateTime.now().toIso8601String(),
        },
      };

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _exportColorPalette: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Импорт цветовой палитры
  Future<Response> _importColorPalette(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as String?;
      final paletteData = data['palette'] as Map<String, dynamic>?;
      
      if (userId == null || paletteData == null) {
        return Response(400,
            body: json.encode({
              'success': false,
              'error': 'Missing required fields: userId, palette',
            }),
            headers: {'content-type': 'application/json'});
      }

      // TODO: Реализовать импорт палитры
      final result = {
        'success': true,
        'message': 'Color palette imported successfully',
        'paletteId': 'imported_${DateTime.now().millisecondsSinceEpoch}',
      };

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _importColorPalette: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Обновление предпочтений пользователя
  Future<Response> _updateUserPreferences(Request request, String userId) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      
      // TODO: Реализовать обновление предпочтений
      final result = {
        'success': true,
        'message': 'User preferences updated successfully',
        'userId': userId,
      };

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _updateUserPreferences: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Получение предпочтений пользователя
  Future<Response> _getUserPreferences(Request request, String userId) async {
    try {
      // TODO: Реализовать получение предпочтений
      final result = {
        'success': true,
        'userId': userId,
        'preferences': {
          'skinTone': 'warm',
          'hairColor': 'brown',
          'eyeColor': 'brown',
          'preferredColors': ['#FF6B6B', '#4ECDC4'],
          'avoidedColors': ['#000000'],
          'style': 'casual',
        },
      };

      return Response(200,
          body: json.encode(result),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      _logger.error('Error in _getUserPreferences: $e');
      return Response(500,
          body: json.encode({
            'success': false,
            'error': 'Internal server error: $e',
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // Вспомогательный метод для получения теории цвета
  Map<String, dynamic> _getTheoryInfo(String harmonyType) {
    final theories = {
      'complementary': {
        'name': 'Дополнительные цвета',
        'description': 'Создают яркий контраст и динамичный образ',
        'tips': ['Используйте 60-30-10 правило', 'Добавляйте нейтральные цвета'],
        'examples': ['Красный + Зеленый', 'Синий + Оранжевый'],
      },
      'analogous': {
        'name': 'Аналогичные цвета',
        'description': 'Создают гармоничный и спокойный образ',
        'tips': ['Выбирайте цвета рядом на цветовом круге', 'Используйте 3-5 цветов'],
        'examples': ['Красный + Оранжевый + Желтый', 'Синий + Голубой + Зеленый'],
      },
      'triadic': {
        'name': 'Триадная схема',
        'description': 'Обеспечивает сбалансированность и яркость',
        'tips': ['Выбирайте цвета на равном расстоянии', 'Один цвет должен быть доминирующим'],
        'examples': ['Красный + Желтый + Синий', 'Оранжевый + Зеленый + Фиолетовый'],
      },
      'monochromatic': {
        'name': 'Монохромная схема',
        'description': 'Создает элегантный и утонченный образ',
        'tips': ['Используйте разные оттенки одного цвета', 'Добавляйте текстуры'],
        'examples': ['Светло-синий + Синий + Темно-синий'],
      },
    };
    
    return theories[harmonyType] ?? {
      'name': 'Неизвестный тип',
      'description': 'Информация недоступна',
      'tips': [],
      'examples': [],
    };
  }
}
