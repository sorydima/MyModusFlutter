import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logger/logger.dart';
import '../services/ar_fitting_service.dart';
import '../database.dart';
import '../models.dart';

class ARFittingHandler {
  final ARFittingService _arService;
  final DatabaseService _db;
  final Logger _logger = Logger();

  ARFittingHandler({
    required ARFittingService arService,
    required DatabaseService db,
  })  : _arService = arService,
        _db = db;

  Router get router {
    final router = Router();

    // Analyze user photo for measurements
    router.post('/analyze-photo', _analyzePhoto);
    
    // Generate virtual try-on recommendations
    router.post('/virtual-try-on', _virtualTryOn);
    
    // Save user measurements
    router.post('/measurements', _saveMeasurements);
    
    // Get user measurements
    router.get('/measurements/<userId>', _getMeasurements);
    
    // Get AR fitting history
    router.get('/history/<userId>', _getFittingHistory);
    
    // Rate product fit
    router.post('/rate-fit', _rateProductFit);
    
    // Get size recommendations
    router.get('/size-recommendations/<category>', _getSizeRecommendations);
    
    // Get body type analysis
    router.get('/body-analysis/<userId>', _getBodyAnalysis);

    return router;
  }

  /// Analyze user photo to determine body measurements
  Future<Response> _analyzePhoto(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final photoPath = data['photoPath'] as String?;
      final userId = data['userId'] as int?;
      
      if (photoPath == null) {
        return Response(400, 
          body: jsonEncode({'error': 'photoPath is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      _logger.i('Analyzing photo for user: $userId');
      
      final analysis = await _arService.analyzeUserPhoto(photoPath);
      
      // Save measurements if userId provided
      if (userId != null) {
        await _arService.saveUserMeasurements(userId, analysis);
      }
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'measurements': analysis,
          'message': 'Photo analysis completed successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error analyzing photo: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to analyze photo',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Generate virtual try-on recommendations
  Future<Response> _virtualTryOn(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as int?;
      final category = data['category'] as String?;
      final userMeasurements = data['userMeasurements'] as Map<String, dynamic>?;
      
      if (userId == null || category == null) {
        return Response(400,
          body: jsonEncode({
            'error': 'userId and category are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      _logger.i('Generating virtual try-on for user $userId, category: $category');
      
      final recommendations = await _arService.generateVirtualTryOn(
        userId: userId,
        category: category,
        userMeasurements: userMeasurements,
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'recommendations': recommendations,
          'message': 'Virtual try-on recommendations generated',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error generating virtual try-on: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to generate virtual try-on',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Save user measurements
  Future<Response> _saveMeasurements(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as int?;
      final measurements = data['measurements'] as Map<String, dynamic>?;
      
      if (userId == null || measurements == null) {
        return Response(400,
          body: jsonEncode({
            'error': 'userId and measurements are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      _logger.i('Saving measurements for user: $userId');
      
      await _arService.saveUserMeasurements(userId, measurements);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Measurements saved successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error saving measurements: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to save measurements',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Get user measurements
  Future<Response> _getMeasurements(Request request) async {
    try {
      final userId = int.parse(request.params['userId']!);
      
      _logger.i('Getting measurements for user: $userId');
      
      final measurements = await _arService._getUserMeasurements(userId);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'measurements': measurements,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting measurements: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to get measurements',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Get AR fitting history
  Future<Response> _getFittingHistory(Request request) async {
    try {
      final userId = int.parse(request.params['userId']!);
      
      _logger.i('Getting fitting history for user: $userId');
      
      final history = await _arService.getFittingHistory(userId);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'history': history,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting fitting history: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to get fitting history',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Rate product fit
  Future<Response> _rateProductFit(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as int?;
      final productId = data['productId'] as int?;
      final rating = data['rating'] as int?;
      final feedback = data['feedback'] as String?;
      
      if (userId == null || productId == null || rating == null) {
        return Response(400,
          body: jsonEncode({
            'error': 'userId, productId, and rating are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      if (rating < 1 || rating > 5) {
        return Response(400,
          body: jsonEncode({
            'error': 'Rating must be between 1 and 5',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      _logger.i('Rating product fit: user $userId, product $productId, rating $rating');
      
      await _arService.rateProductFit(userId, productId, rating, feedback);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Product fit rated successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error rating product fit: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to rate product fit',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Get size recommendations for category
  Future<Response> _getSizeRecommendations(Request request) async {
    try {
      final category = request.params['category']!;
      
      _logger.i('Getting size recommendations for category: $category');
      
      // Mock size recommendations based on category
      final recommendations = _getMockSizeRecommendations(category);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'category': category,
          'recommendations': recommendations,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting size recommendations: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to get size recommendations',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Get body analysis for user
  Future<Response> _getBodyAnalysis(Request request) async {
    try {
      final userId = int.parse(request.params['userId']!);
      
      _logger.i('Getting body analysis for user: $userId');
      
      final measurements = await _arService._getUserMeasurements(userId);
      
      if (measurements == null) {
        return Response(404,
          body: jsonEncode({
            'error': 'No measurements found for user',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final analysis = _analyzeBodyType(measurements);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'measurements': measurements,
          'analysis': analysis,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting body analysis: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to get body analysis',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Mock size recommendations based on category
  Map<String, dynamic> _getMockSizeRecommendations(String category) {
    switch (category.toLowerCase()) {
      case 'shirts':
      case 't-shirts':
        return {
          'sizes': ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
          'chart': {
            'chest': {'XS': 85, 'S': 90, 'M': 95, 'L': 100, 'XL': 105, 'XXL': 110},
            'waist': {'XS': 70, 'S': 75, 'M': 80, 'L': 85, 'XL': 90, 'XXL': 95},
          },
          'tips': [
            'Measure around the fullest part of your chest',
            'Keep the tape measure horizontal',
            'Don\'t pull too tight'
          ]
        };
      case 'pants':
      case 'jeans':
        return {
          'sizes': ['28', '30', '32', '34', '36', '38', '40'],
          'chart': {
            'waist': {'28': 71, '30': 76, '32': 81, '34': 86, '36': 91, '38': 96, '40': 101},
            'inseam': {'28': 76, '30': 76, '32': 76, '34': 76, '36': 76, '38': 76, '40': 76},
          },
          'tips': [
            'Measure around your natural waistline',
            'For inseam, measure from crotch to desired length',
            'Consider your preferred fit (slim, regular, relaxed)'
          ]
        };
      case 'dresses':
        return {
          'sizes': ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
          'chart': {
            'bust': {'XS': 80, 'S': 85, 'M': 90, 'L': 95, 'XL': 100, 'XXL': 105},
            'waist': {'XS': 60, 'S': 65, 'M': 70, 'L': 75, 'XL': 80, 'XXL': 85},
            'hips': {'XS': 85, 'S': 90, 'M': 95, 'L': 100, 'XL': 105, 'XXL': 110},
          },
          'tips': [
            'Measure bust at the fullest point',
            'Measure waist at the narrowest point',
            'Measure hips at the fullest point'
          ]
        };
      default:
        return {
          'sizes': ['S', 'M', 'L'],
          'chart': {},
          'tips': ['Please refer to the specific product sizing guide']
        };
    }
  }

  /// Analyze body type based on measurements
  Map<String, dynamic> _analyzeBodyType(Map<String, dynamic> measurements) {
    final height = measurements['height'] as double? ?? 170.0;
    final weight = measurements['weight'] as double? ?? 70.0;
    final chest = measurements['chest'] as double? ?? 90.0;
    final waist = measurements['waist'] as double? ?? 75.0;
    final hips = measurements['hips'] as double? ?? 90.0;
    
    // Calculate BMI
    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);
    
    // Determine body type
    String bodyType;
    String description;
    List<String> recommendations = [];
    
    if (chest > waist + 10 && hips > waist + 10) {
      bodyType = 'hourglass';
      description = 'Balanced proportions with defined waist';
      recommendations = [
        'Fitted tops that emphasize your waist',
        'High-waisted bottoms',
        'Wrap dresses and tops'
      ];
    } else if (chest > hips + 5) {
      bodyType = 'inverted-triangle';
      description = 'Broader shoulders and chest';
      recommendations = [
        'V-neck tops to elongate',
        'Dark tops with lighter bottoms',
        'Avoid shoulder pads'
      ];
    } else if (hips > chest + 5) {
      bodyType = 'pear';
      description = 'Narrower shoulders, wider hips';
      recommendations = [
        'Structured tops to balance shoulders',
        'Dark bottoms, light tops',
        'A-line skirts and dresses'
      ];
    } else if ((chest - waist).abs() < 5 && (hips - chest).abs() < 5) {
      bodyType = 'rectangle';
      description = 'Straight silhouette with minimal curves';
      recommendations = [
        'Layered clothing for dimension',
        'Belted items to create waist',
        'Textured fabrics'
      ];
    } else {
      bodyType = 'athletic';
      description = 'Toned and muscular build';
      recommendations = [
        'Fitted but not tight clothing',
        'Stretchy fabrics',
        'Avoid oversized items'
      ];
    }
    
    return {
      'bodyType': bodyType,
      'description': description,
      'bmi': bmi.toStringAsFixed(1),
      'bmiCategory': _getBMICategory(bmi),
      'recommendations': recommendations,
      'proportions': {
        'chestToWaist': (chest - waist).abs(),
        'waistToHips': (waist - hips).abs(),
        'shoulderToHip': measurements['shoulders'] != null ? 
          (measurements['shoulders'] as double) * 2 - hips : null,
      }
    };
  }

  /// Get BMI category
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
