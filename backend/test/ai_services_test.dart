import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import '../lib/services/ai_recommendations_service.dart';
import '../lib/services/ai_content_generation_service.dart';
import '../lib/services/ai_style_analysis_service.dart';
import '../lib/models.dart';

// Генерируем моки
@GenerateMocks([http.Client])
import 'ai_services_test.mocks.dart';

void main() {
  group('AI Services Tests', () {
    group('AIRecommendationsService', () {
      late AIRecommendationsService service;
      late MockClient mockClient;

      setUp(() {
        mockClient = MockClient();
        service = AIRecommendationsService(
          apiKey: 'test_key',
          baseUrl: 'https://api.openai.com/v1',
        );
      });

      test('should generate personal recommendations successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "AI analysis"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        final userHistory = [
          Product(
            id: '1',
            title: 'Test Product 1',
            price: 1000,
            imageUrl: 'test1.jpg',
            productUrl: 'test1.com',
            stock: 10,
            reviewCount: 5,
            source: 'test',
            sourceId: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final availableProducts = [
          Product(
            id: '2',
            title: 'Test Product 2',
            price: 1500,
            imageUrl: 'test2.jpg',
            productUrl: 'test2.com',
            stock: 15,
            reviewCount: 8,
            source: 'test',
            sourceId: '2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final result = await service.generatePersonalRecommendations(
          userId: 'user1',
          userHistory: userHistory,
          availableProducts: availableProducts,
          recentlyViewed: [],
        );

        // Assert
        expect(result, isA<List<ProductRecommendation>>());
        expect(result.isNotEmpty, true);
      });

      test('should generate similar product recommendations', () async {
        // Arrange
        final baseProduct = Product(
          id: '1',
          title: 'Base Product',
          price: 1000,
          imageUrl: 'base.jpg',
          productUrl: 'base.com',
          stock: 10,
          reviewCount: 5,
          source: 'test',
          sourceId: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final availableProducts = [
          Product(
            id: '2',
            title: 'Similar Product',
            price: 1200,
            imageUrl: 'similar.jpg',
            productUrl: 'similar.com',
            stock: 15,
            reviewCount: 8,
            source: 'test',
            sourceId: '2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final result = await service.generateSimilarProductRecommendations(
          baseProduct: baseProduct,
          availableProducts: availableProducts,
        );

        // Assert
        expect(result, isA<List<ProductRecommendation>>());
        expect(result.isNotEmpty, true);
      });

      test('should generate new user recommendations', () async {
        // Arrange
        final availableProducts = [
          Product(
            id: '1',
            title: 'Popular Product',
            price: 1000,
            imageUrl: 'popular.jpg',
            productUrl: 'popular.com',
            stock: 10,
            rating: 4.5,
            reviewCount: 20,
            source: 'test',
            sourceId: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final result = await service.generateNewUserRecommendations(
          availableProducts: availableProducts,
          userLocation: 'Moscow',
        );

        // Assert
        expect(result, isA<List<ProductRecommendation>>());
        expect(result.isNotEmpty, true);
      });
    });

    group('AIContentGenerationService', () {
      late AIContentGenerationService service;
      late MockClient mockClient;

      setUp(() {
        mockClient = MockClient();
        service = AIContentGenerationService(
          apiKey: 'test_key',
          baseUrl: 'https://api.openai.com/v1',
        );
      });

      test('should generate product description successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "Amazing product description"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        final specifications = {
          'material': 'cotton',
          'size': 'M',
          'color': 'blue',
        };

        // Act
        final result = await service.generateProductDescription(
          productName: 'Test Product',
          category: 'clothing',
          specifications: specifications,
          brand: 'TestBrand',
          style: 'casual',
        );

        // Assert
        expect(result, isA<ProductDescription>());
        expect(result.content, isNotEmpty);
        expect(result.language, 'ru');
        expect(result.wordCount, greaterThan(0));
      });

      test('should generate product hashtags successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "#fashion #style #trending"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.generateProductHashtags(
          productName: 'Test Product',
          category: 'clothing',
          brand: 'TestBrand',
          hashtagCount: 5,
        );

        // Assert
        expect(result, isA<List<String>>());
        expect(result.isNotEmpty, true);
        expect(result.length, lessThanOrEqualTo(5));
      });

      test('should generate social media post successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "Amazing post with #hashtags"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.generateSocialMediaPost(
          productName: 'Test Product',
          category: 'clothing',
          productDescription: 'Test description',
          platform: 'instagram',
          tone: 'casual',
        );

        // Assert
        expect(result, isA<SocialMediaPost>());
        expect(result.caption, isNotEmpty);
        expect(result.hashtags, isNotEmpty);
        expect(result.platform, 'instagram');
      });

      test('should generate SEO optimized title successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "SEO Optimized Title"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.generateSEOOptimizedTitle(
          productName: 'Test Product',
          category: 'clothing',
          brand: 'TestBrand',
          keyFeatures: 'comfortable, stylish',
        );

        // Assert
        expect(result, isA<String>());
        expect(result.isNotEmpty, true);
      });

      test('should generate product review successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "Great product review"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.generateProductReview(
          productName: 'Test Product',
          category: 'clothing',
          rating: 5,
          brand: 'TestBrand',
          style: 'casual',
        );

        // Assert
        expect(result, isA<ProductReview>());
        expect(result.content, isNotEmpty);
        expect(result.rating, 5);
        expect(result.isAIGenerated, true);
      });
    });

    group('AIStyleAnalysisService', () {
      late AIStyleAnalysisService service;
      late MockClient mockClient;

      setUp(() {
        mockClient = MockClient();
        service = AIStyleAnalysisService(
          apiKey: 'test_key',
          baseUrl: 'https://api.openai.com/v1',
        );
      });

      test('should analyze user style successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "Style analysis insights"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        final purchaseHistory = [
          Product(
            id: '1',
            title: 'Casual T-Shirt',
            price: 1000,
            imageUrl: 'tshirt.jpg',
            productUrl: 'tshirt.com',
            stock: 10,
            reviewCount: 5,
            source: 'test',
            sourceId: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final result = await service.analyzeUserStyle(
          userId: 'user1',
          purchaseHistory: purchaseHistory,
          wishlist: [],
          recentlyViewed: [],
        );

        // Assert
        expect(result, isA<UserStyleProfile>());
        expect(result.userId, 'user1');
        expect(result.primaryStyle, isNotEmpty);
        expect(result.colorPalette, isNotEmpty);
        expect(result.styleConfidence, greaterThan(0.0));
      });

      test('should analyze style compatibility successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "Compatibility score: 0.8"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        final productAttributes = {
          'title': 'Test Product',
          'category': 'clothing',
          'brand': 'TestBrand',
          'price': 1000,
          'style': 'casual',
          'color': 'blue',
        };

        // Act
        final result = await service.analyzeStyleCompatibility(
          userStyle: 'casual',
          productStyle: 'casual',
          productAttributes: productAttributes,
        );

        // Assert
        expect(result, isA<StyleCompatibility>());
        expect(result.userStyle, 'casual');
        expect(result.productStyle, 'casual');
        expect(result.score, greaterThan(0.0));
        expect(result.styleTips, isNotEmpty);
      });

      test('should generate style recommendations successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "Style compatibility score: 0.7"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        final userStyleProfile = UserStyleProfile(
          userId: 'user1',
          primaryStyle: 'casual',
          secondaryStyles: ['street', 'modern'],
          colorPalette: ['black', 'white', 'blue'],
          brandPreferences: ['TestBrand'],
          priceRange: PriceRange(min: 500, max: 2000, average: 1000),
          occasionPreferences: ['everyday', 'work'],
          seasonPreferences: ['spring', 'autumn'],
          styleConfidence: 0.8,
          aiInsights: 'Style insights',
          lastUpdated: DateTime.now(),
        );

        final availableProducts = [
          Product(
            id: '1',
            title: 'Casual Product',
            price: 1000,
            imageUrl: 'product.jpg',
            productUrl: 'product.com',
            stock: 10,
            reviewCount: 5,
            source: 'test',
            sourceId: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final result = await service.generateStyleRecommendations(
          userStyleProfile: userStyleProfile,
          availableProducts: availableProducts,
          occasion: 'everyday',
          season: 'spring',
        );

        // Assert
        expect(result, isA<List<StyleRecommendation>>());
        expect(result.isNotEmpty, true);
      });

      test('should analyze style trends successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "Trend analysis for spring"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.analyzeStyleTrends(
          category: 'clothing',
          season: 'spring',
          location: 'Moscow',
        );

        // Assert
        expect(result, isA<StyleTrends>());
        expect(result.category, 'clothing');
        expect(result.season, 'spring');
        expect(result.trends, isNotEmpty);
        expect(result.colors, isNotEmpty);
        expect(result.styles, isNotEmpty);
      });

      test('should create capsule wardrobe successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"choices": [{"message": {"content": "Capsule wardrobe items"}}]}',
          200,
        );
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        final userStyleProfile = UserStyleProfile(
          userId: 'user1',
          primaryStyle: 'casual',
          secondaryStyles: ['street', 'modern'],
          colorPalette: ['black', 'white', 'blue'],
          brandPreferences: ['TestBrand'],
          priceRange: PriceRange(min: 500, max: 2000, average: 1000),
          occasionPreferences: ['everyday', 'work'],
          seasonPreferences: ['spring', 'autumn'],
          styleConfidence: 0.8,
          aiInsights: 'Style insights',
          lastUpdated: DateTime.now(),
        );

        // Act
        final result = await service.createCapsuleWardrobe(
          userStyleProfile: userStyleProfile,
          occasion: 'everyday',
          season: 'spring',
          itemCount: 5,
        );

        // Assert
        expect(result, isA<CapsuleWardrobe>());
        expect(result.userId, 'user1');
        expect(result.occasion, 'everyday');
        expect(result.season, 'spring');
        expect(result.items, isNotEmpty);
      });
    });

    group('Fallback Generation Tests', () {
      test('should generate fallback product description', () async {
        final service = AIContentGenerationService();
        final result = service._generateFallbackDescription(
          'Test Product',
          'clothing',
          'ru',
        );

        expect(result.content, contains('Test Product'));
        expect(result.content, contains('clothing'));
        expect(result.language, 'ru');
      });

      test('should generate fallback hashtags', () async {
        final service = AIContentGenerationService();
        final result = service._generateFallbackHashtags(
          'clothing',
          'TestBrand',
          5,
        );

        expect(result, isA<List<String>>());
        expect(result.contains('#clothing'), true);
        expect(result.contains('#TestBrand'), true);
        expect(result.contains('#MyModusLook'), true);
      });

      test('should generate fallback style profile', () async {
        final service = AIStyleAnalysisService();
        final result = service._generateFallbackStyleProfile('user1', 'ru');

        expect(result.userId, 'user1');
        expect(result.primaryStyle, 'casual');
        expect(result.colorPalette, isNotEmpty);
        expect(result.styleConfidence, 0.7);
      });
    });

    group('Utility Methods Tests', () {
      test('should extract style from product', () {
        final service = AIStyleAnalysisService();
        final product = Product(
          id: '1',
          title: 'Casual T-Shirt',
          price: 1000,
          imageUrl: 'tshirt.jpg',
          productUrl: 'tshirt.com',
          stock: 10,
          reviewCount: 5,
          source: 'test',
          sourceId: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final style = service._extractStyleFromProduct(product);
        expect(style, 'casual');
      });

      test('should extract color from product', () {
        final service = AIStyleAnalysisService();
        final product = Product(
          id: '1',
          title: 'Blue Jeans',
          price: 1000,
          imageUrl: 'jeans.jpg',
          productUrl: 'jeans.com',
          stock: 10,
          reviewCount: 5,
          source: 'test',
          sourceId: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final color = service._extractColorFromProduct(product);
        expect(color, 'blue');
      });

      test('should calculate style confidence', () {
        final service = AIStyleAnalysisService();
        final confidence = service._calculateStyleConfidence(10, 3);
        
        expect(confidence, greaterThan(0.0));
        expect(confidence, lessThanOrEqualTo(1.0));
      });

      test('should get top items', () {
        final service = AIStyleAnalysisService();
        final items = {'a': 5, 'b': 3, 'c': 7, 'd': 1};
        final topItems = service._getTopItems(items, 2);
        
        expect(topItems.length, 2);
        expect(topItems.first, 'c'); // highest count
        expect(topItems.last, 'a'); // second highest
      });
    });
  });
}
