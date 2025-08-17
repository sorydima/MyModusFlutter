import 'package:flutter/material.dart';
import 'dart:math';

class AIColorMatcherScreen extends StatefulWidget {
  const AIColorMatcherScreen({super.key});

  @override
  State<AIColorMatcherScreen> createState() => _AIColorMatcherScreenState();
}

class _AIColorMatcherScreenState extends State<AIColorMatcherScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _baseColorController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  
  String _selectedColorScheme = 'Аналоговый';
  String _selectedSeason = 'Лето';
  String _selectedMood = 'Энергичный';
  bool _isAnalyzing = false;
  
  List<Map<String, dynamic>> _colorPalettes = [];
  List<Map<String, dynamic>> _favoriteCombinations = [];
  List<Map<String, dynamic>> _colorHistory = [];
  List<Map<String, dynamic>> _trendingColors = [];

  final List<String> _colorSchemes = [
    'Аналоговый', 'Монохромный', 'Триадный', 'Дополнительный', 'Раздельно-дополнительный'
  ];

  final List<String> _seasons = [
    'Весна', 'Лето', 'Осень', 'Зима'
  ];

  final List<String> _moods = [
    'Энергичный', 'Спокойный', 'Романтичный', 'Деловой', 'Креативный', 'Элегантный'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMockData();
    _initializeControllers();
  }

  void _initializeControllers() {
    _baseColorController.text = '#FF6B6B';
    _styleController.text = 'Современный минимализм';
  }

  void _loadMockData() {
    _colorPalettes = [
      {
        'id': '1',
        'name': 'Летний закат',
        'baseColor': '#FF6B6B',
        'colors': ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7'],
        'scheme': 'Аналоговый',
        'season': 'Лето',
        'mood': 'Энергичный',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'likes': 45,
        'downloads': 23,
      },
      {
        'id': '2',
        'name': 'Осенняя листва',
        'baseColor': '#8B4513',
        'colors': ['#8B4513', '#D2691E', '#CD853F', '#F4A460', '#DEB887'],
        'scheme': 'Монохромный',
        'season': 'Осень',
        'mood': 'Спокойный',
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
        'likes': 32,
        'downloads': 18,
      },
    ];

    _favoriteCombinations = [
      {
        'id': '1',
        'name': 'Неоновые ночи',
        'colors': ['#FF1493', '#00CED1', '#FFD700', '#FF4500', '#8A2BE2'],
        'usage': 'Клубная одежда, аксессуары',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '2',
        'name': 'Пастельные мечты',
        'colors': ['#FFB6C1', '#87CEEB', '#98FB98', '#F0E68C', '#DDA0DD'],
        'usage': 'Повседневная одежда, детская мода',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];

    _colorHistory = [
      {
        'id': '1',
        'baseColor': '#FF6B6B',
        'scheme': 'Аналоговый',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'resultCount': 5,
      },
      {
        'id': '2',
        'baseColor': '#4ECDC4',
        'scheme': 'Триадный',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        'resultCount': 4,
      },
    ];

    _trendingColors = [
      {
        'color': '#FF6B6B',
        'name': 'Коралловый',
        'trend': 'Восходящий',
        'usage': 'Летняя одежда, аксессуары',
        'percentage': 85,
      },
      {
        'color': '#4ECDC4',
        'name': 'Мятный',
        'trend': 'Стабильный',
        'usage': 'Повседневная одежда, интерьер',
        'percentage': 72,
      },
      {
        'color': '#45B7D1',
        'name': 'Голубой',
        'trend': 'Нисходящий',
        'usage': 'Деловая одежда, классика',
        'percentage': 58,
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _baseColorController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  Future<void> _generateColorPalette() async {
    if (_baseColorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите базовый цвет')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // Имитация генерации
    await Future.delayed(const Duration(seconds: 2));

    final newPalette = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': 'Новая палитра',
      'baseColor': _baseColorController.text.trim(),
      'colors': _generateRandomColors(_baseColorController.text.trim()),
      'scheme': _selectedColorScheme,
      'season': _selectedSeason,
      'mood': _selectedMood,
      'createdAt': DateTime.now(),
      'likes': 0,
      'downloads': 0,
    };

    setState(() {
      _colorPalettes.insert(0, newPalette);
      _isAnalyzing = false;
    });

    // Добавляем в историю
    _colorHistory.insert(0, {
      'id': newPalette['id'],
      'baseColor': newPalette['baseColor'],
      'scheme': newPalette['scheme'],
      'createdAt': newPalette['createdAt'],
      'resultCount': newPalette['colors'].length,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Цветовая палитра создана!')),
    );
  }

  List<String> _generateRandomColors(String baseColor) {
    final colors = [
      baseColor,
      '#${_getRandomHex()}',
      '#${_getRandomHex()}',
      '#${_getRandomHex()}',
      '#${_getRandomHex()}',
    ];
    return colors;
  }

  String _getRandomHex() {
    final random = Random();
    final r = random.nextInt(256);
    final g = random.nextInt(256);
    final b = random.nextInt(256);
    return '${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  void _likePalette(String paletteId) {
    setState(() {
      final palette = _colorPalettes.firstWhere((p) => p['id'] == paletteId);
      palette['likes'] = (palette['likes'] ?? 0) + 1;
    });
  }

  void _downloadPalette(String paletteId) {
    setState(() {
      final palette = _colorPalettes.firstWhere((p) => p['id'] == paletteId);
      palette['downloads'] = (palette['downloads'] ?? 0) + 1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Палитра скачана!')),
    );
  }

  void _addToFavorites(String paletteId) {
    final palette = _colorPalettes.firstWhere((p) => p['id'] == paletteId);
    final newFavorite = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': palette['name'],
      'colors': palette['colors'],
      'usage': 'Автоматически определено',
      'createdAt': DateTime.now(),
    };

    setState(() {
      _favoriteCombinations.insert(0, newFavorite);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Добавлено в избранное!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Подбор Цветов'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Показать избранное
            },
          ),
          IconButton(
            icon: const Icon(Icons.trending_up),
            onPressed: () {
              // Показать тренды
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
                  'Создайте цветовую палитру',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Базовый цвет и схема
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _baseColorController,
                        decoration: const InputDecoration(
                          labelText: 'Базовый цвет',
                          hintText: '#FF6B6B',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedColorScheme,
                        decoration: const InputDecoration(
                          labelText: 'Цветовая схема',
                          border: OutlineInputBorder(),
                        ),
                        items: _colorSchemes.map((scheme) {
                          return DropdownMenuItem(
                            value: scheme,
                            child: Text(scheme),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedColorScheme = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Сезон и настроение
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
                        value: _selectedMood,
                        decoration: const InputDecoration(
                          labelText: 'Настроение',
                          border: OutlineInputBorder(),
                        ),
                        items: _moods.map((mood) {
                          return DropdownMenuItem(
                            value: mood,
                            child: Text(mood),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMood = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Стиль и кнопка генерации
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _styleController,
                        decoration: const InputDecoration(
                          labelText: 'Стиль',
                          hintText: 'Опишите желаемый стиль',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _generateColorPalette,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.palette),
                        label: Text(_isAnalyzing ? 'Создаем...' : 'Создать палитру'),
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
              Tab(text: 'Палитры'),
              Tab(text: 'Избранное'),
              Tab(text: 'История'),
              Tab(text: 'Тренды'),
            ],
          ),
          
          // Содержимое табов
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPalettesTab(),
                _buildFavoritesTab(),
                _buildHistoryTab(),
                _buildTrendsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalettesTab() {
    if (_colorPalettes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Создайте первую цветовую палитру!',
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
      itemCount: _colorPalettes.length,
      itemBuilder: (context, index) {
        final palette = _colorPalettes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Цветовая палитра
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          palette['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () => _addToFavorites(palette['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _downloadPalette(palette['id']),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Цвета
                    Row(
                      children: (palette['colors'] as List<String>).map((color) {
                        return Expanded(
                          child: Container(
                            height: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _parseColor(color),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Text(
                                color,
                                style: TextStyle(
                                  color: _isLightColor(_parseColor(color)) ? Colors.black : Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Информация
                    Row(
                      children: [
                        Chip(
                          label: Text(palette['scheme']),
                          backgroundColor: Colors.blue[100],
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(palette['season']),
                          backgroundColor: Colors.green[100],
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(palette['mood']),
                          backgroundColor: Colors.purple[100],
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
                              onPressed: () => _likePalette(palette['id']),
                            ),
                            Text('${palette['likes']}'),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _downloadPalette(palette['id']),
                            ),
                            Text('${palette['downloads']}'),
                          ],
                        ),
                        Text(
                          '${palette['createdAt'].hour}:${palette['createdAt'].minute.toString().padLeft(2, '0')}',
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

  Widget _buildFavoritesTab() {
    if (_favoriteCombinations.isEmpty) {
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
              'Добавьте палитры в избранное!',
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
        childAspectRatio: 0.8,
      ),
      itemCount: _favoriteCombinations.length,
      itemBuilder: (context, index) {
        final favorite = _favoriteCombinations[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Цвета
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: (favorite['colors'] as List<String>).map((color) {
                      return Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: _parseColor(color),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // Информация
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      favorite['usage'],
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

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _colorHistory.length,
      itemBuilder: (context, index) {
        final history = _colorHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _parseColor(history['baseColor']),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Text(
                  history['baseColor'],
                  style: TextStyle(
                    color: _isLightColor(_parseColor(history['baseColor'])) ? Colors.black : Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text('Базовый цвет: ${history['baseColor']}'),
            subtitle: Text(
              'Схема: ${history['scheme']} • ${history['resultCount']} цветов',
            ),
            trailing: Text(
              '${history['createdAt'].day}.${history['createdAt'].month}.${history['createdAt'].year}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            onTap: () {
              // Показать детали палитры
            },
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Трендовые цвета',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          ..._trendingColors.map((trend) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  // Цвет
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _parseColor(trend['color']),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        trend['color'],
                        style: TextStyle(
                          color: _isLightColor(_parseColor(trend['color'])) ? Colors.black : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Информация
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trend['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trend['usage'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTrendColor(trend['trend']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                trend['trend'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${trend['percentage']}%',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
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
          }).toList(),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  bool _isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'Восходящий':
        return Colors.green;
      case 'Стабильный':
        return Colors.blue;
      case 'Нисходящий':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
