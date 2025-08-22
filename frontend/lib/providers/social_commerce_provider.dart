import 'package:flutter/foundation.dart';
import '../services/social_commerce_service.dart';

class SocialCommerceProvider extends ChangeNotifier {
  final SocialCommerceService _socialCommerceService = SocialCommerceService();

  // Live Streams
  List<Map<String, dynamic>> _liveStreams = [];
  Map<String, dynamic>? _currentLiveStream;
  bool _isLoadingLiveStreams = false;
  String? _liveStreamError;

  // Group Purchases
  List<Map<String, dynamic>> _groupPurchases = [];
  Map<String, dynamic>? _currentGroupPurchase;
  bool _isLoadingGroupPurchases = false;
  String? _groupPurchaseError;

  // Reviews
  List<Map<String, dynamic>> _reviews = [];
  Map<String, dynamic>? _currentReview;
  bool _isLoadingReviews = false;
  String? _reviewError;

  // Partnerships
  List<Map<String, dynamic>> _partnerships = [];
  Map<String, dynamic>? _currentPartnership;
  bool _isLoadingPartnerships = false;
  String? _partnershipError;

  // Friend Recommendations
  List<Map<String, dynamic>> _friendRecommendations = [];
  bool _isLoadingRecommendations = false;
  String? _recommendationError;

  // Social Media
  List<Map<String, dynamic>> _socialPlatforms = [];
  bool _isLoadingPlatforms = false;
  String? _platformError;

  // Analytics
  Map<String, dynamic>? _analytics;
  bool _isLoadingAnalytics = false;
  String? _analyticsError;

  // Getters
  List<Map<String, dynamic>> get liveStreams => _liveStreams;
  Map<String, dynamic>? get currentLiveStream => _currentLiveStream;
  bool get isLoadingLiveStreams => _isLoadingLiveStreams;
  String? get liveStreamError => _liveStreamError;

  List<Map<String, dynamic>> get groupPurchases => _groupPurchases;
  Map<String, dynamic>? get currentGroupPurchase => _currentGroupPurchase;
  bool get isLoadingGroupPurchases => _isLoadingGroupPurchases;
  String? get groupPurchaseError => _groupPurchaseError;

  List<Map<String, dynamic>> get reviews => _reviews;
  Map<String, dynamic>? get currentReview => _currentReview;
  bool get isLoadingReviews => _isLoadingReviews;
  String? get reviewError => _reviewError;

  List<Map<String, dynamic>> get partnerships => _partnerships;
  Map<String, dynamic>? get currentPartnership => _currentPartnership;
  bool get isLoadingPartnerships => _isLoadingPartnerships;
  String? get partnershipError => _partnershipError;

  List<Map<String, dynamic>> get friendRecommendations => _friendRecommendations;
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  String? get recommendationError => _recommendationError;

  List<Map<String, dynamic>> get socialPlatforms => _socialPlatforms;
  bool get isLoadingPlatforms => _isLoadingPlatforms;
  String? get platformError => _platformError;

  Map<String, dynamic>? get analytics => _analytics;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  String? get analyticsError => _analyticsError;

  // Live Streams
  Future<void> createLiveStream({
    required String userId,
    required String title,
    required String description,
    required DateTime scheduledTime,
    List<String>? productIds,
    String? thumbnailUrl,
    Map<String, dynamic>? settings,
  }) async {
    try {
      _isLoadingLiveStreams = true;
      _liveStreamError = null;
      notifyListeners();

      final result = await _socialCommerceService.createLiveStream(
        userId: userId,
        title: title,
        description: description,
        scheduledTime: scheduledTime,
        productIds: productIds,
        thumbnailUrl: thumbnailUrl,
        settings: settings,
      );

      if (result['success'] == true) {
        _liveStreams.insert(0, result['stream']);
        notifyListeners();
      } else {
        _liveStreamError = result['error'] ?? 'Failed to create live stream';
        notifyListeners();
      }
    } catch (e) {
      _liveStreamError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingLiveStreams = false;
      notifyListeners();
    }
  }

  Future<void> getLiveStreams({
    String? status,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      _isLoadingLiveStreams = true;
      _liveStreamError = null;
      notifyListeners();

      final result = await _socialCommerceService.getLiveStreams(
        status: status,
        category: category,
        limit: limit,
        offset: offset,
      );

      if (result['success'] == true) {
        _liveStreams = List<Map<String, dynamic>>.from(result['streams']);
        notifyListeners();
      } else {
        _liveStreamError = result['error'] ?? 'Failed to get live streams';
        notifyListeners();
      }
    } catch (e) {
      _liveStreamError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingLiveStreams = false;
      notifyListeners();
    }
  }

  Future<void> getLiveStream(String streamId) async {
    try {
      final result = await _socialCommerceService.getLiveStream(streamId);
      if (result['success'] == true) {
        _currentLiveStream = result['stream'];
        notifyListeners();
      }
    } catch (e) {
      _liveStreamError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLiveStream(String streamId, Map<String, dynamic> data) async {
    try {
      final result = await _socialCommerceService.updateLiveStream(streamId, data);
      if (result['success'] == true) {
        final index = _liveStreams.indexWhere((stream) => stream['id'] == streamId);
        if (index != -1) {
          _liveStreams[index] = result['stream'];
          notifyListeners();
        }
      }
    } catch (e) {
      _liveStreamError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteLiveStream(String streamId) async {
    try {
      final result = await _socialCommerceService.deleteLiveStream(streamId);
      if (result['success'] == true) {
        _liveStreams.removeWhere((stream) => stream['id'] == streamId);
        notifyListeners();
      }
    } catch (e) {
      _liveStreamError = e.toString();
      notifyListeners();
    }
  }

  Future<void> startLiveStream(String streamId) async {
    try {
      final result = await _socialCommerceService.startLiveStream(streamId);
      if (result['success'] == true) {
        final index = _liveStreams.indexWhere((stream) => stream['id'] == streamId);
        if (index != -1) {
          _liveStreams[index]['status'] = 'live';
          notifyListeners();
        }
      }
    } catch (e) {
      _liveStreamError = e.toString();
      notifyListeners();
    }
  }

  Future<void> endLiveStream(String streamId) async {
    try {
      final result = await _socialCommerceService.endLiveStream(streamId);
      if (result['success'] == true) {
        final index = _liveStreams.indexWhere((stream) => stream['id'] == streamId);
        if (index != -1) {
          _liveStreams[index]['status'] = 'ended';
          notifyListeners();
        }
      }
    } catch (e) {
      _liveStreamError = e.toString();
      notifyListeners();
    }
  }

  // Group Purchases
  Future<void> createGroupPurchase({
    required String productId,
    required String creatorId,
    required int minParticipants,
    required double discountPercent,
    required DateTime deadline,
    String? description,
    List<String>? tags,
  }) async {
    try {
      _isLoadingGroupPurchases = true;
      _groupPurchaseError = null;
      notifyListeners();

      final result = await _socialCommerceService.createGroupPurchase(
        productId: productId,
        creatorId: creatorId,
        minParticipants: minParticipants,
        discountPercent: discountPercent,
        deadline: deadline,
        description: description,
        tags: tags,
      );

      if (result['success'] == true) {
        _groupPurchases.insert(0, result['group']);
        notifyListeners();
      } else {
        _groupPurchaseError = result['error'] ?? 'Failed to create group purchase';
        notifyListeners();
      }
    } catch (e) {
      _groupPurchaseError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingGroupPurchases = false;
      notifyListeners();
    }
  }

  Future<void> getGroupPurchases() async {
    try {
      _isLoadingGroupPurchases = true;
      _groupPurchaseError = null;
      notifyListeners();

      final result = await _socialCommerceService.getGroupPurchases();
      if (result['success'] == true) {
        _groupPurchases = List<Map<String, dynamic>>.from(result['groups'] ?? []);
        notifyListeners();
      } else {
        _groupPurchaseError = result['error'] ?? 'Failed to get group purchases';
        notifyListeners();
      }
    } catch (e) {
      _groupPurchaseError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingGroupPurchases = false;
      notifyListeners();
    }
  }

  Future<void> joinGroupPurchase({
    required String groupId,
    required String userId,
  }) async {
    try {
      final result = await _socialCommerceService.joinGroupPurchase(
        groupId: groupId,
        userId: userId,
      );
      if (result['success'] == true) {
        // Обновляем количество участников
        final index = _groupPurchases.indexWhere((group) => group['id'] == groupId);
        if (index != -1) {
          _groupPurchases[index]['currentParticipants'] = 
              (_groupPurchases[index]['currentParticipants'] ?? 0) + 1;
          notifyListeners();
        }
      }
    } catch (e) {
      _groupPurchaseError = e.toString();
      notifyListeners();
    }
  }

  // Reviews
  Future<void> createReview({
    required String userId,
    required String productId,
    required double rating,
    required String comment,
    List<String>? photos,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _isLoadingReviews = true;
      _reviewError = null;
      notifyListeners();

      final result = await _socialCommerceService.createReview(
        userId: userId,
        productId: productId,
        rating: rating,
        comment: comment,
        photos: photos,
        additionalData: additionalData,
      );

      if (result['success'] == true) {
        _reviews.insert(0, result['review']);
        notifyListeners();
      } else {
        _reviewError = result['error'] ?? 'Failed to create review';
        notifyListeners();
      }
    } catch (e) {
      _reviewError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  Future<void> getReviews({
    String? productId,
    String? userId,
    double? minRating,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      _isLoadingReviews = true;
      _reviewError = null;
      notifyListeners();

      final result = await _socialCommerceService.getReviews(
        productId: productId,
        userId: userId,
        minRating: minRating,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
      );

      if (result['success'] == true) {
        _reviews = List<Map<String, dynamic>>.from(result['reviews']);
        notifyListeners();
      } else {
        _reviewError = result['error'] ?? 'Failed to get reviews';
        notifyListeners();
      }
    } catch (e) {
      _reviewError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  Future<void> likeReview(String reviewId) async {
    try {
      final result = await _socialCommerceService.likeReview(reviewId);
      if (result['success'] == true) {
        final index = _reviews.indexWhere((review) => review['id'] == reviewId);
        if (index != -1) {
          _reviews[index]['likes'] = (_reviews[index]['likes'] ?? 0) + 1;
          notifyListeners();
        }
      }
    } catch (e) {
      _reviewError = e.toString();
      notifyListeners();
    }
  }

  Future<void> dislikeReview(String reviewId) async {
    try {
      final result = await _socialCommerceService.dislikeReview(reviewId);
      if (result['success'] == true) {
        final index = _reviews.indexWhere((review) => review['id'] == reviewId);
        if (index != -1) {
          _reviews[index]['dislikes'] = (_reviews[index]['dislikes'] ?? 0) + 1;
          notifyListeners();
        }
      }
    } catch (e) {
      _reviewError = e.toString();
      notifyListeners();
    }
  }

  // Partnerships
  Future<void> createInfluencerPartnership({
    required String influencerId,
    required String brandId,
    required Map<String, dynamic> terms,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    try {
      _isLoadingPartnerships = true;
      _partnershipError = null;
      notifyListeners();

      final result = await _socialCommerceService.createInfluencerPartnership(
        influencerId: influencerId,
        brandId: brandId,
        terms: terms,
        startDate: startDate,
        endDate: endDate,
        description: description,
      );

      if (result['success'] == true) {
        _partnerships.insert(0, result['partnership']);
        notifyListeners();
      } else {
        _partnershipError = result['error'] ?? 'Failed to create partnership';
        notifyListeners();
      }
    } catch (e) {
      _partnershipError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingPartnerships = false;
      notifyListeners();
    }
  }

  Future<void> getPartnerships() async {
    try {
      _isLoadingPartnerships = true;
      _partnershipError = null;
      notifyListeners();

      final result = await _socialCommerceService.getPartnerships();
      if (result['success'] == true) {
        _partnerships = List<Map<String, dynamic>>.from(result['partnerships'] ?? []);
        notifyListeners();
      } else {
        _partnershipError = result['error'] ?? 'Failed to get partnerships';
        notifyListeners();
      }
    } catch (e) {
      _partnershipError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingPartnerships = false;
      notifyListeners();
    }
  }

  // Friend Recommendations
  Future<void> getFriendRecommendations({
    required String userId,
    String? category,
    int limit = 10,
  }) async {
    try {
      _isLoadingRecommendations = true;
      _recommendationError = null;
      notifyListeners();

      final result = await _socialCommerceService.getFriendRecommendations(
        userId: userId,
        category: category,
        limit: limit,
      );

      if (result['success'] == true) {
        _friendRecommendations = List<Map<String, dynamic>>.from(result['recommendations']);
        notifyListeners();
      } else {
        _recommendationError = result['error'] ?? 'Failed to get recommendations';
        notifyListeners();
      }
    } catch (e) {
      _recommendationError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  // Social Media
  Future<void> getSocialPlatforms() async {
    try {
      _isLoadingPlatforms = true;
      _platformError = null;
      notifyListeners();

      final result = await _socialCommerceService.getSocialPlatforms();
      if (result['success'] == true) {
        _socialPlatforms = List<Map<String, dynamic>>.from(result['platforms']);
        notifyListeners();
      } else {
        _platformError = result['error'] ?? 'Failed to get platforms';
        notifyListeners();
      }
    } catch (e) {
      _platformError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingPlatforms = false;
      notifyListeners();
    }
  }

  Future<void> shareToSocialMedia({
    required String userId,
    required String platform,
    required String content,
    String? productId,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final result = await _socialCommerceService.shareToSocialMedia(
        userId: userId,
        platform: platform,
        content: content,
        productId: productId,
        imageUrl: imageUrl,
        metadata: metadata,
      );
      // Можно добавить уведомление об успешном шаринге
    } catch (e) {
      _platformError = e.toString();
      notifyListeners();
    }
  }

  // Analytics
  Future<void> getSocialCommerceAnalytics({
    required String userId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoadingAnalytics = true;
      _analyticsError = null;
      notifyListeners();

      final result = await _socialCommerceService.getSocialCommerceAnalytics(
        userId: userId,
        period: period,
        startDate: startDate,
        endDate: endDate,
      );

      if (result['success'] == true) {
        _analytics = result['analytics'];
        notifyListeners();
      } else {
        _analyticsError = result['error'] ?? 'Failed to get analytics';
        notifyListeners();
      }
    } catch (e) {
      _analyticsError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  // Utility methods
  List<String> getAvailableStatuses() => _socialCommerceService.getAvailableStatuses();
  List<String> getAvailableCategories() => _socialCommerceService.getAvailableCategories();
  List<String> getAvailableSortOptions() => _socialCommerceService.getAvailableSortOptions();
  List<String> getAvailablePlatforms() => _socialCommerceService.getAvailablePlatforms();
  List<String> getAvailablePeriods() => _socialCommerceService.getAvailablePeriods();

  // Clear errors
  void clearLiveStreamError() {
    _liveStreamError = null;
    notifyListeners();
  }

  void clearGroupPurchaseError() {
    _groupPurchaseError = null;
    notifyListeners();
  }

  void clearReviewError() {
    _reviewError = null;
    notifyListeners();
  }

  void clearPartnershipError() {
    _partnershipError = null;
    notifyListeners();
  }

  void clearRecommendationError() {
    _recommendationError = null;
    notifyListeners();
  }

  void clearPlatformError() {
    _platformError = null;
    notifyListeners();
  }

  void clearAnalyticsError() {
    _analyticsError = null;
    notifyListeners();
  }

  // Clear all data
  void clearAllData() {
    _liveStreams.clear();
    _currentLiveStream = null;
    _groupPurchases.clear();
    _currentGroupPurchase = null;
    _reviews.clear();
    _currentReview = null;
    _partnerships.clear();
    _currentPartnership = null;
    _friendRecommendations.clear();
    _socialPlatforms.clear();
    _analytics = null;
    notifyListeners();
  }
}
