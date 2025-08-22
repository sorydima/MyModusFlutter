import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../database.dart';
import '../models.dart';

class ARFittingService {
  final DatabaseService _db;
  final Logger _logger = Logger();

  ARFittingService({required DatabaseService db}) : _db = db;

  /// Analyze user photo to determine body measurements
  Future<Map<String, dynamic>> analyzeUserPhoto(String photoPath) async {
    try {
      _logger.i('Analyzing user photo: $photoPath');
      
      // TODO: Integrate with AI vision service for body measurement analysis
      // For now, return mock data structure
      return {
        'height': 175.0,
        'weight': 70.0,
        'chest': 95.0,
        'waist': 80.0,
        'hips': 95.0,
        'shoulders': 45.0,
        'inseam': 80.0,
        'confidence': 0.85,
        'bodyType': 'athletic',
        'recommendations': [
          'Your body type works well with fitted clothing',
          'Consider medium-sized items for most categories',
          'Athletic fit shirts would complement your build'
        ]
      };
    } catch (e) {
      _logger.e('Error analyzing user photo: $e');
      rethrow;
    }
  }

  /// Generate virtual try-on recommendations
  Future<List<Map<String, dynamic>>> generateVirtualTryOn({
    required int userId,
    required String category,
    Map<String, dynamic>? userMeasurements,
  }) async {
    try {
      _logger.i('Generating virtual try-on for user $userId, category: $category');
      
      // Get user preferences and measurements
      final preferences = await _db.getUserPreferences(userId);
      final measurements = userMeasurements ?? await _getUserMeasurements(userId);
      
      // Get products in category
      final products = await _db.getProductsByCategory(category);
      
      // Filter and rank products based on user measurements and preferences
      final recommendations = await _rankProductsForUser(
        products: products,
        userMeasurements: measurements,
        userPreferences: preferences,
      );
      
      return recommendations.take(10).toList();
    } catch (e) {
      _logger.e('Error generating virtual try-on: $e');
      rethrow;
    }
  }

  /// Get user's saved measurements
  Future<Map<String, dynamic>?> _getUserMeasurements(int userId) async {
    try {
      final result = await _db.query(
        'SELECT measurements FROM user_preferences WHERE user_id = @userId',
        substitutionValues: {'userId': userId},
      );
      
      if (result.isNotEmpty && result.first[0] != null) {
        return jsonDecode(result.first[0] as String);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user measurements: $e');
      return null;
    }
    }

  /// Rank products based on user measurements and preferences
  Future<List<Map<String, dynamic>>> _rankProductsForUser({
    required List<Product> products,
    required Map<String, dynamic> userMeasurements,
    required UserPreferences? userPreferences,
  }) async {
    try {
      final rankedProducts = <Map<String, dynamic>>[];
      
      for (final product in products) {
        double score = 0.0;
        final reasons = <String>[];
        
        // Size compatibility scoring
        if (product.sizes != null && product.sizes!.isNotEmpty) {
          final sizeScore = _calculateSizeCompatibility(
            product.sizes!,
            userMeasurements,
          );
          score += sizeScore * 0.4; // 40% weight for size
          if (sizeScore > 0.7) {
            reasons.add('Perfect size match');
          }
        }
        
        // Style preference scoring
        if (userPreferences != null) {
          final styleScore = _calculateStyleCompatibility(
            product,
            userPreferences,
          );
          score += styleScore * 0.3; // 30% weight for style
          if (styleScore > 0.7) {
            reasons.add('Matches your style preferences');
          }
        }
        
        // Color compatibility
        if (userPreferences?.preferredColors != null) {
          final colorScore = _calculateColorCompatibility(
            product,
            userPreferences!.preferredColors!,
          );
          score += colorScore * 0.2; // 20% weight for color
          if (colorScore > 0.7) {
            reasons.add('Great color choice for you');
          }
        }
        
        // Brand preference
        if (userPreferences?.preferredBrands != null && 
            userPreferences!.preferredBrands!.contains(product.brand)) {
          score += 0.1; // 10% bonus for preferred brand
          reasons.add('From your preferred brand');
        }
        
        rankedProducts.add({
          'product': product,
          'score': score,
          'reasons': reasons,
          'fitPrediction': _generateFitPrediction(score),
          'sizeRecommendation': _getSizeRecommendation(product, userMeasurements),
        });
      }
      
      // Sort by score descending
      rankedProducts.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
      
      return rankedProducts;
    } catch (e) {
      _logger.e('Error ranking products: $e');
      rethrow;
    }
  }

  /// Calculate size compatibility score
  double _calculateSizeCompatibility(
    List<String> availableSizes,
    Map<String, dynamic> userMeasurements,
  ) {
    // Simple size compatibility logic
    // In a real implementation, this would use more sophisticated sizing algorithms
    if (availableSizes.contains('M') || availableSizes.contains('L')) {
      return 0.8; // Good compatibility
    } else if (availableSizes.contains('S') || availableSizes.contains('XL')) {
      return 0.6; // Moderate compatibility
    }
    return 0.3; // Low compatibility
  }

  /// Calculate style compatibility score
  double _calculateStyleCompatibility(
    Product product,
    UserPreferences userPreferences,
  ) {
    double score = 0.5; // Base score
    
    if (userPreferences.preferredStyles != null) {
      for (final style in userPreferences.preferredStyles!) {
        if (product.description?.toLowerCase().contains(style.toLowerCase()) ?? false) {
          score += 0.2;
        }
      }
    }
    
    return score.clamp(0.0, 1.0);
  }

  /// Calculate color compatibility score
  double _calculateColorCompatibility(
    Product product,
    List<String> preferredColors,
  ) {
    if (product.description == null) return 0.5;
    
    final description = product.description!.toLowerCase();
    double score = 0.5;
    
    for (final color in preferredColors) {
      if (description.contains(color.toLowerCase())) {
        score += 0.3;
      }
    }
    
    return score.clamp(0.0, 1.0);
  }

  /// Generate fit prediction based on score
  String _generateFitPrediction(double score) {
    if (score >= 0.8) return 'Perfect Fit';
    if (score >= 0.6) return 'Good Fit';
    if (score >= 0.4) return 'Moderate Fit';
    return 'May Not Fit Well';
  }

  /// Get size recommendation for user
  String _getSizeRecommendation(
    Product product,
    Map<String, dynamic> userMeasurements,
  ) {
    // Simple size recommendation logic
    // In a real implementation, this would use detailed sizing charts
    if (product.sizes == null || product.sizes!.isEmpty) {
      return 'Size information not available';
    }
    
    // Mock size recommendation based on measurements
    if (userMeasurements['chest'] != null) {
      final chest = userMeasurements['chest'] as double;
      if (chest < 90) return 'S';
      if (chest < 100) return 'M';
      if (chest < 110) return 'L';
      return 'XL';
    }
    
    return 'M'; // Default recommendation
  }

  /// Save user measurements
  Future<void> saveUserMeasurements(
    int userId,
    Map<String, dynamic> measurements,
  ) async {
    try {
      final measurementsJson = jsonEncode(measurements);
      
      await _db.query(
        '''
        INSERT INTO user_preferences (user_id, measurements, updated_at)
        VALUES (@userId, @measurements, NOW())
        ON CONFLICT (user_id) 
        DO UPDATE SET 
          measurements = @measurements,
          updated_at = NOW()
        ''',
        substitutionValues: {
          'userId': userId,
          'measurements': measurementsJson,
        },
      );
      
      _logger.i('Saved measurements for user $userId');
    } catch (e) {
      _logger.e('Error saving user measurements: $e');
      rethrow;
    }
  }

  /// Get AR fitting history for user
  Future<List<Map<String, dynamic>>> getFittingHistory(int userId) async {
    try {
      final result = await _db.query(
        '''
        SELECT 
          p.id,
          p.name,
          p.brand,
          p.category,
          p.image_url,
          upv.viewed_at,
          upv.fit_rating
        FROM user_product_views upv
        JOIN products p ON upv.product_id = p.id
        WHERE upv.user_id = @userId
        ORDER BY upv.viewed_at DESC
        LIMIT 20
        ''',
        substitutionValues: {'userId': userId},
      );
      
      return result.map((row) => {
        'productId': row[0],
        'productName': row[1],
        'brand': row[2],
        'category': row[3],
        'imageUrl': row[4],
        'viewedAt': row[5],
        'fitRating': row[6],
      }).toList();
    } catch (e) {
      _logger.e('Error getting fitting history: $e');
      rethrow;
    }
  }

  /// Rate product fit after virtual try-on
  Future<void> rateProductFit(
    int userId,
    int productId,
    int rating,
    String? feedback,
  ) async {
    try {
      await _db.query(
        '''
        UPDATE user_product_views 
        SET fit_rating = @rating, fit_feedback = @feedback
        WHERE user_id = @userId AND product_id = @productId
        ''',
        substitutionValues: {
          'userId': userId,
          'productId': productId,
          'rating': rating,
          'feedback': feedback,
        },
      );
      
      _logger.i('Updated fit rating for user $userId, product $productId');
    } catch (e) {
      _logger.e('Error rating product fit: $e');
      rethrow;
    }
  }
}
