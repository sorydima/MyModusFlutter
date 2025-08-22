import 'dart:convert';
import 'dart:math';
import 'package:logger/logger.dart';
import '../database.dart';
import '../models.dart';

class BlockchainLoyaltyService {
  final DatabaseService _db;
  final Logger _logger = Logger();

  BlockchainLoyaltyService({required DatabaseService db}) : _db = db;

  /// Создать или получить профиль лояльности пользователя
  Future<UserLoyaltyProfile> getOrCreateLoyaltyProfile(String userId) async {
    try {
      _logger.i('Getting or creating loyalty profile for user: $userId');
      
      // Попробовать найти существующий профиль
      final existingProfile = await _db.getLoyaltyProfile(userId);
      if (existingProfile != null) {
        return existingProfile;
      }

      // Создать новый профиль
      final profile = await _db.createLoyaltyProfile(userId);
      _logger.i('Created new loyalty profile for user: $userId');
      return profile;
    } catch (e) {
      _logger.e('Error getting/creating loyalty profile: $e');
      rethrow;
    }
  }

  /// Начислить баллы за покупку
  Future<void> awardPointsForPurchase({
    required String userId,
    required double purchaseAmount,
    required String productId,
  }) async {
    try {
      _logger.i('Awarding points for purchase: user=$userId, amount=$purchaseAmount');
      
      // Получить профиль лояльности
      final profile = await getOrCreateLoyaltyProfile(userId);
      
      // Рассчитать баллы (1 балл за каждые 10 рублей)
      final pointsEarned = (purchaseAmount / 10).floor();
      
      // Применить множитель уровня
      final tier = await _db.getLoyaltyTier(profile.loyaltyTier);
      final multiplier = tier?.rewardMultiplier ?? 1.0;
      final finalPoints = (pointsEarned * multiplier).floor();
      
      // Начислить баллы
      await _db.addLoyaltyPoints(userId, finalPoints);
      
      // Создать транзакцию
      await _db.createLoyaltyTransaction(
        userId: userId,
        transactionType: 'purchase',
        pointsAmount: finalPoints.toDouble(),
        description: 'Награда за покупку товара $productId',
        metadata: {
          'productId': productId,
          'purchaseAmount': purchaseAmount,
          'basePoints': pointsEarned,
          'multiplier': multiplier,
          'finalPoints': finalPoints,
        },
      );
      
      // Проверить повышение уровня
      await _checkAndUpdateTier(userId);
      
      _logger.i('Awarded $finalPoints points to user $userId');
    } catch (e) {
      _logger.e('Error awarding points for purchase: $e');
      rethrow;
    }
  }

  /// Начислить баллы за реферала
  Future<void> awardPointsForReferral({
    required String referrerId,
    required String referredId,
  }) async {
    try {
      _logger.i('Awarding referral points: referrer=$referrerId, referred=$referredId');
      
      // Получить награду за реферала
      final reward = await _db.getCryptoReward('referral');
      if (reward == null) {
        throw Exception('Referral reward not configured');
      }
      
      // Начислить баллы
      await _db.addLoyaltyPoints(referrerId, reward.pointsRequired);
      
      // Создать транзакцию
      await _db.createLoyaltyTransaction(
        userId: referrerId,
        transactionType: 'referral',
        pointsAmount: reward.pointsRequired.toDouble(),
        cryptoAmount: reward.cryptoAmount,
        description: 'Награда за приглашение друга',
        metadata: {
          'referredUserId': referredId,
          'rewardType': 'referral',
        },
      );
      
      // Обновить статус реферала
      await _db.updateReferralStatus(referredId, 'completed');
      
      _logger.i('Awarded ${reward.pointsRequired} points for referral');
    } catch (e) {
      _logger.e('Error awarding referral points: $e');
      rethrow;
    }
  }

  /// Начислить ежедневную награду за вход
  Future<void> awardDailyLoginReward(String userId) async {
    try {
      _logger.i('Awarding daily login reward for user: $userId');
      
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      // Проверить, не получена ли уже награда сегодня
      final existingReward = await _db.getDailyLoginReward(userId, todayDate);
      if (existingReward != null) {
        _logger.i('Daily login reward already claimed today for user: $userId');
        return;
      }
      
      // Получить награду за ежедневный вход
      final reward = await _db.getCryptoReward('daily_login');
      if (reward == null) {
        throw Exception('Daily login reward not configured');
      }
      
      // Получить текущую серию входов
      final yesterday = todayDate.subtract(const Duration(days: 1));
      final yesterdayReward = await _db.getDailyLoginReward(userId, yesterday);
      final streakDays = yesterdayReward?.streakDays ?? 0;
      final newStreakDays = streakDays + 1;
      
      // Рассчитать бонус за серию
      final streakBonus = _calculateStreakBonus(newStreakDays);
      final finalPoints = reward.pointsRequired + streakBonus;
      
      // Начислить баллы
      await _db.addLoyaltyPoints(userId, finalPoints);
      
      // Создать транзакцию
      await _db.createLoyaltyTransaction(
        userId: userId,
        transactionType: 'daily_login',
        pointsAmount: finalPoints.toDouble(),
        cryptoAmount: reward.cryptoAmount,
        description: 'Ежедневная награда за вход (серия: $newStreakDays дней)',
        metadata: {
          'streakDays': newStreakDays,
          'basePoints': reward.pointsRequired,
          'streakBonus': streakBonus,
        },
      );
      
      // Сохранить награду за вход
      await _db.createDailyLoginReward(
        userId: userId,
        loginDate: todayDate,
        pointsEarned: finalPoints,
        cryptoEarned: reward.cryptoAmount,
        streakDays: newStreakDays,
      );
      
      _logger.i('Awarded $finalPoints points for daily login (streak: $newStreakDays)');
    } catch (e) {
      _logger.e('Error awarding daily login reward: $e');
      rethrow;
    }
  }

  /// Проверить и обновить уровень лояльности
  Future<void> _checkAndUpdateTier(String userId) async {
    try {
      final profile = await _db.getLoyaltyProfile(userId);
      if (profile == null) return;
      
      // Получить все уровни, отсортированные по минимальным баллам
      final tiers = await _db.getAllLoyaltyTiers();
      tiers.sort((a, b) => a.minPoints.compareTo(b.minPoints));
      
      // Найти подходящий уровень
      LoyaltyTier? newTier;
      for (final tier in tiers.reversed) {
        if (profile.loyaltyPoints >= tier.minPoints && 
            profile.totalSpent >= tier.minSpent) {
          newTier = tier;
          break;
        }
      }
      
      // Обновить уровень, если он изменился
      if (newTier != null && newTier.tierName != profile.loyaltyTier) {
        await _db.updateLoyaltyTier(userId, newTier.tierName);
        
        // Наградить за повышение уровня
        final upgradeReward = await _db.getCryptoReward('tier_upgrade');
        if (upgradeReward != null) {
          await _db.addLoyaltyPoints(userId, upgradeReward.pointsRequired);
          
          await _db.createLoyaltyTransaction(
            userId: userId,
            transactionType: 'tier_upgrade',
            pointsAmount: upgradeReward.pointsRequired.toDouble(),
            cryptoAmount: upgradeReward.cryptoAmount,
            description: 'Награда за повышение до уровня ${newTier.tierName}',
            metadata: {
              'oldTier': profile.loyaltyTier,
              'newTier': newTier.tierName,
              'rewardType': 'tier_upgrade',
            },
          );
        }
        
        _logger.i('User $userId upgraded to tier ${newTier.tierName}');
      }
    } catch (e) {
      _logger.e('Error checking/updating tier: $e');
    }
  }

  /// Рассчитать бонус за серию входов
  int _calculateStreakBonus(int streakDays) {
    if (streakDays >= 30) return 100; // Месячная серия
    if (streakDays >= 7) return 50;   // Недельная серия
    if (streakDays >= 3) return 20;   // Трехдневная серия
    return 0;
  }

  /// Обменять баллы на криптовалюту
  Future<Map<String, dynamic>> exchangePointsForCrypto({
    required String userId,
    required int pointsAmount,
    required String rewardType,
  }) async {
    try {
      _logger.i('Exchanging $pointsAmount points for crypto reward type: $rewardType');
      
      // Получить профиль лояльности
      final profile = await _db.getLoyaltyProfile(userId);
      if (profile == null) {
        throw Exception('Loyalty profile not found');
      }
      
      // Проверить достаточность баллов
      if (profile.loyaltyPoints < pointsAmount) {
        throw Exception('Insufficient loyalty points');
      }
      
      // Получить награду
      final reward = await _db.getCryptoReward(rewardType);
      if (reward == null) {
        throw Exception('Reward type not found: $rewardType');
      }
      
      // Проверить минимальное количество баллов
      if (pointsAmount < reward.pointsRequired) {
        throw Exception('Points amount below minimum required: ${reward.pointsRequired}');
      }
      
      // Проверить дневной лимит
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final dailyClaims = await _db.getDailyRewardClaims(userId, rewardType, todayDate);
      if (dailyClaims >= reward.maxDailyClaims) {
        throw Exception('Daily claim limit reached for reward type: $rewardType');
      }
      
      // Рассчитать количество криптовалюты
      final cryptoAmount = (pointsAmount / reward.pointsRequired) * reward.cryptoAmount;
      
      // Списать баллы
      await _db.deductLoyaltyPoints(userId, pointsAmount);
      
      // Создать транзакцию
      final transaction = await _db.createLoyaltyTransaction(
        userId: userId,
        transactionType: 'exchange',
        pointsAmount: -pointsAmount.toDouble(),
        cryptoAmount: cryptoAmount,
        description: 'Обмен баллов на криптовалюту $rewardType',
        metadata: {
          'rewardType': rewardType,
          'pointsExchanged': pointsAmount,
          'cryptoReceived': cryptoAmount,
          'tokenSymbol': reward.tokenSymbol,
        },
      );
      
      // TODO: Интеграция с блокчейном для отправки токенов
      // await _sendTokensToWallet(profile.walletAddress, cryptoAmount, reward.tokenSymbol);
      
      _logger.i('Successfully exchanged $pointsAmount points for $cryptoAmount ${reward.tokenSymbol}');
      
      return {
        'success': true,
        'transactionId': transaction.id,
        'pointsExchanged': pointsAmount,
        'cryptoReceived': cryptoAmount,
        'tokenSymbol': reward.tokenSymbol,
        'message': 'Обмен успешно выполнен',
      };
    } catch (e) {
      _logger.e('Error exchanging points for crypto: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Ошибка при обмене баллов',
      };
    }
  }

  /// Получить статистику лояльности пользователя
  Future<Map<String, dynamic>> getUserLoyaltyStats(String userId) async {
    try {
      final profile = await _db.getLoyaltyProfile(userId);
      if (profile == null) {
        throw Exception('Loyalty profile not found');
      }
      
      // Получить текущий уровень
      final currentTier = await _db.getLoyaltyTier(profile.loyaltyTier);
      
      // Получить следующий уровень
      final nextTier = await _db.getNextLoyaltyTier(profile.loyaltyPoints);
      
      // Получить историю транзакций
      final transactions = await _db.getLoyaltyTransactions(userId, limit: 10);
      
      // Получить достижения
      final achievements = await _db.getUserAchievements(userId);
      
      // Получить реферальную статистику
      final referrals = await _db.getUserReferrals(userId);
      
      return {
        'profile': profile.toJson(),
        'currentTier': currentTier?.toJson(),
        'nextTier': nextTier?.toJson(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'achievements': achievements.map((a) => a.toJson()).toList(),
        'referrals': referrals.map((r) => r.toJson()).toList(),
        'progressToNextTier': nextTier != null 
            ? ((profile.loyaltyPoints - currentTier!.minPoints) / 
               (nextTier.minPoints - currentTier.minPoints) * 100).clamp(0, 100)
            : 100,
      };
    } catch (e) {
      _logger.e('Error getting user loyalty stats: $e');
      rethrow;
    }
  }

  /// Сгенерировать реферальный код
  String generateReferralCode(String userId) {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(9999).toString().padLeft(4, '0');
    return 'REF${userId.substring(0, 3).toUpperCase()}$timestamp$randomPart';
  }

  /// Создать реферальную связь
  Future<void> createReferral({
    required String referrerId,
    required String referredId,
    required String referralCode,
  }) async {
    try {
      _logger.i('Creating referral: referrer=$referrerId, referred=$referredId');
      
      // Проверить, что пользователь не приглашает сам себя
      if (referrerId == referredId) {
        throw Exception('User cannot refer themselves');
      }
      
      // Проверить, что приглашенный пользователь еще не был приглашен
      final existingReferral = await _db.getUserReferralByReferredId(referredId);
      if (existingReferral != null) {
        throw Exception('User already has a referrer');
      }
      
      // Создать реферальную связь
      await _db.createUserReferral(
        referrerId: referrerId,
        referredId: referredId,
        referralCode: referralCode,
      );
      
      _logger.i('Referral created successfully');
    } catch (e) {
      _logger.e('Error creating referral: $e');
      rethrow;
    }
  }

  /// Получить доступные награды
  Future<List<CryptoReward>> getAvailableRewards() async {
    try {
      return await _db.getActiveCryptoRewards();
    } catch (e) {
      _logger.e('Error getting available rewards: $e');
      rethrow;
    }
  }

  /// Получить историю транзакций пользователя
  Future<List<LoyaltyTransaction>> getUserTransactionHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _db.getLoyaltyTransactions(userId, limit: limit, offset: offset);
    } catch (e) {
      _logger.e('Error getting transaction history: $e');
      rethrow;
    }
  }
}
