import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'real_notification_service.dart';

/// Фронтенд сервис для интеграции уведомлений с другими модулями
class NotificationIntegrationService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api/notification-integration';
  
  final http.Client _httpClient = http.Client();
  final RealNotificationService _notificationService;
  
  NotificationIntegrationService({
    required RealNotificationService notificationService,
  }) : _notificationService = notificationService;

  // ===== AI PERSONAL SHOPPER INTEGRATION =====

  /// Отправка уведомления о новых AI рекомендациях
  Future<bool> notifyNewRecommendations({
    required String userId,
    required List<Map<String, dynamic>> recommendations,
    String? category,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/ai/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'recommendations': recommendations,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('AI recommendations notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send AI recommendations notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending AI recommendations notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о снижении цены
  Future<bool> notifyPriceAlert({
    required String userId,
    required Map<String, dynamic> product,
    required int oldPrice,
    required int newPrice,
    int? discount,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/ai/price-alert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'product': product,
          'oldPrice': oldPrice,
          'newPrice': newPrice,
          'discount': discount,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Price alert notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send price alert notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending price alert notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о персонализированном предложении
  Future<bool> notifyPersonalizedOffer({
    required String userId,
    required String offerType,
    required String description,
    Map<String, dynamic>? offerData,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/ai/personalized-offer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'offerType': offerType,
          'description': description,
          'offerData': offerData,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Personalized offer notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send personalized offer notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending personalized offer notification: $e');
      return false;
    }
  }

  // ===== AR FITTING INTEGRATION =====

  /// Отправка уведомления о завершении AR примерки
  Future<bool> notifyARFittingComplete({
    required String userId,
    required String productName,
    required Map<String, dynamic> fittingResults,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/ar/fitting-complete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'productName': productName,
          'fittingResults': fittingResults,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('AR fitting notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send AR fitting notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending AR fitting notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о рекомендации размера
  Future<bool> notifySizeRecommendation({
    required String userId,
    required String productName,
    required String recommendedSize,
    String? reason,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/ar/size-recommendation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'productName': productName,
          'recommendedSize': recommendedSize,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Size recommendation notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send size recommendation notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending size recommendation notification: $e');
      return false;
    }
  }

  /// Отправка уведомления об обновлении анализа тела
  Future<bool> notifyBodyAnalysisUpdate({
    required String userId,
    required Map<String, dynamic> bodyMetrics,
    String? insight,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/ar/body-analysis-update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'bodyMetrics': bodyMetrics,
          'insight': insight,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Body analysis update notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send body analysis update notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending body analysis update notification: $e');
      return false;
    }
  }

  // ===== BLOCKCHAIN LOYALTY INTEGRATION =====

  /// Отправка уведомления о начислении баллов лояльности
  Future<bool> notifyLoyaltyPointsEarned({
    required String userId,
    required int points,
    required String reason,
    String? source,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/loyalty/points-earned'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'points': points,
          'reason': reason,
          'source': source,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Loyalty points notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send loyalty points notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending loyalty points notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о повышении уровня лояльности
  Future<bool> notifyTierUpgrade({
    required String userId,
    required String oldTier,
    required String newTier,
    required List<String> newBenefits,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/loyalty/tier-upgrade'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'oldTier': oldTier,
          'newTier': newTier,
          'newBenefits': newBenefits,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Tier upgrade notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send tier upgrade notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending tier upgrade notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о реферальном бонусе
  Future<bool> notifyReferralBonus({
    required String userId,
    required String referredUserName,
    required int bonusPoints,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/loyalty/referral-bonus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'referredUserName': referredUserName,
          'bonusPoints': bonusPoints,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Referral bonus notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send referral bonus notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending referral bonus notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о ежедневном входе
  Future<bool> notifyDailyLoginReward({
    required String userId,
    required int points,
    required int streakDays,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/loyalty/daily-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'points': points,
          'streakDays': streakDays,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Daily login reward notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send daily login reward notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending daily login reward notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о крипто-награде
  Future<bool> notifyCryptoReward({
    required String userId,
    required String tokenAmount,
    required String tokenSymbol,
    required String reason,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/loyalty/crypto-reward'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'tokenAmount': tokenAmount,
          'tokenSymbol': tokenSymbol,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Crypto reward notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send crypto reward notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending crypto reward notification: $e');
      return false;
    }
  }

  // ===== SOCIAL ANALYTICS INTEGRATION =====

  /// Отправка уведомления о тренде
  Future<bool> notifyTrendAlert({
    required String userId,
    required String trendType,
    required String description,
    required Map<String, dynamic> trendData,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/analytics/trend-alert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'trendType': trendType,
          'description': description,
          'trendData': trendData,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Trend alert notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send trend alert notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending trend alert notification: $e');
      return false;
    }
  }

  /// Отправка уведомления об обновлении конкурента
  Future<bool> notifyCompetitorUpdate({
    required String userId,
    required String competitorName,
    required String updateType,
    required String description,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/analytics/competitor-update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'competitorName': competitorName,
          'updateType': updateType,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Competitor update notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send competitor update notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending competitor update notification: $e');
      return false;
    }
  }

  /// Отправка уведомления об инсайте аудитории
  Future<bool> notifyAudienceInsight({
    required String userId,
    required String insightType,
    required String description,
    required Map<String, dynamic> insightData,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/analytics/audience-insight'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'insightType': insightType,
          'description': description,
          'insightData': insightData,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Audience insight notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send audience insight notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending audience insight notification: $e');
      return false;
    }
  }

  // ===== SOCIAL COMMERCE INTEGRATION =====

  /// Отправка уведомления о напоминании о live-стриме
  Future<bool> notifyLiveStreamReminder({
    required String userId,
    required String streamTitle,
    required DateTime streamTime,
    String? hostName,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/commerce/live-stream-reminder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'streamTitle': streamTitle,
          'streamTime': streamTime.toIso8601String(),
          'hostName': hostName,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Live stream reminder notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send live stream reminder notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending live stream reminder notification: $e');
      return false;
    }
  }

  /// Отправка уведомления об обновлении групповой покупки
  Future<bool> notifyGroupPurchaseUpdate({
    required String userId,
    required String productName,
    required String updateType,
    required String description,
    Map<String, dynamic>? updateData,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/commerce/group-purchase-update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'productName': productName,
          'updateType': updateType,
          'description': description,
          'updateData': updateData,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Group purchase update notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send group purchase update notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending group purchase update notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о новом отзыве
  Future<bool> notifyNewReview({
    required String userId,
    required String productName,
    required String reviewerName,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/commerce/new-review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'productName': productName,
          'reviewerName': reviewerName,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('New review notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send new review notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending new review notification: $e');
      return false;
    }
  }

  /// Отправка уведомления об одобрении партнерства
  Future<bool> notifyPartnershipApproved({
    required String userId,
    required String partnershipType,
    required String description,
    Map<String, dynamic>? partnershipData,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/commerce/partnership-approved'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'partnershipType': partnershipType,
          'description': description,
          'partnershipData': partnershipData,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Partnership approved notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send partnership approved notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending partnership approved notification: $e');
      return false;
    }
  }

  // ===== SYSTEM NOTIFICATIONS =====

  /// Отправка системного уведомления
  Future<bool> notifySystemUpdate({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/system/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('System update notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send system update notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending system update notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о техническом обслуживании
  Future<bool> notifyMaintenance({
    required String userId,
    required String maintenanceType,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/system/maintenance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'maintenanceType': maintenanceType,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Maintenance notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send maintenance notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending maintenance notification: $e');
      return false;
    }
  }

  /// Отправка уведомления о безопасности
  Future<bool> notifySecurityAlert({
    required String userId,
    required String alertType,
    required String description,
    required String severity,
    Map<String, dynamic>? securityData,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/system/security-alert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'alertType': alertType,
          'description': description,
          'severity': severity,
          'securityData': securityData,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Security alert notification sent successfully');
        return true;
      } else {
        debugPrint('Failed to send security alert notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending security alert notification: $e');
      return false;
    }
  }

  // ===== BULK NOTIFICATIONS =====

  /// Отправка массовых уведомлений по категории
  Future<bool> sendBulkNotificationsByCategory({
    required String category,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    List<String>? excludeUserIds,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/bulk/by-category'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'category': category,
          'title': title,
          'body': body,
          'type': type,
          'data': data,
          'excludeUserIds': excludeUserIds,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Bulk notifications by category sent successfully');
        return true;
      } else {
        debugPrint('Failed to send bulk notifications by category: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending bulk notifications by category: $e');
      return false;
    }
  }

  /// Отправка массовых уведомлений пользователям
  Future<bool> sendBulkNotificationsToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/bulk/to-users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userIds': userIds,
          'title': title,
          'body': body,
          'type': type,
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Bulk notifications to users sent successfully');
        return true;
      } else {
        debugPrint('Failed to send bulk notifications to users: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending bulk notifications to users: $e');
      return false;
    }
  }

  // ===== DEMO AND TESTING =====

  /// Отправка демо уведомлений всех типов
  Future<bool> sendDemoNotifications({String? userId}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/demo/send-all-types'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId ?? 'demo_user_123',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Demo notifications sent successfully');
        return true;
      } else {
        debugPrint('Failed to send demo notifications: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending demo notifications: $e');
      return false;
    }
  }

  /// Симуляция событий модулей
  Future<bool> simulateModuleEvents({
    String? userId,
    String module = 'all',
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/demo/simulate-events'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId ?? 'demo_user_123',
          'module': module,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Module events simulated successfully');
        return true;
      } else {
        debugPrint('Failed to simulate module events: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error simulating module events: $e');
      return false;
    }
  }

  // ===== HELPER METHODS =====

  /// Проверка доступности сервера интеграции
  Future<bool> checkServerAvailability() async {
    try {
      final response = await _httpClient.get(Uri.parse('$baseUrl/demo/send-all-types'));
      return response.statusCode == 405; // Method Not Allowed - значит сервер доступен
    } catch (e) {
      debugPrint('Server not available: $e');
      return false;
    }
  }

  /// Очистка ресурсов
  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}
