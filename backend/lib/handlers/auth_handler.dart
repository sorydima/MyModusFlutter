
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database.dart';
import '../services/jwt_service.dart';

class AuthHandler {
  final DatabaseService _db;
  final JWTService _jwtService;
  
  AuthHandler(this._db) : _jwtService = JWTService();
  
  Router get router {
    final router = Router();
    
    // Регистрация пользователя
    router.post('/register', _register);
    
    // Вход в систему
    router.post('/login', _login);
    
    // Обновление токена
    router.post('/refresh', _refreshToken);
    
    // Выход из системы
    router.post('/logout', _logout);
    
    // Получение профиля пользователя
    router.get('/profile', _getProfile);
    
    return router;
  }
  
  /// Регистрация пользователя
  Future<Response> _register(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final email = data['email'] as String?;
      final password = data['password'] as String?;
      final name = data['name'] as String?;
      final phone = data['phone'] as String?;
      
      if (email == null || password == null) {
        return Response(400, 
          body: jsonEncode({'error': 'Email and password are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Проверка существования пользователя
      final conn = await _db.getConnection();
      try {
        final existingUser = await conn.query(
          'SELECT id FROM users WHERE email = @email',
          substitutionValues: {'email': email},
        );
        
        if (existingUser.isNotEmpty) {
          return Response(409,
            body: jsonEncode({'error': 'User already exists'}),
            headers: {'content-type': 'application/json'},
          );
        }
        
        // Создание пользователя
        final userId = await conn.query(
          '''
          INSERT INTO users (email, password_hash, name, phone)
          VALUES (@email, @password_hash, @name, @phone)
          RETURNING id
          ''',
          substitutionValues: {
            'email': email,
            'password_hash': _hashPassword(password),
            'name': name,
            'phone': phone,
          },
        );
        
        // Генерация JWT токена
        final token = _jwtService.generateToken(userId.first.first.toString());
        
        return Response(201,
          body: jsonEncode({
            'message': 'User registered successfully',
            'token': token,
            'user_id': userId.first.first,
          }),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Registration failed: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Вход в систему
  Future<Response> _login(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final email = data['email'] as String?;
      final password = data['password'] as String?;
      
      if (email == null || password == null) {
        return Response(400,
          body: jsonEncode({'error': 'Email and password are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Проверка пользователя
      final conn = await _db.getConnection();
      try {
        final user = await conn.query(
          'SELECT id, password_hash, name FROM users WHERE email = @email AND is_active = true',
          substitutionValues: {'email': email},
        );
        
        if (user.isEmpty) {
          return Response(401,
            body: jsonEncode({'error': 'Invalid credentials'}),
            headers: {'content-type': 'application/json'},
          );
        }
        
        final userId = user.first[0];
        final storedHash = user.first[1] as String;
        final userName = user.first[2] as String?;
        
        // Проверка пароля
        if (!_verifyPassword(password, storedHash)) {
          return Response(401,
            body: jsonEncode({'error': 'Invalid credentials'}),
            headers: {'content-type': 'application/json'},
          );
        }
        
        // Генерация JWT токена
        final token = _jwtService.generateToken(userId.toString());
        
        return Response.ok(
          jsonEncode({
            'message': 'Login successful',
            'token': token,
            'user_id': userId,
            'name': userName,
          }),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Login failed: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Обновление токена
  Future<Response> _refreshToken(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final refreshToken = data['refresh_token'] as String?;
      
      if (refreshToken == null) {
        return Response(400,
          body: jsonEncode({'error': 'Refresh token is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Проверка refresh токена
      final payload = _jwtService.verifyToken(refreshToken);
      if (payload == null) {
        return Response(401,
          body: jsonEncode({'error': 'Invalid refresh token'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Генерация нового токена
      final newToken = _jwtService.generateToken(payload['user_id']);
      
      return Response.ok(
        jsonEncode({
          'message': 'Token refreshed successfully',
          'token': newToken,
        }),
        headers: {'content-type': 'application/json'},
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Token refresh failed: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Выход из системы
  Future<Response> _logout(Request request) async {
    // В JWT-based аутентификации logout обычно реализуется на клиенте
    // путем удаления токена. Здесь можно добавить blacklist токенов.
    return Response.ok(
      jsonEncode({'message': 'Logged out successfully'}),
      headers: {'content-type': 'application/json'},
    );
  }
  
  /// Получение профиля пользователя
  Future<Response> _getProfile(Request request) async {
    try {
      // Получение токена из заголовка
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401,
          body: jsonEncode({'error': 'Authorization header required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final token = authHeader.substring(7);
      final payload = _jwtService.verifyToken(token);
      
      if (payload == null) {
        return Response(401,
          body: jsonEncode({'error': 'Invalid token'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final userId = payload['user_id'];
      
      // Получение данных пользователя
      final conn = await _db.getConnection();
      try {
        final user = await conn.query(
          'SELECT id, email, name, phone, created_at FROM users WHERE id = @id',
          substitutionValues: {'id': userId},
        );
        
        if (user.isEmpty) {
          return Response(404,
            body: jsonEncode({'error': 'User not found'}),
            headers: {'content-type': 'application/json'},
          );
        }
        
        final userData = user.first;
        
        return Response.ok(
          jsonEncode({
            'id': userData[0],
            'email': userData[1],
            'name': userData[2],
            'phone': userData[3],
            'created_at': userData[4].toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
        
      } finally {
        await conn.close();
      }
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get profile: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
  
  /// Хеширование пароля
  String _hashPassword(String password) {
    // В реальном приложении используйте bcrypt или argon2
    // Здесь упрощенная версия для демонстрации
    return password; // TODO: Implement proper hashing
  }
  
  /// Проверка пароля
  bool _verifyPassword(String password, String hash) {
    // В реальном приложении используйте bcrypt или argon2
    return _hashPassword(password) == hash;
  }
}
