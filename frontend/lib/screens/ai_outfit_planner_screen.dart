import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AIOutfitPlannerScreen extends StatefulWidget {
  const AIOutfitPlannerScreen({super.key});

  @override
  State<AIOutfitPlannerScreen> createState() => _AIOutfitPlannerScreenState();
}

class _AIOutfitPlannerScreenState extends State<AIOutfitPlannerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _occasionController = TextEditingController();
  
  String _selectedSeason = 'summer';
  String _selectedStyle = 'casual';
  String _selectedWeather = 'sunny';
  Color _selectedColorScheme = Colors.blue;
  bool _isGenerating = false;
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _generatedOutfits = [
    {
      'id': '1',
      'name': 'Summer Casual Day',
      'occasion': 'casual',
      'season': 'summer',
      'weather': 'sunny',
      'items': [
        {'type': 'top', 'name': 'White T-Shirt', 'color': 'White'},
        {'type': 'bottom', 'name': 'High-Waisted Shorts', 'color': 'Denim'},
        {'type': 'shoes', 'name': 'White Sneakers', 'color': 'White'},
        {'type': 'accessory', 'name': 'Straw Hat', 'color': 'Natural'},
      ],
      'rating': 4.8,
      'likes': 45,
      'image': 'assets/images/outfit1.jpg',
    },
    {
      'id': '2',
      'name': 'Business Casual Office',
      'occasion': 'work',
      'season': 'all',
      'weather': 'indoor',
      'items': [
        {'type': 'top', 'name': 'Silk Blouse', 'color': 'Light Blue'},
        {'type': 'bottom', 'name': 'Tailored Pants', 'color': 'Navy'},
        {'type': 'shoes', 'name': 'Loafers', 'color': 'Brown'},
        {'type': 'accessory', 'name': 'Minimalist Watch', 'color': 'Silver'},
      ],
      'rating': 4.6,
      'likes': 32,
      'image': 'assets/images/outfit2.jpg',
    },
    {
      'id': '3',
      'name': 'Evening Date Night',
      'occasion': 'formal',
      'season': 'spring',
      'weather': 'mild',
      'items': [
        {'type': 'top', 'name': 'Elegant Blouse', 'color': 'Black'},
        {'type': 'bottom', 'name': 'Midi Skirt', 'color': 'Burgundy'},
        {'type': 'shoes', 'name': 'Heeled Sandals', 'color': 'Black'},
        {'type': 'accessory', 'name': 'Statement Necklace', 'color': 'Gold'},
      ],
      'rating': 4.9,
      'likes': 67,
      'image': 'assets/images/outfit3.jpg',
    },
  ];

  final List<Map<String, dynamic>> _wardrobeItems = [
    {
      'id': '1',
      'name': 'White T-Shirt',
      'type': 'top',
      'color': 'White',
      'season': 'all',
      'occasion': 'casual',
      'lastWorn': '2 days ago',
      'wearCount': 15,
    },
    {
      'id': '2',
      'name': 'Denim Jacket',
      'type': 'outerwear',
      'color': 'Blue',
      'season': 'spring',
      'occasion': 'casual',
      'lastWorn': '1 week ago',
      'wearCount': 8,
    },
    {
      'id': '3',
      'name': 'Black Blazer',
      'type': 'outerwear',
      'color': 'Black',
      'season': 'all',
      'occasion': 'work',
      'lastWorn': '3 days ago',
      'wearCount': 12,
    },
    {
      'id': '4',
      'name': 'High-Waisted Jeans',
      'type': 'bottom',
      'color': 'Blue',
      'season': 'all',
      'occasion': 'casual',
      'lastWorn': 'Yesterday',
      'wearCount': 20,
    },
  ];

  final List<Map<String, dynamic>> _styleInspirations = [
    {
      'name': 'Parisian Chic',
      'description': 'Effortless elegance with neutral tones',
      'colors': ['Beige', 'White', 'Black', 'Navy'],
      'icon': Icons.style,
      'color': Colors.brown,
    },
    {
      'name': 'Scandinavian Minimalism',
      'description': 'Clean lines and functional beauty',
      'colors': ['White', 'Gray', 'Black', 'Beige'],
      'icon': Icons.design_services,
      'color': Colors.grey,
    },
    {
      'name': 'California Casual',
      'description': 'Relaxed and comfortable style',
      'colors': ['Denim', 'White', 'Beige', 'Olive'],
      'icon': Icons.beach_access,
      'color': Colors.blue,
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
    _occasionController.dispose();
    super.dispose();
  }

  void _generateOutfit() {
    setState(() {
      _isGenerating = true;
    });

    // Simulate AI outfit generation
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isGenerating = false;
      });
      
      _showGeneratedOutfit();
    });
  }

  void _showGeneratedOutfit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Generated Outfit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: _selectedColorScheme.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedColorScheme),
              ),
              child: const Icon(
                Icons.checkroom,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_selectedStyle.toUpperCase()} ${_selectedSeason} Outfit',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Occasion: ${_occasionController.text}'),
            Text('Weather: ${_selectedWeather}'),
            Text('Style: ${_selectedStyle}'),
            const SizedBox(height: 16),
            const Text(
              'Outfit Components:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildOutfitComponent('Top', 'Light blouse or t-shirt'),
            _buildOutfitComponent('Bottom', 'Comfortable pants or skirt'),
            _buildOutfitComponent('Shoes', 'Appropriate footwear'),
            _buildOutfitComponent('Accessories', 'Complementary pieces'),
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
              _saveOutfit();
            },
            child: const Text('Save Outfit'),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitComponent(String type, String suggestion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text('$type: $suggestion', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _saveOutfit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outfit saved to your collection!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Outfit Planner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Generate', icon: Icon(Icons.auto_fix_high)),
            Tab(text: 'My Outfits', icon: Icon(Icons.checkroom)),
            Tab(text: 'Wardrobe', icon: Icon(Icons.inventory)),
            Tab(text: 'Inspiration', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOutfitGenerator(),
          _buildMyOutfits(),
          _buildWardrobe(),
          _buildInspiration(),
        ],
      ),
    );
  }

  Widget _buildOutfitGenerator() {
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
                    'Generate Perfect Outfit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _occasionController,
                    decoration: const InputDecoration(
                      labelText: 'Occasion',
                      hintText: 'e.g., work meeting, casual day, date night...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Season',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedSeason,
                          items: const [
                            DropdownMenuItem(value: 'spring', child: Text('Spring')),
                            DropdownMenuItem(value: 'summer', child: Text('Summer')),
                            DropdownMenuItem(value: 'autumn', child: Text('Autumn')),
                            DropdownMenuItem(value: 'winter', child: Text('Winter')),
                            DropdownMenuItem(value: 'all', child: Text('All Year')),
                          ],
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
                          decoration: const InputDecoration(
                            labelText: 'Style',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedStyle,
                          items: const [
                            DropdownMenuItem(value: 'casual', child: Text('Casual')),
                            DropdownMenuItem(value: 'business', child: Text('Business')),
                            DropdownMenuItem(value: 'elegant', child: Text('Elegant')),
                            DropdownMenuItem(value: 'sporty', child: Text('Sporty')),
                            DropdownMenuItem(value: 'vintage', child: Text('Vintage')),
                          ],
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
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Weather',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedWeather,
                          items: const [
                            DropdownMenuItem(value: 'sunny', child: Text('Sunny')),
                            DropdownMenuItem(value: 'rainy', child: Text('Rainy')),
                            DropdownMenuItem(value: 'cold', child: Text('Cold')),
                            DropdownMenuItem(value: 'mild', child: Text('Mild')),
                            DropdownMenuItem(value: 'indoor', child: Text('Indoor')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedWeather = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Color Scheme'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showColorPicker(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _selectedColorScheme,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _occasionController.text.isNotEmpty ? _generateOutfit : null,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_fix_high),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Outfit'),
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
                    'Quick Outfit Ideas',
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
                      _buildQuickOutfitChip('Work outfit'),
                      _buildQuickOutfitChip('Weekend casual'),
                      _buildQuickOutfitChip('Date night'),
                      _buildQuickOutfitChip('Gym session'),
                      _buildQuickOutfitChip('Travel comfort'),
                      _buildQuickOutfitChip('Party look'),
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

  Widget _buildQuickOutfitChip(String outfit) {
    return ActionChip(
      label: Text(outfit),
      onPressed: () {
        _occasionController.text = outfit;
      },
      backgroundColor: Colors.purple.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.purple),
    );
  }

  Widget _buildMyOutfits() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _generatedOutfits.length,
      itemBuilder: (context, index) {
        final outfit = _generatedOutfits[index];
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.checkroom,
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
                            outfit['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  outfit['occasion'],
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  outfit['season'],
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
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
                              Text(' ${outfit['rating']} • ${outfit['likes']} likes'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Outfit Items:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: outfit['items'].map<Widget>((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item['type']}: ${item['name']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite),
                        label: const Text('Wear'),
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

  Widget _buildWardrobe() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _wardrobeItems.length,
      itemBuilder: (context, index) {
        final item = _wardrobeItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getItemTypeColor(item['type']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getItemTypeIcon(item['type']),
                color: _getItemTypeColor(item['type']),
                size: 30,
              ),
            ),
            title: Text(item['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getItemTypeColor(item['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['type'],
                        style: TextStyle(
                          color: _getItemTypeColor(item['type']),
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
                        item['color'],
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
                  'Worn ${item['wearCount']} times • Last: ${item['lastWorn']}',
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildInspiration() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Style Inspirations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._styleInspirations.map((inspiration) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: inspiration['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          inspiration['icon'],
                          color: inspiration['color'],
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inspiration['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              inspiration['description'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              children: inspiration['colors'].map<Widget>((color) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: inspiration['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  color,
                                  style: TextStyle(
                                    color: inspiration['color'],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _occasionController.text = '${inspiration['name']} style';
                          _tabController.animateTo(0);
                        },
                        child: const Text('Try'),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color Scheme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                  Colors.blueGrey,
                  Colors.black,
                ].map((color) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorScheme = color;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColorScheme == color ? Colors.white : Colors.grey,
                        width: _selectedColorScheme == color ? 3 : 1,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  IconData _getItemTypeIcon(String type) {
    switch (type) {
      case 'top':
        return Icons.checkroom;
      case 'bottom':
        return Icons.accessibility;
      case 'outerwear':
        return Icons.ac_unit;
      case 'shoes':
        return Icons.sports_soccer;
      case 'accessory':
        return Icons.watch;
      default:
        return Icons.checkroom;
    }
  }

  Color _getItemTypeColor(String type) {
    switch (type) {
      case 'top':
        return Colors.blue;
      case 'bottom':
        return Colors.green;
      case 'outerwear':
        return Colors.orange;
      case 'shoes':
        return Colors.purple;
      case 'accessory':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
