import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class NFTMarketplaceScreen extends StatefulWidget {
  const NFTMarketplaceScreen({super.key});

  @override
  State<NFTMarketplaceScreen> createState() => _NFTMarketplaceScreenState();
}

class _NFTMarketplaceScreenState extends State<NFTMarketplaceScreen> {
  String _selectedCategory = 'Все';
  String _selectedSort = 'Популярные';
  int _selectedTab = 0;
  
  final List<String> _categories = ['Все', 'Fashion', 'Sneakers', 'Luxury', 'Art', 'Gaming'];
  final List<String> _sortOptions = ['Популярные', 'По цене ↑', 'По цене ↓', 'По редкости', 'По новизне'];

  // Тестовые данные NFT коллекций
  final List<Map<String, dynamic>> _collections = [
    {
      'id': '1',
      'name': 'MyModus Fashion',
      'description': 'Эксклюзивная коллекция модных NFT',
      'imageUrl': 'https://via.placeholder.com/400x200/FF6B6B/FFFFFF?text=Fashion+Collection',
      'floorPrice': 0.5,
      'totalVolume': 125.5,
      'items': 1000,
      'owners': 450,
      'category': 'Fashion',
    },
    {
      'id': '2',
      'name': 'MyModus Sneakers',
      'description': 'Коллекция редких кроссовок',
      'imageUrl': 'https://via.placeholder.com/400x200/4ECDC4/FFFFFF?text=Sneakers+Collection',
      'floorPrice': 0.3,
      'totalVolume': 89.2,
      'items': 500,
      'owners': 200,
      'category': 'Sneakers',
    },
    {
      'id': '3',
      'name': 'MyModus Luxury',
      'description': 'Премиум коллекция люксовых NFT',
      'imageUrl': 'https://via.placeholder.com/400x200/96CEB4/FFFFFF?text=Luxury+Collection',
      'floorPrice': 2.0,
      'totalVolume': 567.8,
      'items': 100,
      'owners': 75,
      'category': 'Luxury',
    },
  ];

  // Тестовые данные NFT для продажи
  final List<Map<String, dynamic>> _nftsForSale = [
    {
      'id': '1',
      'name': 'Fashion NFT #001',
      'collection': 'MyModus Fashion',
      'imageUrl': 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=Fashion+NFT+1',
      'price': 0.5,
      'currency': 'ETH',
      'rarity': 'Legendary',
      'likes': 127,
      'timeLeft': '2 дня',
      'seller': '0x1234...',
    },
    {
      'id': '2',
      'name': 'Sneaker NFT #042',
      'collection': 'MyModus Sneakers',
      'imageUrl': 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=Sneaker+NFT+2',
      'price': 0.3,
      'currency': 'ETH',
      'rarity': 'Rare',
      'likes': 89,
      'timeLeft': '1 день',
      'seller': '0x5678...',
    },
    {
      'id': '3',
      'name': 'Luxury NFT #007',
      'collection': 'MyModus Luxury',
      'imageUrl': 'https://via.placeholder.com/300x300/96CEB4/FFFFFF?text=Luxury+NFT+3',
      'price': 1.2,
      'currency': 'ETH',
      'rarity': 'Epic',
      'likes': 234,
      'timeLeft': '5 дней',
      'seller': '0x9abc...',
    },
    {
      'id': '4',
      'name': 'Art NFT #123',
      'collection': 'MyModus Art',
      'imageUrl': 'https://via.placeholder.com/300x300/FFE66D/000000?text=Art+NFT+4',
      'price': 0.8,
      'currency': 'ETH',
      'rarity': 'Rare',
      'likes': 156,
      'timeLeft': '3 дня',
      'seller': '0xdef0...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            title: const Text(
              'NFT Маркетплейс',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            pinned: true,
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Navigate to wallet
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
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
                  'Коллекции',
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
                  'NFT для продажи',
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
      return _buildCollectionsTab();
    } else {
      return _buildNFTsForSaleTab();
    }
  }

  Widget _buildCollectionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Популярные коллекции',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 20),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _collections.length,
          itemBuilder: (context, index) {
            final collection = _collections[index];
            return _buildCollectionCard(collection);
          },
        ),
      ],
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> collection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          // Изображение коллекции
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: collection['imageUrl'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Информация о коллекции
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        collection['name'],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        collection['category'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  collection['description'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Статистика коллекции
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Floor Price',
                        '${collection['floorPrice']} ETH',
                        Icons.trending_up,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Total Volume',
                        '${collection['totalVolume']} ETH',
                        Icons.bar_chart,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Items',
                        '${collection['items']}',
                        Icons.inventory,
                        Colors.purple,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Owners',
                        '${collection['owners']}',
                        Icons.people,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Кнопка просмотра
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to collection detail
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Просмотреть коллекцию',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNFTsForSaleTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Фильтры
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSort,
                decoration: InputDecoration(
                  labelText: 'Сортировка',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _sortOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'NFT для продажи',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 20),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _nftsForSale.length,
          itemBuilder: (context, index) {
            final nft = _nftsForSale[index];
            return _buildNFTSaleCard(nft);
          },
        ),
      ],
    );
  }

  Widget _buildNFTSaleCard(Map<String, dynamic> nft) {
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: nft['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Редкость
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRarityColor(nft['rarity']).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    nft['rarity'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              // Лайки
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${nft['likes']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                
                // Цена и время
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Продавец: ${nft['seller']}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Осталось:',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          nft['timeLeft'],
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Кнопка покупки
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showBuyNFTDialog(nft);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Купить NFT',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyNFTDialog(Map<String, dynamic> nft) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Покупка ${nft['name']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Коллекция: ${nft['collection']}'),
              Text('Редкость: ${nft['rarity']}'),
              const SizedBox(height: 16),
              Text(
                'Цена: ${nft['price']} ${nft['currency']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Вы уверены, что хотите купить этот NFT?',
                style: TextStyle(fontSize: 14),
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
                _buyNFT(nft);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Купить'),
            ),
          ],
        );
      },
    );
  }

  void _buyNFT(Map<String, dynamic> nft) {
    // TODO: Реальная интеграция с блокчейном
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('NFT ${nft['name']} успешно куплен!'),
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
}
