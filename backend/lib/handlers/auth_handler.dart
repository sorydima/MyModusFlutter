
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/auth_service.dart';
import '../services/jwt_service.dart';

class AuthHandler {
  final AuthService _authService;
  final JWTService _jwtService;

  AuthHandler(this._authService, this._jwtService);

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
    
    // Получение профиля
    router.get('/profile', _getProfile);
    
    // Обновление профиля
    router.put('/profile', _updateProfile);

    return router;
  }

  Future<Response> _register(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final result = await _authService.register(
        email: data['email'],
        password: data['password'],
        name: data['name'],
        phone: data['phone'],
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'User registered successfully',
          'user': result,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _login(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final result = await _authService.login(
        email: data['email'],
        password: data['password'],
      );
      
      if (result != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Login successful',
            'tokens': result,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.unauthorized(
          jsonEncode({
            'success': false,
            'error': 'Invalid credentials',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _refreshToken(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final newTokens = await _jwtService.refreshToken(data['refresh_token']);
      
      if (newTokens != null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'tokens': newTokens,
          }),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.unauthorized(
          jsonEncode({
            'success': false,
            'error': 'Invalid refresh token',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _logout(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      await _jwtService.invalidateToken(data['refresh_token']);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Logout successful',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getProfile(Request request) async {
    try {
      final token = request.headers['authorization']?.replaceFirst('Bearer ', '');
      if (token == null) {
        return Response.unauthorized(
          jsonEncode({
            'success': false,
            'error': 'No token provided',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final userId = _jwtService.getUserIdFromToken(token);
      if (userId == null) {
        return Response.unauthorized(
          jsonEncode({
            'success': false,
            'error': 'Invalid token',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final profile = await _authService.getUserProfile(userId);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'profile': profile,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _updateProfile(Request request) async {
    try {
      final token = request.headers['authorization']?.replaceFirst('Bearer ', '');
      if (token == null) {
        return Response.unauthorized(
          jsonEncode({
            'success': false,
            'error': 'No token provided',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final userId = _jwtService.getUserIdFromToken(token);
      if (userId == null) {
        return Response.unauthorized(
          jsonEncode({
            'success': false,
            'error': 'Invalid token',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      final updatedProfile = await _authService.updateUserProfile(
        userId,
        name: data['name'],
        phone: data['phone'],
        avatarUrl: data['avatar_url'],
        bio: data['bio'],
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Profile updated successfully',
          'profile': updatedProfile,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
