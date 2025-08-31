import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AIFashionDesignerScreen extends StatefulWidget {
  const AIFashionDesignerScreen({super.key});

  @override
  State<AIFashionDesignerScreen> createState() => _AIFashionDesignerScreenState();
}

class _AIFashionDesignerScreenState extends State<AIFashionDesignerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _descriptionController = TextEditingController();
  
  String _selectedStyle = 'casual';
  String _selectedSeason = 'summer';
  String _selectedOccasion = 'daily';
  String _selectedFabric = 'cotton';
  Color _selectedColor = Colors.blue;
  bool _isGenerating = false;
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _generatedDesigns = [
    {
      'id': '1',
      'name': 'Summer Floral Dress',
      'description': 'Light summer dress with floral pattern',
      'style': 'casual',
      'season': 'summer',
      'image': 'assets/images/design1.jpg',
      'timestamp': '2 hours ago',
      'likes': 24,
      'downloads': 12,
    },
    {
      'id': '2',
      'name': 'Business Casual Blazer',
      'description': 'Professional blazer for office wear',
      'style': 'business',
      'season': 'all',
      'image': 'assets/images/design2.jpg',
      'timestamp': '1 day ago',
      'likes': 18,
      'downloads': 8,
    },
    {
      'id': '3',
      'name': 'Winter Cozy Sweater',
      'description': 'Warm knitted sweater for cold weather',
      'style': 'casual',
      'season': 'winter',
      'image': 'assets/images/design3.jpg',
      'timestamp': '3 days ago',
      'likes': 31,
      'downloads': 15,
    },
  ];

  final List<Map<String, dynamic>> _designTemplates = [
    {
      'name': 'Classic T-Shirt',
      'category': 'tops',
      'difficulty': 'easy',
      'time': '30 min',
    },
    {
      'name': 'Summer Dress',
      'category': 'dresses',
      'difficulty': 'medium',
      'time': '1 hour',
    },
    {
      'name': 'Denim Jeans',
      'category': 'bottoms',
      'difficulty': 'hard',
      'time': '2 hours',
    },
    {
      'name': 'Winter Jacket',
      'category': 'outerwear',
      'difficulty': 'expert',
      'time': '3 hours',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _generateDesign() {
    setState(() {
      _isGenerating = true;
    });

    // Simulate AI design generation
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isGenerating = false;
      });
      
      _showGeneratedDesign();
    });
  }

  void _showGeneratedDesign() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Generated Design'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedColor),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_selectedStyle.toUpperCase()} ${_selectedSeason} Design',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Style: ${_selectedStyle}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Season: ${_selectedSeason}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Occasion: ${_selectedOccasion}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Fabric: ${_selectedFabric}',
              style: const TextStyle(fontSize: 14),
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
              _saveDesign();
            },
            child: const Text('Save Design'),
          ),
        ],
      ),
    );
  }

  void _saveDesign() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Design saved to your collection!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Fashion Designer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Create', icon: Icon(Icons.create)),
            Tab(text: 'Templates', icon: Icon(Icons.dashboard)),
            Tab(text: 'My Designs', icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDesignCreator(),
          _buildDesignTemplates(),
          _buildMyDesigns(),
        ],
      ),
    );
  }

  Widget _buildDesignCreator() {
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
                    'Create New Design',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Design Description',
                      hintText: 'Describe your ideal design...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
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
                      const SizedBox(width: 16),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
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
                            DropdownMenuItem(value: 'party', child: Text('Party')),
                            DropdownMenuItem(value: 'formal', child: Text('Formal')),
                            DropdownMenuItem(value: 'casual', child: Text('Casual')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedOccasion = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Fabric',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedFabric,
                          items: const [
                            DropdownMenuItem(value: 'cotton', child: Text('Cotton')),
                            DropdownMenuItem(value: 'silk', child: Text('Silk')),
                            DropdownMenuItem(value: 'wool', child: Text('Wool')),
                            DropdownMenuItem(value: 'denim', child: Text('Denim')),
                            DropdownMenuItem(value: 'linen', child: Text('Linen')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFabric = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Color: '),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showColorPicker(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _descriptionController.text.isNotEmpty ? _generateDesign : null,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_fix_high),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Design'),
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
                    'Quick Start',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _descriptionController.text = 'A comfortable summer dress with floral pattern';
                            _selectedStyle = 'casual';
                            _selectedSeason = 'summer';
                          },
                          icon: const Icon(Icons.content_paste),
                          label: const Text('Summer Dress'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _descriptionController.text = 'Professional business suit for office';
                            _selectedStyle = 'business';
                            _selectedSeason = 'all';
                          },
                          icon: const Icon(Icons.content_paste),
                          label: const Text('Business Suit'),
                        ),
                      ),
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

  Widget _buildDesignTemplates() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _designTemplates.length,
      itemBuilder: (context, index) {
        final template = _designTemplates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(template['category']),
                color: Colors.blue,
                size: 30,
              ),
            ),
            title: Text(template['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(template['difficulty']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        template['difficulty'],
                        style: TextStyle(
                          color: _getDifficultyColor(template['difficulty']),
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
                        template['time'],
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _useTemplate(template);
              },
              child: const Text('Use'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyDesigns() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _generatedDesigns.length,
      itemBuilder: (context, index) {
        final design = _generatedDesigns[index];
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
                            design['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            design['description'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
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
                                  design['style'],
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
                                  design['season'],
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
                    Text(
                      design['timestamp'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 16, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text('${design['likes']}'),
                        const SizedBox(width: 16),
                        Icon(Icons.download, size: 16, color: Colors.blue[400]),
                        const SizedBox(width: 4),
                        Text('${design['downloads']}'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
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

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
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
                      _selectedColor = color;
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
                        color: _selectedColor == color ? Colors.white : Colors.grey,
                        width: _selectedColor == color ? 3 : 1,
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

  void _useTemplate(Map<String, dynamic> template) {
    _descriptionController.text = 'Create a ${template['name']} design';
    _tabController.animateTo(0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Template "${template['name']}" loaded!')),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'tops':
        return Icons.checkroom;
      case 'dresses':
        return Icons.woman;
      case 'bottoms':
        return Icons.accessibility;
      case 'outerwear':
        return Icons.ac_unit;
      default:
        return Icons.checkroom;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
