import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ARFittingService {
  static const String baseUrl = 'http://localhost:8080/api/ar-fitting';
  
  /// Analyze user photo to determine body measurements
  Future<Map<String, dynamic>> analyzePhoto({
    required String photoPath,
    int? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-photo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'photoPath': photoPath,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['measurements'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to analyze photo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing photo: $e');
    }
  }

  /// Generate virtual try-on recommendations
  Future<List<Map<String, dynamic>>> generateVirtualTryOn({
    required int userId,
    required String category,
    Map<String, dynamic>? userMeasurements,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/virtual-try-on'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'category': category,
          'userMeasurements': userMeasurements,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['recommendations']);
      } else {
        throw Exception('Failed to generate virtual try-on: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating virtual try-on: $e');
    }
  }

  /// Save user measurements
  Future<void> saveMeasurements({
    required int userId,
    required Map<String, dynamic> measurements,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/measurements'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'measurements': measurements,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save measurements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving measurements: $e');
    }
  }

  /// Get user measurements
  Future<Map<String, dynamic>?> getMeasurements(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/measurements/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['measurements'] as Map<String, dynamic>?;
      } else if (response.statusCode == 404) {
        return null; // No measurements found
      } else {
        throw Exception('Failed to get measurements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting measurements: $e');
    }
  }

  /// Get AR fitting history
  Future<List<Map<String, dynamic>>> getFittingHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['history']);
      } else {
        throw Exception('Failed to get fitting history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting fitting history: $e');
    }
  }

  /// Rate product fit
  Future<void> rateProductFit({
    required int userId,
    required int productId,
    required int rating,
    String? feedback,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rate-fit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'productId': productId,
          'rating': rating,
          'feedback': feedback,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to rate product fit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rating product fit: $e');
    }
  }

  /// Get size recommendations for category
  Future<Map<String, dynamic>> getSizeRecommendations(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/size-recommendations/$category'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['recommendations'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get size recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting size recommendations: $e');
    }
  }

  /// Get body analysis for user
  Future<Map<String, dynamic>> getBodyAnalysis(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/body-analysis/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'measurements': data['measurements'],
          'analysis': data['analysis'],
        };
      } else {
        throw Exception('Failed to get body analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting body analysis: $e');
    }
  }

  /// Take photo using camera
  Future<File?> takePhoto() async {
    try {
      // TODO: Implement camera functionality
      // This would typically use camera plugin
      // For now, return null as placeholder
      return null;
    } catch (e) {
      throw Exception('Error taking photo: $e');
    }
  }

  /// Select photo from gallery
  Future<File?> selectPhoto() async {
    try {
      // TODO: Implement gallery picker
      // This would typically use image_picker plugin
      // For now, return null as placeholder
      return null;
    } catch (e) {
      throw Exception('Error selecting photo: $e');
    }
  }

  /// Process photo for AR analysis
  Future<Map<String, dynamic>> processPhotoForAR(File photoFile) async {
    try {
      // TODO: Implement photo processing for AR
      // This could include:
      // - Image preprocessing
      // - Body detection
      // - Measurement extraction
      // - AR overlay preparation
      
      // Mock processing result
      return {
        'processed': true,
        'photoPath': photoFile.path,
        'analysisReady': true,
      };
    } catch (e) {
      throw Exception('Error processing photo for AR: $e');
    }
  }

  /// Generate AR overlay for product
  Future<Map<String, dynamic>> generateAROverlay({
    required Product product,
    required Map<String, dynamic> userMeasurements,
  }) async {
    try {
      // TODO: Implement AR overlay generation
      // This would typically:
      // - Load 3D model of the product
      // - Apply user measurements
      // - Generate virtual try-on visualization
      // - Return overlay data for AR rendering
      
      // Mock AR overlay data
      return {
        'productId': product.id,
        'overlayReady': true,
        'virtualFit': 'Good',
        'confidence': 0.85,
        'recommendations': [
          'This size should fit well',
          'Consider the color with your skin tone',
          'Style matches your preferences'
        ],
      };
    } catch (e) {
      throw Exception('Error generating AR overlay: $e');
    }
  }
}
