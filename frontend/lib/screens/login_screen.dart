import 'package:flutter/material.dart';
import '../services/api.dart';

class LoginScreen extends StatefulWidget {
  final ApiService api;
  const LoginScreen({super.key, required this.api});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _doLogin, child: const Text('Login')),
          Text(_status),
        ]),
      ),
    );
  }

  void _doLogin() async {
    setState(() { _status = '...'; });
    final res = await widget.api.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (res.containsKey('token')) {
      setState(() { _status = 'Login ok, token obtained'; });
      // TODO: save token to secure storage
    } else {
      setState(() { _status = 'Error: ' + (res['error'] ?? 'unknown'); });
    }
  }
}
