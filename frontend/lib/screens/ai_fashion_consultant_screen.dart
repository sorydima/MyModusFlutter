import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AIFashionConsultantScreen extends StatefulWidget {
  const AIFashionConsultantScreen({super.key});

  @override
  State<AIFashionConsultantScreen> createState() => _AIFashionConsultantScreenState();
}

class _AIFashionConsultantScreenState extends State<AIFashionConsultantScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  
  String _selectedBodyType = 'hourglass';
  String _selectedSkinTone = 'warm';
  String _selectedHeight = 'average';
  String _selectedAge = '25-35';
  String _selectedLifestyle = 'casual';
  bool _isConsulting = false;
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _consultationHistory = [
    {
      'id': '1',
      'question': 'What should I wear for a job interview?',
      'answer': 'For a job interview, I recommend a well-fitted blazer with tailored pants or a knee-length skirt. Choose neutral colors like navy, black, or gray. Pair with a crisp white blouse and closed-toe shoes.',
      'timestamp': '2 hours ago',
      'category': 'work',
      'rating': 5,
    },
    {
      'id': '2',
      'question': 'How can I style a basic white t-shirt?',
      'answer': 'A white t-shirt is incredibly versatile! Try pairing it with high-waisted jeans and a blazer for a casual-chic look, or with a midi skirt and sneakers for a relaxed vibe.',
      'timestamp': '1 day ago',
      'category': 'casual',
      'rating': 4,
    },
    {
      'id': '3',
      'question': 'What colors work best for my skin tone?',
      'answer': 'Based on your warm skin tone, earth tones like olive green, terracotta, and warm browns will complement you beautifully. Avoid cool tones like icy blues and silvers.',
      'timestamp': '3 days ago',
      'category': 'color',
      'rating': 5,
    },
  ];

  final List<Map<String, dynamic>> _styleProfiles = [
    {
      'name': 'Classic Elegant',
      'description': 'Timeless pieces with sophisticated details',
      'colors': ['Navy', 'Beige', 'White', 'Black'],
      'brands': ['Ralph Lauren', 'Brooks Brothers', 'J.Crew'],
      'icon': Icons.style,
      'color': Colors.blue,
    },
    {
      'name': 'Bohemian Free Spirit',
      'description': 'Flowy fabrics, ethnic prints, and layered looks',
      'colors': ['Earth Tones', 'Jewel Tones', 'Neutrals'],
      'brands': ['Free People', 'Anthropologie', 'Urban Outfitters'],
      'icon': Icons.eco,
      'color': Colors.green,
    },
    {
      'name': 'Minimalist Modern',
      'description': 'Clean lines, neutral colors, and quality basics',
      'colors': ['White', 'Black', 'Gray', 'Beige'],
      'brands': ['COS', 'Everlane', 'Theory'],
      'icon': Icons.design_services,
      'color': Colors.grey,
    },
    {
      'name': 'Street Style',
      'description': 'Trendy pieces with urban edge',
      'colors': ['Black', 'White', 'Neon', 'Denim'],
      'brands': ['Nike', 'Adidas', 'Supreme', 'Off-White'],
      'icon': Icons.sports_soccer,
      'color': Colors.orange,
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
    _questionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _getConsultation() {
    setState(() {
      _isConsulting = true;
    });

    // Simulate AI consultation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isConsulting = false;
      });
      
      _showConsultationResult();
    });
  }

  void _showConsultationResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Fashion Consultation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Based on your profile and question, here\'s my recommendation:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personalized Style Advice:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'For your body type and skin tone, I recommend focusing on structured pieces that define your waist. Consider incorporating warm earth tones and classic silhouettes that will flatter your figure.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Key Recommendations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRecommendationItem('✓ High-waisted bottoms', Colors.green),
            _buildRecommendationItem('✓ Structured blazers', Colors.green),
            _buildRecommendationItem('✓ Warm color palette', Colors.green),
            _buildRecommendationItem('✓ Tailored fits', Colors.green),
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
              _saveConsultation();
            },
            child: const Text('Save Advice'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: color),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _saveConsultation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consultation saved to your history!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Fashion Consultant'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Consult', icon: Icon(Icons.psychology)),
            Tab(text: 'Style Profile', icon: Icon(Icons.person)),
            Tab(text: 'History', icon: Icon(Icons.history)),
            Tab(text: 'Tips', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsultationForm(),
          _buildStyleProfiles(),
          _buildConsultationHistory(),
          _buildFashionTips(),
        ],
      ),
    );
  }

  Widget _buildConsultationForm() {
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
                    'Get Personal Style Advice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Your Style Question',
                      hintText: 'Ask me anything about fashion and style...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Budget Range (Optional)',
                      hintText: 'e.g., $100-300',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Personal Style Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Skin Tone',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedSkinTone,
                          items: const [
                            DropdownMenuItem(value: 'warm', child: Text('Warm')),
                            DropdownMenuItem(value: 'cool', child: Text('Cool')),
                            DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
                            DropdownMenuItem(value: 'olive', child: Text('Olive')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSkinTone = value!;
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
                            labelText: 'Height',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedHeight,
                          items: const [
                            DropdownMenuItem(value: 'petite', child: Text('Petite')),
                            DropdownMenuItem(value: 'average', child: Text('Average')),
                            DropdownMenuItem(value: 'tall', child: Text('Tall')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedHeight = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Age Group',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedAge,
                          items: const [
                            DropdownMenuItem(value: '18-25', child: Text('18-25')),
                            DropdownMenuItem(value: '25-35', child: Text('25-35')),
                            DropdownMenuItem(value: '35-45', child: Text('35-45')),
                            DropdownMenuItem(value: '45+', child: Text('45+')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedAge = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Lifestyle',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedLifestyle,
                    items: const [
                      DropdownMenuItem(value: 'casual', child: Text('Casual')),
                      DropdownMenuItem(value: 'business', child: Text('Business')),
                      DropdownMenuItem(value: 'creative', child: Text('Creative')),
                      DropdownMenuItem(value: 'athletic', child: Text('Athletic')),
                      DropdownMenuItem(value: 'luxury', child: Text('Luxury')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLifestyle = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _questionController.text.isNotEmpty ? _getConsultation : null,
                      icon: _isConsulting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.psychology),
                      label: Text(_isConsulting ? 'Consulting...' : 'Get Style Advice'),
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
                    'Quick Questions',
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
                      _buildQuickQuestionChip('What should I wear for a date?'),
                      _buildQuickQuestionChip('How to style jeans?'),
                      _buildQuickQuestionChip('Best colors for my skin?'),
                      _buildQuickQuestionChip('Office outfit ideas'),
                      _buildQuickQuestionChip('Weekend casual looks'),
                      _buildQuickQuestionChip('Accessorizing tips'),
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

  Widget _buildQuickQuestionChip(String question) {
    return ActionChip(
      label: Text(question),
      onPressed: () {
        _questionController.text = question;
      },
      backgroundColor: Colors.blue.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.blue),
    );
  }

  Widget _buildStyleProfiles() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _styleProfiles.length,
      itemBuilder: (context, index) {
        final profile = _styleProfiles[index];
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
                        color: profile['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        profile['icon'],
                        color: profile['color'],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile['description'],
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
                  'Recommended Colors:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: profile['colors'].map<Widget>((color) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: profile['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      color,
                      style: TextStyle(
                        color: profile['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Brand Suggestions:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: profile['brands'].map<Widget>((brand) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      brand,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _questionController.text = 'Tell me more about ${profile['name'].toLowerCase()} style';
                      _tabController.animateTo(0);
                    },
                    child: const Text('Get Advice for This Style'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConsultationHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _consultationHistory.length,
      itemBuilder: (context, index) {
        final consultation = _consultationHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(consultation['category']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(consultation['category']),
                color: _getCategoryColor(consultation['category']),
              ),
            ),
            title: Text(
              consultation['question'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              consultation['timestamp'],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber[600]),
                Text('${consultation['rating']}'),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation['answer'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
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
                            icon: const Icon(Icons.favorite),
                            label: const Text('Save'),
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

  Widget _buildFashionTips() {
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
                  'Daily Style Tips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTipItem(
                  'Accessorize strategically - less is often more',
                  Icons.style,
                  Colors.blue,
                ),
                _buildTipItem(
                  'Invest in quality basics that mix and match',
                  Icons.checkroom,
                  Colors.green,
                ),
                _buildTipItem(
                  'Consider your body shape when choosing silhouettes',
                  Icons.person,
                  Colors.purple,
                ),
                _buildTipItem(
                  'Don\'t forget about proper fit - it makes all the difference',
                  Icons.fit_screen,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seasonal Advice',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSeasonalTip(
                  'Spring',
                  'Light layers and pastel colors',
                  Icons.local_florist,
                  Colors.pink,
                ),
                _buildSeasonalTip(
                  'Summer',
                  'Breathable fabrics and bright colors',
                  Icons.wb_sunny,
                  Colors.orange,
                ),
                _buildSeasonalTip(
                  'Autumn',
                  'Rich earth tones and cozy textures',
                  Icons.eco,
                  Colors.brown,
                ),
                _buildSeasonalTip(
                  'Winter',
                  'Warm layers and deep jewel tones',
                  Icons.ac_unit,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String tip, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalTip(String season, String advice, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  advice,
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
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'work':
        return Icons.work;
      case 'casual':
        return Icons.weekend;
      case 'color':
        return Icons.palette;
      default:
        return Icons.style;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'work':
        return Colors.blue;
      case 'casual':
        return Colors.green;
      case 'color':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
