import 'dart:convert';
import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  // Загрузка переменных окружения
  DotEnv()..load();
  
  // Подключение к базе данных
  final uri = DotEnv().env['DATABASE_URL'] ?? 'postgres://mymodus:mymodus123@localhost:5432/mymodus';
  final uriObj = Uri.parse(uri);
  
  final connection = PostgreSQLConnection(
    uriObj.host,
    uriObj.port,
    uriObj.path.replaceFirst('/', ''),
    username: uriObj.userInfo.split(':').first,
    password: uriObj.userInfo.split(':').last,
    useSSL: false,
  );
  
  try {
    await connection.open();
    print('✅ Подключение к базе данных установлено');
    
    // Создание тестовых категорий
    await _createCategories(connection);
    
    // Создание тестовых товаров
    await _createProducts(connection);
    
    // Создание тестового пользователя
    await _createTestUser(connection);
    
    print('✅ Тестовые данные успешно добавлены!');
    
  } catch (e) {
    print('❌ Ошибка: $e');
  } finally {
    await connection.close();
  }
}

Future<void> _createCategories(PostgreSQLConnection connection) async {
  print('📁 Создание категорий...');
  
  final categories = [
    {
      'name': 'Обувь',
      'description': 'Кроссовки, туфли, ботинки',
      'icon': '👟',
    },
    {
      'name': 'Одежда',
      'description': 'Футболки, джинсы, куртки',
      'icon': '👕',
    },
    {
      'name': 'Аксессуары',
      'description': 'Сумки, ремни, украшения',
      'icon': '👜',
    },
  ];
  
  for (final category in categories) {
    await connection.execute(
      '''
      INSERT INTO categories (name, description, icon)
      VALUES (@name, @description, @icon)
      ON CONFLICT (name) DO NOTHING
      ''',
      substitutionValues: {
        'name': category['name'],
        'description': category['description'],
        'icon': category['icon'],
      },
    );
  }
  
  print('✅ Категории созданы');
}

Future<void> _createProducts(PostgreSQLConnection connection) async {
  print('🛍️ Создание товаров...');
  
  // Получаем ID категорий
  final categoriesResult = await connection.query('SELECT id, name FROM categories ORDER BY name');
  if (categoriesResult.isEmpty) {
    print('❌ Категории не найдены. Сначала создайте категории.');
    return;
  }
  
  final Map<String, String> categoryNameToId = {
    for (var row in categoriesResult) row[1] as String: row[0].toString()
  };

  final footwearId = categoryNameToId['Обувь'];
  final clothingId = categoryNameToId['Одежда'];
  final accessoriesId = categoryNameToId['Аксессуары'];

  final products = [
    {
      'title': 'Nike Air Max 270',
      'description': 'Стильные кроссовки для спорта и повседневной носки',
      'price': 12990,
      'old_price': 15990,
      'discount': 19,
      'image_url': 'https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=Nike+Air+Max+270',
      'product_url': 'https://example.com/nike-air-max-270',
      'brand': 'Nike',
      'category_id': footwearId, // Обувь
      'sku': 'NIKE-AM270-001',
      'specifications': jsonEncode({
        'material': 'Mesh',
        'sole': 'Rubber',
        'weight': '300g',
      }),
      'stock': 15,
      'rating': 4.8,
      'review_count': 127,
      'source': 'test',
      'source_id': 'nike-am270-001',
    },
    {
      'title': 'Adidas Ultraboost 22',
      'description': 'Профессиональные беговые кроссовки с технологией Boost',
      'price': 18990,
      'old_price': null,
      'discount': null,
      'image_url': 'https://via.placeholder.com/400x400/4ECDC4/FFFFFF?text=Adidas+Ultraboost+22',
      'product_url': 'https://example.com/adidas-ultraboost-22',
      'brand': 'Adidas',
      'category_id': footwearId, // Обувь
      'sku': 'ADIDAS-UB22-001',
      'specifications': jsonEncode({
        'material': 'Primeknit',
        'sole': 'Continental Rubber',
        'weight': '280g',
      }),
      'stock': 8,
      'rating': 4.9,
      'review_count': 89,
      'source': 'test',
      'source_id': 'adidas-ub22-001',
    },
    {
      'title': 'Levi\'s 501 Original Jeans',
      'description': 'Классические джинсы прямого кроя',
      'price': 7990,
      'old_price': 9990,
      'discount': 20,
      'image_url': 'https://via.placeholder.com/400x400/45B7D1/FFFFFF?text=Levis+501+Jeans',
      'product_url': 'https://example.com/levis-501-jeans',
      'brand': 'Levi\'s',
      'category_id': clothingId, // Одежда
      'sku': 'LEVIS-501-001',
      'specifications': jsonEncode({
        'material': '100% Cotton',
        'fit': 'Straight',
        'rise': 'Mid-rise',
      }),
      'stock': 25,
      'rating': 4.6,
      'review_count': 203,
      'source': 'test',
      'source_id': 'levis-501-001',
    },
    {
      'title': 'Apple Watch Series 8',
      'description': 'Умные часы с множеством функций для здоровья и фитнеса',
      'price': 45990,
      'old_price': 49990,
      'discount': 8,
      'image_url': 'https://via.placeholder.com/400x400/96CEB4/FFFFFF?text=Apple+Watch+Series+8',
      'product_url': 'https://example.com/apple-watch-series-8',
      'brand': 'Apple',
      'category_id': accessoriesId, // Аксессуары
      'sku': 'APPLE-WATCH8-001',
      'specifications': jsonEncode({
        'display': 'Always-On Retina',
        'battery': '18 hours',
        'water_resistance': '50m',
      }),
      'stock': 12,
      'rating': 4.7,
      'review_count': 156,
      'source': 'test',
      'source_id': 'apple-watch8-001',
    },
  ];
  
  for (final product in products) {
    await connection.execute(
      '''
      INSERT INTO products (
        title, description, price, old_price, discount,
        image_url, product_url, brand, category_id, sku,
        specifications, stock, rating, review_count, source, source_id
      ) VALUES (
        @title, @description, @price, @old_price, @discount,
        @image_url, @product_url, @brand, @category_id, @sku,
        @specifications, @stock, @rating, @review_count, @source, @source_id
      ) ON CONFLICT (source, source_id) DO NOTHING
      ''',
      substitutionValues: product,
    );
  }
  
  print('✅ Товары созданы');
}

Future<void> _createTestUser(PostgreSQLConnection connection) async {
  print('👤 Создание тестового пользователя...');
  
  await connection.execute(
    '''
    INSERT INTO users (email, password_hash, name, phone)
    VALUES (@email, @password_hash, @name, @phone)
    ON CONFLICT (email) DO NOTHING
    ''',
    substitutionValues: {
      'email': 'test@example.com',
      'password_hash': 'password123', // В реальном приложении - хеш
      'name': 'Test User',
      'phone': '+7 (999) 123-45-67',
    },
  );
  
  print('✅ Тестовый пользователь создан');
}
