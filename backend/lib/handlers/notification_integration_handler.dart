import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/notification_integration_service.dart';
import '../database.dart';

/// API Handler для интеграции уведомлений с другими модулями
class NotificationIntegrationHandler {
  final NotificationIntegrationService _integrationService;
  final DatabaseService _database;

  NotificationIntegrationHandler({
    required NotificationIntegrationService integrationService,
    required DatabaseService database,
  })  : _integrationService = integrationService,
        _database = database;

  Router get router {
    final router = Router();

    // ===== AI PERSONAL SHOPPER INTEGRATION =====
    
    // Уведомления о рекомендациях
    router.post('/ai/recommendations', _notifyNewRecommendations);
    router.post('/ai/price-alert', _notifyPriceAlert);
    router.post('/ai/personalized-offer', _notifyPersonalizedOffer);
    
    // ===== AR FITTING INTEGRATION =====
    
    // Уведомления о примерке
    router.post('/ar/fitting-complete', _notifyARFittingComplete);
    router.post('/ar/size-recommendation', _notifySizeRecommendation);
    router.post('/ar/body-analysis-update', _notifyBodyAnalysisUpdate);
    
    // ===== BLOCKCHAIN LOYALTY INTEGRATION =====
    
    // Уведомления о лояльности
    router.post('/loyalty/points-earned', _notifyLoyaltyPointsEarned);
    router.post('/loyalty/tier-upgrade', _notifyTierUpgrade);
    router.post('/loyalty/referral-bonus', _notifyReferralBonus);
    router.post('/loyalty/daily-login', _notifyDailyLoginReward);
    router.post('/loyalty/crypto-reward', _notifyCryptoReward);
    
    // ===== SOCIAL ANALYTICS INTEGRATION =====
    
    // Уведомления об аналитике
    router.post('/analytics/trend-alert', _notifyTrendAlert);
    router.post('/analytics/competitor-update', _notifyCompetitorUpdate);
    router.post('/analytics/audience-insight', _notifyAudienceInsight);
    
    // ===== SOCIAL COMMERCE INTEGRATION =====
    
    // Уведомления о коммерции
    router.post('/commerce/live-stream-reminder', _notifyLiveStreamReminder);
    router.post('/commerce/group-purchase-update', _notifyGroupPurchaseUpdate);
    router.post('/commerce/new-review', _notifyNewReview);
    router.post('/commerce/partnership-approved', _notifyPartnershipApproved);
    
    // ===== SYSTEM NOTIFICATIONS =====
    
    // Системные уведомления
    router.post('/system/update', _notifySystemUpdate);
    router.post('/system/maintenance', _notifyMaintenance);
    router.post('/system/security-alert', _notifySecurityAlert);
    
    // ===== BULK NOTIFICATIONS =====
    
    // Массовые уведомления
    router.post('/bulk/by-category', _sendBulkNotificationsByCategory);
    router.post('/bulk/to-users', _sendBulkNotificationsToUsers);
    
    // ===== TESTING AND DEMO =====
    
    // Тестовые уведомления для демонстрации
    router.post('/demo/send-all-types', _sendDemoNotifications);
    router.post('/demo/simulate-events', _simulateModuleEvents);

    return router;
  }

  // ===== AI PERSONAL SHOPPER HANDLERS =====

  Future<Response> _notifyNewRecommendations(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final recommendations = data['recommendations'] as List;
      final category = data['category'];

      if (userId == null || recommendations == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID and recommendations are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Преобразуем рекомендации в нужный формат
      final productRecommendations = recommendations.map((r) {
        return ProductRecommendation(
          product: Product.fromJson(r['product']),
          score: (r['score'] as num).toDouble(),
          reason: r['reason'] ?? '',
        );
      }).toList();

      await _integrationService.notifyNewRecommendations(
        userId: userId,
        recommendations: productRecommendations,
        category: category,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Recommendations notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyPriceAlert(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final productData = data['product'];
      final oldPrice = data['oldPrice'];
      final newPrice = data['newPrice'];
      final discount = data['discount'];

      if (userId == null || productData == null || oldPrice == null || newPrice == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, product, old price, and new price are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final product = Product.fromJson(productData);

      await _integrationService.notifyPriceAlert(
        userId: userId,
        product: product,
        oldPrice: oldPrice,
        newPrice: newPrice,
        discount: discount,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Price alert notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyPersonalizedOffer(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final offerType = data['offerType'];
      final description = data['description'];
      final offerData = data['offerData'];

      if (userId == null || offerType == null || description == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, offer type, and description are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyPersonalizedOffer(
        userId: userId,
        offerType: offerType,
        description: description,
        offerData: offerData,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Personalized offer notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== AR FITTING HANDLERS =====

  Future<Response> _notifyARFittingComplete(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final productName = data['productName'];
      final fittingResults = data['fittingResults'];

      if (userId == null || productName == null || fittingResults == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, product name, and fitting results are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyARFittingComplete(
        userId: userId,
        productName: productName,
        fittingResults: Map<String, dynamic>.from(fittingResults),
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'AR fitting notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifySizeRecommendation(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final productName = data['productName'];
      final recommendedSize = data['recommendedSize'];
      final reason = data['reason'];

      if (userId == null || productName == null || recommendedSize == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, product name, and recommended size are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifySizeRecommendation(
        userId: userId,
        productName: productName,
        recommendedSize: recommendedSize,
        reason: reason,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Size recommendation notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyBodyAnalysisUpdate(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final bodyMetrics = data['bodyMetrics'];
      final insight = data['insight'];

      if (userId == null || bodyMetrics == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID and body metrics are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyBodyAnalysisUpdate(
        userId: userId,
        bodyMetrics: Map<String, dynamic>.from(bodyMetrics),
        insight: insight,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Body analysis update notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== BLOCKCHAIN LOYALTY HANDLERS =====

  Future<Response> _notifyLoyaltyPointsEarned(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final points = data['points'];
      final reason = data['reason'];
      final source = data['source'];

      if (userId == null || points == null || reason == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, points, and reason are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyLoyaltyPointsEarned(
        userId: userId,
        points: points,
        reason: reason,
        source: source,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Loyalty points notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyTierUpgrade(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final oldTier = data['oldTier'];
      final newTier = data['newTier'];
      final newBenefits = List<String>.from(data['newBenefits'] ?? []);

      if (userId == null || oldTier == null || newTier == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, old tier, and new tier are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyTierUpgrade(
        userId: userId,
        oldTier: oldTier,
        newTier: newTier,
        newBenefits: newBenefits,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Tier upgrade notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyReferralBonus(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final referredUserName = data['referredUserName'];
      final bonusPoints = data['bonusPoints'];

      if (userId == null || referredUserName == null || bonusPoints == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, referred user name, and bonus points are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyReferralBonus(
        userId: userId,
        referredUserName: referredUserName,
        bonusPoints: bonusPoints,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Referral bonus notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyDailyLoginReward(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final points = data['points'];
      final streakDays = data['streakDays'];

      if (userId == null || points == null || streakDays == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, points, and streak days are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyDailyLoginReward(
        userId: userId,
        points: points,
        streakDays: streakDays,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Daily login reward notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyCryptoReward(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final tokenAmount = data['tokenAmount'];
      final tokenSymbol = data['tokenSymbol'];
      final reason = data['reason'];

      if (userId == null || tokenAmount == null || tokenSymbol == null || reason == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, token amount, token symbol, and reason are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyCryptoReward(
        userId: userId,
        tokenAmount: tokenAmount,
        tokenSymbol: tokenSymbol,
        reason: reason,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Crypto reward notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== SOCIAL ANALYTICS HANDLERS =====

  Future<Response> _notifyTrendAlert(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final trendType = data['trendType'];
      final description = data['description'];
      final trendData = data['trendData'];

      if (userId == null || trendType == null || description == null || trendData == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, trend type, description, and trend data are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyTrendAlert(
        userId: userId,
        trendType: trendType,
        description: description,
        trendData: Map<String, dynamic>.from(trendData),
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Trend alert notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyCompetitorUpdate(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final competitorName = data['competitorName'];
      final updateType = data['updateType'];
      final description = data['description'];

      if (userId == null || competitorName == null || updateType == null || description == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, competitor name, update type, and description are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyCompetitorUpdate(
        userId: userId,
        competitorName: competitorName,
        updateType: updateType,
        description: description,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Competitor update notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyAudienceInsight(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final insightType = data['insightType'];
      final description = data['description'];
      final insightData = data['insightData'];

      if (userId == null || insightType == null || description == null || insightData == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, insight type, description, and insight data are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyAudienceInsight(
        userId: userId,
        insightType: insightType,
        description: description,
        insightData: Map<String, dynamic>.from(insightData),
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Audience insight notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== SOCIAL COMMERCE HANDLERS =====

  Future<Response> _notifyLiveStreamReminder(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final streamTitle = data['streamTitle'];
      final streamTime = DateTime.parse(data['streamTime']);
      final hostName = data['hostName'];

      if (userId == null || streamTitle == null || data['streamTime'] == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, stream title, and stream time are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyLiveStreamReminder(
        userId: userId,
        streamTitle: streamTitle,
        streamTime: streamTime,
        hostName: hostName,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Live stream reminder notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyGroupPurchaseUpdate(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final productName = data['productName'];
      final updateType = data['updateType'];
      final description = data['description'];
      final updateData = data['updateData'];

      if (userId == null || productName == null || updateType == null || description == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, product name, update type, and description are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyGroupPurchaseUpdate(
        userId: userId,
        productName: productName,
        updateType: updateType,
        description: description,
        updateData: updateData != null ? Map<String, dynamic>.from(updateData) : null,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Group purchase update notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyNewReview(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final productName = data['productName'];
      final reviewerName = data['reviewerName'];
      final rating = data['rating'];
      final comment = data['comment'];

      if (userId == null || productName == null || reviewerName == null || rating == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, product name, reviewer name, and rating are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyNewReview(
        userId: userId,
        productName: productName,
        reviewerName: reviewerName,
        rating: rating,
        comment: comment,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'New review notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyPartnershipApproved(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final partnershipType = data['partnershipType'];
      final description = data['description'];
      final partnershipData = data['partnershipData'];

      if (userId == null || partnershipType == null || description == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, partnership type, and description are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyPartnershipApproved(
        userId: userId,
        partnershipType: partnershipType,
        description: description,
        partnershipData: partnershipData != null ? Map<String, dynamic>.from(partnershipData) : null,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Partnership approved notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== SYSTEM NOTIFICATION HANDLERS =====

  Future<Response> _notifySystemUpdate(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final title = data['title'];
      final bodyText = data['body'];
      final notificationData = data['data'];

      if (userId == null || title == null || bodyText == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, title, and body are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifySystemUpdate(
        userId: userId,
        title: title,
        body: bodyText,
        data: notificationData != null ? Map<String, dynamic>.from(notificationData) : null,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'System update notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifyMaintenance(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final maintenanceType = data['maintenanceType'];
      final startTime = DateTime.parse(data['startTime']);
      final endTime = DateTime.parse(data['endTime']);
      final description = data['description'];

      if (userId == null || maintenanceType == null || data['startTime'] == null || data['endTime'] == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, maintenance type, start time, and end time are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifyMaintenance(
        userId: userId,
        maintenanceType: maintenanceType,
        startTime: startTime,
        endTime: endTime,
        description: description,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Maintenance notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _notifySecurityAlert(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'];
      final alertType = data['alertType'];
      final description = data['description'];
      final severity = data['severity'];
      final securityData = data['securityData'];

      if (userId == null || alertType == null || description == null || severity == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID, alert type, description, and severity are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      await _integrationService.notifySecurityAlert(
        userId: userId,
        alertType: alertType,
        description: description,
        severity: severity,
        securityData: securityData != null ? Map<String, dynamic>.from(securityData) : null,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Security alert notification sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== BULK NOTIFICATION HANDLERS =====

  Future<Response> _sendBulkNotificationsByCategory(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final category = data['category'];
      final title = data['title'];
      final bodyText = data['body'];
      final type = data['type'];
      final notificationData = data['data'];
      final excludeUserIds = data['excludeUserIds'];

      if (category == null || title == null || bodyText == null || type == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Category, title, body, and type are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Преобразуем тип уведомления
      final notificationType = NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
        orElse: () => NotificationType.systemUpdate,
      );

      await _integrationService.sendBulkNotificationsByCategory(
        category: category,
        title: title,
        body: bodyText,
        type: notificationType,
        data: notificationData != null ? Map<String, dynamic>.from(notificationData) : null,
        excludeUserIds: excludeUserIds != null ? List<String>.from(excludeUserIds) : null,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Bulk notifications sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _sendBulkNotificationsToUsers(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userIds = List<String>.from(data['userIds'] ?? []);
      final title = data['title'];
      final bodyText = data['body'];
      final type = data['type'];
      final notificationData = data['data'];

      if (userIds.isEmpty || title == null || bodyText == null || type == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User IDs, title, body, and type are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Преобразуем тип уведомления
      final notificationType = NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
        orElse: () => NotificationType.systemUpdate,
      );

      await _integrationService.sendBulkNotificationsToUsers(
        userIds: userIds,
        title: title,
        body: bodyText,
        type: notificationType,
        data: notificationData != null ? Map<String, dynamic>.from(notificationData) : null,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Bulk notifications sent successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ===== DEMO AND TESTING HANDLERS =====

  Future<Response> _sendDemoNotifications(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'] ?? 'demo_user_123';

      // Отправляем уведомления всех типов для демонстрации
      await _integrationService.notifyNewRecommendations(
        userId: userId,
        recommendations: [
          ProductRecommendation(
            product: Product(
              id: 'demo_product_1',
              title: 'Демо товар 1',
              description: 'Описание демо товара',
              price: 1000,
              imageUrl: 'https://example.com/image1.jpg',
              productUrl: 'https://example.com/product1',
              source: 'demo',
              sourceId: '1',
              categoryId: 'demo_category',
            ),
            score: 0.95,
            reason: 'Демо рекомендация',
          ),
        ],
        category: 'Демо категория',
      );

      await _integrationService.notifyPriceAlert(
        userId: userId,
        product: Product(
          id: 'demo_product_2',
          title: 'Демо товар 2',
          description: 'Описание демо товара',
          price: 800,
          imageUrl: 'https://example.com/image2.jpg',
          productUrl: 'https://example.com/product2',
          source: 'demo',
          sourceId: '2',
          categoryId: 'demo_category',
        ),
        oldPrice: 1000,
        newPrice: 800,
        discount: 200,
      );

      await _integrationService.notifyLoyaltyPointsEarned(
        userId: userId,
        points: 100,
        reason: 'Демо активность',
        source: 'demo',
      );

      await _integrationService.notifyARFittingComplete(
        userId: userId,
        productName: 'Демо товар для примерки',
        fittingResults: {
          'size': 'M',
          'fit': 'perfect',
          'confidence': 0.95,
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Demo notifications sent successfully',
          'notifications_sent': 4,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _simulateModuleEvents(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userId = data['userId'] ?? 'demo_user_123';
      final module = data['module'] ?? 'all';

      switch (module) {
        case 'ai':
          await _integrationService.notifyNewRecommendations(
            userId: userId,
            recommendations: [
              ProductRecommendation(
                product: Product(
                  id: 'ai_product_1',
                  title: 'AI рекомендованный товар',
                  description: 'Товар, рекомендованный AI',
                  price: 1500,
                  imageUrl: 'https://example.com/ai1.jpg',
                  productUrl: 'https://example.com/ai1',
                  source: 'ai',
                  sourceId: 'ai1',
                  categoryId: 'ai_category',
                ),
                score: 0.98,
                reason: 'Высокий рейтинг AI',
              ),
            ],
          );
          break;

        case 'ar':
          await _integrationService.notifySizeRecommendation(
            userId: userId,
            productName: 'AR товар',
            recommendedSize: 'L',
            reason: 'На основе ваших параметров',
          );
          break;

        case 'loyalty':
          await _integrationService.notifyTierUpgrade(
            userId: userId,
            oldTier: 'Bronze',
            newTier: 'Silver',
            newBenefits: ['Скидка 5%', 'Приоритетная поддержка'],
          );
          break;

        case 'analytics':
          await _integrationService.notifyTrendAlert(
            userId: userId,
            trendType: 'Мода',
            description: 'Новый тренд в категории "Одежда"',
            trendData: {
              'category': 'Одежда',
              'trend_score': 0.85,
              'growth_rate': '+15%',
            },
          );
          break;

        case 'commerce':
          await _integrationService.notifyLiveStreamReminder(
            userId: userId,
            streamTitle: 'Демо live-стрим',
            streamTime: DateTime.now().add(const Duration(minutes: 30)),
            hostName: 'Демо ведущий',
          );
          break;

        case 'all':
        default:
          // Симулируем события всех модулей
          await _simulateAllModuleEvents(userId);
          break;
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Module events simulated successfully',
          'module': module,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Симуляция событий всех модулей
  Future<void> _simulateAllModuleEvents(String userId) async {
    // AI Personal Shopper
    await _integrationService.notifyPersonalizedOffer(
      userId: userId,
      offerType: 'Скидка',
      description: 'Персональная скидка 20% на ваш любимый бренд',
      offerData: {'discount': 20, 'brand': 'Демо бренд'},
    );

    // AR Fitting
    await _integrationService.notifyBodyAnalysisUpdate(
      userId: userId,
      bodyMetrics: {
        'height': 175,
        'weight': 70,
        'chest': 95,
        'waist': 80,
      },
      insight: 'Ваши параметры обновлены на основе последней примерки',
    );

    // Blockchain Loyalty
    await _integrationService.notifyReferralBonus(
      userId: userId,
      referredUserName: 'Демо пользователь',
      bonusPoints: 50,
    );

    // Social Analytics
    await _integrationService.notifyCompetitorUpdate(
      userId: userId,
      competitorName: 'Демо конкурент',
      updateType: 'Новая коллекция',
      description: 'Конкурент выпустил новую коллекцию',
    );

    // Social Commerce
    await _integrationService.notifyGroupPurchaseUpdate(
      userId: userId,
      productName: 'Демо товар для групповой покупки',
      updateType: 'Достигнута минимальная группа',
      description: 'Групповая покупка активирована!',
      updateData: {'group_size': 5, 'discount': 15},
    );
  }
}
