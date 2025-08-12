import 'package:flutter/material.dart';
import 'services/api.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/feed_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final api = ApiService('http://localhost:8080');
    return MaterialApp(
      title: 'MyModus',
      home: Home(api: api),
    );
  }
}

class Home extends StatelessWidget {
  final ApiService api;
  const Home({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyModus')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FeedScreen(api: api))),
              child: const Text('Feed')),
          const SizedBox(height: 8),
          ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(api: api))),
              child: const Text('Login')),
          const SizedBox(height: 8),
          ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(api: api))),
              child: const Text('Register')),
        ]),
      ),
    );
  }
}
