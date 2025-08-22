import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../lib/providers/auth_provider.dart';
import '../lib/providers/ai_provider.dart';
import '../lib/screens/home_page.dart';
import '../lib/screens/ai_recommendations_screen.dart';
import '../lib/widgets/product_card.dart';
import '../lib/widgets/bottom_navigation_bar.dart';
import '../lib/widgets/category_list.dart';
import '../lib/models/product_model.dart';
import '../lib/services/api_service.dart';

// Генерируем моки
@GenerateMocks([ApiService])
import 'widget_tests.mocks.dart';

void main() {
  group('MyModus Widget Tests', () {
    late MockApiService mockApiService;
    late AuthProvider authProvider;
    late AIProvider aiProvider;

    setUp(() {
      mockApiService = MockApiService();
      authProvider = AuthProvider(mockApiService);
      aiProvider = AIProvider(mockApiService);
    });

    group('ProductCard Widget', () {
      testWidgets('should display product information correctly', (WidgetTester tester) async {
        final product = Product(
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
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: product),
            ),
          ),
        );

        expect(find.text('Test Product'), findsOneWidget);
        expect(find.text('1000 ₽'), findsOneWidget);
        expect(find.text('5 отзывов'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('should handle tap events', (WidgetTester tester) async {
        final product = Product(
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
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: product),
            ),
          ),
        );

        await tester.tap(find.byType(Card));
        await tester.pump();
      });
    });

    group('BottomNavigationBar Widget', () {
      testWidgets('should display all navigation items', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: CustomBottomNavigationBar(
                currentIndex: 0,
                onTap: (index) {},
              ),
            ),
          ),
        );

        expect(find.text('Главная'), findsOneWidget);
        expect(find.text('Каталог'), findsOneWidget);
        expect(find.text('Соцсеть'), findsOneWidget);
        expect(find.text('Профиль'), findsOneWidget);
      });

      testWidgets('should handle navigation taps', (WidgetTester tester) async {
        int tappedIndex = -1;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: CustomBottomNavigationBar(
                currentIndex: 0,
                onTap: (index) => tappedIndex = index,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Каталог'));
        await tester.pump();

        expect(tappedIndex, equals(1));
      });
    });

    group('CategoryList Widget', () {
      testWidgets('should display categories correctly', (WidgetTester tester) async {
        final categories = ['Одежда', 'Обувь', 'Аксессуары', 'Косметика'];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryList(
                categories: categories,
                selectedCategory: 'Одежда',
                onCategorySelected: (category) {},
              ),
            ),
          ),
        );

        for (final category in categories) {
          expect(find.text(category), findsOneWidget);
        }
      });

      testWidgets('should handle category selection', (WidgetTester tester) async {
        final categories = ['Одежда', 'Обувь', 'Аксессуары'];
        String? selectedCategory;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryList(
                categories: categories,
                selectedCategory: 'Одежда',
                onCategorySelected: (category) => selectedCategory = category,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Обувь'));
        await tester.pump();

        expect(selectedCategory, equals('Обувь'));
      });
    });

    group('HomePage Widget', () {
      testWidgets('should display main content sections', (WidgetTester tester) async {
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

        expect(find.text('MyModus'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
      });
    });

    group('AIRecommendationsScreen Widget', () {
      testWidgets('should display tabs correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: AIRecommendationsScreen(),
            ),
          ),
        );

        expect(find.text('Персональные'), findsOneWidget);
        expect(find.text('Похожие'), findsOneWidget);
        expect(find.text('Новым пользователям'), findsOneWidget);
      });

      testWidgets('should handle tab switching', (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: AIRecommendationsScreen(),
            ),
          ),
        );

        await tester.tap(find.text('Похожие'));
        await tester.pump();

        expect(find.text('Похожие товары'), findsOneWidget);
      });
    });

    group('Loading States', () {
      testWidgets('should show loading indicators', (WidgetTester tester) async {
        // Устанавливаем состояние загрузки
        aiProvider.setLoading(true);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: AIRecommendationsScreen(),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Error States', () {
      testWidgets('should display error messages', (WidgetTester tester) async {
        // Устанавливаем ошибку
        aiProvider.setError('Произошла ошибка при загрузке');

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
            ],
            child: MaterialApp(
              home: AIRecommendationsScreen(),
            ),
          ),
        );

        expect(find.text('Произошла ошибка при загрузке'), findsOneWidget);
        expect(find.text('Повторить'), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to different screen sizes', (WidgetTester tester) async {
        // Тестируем на маленьком экране
        tester.binding.window.physicalSizeTestValue = const Size(320, 568);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

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

        // Восстанавливаем размер экрана
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });
  });
}
