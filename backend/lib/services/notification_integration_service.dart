import 'package:logger/logger.dart';
import 'notification_service.dart';
import '../models.dart';

/// Сервис интеграции уведомлений с другими модулями приложения
class NotificationIntegrationService {
  final NotificationService _notificationService;
  final Logger _logger = Logger();

  NotificationIntegrationService({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;

  // ===== AI PERSONAL SHOPPER INTEGRATION =====

  /// Уведомление о новых AI рекомендациях
  Future<void> notifyNewRecommendations({
    required String userId,
    required List<ProductRecommendation> recommendations,
    String? category,
  }) async {
    try {
      final title = '🎯 Новые рекомендации для вас';
      final body = category != null 
          ? 'Открыли $category товары, которые могут вам понравиться'
          : 'У нас есть новые предложения специально для вас';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.newRecommendations,
        title: title,
        body: body,
        data: {
          'recommendations_count': recommendations.length,
          'category': category,
          'product_ids': recommendations.map((r) => r.product.id).toList(),
        },
      );

      _logger.i('Sent new recommendations notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send recommendations notification: $e');
    }
  }

  /// Уведомление о снижении цены на товар из wishlist
  Future<void> notifyPriceAlert({
    required String userId,
    required Product product,
    required int oldPrice,
    required int newPrice,
    int? discount,
  }) async {
    try {
      final priceDiff = oldPrice - newPrice;
      final discountPercent = ((priceDiff / oldPrice) * 100).round();
      
      final title = '💰 Цена снижена!';
      final body = '${product.title} подешевел на $discountPercent% - теперь ${newPrice}₽';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.priceAlert,
        title: title,
        body: body,
        data: {
          'product_id': product.id,
          'old_price': oldPrice,
          'new_price': newPrice,
          'discount_percent': discountPercent,
          'discount_amount': priceDiff,
        },
      );

      _logger.i('Sent price alert notification to user $userId for product ${product.id}');
    } catch (e) {
      _logger.e('Failed to send price alert notification: $e');
    }
  }

  /// Уведомление о персонализированном предложении
  Future<void> notifyPersonalizedOffer({
    required String userId,
    required String offerType,
    required String description,
    Map<String, dynamic>? offerData,
  }) async {
    try {
      final title = '🎁 Персональное предложение';
      final body = description;

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.personalizedOffer,
        title: title,
        body: body,
        data: {
          'offer_type': offerType,
          ...?offerData,
        },
      );

      _logger.i('Sent personalized offer notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send personalized offer notification: $e');
    }
  }

  // ===== AR FITTING INTEGRATION =====

  /// Уведомление о завершении AR примерки
  Future<void> notifyARFittingComplete({
    required String userId,
    required String productName,
    required Map<String, dynamic> fittingResults,
  }) async {
    try {
      final title = '👗 Примерка завершена';
      final body = 'Результаты примерки $productName готовы';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.arFittingComplete,
        title: title,
        body: body,
        data: {
          'product_name': productName,
          'fitting_results': fittingResults,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent AR fitting complete notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send AR fitting notification: $e');
    }
  }

  /// Уведомление о рекомендации размера
  Future<void> notifySizeRecommendation({
    required String userId,
    required String productName,
    required String recommendedSize,
    String? reason,
  }) async {
    try {
      final title = '📏 Рекомендация размера';
      final body = 'Для $productName рекомендуем размер $recommendedSize';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.sizeRecommendation,
        title: title,
        body: body,
        data: {
          'product_name': productName,
          'recommended_size': recommendedSize,
          'reason': reason,
        },
      );

      _logger.i('Sent size recommendation notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send size recommendation notification: $e');
    }
  }

  /// Уведомление об обновлении анализа тела
  Future<void> notifyBodyAnalysisUpdate({
    required String userId,
    required Map<String, dynamic> bodyMetrics,
    String? insight,
  }) async {
    try {
      final title = '📊 Обновление анализа тела';
      final body = insight ?? 'Ваши параметры обновлены';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.bodyAnalysisUpdate,
        title: title,
        body: body,
        data: {
          'body_metrics': bodyMetrics,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent body analysis update notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send body analysis notification: $e');
    }
  }

  // ===== BLOCKCHAIN LOYALTY INTEGRATION =====

  /// Уведомление о начислении баллов лояльности
  Future<void> notifyLoyaltyPointsEarned({
    required String userId,
    required int points,
    required String reason,
    String? source,
  }) async {
    try {
      final title = '⭐ Бонусные баллы начислены';
      final body = 'Вы получили $points баллов за $reason';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.loyaltyPointsEarned,
        title: title,
        body: body,
        data: {
          'points': points,
          'reason': reason,
          'source': source,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent loyalty points notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send loyalty points notification: $e');
    }
  }

  /// Уведомление о повышении уровня лояльности
  Future<void> notifyTierUpgrade({
    required String userId,
    required String oldTier,
    required String newTier,
    required List<String> newBenefits,
  }) async {
    try {
      final title = '🏆 Уровень повышен!';
      final body = 'Поздравляем! Вы достигли уровня $newTier';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.tierUpgrade,
        title: title,
        body: body,
        data: {
          'old_tier': oldTier,
          'new_tier': newTier,
          'new_benefits': newBenefits,
          'upgraded_at': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent tier upgrade notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send tier upgrade notification: $e');
    }
  }

  /// Уведомление о реферальном бонусе
  Future<void> notifyReferralBonus({
    required String userId,
    required String referredUserName,
    required int bonusPoints,
  }) async {
    try {
      final title = '👥 Реферальный бонус';
      final body = 'Ваш друг $referredUserName присоединился! Вы получили $bonusPoints баллов';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.referralBonus,
        title: title,
        body: body,
        data: {
          'referred_user_name': referredUserName,
          'bonus_points': bonusPoints,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent referral bonus notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send referral bonus notification: $e');
    }
  }

  /// Уведомление о ежедневном входе
  Future<void> notifyDailyLoginReward({
    required String userId,
    required int points,
    required int streakDays,
  }) async {
    try {
      final title = '🌅 Ежедневный бонус';
      final body = 'Сегодня вы получили $points баллов! Серия: $streakDays дней';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.dailyLoginReward,
        title: title,
        body: body,
        data: {
          'points': points,
          'streak_days': streakDays,
          'login_date': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent daily login reward notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send daily login reward notification: $e');
    }
  }

  /// Уведомление о крипто-награде
  Future<void> notifyCryptoReward({
    required String userId,
    required String tokenAmount,
    required String tokenSymbol,
    required String reason,
  }) async {
    try {
      final title = '🪙 Крипто-награда';
      final body = 'Вы получили $tokenAmount $tokenSymbol за $reason';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.cryptoReward,
        title: title,
        body: body,
        data: {
          'token_amount': tokenAmount,
          'token_symbol': tokenSymbol,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent crypto reward notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send crypto reward notification: $e');
    }
  }

  // ===== SOCIAL ANALYTICS INTEGRATION =====

  /// Уведомление о тренде
  Future<void> notifyTrendAlert({
    required String userId,
    required String trendType,
    required String description,
    required Map<String, dynamic> trendData,
  }) async {
    try {
      final title = '📈 Новый тренд';
      final body = description;

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.trendAlert,
        title: title,
        body: body,
        data: {
          'trend_type': trendType,
          'trend_data': trendData,
          'detected_at': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent trend alert notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send trend alert notification: $e');
    }
  }

  /// Уведомление об обновлении конкурента
  Future<void> notifyCompetitorUpdate({
    required String userId,
    required String competitorName,
    required String updateType,
    required String description,
  }) async {
    try {
      final title = '👀 Обновление конкурента';
      final body = '$competitorName: $description';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.competitorUpdate,
        title: title,
        body: body,
        data: {
          'competitor_name': competitorName,
          'update_type': updateType,
          'description': description,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent competitor update notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send competitor update notification: $e');
    }
  }

  /// Уведомление об инсайте аудитории
  Future<void> notifyAudienceInsight({
    required String userId,
    required String insightType,
    required String description,
    required Map<String, dynamic> insightData,
  }) async {
    try {
      final title = '👥 Инсайт аудитории';
      final body = description;

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.audienceInsight,
        title: title,
        body: body,
        data: {
          'insight_type': insightType,
          'insight_data': insightData,
          'discovered_at': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent audience insight notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send audience insight notification: $e');
    }
  }

  // ===== SOCIAL COMMERCE INTEGRATION =====

  /// Уведомление о напоминании о live-стриме
  Future<void> notifyLiveStreamReminder({
    required String userId,
    required String streamTitle,
    required DateTime streamTime,
    String? hostName,
  }) async {
    try {
      final timeUntil = streamTime.difference(DateTime.now());
      final minutesUntil = timeUntil.inMinutes;
      
      String body;
      if (minutesUntil <= 0) {
        body = 'Live-стрим "$streamTitle" начинается сейчас!';
      } else if (minutesUntil < 60) {
        body = 'Live-стрим "$streamTitle" через $minutesUntil минут';
      } else {
        final hoursUntil = timeUntil.inHours;
        body = 'Live-стрим "$streamTitle" через $hoursUntil часов';
      }

      final title = '📺 Напоминание о live-стриме';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.liveStreamReminder,
        title: title,
        body: body,
        data: {
          'stream_title': streamTitle,
          'stream_time': streamTime.toIso8601String(),
          'host_name': hostName,
          'minutes_until': minutesUntil,
        },
      );

      _logger.i('Sent live stream reminder notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send live stream reminder notification: $e');
    }
  }

  /// Уведомление об обновлении групповой покупки
  Future<void> notifyGroupPurchaseUpdate({
    required String userId,
    required String productName,
    required String updateType,
    required String description,
    Map<String, dynamic>? updateData,
  }) async {
    try {
      final title = '👥 Групповая покупка';
      final body = description;

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.groupPurchaseUpdate,
        title: title,
        body: body,
        data: {
          'product_name': productName,
          'update_type': updateType,
          'update_data': updateData,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent group purchase update notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send group purchase update notification: $e');
    }
  }

  /// Уведомление о новом отзыве
  Future<void> notifyNewReview({
    required String userId,
    required String productName,
    required String reviewerName,
    required int rating,
    String? comment,
  }) async {
    try {
      final title = '⭐ Новый отзыв';
      final body = '$reviewerName оставил отзыв на $productName';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.newReview,
        title: title,
        body: body,
        data: {
          'product_name': productName,
          'reviewer_name': reviewerName,
          'rating': rating,
          'comment': comment,
          'reviewed_at': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent new review notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send new review notification: $e');
    }
  }

  /// Уведомление об одобрении партнерства
  Future<void> notifyPartnershipApproved({
    required String userId,
    required String partnershipType,
    required String description,
    Map<String, dynamic>? partnershipData,
  }) async {
    try {
      final title = '🤝 Партнерство одобрено';
      final body = description;

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.partnershipApproved,
        title: title,
        body: body,
        data: {
          'partnership_type': partnershipType,
          'partnership_data': partnershipData,
          'approved_at': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent partnership approved notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send partnership approved notification: $e');
    }
  }

  // ===== GENERAL SYSTEM NOTIFICATIONS =====

  /// Системное уведомление
  Future<void> notifySystemUpdate({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.systemUpdate,
        title: title,
        body: body,
        data: data,
      );

      _logger.i('Sent system update notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send system update notification: $e');
    }
  }

  /// Уведомление о техническом обслуживании
  Future<void> notifyMaintenance({
    required String userId,
    required String maintenanceType,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
  }) async {
    try {
      final title = '🔧 Техническое обслуживание';
      final body = description ?? 'Запланировано техническое обслуживание';

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.maintenance,
        title: title,
        body: body,
        data: {
          'maintenance_type': maintenanceType,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'description': description,
        },
      );

      _logger.i('Sent maintenance notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send maintenance notification: $e');
    }
  }

  /// Уведомление о безопасности
  Future<void> notifySecurityAlert({
    required String userId,
    required String alertType,
    required String description,
    required String severity,
    Map<String, dynamic>? securityData,
  }) async {
    try {
      final title = '🔒 Уведомление о безопасности';
      final body = description;

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.securityAlert,
        title: title,
        body: body,
        data: {
          'alert_type': alertType,
          'severity': severity,
          'security_data': securityData,
          'alerted_at': DateTime.now().toIso8601String(),
        },
      );

      _logger.i('Sent security alert notification to user $userId');
    } catch (e) {
      _logger.e('Failed to send security alert notification: $e');
    }
  }

  // ===== BULK NOTIFICATIONS =====

  /// Отправка массовых уведомлений по категории пользователей
  Future<void> sendBulkNotificationsByCategory({
    required String category,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    List<String>? excludeUserIds,
  }) async {
    try {
      // Получаем список пользователей по категории
      final userIds = await _getUserIdsByCategory(category);
      
      if (excludeUserIds != null) {
        userIds.removeWhere((id) => excludeUserIds.contains(id));
      }

      // Отправляем уведомления
      for (final userId in userIds) {
        await _notificationService.createNotification(
          userId: userId,
          type: type,
          title: title,
          body: body,
          data: data,
        );
      }

      _logger.i('Sent bulk notifications to ${userIds.length} users in category $category');
    } catch (e) {
      _logger.e('Failed to send bulk notifications: $e');
    }
  }

  /// Отправка уведомлений по списку пользователей
  Future<void> sendBulkNotificationsToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      for (final userId in userIds) {
        await _notificationService.createNotification(
          userId: userId,
          type: type,
          title: title,
          body: body,
          data: data,
        );
      }

      _logger.i('Sent bulk notifications to ${userIds.length} users');
    } catch (e) {
      _logger.e('Failed to send bulk notifications: $e');
    }
  }

  // ===== HELPER METHODS =====

  /// Получение ID пользователей по категории (заглушка)
  Future<List<String>> _getUserIdsByCategory(String category) async {
    // В реальном приложении здесь будет запрос к базе данных
    // Пока возвращаем пустой список
    return [];
  }

  /// Очистка ресурсов
  void dispose() {
    // Нет ресурсов для очистки
  }
}
