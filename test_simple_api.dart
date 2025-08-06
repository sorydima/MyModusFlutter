import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing simple Wildberries API query...\n');
  
  try {
    // Try a simpler query without specific filters
    final response = await http.get(
      Uri.parse('https://search.wb.ru/exactmatch/ru/common/v4/search?TestGroup=no_test&TestID=no_test&appType=1&cat=8126&curr=rub&dest=-1257786&query=My%20Modus&resultset=catalog&sort=popular&spp=0'),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'application/json',
        'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('\n📋 Response Structure:');
      print('Keys: ${data.keys.toList()}');
      
      // Try different possible structures
      if (data['data'] != null) {
        print('✅ Found data field');
        print('Data keys: ${data['data'].keys.toList()}');
        
        if (data['data']['products'] != null) {
          final products = data['data']['products'] as List;
          print('✅ Found ${products.length} products in data.products');
        }
      }
      
      if (data['products'] != null) {
        final products = data['products'] as List;
        print('✅ Found ${products.length} products in products');
      }
      
      if (data['rs'] != null) {
        print('RS value: ${data['rs']}');
        if (data['rs'] is Map) {
          print('RS keys: ${data['rs'].keys.toList()}');
        }
      }
      
      // Print full response for debugging
      print('\n📋 Full Response:');
      print(json.encode(data));
    }
  } catch (e) {
    print('❌ Error: $e');
  }
} 