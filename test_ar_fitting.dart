import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Test script for AR Fitting functionality
/// This script tests the backend AR fitting API endpoints

class ARFittingTester {
  static const String baseUrl = 'http://localhost:8080/api/ar-fitting';
  
  static Future<void> main() async {
    print('🧪 Testing AR Fitting API...\n');
    
    try {
      // Test 1: Analyze photo
      await testAnalyzePhoto();
      
      // Test 2: Generate virtual try-on
      await testVirtualTryOn();
      
      // Test 3: Save measurements
      await testSaveMeasurements();
      
      // Test 4: Get measurements
      await testGetMeasurements();
      
      // Test 5: Get fitting history
      await testGetFittingHistory();
      
      // Test 6: Rate product fit
      await testRateProductFit();
      
      // Test 7: Get size recommendations
      await testGetSizeRecommendations();
      
      // Test 8: Get body analysis
      await testGetBodyAnalysis();
      
      print('\n✅ All AR Fitting tests completed successfully!');
      
    } catch (e) {
      print('\n❌ Test failed: $e');
    }
  }
  
  /// Test photo analysis endpoint
  static Future<void> testAnalyzePhoto() async {
    print('📸 Testing photo analysis...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-photo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'photoPath': '/test/photo.jpg',
          'userId': 1,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Photo analysis successful');
        print('   Measurements: ${data['measurements']}');
        print('   Message: ${data['message']}');
      } else {
        print('❌ Photo analysis failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Photo analysis error: $e');
    }
    print('');
  }
  
  /// Test virtual try-on endpoint
  static Future<void> testVirtualTryOn() async {
    print('👕 Testing virtual try-on...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/virtual-try-on'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 1,
          'category': 'shirts',
          'userMeasurements': {
            'height': 175.0,
            'chest': 95.0,
            'waist': 80.0,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Virtual try-on successful');
        print('   Recommendations count: ${data['recommendations'].length}');
        if (data['recommendations'].isNotEmpty) {
          final firstRec = data['recommendations'][0];
          print('   First recommendation score: ${firstRec['score']}');
          print('   Fit prediction: ${firstRec['fitPrediction']}');
        }
      } else {
        print('❌ Virtual try-on failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Virtual try-on error: $e');
    }
    print('');
  }
  
  /// Test save measurements endpoint
  static Future<void> testSaveMeasurements() async {
    print('📏 Testing save measurements...');
    
    try {
      final measurements = {
        'height': 175.0,
        'weight': 70.0,
        'chest': 95.0,
        'waist': 80.0,
        'hips': 95.0,
        'shoulders': 45.0,
        'inseam': 80.0,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/measurements'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 1,
          'measurements': measurements,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Save measurements successful');
        print('   Message: ${data['message']}');
      } else {
        print('❌ Save measurements failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Save measurements error: $e');
    }
    print('');
  }
  
  /// Test get measurements endpoint
  static Future<void> testGetMeasurements() async {
    print('📊 Testing get measurements...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/measurements/1'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Get measurements successful');
        if (data['measurements'] != null) {
          final measurements = data['measurements'] as Map<String, dynamic>;
          print('   Height: ${measurements['height']} cm');
          print('   Weight: ${measurements['weight']} kg');
          print('   Chest: ${measurements['chest']} cm');
        }
      } else {
        print('❌ Get measurements failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Get measurements error: $e');
    }
    print('');
  }
  
  /// Test get fitting history endpoint
  static Future<void> testGetFittingHistory() async {
    print('📚 Testing get fitting history...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/1'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Get fitting history successful');
        print('   History items count: ${data['history'].length}');
        if (data['history'].isNotEmpty) {
          final firstItem = data['history'][0];
          print('   First item: ${firstItem['productName']}');
          print('   Brand: ${firstItem['brand']}');
        }
      } else {
        print('❌ Get fitting history failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Get fitting history error: $e');
    }
    print('');
  }
  
  /// Test rate product fit endpoint
  static Future<void> testRateProductFit() async {
    print('⭐ Testing rate product fit...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rate-fit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 1,
          'productId': 1,
          'rating': 5,
          'feedback': 'Perfect fit! Love this shirt.',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Rate product fit successful');
        print('   Message: ${data['message']}');
      } else {
        print('❌ Rate product fit failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Rate product fit error: $e');
    }
    print('');
  }
  
  /// Test get size recommendations endpoint
  static Future<void> testGetSizeRecommendations() async {
    print('👖 Testing get size recommendations...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/size-recommendations/shirts'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Get size recommendations successful');
        print('   Category: ${data['category']}');
        final recommendations = data['recommendations'];
        print('   Available sizes: ${recommendations['sizes']}');
        if (recommendations['tips'] != null) {
          print('   Tips count: ${recommendations['tips'].length}');
        }
      } else {
        print('❌ Get size recommendations failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Get size recommendations error: $e');
    }
    print('');
  }
  
  /// Test get body analysis endpoint
  static Future<void> testGetBodyAnalysis() async {
    print('🔍 Testing get body analysis...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/body-analysis/1'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Get body analysis successful');
        if (data['analysis'] != null) {
          final analysis = data['analysis'];
          print('   Body type: ${analysis['bodyType']}');
          print('   Description: ${analysis['description']}');
          print('   BMI: ${analysis['bmi']}');
          print('   BMI category: ${analysis['bmiCategory']}');
          if (analysis['recommendations'] != null) {
            print('   Style recommendations: ${analysis['recommendations'].length}');
          }
        }
      } else {
        print('❌ Get body analysis failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Get body analysis error: $e');
    }
    print('');
  }
}

/// Run the tests
void main() async {
  await ARFittingTester.main();
}
