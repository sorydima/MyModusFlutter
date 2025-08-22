import 'dart:convert';
import 'package:http/http.dart' as http;

class BlockchainLoyaltyService {
  static const String baseUrl = 'http://localhost:8080/api/loyalty';
  
  /// Получить профиль лояльности пользователя
  Future<Map<String, dynamic>> getLoyaltyProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get loyalty profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting loyalty profile: $e');
    }
  }

  /// Создать или обновить профиль лояльности
  Future<Map<String, dynamic>> createOrUpdateProfile({
    required String userId,
    String? walletAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'walletAddress': walletAddress,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create/update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating/updating profile: $e');
    }
  }

  /// Получить статистику лояльности
  Future<Map<String, dynamic>> getLoyaltyStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get loyalty stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting loyalty stats: $e');
    }
  }

  /// Получить историю транзакций
  Future<Map<String, dynamic>> getTransactionHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$userId?limit=$limit&offset=$offset'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get transaction history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting transaction history: $e');
    }
  }

  /// Получить доступные награды
  Future<Map<String, dynamic>> getAvailableRewards() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rewards'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get available rewards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting available rewards: $e');
    }
  }

  /// Обменять баллы на криптовалюту
  Future<Map<String, dynamic>> exchangePointsForCrypto({
    required String userId,
    required int pointsAmount,
    required String rewardType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/exchange'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'pointsAmount': pointsAmount,
          'rewardType': rewardType,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to exchange points');
      }
    } catch (e) {
      throw Exception('Error exchanging points: $e');
    }
  }

  /// Начислить баллы за покупку
  Future<Map<String, dynamic>> awardPointsForPurchase({
    required String userId,
    required double purchaseAmount,
    required String productId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/award-purchase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'purchaseAmount': purchaseAmount,
          'productId': productId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to award points: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error awarding points: $e');
    }
  }

  /// Начислить ежедневную награду за вход
  Future<Map<String, dynamic>> awardDailyLoginReward(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/daily-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to award daily login reward: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error awarding daily login reward: $e');
    }
  }

  /// Создать реферальную связь
  Future<Map<String, dynamic>> createReferral({
    required String referrerId,
    required String referredId,
    required String referralCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/referral'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'referrerId': referrerId,
          'referredId': referredId,
          'referralCode': referralCode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create referral: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating referral: $e');
    }
  }

  /// Получить реферальную статистику
  Future<Map<String, dynamic>> getReferralStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referrals/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get referral stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting referral stats: $e');
    }
  }

  /// Получить уровни лояльности
  Future<Map<String, dynamic>> getLoyaltyTiers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tiers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get loyalty tiers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting loyalty tiers: $e');
    }
  }

  /// Получить достижения пользователя
  Future<Map<String, dynamic>> getUserAchievements(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/achievements/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user achievements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user achievements: $e');
    }
  }

  /// Получить информацию о кошельке
  Future<Map<String, dynamic>> getUserWallet(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user wallet: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user wallet: $e');
    }
  }

  /// Обновить адрес кошелька
  Future<Map<String, dynamic>> updateWalletAddress({
    required String userId,
    required String walletAddress,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/wallet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'walletAddress': walletAddress,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update wallet address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating wallet address: $e');
    }
  }

  /// Сгенерировать реферальный код
  String generateReferralCode(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = (timestamp % 10000).toString().padLeft(4, '0');
    return 'REF${userId.substring(0, 3).toUpperCase()}$timestamp$randomPart';
  }

  /// Проверить валидность адреса кошелька (базовая проверка)
  bool isValidWalletAddress(String address) {
    // Простая проверка для Ethereum-подобных адресов
    return address.length == 42 && address.startsWith('0x');
  }

  /// Форматировать количество криптовалюты
  String formatCryptoAmount(double amount, String symbol) {
    if (amount >= 1) {
      return '${amount.toStringAsFixed(2)} $symbol';
    } else if (amount >= 0.01) {
      return '${amount.toStringAsFixed(4)} $symbol';
    } else {
      return '${amount.toStringAsFixed(8)} $symbol';
    }
  }

  /// Форматировать количество баллов
  String formatPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    } else if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    } else {
      return points.toString();
    }
  }
}
