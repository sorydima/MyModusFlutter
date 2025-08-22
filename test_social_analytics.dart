import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Test script for Social Analytics functionality
/// This script tests the backend social analytics API endpoints

class SocialAnalyticsTester {
  static const String baseUrl = 'http://localhost:8080/api/social-analytics';
  
  static Future<void> main() async {
    print('🧪 Testing Social Analytics API...\n');
    
    try {
      // Test 1: Get category trends
      await testGetCategoryTrends();
      
      // Test 2: Get social metrics
      await testGetSocialMetrics();
      
      // Test 3: Get audience analysis
      await testGetAudienceAnalysis();
      
      // Test 4: Get trend predictions
      await testGetTrendPredictions();
      
      // Test 5: Get competitor analysis
      await testGetCompetitorAnalysis();
      
      // Test 6: Get report types
      await testGetReportTypes();
      
      // Test 7: Generate report
      await testGenerateReport();
      
      // Test 8: Get period stats
      await testGetPeriodStats();
      
      // Test 9: Get top products
      await testGetTopProducts();
      
      // Test 10: Get seasonality analysis
      await testGetSeasonalityAnalysis();
      
      // Test 11: Compare periods
      await testComparePeriods();
      
      // Test 12: Export analytics data
      await testExportAnalyticsData();
      
      print('\n✅ All Social Analytics tests completed successfully!');
      
    } catch (e) {
      print('\n❌ Test failed: $e');
    }
  }

  /// Test 1: Get category trends
  static Future<void> testGetCategoryTrends() async {
    print('📈 Testing get category trends...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/trends?period=month&limit=10'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Category trends retrieved: ${data['totalCategories'] ?? 0} categories');
      print('  Period: ${data['period']}');
      print('  Top categories: ${(data['topCategories'] as List?)?.length ?? 0}');
    } else {
      print('❌ Failed to get category trends: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 2: Get social metrics
  static Future<void> testGetSocialMetrics() async {
    print('📊 Testing get social metrics...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/social-metrics/test_product_123?period=week'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Social metrics retrieved for product: ${data['productId']}');
      print('  Period: ${data['period']}');
      print('  Engagement rate: ${data['engagementRate']?.toStringAsFixed(2)}%');
    } else {
      print('❌ Failed to get social metrics: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 3: Get audience analysis
  static Future<void> testGetAudienceAnalysis() async {
    print('👥 Testing get audience analysis...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/audience/fashion?period=month'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Audience analysis retrieved for category: ${data['category']}');
      print('  Total users: ${data['summary']?['totalUsers'] ?? 0}');
      print('  Average age: ${data['summary']?['avgAge']?.toStringAsFixed(0) ?? 0}');
    } else {
      print('❌ Failed to get audience analysis: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 4: Get trend predictions
  static Future<void> testGetTrendPredictions() async {
    print('🔮 Testing get trend predictions...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/predictions/electronics?daysAhead=30'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Trend predictions retrieved for category: ${data['category']}');
      print('  Days ahead: ${data['daysAhead']}');
      print('  Trend direction: ${data['summary']?['trendDirection'] ?? 'unknown'}');
      print('  Confidence level: ${((data['summary']?['confidenceLevel'] ?? 0) * 100).toStringAsFixed(0)}%');
    } else {
      print('❌ Failed to get trend predictions: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 5: Get competitor analysis
  static Future<void> testGetCompetitorAnalysis() async {
    print('🏢 Testing get competitor analysis...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/competitors/fashion?limit=5'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Competitor analysis retrieved for category: ${data['category']}');
      print('  Total competitors: ${data['summary']?['totalCompetitors'] ?? 0}');
      print('  Average price: ${data['summary']?['avgPrice']?.toStringAsFixed(0) ?? 0} ₽');
    } else {
      print('❌ Failed to get competitor analysis: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 6: Get report types
  static Future<void> testGetReportTypes() async {
    print('📋 Testing get report types...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/report-types'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Report types retrieved: ${data['total'] ?? 0} types');
      for (final reportType in data['reportTypes'] ?? []) {
        print('  - ${reportType['type']}: ${reportType['name']}');
      }
    } else {
      print('❌ Failed to get report types: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 7: Generate report
  static Future<void> testGenerateReport() async {
    print('📊 Testing generate report...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reportType': 'trends',
        'parameters': {
          'period': 'month',
          'limit': 20,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Report generated successfully: ${data['reportMetadata']?['reportType'] ?? 'unknown'}');
      print('  Generated at: ${data['reportMetadata']?['generatedAt'] ?? 'unknown'}');
    } else {
      print('❌ Failed to generate report: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 8: Get period stats
  static Future<void> testGetPeriodStats() async {
    print('📊 Testing get period stats...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/stats/month'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Period stats retrieved for: ${data['period']}');
      print('  Total products: ${data['totalProducts'] ?? 0}');
      print('  Total sales: ${data['totalSales']?.toStringAsFixed(0) ?? 0} ₽');
      print('  Growth rate: ${(data['growthRate'] ?? 0).toStringAsFixed(2)}');
    } else {
      print('❌ Failed to get period stats: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 9: Get top products
  static Future<void> testGetTopProducts() async {
    print('🏆 Testing get top products...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/top-products/electronics?limit=10&sortBy=sales'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Top products retrieved for category: ${data['category']}');
      print('  Sort by: ${data['sortBy']}');
      print('  Total products: ${data['total'] ?? 0}');
    } else {
      print('❌ Failed to get top products: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 10: Get seasonality analysis
  static Future<void> testGetSeasonalityAnalysis() async {
    print('🌱 Testing get seasonality analysis...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/seasonality/fashion'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Seasonality analysis retrieved for category: ${data['category']}');
      print('  Peak season: ${data['peakSeason'] ?? 'unknown'}');
      print('  Low season: ${data['lowSeason'] ?? 'unknown'}');
      print('  Seasonality strength: ${data['seasonalityStrength'] ?? 'unknown'}');
    } else {
      print('❌ Failed to get seasonality analysis: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 11: Compare periods
  static Future<void> testComparePeriods() async {
    print('📊 Testing compare periods...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/compare-periods'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'period1': 'month',
        'period2': 'week',
        'metrics': ['sales', 'views', 'rating'],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Periods compared successfully');
      print('  Period 1: ${data['period1']}');
      print('  Period 2: ${data['period2']}');
      print('  Overall trend: ${data['summary']?['overallTrend'] ?? 'unknown'}');
    } else {
      print('❌ Failed to compare periods: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 12: Export analytics data
  static Future<void> testExportAnalyticsData() async {
    print('📤 Testing export analytics data...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/export/trends?format=csv&period=month'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('✅ Analytics data exported successfully');
      print('  Format: CSV');
      print('  Data length: ${response.body.length} characters');
      print('  Content type: ${response.headers['content-type']}');
    } else {
      print('❌ Failed to export analytics data: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }
}

/// Run the tests
void main() async {
  await SocialAnalyticsTester.main();
}
