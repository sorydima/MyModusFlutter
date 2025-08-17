import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AIContentModeratorScreen extends StatefulWidget {
  const AIContentModeratorScreen({super.key});

  @override
  State<AIContentModeratorScreen> createState() => _AIContentModeratorScreenState();
}

class _AIContentModeratorScreenState extends State<AIContentModeratorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  
  String _selectedContentType = 'post';
  String _selectedAction = 'review';
  bool _isAnalyzing = false;
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _moderationQueue = [
    {
      'id': '1',
      'type': 'post',
      'content': 'Check out this amazing fashion trend! #fashion #style',
      'user': 'fashion_lover',
      'timestamp': '2 hours ago',
      'status': 'pending',
      'risk_score': 0.15,
      'flags': ['spam', 'inappropriate'],
    },
    {
      'id': '2',
      'type': 'comment',
      'content': 'This product is terrible, don\'t buy it!',
      'user': 'user123',
      'timestamp': '1 hour ago',
      'status': 'flagged',
      'risk_score': 0.85,
      'flags': ['hate_speech', 'spam'],
    },
    {
      'id': '3',
      'type': 'product',
      'content': 'Beautiful summer dress with floral pattern',
      'user': 'boutique_style',
      'timestamp': '30 min ago',
      'status': 'approved',
      'risk_score': 0.05,
      'flags': [],
    },
  ];

  final List<Map<String, dynamic>> _moderationRules = [
    {
      'rule': 'No hate speech or discrimination',
      'category': 'safety',
      'enabled': true,
      'action': 'auto_reject',
    },
    {
      'rule': 'No spam or excessive promotion',
      'category': 'quality',
      'enabled': true,
      'action': 'flag_for_review',
    },
    {
      'rule': 'No inappropriate content',
      'category': 'safety',
      'enabled': true,
      'action': 'auto_reject',
    },
    {
      'rule': 'No fake reviews or ratings',
      'category': 'quality',
      'enabled': true,
      'action': 'flag_for_review',
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
    _contentController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _analyzeContent() {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isAnalyzing = false;
      });
      
      _showAnalysisResult();
    });
  }

  void _showAnalysisResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Content Analysis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalysisRow('Risk Score', '0.25', Colors.orange),
            _buildAnalysisRow('Content Type', 'Fashion Post', Colors.blue),
            _buildAnalysisRow('Language', 'English', Colors.green),
            _buildAnalysisRow('Sentiment', 'Positive', Colors.green),
            _buildAnalysisRow('Spam Probability', '0.05', Colors.green),
            _buildAnalysisRow('Recommendation', 'Approve', Colors.green),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _takeAction(String itemId, String action) {
    setState(() {
      final item = _moderationQueue.firstWhere((item) => item['id'] == itemId);
      item['status'] = action;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action taken: $action')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Content Moderator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Queue', icon: Icon(Icons.queue)),
            Tab(text: 'Analyze', icon: Icon(Icons.analytics)),
            Tab(text: 'Rules', icon: Icon(Icons.rule)),
            Tab(text: 'Reports', icon: Icon(Icons.report)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildModerationQueue(),
          _buildContentAnalyzer(),
          _buildModerationRules(),
          _buildReports(),
        ],
      ),
    );
  }

  Widget _buildModerationQueue() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _moderationQueue.length,
      itemBuilder: (context, index) {
        final item = _moderationQueue[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getContentTypeIcon(item['type']),
                          color: _getStatusColor(item['status']),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['type'].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['status'].toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(item['status']),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item['content'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'by ${item['user']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item['timestamp'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRiskColor(item['risk_score']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Risk: ${(item['risk_score'] * 100).toInt()}%',
                        style: TextStyle(
                          color: _getRiskColor(item['risk_score']),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item['flags'].isNotEmpty)
                      ...item['flags'].map((flag) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          flag,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                          ),
                        ),
                      )),
                  ],
                ),
                const SizedBox(height: 12),
                if (item['status'] == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _takeAction(item['id'], 'approved'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _takeAction(item['id'], 'rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _takeAction(item['id'], 'flagged'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                          child: const Text('Flag'),
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

  Widget _buildContentAnalyzer() {
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
                    'Content Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Content Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedContentType,
                    items: const [
                      DropdownMenuItem(value: 'post', child: Text('Social Post')),
                      DropdownMenuItem(value: 'comment', child: Text('Comment')),
                      DropdownMenuItem(value: 'product', child: Text('Product Description')),
                      DropdownMenuItem(value: 'review', child: Text('Review')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedContentType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Content to Analyze',
                      hintText: 'Enter the content you want to analyze...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL (Optional)',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _contentController.text.isNotEmpty ? _analyzeContent : null,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.analytics),
                      label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Content'),
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
                    'Quick Actions',
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
                            _contentController.text = 'Check out this amazing fashion trend! #fashion #style';
                            _selectedContentType = 'post';
                          },
                          icon: const Icon(Icons.content_paste),
                          label: const Text('Sample Post'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _contentController.text = 'This product is terrible, don\'t buy it!';
                            _selectedContentType = 'comment';
                          },
                          icon: const Icon(Icons.content_paste),
                          label: const Text('Sample Comment'),
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

  Widget _buildModerationRules() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _moderationRules.length,
      itemBuilder: (context, index) {
        final rule = _moderationRules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              _getRuleCategoryIcon(rule['category']),
              color: _getRuleCategoryColor(rule['category']),
            ),
            title: Text(rule['rule']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRuleCategoryColor(rule['category']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rule['category'],
                        style: TextStyle(
                          color: _getRuleCategoryColor(rule['category']),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getActionColor(rule['action']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rule['action'].replaceAll('_', ' '),
                        style: TextStyle(
                          color: _getActionColor(rule['action']),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Switch(
              value: rule['enabled'],
              onChanged: (value) {
                setState(() {
                  rule['enabled'] = value;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildReports() {
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
                  'Moderation Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Pending', '12', Colors.orange),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard('Flagged', '8', Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Approved', '156', Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard('Rejected', '23', Colors.red),
                    ),
                  ],
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
                  'Recent Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionItem('Post approved', 'fashion_lover', '2 min ago', Colors.green),
                _buildActionItem('Comment rejected', 'user123', '5 min ago', Colors.red),
                _buildActionItem('Product flagged', 'boutique_style', '10 min ago', Colors.orange),
                _buildActionItem('Review approved', 'style_expert', '15 min ago', Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String action, String user, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'by $user • $time',
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

  IconData _getContentTypeIcon(String type) {
    switch (type) {
      case 'post':
        return Icons.post_add;
      case 'comment':
        return Icons.comment;
      case 'product':
        return Icons.shopping_bag;
      case 'review':
        return Icons.star;
      default:
        return Icons.text_fields;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'flagged':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getRiskColor(double riskScore) {
    if (riskScore < 0.3) return Colors.green;
    if (riskScore < 0.7) return Colors.orange;
    return Colors.red;
  }

  IconData _getRuleCategoryIcon(String category) {
    switch (category) {
      case 'safety':
        return Icons.security;
      case 'quality':
        return Icons.high_quality;
      case 'spam':
        return Icons.block;
      default:
        return Icons.rule;
    }
  }

  Color _getRuleCategoryColor(String category) {
    switch (category) {
      case 'safety':
        return Colors.red;
      case 'quality':
        return Colors.blue;
      case 'spam':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'auto_reject':
        return Colors.red;
      case 'flag_for_review':
        return Colors.orange;
      case 'auto_approve':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
