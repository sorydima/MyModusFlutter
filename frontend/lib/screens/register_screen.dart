import 'package:flutter/material.dart';
import '../services/api.dart';

class RegisterScreen extends StatefulWidget {
  final ApiService api;
  const RegisterScreen({super.key, required this.api});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _doRegister, child: const Text('Register')),
          Text(_status),
        ]),
      ),
    );
  }

  void _doRegister() async {
    setState(() { _status = '...'; });
    final res = await widget.api.register(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (res['statusCode'] == 201) {
      setState(() { _status = 'Registered successfully'; });
    } else {
      setState(() { _status = 'Error: ' + res['body']; });
    }
  }
}
