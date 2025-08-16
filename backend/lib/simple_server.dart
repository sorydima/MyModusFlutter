import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'database.dart';

void main(List<String> args) async {
  // Инициализация базы данных
  try {
    await DatabaseService.runMigrations();
    print('✅ База данных инициализирована');
  } catch (e) {
    print('❌ Ошибка инициализации БД: $e');
    return;
  }

  // Создание роутера
  final router = Router();

  // Health check
  router.get('/health', (Request request) {
    return Response.ok('OK', headers: {'content-type': 'text/plain'});
  });

  // API endpoints
  router.get('/api/products', _getProducts);
  router.get('/api/categories', _getCategories);
  router.post('/api/auth/register', _register);
  router.post('/api/auth/login', _login);

  // Применение CORS
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router);

  // Запуск сервера
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('🚀 Сервер запущен на http://localhost:8080');

  // Graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n🛑 Остановка сервера...');
    await server.close();
    await DatabaseService.closeConnection();
    exit(0);
  });
}

// Обработчики API
Future<Response> _getProducts(Request request) async {
  try {
    final conn = await DatabaseService.getConnection();
    final result = await conn.query('SELECT * FROM products LIMIT 10');
    
    final products = result.map((row) => {
      'id': row[0],
      'title': row[1],
      'price': row[3],
      'image_url': row[6],
      'brand': row[8],
    }).toList();
    
    return Response.ok(
      '{"products": $products}',
      headers: {'content-type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: '{"error": "Ошибка получения товаров: $e"}',
      headers: {'content-type': 'application/json'},
    );
  }
}

Future<Response> _getCategories(Request request) async {
  try {
    final conn = await DatabaseService.getConnection();
    final result = await conn.query('SELECT * FROM categories');
    
    final categories = result.map((row) => {
      'id': row[0],
      'name': row[1],
      'description': row[2],
      'icon': row[3],
    }).toList();
    
    return Response.ok(
      '{"categories": $categories}',
      headers: {'content-type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: '{"error": "Ошибка получения категорий: $e"}',
      headers: {'content-type': 'application/json'},
    );
  }
}

Future<Response> _register(Request request) async {
  try {
    // Простая регистрация без валидации
    return Response.ok(
      '{"message": "Регистрация успешна", "user_id": "123"}',
      headers: {'content-type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: '{"error": "Ошибка регистрации: $e"}',
      headers: {'content-type': 'application/json'},
    );
  }
}

Future<Response> _login(Request request) async {
  try {
    // Простой вход без валидации
    return Response.ok(
      '{"message": "Вход успешен", "token": "fake_jwt_token"}',
      headers: {'content-type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: '{"error": "Ошибка входа: $e"}',
      headers: {'content-type': 'application/json'},
    );
  }
}
