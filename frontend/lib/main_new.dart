
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/cache_service.dart';
import 'screens/auth_screen.dart';
import 'screens/product_feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const backendUrl = 'http://localhost:8080'; // update to your backend url

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Modus',
      home: const HomeRouter(),
    );
  }
}

class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple home: if not logged - go to auth, else show products
    return Scaffold(
      appBar: AppBar(title: const Text('My Modus')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen(backendUrl: MyApp.backendUrl))),
            ),
            ElevatedButton(
              child: const Text('Products'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFeedScreen(backendUrl: MyApp.backendUrl))),
            ),
          ],
        ),
      ),
    );
  }
}
