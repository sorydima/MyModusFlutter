import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../models/product_model.dart';

class WildberriesParserService {
  static const String _baseUrl = 'https://www.wildberries.ru';
  static const String _brandUrl = 'https://www.wildberries.ru/brands/311036101-my-modus';
  
  // Заголовки для имитации браузера
  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
  };

  /// Получает информацию о бренде My Modus
  Future<Map<String, dynamic>> getBrandInfo() async {
    try {
      final response = await http.get(
        Uri.parse(_brandUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        
        // Извлекаем название бренда
        final brandNameElement = document.querySelector('.brand-page__title');
        final brandName = brandNameElement?.text?.trim() ?? 'My Modus';
        
        // Извлекаем описание бренда
        final brandDescriptionElement = document.querySelector('.brand-page__description');
        final brandDescription = brandDescriptionElement?.text?.trim() ?? 'Бренд модной одежды и аксессуаров';
        
        // Извлекаем количество товаров
        final productsCountElement = document.querySelector('.brand-page__products-count');
        final productsCount = productsCountElement?.text?.trim() ?? '0';
        
        return {
          'name': brandName,
          'description': brandDescription,
          'productsCount': productsCount,
          'url': _brandUrl,
        };
      } else {
        throw Exception('Failed to load brand info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error parsing brand info: $e');
      // Возвращаем fallback данные
      return {
        'name': 'My Modus',
        'description': 'Бренд модной одежды и аксессуаров',
        'productsCount': '150+',
        'url': _brandUrl,
      };
    }
  }

  /// Получает товары бренда My Modus
  Future<List<ProductModel>> getBrandProducts({int limit = 50}) async {
    try {
      // Пытаемся получить данные через API Wildberries
      final apiUrl = 'https://catalog.wb.ru/brands/catalog?TestGroup=no_test&TestID=no_test&appType=1&brand=311036101&cat=8126&curr=rub&dest=-1257786&sort=popular&spp=0';
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['data']['products'] as List;
        
        return products.take(limit).map((product) {
          return ProductModel(
            id: product['id'].toString(),
            title: product['name'] ?? 'Название не указано',
            description: product['description'] ?? 'Описание не указано',
            price: (product['salePriceU'] ?? product['priceU'] ?? 0) / 100.0,
            oldPrice: product['priceU'] != null ? (product['priceU'] / 100.0) : null,
            imageUrl: _getProductImageUrl(product['id']),
            brand: 'My Modus',
            category: _getCategoryFromProduct(product),
            rating: (product['rating'] ?? 0.0).toDouble(),
            reviewCount: product['feedbacks'] ?? 0,
            inStock: product['sizes']?.isNotEmpty ?? false,
            isNew: product['isNew'] ?? false,
            isSale: product['salePriceU'] != null && product['salePriceU'] < product['priceU'],
            status: _getProductStatus(product),
            statusColor: _getStatusColor(product),
            specifications: _getSpecifications(product),
            images: [_getProductImageUrl(product['id'])],
            sizes: _getSizes(product),
            colors: _getColors(product),
            tags: _getTags(product),
            weight: product['weight']?.toDouble(),
            dimensions: _getDimensions(product),
            material: product['material'] ?? 'Не указано',
            country: product['country'] ?? 'Не указано',
            warranty: product['warranty'] ?? 'Не указано',
            deliveryTime: '1-3 дня',
            freeShipping: product['freeShipping'] ?? false,
            returnPolicy: '14 дней',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            viewCount: product['viewCount'] ?? 0,
            likeCount: product['likeCount'] ?? 0,
            inCart: false,
            cartQuantity: 0,
          );
        }).toList();
      } else {
        // Если API не работает, используем fallback данные
        return _getFallbackProducts(limit);
      }
    } catch (e) {
      print('Error parsing brand products: $e');
      return _getFallbackProducts(limit);
    }
  }

  /// Поиск товаров по запросу
  Future<List<ProductModel>> searchProducts(String query, {int limit = 50}) async {
    try {
      final searchUrl = 'https://catalog.wb.ru/catalog/search?TestGroup=no_test&TestID=no_test&appType=1&cat=8126&curr=rub&dest=-1257786&query=${Uri.encodeComponent(query)}&sort=popular&spp=0';
      
      final response = await http.get(
        Uri.parse(searchUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['data']['products'] as List;
        
        return products.take(limit).map((product) {
          return ProductModel(
            id: product['id'].toString(),
            title: product['name'] ?? 'Название не указано',
            description: product['description'] ?? 'Описание не указано',
            price: (product['salePriceU'] ?? product['priceU'] ?? 0) / 100.0,
            oldPrice: product['priceU'] != null ? (product['priceU'] / 100.0) : null,
            imageUrl: _getProductImageUrl(product['id']),
            brand: product['brand'] ?? 'Бренд не указан',
            category: _getCategoryFromProduct(product),
            rating: (product['rating'] ?? 0.0).toDouble(),
            reviewCount: product['feedbacks'] ?? 0,
            inStock: product['sizes']?.isNotEmpty ?? false,
            isNew: product['isNew'] ?? false,
            isSale: product['salePriceU'] != null && product['salePriceU'] < product['priceU'],
            status: _getProductStatus(product),
            statusColor: _getStatusColor(product),
            specifications: _getSpecifications(product),
            images: [_getProductImageUrl(product['id'])],
            sizes: _getSizes(product),
            colors: _getColors(product),
            tags: _getTags(product),
            weight: product['weight']?.toDouble(),
            dimensions: _getDimensions(product),
            material: product['material'] ?? 'Не указано',
            country: product['country'] ?? 'Не указано',
            warranty: product['warranty'] ?? 'Не указано',
            deliveryTime: '1-3 дня',
            freeShipping: product['freeShipping'] ?? false,
            returnPolicy: '14 дней',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            viewCount: product['viewCount'] ?? 0,
            likeCount: product['likeCount'] ?? 0,
            inCart: false,
            cartQuantity: 0,
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Получает категории товаров
  Future<List<String>> getCategories() async {
    try {
      final categoriesUrl = 'https://catalog.wb.ru/catalog/men/catalog?TestGroup=no_test&TestID=no_test&appType=1&cat=8126&curr=rub&dest=-1257786&sort=popular&spp=0';
      
      final response = await http.get(
        Uri.parse(categoriesUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = data['data']['categories'] as List;
        
        return categories.map((category) => category['name'] ?? '').where((name) => name.isNotEmpty).cast<String>().toList();
      } else {
        return _getFallbackCategories();
      }
    } catch (e) {
      print('Error getting categories: $e');
      return _getFallbackCategories();
    }
  }

  /// Получает популярные бренды
  Future<List<String>> getPopularBrands() async {
    try {
      final brandsUrl = 'https://catalog.wb.ru/catalog/men/catalog?TestGroup=no_test&TestID=no_test&appType=1&cat=8126&curr=rub&dest=-1257786&sort=popular&spp=0';
      
      final response = await http.get(
        Uri.parse(brandsUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final brands = data['data']['brands'] as List;
        
        return brands.map((brand) => brand['name'] ?? '').where((name) => name.isNotEmpty).cast<String>().toList();
      } else {
        return _getFallbackBrands();
      }
    } catch (e) {
      print('Error getting popular brands: $e');
      return _getFallbackBrands();
    }
  }

  // Вспомогательные методы

  String _getProductImageUrl(int productId) {
    // Формируем URL изображения товара Wildberries
    final id = productId.toString();
    if (id.length >= 3) {
      final firstPart = id.substring(0, id.length - 3);
      final secondPart = id.substring(id.length - 3);
      return 'https://images.wbstatic.net/c246x328/new/$firstPart$secondPart-1.jpg';
    }
    return 'https://via.placeholder.com/300x400?text=No+Image';
  }

  String _getCategoryFromProduct(Map<String, dynamic> product) {
    final categories = product['categories'] as List?;
    if (categories != null && categories.isNotEmpty) {
      return categories.first['name'] ?? 'Одежда';
    }
    return 'Одежда';
  }

  String _getProductStatus(Map<String, dynamic> product) {
    if (product['isNew'] == true) return 'Новинка';
    if (product['salePriceU'] != null && product['salePriceU'] < product['priceU']) return 'Скидка';
    if (!(product['sizes']?.isNotEmpty ?? false)) return 'Нет в наличии';
    return 'В наличии';
  }

  int _getStatusColor(Map<String, dynamic> product) {
    if (product['isNew'] == true) return 0xFF4CAF50; // Зеленый
    if (product['salePriceU'] != null && product['salePriceU'] < product['priceU']) return 0xFFF44336; // Красный
    if (!(product['sizes']?.isNotEmpty ?? false)) return 0xFF9E9E9E; // Серый
    return 0xFF2196F3; // Синий
  }

  Map<String, String> _getSpecifications(Map<String, dynamic> product) {
    final specs = <String, String>{};
    
    if (product['material'] != null) specs['Материал'] = product['material'];
    if (product['country'] != null) specs['Страна'] = product['country'];
    if (product['weight'] != null) specs['Вес'] = '${product['weight']} г';
    if (product['warranty'] != null) specs['Гарантия'] = product['warranty'];
    
    return specs;
  }

  List<String> _getSizes(Map<String, dynamic> product) {
    final sizes = product['sizes'] as List?;
    if (sizes != null) {
      return sizes.map((size) => size['name'] ?? '').where((name) => name.isNotEmpty).cast<String>().toList();
    }
    return <String>['S', 'M', 'L', 'XL'];
  }

  List<String> _getColors(Map<String, dynamic> product) {
    final colors = product['colors'] as List?;
    if (colors != null) {
      return colors.map((color) => color['name'] ?? '').where((name) => name.isNotEmpty).cast<String>().toList();
    }
    return <String>['Черный', 'Белый', 'Синий'];
  }

  List<String> _getTags(Map<String, dynamic> product) {
    final tags = <String>[];
    
    if (product['isNew'] == true) tags.add('Новинка');
    if (product['salePriceU'] != null && product['salePriceU'] < product['priceU']) tags.add('Скидка');
    if (product['freeShipping'] == true) tags.add('Бесплатная доставка');
    
    return tags;
  }

  String _getDimensions(Map<String, dynamic> product) {
    return 'Длина: Не указано, Ширина: Не указано, Высота: Не указано';
  }

  // Fallback данные - улучшенные товары My Modus

  List<ProductModel> _getFallbackProducts(int limit) {
    final products = <ProductModel>[];
    
    // Одежда
    products.addAll([
      ProductModel(
        id: 'mymodus_001',
        title: 'Футболка My Modus Premium',
        description: 'Премиальная футболка из 100% хлопка с логотипом бренда. Идеально подходит для повседневной носки.',
        price: 2500.0,
        oldPrice: 3200.0,
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=400&fit=crop',
        brand: 'My Modus',
        category: 'Одежда',
        rating: 4.8,
        reviewCount: 156,
        inStock: true,
        isNew: true,
        isSale: true,
        status: 'Скидка',
        statusColor: 0xFFF44336,
        specifications: {'Материал': '100% хлопок', 'Страна': 'Россия', 'Вес': '180 г', 'Гарантия': '30 дней'},
        images: <String>['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=400&fit=crop'],
        sizes: <String>['S', 'M', 'L', 'XL', 'XXL'],
        colors: <String>['Белый', 'Черный', 'Синий', 'Красный'],
        tags: <String>['Новинка', 'Скидка', 'Премиум', 'Хлопок'],
        weight: 180.0,
        dimensions: 'Длина: 70 см, Ширина: 50 см, Высота: 2 см',
        material: '100% хлопок',
        country: 'Россия',
        warranty: '30 дней',
        deliveryTime: '1-3 дня',
        freeShipping: true,
        returnPolicy: '14 дней',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        viewCount: 1250,
        likeCount: 89,
        inCart: false,
        cartQuantity: 0,
      ),
      ProductModel(
        id: 'mymodus_002',
        title: 'Джинсы My Modus Classic',
        description: 'Классические джинсы прямого кроя из качественного денима. Универсальная модель для любого случая.',
        price: 4500.0,
        oldPrice: 5800.0,
        imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=300&h=400&fit=crop',
        brand: 'My Modus',
        category: 'Одежда',
        rating: 4.6,
        reviewCount: 234,
        inStock: true,
        isNew: false,
        isSale: true,
        status: 'Скидка',
        statusColor: 0xFFF44336,
        specifications: {'Материал': 'Деним', 'Страна': 'Россия', 'Вес': '450 г', 'Гарантия': '30 дней'},
        images: <String>['https://images.unsplash.com/photo-1542272604-787c3835535d?w=300&h=400&fit=crop'],
        sizes: <String>['28', '30', '32', '34', '36', '38'],
        colors: <String>['Синий', 'Черный', 'Серый'],
        tags: <String>['Скидка', 'Классика', 'Деним', 'Универсально'],
        weight: 450.0,
        dimensions: 'Длина: 105 см, Ширина: 35 см, Высота: 3 см',
        material: 'Деним',
        country: 'Россия',
        warranty: '30 дней',
        deliveryTime: '1-3 дня',
        freeShipping: true,
        returnPolicy: '14 дней',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        viewCount: 2100,
        likeCount: 156,
        inCart: false,
        cartQuantity: 0,
      ),
      ProductModel(
        id: 'mymodus_003',
        title: 'Куртка My Modus Urban',
        description: 'Стильная куртка для городской жизни. Защищает от ветра и дождя, при этом выглядит современно.',
        price: 8900.0,
        oldPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=300&h=400&fit=crop',
        brand: 'My Modus',
        category: 'Одежда',
        rating: 4.9,
        reviewCount: 89,
        inStock: true,
        isNew: true,
        isSale: false,
        status: 'Новинка',
        statusColor: 0xFF4CAF50,
        specifications: {'Материал': 'Полиэстер + хлопок', 'Страна': 'Россия', 'Вес': '650 г', 'Гарантия': '30 дней'},
        images: <String>['https://images.unsplash.com/photo-1551028719-00167b16eac5?w=300&h=400&fit=crop'],
        sizes: <String>['S', 'M', 'L', 'XL'],
        colors: <String>['Черный', 'Синий', 'Зеленый'],
        tags: <String>['Новинка', 'Городской стиль', 'Защита от дождя'],
        weight: 650.0,
        dimensions: 'Длина: 75 см, Ширина: 55 см, Высота: 4 см',
        material: 'Полиэстер + хлопок',
        country: 'Россия',
        warranty: '30 дней',
        deliveryTime: '1-3 дня',
        freeShipping: true,
        returnPolicy: '14 дней',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
        viewCount: 890,
        likeCount: 67,
        inCart: false,
        cartQuantity: 0,
      ),
    ]);

    // Обувь
    products.addAll([
      ProductModel(
        id: 'mymodus_004',
        title: 'Кроссовки My Modus Sport',
        description: 'Легкие и удобные кроссовки для спорта и повседневной носки. Амортизирующая подошва.',
        price: 6500.0,
        oldPrice: 7800.0,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=400&fit=crop',
        brand: 'My Modus',
        category: 'Обувь',
        rating: 4.7,
        reviewCount: 312,
        inStock: true,
        isNew: false,
        isSale: true,
        status: 'Скидка',
        statusColor: 0xFFF44336,
        specifications: {'Материал': 'Текстиль + резина', 'Страна': 'Россия', 'Вес': '320 г', 'Гарантия': '30 дней'},
        images: <String>['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=400&fit=crop'],
        sizes: <String>['36', '37', '38', '39', '40', '41', '42', '43', '44', '45'],
        colors: <String>['Белый', 'Черный', 'Серый'],
        tags: <String>['Скидка', 'Спорт', 'Комфорт', 'Амортизация'],
        weight: 320.0,
        dimensions: 'Длина: 28 см, Ширина: 10 см, Высота: 12 см',
        material: 'Текстиль + резина',
        country: 'Россия',
        warranty: '30 дней',
        deliveryTime: '1-3 дня',
        freeShipping: true,
        returnPolicy: '14 дней',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        viewCount: 3400,
        likeCount: 234,
        inCart: false,
        cartQuantity: 0,
      ),
      ProductModel(
        id: 'mymodus_005',
        title: 'Ботинки My Modus Classic',
        description: 'Классические ботинки из натуральной кожи. Идеально подходят для делового стиля.',
        price: 12000.0,
        oldPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300&h=400&fit=crop',
        brand: 'My Modus',
        category: 'Обувь',
        rating: 4.8,
        reviewCount: 178,
        inStock: true,
        isNew: false,
        isSale: false,
        status: 'В наличии',
        statusColor: 0xFF2196F3,
        specifications: {'Материал': 'Натуральная кожа', 'Страна': 'Россия', 'Вес': '450 г', 'Гарантия': '30 дней'},
        images: <String>['https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300&h=400&fit=crop'],
        sizes: <String>['39', '40', '41', '42', '43', '44', '45'],
        colors: <String>['Черный', 'Коричневый'],
        tags: <String>['Классика', 'Кожа', 'Деловой стиль', 'Качество'],
        weight: 450.0,
        dimensions: 'Длина: 30 см, Ширина: 11 см, Высота: 15 см',
        material: 'Натуральная кожа',
        country: 'Россия',
        warranty: '30 дней',
        deliveryTime: '1-3 дня',
        freeShipping: true,
        returnPolicy: '14 дней',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
        viewCount: 2800,
        likeCount: 189,
        inCart: false,
        cartQuantity: 0,
      ),
    ]);

    // Аксессуары
    products.addAll([
      ProductModel(
        id: 'mymodus_006',
        title: 'Рюкзак My Modus Urban',
        description: 'Стильный городской рюкзак с множеством карманов. Идеально подходит для работы и учебы.',
        price: 3500.0,
        oldPrice: 4200.0,
        imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&h=400&fit=crop',
        brand: 'My Modus',
        category: 'Аксессуары',
        rating: 4.6,
        reviewCount: 95,
        inStock: true,
        isNew: false,
        isSale: true,
        status: 'Скидка',
        statusColor: 0xFFF44336,
        specifications: {'Материал': 'Полиэстер', 'Страна': 'Россия', 'Вес': '800 г', 'Гарантия': '30 дней'},
        images: <String>['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&h=400&fit=crop'],
        sizes: <String>['Универсальный'],
        colors: <String>['Черный', 'Серый', 'Синий'],
        tags: <String>['Скидка', 'Городской стиль', 'Практичность'],
        weight: 800.0,
        dimensions: 'Длина: 45 см, Ширина: 30 см, Высота: 15 см',
        material: 'Полиэстер',
        country: 'Россия',
        warranty: '30 дней',
        deliveryTime: '1-3 дня',
        freeShipping: true,
        returnPolicy: '14 дней',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
        viewCount: 1600,
        likeCount: 112,
        inCart: false,
        cartQuantity: 0,
      ),
      ProductModel(
        id: 'mymodus_007',
        title: 'Часы My Modus Premium',
        description: 'Элегантные наручные часы с японским механизмом. Премиальное качество по доступной цене.',
        price: 8900.0,
        oldPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=300&h=400&fit=crop',
        brand: 'My Modus',
        category: 'Аксессуары',
        rating: 4.9,
        reviewCount: 67,
        inStock: true,
        isNew: true,
        isSale: false,
        status: 'Новинка',
        statusColor: 0xFF4CAF50,
        specifications: {'Материал': 'Нержавеющая сталь', 'Страна': 'Россия', 'Вес': '120 г', 'Гарантия': '2 года'},
        images: <String>['https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=300&h=400&fit=crop'],
        sizes: <String>['Универсальный'],
        colors: <String>['Серебристый', 'Золотистый', 'Черный'],
        tags: <String>['Новинка', 'Премиум', 'Японский механизм', 'Элегантность'],
        weight: 120.0,
        dimensions: 'Диаметр: 42 мм, Толщина: 12 мм',
        material: 'Нержавеющая сталь',
        country: 'Россия',
        warranty: '2 года',
        deliveryTime: '1-3 дня',
        freeShipping: true,
        returnPolicy: '14 дней',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        viewCount: 450,
        likeCount: 34,
        inCart: false,
        cartQuantity: 0,
      ),
    ]);

    // Добавляем дополнительные товары для достижения лимита
    if (products.length < limit) {
      final additionalCount = limit - products.length;
      for (int i = 0; i < additionalCount; i++) {
        final index = products.length + i;
        products.add(ProductModel(
          id: 'mymodus_${(index + 1).toString().padLeft(3, '0')}',
          title: 'Товар My Modus ${index + 1}',
          description: 'Описание товара My Modus ${index + 1} - качественная продукция от российского бренда.',
          price: 1500.0 + (i * 200),
          oldPrice: 1800.0 + (i * 200),
          imageUrl: 'https://images.unsplash.com/photo-${1500000000 + i}?w=300&h=400&fit=crop',
          brand: 'My Modus',
          category: i % 3 == 0 ? 'Одежда' : i % 3 == 1 ? 'Обувь' : 'Аксессуары',
          rating: 4.0 + (i % 5) * 0.2,
          reviewCount: 20 + (i * 10),
          inStock: true,
          isNew: i < 10,
          isSale: i % 4 == 0,
          status: i < 10 ? 'Новинка' : i % 4 == 0 ? 'Скидка' : 'В наличии',
          statusColor: i < 10 ? 0xFF4CAF50 : i % 4 == 0 ? 0xFFF44336 : 0xFF2196F3,
          specifications: {'Материал': 'Качественные материалы', 'Страна': 'Россия', 'Вес': '${200 + i * 50} г', 'Гарантия': '30 дней'},
          images: <String>['https://images.unsplash.com/photo-${1500000000 + i}?w=300&h=400&fit=crop'],
          sizes: <String>['S', 'M', 'L', 'XL'],
          colors: <String>['Черный', 'Белый', 'Синий'],
          tags: <String>['Качество', 'Стиль', 'Российский бренд'],
          weight: 200.0 + (i * 50),
          dimensions: 'Длина: ${70 + i * 5} см, Ширина: ${50 + i * 3} см, Высота: ${5 + i} см',
          material: 'Качественные материалы',
          country: 'Россия',
          warranty: '30 дней',
          deliveryTime: '1-3 дня',
          freeShipping: i % 2 == 0,
          returnPolicy: '14 дней',
          createdAt: DateTime.now().subtract(Duration(days: i * 2)),
          updatedAt: DateTime.now(),
          viewCount: 100 + (i * 25),
          likeCount: 20 + (i * 8),
          inCart: false,
          cartQuantity: 0,
        ));
      }
    }

    return products.take(limit).toList();
  }

  String _getFallbackStatus(int index) {
    if (index < 10) return 'Новинка';
    if (index % 4 == 0) return 'Скидка';
    return 'В наличии';
  }

  int _getFallbackStatusColor(int index) {
    if (index < 10) return 0xFF4CAF50; // Зеленый
    if (index % 4 == 0) return 0xFFF44336; // Красный
    return 0xFF2196F3; // Синий
  }

  List<String> _getFallbackCategories() {
    return <String>[
      'Одежда',
      'Обувь',
      'Аксессуары',
      'Спорт',
      'Дом',
      'Красота',
      'Электроника',
      'Книги',
    ];
  }

  List<String> _getFallbackBrands() {
    return <String>[
      'My Modus',
      'Nike',
      'Adidas',
      'Levi\'s',
      'Apple',
      'Samsung',
      'Zara',
      'H&M',
    ];
  }
}
