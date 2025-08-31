import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/web3_models.dart';
import '../services/metamask_service.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/transaction_history.dart';
import '../widgets/network_selector.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.surface,
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Заголовок кошелька
              SliverAppBar(
                expandedHeight: 100,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Web3 Кошелек',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withOpacity(0.1),
                          colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () {
                      _showWalletSettings(context);
                    },
                  ),
                ],
              ),

              // Основной контент
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Статус подключения
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildConnectionStatus(context),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Карточка баланса
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: const WalletBalanceCard(),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Выбор сети
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: const NetworkSelector(),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Быстрые действия
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildQuickActions(context),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // История транзакций
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: const TransactionHistory(),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        final isConnected = walletProvider.isConnected;
        final address = walletProvider.currentAddress;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isConnected 
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isConnected ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isConnected ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? 'Кошелек подключен' : 'Кошелек не подключен',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    if (isConnected && address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${address.substring(0, 6)}...${address.substring(address.length - 4)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isConnected)
                ElevatedButton(
                  onPressed: () => _connectWallet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Подключить'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрые действия',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              context,
              'Отправить',
              Icons.send_rounded,
              [Colors.blue.shade400, Colors.blue.shade600],
              () => _showSendDialog(context),
            ),
            _buildActionCard(
              context,
              'Получить',
              Icons.qr_code_rounded,
              [Colors.green.shade400, Colors.green.shade600],
              () => _showReceiveDialog(context),
            ),
            _buildActionCard(
              context,
              'Обмен',
              Icons.swap_horiz_rounded,
              [Colors.orange.shade400, Colors.orange.shade600],
              () => _showSwapDialog(context),
            ),
            _buildActionCard(
              context,
              'NFT',
              Icons.collections_rounded,
              [Colors.purple.shade400, Colors.purple.shade600],
              () => _navigateToNFTGallery(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Методы для действий
  void _connectWallet(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    walletProvider.connectWallet();
  }

  void _showWalletSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsSheet(context),
    );
  }

  void _showSendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildSendDialog(context),
    );
  }

  void _showReceiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildReceiveDialog(context),
    );
  }

  void _showSwapDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildSwapDialog(context),
    );
  }

  void _navigateToNFTGallery(BuildContext context) {
    // TODO: Навигация к NFT галерее
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Переход к NFT галерее...')),
    );
  }

  // Вспомогательные виджеты
  Widget _buildSettingsSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Настройки кошелька',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingItem(
                  context,
                  Icons.security,
                  'Безопасность',
                  'Настройки безопасности',
                  () {},
                ),
                _buildSettingItem(
                  context,
                  Icons.network_check,
                  'Сети',
                  'Управление сетями',
                  () {},
                ),
                _buildSettingItem(
                  context,
                  Icons.backup,
                  'Резервное копирование',
                  'Экспорт приватного ключа',
                  () {},
                ),
                _buildSettingItem(
                  context,
                  Icons.info,
                  'О кошельке',
                  'Версия и информация',
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSendDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Отправить'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Адрес получателя',
              hintText: '0x...',
            ),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Сумма',
              hintText: '0.0',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Транзакция отправлена!')),
            );
          },
          child: const Text('Отправить'),
        ),
      ],
    );
  }

  Widget _buildReceiveDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Получить'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.qr_code,
              size: 100,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '0x1234...5678',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Копировать адрес
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Адрес скопирован!')),
            );
          },
          child: const Text('Копировать'),
        ),
      ],
    );
  }

  Widget _buildSwapDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Обмен токенов'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'От',
              hintText: '0.0 ETH',
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'К',
              hintText: '0.0 USDT',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Обмен выполнен!')),
            );
          },
          child: const Text('Обменять'),
        ),
      ],
    );
  }
}
