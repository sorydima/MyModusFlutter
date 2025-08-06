import 'lib/services/mock_wildberries_service.dart';

void main() async {
  print('Testing Mock Wildberries Service...\n');
  
  try {
    print('📦 Testing fetchMyModusProducts()...');
    final products = await MockWildberriesService.fetchMyModusProducts();
    print('✅ Found ${products.length} products');
    
    if (products.isNotEmpty) {
      print('\n📋 Sample Product:');
      final product = products.first;
      print('Title: ${product.title}');
      print('Price: ${product.price} ₽');
      print('Old Price: ${product.oldPrice} ₽');
      print('Discount: ${product.discount}%');
      print('Image: ${product.image}');
      print('Link: ${product.link}');
    }
    
    print('\n👕 Testing Clothing Category...');
    final clothingProducts = await MockWildberriesService.fetchProductsByCategory('8126');
    print('✅ Found ${clothingProducts.length} clothing products');
    
    print('\n👟 Testing Shoes Category...');
    final shoesProducts = await MockWildberriesService.fetchProductsByCategory('8127');
    print('✅ Found ${shoesProducts.length} shoes products');
    
    print('\n👜 Testing Accessories Category...');
    final accessoriesProducts = await MockWildberriesService.fetchProductsByCategory('8128');
    print('✅ Found ${accessoriesProducts.length} accessories products');
    
    print('\n🏃 Testing Sports Category...');
    final sportsProducts = await MockWildberriesService.fetchProductsByCategory('8129');
    print('✅ Found ${sportsProducts.length} sports products');
    
    print('\n🌐 Web app is running at: http://localhost:8080');
    print('📱 Open your browser to test the app with mock data!');
    
  } catch (e) {
    print('❌ Error testing mock service: $e');
  }
} 