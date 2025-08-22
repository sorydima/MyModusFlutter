import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIColorMatcherTester {
  static const String baseUrl = 'http://localhost:8080/api/color-matcher';
  
  static Future<void> main() async {
    print('🎨 Testing AI Color Matcher API...\n');
    
    try {
      await testAnalyzePhotoColors();
      await testGeneratePersonalPalette();
      await testFindHarmoniousColors();
      await testGetColorTheory();
      await testGetColorRecommendations();
      await testGetOutfitRecommendations();
      await testAnalyzeColorTrends();
      await testGetSeasonalPalettes();
      await testSaveColorPalette();
      await testGetUserPalettes();
      await testGetUserColorHistory();
      await testGetUserColorStats();
      await testExportColorPalette();
      await testImportColorPalette();
      await testUpdateUserPreferences();
      await testGetUserPreferences();
      
      print('\n✅ All AI Color Matcher tests completed successfully!');
    } catch (e) {
      print('\n❌ Test failed: $e');
    }
  }

  // Тест анализа цветов на фото
  static Future<void> testAnalyzePhotoColors() async {
    print('📸 Testing analyze photo colors...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/analyze-photo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'imageUrl': 'https://example.com/test-photo.jpg',
        'userId': 'test_user_123',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Photo analysis successful: ${data['success']}');
      if (data['dominantColors'] != null) {
        print('   Found ${data['dominantColors'].length} dominant colors');
      }
    } else {
      print('❌ Photo analysis failed: ${response.statusCode}');
    }
  }

  // Тест генерации персональной палитры
  static Future<void> testGeneratePersonalPalette() async {
    print('🎨 Testing generate personal palette...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/generate-palette'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': 'test_user_123',
        'preferredColors': ['#FF6B6B', '#4ECDC4'],
        'skinTone': 'warm',
        'hairColor': 'brown',
        'eyeColor': 'brown',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Personal palette generation successful: ${data['success']}');
      if (data['personalPalette'] != null) {
        print('   Generated ${data['personalPalette'].length} colors');
      }
    } else {
      print('❌ Personal palette generation failed: ${response.statusCode}');
    }
  }

  // Тест поиска гармоничных цветов
  static Future<void> testFindHarmoniousColors() async {
    print('🔗 Testing find harmonious colors...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/harmonious-colors?baseColor=%23FF6B6B&harmonyType=complementary&count=5'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Harmonious colors search successful: ${data['success']}');
      if (data['harmoniousColors'] != null) {
        print('   Found ${data['harmoniousColors'].length} harmonious colors');
      }
    } else {
      print('❌ Harmonious colors search failed: ${response.statusCode}');
    }
  }

  // Тест получения теории цвета
  static Future<void> testGetColorTheory() async {
    print('📚 Testing get color theory...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/color-theory/complementary'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Color theory retrieval successful: ${data['success']}');
      if (data['theory'] != null) {
        print('   Theory: ${data['theory']['name']}');
      }
    } else {
      print('❌ Color theory retrieval failed: ${response.statusCode}');
    }
  }

  // Тест получения цветовых рекомендаций
  static Future<void> testGetColorRecommendations() async {
    print('💡 Testing get color recommendations...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations/test_user_123?occasion=casual&season=summer'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Color recommendations retrieval successful: ${data['success']}');
      if (data['recommendations'] != null) {
        print('   Found ${data['recommendations'].length} recommendations');
      }
    } else {
      print('❌ Color recommendations retrieval failed: ${response.statusCode}');
    }
  }

  // Тест получения рекомендаций для образов
  static Future<void> testGetOutfitRecommendations() async {
    print('👗 Testing get outfit recommendations...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/outfit-recommendations/test_user_123?occasion=formal&season=winter'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Outfit recommendations retrieval successful: ${data['success']}');
      if (data['recommendations'] != null) {
        print('   Found ${data['recommendations'].length} outfit recommendations');
      }
    } else {
      print('❌ Outfit recommendations retrieval failed: ${response.statusCode}');
    }
  }

  // Тест анализа цветовых трендов
  static Future<void> testAnalyzeColorTrends() async {
    print('📊 Testing analyze color trends...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/color-trends?category=dresses&season=summer&limit=10'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Color trends analysis successful: ${data['success']}');
      if (data['colorTrends'] != null) {
        print('   Found ${data['colorTrends'].length} color trends');
      }
    } else {
      print('❌ Color trends analysis failed: ${response.statusCode}');
    }
  }

  // Тест получения сезонных палитр
  static Future<void> testGetSeasonalPalettes() async {
    print('🌸 Testing get seasonal palettes...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/seasonal-palettes?season=spring'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Seasonal palettes retrieval successful: ${data['success']}');
      if (data['seasonalPalettes'] != null) {
        print('   Found ${data['seasonalPalettes'].length} seasonal palettes');
      }
    } else {
      print('❌ Seasonal palettes retrieval failed: ${response.statusCode}');
    }
  }

  // Тест сохранения цветовой палитры
  static Future<void> testSaveColorPalette() async {
    print('💾 Testing save color palette...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/save-palette'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': 'test_user_123',
        'name': 'Test Palette',
        'colors': ['#FF6B6B', '#4ECDC4', '#45B7D1'],
        'description': 'A test color palette',
        'tags': ['test', 'demo'],
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Color palette save successful: ${data['success']}');
      print('   Palette ID: ${data['paletteId']}');
    } else {
      print('❌ Color palette save failed: ${response.statusCode}');
    }
  }

  // Тест получения палитр пользователя
  static Future<void> testGetUserPalettes() async {
    print('👤 Testing get user palettes...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/user-palettes/test_user_123'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ User palettes retrieval successful: ${data['success']}');
      if (data['palettes'] != null) {
        print('   Found ${data['palettes'].length} user palettes');
      }
    } else {
      print('❌ User palettes retrieval failed: ${response.statusCode}');
    }
  }

  // Тест получения истории цветовых анализов
  static Future<void> testGetUserColorHistory() async {
    print('📚 Testing get user color history...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/history/test_user_123?limit=20'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ User color history retrieval successful: ${data['success']}');
      if (data['history'] != null) {
        print('   Found ${data['history'].length} history entries');
      }
    } else {
      print('❌ User color history retrieval failed: ${response.statusCode}');
    }
  }

  // Тест получения статистики пользователя
  static Future<void> testGetUserColorStats() async {
    print('📈 Testing get user color stats...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/stats/test_user_123'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ User color stats retrieval successful: ${data['success']}');
      if (data['stats'] != null) {
        print('   Stats available: ${data['stats'].keys.join(', ')}');
      }
    } else {
      print('❌ User color stats retrieval failed: ${response.statusCode}');
    }
  }

  // Тест экспорта цветовой палитры
  static Future<void> testExportColorPalette() async {
    print('📤 Testing export color palette...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/export-palette/test_palette_123'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Color palette export successful: ${data['success']}');
      print('   Export format: ${data['exportFormat']}');
    } else {
      print('❌ Color palette export failed: ${response.statusCode}');
    }
  }

  // Тест импорта цветовой палитры
  static Future<void> testImportColorPalette() async {
    print('📥 Testing import color palette...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/import-palette'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': 'test_user_123',
        'palette': {
          'name': 'Imported Palette',
          'colors': ['#FF0000', '#00FF00', '#0000FF'],
          'description': 'An imported color palette',
        },
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Color palette import successful: ${data['success']}');
      print('   Imported palette ID: ${data['paletteId']}');
    } else {
      print('❌ Color palette import failed: ${response.statusCode}');
    }
  }

  // Тест обновления предпочтений пользователя
  static Future<void> testUpdateUserPreferences() async {
    print('⚙️ Testing update user preferences...');
    
    final response = await http.put(
      Uri.parse('$baseUrl/user-preferences/test_user_123'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'skinTone': 'cool',
        'hairColor': 'blonde',
        'eyeColor': 'blue',
        'preferredColors': ['#0000FF', '#FF00FF'],
        'avoidedColors': ['#FF0000'],
        'style': 'elegant',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ User preferences update successful: ${data['success']}');
    } else {
      print('❌ User preferences update failed: ${response.statusCode}');
    }
  }

  // Тест получения предпочтений пользователя
  static Future<void> testGetUserPreferences() async {
    print('👤 Testing get user preferences...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/user-preferences/test_user_123'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ User preferences retrieval successful: ${data['success']}');
      if (data['preferences'] != null) {
        print('   Preferences available: ${data['preferences'].keys.join(', ')}');
      }
    } else {
      print('❌ User preferences retrieval failed: ${response.statusCode}');
    }
  }
}

void main() async {
  await AIColorMatcherTester.main();
}
