import 'dart:convert';
import 'package:http/http.dart' as http;

class SocialCommerceService {
  static const String baseUrl = 'http://localhost:8080/api/social-commerce';

  // Live Streams
  Future<Map<String, dynamic>> createLiveStream({
    required String userId,
    required String title,
    required String description,
    required DateTime scheduledTime,
    List<String>? productIds,
    String? thumbnailUrl,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/live-streams'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'title': title,
          'description': description,
          'scheduledTime': scheduledTime.toIso8601String(),
          'productIds': productIds,
          'thumbnailUrl': thumbnailUrl,
          'settings': settings,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create live stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating live stream: $e');
    }
  }

  Future<Map<String, dynamic>> getLiveStreams({
    String? status,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      queryParams['limit'] = limit.toString();
      queryParams['offset'] = offset.toString();

      final uri = Uri.parse('$baseUrl/live-streams').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get live streams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting live streams: $e');
    }
  }

  Future<Map<String, dynamic>> getLiveStream(String streamId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/live-streams/$streamId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get live stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting live stream: $e');
    }
  }

  Future<Map<String, dynamic>> updateLiveStream(String streamId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/live-streams/$streamId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update live stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating live stream: $e');
    }
  }

  Future<Map<String, dynamic>> deleteLiveStream(String streamId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/live-streams/$streamId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete live stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting live stream: $e');
    }
  }

  Future<Map<String, dynamic>> startLiveStream(String streamId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/live-streams/$streamId/start'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to start live stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting live stream: $e');
    }
  }

  Future<Map<String, dynamic>> endLiveStream(String streamId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/live-streams/$streamId/end'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to end live stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error ending live stream: $e');
    }
  }

  // Group Purchases
  Future<Map<String, dynamic>> createGroupPurchase({
    required String productId,
    required String creatorId,
    required int minParticipants,
    required double discountPercent,
    required DateTime deadline,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/group-purchases'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productId': productId,
          'creatorId': creatorId,
          'minParticipants': minParticipants,
          'discountPercent': discountPercent,
          'deadline': deadline.toIso8601String(),
          'description': description,
          'tags': tags,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create group purchase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating group purchase: $e');
    }
  }

  Future<Map<String, dynamic>> getGroupPurchases() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/group-purchases'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get group purchases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting group purchases: $e');
    }
  }

  Future<Map<String, dynamic>> getGroupPurchase(String groupId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/group-purchases/$groupId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get group purchase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting group purchase: $e');
    }
  }

  Future<Map<String, dynamic>> joinGroupPurchase({
    required String groupId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/group-purchases/$groupId/join'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to join group purchase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error joining group purchase: $e');
    }
  }

  Future<Map<String, dynamic>> leaveGroupPurchase(String groupId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/group-purchases/$groupId/leave'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to leave group purchase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error leaving group purchase: $e');
    }
  }

  Future<Map<String, dynamic>> updateGroupPurchase(String groupId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/group-purchases/$groupId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update group purchase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating group purchase: $e');
    }
  }

  Future<Map<String, dynamic>> deleteGroupPurchase(String groupId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/group-purchases/$groupId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete group purchase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting group purchase: $e');
    }
  }

  // Reviews & Ratings
  Future<Map<String, dynamic>> createReview({
    required String userId,
    required String productId,
    required double rating,
    required String comment,
    List<String>? photos,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'productId': productId,
          'rating': rating,
          'comment': comment,
          'photos': photos,
          'additionalData': additionalData,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }

  Future<Map<String, dynamic>> getReviews({
    String? productId,
    String? userId,
    double? minRating,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (productId != null) queryParams['productId'] = productId;
      if (userId != null) queryParams['userId'] = userId;
      if (minRating != null) queryParams['minRating'] = minRating.toString();
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      queryParams['limit'] = limit.toString();
      queryParams['offset'] = offset.toString();

      final uri = Uri.parse('$baseUrl/reviews').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting reviews: $e');
    }
  }

  Future<Map<String, dynamic>> getReview(String reviewId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews/$reviewId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting review: $e');
    }
  }

  Future<Map<String, dynamic>> updateReview(String reviewId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating review: $e');
    }
  }

  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/reviews/$reviewId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }

  Future<Map<String, dynamic>> likeReview(String reviewId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/reviews/$reviewId/like'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to like review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error liking review: $e');
    }
  }

  Future<Map<String, dynamic>> dislikeReview(String reviewId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/reviews/$reviewId/dislike'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to dislike review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error disliking review: $e');
    }
  }

  Future<Map<String, dynamic>> markReviewHelpful(String reviewId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/reviews/$reviewId/helpful'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to mark review helpful: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking review helpful: $e');
    }
  }

  // Influencer Partnerships
  Future<Map<String, dynamic>> createInfluencerPartnership({
    required String influencerId,
    required String brandId,
    required Map<String, dynamic> terms,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/partnerships'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'influencerId': influencerId,
          'brandId': brandId,
          'terms': terms,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create partnership: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating partnership: $e');
    }
  }

  Future<Map<String, dynamic>> getPartnerships() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/partnerships'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get partnerships: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting partnerships: $e');
    }
  }

  Future<Map<String, dynamic>> getPartnership(String partnershipId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/partnerships/$partnershipId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get partnership: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting partnership: $e');
    }
  }

  Future<Map<String, dynamic>> updatePartnership(String partnershipId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/partnerships/$partnershipId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update partnership: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating partnership: $e');
    }
  }

  Future<Map<String, dynamic>> deletePartnership(String partnershipId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/partnerships/$partnershipId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete partnership: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting partnership: $e');
    }
  }

  Future<Map<String, dynamic>> approvePartnership(String partnershipId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/partnerships/$partnershipId/approve'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to approve partnership: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error approving partnership: $e');
    }
  }

  Future<Map<String, dynamic>> rejectPartnership(String partnershipId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/partnerships/$partnershipId/reject'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to reject partnership: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rejecting partnership: $e');
    }
  }

  // Friend Recommendations
  Future<Map<String, dynamic>> getFriendRecommendations({
    required String userId,
    String? category,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/friend-recommendations/$userId').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get friend recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting friend recommendations: $e');
    }
  }

  Future<Map<String, dynamic>> shareRecommendation(String userId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/friend-recommendations/$userId/share'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to share recommendation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sharing recommendation: $e');
    }
  }

  // Social Media Integration
  Future<Map<String, dynamic>> shareToSocialMedia({
    required String userId,
    required String platform,
    required String content,
    String? productId,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/share'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'platform': platform,
          'content': content,
          'productId': productId,
          'imageUrl': imageUrl,
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to share to social media: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sharing to social media: $e');
    }
  }

  Future<Map<String, dynamic>> getSocialPlatforms() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/social/platforms'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get social platforms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting social platforms: $e');
    }
  }

  Future<Map<String, dynamic>> getSocialAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/social/analytics'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get social analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting social analytics: $e');
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getSocialCommerceAnalytics({
    required String userId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl/analytics/$userId').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getTrendsAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics/trends'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get trends analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting trends analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getEngagementAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics/engagement'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get engagement analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting engagement analytics: $e');
    }
  }

  // Utility methods
  List<String> getAvailableStatuses() {
    return ['scheduled', 'live', 'ended'];
  }

  List<String> getAvailableCategories() {
    return ['all', 'clothing', 'shoes', 'accessories', 'beauty', 'home'];
  }

  List<String> getAvailableSortOptions() {
    return ['newest', 'rating', 'helpful'];
  }

  List<String> getAvailablePlatforms() {
    return ['instagram', 'facebook', 'twitter', 'tiktok', 'telegram'];
  }

  List<String> getAvailablePeriods() {
    return ['day', 'week', 'month', 'year'];
  }
}
