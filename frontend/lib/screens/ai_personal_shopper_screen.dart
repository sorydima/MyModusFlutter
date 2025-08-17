import 'package:flutter/material.dart';

class AIPersonalShopperScreen extends StatefulWidget {
  const AIPersonalShopperScreen({super.key});

  @override
  State<AIPersonalShopperScreen> createState() => _AIPersonalShopperScreenState();
}

class _AIPersonalShopperScreenState extends State<AIPersonalShopperScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _occasionController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  
  String _selectedBudgetRange = 'Средний';
  String _selectedSeason = 'Лето';
  String _selectedPriority = 'Качество';
  bool _isAnalyzing = false;
  
  List<Map<String, dynamic>> _shoppingList = [];
  List<Map<String, dynamic>> _recommendations = [];
  List<Map<String, dynamic>> _budgetHistory = [];
  List<Map<String, dynamic>> _stylePreferences = [];

  final List<String> _budgetRanges = [
    'Экономный', 'Средний', 'Высокий', 'Премиум'
  ];

  final List<String> _seasons = [
    'Весна', 'Лето', 'Осень', 'Зима'
  ];

  final List<String> _priorities = [
    'Качество', 'Цена', 'Стиль', 'Бренд', 'Универсальность'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMockData();
    _initializeControllers();
  }

  void _initializeControllers() {
    _budgetController.text = '50000';
    _occasionController.text = 'Повседневная одежда';
    _styleController.text = 'Современный минимализм';
  }

  void _loadMockData() {
    _shoppingList = [
      {
        'id': '1',
        'item': 'Джинсы классического кроя',
        'category': 'Брюки',
        'budget': 8000,
        'priority': 'Высокий',
        'status': 'pending',
        'addedAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '2',
        'item': 'Белая футболка',
        'category': 'Футболки',
        'budget': 3000,
        'priority': 'Средний',
        'status': 'completed',
        'addedAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '3',
        'item': 'Кроссовки для повседневной носки',
        'category': 'Обувь',
        'budget': 12000,
        'priority': 'Высокий',
        'status': 'pending',
        'addedAt': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    _recommendations = [
      {
        'id': '1',
        'product': 'Пиджак oversize',
        'category': 'Верхняя одежда',
        'price': 15000,
        'match': 95,
        'reason': 'Отлично подходит к вашему стилю',
        'imageUrl': 'https://via.placeholder.com/150x200/2C3E50/FFFFFF?text=Blazer',
      },
      {
        'id': '2',
        'product': 'Платье миди',
        'category': 'Платья',
        'price': 12000,
        'match': 88,
        'reason': 'Соответствует вашему бюджету',
        'imageUrl': 'https://via.placeholder.com/150x200/8E44AD/FFFFFF?text=Dress',
      },
    ];

    _budgetHistory = [
      {
        'month': 'Январь',
        'budget': 50000,
        'spent': 32000,
        'saved': 18000,
      },
      {
        'month': 'Февраль',
        'budget': 45000,
        'spent': 28000,
        'saved': 17000,
      },
    ];

    _stylePreferences = [
      {
        'style': 'Минимализм',
        'percentage': 85,
        'color': Colors.grey,
      },
      {
        'style': 'Классика',
        'percentage': 70,
        'color': Colors.blue,
      },
      {
        'style': 'Современность',
        'percentage': 65,
        'color': Colors.green,
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _budgetController.dispose();
    _occasionController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  Future<void> _analyzePreferences() async {
    if (_budgetController.text.isEmpty || _occasionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните основные поля')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // Имитация анализа
    await Future.delayed(const Duration(seconds: 2));

    final newRecommendation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'product': 'Новая рекомендация',
      'category': 'Автоматически подобранная',
      'price': int.parse(_budgetController.text) ~/ 3,
      'match': 90 + (DateTime.now().millisecond % 10),
      'reason': 'На основе ваших предпочтений',
      'imageUrl': 'https://via.placeholder.com/150x200/95A5A6/FFFFFF?text=New',
    };

    setState(() {
      _recommendations.insert(0, newRecommendation);
      _isAnalyzing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Анализ завершен!')),
    );
  }

  void _addToShoppingList() {
    if (_styleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название товара')),
      );
      return;
    }

    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'item': _styleController.text.trim(),
      'category': 'Автоматически определенная',
      'budget': int.parse(_budgetController.text) ~/ 4,
      'priority': _selectedPriority,
      'status': 'pending',
      'addedAt': DateTime.now(),
    };

    setState(() {
      _shoppingList.insert(0, newItem);
      _styleController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Добавлено в список покупок!')),
    );
  }

  void _toggleItemStatus(String itemId) {
    setState(() {
      final item = _shoppingList.firstWhere((item) => item['id'] == itemId);
      item['status'] = item['status'] == 'pending' ? 'completed' : 'pending';
    });
  }

  void _removeFromList(String itemId) {
    setState(() {
      _shoppingList.removeWhere((item) => item['id'] == itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Персональный Шоппер'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Показать корзину
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              // Показать аналитику
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Форма настроек
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Персональные настройки',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Бюджет и приоритеты
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Бюджет (₽)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBudgetRange,
                        decoration: const InputDecoration(
                          labelText: 'Диапазон',
                          border: OutlineInputBorder(),
                        ),
                        items: _budgetRanges.map((range) {
                          return DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBudgetRange = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Сезон и приоритет
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSeason,
                        decoration: const InputDecoration(
                          labelText: 'Сезон',
                          border: OutlineInputBorder(),
                        ),
                        items: _seasons.map((season) {
                          return DropdownMenuItem(
                            value: season,
                            child: Text(season),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSeason = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Приоритет',
                          border: OutlineInputBorder(),
                        ),
                        items: _priorities.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Повод и стиль
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _occasionController,
                        decoration: const InputDecoration(
                          labelText: 'Повод',
                          hintText: 'Для чего нужна одежда?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _styleController,
                        decoration: const InputDecoration(
                          labelText: 'Товар',
                          hintText: 'Что хотите купить?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Кнопки
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _analyzePreferences,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.psychology),
                        label: Text(_isAnalyzing ? 'Анализируем...' : 'Анализировать'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addToShoppingList,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Добавить в список'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Табы
          TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: const [
              Tab(text: 'Список покупок'),
              Tab(text: 'Рекомендации'),
              Tab(text: 'Бюджет'),
              Tab(text: 'Предпочтения'),
            ],
          ),
          
          // Содержимое табов
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShoppingListTab(),
                _buildRecommendationsTab(),
                _buildBudgetTab(),
                _buildPreferencesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListTab() {
    if (_shoppingList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Добавьте товары в список покупок!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _shoppingList.length,
      itemBuilder: (context, index) {
        final item = _shoppingList[index];
        final isCompleted = item['status'] == 'completed';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.shopping_bag,
                color: isCompleted ? Colors.green : Colors.blue,
              ),
            ),
            title: Text(
              item['item'],
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item['category']} • ${item['budget']} ₽'),
                Text(
                  'Приоритет: ${item['priority']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isCompleted ? Icons.undo : Icons.check,
                    color: isCompleted ? Colors.orange : Colors.green,
                  ),
                  onPressed: () => _toggleItemStatus(item['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeFromList(item['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsTab() {
    if (_recommendations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Получите персональные рекомендации!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = _recommendations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    recommendation['imageUrl'],
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 32,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['product'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation['category'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${recommendation['price']} ₽',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${recommendation['match']}%',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendation['reason'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {
                        // Добавить в избранное
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        // Добавить в корзину
                      },
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

  Widget _buildBudgetTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Управление бюджетом',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Текущий месяц
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple[200]!),
            ),
            child: Column(
              children: [
                const Text(
                  'Текущий месяц',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBudgetItem('Бюджет', '${_budgetController.text} ₽', Colors.blue),
                    _buildBudgetItem('Потрачено', '0 ₽', Colors.orange),
                    _buildBudgetItem('Осталось', '${_budgetController.text} ₽', Colors.green),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'История',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._budgetHistory.map((month) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Text(
                    month['month'][0],
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(month['month']),
                subtitle: Text('Бюджет: ${month['budget']} ₽'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Потрачено: ${month['spent']} ₽',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Сэкономлено: ${month['saved']} ₽',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ваши стилистические предпочтения',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          ..._stylePreferences.map((style) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        style['style'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${style['percentage']}%',
                        style: TextStyle(
                          color: style['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: style['percentage'] / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(style['color']),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 32),
          
          const Text(
            'Настройки персонализации',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Уведомления о скидках',
            subtitle: 'Включено',
            onTap: () {
              // Настройка уведомлений
            },
          ),
          
          _buildSettingItem(
            icon: Icons.trending_up,
            title: 'Анализ трендов',
            subtitle: 'Автоматически',
            onTap: () {
              // Настройка анализа
            },
          ),
          
          _buildSettingItem(
            icon: Icons.sync,
            title: 'Обновление предпочтений',
            subtitle: 'Еженедельно',
            onTap: () {
              // Настройка обновлений
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
