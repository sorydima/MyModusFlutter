import 'package:flutter_test/flutter_test.dart';
import 'package:modus/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('should create Product from JSON', () {
      final json = {
        'title': 'Test Product',
        'price': 1000,
        'oldPrice': 1200,
        'discount': 20,
        'image': 'https://example.com/image.jpg',
        'link': 'https://example.com/product'
      };

      final product = Product.fromJson(json);

      expect(product.title, 'Test Product');
      expect(product.price, 1000);
      expect(product.oldPrice, 1200);
      expect(product.discount, 20);
      expect(product.image, 'https://example.com/image.jpg');
      expect(product.link, 'https://example.com/product');
    });

    test('should handle null values in JSON', () {
      final json = {
        'title': 'Test Product',
        'price': null,
        'oldPrice': null,
        'discount': null,
        'image': null,
        'link': 'https://example.com/product'
      };

      final product = Product.fromJson(json);

      expect(product.title, 'Test Product');
      expect(product.price, null);
      expect(product.oldPrice, null);
      expect(product.discount, null);
      expect(product.image, null);
      expect(product.link, 'https://example.com/product');
    });
  });
} 