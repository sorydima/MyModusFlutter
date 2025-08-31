import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AIShoppingAssistantScreen extends StatefulWidget {
  const AIShoppingAssistantScreen({super.key});

  @override
  State<AIShoppingAssistantScreen> createState() => _AIShoppingAssistantScreenState();
}

class _AIShoppingAssistantScreenState extends State<AIShoppingAssistantScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  
  String _selectedCategory = 'all';
  String _selectedPriceRange = '100-500';
  String _selectedOccasion = 'daily';
  bool _isSearching = false;
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _recommendedProducts = [
    {
      'id': '1',
      'name': 'Summer Floral Dress',
      'brand': 'Zara',
      'price': 89.99,
      'originalPrice': 129.99,
      'discount': 31,
      'rating': 4.5,
      'reviews': 128,
      'image': 'assets/images/dress1.jpg',
      'category': 'dresses',
      'occasion': 'casual',
      'colors': ['Blue', 'Pink', 'White'],
      'sizes': ['XS', 'S', 'M', 'L'],
    },
    {
      'id': '2',
      'name': 'Classic Denim Jacket',
      'brand': 'Levi\'s',
      'price': 149.99,
      'originalPrice': 199.99,
      'discount': 25,
      'rating': 4.8,
      'reviews': 89,
      'image': 'assets/images/jacket1.jpg',
      'category': 'outerwear',
      'occasion': 'casual',
      'colors': ['Blue', 'Black', 'White'],
      'sizes': ['S', 'M', 'L', 'XL'],
    },
    {
      'id': '3',
      'name': 'High-Waisted Skinny Jeans',
      'brand': 'H&M',
      'price': 59.99,
      'originalPrice': 79.99,
      'discount': 25,
      'rating': 4.3,
      'reviews': 256,
      'image': 'assets/images/jeans1.jpg',
      'category': 'bottoms',
      'occasion': 'casual',
      'colors': ['Blue', 'Black', 'Gray'],
      'sizes': ['24', '26', '28', '30', '32'],
    },
  ];

  final List<Map<String, dynamic>> _shoppingList = [
    {
      'id': '1',
      'name': 'White Blouse',
      'category': 'tops',
      'priority': 'high',
      'budget': 50.0,
      'added': '2 days ago',
      'completed': false,
    },
    {
      'id': '2',
      'name': 'Black Blazer',
      'category': 'outerwear',
      'priority': 'medium',
      'budget': 150.0,
      'added': '1 week ago',
      'completed': false,
    },
    {
      'id': '3',
      'name': 'Summer Sandals',
      'category': 'shoes',
      'priority': 'low',
      'budget': 80.0,
      'added': '3 days ago',
      'completed': true,
    },
  ];

  final List<Map<String, dynamic>> _priceAlerts = [
    {
      'id': '1',
      'product': 'Summer Dress',
      'currentPrice': 89.99,
      'targetPrice': 70.0,
      'store': 'Zara',
      'expires': '3 days',
      'status': 'active',
    },
    {
      'id': '2',
      'product': 'Denim Jacket',
      'currentPrice': 149.99,
      'targetPrice': 120.0,
      'store': 'Levi\'s',
      'expires': '1 week',
      'status': 'active',
    },
    {
      'id': '3',
      'product': 'Running Shoes',
      'currentPrice': 120.0,
      'targetPrice': 100.0,
      'store': 'Nike',
      'expires': 'Expired',
      'status': 'expired',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _searchProducts() {
    setState(() {
      _isSearching = true;
    });

    // Simulate AI search
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSearching = false;
      });
      
      _showSearchResults();
    });
  }

  void _showSearchResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Shopping Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Based on your preferences and budget, here are my recommendations:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Shopping Tips:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Consider buying versatile pieces that mix and match\n• Look for quality over quantity within your budget\n• Check for seasonal sales and discounts\n• Read reviews from similar body types',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Found ${_recommendedProducts.length} products matching your criteria',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(1);
            },
            child: const Text('View Products'),
          ),
        ],
      ),
    );
  }

  void _addToShoppingList(String productName) {
    setState(() {
      _shoppingList.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': productName,
        'category': 'general',
        'priority': 'medium',
        'budget': 0.0,
        'added': 'Just now',
        'completed': false,
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$productName added to shopping list!')),
    );
  }

  void _toggleShoppingItem(String id) {
    setState(() {
      final item = _shoppingList.firstWhere((item) => item['id'] == id);
      item['completed'] = !item['completed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Shopping Assistant'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search', icon: Icon(Icons.search)),
            Tab(text: 'Products', icon: Icon(Icons.shopping_bag)),
            Tab(text: 'Shopping List', icon: Icon(Icons.list)),
            Tab(text: 'Price Alerts', icon: Icon(Icons.notifications)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildProductsTab(),
          _buildShoppingListTab(),
          _buildPriceAlertsTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Product Search',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'What are you looking for?',
                      hintText: 'e.g., summer dress, casual blazer, comfortable shoes...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Budget Range',
                      hintText: 'e.g., \$50-200',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedCategory,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Categories')),
                            DropdownMenuItem(value: 'tops', child: Text('Tops')),
                            DropdownMenuItem(value: 'bottoms', child: Text('Bottoms')),
                            DropdownMenuItem(value: 'dresses', child: Text('Dresses')),
                            DropdownMenuItem(value: 'outerwear', child: Text('Outerwear')),
                            DropdownMenuItem(value: 'shoes', child: Text('Shoes')),
                            DropdownMenuItem(value: 'accessories', child: Text('Accessories')),
                          ],
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
                          decoration: const InputDecoration(
                            labelText: 'Occasion',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedOccasion,
                          items: const [
                            DropdownMenuItem(value: 'daily', child: Text('Daily')),
                            DropdownMenuItem(value: 'work', child: Text('Work')),
                            DropdownMenuItem(value: 'casual', child: Text('Casual')),
                            DropdownMenuItem(value: 'formal', child: Text('Formal')),
                            DropdownMenuItem(value: 'sport', child: Text('Sport')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedOccasion = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Price Range',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedPriceRange,
                    items: const [
                      DropdownMenuItem(value: '0-50', child: Text('\$0 - \$50')),
                      DropdownMenuItem(value: '50-100', child: Text('\$50 - \$100')),
                      DropdownMenuItem(value: '100-500', child: Text('\$100 - \$500')),
                      DropdownMenuItem(value: '500+', child: Text('\$500+')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPriceRange = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _searchController.text.isNotEmpty ? _searchProducts : null,
                      icon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.smart_toy),
                      label: Text(_isSearching ? 'Searching...' : 'AI Smart Search'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickSearchChip('Work outfits under \$100'),
                      _buildQuickSearchChip('Summer dresses'),
                      _buildQuickSearchChip('Comfortable shoes'),
                      _buildQuickSearchChip('Casual blazers'),
                      _buildQuickSearchChip('Weekend looks'),
                      _buildQuickSearchChip('Accessories under \$50'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String search) {
    return ActionChip(
      label: Text(search),
      onPressed: () {
        _searchController.text = search;
      },
      backgroundColor: Colors.blue.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.blue),
    );
  }

  Widget _buildProductsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recommendedProducts.length,
      itemBuilder: (context, index) {
        final product = _recommendedProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product['brand'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '\$${product['price']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${product['originalPrice']}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '-${product['discount']}%',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber[600]),
                              Text(' ${product['rating']} (${product['reviews']})'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Colors: '),
                    ...product['colors'].map((color) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        color,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Sizes: '),
                    ...product['sizes'].map((size) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        size,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _addToShoppingList(product['name']),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to List'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Buy Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShoppingListTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _shoppingList.length,
      itemBuilder: (context, index) {
        final item = _shoppingList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: item['completed'],
              onChanged: (value) => _toggleShoppingItem(item['id']),
            ),
            title: Text(
              item['name'],
              style: TextStyle(
                decoration: item['completed'] ? TextDecoration.lineThrough : null,
                color: item['completed'] ? Colors.grey : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(item['priority']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['priority'].toUpperCase(),
                        style: TextStyle(
                          color: _getPriorityColor(item['priority']),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['category'],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Budget: \$${item['budget']} • Added: ${item['added']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  setState(() {
                    _shoppingList.removeWhere((item) => item['id'] == _shoppingList[index]['id']);
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceAlertsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _priceAlerts.length,
      itemBuilder: (context, index) {
        final alert = _priceAlerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getAlertStatusColor(alert['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getAlertStatusIcon(alert['status']),
                color: _getAlertStatusColor(alert['status']),
              ),
            ),
            title: Text(alert['product']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Current: \$${alert['currentPrice']}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Target: \$${alert['targetPrice']}',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert['store']} • Expires: ${alert['expires']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAlertStatusColor(alert['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                alert['status'].toUpperCase(),
                style: TextStyle(
                  color: _getAlertStatusColor(alert['status']),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getAlertStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.notifications_active;
      case 'expired':
        return Icons.notifications_off;
      default:
        return Icons.notifications;
    }
  }
}
