import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AIProductImageGeneratorScreen extends StatefulWidget {
  const AIProductImageGeneratorScreen({super.key});

  @override
  State<AIProductImageGeneratorScreen> createState() => _AIProductImageGeneratorScreenState();
}

class _AIProductImageGeneratorScreenState extends State<AIProductImageGeneratorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  
  String _selectedCategory = 'Одежда';
  String _selectedStyle = 'Современный';
  String _selectedQuality = 'Высокое';
  bool _isGenerating = false;
  List<Map<String, dynamic>> _generatedImages = [];
  List<Map<String, dynamic>> _generationHistory = [];

  final List<String> _categories = [
    'Одежда', 'Обувь', 'Аксессуары', 'Сумки', 'Украшения', 'Косметика'
  ];

  final List<String> _styles = [
    'Современный', 'Классический', 'Винтажный', 'Минималистичный', 'Экстравагантный', 'Спортивный'
  ];

  final List<String> _qualities = [
    'Низкое', 'Среднее', 'Высокое', 'Премиум'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
  }

  void _loadMockData() {
    _generatedImages = [
      {
        'id': '1',
        'url': 'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=AI+Generated+1',
        'description': 'Красное платье в стиле 60-х',
        'category': 'Одежда',
        'style': 'Винтажный',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'likes': 24,
        'downloads': 12,
      },
      {
        'id': '2',
        'url': 'https://via.placeholder.com/300x400/4ECDC4/FFFFFF?text=AI+Generated+2',
        'description': 'Минималистичная белая футболка',
        'category': 'Одежда',
        'style': 'Минималистичный',
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
        'likes': 18,
        'downloads': 8,
      },
    ];

    _generationHistory = [
      {
        'id': '1',
        'description': 'Элегантное черное платье',
        'status': 'completed',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'resultCount': 4,
      },
      {
        'id': '2',
        'description': 'Спортивные кроссовки',
        'status': 'completed',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        'resultCount': 3,
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _styleController.dispose();
    _colorController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  Future<void> _generateImages() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите описание товара')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Имитация генерации
    await Future.delayed(const Duration(seconds: 3));

    final newImage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'url': 'https://via.placeholder.com/300x400/${_getRandomColor()}/FFFFFF?text=AI+Generated',
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'style': _selectedStyle,
      'createdAt': DateTime.now(),
      'likes': 0,
      'downloads': 0,
    };

    setState(() {
      _generatedImages.insert(0, newImage);
      _isGenerating = false;
    });

    // Добавляем в историю
    _generationHistory.insert(0, {
      'id': newImage['id'],
      'description': newImage['description'],
      'status': 'completed',
      'createdAt': newImage['createdAt'],
      'resultCount': 1,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Изображения сгенерированы!')),
    );
  }

  String _getRandomColor() {
    final colors = ['FF6B6B', '4ECDC4', '45B7D1', '96CEB4', 'FFEAA7', 'DDA0DD'];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }

  void _likeImage(String imageId) {
    setState(() {
      final image = _generatedImages.firstWhere((img) => img['id'] == imageId);
      image['likes'] = (image['likes'] ?? 0) + 1;
    });
  }

  void _downloadImage(String imageId) {
    setState(() {
      final image = _generatedImages.firstWhere((img) => img['id'] == imageId);
      image['downloads'] = (image['downloads'] ?? 0) + 1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Изображение скачано!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Генератор Изображений'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Показать историю генераций
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Настройки генератора
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Форма генерации
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
                  'Создайте изображение товара',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Описание
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Описание товара',
                    hintText: 'Опишите товар детально: цвет, стиль, материал...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Настройки
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
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: 'Цветовая палитра',
                          hintText: 'Основные цвета',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _materialController,
                        decoration: const InputDecoration(
                          labelText: 'Материал',
                          hintText: 'Тип ткани/материала',
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
                      child: DropdownButtonFormField<String>(
                        value: _selectedQuality,
                        decoration: const InputDecoration(
                          labelText: 'Качество',
                          border: OutlineInputBorder(),
                        ),
                        items: _qualities.map((quality) {
                          return DropdownMenuItem(
                            value: quality,
                            child: Text(quality),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQuality = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateImages,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_isGenerating ? 'Генерируем...' : 'Сгенерировать'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
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
              Tab(text: 'Результаты'),
              Tab(text: 'История'),
              Tab(text: 'Настройки'),
            ],
          ),
          
          // Содержимое табов
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResultsTab(),
                _buildHistoryTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    if (_generatedImages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Сгенерируйте первое изображение!',
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
      itemCount: _generatedImages.length,
      itemBuilder: (context, index) {
        final image = _generatedImages[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  image['url'],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              
              // Информация
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      image['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Chip(
                          label: Text(image['category']),
                          backgroundColor: Colors.blue[100],
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(image['style']),
                          backgroundColor: Colors.green[100],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () => _likeImage(image['id']),
                            ),
                            Text('${image['likes']}'),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _downloadImage(image['id']),
                            ),
                            Text('${image['downloads']}'),
                          ],
                        ),
                        Text(
                          '${image['createdAt'].hour}:${image['createdAt'].minute.toString().padLeft(2, '0')}',
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

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _generationHistory.length,
      itemBuilder: (context, index) {
        final history = _generationHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
            title: Text(history['description']),
            subtitle: Text(
              'Создано: ${history['createdAt'].day}.${history['createdAt'].month}.${history['createdAt'].year}',
            ),
            trailing: Text(
              '${history['resultCount']} изображений',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            onTap: () {
              // Показать детали генерации
            },
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
            'Настройки генератора',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSettingItem(
            icon: Icons.image,
            title: 'Размер изображения',
            subtitle: '1024x1024 пикселей',
            onTap: () {
              // Настройка размера
            },
          ),
          
          _buildSettingItem(
            icon: Icons.style,
            title: 'Стиль генерации',
            subtitle: 'Фотореалистичный',
            onTap: () {
              // Настройка стиля
            },
          ),
          
          _buildSettingItem(
            icon: Icons.tune,
            title: 'Параметры качества',
            subtitle: 'Высокое качество',
            onTap: () {
              // Настройка качества
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
                // Сброс настроек
              },
              icon: const Icon(Icons.restore),
              label: const Text('Сбросить настройки'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[700],
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
