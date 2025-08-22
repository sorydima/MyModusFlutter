import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'api_service.dart';

class AvitoService {
  static const String _baseUrl = 'https://www.avito.ru';
  final ApiService _apiService = ApiService();

  /// Парсит URL товара с Avito и возвращает информацию о товаре
  Future<Product?> parseProductUrl(String avitoUrl) async {
    try {
      // Отправляем URL на backend для парсинга
      final response = await _apiService.post('/api/parse/avito', {
        'url': avitoUrl,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          throw Exception('Ошибка парсинга: ${data['error']}');
        }
        return Product.fromAvito(data);
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка парсинга Avito URL: $e');
      return null;
    }
  }

  /// Получает список товаров с Avito по категории
  Future<List<Product>> getProductsByCategory(String category, {int page = 1}) async {
    try {
      final response = await _apiService.get('/api/avito/category/$category?page=$page');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        return productsJson
            .map((json) => Product.fromAvito(json))
            .where((product) => product != null)
            .cast<Product>()
            .toList();
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения товаров Avito: $e');
      return [];
    }
  }

  /// Поиск товаров на Avito
  Future<List<Product>> searchProducts(String query, {
    String? location,
    int? minPrice,
    int? maxPrice,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{
        'q': query,
        'page': page.toString(),
      };

      if (location != null) params['location'] = location;
      if (minPrice != null) params['min_price'] = minPrice.toString();
      if (maxPrice != null) params['max_price'] = maxPrice.toString();

      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiService.get('/api/avito/search?$queryString');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        return productsJson
            .map((json) => Product.fromAvito(json))
            .where((product) => product != null)
            .cast<Product>()
            .toList();
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка поиска на Avito: $e');
      return [];
    }
  }

  /// Получает информацию о продавце на Avito
  Future<Map<String, dynamic>?> getSellerInfo(String sellerUrl) async {
    try {
      final response = await _apiService.post('/api/avito/seller', {
        'url': sellerUrl,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          throw Exception('Ошибка получения информации о продавце: ${data['error']}');
        }
        return data;
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения информации о продавце: $e');
      return null;
    }
  }

  /// Получает похожие товары на Avito
  Future<List<Product>> getSimilarProducts(String productId) async {
    try {
      final response = await _apiService.get('/api/avito/similar/$productId');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        return productsJson
            .map((json) => Product.fromAvito(json))
            .where((product) => product != null)
            .cast<Product>()
            .toList();
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения похожих товаров: $e');
      return [];
    }
  }

  /// Добавляет товар в избранное
  Future<bool> addToFavorites(String productId) async {
    try {
      final response = await _apiService.post('/api/avito/favorites', {
        'product_id': productId,
      });

      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка добавления в избранное: $e');
      return false;
    }
  }

  /// Удаляет товар из избранного
  Future<bool> removeFromFavorites(String productId) async {
    try {
      final response = await _apiService.delete('/api/avito/favorites/$productId');

      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка удаления из избранного: $e');
      return false;
    }
  }

  /// Получает список избранных товаров
  Future<List<Product>> getFavorites() async {
    try {
      final response = await _apiService.get('/api/avito/favorites');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        return productsJson
            .map((json) => Product.fromAvito(json))
            .where((product) => product != null)
            .cast<Product>()
            .toList();
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения избранного: $e');
      return [];
    }
  }

  /// Проверяет актуальность цены товара
  Future<Map<String, dynamic>?> checkPriceUpdate(String productUrl) async {
    try {
      final response = await _apiService.post('/api/avito/price-check', {
        'url': productUrl,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          throw Exception('Ошибка проверки цены: ${data['error']}');
        }
        return data;
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка проверки цены: $e');
      return null;
    }
  }

  /// Подписывается на уведомления о снижении цены
  Future<bool> subscribeToPriceAlerts(String productId, int targetPrice) async {
    try {
      final response = await _apiService.post('/api/avito/price-alerts', {
        'product_id': productId,
        'target_price': targetPrice,
      });

      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка подписки на уведомления: $e');
      return false;
    }
  }

  /// Получает статистику по категории
  Future<Map<String, dynamic>?> getCategoryStats(String category) async {
    try {
      final response = await _apiService.get('/api/avito/stats/$category');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения статистики: $e');
      return null;
    }
  }

  /// Валидирует URL Avito
  static bool isValidAvitoUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('avito.ru') && uri.path.contains('/');
    } catch (e) {
      return false;
    }
  }

  /// Извлекает ID товара из URL
  static String? extractProductId(String avitoUrl) {
    try {
      final uri = Uri.parse(avitoUrl);
      final pathSegments = uri.pathSegments;
      
      // Ищем сегмент, который содержит ID товара (обычно последний сегмент с цифрами)
      for (final segment in pathSegments.reversed) {
        if (segment.contains('_') && RegExp(r'\d+').hasMatch(segment)) {
          return segment;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Форматирует цену для отображения
  static String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ')} ₽';
  }

  /// Получает список популярных категорий Avito
  static List<Map<String, String>> getPopularCategories() {
    return [
      {'name': 'Одежда и обувь', 'code': 'odezhda_obuv_aksessuary'},
      {'name': 'Электроника', 'code': 'elektronika'},
      {'name': 'Дом и дача', 'code': 'dom_i_dacha'},
      {'name': 'Транспорт', 'code': 'transport'},
      {'name': 'Хобби и отдых', 'code': 'hobbi_i_otdyh'},
      {'name': 'Для бизнеса', 'code': 'dlya_biznesa'},
      {'name': 'Недвижимость', 'code': 'nedvizhimost'},
      {'name': 'Работа', 'code': 'rabota'},
      {'name': 'Услуги', 'code': 'uslugi'},
    ];
  }
}
