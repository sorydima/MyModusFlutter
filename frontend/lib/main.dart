import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'providers/ipfs_provider.dart';
import 'services/ipfs_service.dart';
import 'screens/auth_screen.dart';
import 'screens/main_app_screen.dart';

void main() async {
  // Убеждаемся, что Flutter инициализирован
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
        ChangeNotifierProvider(
          create: (_) => IPFSProvider(
            ipfsService: IPFSService(
              baseUrl: 'http://localhost:3000', // URL вашего backend
            ),
          ),
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Инициализируем приложение при первом запуске
          if (!appProvider.isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              appProvider.initialize();
            });
          }
          
          return MaterialApp(
            title: 'MyModus',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6750A4),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Inter',
            ),
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Показываем экран загрузки, пока приложение инициализируется
        if (!appProvider.isInitialized) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Логотип или иконка приложения
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'MyModus',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Мода и стиль в ваших руках',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Инициализация...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Если есть ошибки, показываем экран ошибки
        if (appProvider.hasErrors) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ошибка инициализации',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Не удалось запустить приложение. Проверьте подключение к интернету и попробуйте снова.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        appProvider.clearAllErrors();
                        appProvider.initialize();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторить'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        // Приложение готово, показываем основной интерфейс
        return const MyModusAppContent();
      },
    );
  }
}

class MyModusAppContent extends StatelessWidget {
  const MyModusAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Проверяем аутентификацию
        if (appProvider.authProvider.isAuthenticated) {
          // Пользователь аутентифицирован, показываем основное приложение
          return const MainAppScreen();
        } else {
          // Пользователь не аутентифицирован, показываем экран входа
          return const AuthScreen();
        }
      },
    );
  }
}
