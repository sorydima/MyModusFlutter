import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';

class AIDashboardScreen extends StatefulWidget {
  const AIDashboardScreen({super.key});

  @override
  State<AIDashboardScreen> createState() => _AIDashboardScreenState();
}

class _AIDashboardScreenState extends State<AIDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

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
        title: const Text('AI Dashboard'),
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
          // AI Stats Overview Cards
          _buildAIStatsOverview(),
          
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
                Tab(text: 'Поведение'),
                Tab(text: 'Эффективность'),
                Tab(text: 'Аналитика'),
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
                _buildBehaviorTab(),
                _buildEffectivenessTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIStatsOverview() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            title: 'AI Запросы',
            value: '15,420',
            subtitle: '+12% за неделю',
            icon: Icons.psychology,
            color: Colors.blue,
          ),
          _buildStatCard(
            title: 'Успешность',
            value: '96.6%',
            subtitle: 'Высокий уровень',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          _buildStatCard(
            title: 'Время ответа',
            value: '1.25s',
            subtitle: 'Среднее время',
            icon: Icons.speed,
            color: Colors.orange,
          ),
          _buildStatCard(
            title: 'Стоимость',
            value: '\$45.80',
            subtitle: 'За месяц',
            icon: Icons.attach_money,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return _buildTabContent(
      title: 'Модные тренды',
      subtitle: 'AI анализ текущих трендов в моде',
      children: [
        _buildTrendCard(
          name: 'Sustainable Fashion',
          description: 'Растущий интерес к экологичной моде',
          confidence: 0.92,
          growthRate: 25.0,
          brands: ['Patagonia', 'Stella McCartney', 'Veja'],
        ),
        _buildTrendCard(
          name: 'Athleisure',
          description: 'Спортивная одежда для повседневной носки',
          confidence: 0.88,
          growthRate: 18.0,
          brands: ['Lululemon', 'Nike', 'Adidas'],
        ),
        _buildTrendCard(
          name: 'Vintage Revival',
          description: 'Возвращение винтажных стилей',
          confidence: 0.85,
          growthRate: 12.0,
          brands: ['Levi\'s', 'Carhartt', 'Champion'],
        ),
      ],
    );
  }

  Widget _buildBehaviorTab() {
    return _buildTabContent(
      title: 'Анализ поведения',
      subtitle: 'AI анализ пользовательского поведения',
      children: [
        _buildBehaviorCard(
          title: 'Паттерны покупок',
          data: {
            'Предпочитаемые категории': 'Обувь, Одежда',
            'Любимые бренды': 'Nike, Adidas, Levi\'s',
            'Средний чек': '15,000 ₽',
            'Частота покупок': 'Еженедельно',
          },
        ),
        _buildBehaviorCard(
          title: 'Время активности',
          data: {
            'Пиковые часы': '12:00, 18:00, 21:00',
            'Любимые дни': 'Среда, Пятница, Суббота',
            'Длительность сессии': '15-30 минут',
            'Процент возвратов': '85%',
          },
        ),
        _buildBehaviorCard(
          title: 'Вовлеченность',
          data: {
            'Просмотрено постов': '45',
            'Оставлено комментариев': '12',
            'Поставлено лайков': '67',
            'Подписчиков': '234',
          },
        ),
      ],
    );
  }

  Widget _buildEffectivenessTab() {
    return _buildTabContent(
      title: 'Эффективность рекомендаций',
      subtitle: 'AI метрики эффективности системы рекомендаций',
      children: [
        _buildMetricCard(
          title: 'Click-through Rate (CTR)',
          value: '15%',
          description: 'Процент кликов по рекомендациям',
          trend: '+2.3%',
          isPositive: true,
        ),
        _buildMetricCard(
          title: 'Conversion Rate',
          value: '8%',
          description: 'Процент конверсии в покупки',
          trend: '+1.1%',
          isPositive: true,
        ),
        _buildMetricCard(
          title: 'Average Order Value',
          value: '18,500 ₽',
          description: 'Средний чек заказа',
          trend: '+5.2%',
          isPositive: true,
        ),
        _buildMetricCard(
          title: 'User Engagement',
          value: '72%',
          description: 'Уровень вовлеченности пользователей',
          trend: '+3.8%',
          isPositive: true,
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return _buildTabContent(
      title: 'AI Аналитика',
      subtitle: 'Детальная аналитика AI системы',
      children: [
        _buildAnalyticsCard(
          title: 'Прогнозирование спроса',
          items: [
            'Nike Air Max 270: +20% к Q2',
            'Levi\'s 501 Jeans: стабильный спрос',
            'Apple Watch: рост на 15%',
          ],
        ),
        _buildAnalyticsCard(
          title: 'Анализ конкурентов',
          items: [
            'Zara: фокус на качество',
            'H&M: уникальное позиционирование',
            'Uniqlo: технологические инновации',
          ],
        ),
        _buildAnalyticsCard(
          title: 'Модерация контента',
          items: [
            'Одобрено: 78%',
            'На рассмотрении: 18%',
            'Отклонено: 4%',
          ],
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
    required List<String> brands,
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
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Уверенность: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '${(confidence * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Бренды: ${brands.join(', ')}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorCard({
    required String title,
    required Map<String, String> data,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...data.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String description,
    required String trend,
    required bool isPositive,
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required List<String> items,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
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
