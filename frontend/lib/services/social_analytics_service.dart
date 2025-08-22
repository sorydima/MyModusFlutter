import 'dart:convert';
import 'package:http/http.dart' as http;

class SocialAnalyticsService {
  static const String baseUrl = 'http://localhost:8080/api/social-analytics';
  
  /// Получить тренды по категориям
  Future<Map<String, dynamic>> getCategoryTrends({
    String period = 'month',
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trends?period=$period&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get category trends: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting category trends: $e');
    }
  }

  /// Получить социальные метрики продукта
  Future<Map<String, dynamic>> getSocialMetrics({
    required String productId,
    String? period,
  }) async {
    try {
      final uri = period != null 
          ? Uri.parse('$baseUrl/social-metrics/$productId?period=$period')
          : Uri.parse('$baseUrl/social-metrics/$productId');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get social metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting social metrics: $e');
    }
  }

  /// Получить анализ аудитории
  Future<Map<String, dynamic>> getAudienceAnalysis({
    required String category,
    String? period,
  }) async {
    try {
      final uri = period != null 
          ? Uri.parse('$baseUrl/audience/$category?period=$period')
          : Uri.parse('$baseUrl/audience/$category');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get audience analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting audience analysis: $e');
    }
  }

  /// Получить прогнозы трендов
  Future<Map<String, dynamic>> getTrendPredictions({
    required String category,
    int daysAhead = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/predictions/$category?daysAhead=$daysAhead'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get trend predictions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting trend predictions: $e');
    }
  }

  /// Получить анализ конкурентов
  Future<Map<String, dynamic>> getCompetitorAnalysis({
    required String category,
    int limit = 5,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitors/$category?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get competitor analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting competitor analysis: $e');
    }
  }

  /// Сгенерировать отчет
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reportType': reportType,
          'parameters': parameters,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating report: $e');
    }
  }

  /// Получить доступные типы отчетов
  Future<Map<String, dynamic>> getReportTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/report-types'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get report types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting report types: $e');
    }
  }

  /// Получить статистику по периодам
  Future<Map<String, dynamic>> getPeriodStats(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/$period'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get period stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting period stats: $e');
    }
  }

  /// Экспортировать данные аналитики
  Future<String> exportAnalyticsData({
    required String dataType,
    String format = 'json',
    String period = 'month',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/export/$dataType?format=$format&period=$period'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to export analytics data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting analytics data: $e');
    }
  }

  /// Получить топ продуктов по категории
  Future<Map<String, dynamic>> getTopProducts({
    required String category,
    int limit = 10,
    String sortBy = 'sales',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/top-products/$category?limit=$limit&sortBy=$sortBy'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get top products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting top products: $e');
    }
  }

  /// Получить анализ сезонности
  Future<Map<String, dynamic>> getSeasonalityAnalysis(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/seasonality/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get seasonality analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting seasonality analysis: $e');
    }
  }

  /// Сравнить периоды
  Future<Map<String, dynamic>> comparePeriods({
    required String period1,
    required String period2,
    List<String>? metrics,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/compare-periods'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'period1': period1,
          'period2': period2,
          'metrics': metrics ?? ['sales', 'views', 'rating'],
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to compare periods: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error comparing periods: $e');
    }
  }

  // Utility methods

  /// Форматировать процент изменения
  String formatPercentageChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${(change * 100).toStringAsFixed(1)}%';
  }

  /// Форматировать тренд
  String formatTrend(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return '📈 Растет';
      case 'falling':
        return '📉 Падает';
      case 'stable':
        return '➡️ Стабильно';
      case 'up':
        return '📈 Вверх';
      case 'down':
        return '📉 Вниз';
      default:
        return '➡️ $trend';
    }
  }

  /// Получить цвет для тренда
  int getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
      case 'up':
        return 0xFF4CAF50; // Зеленый
      case 'falling':
      case 'down':
        return 0xFFF44336; // Красный
      case 'stable':
        return 0xFF2196F3; // Синий
      default:
        return 0xFF9E9E9E; // Серый
    }
  }

  /// Форматировать количество
  String formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  /// Форматировать рейтинг
  String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  /// Получить иконку для категории
  String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
      case 'электроника':
        return '📱';
      case 'fashion':
      case 'мода':
      case 'одежда':
        return '👗';
      case 'home':
      case 'дом':
      case 'быт':
        return '🏠';
      case 'sports':
      case 'спорт':
        return '⚽';
      case 'beauty':
      case 'красота':
        return '💄';
      case 'books':
      case 'книги':
        return '📚';
      case 'food':
      case 'еда':
        return '🍕';
      case 'automotive':
      case 'авто':
        return '🚗';
      default:
        return '📦';
    }
  }

  /// Получить доступные периоды
  List<Map<String, dynamic>> getAvailablePeriods() {
    return [
      {'value': 'day', 'label': 'День', 'icon': '📅'},
      {'value': 'week', 'label': 'Неделя', 'icon': '📆'},
      {'value': 'month', 'label': 'Месяц', 'icon': '🗓️'},
      {'value': 'year', 'label': 'Год', 'icon': '📊'},
    ];
  }

  /// Получить доступные метрики для сравнения
  List<Map<String, dynamic>> getAvailableMetrics() {
    return [
      {'value': 'sales', 'label': 'Продажи', 'icon': '💰'},
      {'value': 'views', 'label': 'Просмотры', 'icon': '👁️'},
      {'value': 'rating', 'label': 'Рейтинг', 'icon': '⭐'},
      {'value': 'revenue', 'label': 'Доход', 'icon': '💵'},
      {'value': 'orders', 'label': 'Заказы', 'icon': '📦'},
    ];
  }
}
