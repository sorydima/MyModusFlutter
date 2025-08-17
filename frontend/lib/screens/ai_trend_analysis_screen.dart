import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';

class AITrendAnalysisScreen extends StatefulWidget {
  const AITrendAnalysisScreen({super.key});

  @override
  State<AITrendAnalysisScreen> createState() => _AITrendAnalysisScreenState();
}

class _AITrendAnalysisScreenState extends State<AITrendAnalysisScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _selectedTimeframe = '30d';
  String _selectedRegion = 'Global';
  String _selectedCategory = 'All';

  final List<String> _timeframes = ['7d', '30d', '90d', '180d', '1y'];
  final List<String> _regions = ['Global', 'Europe', 'Asia', 'North America', 'Russia'];
  final List<String> _categories = ['All', 'Clothing', 'Shoes', 'Accessories', 'Beauty'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('AI Анализ трендов'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтры
          _buildFilters(),
          
          const SizedBox(height: 20),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).primaryColor,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              tabs: const [
                Tab(text: 'Тренды'),
                Tab(text: 'Анализ'),
                Tab(text: 'Прогнозы'),
                Tab(text: 'Инсайты'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrendsTab(),
                _buildAnalysisTab(),
                _buildForecastsTab(),
                _buildInsightsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Параметры анализа',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Период',
                  value: _selectedTimeframe,
                  items: _timeframes,
                  onChanged: (value) => setState(() => _selectedTimeframe = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Регион',
                  value: _selectedRegion,
                  items: _regions,
                  onChanged: (value) => setState(() => _selectedRegion = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Категория',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 14)),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTrendsTab() {
    return _buildTabContent(
      title: 'Актуальные тренды',
      subtitle: 'AI анализ текущих модных трендов',
      children: [
        _buildTrendCard(
          name: 'Sustainable Fashion',
          description: 'Растущий интерес к экологичной моде и осознанному потреблению',
          confidence: 0.95,
          growthRate: 28.5,
          popularity: 'Very High',
          duration: 'Long-term',
          brands: ['Patagonia', 'Stella McCartney', 'Veja', 'Reformation'],
          imageUrl: 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Sustainable',
        ),
        _buildTrendCard(
          name: 'Athleisure Evolution',
          description: 'Спортивная одежда становится повседневной, стильной и функциональной',
          confidence: 0.92,
          growthRate: 22.3,
          popularity: 'High',
          duration: 'Medium-term',
          brands: ['Lululemon', 'Nike', 'Adidas', 'Alo Yoga'],
          imageUrl: 'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Athleisure',
        ),
        _buildTrendCard(
          name: 'Vintage Revival',
          description: 'Возвращение винтажных стилей с современным подходом',
          confidence: 0.88,
          growthRate: 18.7,
          popularity: 'Medium',
          duration: 'Short-term',
          brands: ['Levi\'s', 'Carhartt', 'Champion', 'Dickies'],
          imageUrl: 'https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Vintage',
        ),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    return _buildTabContent(
      title: 'Детальный анализ',
      subtitle: 'Глубокий AI анализ трендов и их влияния',
      children: [
        _buildAnalysisCard(
          title: 'Демографический анализ',
          data: {
            'Основная аудитория': '18-35 лет',
            'Гендерное распределение': 'Женщины 65%, Мужчины 35%',
            'Географический фокус': 'Европа и Северная Америка',
            'Уровень дохода': 'Средний и выше среднего',
            'Стиль жизни': 'Активный, социально ответственный',
          },
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildAnalysisCard(
          title: 'Экономические показатели',
          data: {
            'Рыночная стоимость': '€45.2 млрд',
            'Рост рынка': '+15.3% год к году',
            'Средний чек': '€89',
            'Частота покупок': 'Ежемесячно',
            'Влияние сезонности': 'Высокое',
          },
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        _buildAnalysisCard(
          title: 'Технологические факторы',
          data: {
            'E-commerce доля': '78%',
            'Мобильные покупки': '65%',
            'AR/VR использование': '23%',
            'AI рекомендации': '89%',
            'Социальные сети': 'Критично важно',
          },
          icon: Icons.phone_android,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildForecastsTab() {
    return _buildTabContent(
      title: 'Прогнозы развития',
      subtitle: 'AI предсказания будущих трендов',
      children: [
        _buildForecastCard(
          title: 'Q2 2024 - Весенние тренды',
          predictions: [
            'Пастельные тона доминируют',
            'Экологичные материалы растут на 25%',
            'Oversize силуэты популярны',
            'Яркие акценты в базовых образах',
          ],
          confidence: 0.91,
          timeframe: '3 месяца',
          icon: Icons.spring,
          color: Colors.pink,
        ),
        _buildForecastCard(
          title: 'Q3 2024 - Летние инновации',
          predictions: [
            'Технологичные ткани',
            'Умная одежда с датчиками',
            'Персонализированный дизайн',
            'Цифровые принты',
          ],
          confidence: 0.87,
          timeframe: '6 месяцев',
          icon: Icons.wb_sunny,
          color: Colors.orange,
        ),
        _buildForecastCard(
          title: 'Q4 2024 - Осенние тренды',
          predictions: [
            'Темные насыщенные тона',
            'Текстурированные материалы',
            'Многослойность',
            'Классические силуэты',
          ],
          confidence: 0.84,
          timeframe: '9 месяцев',
          icon: Icons.eco,
          color: Colors.brown,
        ),
      ],
    );
  }

  Widget _buildInsightsTab() {
    return _buildTabContent(
      title: 'AI Инсайты',
      subtitle: 'Уникальные наблюдения и рекомендации',
      children: [
        _buildInsightCard(
          title: 'Психология моды',
          content: 'AI анализ показывает, что потребители все больше ценят '
              'эмоциональную связь с брендами. Успешные компании фокусируются '
              'на storytelling и создании сообщества вокруг своих продуктов.',
          icon: Icons.psychology,
          color: Colors.indigo,
          tags: ['Психология', 'Брендинг', 'Сообщество'],
        ),
        _buildInsightCard(
          title: 'Устойчивое развитие',
          content: 'Экологичность становится не просто трендом, а необходимостью. '
              'Потребители готовы платить на 15-20% больше за экологичные продукты. '
              'Бренды, которые не адаптируются, рискуют потерять аудиторию.',
          icon: Icons.eco,
          color: Colors.green,
          tags: ['Экология', 'Устойчивость', 'Цена'],
        ),
        _buildInsightCard(
          title: 'Технологическая интеграция',
          content: 'AR/VR технологии трансформируют шоппинг. '
              'Виртуальные примерочные увеличивают конверсию на 30%. '
              'AI-персональные стилисты повышают удовлетворенность клиентов.',
          icon: Icons.vr_headset,
          color: Colors.cyan,
          tags: ['AR/VR', 'Технологии', 'Конверсия'],
        ),
      ],
    );
  }

  Widget _buildTabContent({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ...children,
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTrendCard({
    required String name,
    required String description,
    required double confidence,
    required double growthRate,
    required String popularity,
    required String duration,
    required List<String> brands,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 200,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 50),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок и метрики
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+${growthRate.toInt()}%',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(confidence * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Детали тренда
                Row(
                  children: [
                    _buildTrendDetail('Популярность', popularity, _getPopularityColor(popularity)),
                    const SizedBox(width: 20),
                    _buildTrendDetail('Длительность', duration, _getDurationColor(duration)),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Бренды
                Text(
                  'Ключевые бренды:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: brands.map((brand) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      brand,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendDetail(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required Map<String, String> data,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...data.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildForecastCard({
    required String title,
    required List<String> predictions,
    required double confidence,
    required String timeframe,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Горизонт: $timeframe',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(confidence * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...predictions.map((prediction) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prediction,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required List<String> tags,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Color _getPopularityColor(String popularity) {
    switch (popularity.toLowerCase()) {
      case 'very high':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getDurationColor(String duration) {
    switch (duration.toLowerCase()) {
      case 'long-term':
        return Colors.green;
      case 'medium-term':
        return Colors.orange;
      case 'short-term':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
    });
    
    // Имитация обновления данных
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
}
