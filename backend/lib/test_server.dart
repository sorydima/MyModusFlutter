import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

void main(List<String> args) async {
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
  print('🚀 Тестовый сервер запущен на http://localhost:8080');
  print('📱 Health check: http://localhost:8080/health');
  print('🛍️ Товары: http://localhost:8080/api/products');
  print('📁 Категории: http://localhost:8080/api/categories');

  // Graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n🛑 Остановка сервера...');
    await server.close();
    exit(0);
  });
}

// Обработчики API
Future<Response> _getProducts(Request request) async {
  final products = [
    {
      'id': '1',
      'title': 'Nike Air Max 270',
      'price': 12990,
      'image_url': 'https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=Nike+Air+Max+270',
      'brand': 'Nike',
    },
    {
      'id': '2',
      'title': 'Adidas Ultraboost 22',
      'price': 18990,
      'image_url': 'https://via.placeholder.com/400x400/4ECDC4/FFFFFF?text=Adidas+Ultraboost+22',
      'brand': 'Adidas',
    },
    {
      'id': '3',
      'title': 'Levi\'s 501 Original Jeans',
      'price': 7990,
      'image_url': 'https://via.placeholder.com/400x400/45B7D1/FFFFFF?text=Levis+501+Jeans',
      'brand': 'Levi\'s',
    },
  ];
  
  return Response.ok(
    '{"products": $products}',
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _getCategories(Request request) async {
  final categories = [
    {
      'id': '1',
      'name': 'Обувь',
      'description': 'Кроссовки, туфли, ботинки',
      'icon': '👟',
    },
    {
      'id': '2',
      'name': 'Одежда',
      'description': 'Футболки, джинсы, куртки',
      'icon': '👕',
    },
    {
      'id': '3',
      'name': 'Аксессуары',
      'description': 'Сумки, ремни, украшения',
      'icon': '👜',
    },
  ];
  
  return Response.ok(
    '{"categories": $categories}',
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _register(Request request) async {
  return Response.ok(
    '{"message": "Регистрация успешна", "user_id": "123"}',
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _login(Request request) async {
  return Response.ok(
    '{"message": "Вход успешен", "token": "fake_jwt_token"}',
    headers: {'content-type': 'application/json'},
  );
}
