import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Debugging Wildberries API response structure...\n');
  
  try {
    final response = await http.get(
      Uri.parse('https://search.wb.ru/exactmatch/ru/common/v4/search?TestGroup=no_test&TestID=no_test&appType=1&cat=8126&curr=rub&dest=-1257786&filters=xsubject&query=My%20Modus&resultset=catalog&sort=popular&spp=0&suppressSpellcheck=false'),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'application/json',
        'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📋 Full API Response Structure:');
      print(json.encode(data));
      
      print('\n🔍 Top-level keys: ${data.keys.toList()}');
      
      if (data['rs'] != null) {
        print('\n📦 RS structure: ${data['rs'].keys.toList()}');
        if (data['rs']['data'] != null) {
          print('📦 RS.data structure: ${data['rs']['data'].keys.toList()}');
          if (data['rs']['data']['products'] != null) {
            final products = data['rs']['data']['products'] as List;
            print('✅ Found ${products.length} products in rs.data.products');
            
            if (products.isNotEmpty) {
              print('\n📋 Sample Product:');
              final product = products.first;
              print(json.encode(product));
            }
          }
        }
      }
    }
  } catch (e) {
    print('❌ Error: $e');
  }
} 