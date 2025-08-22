import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blockchain_loyalty_provider.dart';

class BlockchainLoyaltyScreen extends StatefulWidget {
  const BlockchainLoyaltyScreen({super.key});

  @override
  State<BlockchainLoyaltyScreen> createState() => _BlockchainLoyaltyScreenState();
}

class _BlockchainLoyaltyScreenState extends State<BlockchainLoyaltyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentUserId = 1; // Mock user ID for demo
  final TextEditingController _walletController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BlockchainLoyaltyProvider>();
      provider.loadAllUserData(_currentUserId.toString());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Блокчейн-Лояльность'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Профиль'),
            Tab(icon: Icon(Icons.card_giftcard), text: 'Награды'),
            Tab(icon: Icon(Icons.history), text: 'Транзакции'),
            Tab(icon: Icon(Icons.share), text: 'Рефералы'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Кошелек'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildRewardsTab(),
          _buildTransactionsTab(),
          _buildReferralsTab(),
          _buildWalletTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<BlockchainLoyaltyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = provider.loyaltyProfile;
        final stats = provider.loyaltyStats;
        final currentTier = stats?['currentTier'];
        final nextTier = stats?['nextTier'];
        final progress = stats?['progressToNextTier'] ?? 0.0;

        if (profile == null) {
          return const Center(child: Text('Профиль не найден'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(profile, currentTier),
              const SizedBox(height: 16),
              _buildTierProgressCard(currentTier, nextTier, progress),
              const SizedBox(height: 16),
              _buildStatsCard(stats),
              const SizedBox(height: 16),
              _buildAchievementsCard(provider.achievements),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile, Map<String, dynamic>? tier) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    profile['loyaltyTier']?.toString().toUpperCase().substring(0, 1) ?? 'B',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Уровень ${profile['loyaltyTier'] ?? 'Bronze'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (tier != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Множитель: ${tier['rewardMultiplier']}x',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Баллы',
                  provider.formatPoints(profile['loyaltyPoints']?.toInt() ?? 0),
                  Icons.stars,
                  Colors.amber,
                ),
                _buildStatItem(
                  'Потрачено',
                  '${profile['totalSpent']?.toStringAsFixed(0) ?? 0} ₽',
                  Icons.shopping_cart,
                  Colors.green,
                ),
                _buildStatItem(
                  'Заработано',
                  provider.formatCryptoAmount(
                    profile['totalRewardsEarned']?.toDouble() ?? 0,
                    'MODUS',
                  ),
                  Icons.monetization_on,
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTierProgressCard(Map<String, dynamic>? currentTier, Map<String, dynamic>? nextTier, double progress) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Прогресс до следующего уровня',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (nextTier != null) ...[
              Text(
                'Следующий уровень: ${nextTier['tierName']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              Text(
                'Вы достигли максимального уровня!',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic>? stats) {
    if (stats == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Статистика',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Транзакции',
                  '${stats['transactions']?.length ?? 0}',
                  Icons.receipt,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Достижения',
                  '${stats['achievements']?.length ?? 0}',
                  Icons.emoji_events,
                  Colors.purple,
                ),
                _buildStatItem(
                  'Рефералы',
                  '${stats['referrals']?.length ?? 0}',
                  Icons.people,
                  Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(List<Map<String, dynamic>> achievements) {
    if (achievements.isEmpty) {
      return Card(
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Пока нет достижений',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Последние достижения',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...achievements.take(3).map((achievement) => ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: Text(achievement['achievementName'] ?? ''),
              subtitle: Text(achievement['description'] ?? ''),
              trailing: Text(
                '+${achievement['pointsRewarded']} баллов',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsTab() {
    return Consumer<BlockchainLoyaltyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Доступные награды',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...provider.rewards.map((reward) => _buildRewardCard(reward, provider)),
              const SizedBox(height: 16),
              _buildDailyLoginCard(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward, BlockchainLoyaltyProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reward['rewardType'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${reward['tokenSymbol']} ${reward['cryptoAmount']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Требуется баллов: ${reward['pointsRequired']}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (reward['maxDailyClaims'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Максимум в день: ${reward['maxDailyClaims']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showExchangeDialog(reward, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Обменять баллы'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyLoginCard(BlockchainLoyaltyProvider provider) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.login, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Ежедневная награда за вход',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Получайте баллы каждый день за вход в приложение',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => provider.awardDailyLoginReward(_currentUserId.toString()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Получить награду'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Consumer<BlockchainLoyaltyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.transactions.isEmpty) {
          return const Center(
            child: Text(
              'Пока нет транзакций',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.transactions[index];
            return _buildTransactionCard(transaction, provider);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, BlockchainLoyaltyProvider provider) {
    final isPositive = transaction['pointsAmount'] > 0;
    final icon = _getTransactionIcon(transaction['transactionType']);
    final color = isPositive ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction['description'] ?? 'Транзакция',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatTransactionDate(transaction['createdAt']),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isPositive ? '+' : ''}${transaction['pointsAmount']?.toStringAsFixed(0) ?? 0}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (transaction['cryptoAmount'] != null) ...[
              const SizedBox(height: 2),
              Text(
                provider.formatCryptoAmount(
                  transaction['cryptoAmount'].toDouble(),
                  'MODUS',
                ),
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String? type) {
    switch (type) {
      case 'purchase':
        return Icons.shopping_cart;
      case 'referral':
        return Icons.people;
      case 'daily_login':
        return Icons.login;
      case 'achievement':
        return Icons.emoji_events;
      case 'tier_upgrade':
        return Icons.trending_up;
      case 'exchange':
        return Icons.swap_horiz;
      default:
        return Icons.receipt;
    }
  }

  String _formatTransactionDate(dynamic date) {
    if (date == null) return 'Неизвестно';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return 'Неизвестно';
    }
  }

  Widget _buildReferralsTab() {
    return Consumer<BlockchainLoyaltyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReferralCodeCard(provider),
              const SizedBox(height: 16),
              _buildReferralStatsCard(provider),
              const SizedBox(height: 16),
              _buildReferralListCard(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReferralCodeCard(BlockchainLoyaltyProvider provider) {
    final referralCode = provider.generateReferralCode(_currentUserId.toString());
    
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Ваш реферальный код',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      referralCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Код скопирован')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    color: Colors.green[600],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Поделитесь этим кодом с друзьями и получайте награды за их регистрацию!',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralStatsCard(BlockchainLoyaltyProvider provider) {
    final totalReferrals = provider.referrals.length;
    final totalCryptoEarned = provider.referrals.fold<double>(
      0,
      (sum, r) => sum + (r['cryptoRewarded']?.toDouble() ?? 0),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Реферальная статистика',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Рефералы',
                  totalReferrals.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Заработано',
                  provider.formatCryptoAmount(totalCryptoEarned, 'MODUS'),
                  Icons.monetization_on,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralListCard(BlockchainLoyaltyProvider provider) {
    if (provider.referrals.isEmpty) {
      return Card(
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Пока нет рефералов',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ваши рефералы',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...provider.referrals.map((referral) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  referral['referredId']?.toString().substring(0, 2).toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('Пользователь ${referral['referredId']}'),
              subtitle: Text(
                referral['status'] == 'completed' ? 'Завершен' : 'В ожидании',
              ),
              trailing: Text(
                '+${referral['cryptoRewarded']} MODUS',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTab() {
    return Consumer<BlockchainLoyaltyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWalletInfoCard(provider),
              const SizedBox(height: 16),
              _buildWalletAddressCard(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletInfoCard(BlockchainLoyaltyProvider provider) {
    final walletInfo = provider.walletInfo;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.deepPurple[600]),
                const SizedBox(width: 8),
                const Text(
                  'Информация о кошельке',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (walletInfo != null) ...[
              _buildWalletInfoRow('Адрес кошелька', walletInfo['walletAddress'] ?? 'Не указан'),
              const SizedBox(height: 8),
              _buildWalletInfoRow('Баллы лояльности', 
                provider.formatPoints(walletInfo['loyaltyPoints']?.toInt() ?? 0)),
              const SizedBox(height: 8),
              _buildWalletInfoRow('Всего заработано', 
                provider.formatCryptoAmount(walletInfo['totalRewardsEarned']?.toDouble() ?? 0, 'MODUS')),
            ] else ...[
              const Text(
                'Кошелек не настроен',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWalletInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletAddressCard(BlockchainLoyaltyProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Настройка кошелька',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _walletController,
              decoration: const InputDecoration(
                labelText: 'Адрес кошелька',
                hintText: '0x...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_walletController.text.isNotEmpty) {
                    provider.updateWalletAddress(
                      userId: _currentUserId.toString(),
                      walletAddress: _walletController.text,
                    );
                    _walletController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Обновить адрес'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Введите адрес вашего Ethereum-кошелька для получения крипто-наград',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExchangeDialog(Map<String, dynamic> reward, BlockchainLoyaltyProvider provider) {
    final pointsController = TextEditingController();
    final currentProfile = provider.loyaltyProfile;
    
    if (currentProfile == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Обмен баллов на ${reward['tokenSymbol']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Доступно баллов: ${currentProfile['loyaltyPoints']?.toStringAsFixed(0) ?? 0}'),
            const SizedBox(height: 16),
            TextField(
              controller: pointsController,
              decoration: const InputDecoration(
                labelText: 'Количество баллов для обмена',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'Вы получите: ${_calculateCryptoAmount(reward, pointsController.text)} ${reward['tokenSymbol']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final points = int.tryParse(pointsController.text);
              if (points != null && points > 0) {
                Navigator.of(context).pop();
                final result = await provider.exchangePointsForCrypto(
                  userId: _currentUserId.toString(),
                  pointsAmount: points,
                  rewardType: reward['rewardType'],
                );
                
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Обмен выполнен успешно'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['error'] ?? 'Ошибка при обмене'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Обменять'),
          ),
        ],
      ),
    );
  }

  String _calculateCryptoAmount(Map<String, dynamic> reward, String pointsText) {
    final points = int.tryParse(pointsText);
    if (points == null) return '0';
    
    final rewardAmount = reward['cryptoAmount']?.toDouble() ?? 0;
    final requiredPoints = reward['pointsRequired']?.toInt() ?? 1;
    
    return ((points / requiredPoints) * rewardAmount).toStringAsFixed(4);
  }
}
