
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final String backendUrl;
  const AuthScreen({super.key, required this.backendUrl});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() { _loading = true; });
    final auth = AuthService(backendUrl: widget.backendUrl);
    final ok = await auth.login(_email.text.trim(), _pass.text.trim());
    if (ok) {
      final access = await auth.getAccessToken();
      // refresh token is stored by AuthService
      if (access != null) {
        await ref.read(authProvider.notifier).setTokens(access, '');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text('Login')),
          ],
        ),
      ),
    );
  }
}
