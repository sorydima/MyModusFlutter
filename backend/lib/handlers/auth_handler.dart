
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';
import '../services/jwt_service.dart';

class AuthHandler {
  final DatabaseService _db;
  final JWTService _jwtService;
  final Uuid _uuid = Uuid();

  AuthHandler(this._db, this._jwtService);

  Router get router {
    final router = Router();

    // Регистрация пользователя
    router.post('/register', _register);
    
    // Вход пользователя
    router.post('/login', _login);
    
    // Выход пользователя
    router.post('/logout', _logout);
    
    // Обновление токена
    router.post('/refresh', _refreshToken);
    
    // Подтверждение email
    router.post('/verify-email', _verifyEmail);
    
    // Сброс пароля
    router.post('/forgot-password', _forgotPassword);
    router.post('/reset-password', _resetPassword);
    
    // Изменение пароля
    router.post('/change-password', _changePassword);
    
    // Обновление профиля
    router.put('/profile', _updateProfile);
    
    // Получение профиля
    router.get('/profile', _getProfile);
    
    // Web3 аутентификация
    router.post('/web3-login', _web3Login);
    router.post('/connect-wallet', _connectWallet);
    
    // Проверка токена
    router.get('/verify', _verifyToken);

    return router;
  }

  // Регистрация пользователя
  Future<Response> _register(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final email = data['email'] as String?;
      final password = data['password'] as String?;
      final name = data['name'] as String?;
      final phone = data['phone'] as String?;

      if (email == null || password == null) {
        return Response(400, 
          body: json.encode({'error': 'Email и пароль обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка существования пользователя
      final existingUser = await _db.query(
        'SELECT id FROM users WHERE email = @email',
        substitutionValues: {'email': email}
      );

      if (existingUser.isNotEmpty) {
        return Response(409, 
          body: json.encode({'error': 'Пользователь с таким email уже существует'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Хеширование пароля
      final passwordHash = _hashPassword(password);

      // Создание пользователя
      final userId = _uuid.v4();
      await _db.execute(
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
        }
      );

      // Генерация JWT токена
      final token = _jwtService.generateToken(userId, email);

      return Response(201, 
        body: json.encode({
          'message': 'Пользователь успешно зарегистрирован',
          'user': {
            'id': userId,
            'email': email,
            'name': name,
            'phone': phone,
            'isVerified': false
          },
          'token': token
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Вход пользователя
  Future<Response> _login(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final email = data['email'] as String?;
      final password = data['password'] as String?;

      if (email == null || password == null) {
        return Response(400, 
          body: json.encode({'error': 'Email и пароль обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Поиск пользователя
      final users = await _db.query(
        '''
        SELECT id, email, password_hash, name, phone, is_active, is_verified, 
               wallet_address, avatar_url, bio
        FROM users WHERE email = @email
        ''',
        substitutionValues: {'email': email}
      );

      if (users.isEmpty) {
        return Response(401, 
          body: json.encode({'error': 'Неверный email или пароль'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final user = users.first;
      final passwordHash = user['password_hash'] as String;

      // Проверка пароля
      if (!_verifyPassword(password, passwordHash)) {
        return Response(401, 
          body: json.encode({'error': 'Неверный email или пароль'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка активности
      if (!(user['is_active'] as bool)) {
        return Response(403, 
          body: json.encode({'error': 'Аккаунт заблокирован'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Генерация JWT токена
      final token = _jwtService.generateToken(user['id'], user['email']);

      return Response(200, 
        body: json.encode({
          'message': 'Успешный вход',
          'user': {
            'id': user['id'],
            'email': user['email'],
            'name': user['name'],
            'phone': user['phone'],
            'isVerified': user['is_verified'],
            'walletAddress': user['wallet_address'],
            'avatarUrl': user['avatar_url'],
            'bio': user['bio']
          },
          'token': token
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Web3 аутентификация
  Future<Response> _web3Login(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final walletAddress = data['walletAddress'] as String?;
      final signature = data['signature'] as String?;
      final message = data['message'] as String?;

      if (walletAddress == null || signature == null || message == null) {
        return Response(400, 
          body: json.encode({'error': 'Адрес кошелька, подпись и сообщение обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // TODO: Верификация подписи Ethereum
      // Здесь должна быть проверка подписи через web3dart

      // Поиск пользователя по адресу кошелька
      final users = await _db.query(
        '''
        SELECT id, email, name, phone, is_active, is_verified, 
               wallet_address, avatar_url, bio
        FROM users WHERE wallet_address = @walletAddress
        ''',
        substitutionValues: {'walletAddress': walletAddress}
      );

      if (users.isEmpty) {
        // Создание нового пользователя с Web3 кошельком
        final userId = _uuid.v4();
        await _db.execute(
          '''
          INSERT INTO users (id, wallet_address, is_active, is_verified)
          VALUES (@id, @walletAddress, true, true)
          ''',
          substitutionValues: {
            'id': userId,
            'walletAddress': walletAddress,
          }
        );

        // Генерация JWT токена
        final token = _jwtService.generateToken(userId, walletAddress);

        return Response(201, 
          body: json.encode({
            'message': 'Web3 пользователь создан',
            'user': {
              'id': userId,
              'walletAddress': walletAddress,
              'isVerified': true
            },
            'token': token
          }),
          headers: {'content-type': 'application/json'}
        );
      }

      final user = users.first;

      // Проверка активности
      if (!(user['is_active'] as bool)) {
        return Response(403, 
          body: json.encode({'error': 'Аккаунт заблокирован'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Генерация JWT токена
      final token = _jwtService.generateToken(user['id'], user['email'] ?? user['wallet_address']);

      return Response(200, 
        body: json.encode({
          'message': 'Web3 вход выполнен',
          'user': {
            'id': user['id'],
            'email': user['email'],
            'name': user['name'],
            'phone': user['phone'],
            'isVerified': user['is_verified'],
            'walletAddress': user['wallet_address'],
            'avatarUrl': user['avatar_url'],
            'bio': user['bio']
          },
          'token': token
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Подключение кошелька к существующему аккаунту
  Future<Response> _connectWallet(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final userId = data['userId'] as String?;
      final walletAddress = data['walletAddress'] as String?;
      final signature = data['signature'] as String?;

      if (userId == null || walletAddress == null || signature == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя, адрес кошелька и подпись обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // TODO: Верификация подписи
      // Проверка, что пользователь владеет кошельком

      // Проверка существования пользователя
      final users = await _db.query(
        'SELECT id FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId}
      );

      if (users.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Пользователь не найден'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка, что кошелек не занят
      final existingWallet = await _db.query(
        'SELECT id FROM users WHERE wallet_address = @walletAddress',
        substitutionValues: {'walletAddress': walletAddress}
      );

      if (existingWallet.isNotEmpty) {
        return Response(409, 
          body: json.encode({'error': 'Кошелек уже подключен к другому аккаунту'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Подключение кошелька
      await _db.execute(
        'UPDATE users SET wallet_address = @walletAddress WHERE id = @userId',
        substitutionValues: {
          'userId': userId,
          'walletAddress': walletAddress,
        }
      );

      return Response(200, 
        body: json.encode({'message': 'Кошелек успешно подключен'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Обновление профиля
  Future<Response> _updateProfile(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final userId = data['userId'] as String?;
      final name = data['name'] as String?;
      final phone = data['phone'] as String?;
      final avatarUrl = data['avatarUrl'] as String?;
      final bio = data['bio'] as String?;

      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка существования пользователя
      final users = await _db.query(
        'SELECT id FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId}
      );

      if (users.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Пользователь не найден'}),
          headers: {'content-type': 'application/json'}
        );
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

        await _db.execute(query, substitutionValues: substitutionValues);
      }

      return Response(200, 
        body: json.encode({'message': 'Профиль обновлен'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение профиля
  Future<Response> _getProfile(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      
      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final users = await _db.query(
        '''
        SELECT id, email, name, phone, is_active, is_verified, 
               wallet_address, avatar_url, bio, created_at
        FROM users WHERE id = @userId
        ''',
        substitutionValues: {'userId': userId}
      );

      if (users.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Пользователь не найден'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final user = users.first;

      return Response(200, 
        body: json.encode({
          'user': {
            'id': user['id'],
            'email': user['email'],
            'name': user['name'],
            'phone': user['phone'],
            'isActive': user['is_active'],
            'isVerified': user['is_verified'],
            'walletAddress': user['wallet_address'],
            'avatarUrl': user['avatar_url'],
            'bio': user['bio'],
            'createdAt': user['created_at'].toString()
          }
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Выход пользователя
  Future<Response> _logout(Request request) async {
    try {
      // В реальном приложении здесь можно добавить токен в blacklist
      return Response(200, 
        body: json.encode({'message': 'Успешный выход'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Обновление токена
  Future<Response> _refreshToken(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final refreshToken = data['refreshToken'] as String?;

      if (refreshToken == null) {
        return Response(400, 
          body: json.encode({'error': 'Refresh токен обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // TODO: Валидация refresh токена и генерация нового access токена
      return Response(200, 
        body: json.encode({'message': 'Токен обновлен'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Подтверждение email
  Future<Response> _verifyEmail(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final email = data['email'] as String?;
      final verificationCode = data['verificationCode'] as String?;

      if (email == null || verificationCode == null) {
        return Response(400, 
          body: json.encode({'error': 'Email и код подтверждения обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // TODO: Проверка кода подтверждения
      // В реальном приложении здесь должна быть проверка кода

      await _db.execute(
        'UPDATE users SET is_verified = true WHERE email = @email',
        substitutionValues: {'email': email}
      );

      return Response(200, 
        body: json.encode({'message': 'Email подтвержден'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Сброс пароля
  Future<Response> _forgotPassword(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final email = data['email'] as String?;

      if (email == null) {
        return Response(400, 
          body: json.encode({'error': 'Email обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // TODO: Отправка email с кодом сброса
      // В реальном приложении здесь должна быть отправка email

      return Response(200, 
        body: json.encode({'message': 'Инструкции по сбросу пароля отправлены на email'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Сброс пароля
  Future<Response> _resetPassword(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final email = data['email'] as String?;
      final resetCode = data['resetCode'] as String?;
      final newPassword = data['newPassword'] as String?;

      if (email == null || resetCode == null || newPassword == null) {
        return Response(400, 
          body: json.encode({'error': 'Email, код сброса и новый пароль обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // TODO: Проверка кода сброса
      // В реальном приложении здесь должна быть проверка кода

      final passwordHash = _hashPassword(newPassword);

      await _db.execute(
        'UPDATE users SET password_hash = @passwordHash WHERE email = @email',
        substitutionValues: {
          'email': email,
          'passwordHash': passwordHash,
        }
      );

      return Response(200, 
        body: json.encode({'message': 'Пароль успешно изменен'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Изменение пароля
  Future<Response> _changePassword(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final userId = data['userId'] as String?;
      final currentPassword = data['currentPassword'] as String?;
      final newPassword = data['newPassword'] as String?;

      if (userId == null || currentPassword == null || newPassword == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя, текущий и новый пароль обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Проверка текущего пароля
      final users = await _db.query(
        'SELECT password_hash FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId}
      );

      if (users.isEmpty) {
        return Response(404, 
          body: json.encode({'error': 'Пользователь не найден'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final currentPasswordHash = users.first['password_hash'] as String;

      if (!_verifyPassword(currentPassword, currentPasswordHash)) {
        return Response(401, 
          body: json.encode({'error': 'Неверный текущий пароль'}),
          headers: {'content-type': 'application/json'}
        );
      }

      // Обновление пароля
      final newPasswordHash = _hashPassword(newPassword);

      await _db.execute(
        'UPDATE users SET password_hash = @passwordHash WHERE id = @userId',
        substitutionValues: {
          'userId': userId,
          'passwordHash': newPasswordHash,
        }
      );

      return Response(200, 
        body: json.encode({'message': 'Пароль успешно изменен'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Проверка токена
  Future<Response> _verifyToken(Request request) async {
    try {
      final authHeader = request.headers['authorization'];
      
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401, 
          body: json.encode({'error': 'Токен не предоставлен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final token = authHeader.substring(7);
      
      try {
        final payload = _jwtService.verifyToken(token);
        return Response(200, 
          body: json.encode({
            'valid': true,
            'userId': payload['userId'],
            'email': payload['email']
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e) {
        return Response(401, 
          body: json.encode({'error': 'Недействительный токен'}),
          headers: {'content-type': 'application/json'}
        );
      }
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Хеширование пароля
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Проверка пароля
  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }
}
