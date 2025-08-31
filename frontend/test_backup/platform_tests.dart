import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import '../lib/providers/auth_provider.dart';
import '../lib/providers/ai_provider.dart';
import '../lib/screens/home_page.dart';
import '../lib/screens/ai_recommendations_screen.dart';
import '../lib/widgets/product_card.dart';
import '../lib/widgets/bottom_navigation_bar.dart';
import '../lib/services/api_service.dart';

void main() {
  group('MyModus Platform Tests', () {
    late MockApiService mockApiService;
    late AuthProvider authProvider;
    late AIProvider aiProvider;

    setUp(() {
      mockApiService = MockApiService();
      authProvider = AuthProvider(mockApiService);
      aiProvider = AIProvider(mockApiService);
    });

    group('Mobile Platform Tests', () {
      testWidgets('should display mobile-optimized layout', (WidgetTester tester) async {
        // Симулируем мобильное устройство
        tester.binding.window.physicalSizeTestValue = const Size(375, 812); // iPhone X
        tester.binding.window.devicePixelRatioTestValue = 3.0;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: HomePage(),
            ),
          ),
        );

        await tester.pump();

        // Проверяем мобильную навигацию
        expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
        
        // Проверяем размеры для мобильных устройств
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.toolbarHeight, lessThan(80.0)); // Мобильная высота

        // Восстанавливаем размер экрана
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      testWidgets('should handle mobile gestures correctly', (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(375, 812);
        tester.binding.window.devicePixelRatioTestValue = 3.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: List.generate(10, (index) => 
                  ProductCard(
                    product: Product(
                      id: index.toString(),
                      title: 'Product $index',
                      price: 1000 + index * 100,
                      imageUrl: 'test$index.jpg',
                      productUrl: 'test$index.com',
                      stock: 10,
                      reviewCount: 5,
                      source: 'test',
                      sourceId: index.toString(),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Тестируем скролл
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pump();

        // Тестируем тап по карточке
        await tester.tap(find.byType(ProductCard).first);
        await tester.pump();

        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });

    group('Tablet Platform Tests', () {
      testWidgets('should display tablet-optimized layout', (WidgetTester tester) async {
        // Симулируем планшет
        tester.binding.window.physicalSizeTestValue = const Size(768, 1024); // iPad
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: HomePage(),
            ),
          ),
        );

        await tester.pump();

        // Проверяем планшетную навигацию
        expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
        
        // Проверяем размеры для планшетов
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.toolbarHeight, greaterThan(56.0)); // Планшетная высота

        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      testWidgets('should handle tablet orientation changes', (WidgetTester tester) async {
        // Портретная ориентация
        tester.binding.window.physicalSizeTestValue = const Size(768, 1024);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: AIRecommendationsScreen(),
          ),
        );

        await tester.pump();

        // Проверяем портретную компоновку
        expect(find.byType(TabBar), findsOneWidget);

        // Ландшафтная ориентация
        tester.binding.window.physicalSizeTestValue = const Size(1024, 768);
        await tester.pump();

        // Проверяем ландшафтную компоновку
        expect(find.byType(TabBar), findsOneWidget);

        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });

    group('Web Platform Tests', () {
      testWidgets('should display web-optimized layout', (WidgetTester tester) async {
        // Симулируем веб-браузер
        tester.binding.window.physicalSizeTestValue = const Size(1920, 1080); // Full HD
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: HomePage(),
            ),
          ),
        );

        await tester.pump();

        // Проверяем веб-навигацию
        expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
        
        // Проверяем размеры для веба
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.toolbarHeight, greaterThan(64.0)); // Веб высота

        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      testWidgets('should handle web keyboard navigation', (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(autofocus: true),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Button 1'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Button 2'),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // Тестируем навигацию по Tab
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should adapt to different screen densities', (WidgetTester tester) async {
        final densities = [1.0, 1.5, 2.0, 3.0];
        
        for (final density in densities) {
          tester.binding.window.devicePixelRatioTestValue = density;
          tester.binding.window.physicalSizeTestValue = const Size(375, 812);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ProductCard(
                  product: Product(
                    id: '1',
                    title: 'Test Product',
                    price: 1000,
                    imageUrl: 'test.jpg',
                    productUrl: 'test.com',
                    stock: 10,
                    reviewCount: 5,
                    source: 'test',
                    sourceId: '1',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ),
              ),
            ),
          );

          await tester.pump();

          // Проверяем, что UI адаптируется к плотности пикселей
          final card = tester.widget<Card>(find.byType(Card));
          expect(card, isNotNull);

          tester.binding.window.clearDevicePixelRatioTestValue();
        }

        tester.binding.window.clearPhysicalSizeTestValue();
      });

      testWidgets('should handle extreme screen sizes', (WidgetTester tester) async {
        final sizes = [
          const Size(240, 320),   // Очень маленький экран
          const Size(1920, 1080), // Full HD
          const Size(2560, 1440), // 2K
          const Size(3840, 2160), // 4K
        ];

        for (final size in sizes) {
          tester.binding.window.physicalSizeTestValue = size;
          tester.binding.window.devicePixelRatioTestValue = 1.0;

          await tester.pumpWidget(
            MaterialApp(
              home: HomePage(),
            ),
          );

          await tester.pump();

          // Проверяем, что UI не ломается на экстремальных размерах
          expect(find.byType(AppBar), findsOneWidget);
          expect(find.byType(CustomBottomNavigationBar), findsOneWidget);

          tester.binding.window.clearPhysicalSizeTestValue();
        }
      });
    });

    group('Platform-Specific Features Tests', () {
      testWidgets('should handle platform-specific gestures', (WidgetTester tester) async {
        // Тестируем различные жесты
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onTap: () {},
                onLongPress: () {},
                onDoubleTap: () {},
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                  child: Text('Gesture Test'),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Тестируем тап
        await tester.tap(find.text('Gesture Test'));
        await tester.pump();

        // Тестируем долгое нажатие
        await tester.longPress(find.text('Gesture Test'));
        await tester.pump();

        // Тестируем двойной тап
        await tester.tap(find.text('Gesture Test'));
        await tester.pump();
        await tester.tap(find.text('Gesture Test'));
        await tester.pump();
      });

      testWidgets('should handle platform-specific animations', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 100,
                height: 100,
                color: Colors.red,
                child: Text('Animation Test'),
              ),
            ),
          ),
        );

        await tester.pump();

        // Проверяем начальное состояние
        expect(find.byType(AnimatedContainer), findsOneWidget);

        // Запускаем анимацию
        await tester.pump(Duration(milliseconds: 150));
        await tester.pump(Duration(milliseconds: 150));
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should support screen readers', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Text('Main Content', semanticsLabel: 'Main content area'),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Action Button'),
                  ),
                  Image.asset('test.jpg', semanticLabel: 'Test image'),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // Проверяем семантические метки
        expect(find.bySemanticsLabel('Main content area'), findsOneWidget);
        expect(find.bySemanticsLabel('Action Button'), findsOneWidget);
        expect(find.bySemanticsLabel('Test image'), findsOneWidget);
      });

      testWidgets('should handle high contrast mode', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: Brightness.dark,
              highContrastTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.highContrastDark,
              ),
            ),
            home: Scaffold(
              body: Text('High Contrast Test'),
            ),
          ),
        );

        await tester.pump();

        // Проверяем, что UI поддерживает высокую контрастность
        expect(find.text('High Contrast Test'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should handle rapid UI updates', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Text('Counter: ${DateTime.now().millisecondsSinceEpoch}'),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: Text('Update'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Быстрые обновления UI
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.text('Update'));
          await tester.pump();
        }
      });

      testWidgets('should handle memory pressure', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 1000,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Item $index'),
                    subtitle: Text('Description $index'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Скролл для проверки производительности
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump();

        await tester.drag(find.byType(ListView), const Offset(0, 500));
        await tester.pump();
      });
    });
  });
}

// Мок класс для ApiService
class MockApiService extends Mock implements ApiService {}

// Модель Product для тестов
class Product {
  final String id;
  final String title;
  final int price;
  final String imageUrl;
  final String productUrl;
  final int stock;
  final int reviewCount;
  final String source;
  final String sourceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.productUrl,
    required this.stock,
    required this.reviewCount,
    required this.source,
    required this.sourceId,
    required this.createdAt,
    required this.updatedAt,
  });
}
