
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _userId;
  String? _userName;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('user_id');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      // TODO: Implement actual API call
      // For now, simulate successful login
      await Future.delayed(const Duration(seconds: 1));
      
      _token = 'fake_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      _userId = 'user_123';
      _userName = 'Test User';
      _userEmail = email;
      _isAuthenticated = true;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_name', _userName!);
      await prefs.setString('user_email', _userEmail!);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      // TODO: Implement actual API call
      // For now, simulate successful registration
      await Future.delayed(const Duration(seconds: 1));
      
      _token = 'fake_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _userName = name;
      _userEmail = email;
      _isAuthenticated = true;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_name', _userName!);
      await prefs.setString('user_email', _userEmail!);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _isAuthenticated = false;

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');

    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? email}) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('user_name', name);
    if (email != null) await prefs.setString('user_email', email);

    notifyListeners();
  }
}
