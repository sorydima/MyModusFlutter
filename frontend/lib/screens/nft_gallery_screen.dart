import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/web3_models.dart';
import '../widgets/nft_card.dart';
import '../widgets/nft_filter_bar.dart';
import '../widgets/create_nft_dialog.dart';

class NFTGalleryScreen extends StatefulWidget {
  const NFTGalleryScreen({super.key});

  @override
  State<NFTGalleryScreen> createState() => _NFTGalleryScreenState();
}

class _NFTGalleryScreenState extends State<NFTGalleryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Состояние фильтров
  String _selectedFilter = 'all';
  String _selectedSort = 'recent';
  bool _showOnlyMyNFTs = false;
  String _searchQuery = '';

  // Убираем неиспользуемые импорты
  // import 'package:provider/provider.dart';
  // import '../providers/wallet_provider.dart';

  // Тестовые данные NFT
  final List<NFTModel> _nfts = [
    NFTModel(
      id: '1',
      tokenId: 1,
      contractAddress: '0x1234567890123456789012345678901234567890',
      owner: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      metadata: NFTMetadata(
        name: 'Fashion NFT #001',
        description: 'Эксклюзивный NFT из коллекции MyModus Fashion',
        image: 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=Fashion+NFT+1',
        attributes: 'fashion',
      ),
      price: 0.5,
      isForSale: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      viewCount: 42,
      likeCount: 15,
      rarity: 0.9,
    ),
    NFTModel(
      id: '2',
      tokenId: 2,
      contractAddress: '0x1234567890123456789012345678901234567890',
      owner: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      metadata: NFTMetadata(
        name: 'Sneaker NFT #042',
        description: 'Редкий NFT кроссовок из коллекции MyModus Sneakers',
        image: 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=Sneaker+NFT+2',
        attributes: 'sneakers',
      ),
      price: null,
      isForSale: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      viewCount: 28,
      likeCount: 8,
      rarity: 0.7,
    ),
    NFTModel(
      id: '3',
      tokenId: 3,
      contractAddress: '0x1234567890123456789012345678901234567890',
      owner: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      metadata: NFTMetadata(
        name: 'Luxury NFT #007',
        description: 'Премиум NFT из коллекции MyModus Luxury',
        image: 'https://via.placeholder.com/300x300/96CEB4/FFFFFF?text=Luxury+NFT+3',
        attributes: 'luxury',
      ),
      price: 1.2,
      isForSale: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      viewCount: 67,
      likeCount: 23,
      rarity: 0.95,
    ),
  ];

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
              // Заголовок NFT галереи
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'NFT Галерея',
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
                      Icons.search,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () {
                      _showSearchDialog(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: colorScheme.primary,
                    ),
                    onPressed: () {
                      _showCreateNFTDialog(context);
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
                      // Статистика
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildStatistics(context),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Фильтры
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: NFTFilterBar(
                            selectedFilter: _selectedFilter,
                            selectedSort: _selectedSort,
                            showOnlyMyNFTs: _showOnlyMyNFTs,
                            onFilterChanged: (filter) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            onSortChanged: (sort) {
                              setState(() {
                                _selectedSort = sort;
                              });
                            },
                            onMyNFTsChanged: (value) {
                              setState(() {
                                _showOnlyMyNFTs = value;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Список NFT
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildNFTGrid(context),
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

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    final filteredNFTs = _getFilteredNFTs();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              theme,
              Icons.collections,
              'Всего NFT',
              '${_nfts.length}',
              theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              theme,
              Icons.sell,
              'На продаже',
              '${_nfts.where((nft) => nft.isForSale).length}',
              Colors.orange,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              theme,
              Icons.person,
              'Мои NFT',
              '${_nfts.where((nft) => nft.owner == '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6').length}',
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNFTGrid(BuildContext context) {
    final filteredNFTs = _getFilteredNFTs();
    
    if (filteredNFTs.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Найдено ${filteredNFTs.length} NFT',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
          itemCount: filteredNFTs.length,
          itemBuilder: (context, index) {
            return NFTCard(
              nft: filteredNFTs[index],
              onTap: () => _showNFTDetails(context, filteredNFTs[index]),
              onBuy: () => _buyNFT(context, filteredNFTs[index]),
              onSell: () => _sellNFT(context, filteredNFTs[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.collections_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'NFT не найдены',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить фильтры или создать новый NFT',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showCreateNFTDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Создать NFT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<NFTModel> _getFilteredNFTs() {
    List<NFTModel> filtered = List.from(_nfts);
    
    // Фильтр по типу
    if (_selectedFilter != 'all') {
      // TODO: Реализовать фильтрацию по типу NFT
    }
    
    // Показать только мои NFT
    if (_showOnlyMyNFTs) {
      filtered = filtered.where((nft) => 
        nft.owner == '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6'
      ).toList();
    }
    
    // Сортировка
    switch (_selectedSort) {
      case 'recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'price_low':
        filtered.sort((a, b) {
          final priceA = a.price ?? 0;
          final priceB = b.price ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high':
        filtered.sort((a, b) {
          final priceA = a.price ?? 0;
          final priceB = b.price ?? 0;
          return priceB.compareTo(priceA);
        });
        break;
    }
    
    return filtered;
  }

  // Методы для действий
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поиск NFT'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Название или описание',
                hintText: 'Введите текст для поиска...',
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Поиск выполнен!')),
              );
            },
            child: const Text('Найти'),
          ),
        ],
      ),
    );
  }

  void _showCreateNFTDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateNFTDialog(),
    );
  }

  void _showNFTDetails(BuildContext context, NFTModel nft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nft.metadata?.name ?? 'NFT'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nft.metadata?.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  nft.metadata!.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            if (nft.metadata?.description != null)
              Text(
                nft.metadata!.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            _buildDetailRow('Владелец', '${nft.owner.substring(0, 6)}...${nft.owner.substring(nft.owner.length - 4)}'),
                          _buildDetailRow('Создатель', '${nft.owner.substring(0, 6)}...${nft.owner.substring(nft.owner.length - 4)}'),
            _buildDetailRow('Дата создания', _formatDate(nft.createdAt)),
            if (nft.isForSale && nft.price != null)
              _buildDetailRow('Цена', '${nft.price?.toStringAsFixed(2) ?? '0.00'} ETH'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          if (nft.isForSale)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _buyNFT(context, nft);
              },
              child: const Text('Купить'),
            ),
        ],
      ),
    );
  }

  void _buyNFT(BuildContext context, NFTModel nft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Покупка NFT'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Вы уверены, что хотите купить ${nft.metadata?.name ?? 'этот NFT'}?'),
            const SizedBox(height: 16),
            Text(
              'Цена: ${nft.price?.toStringAsFixed(2) ?? '0.00'} ETH',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('NFT успешно куплен!')),
              );
            },
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }

  void _sellNFT(BuildContext context, NFTModel nft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Продажа NFT'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Установите цену для ${nft.metadata?.name ?? 'этого NFT'}'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Цена (ETH)',
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
                const SnackBar(content: Text('NFT выставлен на продажу!')),
              );
            },
            child: const Text('Выставить'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }


}
