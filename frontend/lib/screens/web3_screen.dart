import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/web3_wallet_card.dart';
import '../widgets/nft_grid.dart';
import '../widgets/loyalty_tokens_list.dart';
import '../widgets/transaction_history.dart';
import '../widgets/ipfs_nft_dialog.dart';
import 'web3_demo_screen.dart';
import 'metamask_ipfs_demo_screen.dart';

class Web3Screen extends StatefulWidget {
  const Web3Screen({super.key});

  @override
  State<Web3Screen> createState() => _Web3ScreenState();
}

class _Web3ScreenState extends State<Web3Screen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final web3Provider = appProvider.web3Provider;
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Заголовок
              SliverAppBar(
                floating: true,
                title: const Text(
                  'Web3',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                actions: [
                  // Кнопка демо режима
                  IconButton(
                    onPressed: () => _navigateToDemo(context),
                    icon: const Icon(Icons.science),
                    tooltip: 'Web3 Demo',
                  ),
                  // Кнопка MetaMask & IPFS Demo
                  IconButton(
                    onPressed: () => _navigateToMetaMaskIPFSDemo(context),
                    icon: const Icon(Icons.account_balance_wallet),
                    tooltip: 'MetaMask & IPFS Demo',
                  ),
                  // Кнопка создания NFT
                  IconButton(
                    onPressed: () => _showCreateNFTDialog(context),
                    icon: const Icon(Icons.image),
                    tooltip: 'Создать NFT',
                  ),
                  if (web3Provider.isConnected)
                    IconButton(
                      onPressed: () => _showDisconnectDialog(context),
                      icon: const Icon(Icons.logout),
                    ),
                ],
              ),
              
              // Карточка кошелька
              SliverToBoxAdapter(
                child: Web3WalletCard(),
              ),
              
              // Вкладки Web3 функций
              SliverPersistentHeader(
                pinned: true,
                delegate: _Web3TabsDelegate(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: TabBar(
                      onTap: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      tabs: const [
                        Tab(text: 'NFT'),
                        Tab(text: 'Токены'),
                        Tab(text: 'Транзакции'),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Содержимое вкладок
              _buildTabContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return const SliverToBoxAdapter(
          child: NFTGrid(),
        );
      case 1:
        return const SliverToBoxAdapter(
          child: LoyaltyTokensList(),
        );
      case 2:
        return const SliverToBoxAdapter(
          child: TransactionHistory(),
        );
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  void _navigateToDemo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Web3DemoScreen(),
      ),
    );
  }

  void _navigateToMetaMaskIPFSDemo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MetaMaskIPFSDemoScreen(),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отключить кошелек?'),
        content: const Text('Вы уверены, что хотите отключить кошелек?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final appProvider = context.read<AppProvider>();
              appProvider.web3Provider.disconnectWallet();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Отключить'),
          ),
        ],
      ),
    );
  }

  void _showCreateNFTDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const IPFSNFTDialog(),
    );
  }
}

class _Web3TabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _Web3TabsDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
