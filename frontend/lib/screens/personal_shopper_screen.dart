import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/personal_shopper_service.dart';
import '../components/product_card.dart';
import '../models/product.dart';

class PersonalShopperScreen extends StatefulWidget {
  const PersonalShopperScreen({Key? key}) : super(key: key);

  @override
  _PersonalShopperScreenState createState() => _PersonalShopperScreenState();
}

class _PersonalShopperScreenState extends State<PersonalShopperScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PersonalShopperService _service = PersonalShopperService();
  
  // Данные
  List<AIRecommendation> _recommendations = [];
  List<WishlistItem> _wishlistItems = [];
  UserPreferences? _preferences;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _insights;
  
  // Состояние загрузки
  bool _isLoading = false;
  bool _isGeneratingRecommendations = false;
  String _errorMessage = '';

  // Фильтры
  String? _selectedCategory;
  String? _selectedType;
  
  final String _userId = 'user123'; // В реальном приложении получать из auth

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.wait([
        _loadRecommendations(),
        _loadWishlist(),
        _loadPreferences(),
        _loadStats(),
        _loadInsights(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки данных: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecommendations() async {
    final recommendations = await _service.getPersonalRecommendations(
      _userId,
      category: _selectedCategory,
      type: _selectedType,
    );
    
    setState(() {
      _recommendations = recommendations;
    });
  }

  Future<void> _loadWishlist() async {
    final wishlist = await _service.getWishlist(_userId);
    setState(() {
      _wishlistItems = wishlist;
    });
  }

  Future<void> _loadPreferences() async {
    final preferences = await _service.getUserPreferences(_userId);
    setState(() {
      _preferences = preferences;
    });
  }

  Future<void> _loadStats() async {
    final stats = await _service.getUserStats(_userId);
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _loadInsights() async {
    final insights = await _service.getUserInsights(_userId);
    setState(() {
      _insights = insights;
    });
  }

  Future<void> _generateNewRecommendations() async {
    setState(() {
      _isGeneratingRecommendations = true;
    });

    try {
      final newRecommendations = await _service.generateRecommendations(
        _userId,
        category: _selectedCategory,
      );
      
      setState(() {
        _recommendations = newRecommendations;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Сгенерировано ${newRecommendations.length} новых рекомендаций'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка генерации рекомендаций: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingRecommendations = false;
      });
    }
  }

  Future<void> _analyzePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _service.analyzeUserPreferences(_userId);
      if (success) {
        await _loadPreferences();
        await _loadInsights();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Предпочтения успешно проанализированы'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка анализа предпочтений: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onRecommendationTap(AIRecommendation recommendation) {
    // Отмечаем как просмотренную
    _service.markRecommendationViewed(recommendation.id);
    
    // Открываем товар
    // Navigator.push(...) - переход к детальному просмотру товара
  }

  void _onRecommendationFavorite(AIRecommendation recommendation) async {
    final product = recommendation.toProduct();
    final success = await _service.addToWishlist(_userId, product);
    
    if (success) {
      await _loadWishlist();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добавлено в избранное'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _onWishlistItemRemove(WishlistItem item) async {
    final success = await _service.removeFromWishlist(_userId, item.productId);
    
    if (success) {
      await _loadWishlist();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Удалено из избранного'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Персональный Шоппер'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _analyzePreferences,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.recommend), text: 'Рекомендации'),
            Tab(icon: Icon(Icons.favorite), text: 'Избранное'),
            Tab(icon: Icon(Icons.settings), text: 'Предпочтения'),
            Tab(icon: Icon(Icons.insights), text: 'Аналитика'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecommendationsTab(),
                    _buildWishlistTab(),
                    _buildPreferencesTab(),
                    _buildAnalyticsTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return Column(
      children: [
        // Фильтры и кнопка генерации
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Все категории')),
                        ...['Одежда', 'Обувь', 'Аксессуары', 'Электроника']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _loadRecommendations();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Тип',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedType,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Все типы')),
                        ...['personal', 'trending', 'similar', 'price_drop']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                        _loadRecommendations();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingRecommendations ? null : _generateNewRecommendations,
                  icon: _isGeneratingRecommendations
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGeneratingRecommendations 
                      ? 'Генерируем...' 
                      : 'Сгенерировать новые рекомендации'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Список рекомендаций
        Expanded(
          child: _recommendations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.recommend, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Нет рекомендаций'),
                      Text('Попробуйте сгенерировать новые'),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = _recommendations[index];
                    return _buildRecommendationCard(recommendation);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(AIRecommendation recommendation) {
    final product = recommendation.toProduct();
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: recommendation.productImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(recommendation.productImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[200],
                  ),
                  child: recommendation.productImageUrl == null
                      ? const Icon(Icons.image, size: 64, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getScoreColor(recommendation.recommendationScore),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(recommendation.recommendationScore * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      recommendation.recommendationType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.productTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${recommendation.productPrice} ₽',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (recommendation.recommendationReasons.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    recommendation.recommendationReasons.first,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _onRecommendationTap(recommendation),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        child: const Text('Посмотреть', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _onRecommendationFavorite(recommendation),
                      icon: const Icon(Icons.favorite_border, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildWishlistTab() {
    return _wishlistItems.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Ваш список избранного пуст'),
                Text('Добавляйте товары из рекомендаций'),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _wishlistItems.length,
            itemBuilder: (context, index) {
              final item = _wishlistItems[index];
              return _buildWishlistItemCard(item);
            },
          );
  }

  Widget _buildWishlistItemCard(WishlistItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: item.productImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(item.productImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: Colors.grey[200],
          ),
          child: item.productImageUrl == null
              ? const Icon(Icons.image, color: Colors.grey)
              : null,
        ),
        title: Text(
          item.productTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.productPrice} ₽',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                Text(' Приоритет: ${item.priority}'),
              ],
            ),
            if (item.notes != null && item.notes!.isNotEmpty)
              Text(
                item.notes!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Редактировать'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Удалить', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'remove') {
              _onWishlistItemRemove(item);
            } else if (value == 'edit') {
              // Показать диалог редактирования
              _showEditWishlistItemDialog(item);
            }
          },
        ),
      ),
    );
  }

  void _showEditWishlistItemDialog(WishlistItem item) {
    int priority = item.priority;
    String notes = item.notes ?? '';
    int? priceAlert = item.priceAlertThreshold;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Редактировать избранное'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Приоритет: '),
                  Expanded(
                    child: Slider(
                      value: priority.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: priority.toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          priority = value.round();
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Заметки',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                controller: TextEditingController(text: notes),
                onChanged: (value) => notes = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Уведомить при цене ниже (₽)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: priceAlert?.toString() ?? '',
                ),
                onChanged: (value) {
                  priceAlert = int.tryParse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await _service.updateWishlistItem(
                  _userId,
                  item.productId,
                  priority: priority,
                  notes: notes.isNotEmpty ? notes : null,
                  priceAlertThreshold: priceAlert,
                );
                
                Navigator.pop(context);
                
                if (success) {
                  await _loadWishlist();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Элемент обновлен'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesTab() {
    if (_preferences == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка предпочтений...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreferenceSection(
            'Любимые категории',
            _preferences!.categoryPreferences,
            Icons.category,
          ),
          const SizedBox(height: 24),
          _buildPreferenceSection(
            'Предпочитаемые бренды',
            _preferences!.brandPreferences,
            Icons.branding_watermark,
          ),
          const SizedBox(height: 24),
          _buildPriceRangeSection(),
          const SizedBox(height: 24),
          _buildMarketplacesSection(),
          const SizedBox(height: 24),
          _buildBudgetSection(),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(
    String title,
    Map<String, double> preferences,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (preferences.isEmpty)
              const Text('Предпочтения не установлены')
            else
              ...preferences.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.grey[300],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (entry.value / 3).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    final minPrice = _preferences!.priceRange['min'] ?? 0;
    final maxPrice = _preferences!.priceRange['max'] ?? 1000000;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.price_change, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Ценовой диапазон',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Минимум'),
                      Text(
                        '$minPrice ₽',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('—', style: TextStyle(fontSize: 24)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Максимум'),
                      Text(
                        '$maxPrice ₽',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplacesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.store, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Предпочитаемые площадки',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _preferences!.preferredMarketplaces.map((marketplace) => 
                Chip(
                  label: Text(marketplace),
                  backgroundColor: Colors.blue[100],
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Месячный бюджет',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${_preferences!.budgetMonthly} ₽',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_stats != null) _buildStatsSection(),
          const SizedBox(height: 24),
          if (_insights != null) _buildInsightsSection(),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final views = _stats!['views'] ?? {};
    final purchases = _stats!['purchases'] ?? {};
    final wishlist = _stats!['wishlist'] ?? {};
    final recommendations = _stats!['recommendations'] ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Статистика',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Просмотров',
                    (views['total_views'] ?? 0).toString(),
                    Icons.visibility,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Покупок',
                    (purchases['total_purchases'] ?? 0).toString(),
                    Icons.shopping_bag,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'В избранном',
                    (wishlist['items_count'] ?? 0).toString(),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Рекомендаций',
                    (recommendations['total_generated'] ?? 0).toString(),
                    Icons.recommend,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.money, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Потрачено: '),
                Text(
                  '${purchases['total_spent'] ?? 0} ₽',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    final topCategories = List<Map<String, dynamic>>.from(_insights!['top_categories'] ?? []);
    final topBrands = List<Map<String, dynamic>>.from(_insights!['top_brands'] ?? []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Аналитика предпочтений',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (topCategories.isNotEmpty) ...[
              const Text(
                'Любимые категории:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...topCategories.take(3).map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Text('• '),
                    Text(cat['category'] ?? ''),
                    const Spacer(),
                    Text(
                      '${(cat['score'] as double).toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            if (topBrands.isNotEmpty) ...[
              const Text(
                'Любимые бренды:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...topBrands.take(3).map((brand) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Text('• '),
                    Text(brand['brand'] ?? ''),
                    const Spacer(),
                    Text(
                      '${(brand['score'] as double).toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
