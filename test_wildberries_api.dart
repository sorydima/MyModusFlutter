import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing Wildberries API integration...\n');
  
  try {
    // Test the Wildberries API endpoint
    final response = await http.get(
      Uri.parse('https://search.wb.ru/exactmatch/ru/common/v4/search?TestGroup=no_test&TestID=no_test&appType=1&cat=8126&curr=rub&dest=-1257786&filters=xsubject&query=My%20Modus&resultset=catalog&sort=popular&spp=0&suppressSpellcheck=false'),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'application/json',
        'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('\n✅ API Response received successfully!');
      
      if (data['data'] != null && data['data']['products'] != null) {
        final products = data['data']['products'] as List;
        print('📦 Found ${products.length} products');
        
        if (products.isNotEmpty) {
          print('\n📋 Sample Product Data:');
          final sampleProduct = products.first;
          print('ID: ${sampleProduct['id']}');
          print('Name: ${sampleProduct['name']}');
          print('Price: ${sampleProduct['priceU']} kopeks');
          print('Sale Price: ${sampleProduct['salePriceU']} kopeks');
          print('Brand: ${sampleProduct['brand']}');
          
          // Test image URL generation
          final imageId = sampleProduct['id'];
          final imageUrl = "https://images.wbstatic.net/c246x328/new/$imageId-1.jpg";
          print('Image URL: $imageUrl');
          
          // Test product link generation
          final productLink = "https://www.wildberries.ru/catalog/$imageId/detail.aspx";
          print('Product Link: $productLink');
        }
      } else {
        print('⚠️ No products found in response');
        print('Response structure: ${data.keys.toList()}');
      }
    } else {
      print('❌ API request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('❌ Error testing API: $e');
  }
  
  print('\n🌐 Web app should be available at: http://localhost:8080');
  print('📱 Open your browser and navigate to the URL above to test the app!');
} 