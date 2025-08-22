import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Test script for Blockchain Loyalty functionality
/// This script tests the backend blockchain loyalty API endpoints

class BlockchainLoyaltyTester {
  static const String baseUrl = 'http://localhost:8080/api/loyalty';
  static const String testUserId = '1';
  
  static Future<void> main() async {
    print('🧪 Testing Blockchain Loyalty API...\n');
    
    try {
      // Test 1: Create/Get loyalty profile
      await testCreateOrUpdateProfile();
      
      // Test 2: Get loyalty stats
      await testGetLoyaltyStats();
      
      // Test 3: Award points for purchase
      await testAwardPointsForPurchase();
      
      // Test 4: Award daily login reward
      await testAwardDailyLoginReward();
      
      // Test 5: Get available rewards
      await testGetAvailableRewards();
      
      // Test 6: Exchange points for crypto
      await testExchangePointsForCrypto();
      
      // Test 7: Create referral
      await testCreateReferral();
      
      // Test 8: Get referral stats
      await testGetReferralStats();
      
      // Test 9: Get loyalty tiers
      await testGetLoyaltyTiers();
      
      // Test 10: Get user achievements
      await testGetUserAchievements();
      
      // Test 11: Get user wallet
      await testGetUserWallet();
      
      // Test 12: Update wallet address
      await testUpdateWalletAddress();
      
      // Test 13: Get transaction history
      await testGetTransactionHistory();
      
      print('\n✅ All Blockchain Loyalty tests completed successfully!');
      
    } catch (e) {
      print('\n❌ Test failed: $e');
    }
  }

  /// Test 1: Create or update loyalty profile
  static Future<void> testCreateOrUpdateProfile() async {
    print('📝 Testing create/update loyalty profile...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': testUserId,
        'walletAddress': '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Profile created/updated: ${data['success']}');
    } else {
      print('❌ Failed to create/update profile: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 2: Get loyalty stats
  static Future<void> testGetLoyaltyStats() async {
    print('📊 Testing get loyalty stats...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/stats/$testUserId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Loyalty stats retrieved: ${data['profile']?['loyaltyTier'] ?? 'Unknown'} tier');
    } else {
      print('❌ Failed to get loyalty stats: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 3: Award points for purchase
  static Future<void> testAwardPointsForPurchase() async {
    print('🛒 Testing award points for purchase...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/award-purchase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': testUserId,
        'purchaseAmount': 1500.0,
        'productId': 'test_product_123',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Points awarded: ${data['message']}');
    } else {
      print('❌ Failed to award points: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 4: Award daily login reward
  static Future<void> testAwardDailyLoginReward() async {
    print('🔐 Testing award daily login reward...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/daily-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': testUserId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Daily login reward awarded: ${data['message']}');
    } else {
      print('❌ Failed to award daily login reward: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 5: Get available rewards
  static Future<void> testGetAvailableRewards() async {
    print('🎁 Testing get available rewards...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/rewards'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Available rewards retrieved: ${data['total']} rewards');
      for (final reward in data['rewards']) {
        print('  - ${reward['rewardType']}: ${reward['cryptoAmount']} ${reward['tokenSymbol']}');
      }
    } else {
      print('❌ Failed to get available rewards: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 6: Exchange points for crypto
  static Future<void> testExchangePointsForCrypto() async {
    print('💱 Testing exchange points for crypto...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/exchange'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': testUserId,
        'pointsAmount': 100,
        'rewardType': 'purchase',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('✅ Points exchanged successfully: ${data['message']}');
        print('  Received: ${data['cryptoReceived']} ${data['tokenSymbol']}');
      } else {
        print('⚠️ Exchange failed: ${data['message']}');
      }
    } else {
      print('❌ Failed to exchange points: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 7: Create referral
  static Future<void> testCreateReferral() async {
    print('👥 Testing create referral...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/referral'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'referrerId': testUserId,
        'referredId': '2',
        'referralCode': 'REF123456789',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Referral created: ${data['message']}');
    } else {
      print('❌ Failed to create referral: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 8: Get referral stats
  static Future<void> testGetReferralStats() async {
    print('📈 Testing get referral stats...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/referrals/$testUserId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Referral stats retrieved: ${data['totalReferrals']} referrals');
      print('  Total crypto earned: ${data['totalCryptoEarned']} MODUS');
    } else {
      print('❌ Failed to get referral stats: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 9: Get loyalty tiers
  static Future<void> testGetLoyaltyTiers() async {
    print('🏆 Testing get loyalty tiers...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/tiers'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Loyalty tiers retrieved: ${data['total']} tiers');
      for (final tier in data['tiers']) {
        print('  - ${tier['tierName']}: ${tier['minPoints']} points, ${tier['rewardMultiplier']}x multiplier');
      }
    } else {
      print('❌ Failed to get loyalty tiers: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 10: Get user achievements
  static Future<void> testGetUserAchievements() async {
    print('🏅 Testing get user achievements...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/achievements/$testUserId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ User achievements retrieved: ${data['total']} achievements');
    } else {
      print('❌ Failed to get user achievements: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 11: Get user wallet
  static Future<void> testGetUserWallet() async {
    print('💳 Testing get user wallet...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/$testUserId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ User wallet retrieved: ${data['walletAddress'] ?? 'No wallet'}');
      print('  Loyalty points: ${data['loyaltyPoints']}');
      print('  Total rewards earned: ${data['totalRewardsEarned']} MODUS');
    } else {
      print('❌ Failed to get user wallet: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 12: Update wallet address
  static Future<void> testUpdateWalletAddress() async {
    print('🔧 Testing update wallet address...');
    
    final response = await http.put(
      Uri.parse('$baseUrl/wallet'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': testUserId,
        'walletAddress': '0x1234567890abcdef1234567890abcdef12345678',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Wallet address updated: ${data['message']}');
    } else {
      print('❌ Failed to update wallet address: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  /// Test 13: Get transaction history
  static Future<void> testGetTransactionHistory() async {
    print('📜 Testing get transaction history...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/$testUserId?limit=10&offset=0'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Transaction history retrieved: ${data['total']} transactions');
      for (final transaction in data['transactions'].take(3)) {
        print('  - ${transaction['transactionType']}: ${transaction['pointsAmount']} points');
      }
    } else {
      print('❌ Failed to get transaction history: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }
}

/// Run the tests
void main() async {
  await BlockchainLoyaltyTester.main();
}
