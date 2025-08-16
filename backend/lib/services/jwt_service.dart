
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';

class JWTService {
  late final String _secret;

  JWTService() {
    final env = DotEnv()..load();
    _secret = env['JWT_SECRET'] ?? 'your_jwt_secret_here';
  }

  /// Генерация JWT токена
  String generateToken(String userId) {
    final jwt = JWT(
      {
        'user_id': userId,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
      },
      issuer: 'mymodus',
    );

    return jwt.sign(SecretKey(_secret));
  }

  /// Проверка JWT токена
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }

  /// Проверка срока действия токена
  bool isTokenExpired(String token) {
    try {
      final payload = verifyToken(token);
      if (payload == null) return true;

      final exp = payload['exp'] as int?;
      if (exp == null) return true;

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationTime);
    } catch (e) {
      return true;
    }
  }

  /// Обновление токена
  String? refreshToken(String token) {
    try {
      final payload = verifyToken(token);
      if (payload == null) return null;

      final userId = payload['user_id'] as String?;
      if (userId == null) return null;

      return generateToken(userId);
    } catch (e) {
      return null;
    }
  }
}
