import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final int categoryIndex;

  const ProductGrid({
    super.key,
    required this.categoryIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Тестовые данные товаров
    final products = [
      {
        'id': '1',
        'title': 'Nike Air Max 270',
        'price': 12990,
        'oldPrice': 15990,
        'discount': 19,
        'imageUrl': 'https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=Nike+Air+Max+270',
        'brand': 'Nike',
        'rating': 4.8,
        'reviewCount': 127,
      },
      {
        'id': '2',
        'title': 'Adidas Ultraboost 22',
        'price': 18990,
        'oldPrice': null,
        'discount': null,
        'imageUrl': 'https://via.placeholder.com/400x400/4ECDC4/FFFFFF?text=Adidas+Ultraboost+22',
        'brand': 'Adidas',
        'rating': 4.9,
        'reviewCount': 89,
      },
      {
        'id': '3',
        'title': 'Levi\'s 501 Original Jeans',
        'price': 7990,
        'oldPrice': 9990,
        'discount': 20,
        'imageUrl': 'https://via.placeholder.com/400x400/45B7D1/FFFFFF?text=Levis+501+Jeans',
        'brand': 'Levi\'s',
        'rating': 4.6,
        'reviewCount': 203,
      },
      {
        'id': '4',
        'title': 'Apple Watch Series 8',
        'price': 45990,
        'oldPrice': 49990,
        'discount': 8,
        'imageUrl': 'https://via.placeholder.com/400x400/96CEB4/FFFFFF?text=Apple+Watch+Series+8',
        'brand': 'Apple',
        'rating': 4.7,
        'reviewCount': 156,
      },
      {
        'id': '5',
        'title': 'Samsung Galaxy S23',
        'price': 89990,
        'oldPrice': 99990,
        'discount': 10,
        'imageUrl': 'https://via.placeholder.com/400x400/FFE66D/000000?text=Samsung+S23',
        'brand': 'Samsung',
        'rating': 4.5,
        'reviewCount': 89,
      },
      {
        'id': '6',
        'title': 'Converse Chuck Taylor',
        'price': 5990,
        'oldPrice': 7990,
        'discount': 25,
        'imageUrl': 'https://via.placeholder.com/400x400/FF6B9D/FFFFFF?text=Converse+Chuck',
        'brand': 'Converse',
        'rating': 4.4,
        'reviewCount': 312,
      },
    ];

    // Фильтрация по категории
    List<Map<String, dynamic>> filteredProducts = products;
    if (categoryIndex > 0) {
      final categoryNames = ['Все', 'Одежда', 'Обувь', 'Аксессуары'];
      final categoryName = categoryNames[categoryIndex];
      
      if (categoryName == 'Обувь') {
        filteredProducts = products.where((p) => 
          p['brand'] == 'Nike' || p['brand'] == 'Adidas' || p['brand'] == 'Converse'
        ).toList();
      } else if (categoryName == 'Одежда') {
        filteredProducts = products.where((p) => p['brand'] == 'Levi\'s').toList();
      } else if (categoryName == 'Аксессуары') {
        filteredProducts = products.where((p) => 
          p['brand'] == 'Apple' || p['brand'] == 'Samsung'
        ).toList();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return ProductCard(
            id: product['id'],
            title: product['title'],
            price: product['price'],
            oldPrice: product['oldPrice'],
            discount: product['discount'],
            imageUrl: product['imageUrl'],
            brand: product['brand'],
            rating: product['rating'],
            reviewCount: product['reviewCount'],
          );
        },
      ),
    );
  }
}
