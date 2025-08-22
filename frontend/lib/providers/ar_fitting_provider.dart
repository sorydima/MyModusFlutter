import 'package:flutter/foundation.dart';
import '../services/ar_fitting_service.dart';
import '../models/product.dart';

class ARFittingProvider extends ChangeNotifier {
  final ARFittingService _arService = ARFittingService();
  
  // State variables
  Map<String, dynamic>? _userMeasurements;
  List<Map<String, dynamic>> _virtualTryOnRecommendations = [];
  List<Map<String, dynamic>> _fittingHistory = [];
  Map<String, dynamic>? _bodyAnalysis;
  Map<String, dynamic>? _sizeRecommendations;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  Map<String, dynamic>? get userMeasurements => _userMeasurements;
  List<Map<String, dynamic>> get virtualTryOnRecommendations => _virtualTryOnRecommendations;
  List<Map<String, dynamic>> get fittingHistory => _fittingHistory;
  Map<String, dynamic>? get bodyAnalysis => _bodyAnalysis;
  Map<String, dynamic>? get sizeRecommendations => _sizeRecommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Analyze user photo for measurements
  Future<void> analyzePhoto({
    required String photoPath,
    int? userId,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final measurements = await _arService.analyzePhoto(
        photoPath: photoPath,
        userId: userId,
      );
      
      _userMeasurements = measurements;
      notifyListeners();
      
      // If userId provided, also get body analysis
      if (userId != null) {
        await getBodyAnalysis(userId);
      }
    } catch (e) {
      _setError('Failed to analyze photo: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Generate virtual try-on recommendations
  Future<void> generateVirtualTryOn({
    required int userId,
    required String category,
    Map<String, dynamic>? userMeasurements,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final recommendations = await _arService.generateVirtualTryOn(
        userId: userId,
        category: category,
        userMeasurements: userMeasurements ?? _userMeasurements,
      );
      
      _virtualTryOnRecommendations = recommendations;
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate virtual try-on: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Save user measurements
  Future<void> saveMeasurements({
    required int userId,
    required Map<String, dynamic> measurements,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _arService.saveMeasurements(
        userId: userId,
        measurements: measurements,
      );
      
      _userMeasurements = measurements;
      notifyListeners();
    } catch (e) {
      _setError('Failed to save measurements: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get user measurements
  Future<void> getMeasurements(int userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final measurements = await _arService.getMeasurements(userId);
      _userMeasurements = measurements;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get measurements: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get AR fitting history
  Future<void> getFittingHistory(int userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final history = await _arService.getFittingHistory(userId);
      _fittingHistory = history;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get fitting history: $e');
    } finally {
      _setLoading(false);
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
      _setLoading(true);
      _clearError();
      
      await _arService.rateProductFit(
        userId: userId,
        productId: productId,
        rating: rating,
        feedback: feedback,
      );
      
      // Refresh fitting history
      await getFittingHistory(userId);
    } catch (e) {
      _setError('Failed to rate product fit: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get size recommendations for category
  Future<void> getSizeRecommendations(String category) async {
    try {
      _setLoading(true);
      _clearError();
      
      final recommendations = await _arService.getSizeRecommendations(category);
      _sizeRecommendations = recommendations;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get size recommendations: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get body analysis for user
  Future<void> getBodyAnalysis(int userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final analysis = await _arService.getBodyAnalysis(userId);
      _bodyAnalysis = analysis;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get body analysis: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Take photo using camera
  Future<String?> takePhoto() async {
    try {
      _clearError();
      
      final photoFile = await _arService.takePhoto();
      if (photoFile != null) {
        return photoFile.path;
      }
      return null;
    } catch (e) {
      _setError('Failed to take photo: $e');
      return null;
    }
  }
  
  /// Select photo from gallery
  Future<String?> selectPhoto() async {
    try {
      _clearError();
      
      final photoFile = await _arService.selectPhoto();
      if (photoFile != null) {
        return photoFile.path;
      }
      return null;
    } catch (e) {
      _setError('Failed to select photo: $e');
      return null;
    }
  }
  
  /// Process photo for AR analysis
  Future<Map<String, dynamic>?> processPhotoForAR(String photoPath) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Create a mock file for now
      // In real implementation, this would be an actual File object
      final mockFile = File(photoPath);
      final result = await _arService.processPhotoForAR(mockFile);
      
      return result;
    } catch (e) {
      _setError('Failed to process photo for AR: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Generate AR overlay for product
  Future<Map<String, dynamic>?> generateAROverlay({
    required Product product,
    required Map<String, dynamic> userMeasurements,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final overlay = await _arService.generateAROverlay(
        product: product,
        userMeasurements: userMeasurements,
      );
      
      return overlay;
    } catch (e) {
      _setError('Failed to generate AR overlay: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Clear all data
  void clearData() {
    _userMeasurements = null;
    _virtualTryOnRecommendations = [];
    _fittingHistory = [];
    _bodyAnalysis = null;
    _sizeRecommendations = null;
    _clearError();
    notifyListeners();
  }
  
  /// Clear recommendations
  void clearRecommendations() {
    _virtualTryOnRecommendations = [];
    notifyListeners();
  }
  
  /// Update measurements manually
  void updateMeasurements(Map<String, dynamic> measurements) {
    _userMeasurements = measurements;
    notifyListeners();
  }
  
  /// Add manual measurement
  void addMeasurement(String key, dynamic value) {
    if (_userMeasurements == null) {
      _userMeasurements = {};
    }
    _userMeasurements![key] = value;
    notifyListeners();
  }
  
  /// Remove measurement
  void removeMeasurement(String key) {
    _userMeasurements?.remove(key);
    notifyListeners();
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
