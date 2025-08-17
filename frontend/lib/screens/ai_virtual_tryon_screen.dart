import 'package:flutter/material.dart';
import 'dart:math';

class AIVirtualTryOnScreen extends StatefulWidget {
  const AIVirtualTryOnScreen({super.key});

  @override
  State<AIVirtualTryOnScreen> createState() => _AIVirtualTryOnScreenState();
}

class _AIVirtualTryOnScreenState extends State<AIVirtualTryOnScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Верхняя одежда';
  String _selectedStyle = 'Повседневный';
  bool _isProcessing = false;
  List<Map<String, dynamic>> _tryOnHistory = [];
  List<Map<String, dynamic>> _favoriteOutfits = [];
  
  // Контроллеры для размеров
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _shoulderController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();

  final List<String> _categories = [
    'Верхняя одежда', 'Платья', 'Брюки', 'Юбки', 'Обувь', 'Аксессуары'
  ];

  final List<String> _styles = [
    'Повседневный', 'Деловой', 'Вечерний', 'Спортивный', 'Классический', 'Творческий'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
    _initializeMeasurements();
  }

  void _initializeMeasurements() {
    _heightController.text = '170';
    _weightController.text = '65';
    _shoulderController.text = '42';
    _chestController.text = '88';
    _waistController.text = '70';
    _hipController.text = '92';
  }

  void _loadMockData() {
    _tryOnHistory = [
      {
        'id': '1',
        'productName': 'Классическое черное платье',
        'category': 'Платья',
        'style': 'Вечерний',
        'imageUrl': 'https://via.placeholder.com/200x300/000000/FFFFFF?text=Dress',
        'tryOnUrl': 'https://via.placeholder.com/200x300/FF6B6B/FFFFFF?text=Try+On',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'rating': 4.5,
        'favorite': true,
      },
      {
        'id': '2',
        'productName': 'Джинсы классического кроя',
        'category': 'Брюки',
        'style': 'Повседневный',
        'imageUrl': 'https://via.placeholder.com/200x300/000080/FFFFFF?text=Jeans',
        'tryOnUrl': 'https://via.placeholder.com/200x300/4ECDC4/FFFFFF?text=Try+On',
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
        'rating': 4.2,
        'favorite': false,
      },
    ];

    _favoriteOutfits = [
      {
        'id': '1',
        'name': 'Деловой образ',
        'items': ['Пиджак', 'Блузка', 'Брюки'],
        'imageUrl': 'https://via.placeholder.com/300x400/2C3E50/FFFFFF?text=Business+Look',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '2',
        'name': 'Вечерний образ',
        'items': ['Платье', 'Туфли', 'Сумка'],
        'imageUrl': 'https://via.placeholder.com/300x400/8E44AD/FFFFFF?text=Evening+Look',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _shoulderController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }

  Future<void> _startVirtualTryOn() async {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните основные размеры')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Имитация обработки
    await Future.delayed(const Duration(seconds: 3));

    final newTryOn = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'productName': 'Новый товар для примерки',
      'category': _selectedCategory,
      'style': _selectedStyle,
      'imageUrl': 'https://via.placeholder.com/200x300/95A5A6/FFFFFF?text=Product',
      'tryOnUrl': 'https://via.placeholder.com/200x300/${_getRandomColor()}/FFFFFF?text=Try+On',
      'createdAt': DateTime.now(),
      'rating': 0.0,
      'favorite': false,
    };

    setState(() {
      _tryOnHistory.insert(0, newTryOn);
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Виртуальная примерка готова!')),
    );
  }

  String _getRandomColor() {
    final colors = ['FF6B6B', '4ECDC4', '45B7D1', '96CEB4', 'FFEAA7', 'DDA0DD'];
    return colors[Random().nextInt(colors.length)];
  }

  void _toggleFavorite(String tryOnId) {
    setState(() {
      final tryOn = _tryOnHistory.firstWhere((item) => item['id'] == tryOnId);
      tryOn['favorite'] = !(tryOn['favorite'] ?? false);
    });
  }

  void _rateTryOn(String tryOnId, double rating) {
    setState(() {
      final tryOn = _tryOnHistory.firstWhere((item) => item['id'] == tryOnId);
      tryOn['rating'] = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Виртуальная Примерка'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Показать избранные образы
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Показать историю примерок
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
                  'Настройки примерки',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Основные размеры
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Рост (см)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Вес (кг)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Дополнительные размеры
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _shoulderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Плечи (см)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _chestController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Грудь (см)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _waistController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Талия (см)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _hipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Бедра (см)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Категория и стиль
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Категория',
                          border: OutlineInputBorder(),
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
                        value: _selectedStyle,
                        decoration: const InputDecoration(
                          labelText: 'Стиль',
                          border: OutlineInputBorder(),
                        ),
                        items: _styles.map((style) {
                          return DropdownMenuItem(
                            value: style,
                            child: Text(style),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStyle = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _startVirtualTryOn,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt),
                    label: Text(_isProcessing ? 'Обрабатываем...' : 'Начать примерку'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
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
              Tab(text: 'История примерок'),
              Tab(text: 'Избранные образы'),
              Tab(text: 'Настройки'),
            ],
          ),
          
          // Содержимое табов
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTryOnHistoryTab(),
                _buildFavoriteOutfitsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTryOnHistoryTab() {
    if (_tryOnHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Попробуйте виртуальную примерку!',
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
      itemCount: _tryOnHistory.length,
      itemBuilder: (context, index) {
        final tryOn = _tryOnHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображения
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Оригинал',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tryOn['imageUrl'],
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Примерка',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tryOn['tryOnUrl'],
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
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
                      ],
                    ),
                  ),
                ],
              ),
              
              // Информация
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tryOn['productName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Chip(
                          label: Text(tryOn['category']),
                          backgroundColor: Colors.blue[100],
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(tryOn['style']),
                          backgroundColor: Colors.green[100],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Рейтинг
                    Row(
                      children: [
                        const Text('Оценка: '),
                        ...List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => _rateTryOn(tryOn['id'], index + 1.0),
                            child: Icon(
                              index < (tryOn['rating'] ?? 0).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text('${tryOn['rating']}'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                tryOn['favorite'] ?? false
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: tryOn['favorite'] ?? false
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () => _toggleFavorite(tryOn['id']),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                // Поделиться
                              },
                            ),
                          ],
                        ),
                        Text(
                          '${tryOn['createdAt'].hour}:${tryOn['createdAt'].minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
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
      },
    );
  }

  Widget _buildFavoriteOutfitsTab() {
    if (_favoriteOutfits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Добавьте образы в избранное!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _favoriteOutfits.length,
      itemBuilder: (context, index) {
        final outfit = _favoriteOutfits[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    outfit['imageUrl'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      outfit['items'].join(', '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки примерки',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSettingItem(
            icon: Icons.camera_alt,
            title: 'Качество камеры',
            subtitle: 'Высокое разрешение',
            onTap: () {
              // Настройка качества
            },
          ),
          
          _buildSettingItem(
            icon: Icons.light_mode,
            title: 'Освещение',
            subtitle: 'Автоматическое',
            onTap: () {
              // Настройка освещения
            },
          ),
          
          _buildSettingItem(
            icon: Icons.style,
            title: 'Стиль примерки',
            subtitle: 'Реалистичный',
            onTap: () {
              // Настройка стиля
            },
          ),
          
          _buildSettingItem(
            icon: Icons.save,
            title: 'Автосохранение',
            subtitle: 'Включено',
            onTap: () {
              // Настройка автосохранения
            },
          ),
          
          _buildSettingItem(
            icon: Icons.share,
            title: 'Поделиться результатами',
            subtitle: 'Включено',
            onTap: () {
              // Настройка шаринга
            },
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Калибровка камеры
              },
              icon: const Icon(Icons.camera_roll),
              label: const Text('Калибровать камеру'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
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
