import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/ai_chat_provider.dart';
import 'providers/products_provider.dart';
import 'services/notification_service.dart';
import 'screens/main_app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyModusApp());
}

class MyModusApp extends StatelessWidget {
  const MyModusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => AIChatProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: Consumer<ProductsProvider>(
        builder: (context, productsProvider, child) {
          // Инициализируем провайдер товаров
          WidgetsBinding.instance.addPostFrameCallback((_) {
            productsProvider.initialize();
          });
          
          return MaterialApp(
            title: 'MyModus',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFF6B6B),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Inter',
            ),
            home: const MainAppScreen(),
          );
        },
      ),
    );
  }
}
