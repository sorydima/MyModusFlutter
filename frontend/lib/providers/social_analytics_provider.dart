import 'package:flutter/foundation.dart';
import '../services/social_analytics_service.dart';

class SocialAnalyticsProvider extends ChangeNotifier {
  final SocialAnalyticsService _analyticsService = SocialAnalyticsService();
  
  // State variables
  Map<String, dynamic>? _categoryTrends;
  Map<String, dynamic>? _socialMetrics;
  Map<String, dynamic>? _audienceAnalysis;
  Map<String, dynamic>? _trendPredictions;
  Map<String, dynamic>? _competitorAnalysis;
  Map<String, dynamic>? _periodStats;
  List<Map<String, dynamic>> _topProducts = [];
  Map<String, dynamic>? _seasonalityAnalysis;
  Map<String, dynamic>? _periodComparison;
  List<Map<String, dynamic>> _reportTypes = [];
  Map<String, dynamic>? _generatedReport;
  
  bool _isLoading = false;
  String? _error;
  String _selectedPeriod = 'month';
  String _selectedCategory = 'all';
  
  // Getters
  Map<String, dynamic>? get categoryTrends => _categoryTrends;
  Map<String, dynamic>? get socialMetrics => _socialMetrics;
  Map<String, dynamic>? get audienceAnalysis => _audienceAnalysis;
  Map<String, dynamic>? get trendPredictions => _trendPredictions;
  Map<String, dynamic>? get competitorAnalysis => _competitorAnalysis;
  Map<String, dynamic>? get periodStats => _periodStats;
  List<Map<String, dynamic>> get topProducts => _topProducts;
  Map<String, dynamic>? get seasonalityAnalysis => _seasonalityAnalysis;
  Map<String, dynamic>? get periodComparison => _periodComparison;
  List<Map<String, dynamic>> get reportTypes => _reportTypes;
  Map<String, dynamic>? get generatedReport => _generatedReport;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedPeriod => _selectedPeriod;
  String get selectedCategory => _selectedCategory;
  
  /// Получить тренды по категориям
  Future<void> getCategoryTrends({
    String? period,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final trends = await _analyticsService.getCategoryTrends(
        period: period ?? _selectedPeriod,
        limit: limit,
      );
      
      _categoryTrends = trends;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get category trends: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить социальные метрики продукта
  Future<void> getSocialMetrics({
    required String productId,
    String? period,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final metrics = await _analyticsService.getSocialMetrics(
        productId: productId,
        period: period,
      );
      
      _socialMetrics = metrics;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get social metrics: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить анализ аудитории
  Future<void> getAudienceAnalysis({
    String? category,
    String? period,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final analysis = await _analyticsService.getAudienceAnalysis(
        category: category ?? _selectedCategory,
        period: period,
      );
      
      _audienceAnalysis = analysis;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get audience analysis: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить прогнозы трендов
  Future<void> getTrendPredictions({
    String? category,
    int daysAhead = 30,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final predictions = await _analyticsService.getTrendPredictions(
        category: category ?? _selectedCategory,
        daysAhead: daysAhead,
      );
      
      _trendPredictions = predictions;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get trend predictions: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить анализ конкурентов
  Future<void> getCompetitorAnalysis({
    String? category,
    int limit = 5,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final analysis = await _analyticsService.getCompetitorAnalysis(
        category: category ?? _selectedCategory,
        limit: limit,
      );
      
      _competitorAnalysis = analysis;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get competitor analysis: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить статистику по периодам
  Future<void> getPeriodStats(String period) async {
    try {
      _setLoading(true);
      _clearError();
      
      final stats = await _analyticsService.getPeriodStats(period);
      
      _periodStats = stats;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get period stats: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить топ продуктов по категории
  Future<void> getTopProducts({
    String? category,
    int limit = 10,
    String sortBy = 'sales',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _analyticsService.getTopProducts(
        category: category ?? _selectedCategory,
        limit: limit,
        sortBy: sortBy,
      );
      
      _topProducts = List<Map<String, dynamic>>.from(result['products'] ?? []);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get top products: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить анализ сезонности
  Future<void> getSeasonalityAnalysis(String category) async {
    try {
      _setLoading(true);
      _clearError();
      
      final analysis = await _analyticsService.getSeasonalityAnalysis(category);
      
      _seasonalityAnalysis = analysis;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get seasonality analysis: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Сравнить периоды
  Future<void> comparePeriods({
    required String period1,
    required String period2,
    List<String>? metrics,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final comparison = await _analyticsService.comparePeriods(
        period1: period1,
        period2: period2,
        metrics: metrics,
      );
      
      _periodComparison = comparison;
      notifyListeners();
    } catch (e) {
      _setError('Failed to compare periods: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить доступные типы отчетов
  Future<void> getReportTypes() async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _analyticsService.getReportTypes();
      
      _reportTypes = List<Map<String, dynamic>>.from(result['reportTypes'] ?? []);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get report types: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Сгенерировать отчет
  Future<void> generateReport({
    required String reportType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final report = await _analyticsService.generateReport(
        reportType: reportType,
        parameters: parameters,
      );
      
      _generatedReport = report;
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate report: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Экспортировать данные аналитики
  Future<String> exportAnalyticsData({
    required String dataType,
    String format = 'json',
    String? period,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final exportData = await _analyticsService.exportAnalyticsData(
        dataType: dataType,
        format: format,
        period: period ?? _selectedPeriod,
      );
      
      return exportData;
    } catch (e) {
      _setError('Failed to export analytics data: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Установить выбранный период
  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }
  
  /// Установить выбранную категорию
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  /// Загрузить все данные для категории
  Future<void> loadAllCategoryData(String category) async {
    try {
      _setLoading(true);
      _clearError();
      
      await Future.wait([
        getCategoryTrends(period: _selectedPeriod),
        getAudienceAnalysis(category: category),
        getTrendPredictions(category: category),
        getCompetitorAnalysis(category: category),
        getTopProducts(category: category),
        getSeasonalityAnalysis(category),
      ]);
    } catch (e) {
      _setError('Failed to load category data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Загрузить все данные для периода
  Future<void> loadAllPeriodData(String period) async {
    try {
      _setLoading(true);
      _clearError();
      
      await Future.wait([
        getCategoryTrends(period: period),
        getPeriodStats(period),
      ]);
    } catch (e) {
      _setError('Failed to load period data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Загрузить все данные аналитики
  Future<void> loadAllAnalyticsData() async {
    try {
      _setLoading(true);
      _clearError();
      
      await Future.wait([
        getCategoryTrends(),
        getReportTypes(),
        getPeriodStats(_selectedPeriod),
      ]);
    } catch (e) {
      _setError('Failed to load analytics data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Очистить все данные
  void clearData() {
    _categoryTrends = null;
    _socialMetrics = null;
    _audienceAnalysis = null;
    _trendPredictions = null;
    _competitorAnalysis = null;
    _periodStats = null;
    _topProducts.clear();
    _seasonalityAnalysis = null;
    _periodComparison = null;
    _generatedReport = null;
    _clearError();
    notifyListeners();
  }
  
  /// Очистить ошибки
  void clearErrors() {
    _clearError();
    notifyListeners();
  }
  
  // Utility methods
  
  /// Получить цвет для тренда
  int getTrendColor(String trend) {
    return _analyticsService.getTrendColor(trend);
  }
  
  /// Форматировать тренд
  String formatTrend(String trend) {
    return _analyticsService.formatTrend(trend);
  }
  
  /// Форматировать процент изменения
  String formatPercentageChange(double change) {
    return _analyticsService.formatPercentageChange(change);
  }
  
  /// Форматировать количество
  String formatNumber(num number) {
    return _analyticsService.formatNumber(number);
  }
  
  /// Форматировать рейтинг
  String formatRating(double rating) {
    return _analyticsService.formatRating(rating);
  }
  
  /// Получить иконку для категории
  String getCategoryIcon(String category) {
    return _analyticsService.getCategoryIcon(category);
  }
  
  /// Получить доступные периоды
  List<Map<String, dynamic>> getAvailablePeriods() {
    return _analyticsService.getAvailablePeriods();
  }
  
  /// Получить доступные метрики для сравнения
  List<Map<String, dynamic>> getAvailableMetrics() {
    return _analyticsService.getAvailableMetrics();
  }
  
  // Private methods
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
}
