import 'package:flutter/material.dart';
import '../services/blockchain_ecosystem_service.dart';

/// Вкладка торговой площадки
class MarketplaceTab extends StatefulWidget {
  final BlockchainEcosystemService blockchainService;

  const MarketplaceTab({
    super.key,
    required this.blockchainService,
  });

  @override
  State<MarketplaceTab> createState() => _MarketplaceTabState();
}

class _MarketplaceTabState extends State<MarketplaceTab> {
  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String _selectedCurrency = 'all';
  double? _minPrice;
  double? _maxPrice;

  final _categoryController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _currencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    try {
      final listings = await widget.blockchainService.getActiveListings(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        currency: _selectedCurrency == 'all' ? null : _selectedCurrency,
      );
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки листингов: $e')),
        );
      }
    }
  }

  Future<void> _purchaseNFT(String listingId) async {
    try {
      final buyerId = 'demo_buyer_${DateTime.now().millisecondsSinceEpoch}';
      final order = await widget.blockchainService.purchaseNFT(
        listingId: listingId,
        buyerId: buyerId,
        amount: 0.2, // Демо сумма
      );

      if (order != null) {
        // Обновляем список листингов
        _loadListings();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('NFT успешно куплен! ID заказа: ${order['id']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка покупки: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Фильтры'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Мин. цена',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Макс. цена',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _currencyController,
              decoration: const InputDecoration(
                labelText: 'Валюта',
                border: OutlineInputBorder(),
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
              _selectedCategory = _categoryController.text.isEmpty ? 'all' : _categoryController.text;
              _minPrice = _minPriceController.text.isEmpty ? null : double.tryParse(_minPriceController.text);
              _maxPrice = _maxPriceController.text.isEmpty ? null : double.tryParse(_maxPriceController.text);
              _selectedCurrency = _currencyController.text.isEmpty ? 'all' : _currencyController.text;
              
              Navigator.of(context).pop();
              _loadListings();
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Торговая площадка',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showFiltersDialog,
                icon: const Icon(Icons.filter_list),
                label: const Text('Фильтры'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_listings.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: ListView.builder(
                itemCount: _listings.length,
                itemBuilder: (context, index) {
                  final listing = _listings[index];
                  return _buildListingCard(listing);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Листинги не найдены',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить фильтры или создайте демо-данные',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await widget.blockchainService.createSampleData();
                _loadListings();
              },
              icon: const Icon(Icons.add),
              label: const Text('Создать демо-данные'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: Icon(
                    Icons.image,
                    color: Colors.grey.shade400,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NFT Токен #${listing['tokenId']?.substring(0, 8) ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing['description'] ?? 'Без описания',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        '${listing['price']?.toStringAsFixed(3) ?? '0'} ${listing['currency'] ?? 'ETH'}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Text(
                        listing['status'] ?? 'unknown',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  'Продавец',
                  listing['sellerId']?.substring(0, 8) ?? 'Unknown',
                  Icons.person,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  'Создан',
                  _formatDate(listing['createdAt']),
                  Icons.calendar_today,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  'Истекает',
                  _formatDate(listing['expiresAt']),
                  Icons.timer,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Просмотр деталей
                  },
                  icon: const Icon(Icons.info),
                  label: const Text('Детали'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _purchaseNFT(listing['id']),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Купить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Неизвестно';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return 'Неизвестно';
    }
  }
}

