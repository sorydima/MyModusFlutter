import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/web3_provider.dart';
import '../widgets/web3_wallet_card.dart';
import '../widgets/nft_grid.dart';
import '../widgets/loyalty_tokens_list.dart';
import '../widgets/transaction_history.dart';

class Web3DemoScreen extends StatefulWidget {
  const Web3DemoScreen({super.key});

  @override
  State<Web3DemoScreen> createState() => _Web3DemoScreenState();
}

class _Web3DemoScreenState extends State<Web3DemoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nftNameController = TextEditingController();
  final TextEditingController _nftDescriptionController = TextEditingController();
  final TextEditingController _nftImageUrlController = TextEditingController();
  final TextEditingController _nftCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Инициализируем Web3 при загрузке экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Web3Provider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nftNameController.dispose();
    _nftDescriptionController.dispose();
    _nftImageUrlController.dispose();
    _nftCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<Web3Provider>(
            builder: (context, web3Provider, child) {
              return Switch(
                value: web3Provider.isTestMode,
                onChanged: (value) {
                  web3Provider.toggleTestMode();
                },
                activeColor: Colors.green,
              );
            },
          ),
          const SizedBox(width: 8),
          Consumer<Web3Provider>(
            builder: (context, web3Provider, child) {
              return Text(
                web3Provider.isTestMode ? 'TEST' : 'LIVE',
                style: TextStyle(
                  color: web3Provider.isTestMode ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Кошелек'),
            Tab(icon: Icon(Icons.image), text: 'NFT'),
            Tab(icon: Icon(Icons.token), text: 'Токены'),
            Tab(icon: Icon(Icons.history), text: 'Транзакции'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWalletTab(),
          _buildNFTTab(),
          _buildTokensTab(),
          _buildTransactionsTab(),
        ],
      ),
    );
  }

  Widget _buildWalletTab() {
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Информация о режиме
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Режим работы:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            web3Provider.isTestMode ? Icons.science : Icons.public,
                            color: web3Provider.isTestMode ? Colors.green : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            web3Provider.isTestMode 
                                ? 'Тестовый режим (Mock данные)'
                                : 'Реальный режим (Блокчейн)',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Переключайте режим кнопкой в AppBar',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Карточка кошелька
              const Web3WalletCard(),
              
              const SizedBox(height: 16),
              
              // Кнопки управления
              if (!web3Provider.isConnected) ...[
                ElevatedButton.icon(
                  onPressed: web3Provider.isLoading
                      ? null
                      : () => web3Provider.connectWalletWithPrivateKey(''),
                  icon: const Icon(Icons.connect_without_contact),
                  label: const Text('Подключить кошелек'),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: web3Provider.isLoading
                      ? null
                      : () => web3Provider.disconnectWallet(),
                  icon: const Icon(Icons.link_off),
                  label: const Text('Отключить кошелек'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Статистика
              if (web3Provider.isConnected) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Статистика:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow('NFT:', '${web3Provider.nfts.length}'),
                        _buildStatRow('Токены:', '${web3Provider.loyaltyTokens.length}'),
                        _buildStatRow('Транзакции:', '${web3Provider.transactions.length}'),
                        _buildStatRow('Баланс:', '${web3Provider.getBalanceInETH()} ETH'),
                      ],
                    ),
                  ),
                ),
              ],
              
              if (web3Provider.isLoading)
                const Center(child: CircularProgressIndicator()),
              
              if (web3Provider.error != null)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Ошибка:',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          web3Provider.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: web3Provider.clearError,
                          child: const Text('Очистить'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNFTTab() {
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Форма создания NFT
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Создать новый NFT:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nftNameController,
                        decoration: const InputDecoration(
                          labelText: 'Название NFT',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nftDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nftImageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL изображения',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nftCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Категория',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: web3Provider.isConnected && !web3Provider.isLoading
                              ? _createNFT
                              : null,
                          icon: const Icon(Icons.add),
                          label: const Text('Создать NFT'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Список NFT
              Expanded(
                child: web3Provider.isConnected
                    ? const NFTGrid()
                    : const Center(
                        child: Text('Подключите кошелек для просмотра NFT'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTokensTab() {
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Информация о токенах
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Токены лояльности:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'В тестовом режиме используются mock данные для демонстрации функционала.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Список токенов
              Expanded(
                child: web3Provider.isConnected
                    ? const LoyaltyTokensList()
                    : const Center(
                        child: Text('Подключите кошелек для просмотра токенов'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Информация о транзакциях
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'История транзакций:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'В тестовом режиме отображаются mock транзакции для демонстрации.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Список транзакций
              Expanded(
                child: web3Provider.isConnected
                    ? const TransactionHistory()
                    : const Center(
                        child: Text('Подключите кошелек для просмотра транзакций'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _createNFT() async {
    if (_nftNameController.text.isEmpty ||
        _nftDescriptionController.text.isEmpty ||
        _nftImageUrlController.text.isEmpty ||
        _nftCategoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните все поля'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final web3Provider = context.read<Web3Provider>();
    final success = await web3Provider.mintNFT(
      name: _nftNameController.text,
      description: _nftDescriptionController.text,
      imageUrl: _nftImageUrlController.text,
      tokenType: _nftCategoryController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NFT успешно создан!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Очищаем поля
      _nftNameController.clear();
      _nftDescriptionController.clear();
      _nftImageUrlController.clear();
      _nftCategoryController.clear();
      
      // Переключаемся на вкладку NFT
      _tabController.animateTo(1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка создания NFT: ${web3Provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
