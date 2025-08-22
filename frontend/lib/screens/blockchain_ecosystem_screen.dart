import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/blockchain_ecosystem_service.dart';
import '../widgets/nft_collections_tab.dart';
import '../widgets/marketplace_tab.dart';
import '../widgets/verification_tab.dart';
import '../widgets/brand_tokens_tab.dart';
import '../widgets/smart_contracts_tab.dart';
import '../widgets/analytics_tab.dart';

/// Главный экран блокчейн-экосистемы приложения
class BlockchainEcosystemScreen extends StatefulWidget {
  const BlockchainEcosystemScreen({super.key});

  @override
  State<BlockchainEcosystemScreen> createState() => _BlockchainEcosystemScreenState();
}

class _BlockchainEcosystemScreenState extends State<BlockchainEcosystemScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _ecosystemStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadEcosystemStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEcosystemStats() async {
    final service = context.read<BlockchainEcosystemService>();
    final stats = await service.getEcosystemStats();
    if (stats != null) {
      setState(() {
        _ecosystemStats = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⛓️ Блокчейн-экосистема'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.collections), text: 'NFT Коллекции'),
            Tab(icon: Icon(Icons.store), text: 'Торговая площадка'),
            Tab(icon: Icon(Icons.verified), text: 'Верификация'),
            Tab(icon: Icon(Icons.token), text: 'Токены брендов'),
            Tab(icon: Icon(Icons.code), text: 'Смарт-контракты'),
            Tab(icon: Icon(Icons.analytics), text: 'Аналитика'),
          ],
        ),
      ),
      body: Consumer<BlockchainEcosystemService>(
        builder: (context, blockchainService, child) {
          return Column(
            children: [
              _buildEcosystemStats(blockchainService),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    NFTCollectionsTab(blockchainService: blockchainService),
                    MarketplaceTab(blockchainService: blockchainService),
                    VerificationTab(blockchainService: blockchainService),
                    BrandTokensTab(blockchainService: blockchainService),
                    SmartContractsTab(blockchainService: blockchainService),
                    AnalyticsTab(blockchainService: blockchainService),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEcosystemStats(BlockchainEcosystemService service) {
    if (_ecosystemStats == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.purple.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Статистика экосистемы',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Коллекции',
                  _ecosystemStats!['collections'].toString(),
                  Icons.collections,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Токены',
                  _ecosystemStats!['tokens'].toString(),
                  Icons.token,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Листинги',
                  _ecosystemStats!['activeListings'].toString(),
                  Icons.store,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Объем',
                  '${_ecosystemStats!['totalVolume'].toStringAsFixed(2)} ETH',
                  Icons.trending_up,
                  Colors.red,
                ),
              ),
            ],
          ),
          if (service.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red.shade700, size: 20),
                    onPressed: service.clearError,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
