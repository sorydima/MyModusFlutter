import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isConnected = false;
  String _walletAddress = '';
  double _ethBalance = 0.0;
  double _usdtBalance = 0.0;
  int _selectedTab = 0;
  
  // Тестовые данные NFT
  final List<Map<String, dynamic>> _nfts = [
    {
      'id': '1',
      'name': 'Fashion NFT #001',
      'imageUrl': 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=Fashion+NFT+1',
      'collection': 'MyModus Fashion',
      'price': 0.5,
      'currency': 'ETH',
      'rarity': 'Legendary',
      'attributes': [
        {'trait': 'Style', 'value': 'Streetwear'},
        {'trait': 'Color', 'value': 'Red'},
        {'trait': 'Rarity', 'value': 'Legendary'},
      ],
    },
    {
      'id': '2',
      'name': 'Sneaker NFT #042',
      'imageUrl': 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=Sneaker+NFT+2',
      'collection': 'MyModus Sneakers',
      'price': 0.3,
      'currency': 'ETH',
      'rarity': 'Rare',
      'attributes': [
        {'trait': 'Brand', 'value': 'Nike'},
        {'trait': 'Model', 'value': 'Air Max'},
        {'trait': 'Rarity', 'value': 'Rare'},
      ],
    },
    {
      'id': '3',
      'name': 'Luxury NFT #007',
      'imageUrl': 'https://via.placeholder.com/300x300/96CEB4/FFFFFF?text=Luxury+NFT+3',
      'collection': 'MyModus Luxury',
      'price': 1.2,
      'currency': 'ETH',
      'rarity': 'Epic',
      'attributes': [
        {'trait': 'Category', 'value': 'Luxury'},
        {'trait': 'Material', 'value': 'Gold'},
        {'trait': 'Rarity', 'value': 'Epic'},
      ],
    },
  ];

  // Тестовые данные транзакций
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': '1',
      'type': 'buy',
      'amount': 0.5,
      'currency': 'ETH',
      'status': 'completed',
      'time': '2 часа назад',
      'description': 'Покупка Fashion NFT #001',
    },
    {
      'id': '2',
      'type': 'sell',
      'amount': 0.3,
      'currency': 'ETH',
      'status': 'completed',
      'time': '1 день назад',
      'description': 'Продажа Sneaker NFT #042',
    },
    {
      'id': '3',
      'type': 'transfer',
      'amount': 0.1,
      'currency': 'ETH',
      'status': 'pending',
      'time': '3 дня назад',
      'description': 'Перевод на кошелек 0x1234...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  void _loadWalletData() {
    // TODO: Реальная интеграция с MetaMask
    setState(() {
      _isConnected = true;
      _walletAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
      _ethBalance = 2.45;
      _usdtBalance = 1250.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            title: const Text(
              'Web3 Кошелек',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            pinned: true,
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Navigate to wallet settings
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: Colors.grey.shade600,
                  ),
                ),
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
                  _buildConnectionStatus(),
                  
                  const SizedBox(height: 24),
                  
                  // Балансы
                  _buildBalances(),
                  
                  const SizedBox(height: 24),
                  
                  // Табы
                  _buildTabs(),
                  
                  const SizedBox(height: 24),
                  
                  // Содержимое табов
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isConnected ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? 'Кошелек подключен' : 'Кошелек не подключен',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: _isConnected ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                if (_isConnected) ...[
                  const SizedBox(height: 4),
                  Text(
                    _walletAddress,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!_isConnected)
            ElevatedButton(
              onPressed: _connectWallet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Подключить'),
            ),
        ],
      ),
    );
  }

  Widget _buildBalances() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.currency_bitcoin,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ETH',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${_ethBalance.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  '\$${(_ethBalance * 2000).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.green.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'USDT',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${_usdtBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Text(
                  '\$${_usdtBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'NFT Коллекция',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Транзакции',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 0) {
      return _buildNFTCollection();
    } else {
      return _buildTransactions();
    }
  }

  Widget _buildNFTCollection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ваши NFT (${_nfts.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to NFT marketplace
              },
              icon: const Icon(Icons.add),
              label: const Text('Купить NFT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _nfts.length,
          itemBuilder: (context, index) {
            final nft = _nfts[index];
            return _buildNFTCard(nft);
          },
        ),
      ],
    );
  }

  Widget _buildNFTCard(Map<String, dynamic> nft) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение NFT
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: nft['imageUrl'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Информация о NFT
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nft['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  nft['collection'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Редкость
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRarityColor(nft['rarity']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    nft['rarity'],
                    style: TextStyle(
                      color: _getRarityColor(nft['rarity']),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Цена
                Row(
                  children: [
                    Icon(
                      Icons.currency_bitcoin,
                      size: 16,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${nft['price']} ${nft['currency']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'История транзакций',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 20),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final transaction = _transactions[index];
            return _buildTransactionCard(transaction);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Иконка типа транзакции
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTransactionColor(transaction['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTransactionIcon(transaction['type']),
              color: _getTransactionColor(transaction['type']),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Детали транзакции
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  transaction['time'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Сумма и статус
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction['type'] == 'sell' ? '+' : '-'}${transaction['amount']} ${transaction['currency']}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: transaction['type'] == 'sell' 
                      ? Colors.green.shade600 
                      : Colors.red.shade600,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(transaction['status']),
                  style: TextStyle(
                    color: _getStatusColor(transaction['status']),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _connectWallet() {
    // TODO: Реальная интеграция с MetaMask
    setState(() {
      _isConnected = true;
      _walletAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
      _ethBalance = 2.45;
      _usdtBalance = 1250.0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Кошелек успешно подключен!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Common':
        return Colors.grey;
      case 'Uncommon':
        return Colors.green;
      case 'Rare':
        return Colors.blue;
      case 'Epic':
        return Colors.purple;
      case 'Legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'buy':
        return Colors.red;
      case 'sell':
        return Colors.green;
      case 'transfer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'buy':
        return Icons.shopping_cart;
      case 'sell':
        return Icons.sell;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.attach_money;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Завершено';
      case 'pending':
        return 'В процессе';
      case 'failed':
        return 'Ошибка';
      default:
        return 'Неизвестно';
    }
  }
}
