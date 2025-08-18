
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

class JWTService {
  static const String _secretKey = 'your-secret-key-here'; // В продакшене использовать переменную окружения
  static const Duration _accessTokenExpiry = Duration(hours: 1);
  static const Duration _refreshTokenExpiry = Duration(days: 30);
  
  final Uuid _uuid = Uuid();

  /// Генерация JWT токена
  String generateToken(String userId, String email) {
    final jwt = JWT(
      {
        'userId': userId,
        'email': email,
        'type': 'access',
        'jti': _uuid.v4(), // JWT ID для уникальности
      },
      issuer: 'mymodus',
      audience: 'mymodus-users',
    );

    return jwt.sign(SecretKey(_secretKey), expiresIn: _accessTokenExpiry);
  }

  /// Генерация refresh токена
  String generateRefreshToken(String userId) {
    final jwt = JWT(
      {
        'userId': userId,
        'type': 'refresh',
        'jti': _uuid.v4(),
      },
      issuer: 'mymodus',
      audience: 'mymodus-users',
    );

    return jwt.sign(SecretKey(_secretKey), expiresIn: _refreshTokenExpiry);
  }

  /// Валидация токена
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }

  /// Получение ID пользователя из токена
  String? getUserIdFromToken(String token) {
    final payload = verifyToken(token);
    if (payload != null && payload['type'] == 'access') {
      return payload['userId'] as String?;
    }
    return null;
  }

  /// Получение email из токена
  String? getEmailFromToken(String token) {
    final payload = verifyToken(token);
    if (payload != null && payload['type'] == 'access') {
      return payload['email'] as String?;
    }
    return null;
  }

  /// Обновление токена
  Map<String, String>? refreshToken(String refreshToken) {
    try {
      final payload = verifyToken(refreshToken);
      if (payload != null && payload['type'] == 'refresh') {
        final userId = payload['userId'] as String?;
        if (userId != null) {
          // Получаем email пользователя (в реальном приложении из базы данных)
          final email = 'user@example.com'; // TODO: Получать из базы
          
          final newAccessToken = generateToken(userId, email);
          final newRefreshToken = generateRefreshToken(userId);
          
          return {
            'accessToken': newAccessToken,
            'refreshToken': newRefreshToken,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Инвалидация токена (добавление в blacklist)
  Future<void> invalidateToken(String refreshToken) async {
    // TODO: Добавить токен в blacklist в Redis
    // await _redis.setex('blacklist:$refreshToken', 86400, '1'); // 24 часа
  }

  /// Проверка, не находится ли токен в blacklist
  Future<bool> isTokenBlacklisted(String token) async {
    // TODO: Проверить токен в blacklist в Redis
    // final isBlacklisted = await _redis.exists('blacklist:$token');
    // return isBlacklisted == 1;
    return false;
  }

  /// Создание пары токенов (access + refresh)
  Map<String, String> createTokenPair(String userId, String email) {
    return {
      'accessToken': generateToken(userId, email),
      'refreshToken': generateRefreshToken(userId),
    };
  }

  /// Проверка срока действия токена
  bool isTokenExpired(String token) {
    try {
      final payload = verifyToken(token);
      if (payload != null) {
        final exp = payload['exp'] as int?;
        if (exp != null) {
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          return DateTime.now().isAfter(expiryTime);
        }
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Получение времени истечения токена
  DateTime? getTokenExpiry(String token) {
    try {
      final payload = verifyToken(token);
      if (payload != null) {
        final exp = payload['exp'] as int?;
        if (exp != null) {
          return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Валидация структуры токена
  bool isValidTokenStructure(String token) {
    try {
      final parts = token.split('.');
      return parts.length == 3;
    } catch (e) {
      return false;
    }
  }

  /// Создание токена для сброса пароля
  String generatePasswordResetToken(String userId, String email) {
    final jwt = JWT(
      {
        'userId': userId,
        'email': email,
        'type': 'password_reset',
        'jti': _uuid.v4(),
      },
      issuer: 'mymodus',
      audience: 'mymodus-users',
    );

    return jwt.sign(SecretKey(_secretKey), expiresIn: Duration(hours: 1));
  }

  /// Валидация токена сброса пароля
  Map<String, dynamic>? verifyPasswordResetToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      final payload = jwt.payload;
      
      if (payload['type'] == 'password_reset') {
        return payload;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Создание токена для верификации email
  String generateEmailVerificationToken(String userId, String email) {
    final jwt = JWT(
      {
        'userId': userId,
        'email': email,
        'type': 'email_verification',
        'jti': _uuid.v4(),
      },
      issuer: 'mymodus',
      audience: 'mymodus-users',
    );

    return jwt.sign(SecretKey(_secretKey), expiresIn: Duration(days: 7));
  }

  /// Валидация токена верификации email
  Map<String, dynamic>? verifyEmailVerificationToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      final payload = jwt.payload;
      
      if (payload['type'] == 'email_verification') {
        return payload;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
