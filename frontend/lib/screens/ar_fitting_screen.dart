import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ar_fitting_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class ARFittingScreen extends StatefulWidget {
  const ARFittingScreen({super.key});

  @override
  State<ARFittingScreen> createState() => _ARFittingScreenState();
}

class _ARFittingScreenState extends State<ARFittingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentUserId = 1; // Mock user ID for demo
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ARFittingProvider>();
      provider.getMeasurements(_currentUserId);
      provider.getFittingHistory(_currentUserId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📱 AR-Примерка'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt), text: 'Фото'),
            Tab(icon: Icon(Icons.visibility), text: 'Примерка'),
            Tab(icon: Icon(Icons.history), text: 'История'),
            Tab(icon: Icon(Icons.analytics), text: 'Анализ'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhotoTab(),
          _buildVirtualTryOnTab(),
          _buildHistoryTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildPhotoTab() {
    return Consumer<ARFittingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Camera preview placeholder
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Камера для AR-анализа',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Сделайте фото для анализа размеров',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _takePhoto(provider),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Сделать фото'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectPhoto(provider),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Выбрать фото'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Manual measurements section
              _buildManualMeasurementsSection(provider),
              
              const SizedBox(height: 24),
              
              // Current measurements display
              if (provider.userMeasurements != null)
                _buildMeasurementsDisplay(provider.userMeasurements!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVirtualTryOnTab() {
    return Consumer<ARFittingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category selection
              _buildCategorySelector(provider),
              
              const SizedBox(height: 24),
              
              // Generate recommendations button
              if (provider.userMeasurements != null)
                ElevatedButton.icon(
                  onPressed: () => _generateRecommendations(provider),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Сгенерировать рекомендации'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Recommendations display
              if (provider.virtualTryOnRecommendations.isNotEmpty)
                _buildRecommendationsDisplay(provider.virtualTryOnRecommendations),
              
              // Loading indicator
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator()),
              
              // Error display
              if (provider.error != null)
                _buildErrorDisplay(provider.error!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<ARFittingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.fittingHistory.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'История примерок пуста',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Попробуйте виртуальную примерку товаров',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.fittingHistory.length,
          itemBuilder: (context, index) {
            final item = provider.fittingHistory[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: item['imageUrl'] != null
                      ? NetworkImage(item['imageUrl'])
                      : null,
                  child: item['imageUrl'] == null
                      ? const Icon(Icons.image)
                      : null,
                ),
                title: Text(item['productName'] ?? 'Unknown Product'),
                subtitle: Text(item['brand'] ?? 'Unknown Brand'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item['fitRating'] != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < item['fitRating']
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(item['viewedAt']),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: () => _showFitRatingDialog(item),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalysisTab() {
    return Consumer<ARFittingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Body analysis button
              ElevatedButton.icon(
                onPressed: () => _getBodyAnalysis(provider),
                icon: const Icon(Icons.analytics),
                label: const Text('Анализ телосложения'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Body analysis display
              if (provider.bodyAnalysis != null)
                _buildBodyAnalysisDisplay(provider.bodyAnalysis!),
              
              const SizedBox(height: 24),
              
              // Size recommendations section
              _buildSizeRecommendationsSection(provider),
              
              // Loading indicator
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator()),
              
              // Error display
              if (provider.error != null)
                _buildErrorDisplay(provider.error!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManualMeasurementsSection(ARFittingProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ручные измерения',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Рост (см)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        provider.addMeasurement('height', double.tryParse(value));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Вес (кг)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        provider.addMeasurement('weight', double.tryParse(value));
                      }
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
                    decoration: const InputDecoration(
                      labelText: 'Грудь (см)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        provider.addMeasurement('chest', double.tryParse(value));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Талия (см)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        provider.addMeasurement('waist', double.tryParse(value));
                      }
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
                    decoration: const InputDecoration(
                      labelText: 'Бедра (см)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        provider.addMeasurement('hips', double.tryParse(value));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Плечи (см)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        provider.addMeasurement('shoulders', double.tryParse(value));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveMeasurements(provider),
                child: const Text('Сохранить измерения'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsDisplay(Map<String, dynamic> measurements) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Текущие измерения',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: measurements.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key}: ${entry.value}'),
                  backgroundColor: Colors.blue[100],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ARFittingProvider provider) {
    final categories = ['shirts', 'pants', 'dresses', 'shoes', 'accessories'];
    String? selectedCategory;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите категорию',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Категория товаров',
                border: OutlineInputBorder(),
              ),
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryDisplayName(category)),
                );
              }).toList(),
              onChanged: (value) {
                selectedCategory = value;
                if (value != null) {
                  provider.getSizeRecommendations(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsDisplay(List<Map<String, dynamic>> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Рекомендации для примерки',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final recommendation = recommendations[index];
            final product = recommendation['product'] as Product;
            final score = recommendation['score'] as double;
            final reasons = List<String>.from(recommendation['reasons'] ?? []);
            final fitPrediction = recommendation['fitPrediction'] as String;
            final sizeRecommendation = recommendation['sizeRecommendation'] as String;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ProductCard(
                            product: product,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getFitColor(fitPrediction),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                fitPrediction,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Совпадение: ${(score * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Размер: $sizeRecommendation',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (reasons.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Почему подходит:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: reasons.map((reason) {
                          return Chip(
                            label: Text(reason),
                            backgroundColor: Colors.green[100],
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _tryOnProduct(product),
                            icon: const Icon(Icons.visibility),
                            label: const Text('Примерить'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _rateProductFit(product),
                            icon: const Icon(Icons.star),
                            label: const Text('Оценить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBodyAnalysisDisplay(Map<String, dynamic> analysis) {
    final measurements = analysis['measurements'] as Map<String, dynamic>;
    final bodyAnalysis = analysis['analysis'] as Map<String, dynamic>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Анализ телосложения',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Body type
            Row(
              children: [
                Icon(
                  _getBodyTypeIcon(bodyAnalysis['bodyType']),
                  size: 32,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getBodyTypeDisplayName(bodyAnalysis['bodyType']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bodyAnalysis['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // BMI and measurements
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'BMI',
                    bodyAnalysis['bmi'],
                    bodyAnalysis['bmiCategory'],
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Рост',
                    '${measurements['height']?.toStringAsFixed(1)} см',
                    'Нормальный',
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recommendations
            const Text(
              'Рекомендации по стилю:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List<String>.from(bodyAnalysis['recommendations'] ?? []).map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeRecommendationsSection(ARFittingProvider provider) {
    if (provider.sizeRecommendations == null) {
      return const SizedBox.shrink();
    }
    
    final recommendations = provider.sizeRecommendations!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Рекомендации по размерам',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Available sizes
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<String>.from(recommendations['sizes'] ?? []).map(
                (size) => Chip(
                  label: Text(size),
                  backgroundColor: Colors.blue[100],
                ),
              ).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Tips
            if (recommendations['tips'] != null) ...[
              const Text(
                'Советы по измерению:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...List<String>.from(recommendations['tips']).map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, String subtitle, Color color) {
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
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'shirts': return 'Рубашки и футболки';
      case 'pants': return 'Брюки и джинсы';
      case 'dresses': return 'Платья';
      case 'shoes': return 'Обувь';
      case 'accessories': return 'Аксессуары';
      default: return category;
    }
  }

  Color _getFitColor(String fitPrediction) {
    switch (fitPrediction) {
      case 'Perfect Fit': return Colors.green;
      case 'Good Fit': return Colors.blue;
      case 'Moderate Fit': return Colors.orange;
      default: return Colors.red;
    }
  }

  IconData _getBodyTypeIcon(String bodyType) {
    switch (bodyType) {
      case 'hourglass': return Icons.favorite;
      case 'inverted-triangle': return Icons.triangle_up;
      case 'pear': return Icons.triangle_down;
      case 'rectangle': return Icons.rectangle;
      case 'athletic': return Icons.fitness_center;
      default: return Icons.person;
    }
  }

  String _getBodyTypeDisplayName(String bodyType) {
    switch (bodyType) {
      case 'hourglass': return 'Песочные часы';
      case 'inverted-triangle': return 'Перевернутый треугольник';
      case 'pear': return 'Груша';
      case 'rectangle': return 'Прямоугольник';
      case 'athletic': return 'Атлетическое';
      default: return bodyType;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Action methods
  Future<void> _takePhoto(ARFittingProvider provider) async {
    final photoPath = await provider.takePhoto();
    if (photoPath != null) {
      await provider.analyzePhoto(
        photoPath: photoPath,
        userId: _currentUserId,
      );
    }
  }

  Future<void> _selectPhoto(ARFittingProvider provider) async {
    final photoPath = await provider.selectPhoto();
    if (photoPath != null) {
      await provider.analyzePhoto(
        photoPath: photoPath,
        userId: _currentUserId,
      );
    }
  }

  Future<void> _saveMeasurements(ARFittingProvider provider) async {
    if (provider.userMeasurements != null) {
      await provider.saveMeasurements(
        userId: _currentUserId,
        measurements: provider.userMeasurements!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Измерения сохранены')),
      );
    }
  }

  Future<void> _generateRecommendations(ARFittingProvider provider) async {
    // Get selected category from UI state
    // For now, use a default category
    await provider.generateVirtualTryOn(
      userId: _currentUserId,
      category: 'shirts',
    );
  }

  Future<void> _getBodyAnalysis(ARFittingProvider provider) async {
    await provider.getBodyAnalysis(_currentUserId);
  }

  void _tryOnProduct(Product product) {
    // TODO: Implement AR try-on visualization
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Примерка ${product.name} в AR'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _rateProductFit(Product product) {
    _showFitRatingDialog({
      'productId': product.id,
      'productName': product.name,
    });
  }

  void _showFitRatingDialog(Map<String, dynamic> item) {
    int rating = 0;
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Оценить примерку: ${item['productName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Оценка:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    rating = index + 1;
                    (context as Element).markNeedsBuild();
                  },
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: 'Отзыв (необязательно)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: rating > 0
                ? () {
                    final provider = context.read<ARFittingProvider>();
                    provider.rateProductFit(
                      userId: _currentUserId,
                      productId: item['productId'],
                      rating: rating,
                      feedback: feedbackController.text.isNotEmpty
                          ? feedbackController.text
                          : null,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Оценка сохранена')),
                    );
                  }
                : null,
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
