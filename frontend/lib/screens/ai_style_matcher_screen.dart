import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AIStyleMatcherScreen extends StatefulWidget {
  const AIStyleMatcherScreen({super.key});

  @override
  State<AIStyleMatcherScreen> createState() => _AIStyleMatcherScreenState();
}

class _AIStyleMatcherScreenState extends State<AIStyleMatcherScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _styleDescriptionController = TextEditingController();
  
  String _selectedStyleCategory = 'casual';
  String _selectedMood = 'confident';
  String _selectedBodyType = 'hourglass';
  bool _isMatching = false;
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _styleMatches = [
    {
      'id': '1',
      'name': 'Boho Chic',
      'matchScore': 95,
      'description': 'Free-spirited style with flowing fabrics and ethnic details',
      'inspiration': 'Instagram @bohostyle',
      'items': [
        {'name': 'Flowy Maxi Dress', 'brand': 'Free People', 'price': 89.99},
        {'name': 'Fringed Bag', 'brand': 'Anthropologie', 'price': 45.00},
        {'name': 'Leather Sandals', 'brand': 'Birkenstock', 'price': 120.00},
      ],
      'colors': ['Earth Tones', 'Jewel Tones', 'Neutrals'],
      'image': 'assets/images/boho.jpg',
    },
    {
      'id': '2',
      'name': 'Minimalist Elegance',
      'matchScore': 88,
      'description': 'Clean lines and sophisticated simplicity',
      'inspiration': 'Pinterest Minimalist Fashion',
      'items': [
        {'name': 'Tailored Blazer', 'brand': 'Theory', 'price': 299.99},
        {'name': 'Silk Blouse', 'brand': 'COS', 'price': 89.99},
        {'name': 'Straight Leg Pants', 'brand': 'Everlane', 'price': 78.00},
      ],
      'colors': ['White', 'Black', 'Gray', 'Beige'],
      'image': 'assets/images/minimalist.jpg',
    },
    {
      'id': '3',
      'name': 'Street Style Edge',
      'matchScore': 82,
      'description': 'Urban cool with trendy pieces and attitude',
      'inspiration': 'Fashion Week Street Style',
      'items': [
        {'name': 'Oversized Hoodie', 'brand': 'Supreme', 'price': 168.00},
        {'name': 'Distressed Jeans', 'brand': 'Levi\'s', 'price': 89.99},
        {'name': 'Chunky Sneakers', 'brand': 'Nike', 'price': 120.00},
      ],
      'colors': ['Black', 'White', 'Neon', 'Denim'],
      'image': 'assets/images/street.jpg',
    },
  ];

  final List<Map<String, dynamic>> _styleEvolution = [
    {
      'period': '2020',
      'style': 'Comfort First',
      'description': 'Loungewear and athleisure dominated',
      'trends': ['Oversized fits', 'Comfortable fabrics', 'Athletic wear'],
      'color': Colors.blue,
    },
    {
      'period': '2021',
      'style': 'Y2K Revival',
      'description': 'Early 2000s fashion made a comeback',
      'trends': ['Low-rise jeans', 'Crop tops', 'Platform shoes'],
      'color': Colors.pink,
    },
    {
      'period': '2022',
      'style': 'Quiet Luxury',
      'description': 'Understated elegance and quality',
      'trends': ['Neutral colors', 'Quality materials', 'Timeless pieces'],
      'color': Colors.brown,
    },
    {
      'period': '2023',
      'style': 'Maximalist Expression',
      'description': 'Bold colors and statement pieces',
      'trends': ['Bright colors', 'Pattern mixing', 'Layered looks'],
      'color': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _compatibilityMatrix = [
    {
      'style1': 'Boho',
      'style2': 'Minimalist',
      'compatibility': 65,
      'reason': 'Different approaches to fashion',
      'color': Colors.orange,
    },
    {
      'style1': 'Boho',
      'style2': 'Street',
      'compatibility': 80,
      'reason': 'Both embrace individuality',
      'color': Colors.green,
    },
    {
      'style1': 'Minimalist',
      'style2': 'Street',
      'compatibility': 70,
      'reason': 'Can blend with careful styling',
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
    _styleDescriptionController.dispose();
    super.dispose();
  }

  void _findStyleMatches() {
    setState(() {
      _isMatching = true;
    });

    // Simulate AI style matching
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isMatching = false;
      });
      
      _showStyleMatches();
    });
  }

  void _showStyleMatches() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Style Matches Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Based on your preferences, here are your perfect style matches:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Style Analysis:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your style preferences align with modern, versatile fashion that emphasizes comfort and self-expression. You tend to gravitate towards pieces that can be mixed and matched.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Found ${_styleMatches.length} style matches with 80%+ compatibility',
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
              _tabController.animateTo(0);
            },
            child: const Text('View Matches'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Style Matcher'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Match', icon: Icon(Icons.psychology)),
            Tab(text: 'Evolution', icon: Icon(Icons.timeline)),
            Tab(text: 'Compatibility', icon: Icon(Icons.compare)),
            Tab(text: 'Inspiration', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStyleMatcher(),
          _buildStyleEvolution(),
          _buildCompatibilityMatrix(),
          _buildInspirationGallery(),
        ],
      ),
    );
  }

  Widget _buildStyleMatcher() {
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
                    'Find Your Perfect Style Match',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _styleDescriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Describe Your Style',
                      hintText: 'Tell us about your fashion preferences, favorite looks, or style goals...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.style),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Style Category',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedStyleCategory,
                          items: const [
                            DropdownMenuItem(value: 'casual', child: Text('Casual')),
                            DropdownMenuItem(value: 'business', child: Text('Business')),
                            DropdownMenuItem(value: 'elegant', child: Text('Elegant')),
                            DropdownMenuItem(value: 'creative', child: Text('Creative')),
                            DropdownMenuItem(value: 'sporty', child: Text('Sporty')),
                            DropdownMenuItem(value: 'vintage', child: Text('Vintage')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStyleCategory = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Style Mood',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedMood,
                          items: const [
                            DropdownMenuItem(value: 'confident', child: Text('Confident')),
                            DropdownMenuItem(value: 'comfortable', child: Text('Comfortable')),
                            DropdownMenuItem(value: 'adventurous', child: Text('Adventurous')),
                            DropdownMenuItem(value: 'sophisticated', child: Text('Sophisticated')),
                            DropdownMenuItem(value: 'playful', child: Text('Playful')),
                          ],
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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Body Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedBodyType,
                    items: const [
                      DropdownMenuItem(value: 'hourglass', child: Text('Hourglass')),
                      DropdownMenuItem(value: 'rectangle', child: Text('Rectangle')),
                      DropdownMenuItem(value: 'triangle', child: Text('Triangle')),
                      DropdownMenuItem(value: 'inverted-triangle', child: Text('Inverted Triangle')),
                      DropdownMenuItem(value: 'oval', child: Text('Oval')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBodyType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _styleDescriptionController.text.isNotEmpty ? _findStyleMatches : null,
                      icon: _isMatching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.psychology),
                      label: Text(_isMatching ? 'Matching...' : 'Find Style Matches'),
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
                    'Quick Style Descriptions',
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
                      _buildQuickStyleChip('I love comfortable, casual looks'),
                      _buildQuickStyleChip('I prefer elegant, sophisticated styles'),
                      _buildQuickStyleChip('I like bold, statement pieces'),
                      _buildQuickStyleChip('I want to try new trends'),
                      _buildQuickStyleChip('I need work-appropriate outfits'),
                      _buildQuickStyleChip('I love vintage and retro styles'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_styleMatches.isNotEmpty) ...[
            const Text(
              'Your Style Matches',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._styleMatches.map((match) => _buildStyleMatchCard(match)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStyleChip(String description) {
    return ActionChip(
      label: Text(description),
      onPressed: () {
        _styleDescriptionController.text = description;
      },
      backgroundColor: Colors.purple.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.purple),
    );
  }

  Widget _buildStyleMatchCard(Map<String, dynamic> match) {
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
                    Icons.style,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            match['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getMatchScoreColor(match['matchScore']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${match['matchScore']}%',
                              style: TextStyle(
                                color: _getMatchScoreColor(match['matchScore']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inspired by: ${match['inspiration']}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Key Items:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...match['items'].map<Widget>((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${item['name']} - ${item['brand']}'),
                  ),
                  Text('\$${item['price']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Colors: '),
                ...match['colors'].map((color) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    color,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 10,
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
                    onPressed: () {},
                    icon: const Icon(Icons.favorite),
                    label: const Text('Save Style'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Shop Items'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleEvolution() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _styleEvolution.length,
      itemBuilder: (context, index) {
        final evolution = _styleEvolution[index];
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: evolution['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        evolution['period'],
                        style: TextStyle(
                          color: evolution['color'],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evolution['style'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            evolution['description'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Key Trends:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: evolution['trends'].map<Widget>((trend) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: evolution['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        color: evolution['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompatibilityMatrix() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _compatibilityMatrix.length,
      itemBuilder: (context, index) {
        final compatibility = _compatibilityMatrix[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        compatibility['style1'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: compatibility['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${compatibility['compatibility']}%',
                        style: TextStyle(
                          color: compatibility['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        compatibility['style2'],
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  compatibility['reason'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInspirationGallery() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'Style Inspiration ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to explore',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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

  Color _getMatchScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
