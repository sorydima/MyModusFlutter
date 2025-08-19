
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Состояние аутентификации
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _error;

  // Геттеры
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  // Инициализация - проверяем существующий токен
  Future<void> initialize() async {
    try {
      _setLoading(true);
      final profile = await _apiService.getProfile();
      _user = profile;
      _isAuthenticated = true;
      _error = null;
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _error = null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Регистрация
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      
      final user = await _apiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      
      _user = user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Вход в систему
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;
      
      final tokens = await _apiService.login(email, password);
      
      // Получаем профиль пользователя
      final profile = await _apiService.getProfile();
      
      _user = profile;
      _isAuthenticated = true;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Выход из системы
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Игнорируем ошибки при logout
    } finally {
      _user = null;
      _isAuthenticated = false;
      _error = null;
      notifyListeners();
    }
  }

  // Обновление профиля
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      
      final updatedProfile = await _apiService.updateProfile(
        name: name,
        phone: phone,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      
      _user = updatedProfile;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Приватные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Проверка, является ли пользователь администратором
  bool get isAdmin {
    if (_user == null) return false;
    return _user!['role'] == 'admin' || _user!['is_admin'] == true;
  }

  // Получение ID пользователя
  String? get userId {
    return _user?['id'];
  }

  // Получение имени пользователя
  String? get userName {
    return _user?['name'];
  }

  // Получение email пользователя
  String? get userEmail {
    return _user?['email'];
  }

  // Получение аватара пользователя
  String? get userAvatar {
    return _user?['avatar_url'];
  }
}

