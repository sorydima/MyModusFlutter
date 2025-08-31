import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class WildberriesService {
  static const String _baseUrl = 'https://www.wildberries.ru';
  
  // Реальные категории Wildberries
  static const List<String> _categories = [
    'Одежда',
    'Обувь',
    'Аксессуары',
    'Спорт',
    'Электроника',
    'Красота',
    'Дом',
    'Детские товары',
    'Автотовары',
    'Книги',
    'Игрушки',
    'Зоотовары',
    'Сад и огород',
    'Строительство',
    'Мебель',
    'Освещение',
    'Текстиль',
    'Посуда',
    'Хобби и творчество',
    'Туризм и рыбалка'
  ];

  // Популярные бренды Wildberries
  static const List<String> _popularBrands = [
    'My Modus',
    'Nike',
    'Adidas',
    'Levi\'s',
    'Apple',
    'Samsung',
    'Xiaomi',
    'Huawei',
    'Sony',
    'LG',
    'Canon',
    'Nikon',
    'Asus',
    'Lenovo',
    'HP',
    'Dell',
    'Reebok',
    'Puma',
    'New Balance',
    'Converse',
    'Vans',
    'Timberland',
    'Dr. Martens',
    'Clarks',
    'Ecco',
    'Geox',
    'Salomon',
    'Columbia',
    'The North Face',
    'Patagonia',
    'Arc\'teryx'
  ];

  // Получить список категорий
  static Future<List<String>> getCategories() async {
    // В реальном приложении здесь был бы API запрос
    await Future.delayed(const Duration(milliseconds: 500)); // Имитация задержки
    return _categories;
  }

  // Получить популярные бренды
  static Future<List<String>> getPopularBrands() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _popularBrands;
  }

  // Получить информацию о бренде
  static Future<Map<String, dynamic>> getBrandInfo(String brandName) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Имитация данных о бренде
    return {
      'name': brandName,
      'description': 'Популярный бренд с высоким качеством продукции',
      'rating': 4.5,
      'reviewCount': 1250,
      'productCount': 500,
      'logo': 'https://via.placeholder.com/100x100/007bff/ffffff?text=${brandName[0]}',
      'website': 'https://www.$brandName.toLowerCase().com',
      'founded': 1990,
      'country': 'США',
      'category': 'Основная категория',
    };
  }

  // Поиск товаров по запросу
  static Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    
    await Future.delayed(const Duration(milliseconds: 800)); // Имитация задержки
    
    // Генерируем реалистичные товары на основе запроса
    final products = <ProductModel>[];
    final queryLower = query.toLowerCase();
    
    // Определяем категорию на основе запроса
    String category = 'Другое';
    if (queryLower.contains('кроссовки') || queryLower.contains('обувь') || queryLower.contains('туфли')) {
      category = 'Обувь';
    } else if (queryLower.contains('джинсы') || queryLower.contains('футболка') || queryLower.contains('кофта')) {
      category = 'Одежда';
    } else if (queryLower.contains('телефон') || queryLower.contains('смартфон') || queryLower.contains('ноутбук')) {
      category = 'Электроника';
    } else if (queryLower.contains('спорт') || queryLower.contains('фитнес')) {
      category = 'Спорт';
    }
    
    // Генерируем товары
    for (int i = 0; i < 20; i++) {
      final brand = _getRandomBrand(query);
      final price = _generateRealisticPrice(category);
      final oldPrice = price * (1 + (0.1 + i * 0.05)); // Скидка 10-25%
      
      products.add(ProductModel(
        id: 'wb_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: _generateProductTitle(query, brand, category),
        brand: brand,
        category: category,
        price: price,
        oldPrice: oldPrice,
        imageUrl: _generateProductImage(query, category),
        rating: 3.5 + (i % 5) * 0.3, // Рейтинг от 3.5 до 5.0
        reviewCount: 10 + (i % 100) * 10, // Отзывы от 10 до 1000
        inStock: i % 10 != 0, // 90% товаров в наличии
        isNew: i % 7 == 0, // 14% новых товаров
        isSale: i % 3 == 0, // 33% товаров со скидкой
        status: _getProductStatus(i),
        statusColor: _getStatusColor(i),
        description: _generateProductDescription(query, brand, category),
        specifications: _generateSpecifications(category),
        images: _generateProductImages(query, category),
        sizes: _generateSizes(category),
        colors: _generateColors(),
        tags: _generateTags(query, category),
        weight: 0.5 + (i % 10) * 0.1,
        dimensions: '${10 + i % 20}x${5 + i % 15}x${2 + i % 8}',
        material: _getMaterial(category),
        country: _getCountry(brand),
        warranty: '${6 + i % 18} месяцев',
        deliveryTime: '${1 + i % 7} дней',
        freeShipping: i % 2 == 0,
        returnPolicy: '30 дней',
        createdAt: DateTime.now().subtract(Duration(days: i % 30)),
        updatedAt: DateTime.now(),
        viewCount: 100 + (i % 1000),
        likeCount: 10 + (i % 100),
        isFavorite: false,
        inCart: false,
        cartQuantity: 0,
      ));
    }
    
    return products;
  }

  // Получить товары по категории
  static Future<List<ProductModel>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final products = <ProductModel>[];
    final brands = _getBrandsForCategory(category);
    
    for (int i = 0; i < 25; i++) {
      final brand = brands[i % brands.length];
      final price = _generateRealisticPrice(category);
      final oldPrice = price * (1 + (0.1 + i * 0.03));
      
      products.add(ProductModel(
        id: 'wb_cat_${category}_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: _generateCategoryProductTitle(category, brand),
        brand: brand,
        category: category,
        price: price,
        oldPrice: oldPrice,
        imageUrl: _generateCategoryProductImage(category),
        rating: 3.8 + (i % 5) * 0.2,
        reviewCount: 20 + (i % 200) * 5,
        inStock: i % 12 != 0,
        isNew: i % 8 == 0,
        isSale: i % 4 == 0,
        status: _getProductStatus(i),
        statusColor: _getStatusColor(i),
        description: _generateCategoryProductDescription(category, brand),
        specifications: _generateSpecifications(category),
        images: _generateCategoryProductImages(category),
        sizes: _generateSizes(category),
        colors: _generateColors(),
        tags: _generateCategoryTags(category),
        weight: 0.3 + (i % 15) * 0.1,
        dimensions: '${8 + i % 25}x${4 + i % 20}x${1 + i % 10}',
        material: _getMaterial(category),
        country: _getCountry(brand),
        warranty: '${3 + i % 24} месяцев',
        deliveryTime: '${1 + i % 10} дней',
        freeShipping: i % 3 == 0,
        returnPolicy: '30 дней',
        createdAt: DateTime.now().subtract(Duration(days: i % 45)),
        updatedAt: DateTime.now(),
        viewCount: 150 + (i % 1200),
        likeCount: 15 + (i % 150),
        isFavorite: false,
        inCart: false,
        cartQuantity: 0,
      ));
    }
    
    return products;
  }

  // Получить популярные товары
  static Future<List<ProductModel>> getPopularProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final products = <ProductModel>[];
    final popularCategories = ['Одежда', 'Обувь', 'Электроника', 'Спорт'];
    
    for (int i = 0; i < 30; i++) {
      final category = popularCategories[i % popularCategories.length];
      final brand = _getRandomBrand('');
      final price = _generateRealisticPrice(category);
      
      products.add(ProductModel(
        id: 'wb_pop_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: _generatePopularProductTitle(category, brand),
        brand: brand,
        category: category,
        price: price,
        oldPrice: price * 1.15,
        imageUrl: _generatePopularProductImage(category),
        rating: 4.0 + (i % 5) * 0.2,
        reviewCount: 50 + (i % 500) * 10,
        inStock: true,
        isNew: i % 10 == 0,
        isSale: i % 5 == 0,
        status: _getProductStatus(i),
        statusColor: _getStatusColor(i),
        description: _generatePopularProductDescription(category, brand),
        specifications: _generateSpecifications(category),
        images: _generatePopularProductImages(category),
        sizes: _generateSizes(category),
        colors: _generateColors(),
        tags: _generatePopularTags(category),
        weight: 0.4 + (i % 12) * 0.1,
        dimensions: '${9 + i % 22}x${5 + i % 18}x${2 + i % 9}',
        material: _getMaterial(category),
        country: _getCountry(brand),
        warranty: '${6 + i % 18} месяцев',
        deliveryTime: '${1 + i % 5} дней',
        freeShipping: i % 2 == 0,
        returnPolicy: '30 дней',
        createdAt: DateTime.now().subtract(Duration(days: i % 20)),
        updatedAt: DateTime.now(),
        viewCount: 500 + (i % 2000),
        likeCount: 50 + (i % 300),
        isFavorite: false,
        inCart: false,
        cartQuantity: 0,
      ));
    }
    
    return products;
  }

  // Получить товары со скидкой
  static Future<List<ProductModel>> getDiscountedProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final products = <ProductModel>[];
    final categories = ['Одежда', 'Обувь', 'Электроника', 'Спорт', 'Дом', 'Красота'];
    
    for (int i = 0; i < 35; i++) {
      final category = categories[i % categories.length];
      final brand = _getRandomBrand('');
      final price = _generateRealisticPrice(category);
      final discount = 0.15 + (i % 6) * 0.05; // Скидка 15-40%
      final oldPrice = price / (1 - discount);
      
      products.add(ProductModel(
        id: 'wb_disc_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: _generateDiscountedProductTitle(category, brand),
        brand: brand,
        category: category,
        price: price,
        oldPrice: oldPrice,
        imageUrl: _generateDiscountedProductImage(category),
        rating: 3.5 + (i % 5) * 0.3,
        reviewCount: 30 + (i % 400) * 8,
        inStock: i % 15 != 0,
        isNew: false,
        isSale: true,
        status: 'Скидка ${(discount * 100).toInt()}%',
        statusColor: 0xFFFF0000, // Красный
        description: _generateDiscountedProductDescription(category, brand, discount),
        specifications: _generateSpecifications(category),
        images: _generateDiscountedProductImages(category),
        sizes: _generateSizes(category),
        colors: _generateColors(),
        tags: _generateDiscountedTags(category, discount),
        weight: 0.3 + (i % 18) * 0.1,
        dimensions: '${7 + i % 28}x${3 + i % 22}x${1 + i % 12}',
        material: _getMaterial(category),
        country: _getCountry(brand),
        warranty: '${3 + i % 21} месяцев',
        deliveryTime: '${1 + i % 8} дней',
        freeShipping: i % 4 == 0,
        returnPolicy: '30 дней',
        createdAt: DateTime.now().subtract(Duration(days: i % 60)),
        updatedAt: DateTime.now(),
        viewCount: 200 + (i % 1500),
        likeCount: 25 + (i % 200),
        isFavorite: false,
        inCart: false,
        cartQuantity: 0,
      ));
    }
    
    return products;
  }

  // Вспомогательные методы для генерации данных
  static String _getRandomBrand(String query) {
    if (query.toLowerCase().contains('nike')) return 'Nike';
    if (query.toLowerCase().contains('adidas')) return 'Adidas';
    if (query.toLowerCase().contains('apple')) return 'Apple';
    if (query.toLowerCase().contains('samsung')) return 'Samsung';
    
    final random = DateTime.now().millisecondsSinceEpoch;
    return _popularBrands[random % _popularBrands.length];
  }

  static double _generateRealisticPrice(String category) {
    final basePrices = {
      'Одежда': 1500.0,
      'Обувь': 3000.0,
      'Электроника': 15000.0,
      'Спорт': 2500.0,
      'Дом': 2000.0,
      'Красота': 800.0,
      'Другое': 1000.0,
    };
    
    final basePrice = basePrices[category] ?? 1000.0;
    final variation = 0.3 + (DateTime.now().millisecondsSinceEpoch % 100) / 100.0;
    return (basePrice * variation).roundToDouble();
  }

  static String _generateProductTitle(String query, String brand, String category) {
    final titles = {
      'Одежда': ['Футболка', 'Джинсы', 'Кофта', 'Пальто', 'Платье', 'Рубашка', 'Свитер', 'Куртка'],
      'Обувь': ['Кроссовки', 'Туфли', 'Ботинки', 'Сандалии', 'Сапоги', 'Лоферы', 'Мокасины', 'Кеды'],
      'Электроника': ['Смартфон', 'Ноутбук', 'Планшет', 'Наушники', 'Телевизор', 'Камера', 'Принтер', 'Монитор'],
      'Спорт': ['Кроссовки', 'Спортивный костюм', 'Футболка', 'Шорты', 'Куртка', 'Штаны', 'Кепка', 'Рюкзак'],
      'Дом': ['Подушка', 'Плед', 'Ваза', 'Светильник', 'Часы', 'Картина', 'Растение', 'Ковер'],
      'Красота': ['Крем', 'Маска', 'Сыворотка', 'Тональный крем', 'Помада', 'Тушь', 'Тени', 'Духи'],
    };
    
    final categoryTitles = titles[category] ?? ['Товар'];
    final title = categoryTitles[DateTime.now().millisecondsSinceEpoch % categoryTitles.length];
    
    if (query.isNotEmpty) {
      return '$title $brand ${query[0].toUpperCase() + query.substring(1)}';
    }
    return '$title $brand';
  }

  static String _generateProductImage(String query, String category) {
    final images = {
      'Одежда': [
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=400&fit=crop',
      ],
      'Обувь': [
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&h=400&fit=crop',
      ],
      'Электроника': [
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1526738549149-8e07eca6c147?w=400&h=400&fit=crop',
      ],
      'Спорт': [
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
      ],
    };
    
    final categoryImages = images[category] ?? [
      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=400&fit=crop'
    ];
    
    return categoryImages[DateTime.now().millisecondsSinceEpoch % categoryImages.length];
  }

  static String _getProductStatus(int index) {
    if (index % 7 == 0) return 'Новинка';
    if (index % 3 == 0) return 'Скидка';
    if (index % 10 == 0) return 'Нет в наличии';
    return 'В наличии';
  }

  static int _getStatusColor(int index) {
    if (index % 7 == 0) return 0xFF00FF00; // Зеленый для новинок
    if (index % 3 == 0) return 0xFFFF0000; // Красный для скидок
    if (index % 10 == 0) return 0xFF808080; // Серый для отсутствующих
    return 0xFF0000FF; // Синий для обычных
  }

  static String _generateProductDescription(String query, String brand, String category) {
    return 'Качественный товар от бренда $brand в категории $category. ${query.isNotEmpty ? 'Отлично подходит для: $query.' : ''} Высокое качество, стильный дизайн, доступная цена.';
  }

  static Map<String, String> _generateSpecifications(String category) {
    final specs = {
      'Одежда': {
        'Материал': '100% хлопок',
        'Сезон': 'Всесезонный',
        'Стиль': 'Повседневный',
        'Уход': 'Машинная стирка 30°C',
      },
      'Обувь': {
        'Материал верха': 'Натуральная кожа',
        'Материал подошвы': 'Резина',
        'Сезон': 'Всесезонный',
        'Размеры': '36-45',
      },
      'Электроника': {
        'Гарантия': '12 месяцев',
        'Страна производства': 'Китай',
        'Вес': '150-500г',
        'Питание': 'Аккумулятор',
      },
      'Спорт': {
        'Материал': 'Полиэстер',
        'Вентиляция': 'Да',
        'Водоотталкивающие свойства': 'Да',
        'УФ защита': 'UPF 50+',
      },
    };
    
    return specs[category] ?? {
      'Качество': 'Высокое',
      'Бренд': 'Проверенный',
      'Гарантия': 'Да',
    };
  }

  static List<String> _generateProductImages(String query, String category) {
    final baseImage = _generateProductImage(query, category);
    return [
      baseImage,
      baseImage.replaceAll('w=400&h=400', 'w=400&h=400&fit=crop&crop=entropy'),
      baseImage.replaceAll('w=400&h=400', 'w=400&h=400&fit=crop&crop=faces'),
    ];
  }

  static List<String> _generateSizes(String category) {
    if (category == 'Одежда') {
      return ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
    } else if (category == 'Обувь') {
      return ['36', '37', '38', '39', '40', '41', '42', '43', '44', '45'];
    } else if (category == 'Электроника') {
      return ['Один размер'];
    }
    return ['Универсальный'];
  }

  static List<String> _generateColors() {
    return ['Черный', 'Белый', 'Красный', 'Синий', 'Зеленый', 'Желтый', 'Серый', 'Коричневый'];
  }

  static List<String> _generateTags(String query, String category) {
    final tags = <String>[];
    
    if (query.isNotEmpty) {
      tags.add(query);
    }
    
    tags.addAll([category, 'Качество', 'Стиль', 'Мода']);
    
    if (category == 'Одежда') {
      tags.addAll(['Повседневный', 'Удобный', 'Модный']);
    } else if (category == 'Обувь') {
      tags.addAll(['Комфортный', 'Стильный', 'Качественный']);
    } else if (category == 'Электроника') {
      tags.addAll(['Современный', 'Функциональный', 'Надежный']);
    }
    
    return tags;
  }

  static String _getMaterial(String category) {
    final materials = {
      'Одежда': 'Хлопок, Полиэстер',
      'Обувь': 'Натуральная кожа, Текстиль',
      'Электроника': 'Пластик, Металл, Стекло',
      'Спорт': 'Полиэстер, Спандекс',
      'Дом': 'Текстиль, Дерево, Металл',
      'Красота': 'Натуральные компоненты',
    };
    
    return materials[category] ?? 'Качественные материалы';
  }

  static String _getCountry(String brand) {
    final countries = {
      'Nike': 'США',
      'Adidas': 'Германия',
      'Apple': 'США',
      'Samsung': 'Южная Корея',
      'Xiaomi': 'Китай',
      'Huawei': 'Китай',
    };
    
    return countries[brand] ?? 'Различные страны';
  }

  // Методы для категорий
  static String _generateCategoryProductTitle(String category, String brand) {
    final titles = {
      'Одежда': ['Футболка', 'Джинсы', 'Кофта', 'Пальто', 'Платье'],
      'Обувь': ['Кроссовки', 'Туфли', 'Ботинки', 'Сандалии', 'Сапоги'],
      'Электроника': ['Смартфон', 'Ноутбук', 'Планшет', 'Наушники', 'Телевизор'],
      'Спорт': ['Кроссовки', 'Спортивный костюм', 'Футболка', 'Шорты', 'Куртка'],
    };
    
    final categoryTitles = titles[category] ?? ['Товар'];
    final title = categoryTitles[DateTime.now().millisecondsSinceEpoch % categoryTitles.length];
    
    return '$title $brand';
  }

  static String _generateCategoryProductImage(String category) {
    return _generateProductImage('', category);
  }

  static String _generateCategoryProductDescription(String category, String brand) {
    return 'Отличный товар от бренда $brand в категории $category. Высокое качество, стильный дизайн.';
  }

  static List<String> _generateCategoryProductImages(String category) {
    return _generateProductImages('', category);
  }

  static List<String> _generateCategoryTags(String category) {
    return _generateTags('', category);
  }

  // Методы для популярных товаров
  static String _generatePopularProductTitle(String category, String brand) {
    return 'Популярный ${_generateCategoryProductTitle(category, brand)}';
  }

  static String _generatePopularProductImage(String category) {
    return _generateCategoryProductImage(category);
  }

  static String _generatePopularProductDescription(String category, String brand) {
    return 'Популярный товар от бренда $brand в категории $category. Высокий рейтинг, много отзывов.';
  }

  static List<String> _generatePopularProductImages(String category) {
    return _generateCategoryProductImages(category);
  }

  static List<String> _generatePopularTags(String category) {
    final tags = _generateCategoryTags(category);
    tags.addAll(['Популярный', 'Топ продаж', 'Высокий рейтинг']);
    return tags;
  }

  // Методы для товаров со скидкой
  static String _generateDiscountedProductTitle(String category, String brand) {
    return '${_generateCategoryProductTitle(category, brand)} со скидкой';
  }

  static String _generateDiscountedProductImage(String category) {
    return _generateCategoryProductImage(category);
  }

  static String _generateDiscountedProductDescription(String category, String brand, double discount) {
    return '${_generateCategoryProductDescription(category, brand)} Специальная скидка ${(discount * 100).toInt()}%!';
  }

  static List<String> _generateDiscountedProductImages(String category) {
    return _generateCategoryProductImages(category);
  }

  static List<String> _generateDiscountedTags(String category, double discount) {
    final tags = _generateCategoryTags(category);
    tags.addAll(['Скидка', '${(discount * 100).toInt()}%', 'Выгодно']);
    return tags;
  }

  // Получить бренды для категории
  static List<String> _getBrandsForCategory(String category) {
    final categoryBrands = {
      'Одежда': ['Nike', 'Adidas', 'Levi\'s', 'My Modus', 'Reebok', 'Puma'],
      'Обувь': ['Nike', 'Adidas', 'Reebok', 'Puma', 'New Balance', 'Converse'],
      'Электроника': ['Apple', 'Samsung', 'Xiaomi', 'Huawei', 'Sony', 'LG'],
      'Спорт': ['Nike', 'Adidas', 'Reebok', 'Puma', 'Under Armour', 'Columbia'],
      'Дом': ['IKEA', 'Zara Home', 'H&M Home', 'Muji', 'Uniqlo', 'H&M'],
      'Красота': ['L\'Oreal', 'Maybelline', 'Revlon', 'NYX', 'Wet n Wild', 'Essence'],
    };
    
    return categoryBrands[category] ?? _popularBrands.take(6).toList();
  }
}
