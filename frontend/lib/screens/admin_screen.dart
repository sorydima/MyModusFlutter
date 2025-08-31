import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import '../theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService _apiService = ApiService();
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const AdminDashboard(),
    const AdminProductsScreen(),
    const AdminOrdersScreen(),
    const AdminScrapingScreen(),
  ];

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement admin logout
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.scanner),
            label: 'Scraping',
          ),
        ],
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load analytics data
      final analytics = await _apiService.getAnalytics();
      setState(() {
        _stats = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Stats cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dashboard Overview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                          children: [
                            _buildStatCard(
                              title: 'Total Products',
                              value: _stats['totalProducts']?.toString() ?? '0',
                              icon: Icons.inventory_2,
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              title: 'Total Orders',
                              value: _stats['totalOrders']?.toString() ?? '0',
                              icon: Icons.shopping_cart,
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              title: 'Total Revenue',
                              value: '${_stats['totalRevenue']?.toString() ?? '0'}',
                              icon: Icons.attach_money,
                              color: Colors.amber,
                            ),
                            _buildStatCard(
                              title: 'Active Users',
                              value: _stats['activeUsers']?.toString() ?? '0',
                              icon: Icons.people,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Quick actions
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                          children: [
                            _buildActionButton(
                              icon: Icons.add,
                              label: 'Add Product',
                              color: Colors.blue,
                              onPressed: () => Navigator.pushNamed(context, '/admin/products/new'),
                            ),
                            _buildActionButton(
                              icon: Icons.file_download,
                              label: 'Export Data',
                              color: Colors.green,
                              onPressed: _exportData,
                            ),
                            _buildActionButton(
                              icon: Icons.file_upload,
                              label: 'Import Data',
                              color: Colors.orange,
                              onPressed: _importData,
                            ),
                            _buildActionButton(
                              icon: Icons.scanner,
                              label: 'Start Scraping',
                              color: Colors.purple,
                              onPressed: () => Navigator.pushNamed(context, '/admin/scraping'),
                            ),
                            _buildActionButton(
                              icon: Icons.notifications,
                              label: 'Send Push',
                              color: Colors.red,
                              onPressed: _sendPushNotification,
                            ),
                            _buildActionButton(
                              icon: Icons.settings,
                              label: 'Settings',
                              color: Colors.grey,
                              onPressed: () => Navigator.pushNamed(context, '/admin/settings'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recent orders
                        const Text(
                          'Recent Orders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Orders list
                        _buildRecentOrders(),
                        
                        const SizedBox(height: 24),
                        
                        // Top products
                        const Text(
                          'Top Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Products list
                        _buildTopProducts(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentOrders.length,
        itemBuilder: (context, index) {
          final order = _recentOrders[index];
          return _buildOrderItem(order);
        },
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return ListTile(
      leading: const Icon(Icons.shopping_bag),
      title: Text('Order #${order['id']}'),
      subtitle: Text('${order['customer']} • ${order['date']}'),
      trailing: Text(
        '${order['total']}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _topProducts.length,
        itemBuilder: (context, index) {
          final product = _topProducts[index];
          return _buildProductItem(product);
        },
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return ListTile(
      leading: Image.network(
        product['imageUrl'],
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
      title: Text(product['title']),
      subtitle: Text('${product['orders']} orders'),
      trailing: Text(
        '${product['revenue']}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final data = await _apiService.exportData();
      // TODO: Implement file download
      Fluttertoast.showToast(
        msg: 'Data exported successfully!',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error exporting data: $e',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _importData() async {
    // TODO: Implement file upload and import
    Fluttertoast.showToast(
      msg: 'Import feature coming soon!',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  Future<void> _sendPushNotification() async {
    // TODO: Implement push notification sending
    Fluttertoast.showToast(
      msg: 'Push notification feature coming soon!',
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Products Management'),
    );
  }
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Orders Management'),
    );
  }
}

class AdminScrapingScreen extends StatefulWidget {
  const AdminScrapingScreen({Key? key}) : super(key: key);

  @override
  State<AdminScrapingScreen> createState() => _AdminScrapingScreenState();
}

class _AdminScrapingScreenState extends State<AdminScrapingScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _scrapingJobs = [];
  Map<String, dynamic> _scrapingStats = {};

  @override
  void initState() {
    super.initState();
    _loadScrapingData();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadScrapingData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobs = await _apiService.getScrapingJobs();
      final stats = await _apiService.getScrapingStats();
      
      setState(() {
        _scrapingJobs = jobs;
        _scrapingStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading scraping data: $e')),
        );
      }
    }
  }

  Future<void> _startScraping(String source) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.startScrapingSource(source);
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Scraping started for $source',
          toastLength: Toast.LENGTH_SHORT,
        );
        
        // Refresh data after a delay
        Future.delayed(const Duration(seconds: 2), _loadScrapingData);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting scraping: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadScrapingData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scraping Statistics',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats cards
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                          children: [
                            _buildStatCard(
                              title: 'Total Products',
                              value: _scrapingStats['totalProducts']?.toString() ?? '0',
                              icon: Icons.inventory_2,
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              title: 'Products Today',
                              value: _scrapingStats['productsToday']?.toString() ?? '0',
                              icon: Icons.today,
                              color: Colors.green,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Control buttons
                        const Text(
                          'Scraping Control',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () => _startScraping('wildberries'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Wildberries'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () => _startScraping('ozon'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Ozon'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () => _startScraping('lamoda'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Lamoda'),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recent jobs
                        const Text(
                          'Recent Scraping Jobs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Jobs list
                        _buildJobsList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    if (_scrapingJobs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text('No scraping jobs found'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _scrapingJobs.length,
        itemBuilder: (context, index) {
          final job = _scrapingJobs[index];
          return _buildJobItem(job);
        },
      ),
    );
  }

  Widget _buildJobItem(Map<String, dynamic> job) {
    return ListTile(
      leading: Icon(
        job['status'] == 'completed' ? Icons.check_circle : Icons.schedule,
        color: job['status'] == 'completed' ? Colors.green : Colors.orange,
      ),
      title: Text('${job['source'].toUpperCase()} - ${job['status']}'),
      subtitle: Text('Products: ${job['productsScraped']}'),
      trailing: Text(
        job['completedAt'] != null ? 'Completed' : 'Running',
        style: TextStyle(
          color: job['status'] == 'completed' ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}