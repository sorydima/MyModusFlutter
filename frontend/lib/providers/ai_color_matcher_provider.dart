import 'package:flutter/foundation.dart';
import '../services/ai_color_matcher_service.dart';

class AIColorMatcherProvider extends ChangeNotifier {
  final AIColorMatcherService _colorMatcherService = AIColorMatcherService();
  
  // Состояние анализа фото
  Map<String, dynamic>? _photoAnalysis;
  bool _isAnalyzingPhoto = false;
  String? _photoAnalysisError;
  
  // Состояние персональной палитры
  List<Map<String, dynamic>>? _personalPalette;
  bool _isGeneratingPalette = false;
  String? _paletteGenerationError;
  
  // Состояние гармоничных цветов
  List<Map<String, dynamic>>? _harmoniousColors;
  bool _isFindingHarmoniousColors = false;
  String? _harmoniousColorsError;
  
  // Состояние рекомендаций
  List<Map<String, dynamic>>? _colorRecommendations;
  bool _isLoadingRecommendations = false;
  String? _recommendationsError;
  
  // Состояние трендов
  List<Map<String, dynamic>>? _colorTrends;
  bool _isLoadingTrends = false;
  String? _trendsError;
  
  // Состояние сезонных палитр
  Map<String, dynamic>? _seasonalPalettes;
  bool _isLoadingSeasonalPalettes = false;
  String? _seasonalPalettesError;
  
  // Состояние пользовательских палитр
  List<Map<String, dynamic>>? _userPalettes;
  bool _isLoadingUserPalettes = false;
  String? _userPalettesError;
  
  // Состояние истории
  List<Map<String, dynamic>>? _colorHistory;
  bool _isLoadingHistory = false;
  String? _colorHistoryError;
  
  // Состояние статистики
  Map<String, dynamic>? _userColorStats;
  bool _isLoadingStats = false;
  String? _userStatsError;
  
  // Состояние предпочтений
  Map<String, dynamic>? _userPreferences;
  bool _isLoadingPreferences = false;
  String? _userPreferencesError;
  
  // Фильтры
  String _selectedHarmonyType = 'complementary';
  String _selectedSeason = 'all';
  String _selectedOccasion = 'all';
  String _selectedCategory = 'all';
  
  // Геттеры
  Map<String, dynamic>? get photoAnalysis => _photoAnalysis;
  bool get isAnalyzingPhoto => _isAnalyzingPhoto;
  String? get photoAnalysisError => _photoAnalysisError;
  
  List<Map<String, dynamic>>? get personalPalette => _personalPalette;
  bool get isGeneratingPalette => _isGeneratingPalette;
  String? get paletteGenerationError => _paletteGenerationError;
  
  List<Map<String, dynamic>>? get harmoniousColors => _harmoniousColors;
  bool get isFindingHarmoniousColors => _isFindingHarmoniousColors;
  String? get harmoniousColorsError => _harmoniousColorsError;
  
  List<Map<String, dynamic>>? get colorRecommendations => _colorRecommendations;
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  String? get recommendationsError => _recommendationsError;
  
  List<Map<String, dynamic>>? get colorTrends => _colorTrends;
  bool get isLoadingTrends => _isLoadingTrends;
  String? get trendsError => _trendsError;
  
  Map<String, dynamic>? get seasonalPalettes => _seasonalPalettes;
  bool get isLoadingSeasonalPalettes => _isLoadingSeasonalPalettes;
  String? get seasonalPalettesError => _seasonalPalettesError;
  
  List<Map<String, dynamic>>? get userPalettes => _userPalettes;
  bool get isLoadingUserPalettes => _isLoadingUserPalettes;
  String? get userPalettesError => _userPalettesError;
  
  List<Map<String, dynamic>>? get colorHistory => _colorHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get colorHistoryError => _colorHistoryError;
  
  Map<String, dynamic>? get userColorStats => _userColorStats;
  bool get isLoadingStats => _isLoadingStats;
  String? get userStatsError => _userStatsError;
  
  Map<String, dynamic>? get userPreferences => _userPreferences;
  bool get isLoadingPreferences => _isLoadingPreferences;
  String? get userPreferencesError => _userPreferencesError;
  
  String get selectedHarmonyType => _selectedHarmonyType;
  String get selectedSeason => _selectedSeason;
  String get selectedOccasion => _selectedOccasion;
  String get selectedCategory => _selectedCategory;
  
  // Методы для анализа фото
  Future<void> analyzePhotoColors({
    required String imageUrl,
    required String userId,
  }) async {
    _isAnalyzingPhoto = true;
    _photoAnalysisError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.analyzePhotoColors(
        imageUrl: imageUrl,
        userId: userId,
      );
      
      if (result['success'] == true) {
        _photoAnalysis = result;
        _photoAnalysisError = null;
      } else {
        _photoAnalysisError = result['error'] ?? 'Failed to analyze photo';
      }
    } catch (e) {
      _photoAnalysisError = 'Error: $e';
    } finally {
      _isAnalyzingPhoto = false;
      notifyListeners();
    }
  }
  
  // Методы для персональной палитры
  Future<void> generatePersonalPalette({
    required String userId,
    List<String>? preferredColors,
    String? skinTone,
    String? hairColor,
    String? eyeColor,
  }) async {
    _isGeneratingPalette = true;
    _paletteGenerationError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.generatePersonalPalette(
        userId: userId,
        preferredColors: preferredColors,
        skinTone: skinTone,
        hairColor: hairColor,
        eyeColor: eyeColor,
      );
      
      if (result['success'] == true) {
        _personalPalette = List<Map<String, dynamic>>.from(result['personalPalette'] ?? []);
        _paletteGenerationError = null;
      } else {
        _paletteGenerationError = result['error'] ?? 'Failed to generate palette';
      }
    } catch (e) {
      _paletteGenerationError = 'Error: $e';
    } finally {
      _isGeneratingPalette = false;
      notifyListeners();
    }
  }
  
  Future<void> getPersonalPalette(String userId) async {
    try {
      final result = await _colorMatcherService.getPersonalPalette(userId);
      
      if (result['success'] == true) {
        _personalPalette = List<Map<String, dynamic>>.from(result['palettes'] ?? []);
      }
    } catch (e) {
      // Ошибка не критична для получения палитры
    }
  }
  
  // Методы для гармоничных цветов
  Future<void> findHarmoniousColors({
    required String baseColor,
    String? harmonyType,
    int count = 5,
  }) async {
    _isFindingHarmoniousColors = true;
    _harmoniousColorsError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.findHarmoniousColors(
        baseColor: baseColor,
        harmonyType: harmonyType ?? _selectedHarmonyType,
        count: count,
      );
      
      if (result['success'] == true) {
        _harmoniousColors = List<Map<String, dynamic>>.from(result['harmoniousColors'] ?? []);
        _harmoniousColorsError = null;
      } else {
        _harmoniousColorsError = result['error'] ?? 'Failed to find harmonious colors';
      }
    } catch (e) {
      _harmoniousColorsError = 'Error: $e';
    } finally {
      _isFindingHarmoniousColors = false;
      notifyListeners();
    }
  }
  
  // Методы для рекомендаций
  Future<void> getColorRecommendations({
    required String userId,
    String? occasion,
    String? season,
    List<String>? existingColors,
  }) async {
    _isLoadingRecommendations = true;
    _recommendationsError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.getColorRecommendations(
        userId: userId,
        occasion: occasion ?? _selectedOccasion,
        season: season ?? _selectedSeason,
        existingColors: existingColors,
      );
      
      if (result['success'] == true) {
        _colorRecommendations = List<Map<String, dynamic>>.from(result['recommendations'] ?? []);
        _recommendationsError = null;
      } else {
        _recommendationsError = result['error'] ?? 'Failed to get recommendations';
      }
    } catch (e) {
      _recommendationsError = 'Error: $e';
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }
  
  // Методы для трендов
  Future<void> analyzeColorTrends({
    String? category,
    String? season,
    int limit = 10,
  }) async {
    _isLoadingTrends = true;
    _trendsError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.analyzeColorTrends(
        category: category ?? _selectedCategory,
        season: season ?? _selectedSeason,
        limit: limit,
      );
      
      if (result['success'] == true) {
        _colorTrends = List<Map<String, dynamic>>.from(result['colorTrends'] ?? []);
        _trendsError = null;
      } else {
        _trendsError = result['error'] ?? 'Failed to analyze trends';
      }
    } catch (e) {
      _trendsError = 'Error: $e';
    } finally {
      _isLoadingTrends = false;
      notifyListeners();
    }
  }
  
  // Методы для сезонных палитр
  Future<void> getSeasonalPalettes({String? season}) async {
    _isLoadingSeasonalPalettes = true;
    _seasonalPalettesError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.getSeasonalPalettes(
        season: season ?? _selectedSeason,
      );
      
      if (result['success'] == true) {
        _seasonalPalettes = result;
        _seasonalPalettesError = null;
      } else {
        _seasonalPalettesError = result['error'] ?? 'Failed to get seasonal palettes';
      }
    } catch (e) {
      _seasonalPalettesError = 'Error: $e';
    } finally {
      _isLoadingSeasonalPalettes = false;
      notifyListeners();
    }
  }
  
  // Методы для пользовательских палитр
  Future<void> getUserPalettes(String userId) async {
    _isLoadingUserPalettes = true;
    _userPalettesError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.getUserPalettes(userId);
      
      if (result['success'] == true) {
        _userPalettes = List<Map<String, dynamic>>.from(result['palettes'] ?? []);
        _userPalettesError = null;
      } else {
        _userPalettesError = result['error'] ?? 'Failed to get user palettes';
      }
    } catch (e) {
      _userPalettesError = 'Error: $e';
    } finally {
      _isLoadingUserPalettes = false;
      notifyListeners();
    }
  }
  
  Future<void> saveColorPalette({
    required String userId,
    required String name,
    required List<String> colors,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final result = await _colorMatcherService.saveColorPalette(
        userId: userId,
        name: name,
        colors: colors,
        description: description,
        tags: tags,
      );
      
      if (result['success'] == true) {
        // Обновляем список палитр
        await getUserPalettes(userId);
      }
    } catch (e) {
      // Ошибка обрабатывается в UI
    }
  }
  
  Future<void> deleteColorPalette(String paletteId, String userId) async {
    try {
      final result = await _colorMatcherService.deleteColorPalette(paletteId);
      
      if (result['success'] == true) {
        // Обновляем список палитр
        await getUserPalettes(userId);
      }
    } catch (e) {
      // Ошибка обрабатывается в UI
    }
  }
  
  // Методы для истории
  Future<void> getUserColorHistory({
    required String userId,
    int limit = 20,
  }) async {
    _isLoadingHistory = true;
    _colorHistoryError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.getUserColorHistory(
        userId: userId,
        limit: limit,
      );
      
      if (result['success'] == true) {
        _colorHistory = List<Map<String, dynamic>>.from(result['history'] ?? []);
        _colorHistoryError = null;
      } else {
        _colorHistoryError = result['error'] ?? 'Failed to get history';
      }
    } catch (e) {
      _colorHistoryError = 'Error: $e';
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }
  
  // Методы для статистики
  Future<void> getUserColorStats(String userId) async {
    _isLoadingStats = true;
    _userStatsError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.getUserColorStats(userId);
      
      if (result['success'] == true) {
        _userColorStats = result['stats'];
        _userStatsError = null;
      } else {
        _userStatsError = result['error'] ?? 'Failed to get stats';
      }
    } catch (e) {
      _userStatsError = 'Error: $e';
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }
  
  // Методы для предпочтений
  Future<void> getUserPreferences(String userId) async {
    _isLoadingPreferences = true;
    _userPreferencesError = null;
    notifyListeners();
    
    try {
      final result = await _colorMatcherService.getUserPreferences(userId);
      
      if (result['success'] == true) {
        _userPreferences = result['preferences'];
        _userPreferencesError = null;
      } else {
        _userPreferencesError = result['error'] ?? 'Failed to get preferences';
      }
    } catch (e) {
      _userPreferencesError = 'Error: $e';
    } finally {
      _isLoadingPreferences = false;
      notifyListeners();
    }
  }
  
  Future<void> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final result = await _colorMatcherService.updateUserPreferences(
        userId: userId,
        preferences: preferences,
      );
      
      if (result['success'] == true) {
        // Обновляем локальные предпочтения
        _userPreferences = preferences;
        notifyListeners();
      }
    } catch (e) {
      // Ошибка обрабатывается в UI
    }
  }
  
  // Методы для управления фильтрами
  void setHarmonyType(String harmonyType) {
    _selectedHarmonyType = harmonyType;
    notifyListeners();
  }
  
  void setSeason(String season) {
    _selectedSeason = season;
    notifyListeners();
  }
  
  void setOccasion(String occasion) {
    _selectedOccasion = occasion;
    notifyListeners();
  }
  
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  // Методы для сброса состояния
  void clearPhotoAnalysis() {
    _photoAnalysis = null;
    _photoAnalysisError = null;
    notifyListeners();
  }
  
  void clearHarmoniousColors() {
    _harmoniousColors = null;
    _harmoniousColorsError = null;
    notifyListeners();
  }
  
  void clearRecommendations() {
    _colorRecommendations = null;
    _recommendationsError = null;
    notifyListeners();
  }
  
  void clearTrends() {
    _colorTrends = null;
    _trendsError = null;
    notifyListeners();
  }
  
  // Метод для загрузки всех данных пользователя
  Future<void> loadAllUserData(String userId) async {
    await Future.wait([
      getPersonalPalette(userId),
      getUserPalettes(userId),
      getUserColorHistory(userId: userId),
      getUserColorStats(userId),
      getUserPreferences(userId),
    ]);
  }
  
  // Метод для обновления всех данных
  Future<void> refreshAllData(String userId) async {
    await loadAllUserData(userId);
  }
  
  // Метод для очистки всех ошибок
  void clearAllErrors() {
    _photoAnalysisError = null;
    _paletteGenerationError = null;
    _harmoniousColorsError = null;
    _recommendationsError = null;
    _trendsError = null;
    _seasonalPalettesError = null;
    _userPalettesError = null;
    _colorHistoryError = null;
    _userStatsError = null;
    _userPreferencesError = null;
    notifyListeners();
  }
  
  // Метод для проверки наличия ошибок
  bool get hasErrors {
    return _photoAnalysisError != null ||
           _paletteGenerationError != null ||
           _harmoniousColorsError != null ||
           _recommendationsError != null ||
           _trendsError != null ||
           _seasonalPalettesError != null ||
           _userPalettesError != null ||
           _colorHistoryError != null ||
           _userStatsError != null ||
           _userPreferencesError != null;
  }
  
  // Метод для получения всех ошибок
  List<String> get allErrors {
    final errors = <String>[];
    if (_photoAnalysisError != null) errors.add(_photoAnalysisError!);
    if (_paletteGenerationError != null) errors.add(_paletteGenerationError!);
    if (_harmoniousColorsError != null) errors.add(_harmoniousColorsError!);
    if (_recommendationsError != null) errors.add(_recommendationsError!);
    if (_trendsError != null) errors.add(_trendsError!);
    if (_seasonalPalettesError != null) errors.add(_seasonalPalettesError!);
    if (_userPalettesError != null) errors.add(_userPalettesError!);
    if (_colorHistoryError != null) errors.add(_colorHistoryError!);
    if (_userStatsError != null) errors.add(_userStatsError!);
    if (_userPreferencesError != null) errors.add(_userPreferencesError!);
    return errors;
  }
}
