import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_analytics_provider.dart';

class SocialAnalyticsScreen extends StatefulWidget {
  const SocialAnalyticsScreen({super.key});

  @override
  State<SocialAnalyticsScreen> createState() => _SocialAnalyticsScreenState();
}

class _SocialAnalyticsScreenState extends State<SocialAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  String _selectedPeriod = 'month';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SocialAnalyticsProvider>();
      provider.loadAllAnalyticsData();
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
        title: const Text('📊 Социальная аналитика'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = context.read<SocialAnalyticsProvider>();
              provider.loadAllAnalyticsData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'Тренды'),
            Tab(icon: Icon(Icons.people), text: 'Аудитория'),
            Tab(icon: Icon(Icons.business), text: 'Конкуренты'),
            Tab(icon: Icon(Icons.psychology), text: 'Прогнозы'),
            Tab(icon: Icon(Icons.analytics), text: 'Отчеты'),
            Tab(icon: Icon(Icons.compare), text: 'Сравнение'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Column(
        children: [
          // Фильтры
          _buildFilters(),
          
          // Основной контент
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrendsTab(),
                _buildAudienceTab(),
                _buildCompetitorsTab(),
                _buildPredictionsTab(),
                _buildReportsTab(),
                _buildComparisonTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Построить фильтры
  Widget _buildFilters() {
    return Consumer<SocialAnalyticsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              // Выбор периода
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Период',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.getAvailablePeriods().map((period) {
                    return DropdownMenuItem(
                      value: period['value'],
                      child: Text('${period['icon']} ${period['label']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                      provider.setSelectedPeriod(value);
                      provider.loadAllPeriodData(value);
                    }
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Выбор категории
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('📦 Все категории')),
                    const DropdownMenuItem(value: 'electronics', child: Text('📱 Электроника')),
                    const DropdownMenuItem(value: 'fashion', child: Text('👗 Мода')),
                    const DropdownMenuItem(value: 'home', child: Text('🏠 Дом')),
                    const DropdownMenuItem(value: 'sports', child: Text('⚽ Спорт')),
                    const DropdownMenuItem(value: 'beauty', child: Text('💄 Красота')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      provider.setSelectedCategory(value);
                      if (value != 'all') {
                        provider.loadAllCategoryData(value);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Построить вкладку трендов
  Widget _buildTrendsTab() {
    return Consumer<SocialAnalyticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Ошибка: ${provider.error}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadAllAnalyticsData(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        final trends = provider.categoryTrends;
        if (trends == null) {
          return const Center(child: Text('Нет данных о трендах'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Сводка
              _buildTrendsSummary(trends),
              
              const SizedBox(height: 24),
              
              // Топ категории
              _buildTopCategories(trends),
              
              const SizedBox(height: 24),
              
              // График трендов
              _buildTrendsChart(trends),
            ],
          ),
        );
      },
    );
  }

  /// Построить сводку трендов
  Widget _buildTrendsSummary(Map<String, dynamic> trends) {
    final summary = trends['summary'] as Map<String, dynamic>?;
    if (summary == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Сводка трендов',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    '📈 Растущие',
                    '${summary['trendingUp'] ?? 0}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    '📉 Падающие',
                    '${summary['trendingDown'] ?? 0}',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Всего категорий',
                    '${trends['totalCategories'] ?? 0}',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Построить карточку сводки
  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Построить топ категории
  Widget _buildTopCategories(Map<String, dynamic> trends) {
    final topCategories = trends['topCategories'] as List<dynamic>?;
    if (topCategories == null || topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Топ категории',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topCategories.length,
              itemBuilder: (context, index) {
                final category = topCategories[index];
                return _buildCategoryCard(category, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Построить карточку категории
  Widget _buildCategoryCard(Map<String, dynamic> category, int rank) {
    final provider = context.read<SocialAnalyticsProvider>();
    final trend = category['trend'] as String? ?? 'stable';
    final trendColor = provider.getTrendColor(trend);
    final formattedTrend = provider.formatTrend(trend);
    final growthRate = (category['growthRate'] as num?)?.toDouble() ?? 0.0;
    final formattedGrowth = provider.formatPercentageChange(growthRate);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(trendColor),
          child: Text(
            '$rank',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          category['categoryName'] as String? ?? 'Неизвестная категория',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Тренд: $formattedTrend'),
            Text('Рост: $formattedGrowth'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              provider.formatNumber(category['totalSales'] ?? 0),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${provider.formatRating(category['avgRating'] ?? 0)} ⭐',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Построить график трендов
  Widget _buildTrendsChart(Map<String, dynamic> trends) {
    // TODO: Реализовать график трендов
    return Card(
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '📈 График трендов будет здесь',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Построить вкладку аудитории
  Widget _buildAudienceTab() {
    return Consumer<SocialAnalyticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final analysis = provider.audienceAnalysis;
        if (analysis == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () => provider.getAudienceAnalysis(),
              child: const Text('Загрузить анализ аудитории'),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAudienceSummary(analysis),
              const SizedBox(height: 24),
              _buildDemographicsChart(analysis),
              const SizedBox(height: 24),
              _buildInterestsChart(analysis),
              const SizedBox(height: 24),
              _buildBehaviorMetrics(analysis),
            ],
          ),
        );
      },
    );
  }

  /// Построить сводку аудитории
  Widget _buildAudienceSummary(Map<String, dynamic> analysis) {
    final summary = analysis['summary'] as Map<String, dynamic>?;
    if (summary == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👥 Сводка аудитории',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Всего пользователей',
                    provider.formatNumber(summary['totalUsers'] ?? 0),
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Активных',
                    provider.formatNumber(summary['activeUsers'] ?? 0),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Средний возраст',
                    '${summary['avgAge']?.toStringAsFixed(0) ?? 0}',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Построить график демографии
  Widget _buildDemographicsChart(Map<String, dynamic> analysis) {
    final demographics = analysis['demographics'] as Map<String, dynamic>?;
    if (demographics == null) return const SizedBox.shrink();

    return Card(
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '📊 График демографии будет здесь',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Построить график интересов
  Widget _buildInterestsChart(Map<String, dynamic> analysis) {
    final interests = analysis['interests'] as List<dynamic>?;
    if (interests == null || interests.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Интересы аудитории',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: interests.length,
              itemBuilder: (context, index) {
                final interest = interests[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Text(
                      interest['interest']?.toString().substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(color: Colors.purple[700]),
                    ),
                  ),
                  title: Text(interest['interest']?.toString() ?? ''),
                  subtitle: Text('Тренд: ${provider.formatTrend(interest['trend'] ?? 'stable')}'),
                  trailing: Text(
                    '${interest['percentage']}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Построить метрики поведения
  Widget _buildBehaviorMetrics(Map<String, dynamic> analysis) {
    final behavior = analysis['behavior'] as Map<String, dynamic>?;
    if (behavior == null) return const SizedBox.shrink();

    return Card(
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '📈 Метрики поведения будут здесь',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Построить вкладку конкурентов
  Widget _buildCompetitorsTab() {
    return Consumer<SocialAnalyticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final analysis = provider.competitorAnalysis;
        if (analysis == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () => provider.getCompetitorAnalysis(),
              child: const Text('Загрузить анализ конкурентов'),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompetitorSummary(analysis),
              const SizedBox(height: 24),
              _buildCompetitorList(analysis),
              const SizedBox(height: 24),
              _buildPriceAnalysis(analysis),
            ],
          ),
        );
      },
    );
  }

  /// Построить сводку конкурентов
  Widget _buildCompetitorSummary(Map<String, dynamic> analysis) {
    final summary = analysis['summary'] as Map<String, dynamic>?;
    if (summary == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏢 Сводка конкурентов',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Всего конкурентов',
                    '${summary['totalCompetitors'] ?? 0}',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Средняя цена',
                    '${summary['avgPrice']?.toStringAsFixed(0) ?? 0} ₽',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Построить список конкурентов
  Widget _buildCompetitorList(Map<String, dynamic> analysis) {
    final competitors = analysis['competitors'] as List<dynamic>?;
    if (competitors == null || competitors.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🥇 Рейтинг конкурентов',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: competitors.length,
              itemBuilder: (context, index) {
                final competitor = competitors[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index == 0 ? Colors.amber : Colors.grey[300],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index == 0 ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(competitor['name']?.toString() ?? 'Конкурент ${index + 1}'),
                  subtitle: Text('Счет: ${(competitor['score'] as num?)?.toStringAsFixed(2) ?? '0'}'),
                  trailing: Text(
                    '${competitor['price']?.toStringAsFixed(0) ?? 0} ₽',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Построить анализ цен
  Widget _buildPriceAnalysis(Map<String, dynamic> analysis) {
    final priceAnalysis = analysis['priceAnalysis'] as Map<String, dynamic>?;
    if (priceAnalysis == null) return const SizedBox.shrink();

    return Card(
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '💰 Анализ цен будет здесь',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Построить вкладку прогнозов
  Widget _buildPredictionsTab() {
    return Consumer<SocialAnalyticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final predictions = provider.trendPredictions;
        if (predictions == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () => provider.getTrendPredictions(),
              child: const Text('Загрузить прогнозы'),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPredictionSummary(predictions),
              const SizedBox(height: 24),
              _buildPredictionChart(predictions),
              const SizedBox(height: 24),
              _buildRecommendations(predictions),
            ],
          ),
        );
      },
    );
  }

  /// Построить сводку прогнозов
  Widget _buildPredictionSummary(Map<String, dynamic> predictions) {
    final summary = predictions['summary'] as Map<String, dynamic>?;
    if (summary == null) return const SizedBox.shrink();

    final provider = context.read<SocialAnalyticsProvider>();
    final trendDirection = summary['trendDirection'] as String? ?? 'stable';
    final trendColor = provider.getTrendColor(trendDirection);
    final formattedTrend = provider.formatTrend(trendDirection);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔮 Сводка прогнозов',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Направление тренда',
                    formattedTrend,
                    Color(trendColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Ожидаемый рост',
                    provider.formatPercentageChange(summary['expectedGrowth'] ?? 0),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Уверенность',
                    '${((summary['confidenceLevel'] ?? 0) * 100).toStringAsFixed(0)}%',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Построить график прогнозов
  Widget _buildPredictionChart(Map<String, dynamic> predictions) {
    return Card(
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '📈 График прогнозов будет здесь',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Построить рекомендации
  Widget _buildRecommendations(Map<String, dynamic> predictions) {
    final recommendations = predictions['recommendations'] as Map<String, dynamic>?;
    if (recommendations == null) return const SizedBox.shrink();

    final recs = recommendations['recommendations'] as List<dynamic>? ?? [];
    final risks = recommendations['risks'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Рекомендации',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (recs.isNotEmpty) ...[
              const Text(
                '✅ Что делать:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...recs.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(rec.toString())),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            
            if (risks.isNotEmpty) ...[
              const Text(
                '⚠️ Риски:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
              ),
              const SizedBox(height: 8),
              ...risks.map((risk) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(risk.toString())),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  /// Построить вкладку отчетов
  Widget _buildReportsTab() {
    return Consumer<SocialAnalyticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.reportTypes.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () => provider.getReportTypes(),
              child: const Text('Загрузить типы отчетов'),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📋 Доступные отчеты',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildReportTypesList(provider),
              const SizedBox(height: 24),
              if (provider.generatedReport != null) ...[
                _buildGeneratedReport(provider.generatedReport!),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Построить список типов отчетов
  Widget _buildReportTypesList(SocialAnalyticsProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.reportTypes.length,
      itemBuilder: (context, index) {
        final reportType = provider.reportTypes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.description, color: Colors.blue[700]),
            ),
            title: Text(reportType['name']?.toString() ?? ''),
            subtitle: Text(reportType['description']?.toString() ?? ''),
            trailing: ElevatedButton(
              onPressed: () => _generateReport(provider, reportType),
              child: const Text('Создать'),
            ),
          ),
        );
      },
    );
  }

  /// Сгенерировать отчет
  void _generateReport(SocialAnalyticsProvider provider, Map<String, dynamic> reportType) {
    final reportTypeValue = reportType['type'] as String?;
    if (reportTypeValue == null) return;

    Map<String, dynamic>? parameters;
    
    if (reportTypeValue == 'trends') {
      parameters = {
        'period': _selectedPeriod,
        'limit': 20,
      };
    } else if (reportTypeValue == 'audience') {
      parameters = {
        'category': _selectedCategory,
        'period': _selectedPeriod,
      };
    } else if (reportTypeValue == 'competitors') {
      parameters = {
        'category': _selectedCategory,
        'limit': 10,
      };
    }

    provider.generateReport(
      reportType: reportTypeValue,
      parameters: parameters,
    );
  }

  /// Построить сгенерированный отчет
  Widget _buildGeneratedReport(Map<String, dynamic> report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📊 Сгенерированный отчет',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // TODO: Реализовать скачивание отчета
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Тип: ${report['reportMetadata']?['reportType'] ?? 'Неизвестно'}'),
            Text('Создан: ${report['reportMetadata']?['generatedAt'] ?? 'Неизвестно'}'),
            const SizedBox(height: 16),
            const Text(
              'Содержимое отчета будет отображаться здесь',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Построить вкладку сравнения
  Widget _buildComparisonTab() {
    return Consumer<SocialAnalyticsProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Сравнение периодов',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildComparisonForm(provider),
              const SizedBox(height: 24),
              if (provider.periodComparison != null) ...[
                _buildComparisonResults(provider.periodComparison!),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Построить форму сравнения
  Widget _buildComparisonForm(SocialAnalyticsProvider provider) {
    String period1 = 'month';
    String period2 = 'week';
    List<String> selectedMetrics = ['sales', 'views', 'rating'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите параметры для сравнения:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            
            // Период 1
            DropdownButtonFormField<String>(
              value: period1,
              decoration: const InputDecoration(
                labelText: 'Период 1',
                border: OutlineInputBorder(),
              ),
              items: provider.getAvailablePeriods().map((period) {
                return DropdownMenuItem(
                  value: period['value'],
                  child: Text('${period['icon']} ${period['label']}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) period1 = value;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Период 2
            DropdownButtonFormField<String>(
              value: period2,
              decoration: const InputDecoration(
                labelText: 'Период 2',
                border: OutlineInputBorder(),
              ),
              items: provider.getAvailablePeriods().map((period) {
                return DropdownMenuItem(
                  value: period['value'],
                  child: Text('${period['icon']} ${period['label']}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) period2 = value;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Метрики
            const Text(
              'Метрики для сравнения:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: provider.getAvailableMetrics().map((metric) {
                final isSelected = selectedMetrics.contains(metric['value']);
                return FilterChip(
                  label: Text('${metric['icon']} ${metric['label']}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      selectedMetrics.add(metric['value']);
                    } else {
                      selectedMetrics.remove(metric['value']);
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.comparePeriods(
                    period1: period1,
                    period2: period2,
                    metrics: selectedMetrics,
                  );
                },
                child: const Text('Сравнить периоды'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Построить результаты сравнения
  Widget _buildComparisonResults(Map<String, dynamic> comparison) {
    final comparisonData = comparison['comparison'] as Map<String, dynamic>?;
    if (comparisonData == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Результаты сравнения',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...comparisonData.entries.map((entry) {
              final metric = entry.key;
              final data = entry.value as Map<String, dynamic>;
              final change = data['change'] as num? ?? 0;
              final trend = data['trend'] as String? ?? 'stable';
              
              final provider = context.read<SocialAnalyticsProvider>();
              final trendColor = provider.getTrendColor(trend);
              final formattedChange = provider.formatPercentageChange(change.toDouble());
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(trendColor),
                  child: Icon(
                    change > 0 ? Icons.trending_up : change < 0 ? Icons.trending_down : Icons.trending_flat,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(metric),
                subtitle: Text('${data['period1']} → ${data['period2']}'),
                trailing: Text(
                  formattedChange,
                  style: TextStyle(
                    color: Color(trendColor),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
