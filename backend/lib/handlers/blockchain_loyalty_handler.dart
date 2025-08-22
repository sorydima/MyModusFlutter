import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logger/logger.dart';
import '../services/blockchain_loyalty_service.dart';
import '../database.dart';
import '../models.dart';

class BlockchainLoyaltyHandler {
  final BlockchainLoyaltyService _loyaltyService;
  final DatabaseService _db;
  final Logger _logger = Logger();

  BlockchainLoyaltyHandler({
    required BlockchainLoyaltyService loyaltyService,
    required DatabaseService db,
  })  : _loyaltyService = loyaltyService,
        _db = db;

  Router get router {
    final router = Router();

    // Получить профиль лояльности пользователя
    router.get('/profile/<userId>', _getLoyaltyProfile);
    
    // Создать или обновить профиль лояльности
    router.post('/profile', _createOrUpdateProfile);
    
    // Получить статистику лояльности
    router.get('/stats/<userId>', _getLoyaltyStats);
    
    // Получить историю транзакций
    router.get('/transactions/<userId>', _getTransactionHistory);
    
    // Получить доступные награды
    router.get('/rewards', _getAvailableRewards);
    
    // Обменять баллы на криптовалюту
    router.post('/exchange', _exchangePointsForCrypto);
    
    // Начислить баллы за покупку
    router.post('/award-purchase', _awardPointsForPurchase);
    
    // Начислить ежедневную награду за вход
    router.post('/daily-login', _awardDailyLoginReward);
    
    // Создать реферальную связь
    router.post('/referral', _createReferral);
    
    // Получить реферальную статистику
    router.get('/referrals/<userId>', _getReferralStats);
    
    // Получить уровни лояльности
    router.get('/tiers', _getLoyaltyTiers);
    
    // Получить достижения пользователя
    router.get('/achievements/<userId>', _getUserAchievements);
    
    // Получить кошелек пользователя
    router.get('/wallet/<userId>', _getUserWallet);
    
    // Обновить адрес кошелька
    router.put('/wallet', _updateWalletAddress);

    return router;
  }

  /// Получить профиль лояльности пользователя
  Future<Response> _getLoyaltyProfile(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }

      final profile = await _loyaltyService.getOrCreateLoyaltyProfile(userId);
      
      return Response.ok(
        jsonEncode(profile.toJson()),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting loyalty profile: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get loyalty profile: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Создать или обновить профиль лояльности
  Future<Response> _createOrUpdateProfile(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as String?;
      final walletAddress = data['walletAddress'] as String?;
      
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }

      // Получить или создать профиль
      final profile = await _loyaltyService.getOrCreateLoyaltyProfile(userId);
      
      // Обновить адрес кошелька, если предоставлен
      if (walletAddress != null && walletAddress.isNotEmpty) {
        await _db.updateWalletAddress(userId, walletAddress);
      }
      
      return Response.ok(
        jsonEncode({'success': true, 'profile': profile.toJson()}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error creating/updating loyalty profile: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create/update profile: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получить статистику лояльности
  Future<Response> _getLoyaltyStats(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }

      final stats = await _loyaltyService.getUserLoyaltyStats(userId);
      
      return Response.ok(
        jsonEncode(stats),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting loyalty stats: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get loyalty stats: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получить историю транзакций
  Future<Response> _getTransactionHistory(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '50') ?? 50;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final transactions = await _loyaltyService.getUserTransactionHistory(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      
      return Response.ok(
        jsonEncode({
          'transactions': transactions.map((t) => t.toJson()).toList(),
          'total': transactions.length,
          'limit': limit,
          'offset': offset,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting transaction history: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get transaction history: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получить доступные награды
  Future<Response> _getAvailableRewards(Request request) async {
    try {
      final rewards = await _loyaltyService.getAvailableRewards();
      
      return Response.ok(
        jsonEncode({
          'rewards': rewards.map((r) => r.toJson()).toList(),
          'total': rewards.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting available rewards: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get available rewards: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Обменять баллы на криптовалюту
  Future<Response> _exchangePointsForCrypto(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as String?;
      final pointsAmount = data['pointsAmount'] as int?;
      final rewardType = data['rewardType'] as String?;
      
      if (userId == null || pointsAmount == null || rewardType == null) {
        return Response(400, body: jsonEncode({
          'error': 'User ID, points amount, and reward type are required'
        }));
      }

      final result = await _loyaltyService.exchangePointsForCrypto(
        userId: userId,
        pointsAmount: pointsAmount,
        rewardType: rewardType,
      );
      
      if (result['success'] == true) {
        return Response.ok(
          jsonEncode(result),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response(400, body: jsonEncode(result));
      }
    } catch (e) {
      _logger.e('Error exchanging points for crypto: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to exchange points: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Начислить баллы за покупку
  Future<Response> _awardPointsForPurchase(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as String?;
      final purchaseAmount = data['purchaseAmount'] as double?;
      final productId = data['productId'] as String?;
      
      if (userId == null || purchaseAmount == null || productId == null) {
        return Response(400, body: jsonEncode({
          'error': 'User ID, purchase amount, and product ID are required'
        }));
      }

      await _loyaltyService.awardPointsForPurchase(
        userId: userId,
        purchaseAmount: purchaseAmount,
        productId: productId,
      );
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Points awarded successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error awarding points for purchase: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to award points: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Начислить ежедневную награду за вход
  Future<Response> _awardDailyLoginReward(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as String?;
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }

      await _loyaltyService.awardDailyLoginReward(userId);
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Daily login reward awarded'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error awarding daily login reward: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to award daily login reward: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Создать реферальную связь
  Future<Response> _createReferral(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final referrerId = data['referrerId'] as String?;
      final referredId = data['referredId'] as String?;
      final referralCode = data['referralCode'] as String?;
      
      if (referrerId == null || referredId == null || referralCode == null) {
        return Response(400, body: jsonEncode({
          'error': 'Referrer ID, referred ID, and referral code are required'
        }));
      }

      await _loyaltyService.createReferral(
        referrerId: referrerId,
        referredId: referredId,
        referralCode: referralCode,
      );
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Referral created successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error creating referral: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create referral: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получить реферальную статистику
  Future<Response> _getReferralStats(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }

      final referrals = await _db.getUserReferrals(userId);
      final totalEarned = referrals.fold(0.0, (sum, r) => sum + r.cryptoRewarded);
      
      return Response.ok(
        jsonEncode({
          'referrals': referrals.map((r) => r.toJson()).toList(),
          'totalReferrals': referrals.length,
          'totalCryptoEarned': totalEarned,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting referral stats: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get referral stats: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получить уровни лояльности
  Future<Response> _getLoyaltyTiers(Request request) async {
    try {
      final tiers = await _db.getAllLoyaltyTiers();
      
      return Response.ok(
        jsonEncode({
          'tiers': tiers.map((t) => t.toJson()).toList(),
          'total': tiers.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting loyalty tiers: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get loyalty tiers: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получить достижения пользователя
  Future<Response> _getUserAchievements(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }

      final achievements = await _db.getUserAchievements(userId);
      
      return Response.ok(
        jsonEncode({
          'achievements': achievements.map((a) => a.toJson()).toList(),
          'total': achievements.length,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting user achievements: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get user achievements: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Получить кошелек пользователя
  Future<Response> _getUserWallet(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'User ID is required'}));
      }

      final profile = await _db.getLoyaltyProfile(userId);
      if (profile == null) {
        return Response(404, body: jsonEncode({'error': 'Loyalty profile not found'}));
      }
      
      return Response.ok(
        jsonEncode({
          'walletAddress': profile.walletAddress,
          'loyaltyPoints': profile.loyaltyPoints,
          'totalRewardsEarned': profile.totalRewardsEarned,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error getting user wallet: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get user wallet: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Обновить адрес кошелька
  Future<Response> _updateWalletAddress(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as String?;
      final walletAddress = data['walletAddress'] as String?;
      
      if (userId == null || walletAddress == null) {
        return Response(400, body: jsonEncode({
          'error': 'User ID and wallet address are required'
        }));
      }

      await _db.updateWalletAddress(userId, walletAddress);
      
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Wallet address updated successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error updating wallet address: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update wallet address: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
