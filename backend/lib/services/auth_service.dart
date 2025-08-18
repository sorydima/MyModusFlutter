import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';
import 'jwt_service.dart';

class AuthService {
  final DatabaseService _database;
  final JWTService _jwtService;
  final Uuid _uuid = Uuid();

  AuthService(this._database, this._jwtService);

  /// Регистрация пользователя
  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      // Проверка существования пользователя
      final existingUser = await _database.query(
        'SELECT id FROM users WHERE email = @email',
        substitutionValues: {'email': email},
      );

      if (existingUser.isNotEmpty) {
        throw Exception('User with this email already exists');
      }

      // Хеширование пароля
      final passwordHash = _hashPassword(password);

      // Создание пользователя
      final userId = _uuid.v4();
      await _database.execute(
        '''
        INSERT INTO users (id, email, password_hash, name, phone, is_active, is_verified)
        VALUES (@id, @email, @passwordHash, @name, @phone, true, false)
        ''',
        substitutionValues: {
          'id': userId,
          'email': email,
          'passwordHash': passwordHash,
          'name': name,
          'phone': phone,
        },
      );

      // Генерация токенов
      final tokens = _jwtService.createTokenPair(userId, email);

      // Получение профиля пользователя
      final userProfile = await getUserProfile(userId);

      return {
        'user': userProfile,
        'tokens': tokens,
      };
    } catch (e) {
      print('Error in register: $e');
      return null;
    }
  }

  /// Вход пользователя
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Поиск пользователя
      final users = await _database.query(
        '''
        SELECT id, email, password_hash, name, phone, is_active, is_verified, 
               wallet_address, avatar_url, bio
        FROM users WHERE email = @email
        ''',
        substitutionValues: {'email': email},
      );

      if (users.isEmpty) {
        return null;
      }

      final user = users.first;
      final passwordHash = user['password_hash'] as String;

      // Проверка пароля
      if (!_verifyPassword(password, passwordHash)) {
        return null;
      }

      // Проверка активности
      if (!(user['is_active'] as bool)) {
        throw Exception('Account is blocked');
      }

      // Генерация токенов
      final tokens = _jwtService.createTokenPair(user['id'], user['email']);

      return {
        'accessToken': tokens['accessToken'],
        'refreshToken': tokens['refreshToken'],
      };
    } catch (e) {
      print('Error in login: $e');
      return null;
    }
  }

  /// Получение профиля пользователя
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final users = await _database.query(
        '''
        SELECT id, email, name, phone, is_active, is_verified, 
               wallet_address, avatar_url, bio, created_at, updated_at
        FROM users WHERE id = @userId
        ''',
        substitutionValues: {'userId': userId},
      );

      if (users.isEmpty) {
        return null;
      }

      final user = users.first;

      // Получаем количество постов пользователя
      final postCount = await _database.query(
        'SELECT COUNT(*) as count FROM posts WHERE user_id = @userId',
        substitutionValues: {'userId': userId},
      );

      // Получаем количество подписчиков
      final followersCount = await _database.query(
        'SELECT COUNT(*) as count FROM follows WHERE following_id = @userId',
        substitutionValues: {'userId': userId},
      );

      // Получаем количество подписок
      final followingCount = await _database.query(
        'SELECT COUNT(*) as count FROM follows WHERE follower_id = @userId',
        substitutionValues: {'userId': userId},
      );

      return {
        'id': user['id'],
        'email': user['email'],
        'name': user['name'],
        'phone': user['phone'],
        'isActive': user['is_active'],
        'isVerified': user['is_verified'],
        'walletAddress': user['wallet_address'],
        'avatarUrl': user['avatar_url'],
        'bio': user['bio'],
        'createdAt': user['created_at'].toString(),
        'updatedAt': user['updated_at'].toString(),
        'stats': {
          'posts': postCount.first['count'] ?? 0,
          'followers': followersCount.first['count'] ?? 0,
          'following': followingCount.first['count'] ?? 0,
        },
      };
    } catch (e) {
      print('Error in getUserProfile: $e');
      return null;
    }
  }

  /// Обновление профиля пользователя
  Future<Map<String, dynamic>?> updateUserProfile(
    String userId, {
    String? name,
    String? phone,
    String? avatarUrl,
    String? bio,
  }) async {
    try {
      // Проверка существования пользователя
      final existingUser = await _database.query(
        'SELECT id FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId},
      );

      if (existingUser.isEmpty) {
        throw Exception('User not found');
      }

      // Обновление профиля
      final updateFields = <String, dynamic>{};
      if (name != null) updateFields['name'] = name;
      if (phone != null) updateFields['phone'] = phone;
      if (avatarUrl != null) updateFields['avatar_url'] = avatarUrl;
      if (bio != null) updateFields['bio'] = bio;

      if (updateFields.isNotEmpty) {
        final setClause = updateFields.keys.map((key) => '$key = @$key').join(', ');
        final query = 'UPDATE users SET $setClause WHERE id = @userId';

        final substitutionValues = Map<String, dynamic>.from(updateFields);
        substitutionValues['userId'] = userId;

        await _database.execute(query, substitutionValues: substitutionValues);
      }

      // Получаем обновленный профиль
      return await getUserProfile(userId);
    } catch (e) {
      print('Error in updateUserProfile: $e');
      return null;
    }
  }

  /// Изменение пароля
  Future<bool> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Получаем текущий пароль
      final users = await _database.query(
        'SELECT password_hash FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId},
      );

      if (users.isEmpty) {
        return false;
      }

      final currentPasswordHash = users.first['password_hash'] as String;

      // Проверяем текущий пароль
      if (!_verifyPassword(currentPassword, currentPasswordHash)) {
        return false;
      }

      // Хешируем новый пароль
      final newPasswordHash = _hashPassword(newPassword);

      // Обновляем пароль
      await _database.execute(
        'UPDATE users SET password_hash = @newPasswordHash WHERE id = @userId',
        substitutionValues: {
          'userId': userId,
          'newPasswordHash': newPasswordHash,
        },
      );

      return true;
    } catch (e) {
      print('Error in changePassword: $e');
      return false;
    }
  }

  /// Сброс пароля
  Future<bool> resetPassword(String email, String resetCode, String newPassword) async {
    try {
      // TODO: Проверка кода сброса
      // В реальном приложении здесь должна быть проверка кода

      // Хешируем новый пароль
      final newPasswordHash = _hashPassword(newPassword);

      // Обновляем пароль
      await _database.execute(
        'UPDATE users SET password_hash = @newPasswordHash WHERE email = @email',
        substitutionValues: {
          'email': email,
          'newPasswordHash': newPasswordHash,
        },
      );

      return true;
    } catch (e) {
      print('Error in resetPassword: $e');
      return false;
    }
  }

  /// Подтверждение email
  Future<bool> verifyEmail(String email, String verificationCode) async {
    try {
      // TODO: Проверка кода подтверждения
      // В реальном приложении здесь должна быть проверка кода

      // Обновляем статус верификации
      await _database.execute(
        'UPDATE users SET is_verified = true WHERE email = @email',
        substitutionValues: {'email': email},
      );

      return true;
    } catch (e) {
      print('Error in verifyEmail: $e');
      return false;
    }
  }

  /// Web3 аутентификация
  Future<Map<String, dynamic>?> web3Login({
    required String walletAddress,
    required String signature,
    required String message,
  }) async {
    try {
      // TODO: Верификация подписи Ethereum
      // Здесь должна быть проверка подписи через web3dart

      // Поиск пользователя по адресу кошелька
      final users = await _database.query(
        '''
        SELECT id, email, name, phone, is_active, is_verified, 
               wallet_address, avatar_url, bio
        FROM users WHERE wallet_address = @walletAddress
        ''',
        substitutionValues: {'walletAddress': walletAddress},
      );

      if (users.isNotEmpty) {
        // Пользователь существует
        final user = users.first;

        // Проверка активности
        if (!(user['is_active'] as bool)) {
          throw Exception('Account is blocked');
        }

        // Генерация токенов
        final tokens = _jwtService.createTokenPair(
          user['id'],
          user['email'] ?? walletAddress,
        );

        return {
          'accessToken': tokens['accessToken'],
          'refreshToken': tokens['refreshToken'],
        };
      } else {
        // Создание нового пользователя с Web3 кошельком
        final userId = _uuid.v4();
        await _database.execute(
          '''
          INSERT INTO users (id, wallet_address, is_active, is_verified)
          VALUES (@id, @walletAddress, true, true)
          ''',
          substitutionValues: {
            'id': userId,
            'walletAddress': walletAddress,
          },
        );

        // Генерация токенов
        final tokens = _jwtService.createTokenPair(userId, walletAddress);

        return {
          'accessToken': tokens['accessToken'],
          'refreshToken': tokens['refreshToken'],
        };
      }
    } catch (e) {
      print('Error in web3Login: $e');
      return null;
    }
  }

  /// Подключение кошелька к существующему аккаунту
  Future<bool> connectWallet(
    String userId,
    String walletAddress,
    String signature,
  ) async {
    try {
      // TODO: Верификация подписи
      // Проверка, что пользователь владеет кошельком

      // Проверка существования пользователя
      final existingUser = await _database.query(
        'SELECT id FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId},
      );

      if (existingUser.isEmpty) {
        return false;
      }

      // Проверка, что кошелек не занят
      final existingWallet = await _database.query(
        'SELECT id FROM users WHERE wallet_address = @walletAddress',
        substitutionValues: {'walletAddress': walletAddress},
      );

      if (existingWallet.isNotEmpty) {
        return false;
      }

      // Подключение кошелька
      await _database.execute(
        'UPDATE users SET wallet_address = @walletAddress WHERE id = @userId',
        substitutionValues: {
          'userId': userId,
          'walletAddress': walletAddress,
        },
      );

      return true;
    } catch (e) {
      print('Error in connectWallet: $e');
      return false;
    }
  }

  /// Хеширование пароля
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Проверка пароля
  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }
}
