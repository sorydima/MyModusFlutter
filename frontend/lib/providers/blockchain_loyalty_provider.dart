import 'package:flutter/foundation.dart';
import '../services/blockchain_loyalty_service.dart';

class BlockchainLoyaltyProvider extends ChangeNotifier {
  final BlockchainLoyaltyService _loyaltyService = BlockchainLoyaltyService();
  
  // State variables
  Map<String, dynamic>? _loyaltyProfile;
  Map<String, dynamic>? _loyaltyStats;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _rewards = [];
  List<Map<String, dynamic>> _tiers = [];
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _referrals = [];
  Map<String, dynamic>? _walletInfo;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  Map<String, dynamic>? get loyaltyProfile => _loyaltyProfile;
  Map<String, dynamic>? get loyaltyStats => _loyaltyStats;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get rewards => _rewards;
  List<Map<String, dynamic>> get tiers => _tiers;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get referrals => _referrals;
  Map<String, dynamic>? get walletInfo => _walletInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Получить профиль лояльности
  Future<void> getLoyaltyProfile(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final profile = await _loyaltyService.getLoyaltyProfile(userId);
      _loyaltyProfile = profile;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get loyalty profile: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Создать или обновить профиль лояльности
  Future<void> createOrUpdateProfile({
    required String userId,
    String? walletAddress,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.createOrUpdateProfile(
        userId: userId,
        walletAddress: walletAddress,
      );
      
      if (result['success'] == true) {
        _loyaltyProfile = result['profile'];
        notifyListeners();
      } else {
        _setError('Failed to create/update profile');
      }
    } catch (e) {
      _setError('Failed to create/update profile: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить статистику лояльности
  Future<void> getLoyaltyStats(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final stats = await _loyaltyService.getLoyaltyStats(userId);
      _loyaltyStats = stats;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get loyalty stats: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить историю транзакций
  Future<void> getTransactionHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.getTransactionHistory(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      
      _transactions = List<Map<String, dynamic>>.from(result['transactions'] ?? []);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get transaction history: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить доступные награды
  Future<void> getAvailableRewards() async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.getAvailableRewards();
      _rewards = List<Map<String, dynamic>>.from(result['rewards'] ?? []);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get available rewards: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Обменять баллы на криптовалюту
  Future<Map<String, dynamic>> exchangePointsForCrypto({
    required String userId,
    required int pointsAmount,
    required String rewardType,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.exchangePointsForCrypto(
        userId: userId,
        pointsAmount: pointsAmount,
        rewardType: rewardType,
      );
      
      if (result['success'] == true) {
        // Обновить профиль после успешного обмена
        await getLoyaltyProfile(userId);
        await getTransactionHistory(userId: userId);
      }
      
      return result;
    } catch (e) {
      _setError('Failed to exchange points: $e');
      return {'success': false, 'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }
  
  /// Начислить баллы за покупку
  Future<void> awardPointsForPurchase({
    required String userId,
    required double purchaseAmount,
    required String productId,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.awardPointsForPurchase(
        userId: userId,
        purchaseAmount: purchaseAmount,
        productId: productId,
      );
      
      if (result['success'] == true) {
        // Обновить профиль и статистику после начисления баллов
        await getLoyaltyProfile(userId);
        await getLoyaltyStats(userId);
        await getTransactionHistory(userId: userId);
      }
    } catch (e) {
      _setError('Failed to award points: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Начислить ежедневную награду за вход
  Future<void> awardDailyLoginReward(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.awardDailyLoginReward(userId);
      
      if (result['success'] == true) {
        // Обновить профиль и статистику после начисления награды
        await getLoyaltyProfile(userId);
        await getLoyaltyStats(userId);
        await getTransactionHistory(userId: userId);
      }
    } catch (e) {
      _setError('Failed to award daily login reward: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Создать реферальную связь
  Future<void> createReferral({
    required String referrerId,
    required String referredId,
    required String referralCode,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.createReferral(
        referrerId: referrerId,
        referredId: referredId,
        referralCode: referralCode,
      );
      
      if (result['success'] == true) {
        // Обновить реферальную статистику
        await getReferralStats(referrerId);
      }
    } catch (e) {
      _setError('Failed to create referral: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить реферальную статистику
  Future<void> getReferralStats(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.getReferralStats(userId);
      _referrals = List<Map<String, dynamic>>.from(result['referrals'] ?? []);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get referral stats: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить уровни лояльности
  Future<void> getLoyaltyTiers() async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.getLoyaltyTiers();
      _tiers = List<Map<String, dynamic>>.from(result['tiers'] ?? []);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get loyalty tiers: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить достижения пользователя
  Future<void> getUserAchievements(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.getUserAchievements(userId);
      _achievements = List<Map<String, dynamic>>.from(result['achievements'] ?? []);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get user achievements: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить информацию о кошельке
  Future<void> getUserWallet(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final wallet = await _loyaltyService.getUserWallet(userId);
      _walletInfo = wallet;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get user wallet: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Обновить адрес кошелька
  Future<void> updateWalletAddress({
    required String userId,
    required String walletAddress,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _loyaltyService.updateWalletAddress(
        userId: userId,
        walletAddress: walletAddress,
      );
      
      if (result['success'] == true) {
        // Обновить профиль и кошелек
        await getLoyaltyProfile(userId);
        await getUserWallet(userId);
      }
    } catch (e) {
      _setError('Failed to update wallet address: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Сгенерировать реферальный код
  String generateReferralCode(String userId) {
    return _loyaltyService.generateReferralCode(userId);
  }
  
  /// Проверить валидность адреса кошелька
  bool isValidWalletAddress(String address) {
    return _loyaltyService.isValidWalletAddress(address);
  }
  
  /// Форматировать количество криптовалюты
  String formatCryptoAmount(double amount, String symbol) {
    return _loyaltyService.formatCryptoAmount(amount, symbol);
  }
  
  /// Форматировать количество баллов
  String formatPoints(int points) {
    return _loyaltyService.formatPoints(points);
  }
  
  /// Загрузить все данные для пользователя
  Future<void> loadAllUserData(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await Future.wait([
        getLoyaltyProfile(userId),
        getLoyaltyStats(userId),
        getTransactionHistory(userId: userId),
        getAvailableRewards(),
        getLoyaltyTiers(),
        getUserAchievements(userId),
        getReferralStats(userId),
        getUserWallet(userId),
      ]);
    } catch (e) {
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Очистить все данные
  void clearData() {
    _loyaltyProfile = null;
    _loyaltyStats = null;
    _transactions.clear();
    _rewards.clear();
    _tiers.clear();
    _achievements.clear();
    _referrals.clear();
    _walletInfo = null;
    _clearError();
    notifyListeners();
  }
  
  /// Очистить ошибки
  void clearErrors() {
    _clearError();
    notifyListeners();
  }
  
  // Private methods
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
  }
}
