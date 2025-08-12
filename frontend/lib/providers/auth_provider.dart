
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthState {
  final bool loggedIn;
  final String? accessToken;
  AuthState({required this.loggedIn, this.accessToken});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(): super(AuthState(loggedIn: false));

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      state = AuthState(loggedIn: true, accessToken: token);
    }
  }

  Future<void> setTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
    state = AuthState(loggedIn: true, accessToken: access);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    state = AuthState(loggedIn: false);
  }
}
