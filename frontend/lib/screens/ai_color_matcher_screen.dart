import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_color_matcher_provider.dart';
import '../services/ai_color_matcher_service.dart';

class AIColorMatcherScreen extends StatefulWidget {
  const AIColorMatcherScreen({super.key});

  @override
  State<AIColorMatcherScreen> createState() => _AIColorMatcherScreenState();
}

class _AIColorMatcherScreenState extends State<AIColorMatcherScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedHarmonyType = 'complementary';
  String _selectedSeason = 'all';
  String _selectedOccasion = 'all';
  String _selectedCategory = 'all';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Загружаем данные при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AIColorMatcherProvider>();
      provider.getSeasonalPalettes();
      provider.analyzeColorTrends();
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
        title: const Text('🎨 AI Color Matcher'),
        backgroundColor: Colors.purple[100],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.purple[300],
          labelColor: Colors.purple[800],
          unselectedLabelColor: Colors.purple[600],
          tabs: const [
            Tab(text: '📸 Фото'),
            Tab(text: '🎨 Палитра'),
            Tab(text: '🔗 Гармония'),
            Tab(text: '💡 Рекомендации'),
            Tab(text: '📊 Тренды'),
            Tab(text: '📚 История'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhotoTab(),
          _buildPaletteTab(),
          _buildHarmonyTab(),
          _buildRecommendationsTab(),
          _buildTrendsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // Вкладка "Фото"
  Widget _buildPhotoTab() {
    return Consumer<AIColorMatcherProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Анализ цветов на фото'),
              const SizedBox(height: 16),
              
              // Загрузка фото
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.camera_alt, size: 48, color: Colors.purple),
                      const SizedBox(height: 16),
                      const Text(
                        'Загрузите фото для анализа цветов',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showPhotoOptions(context, provider),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Выбрать фото'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Результаты анализа
              if (provider.photoAnalysis != null) ...[
                _buildAnalysisResults(provider.photoAnalysis!),
                const SizedBox(height: 24),
              ],
              
              // Ошибки
              if (provider.photoAnalysisError != null) ...[
                _buildErrorCard(provider.photoAnalysisError!),
                const SizedBox(height: 24),
              ],
              
              // Загрузка
              if (provider.isAnalyzingPhoto) ...[
                _buildLoadingCard('Анализируем фото...'),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  // Вкладка "Палитра"
  Widget _buildPaletteTab() {
    return Consumer<AIColorMatcherProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Персональная цветовая палитра'),
              const SizedBox(height: 16),
              
              // Генерация палитры
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Создайте персональную палитру',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Фильтры
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSeason,
                              decoration: const InputDecoration(
                                labelText: 'Сезон',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'all', child: Text('Все сезоны')),
                                ...provider._colorMatcherService.getAvailableSeasons().map(
                                  (season) => DropdownMenuItem(
                                    value: season,
                                    child: Text(provider._colorMatcherService.getSeasonName(season)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedSeason = value ?? 'all');
                                provider.setSeason(value ?? 'all');
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedOccasion,
                              decoration: const InputDecoration(
                                labelText: 'Случай',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'all', child: Text('Все случаи')),
                                ...provider._colorMatcherService.getAvailableOccasions().map(
                                  (occasion) => DropdownMenuItem(
                                    value: occasion,
                                    child: Text(provider._colorMatcherService.getOccasionName(occasion)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedOccasion = value ?? 'all');
                                provider.setOccasion(value ?? 'all');
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ElevatedButton.icon(
                        onPressed: () => _generatePersonalPalette(context, provider),
                        icon: const Icon(Icons.palette),
                        label: const Text('Сгенерировать палитру'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Персональная палитра
              if (provider.personalPalette != null && provider.personalPalette!.isNotEmpty) ...[
                _buildPersonalPalette(provider.personalPalette!),
                const SizedBox(height: 24),
              ],
              
              // Сезонные палитры
              if (provider.seasonalPalettes != null) ...[
                _buildSeasonalPalettes(provider.seasonalPalettes!),
                const SizedBox(height: 24),
              ],
              
              // Ошибки и загрузка
              if (provider.paletteGenerationError != null) ...[
                _buildErrorCard(provider.paletteGenerationError!),
                const SizedBox(height: 24),
              ],
              
              if (provider.isGeneratingPalette) ...[
                _buildLoadingCard('Генерируем палитру...'),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  // Вкладка "Гармония"
  Widget _buildHarmonyTab() {
    return Consumer<AIColorMatcherProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Подбор гармоничных цветов'),
              const SizedBox(height: 16),
              
              // Выбор базового цвета
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Выберите базовый цвет',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Палитра базовых цветов
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4',
                          '#FFEAA7', '#DDA0DD', '#FF0000', '#00FF00',
                          '#0000FF', '#FFFF00', '#FF00FF', '#00FFFF',
                        ].map((color) => _buildColorSwatch(
                          color,
                          () => _findHarmoniousColors(context, provider, color),
                        )).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Тип гармонии
                      DropdownButtonFormField<String>(
                        value: _selectedHarmonyType,
                        decoration: const InputDecoration(
                          labelText: 'Тип гармонии',
                          border: OutlineInputBorder(),
                        ),
                        items: provider._colorMatcherService.getAvailableHarmonyTypes().map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(provider._colorMatcherService.getHarmonyTypeName(type)),
                          ),
                        ).toList(),
                        onChanged: (value) {
                          setState(() => _selectedHarmonyType = value ?? 'complementary');
                          provider.setHarmonyType(value ?? 'complementary');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Результаты поиска гармоничных цветов
              if (provider.harmoniousColors != null && provider.harmoniousColors!.isNotEmpty) ...[
                _buildHarmoniousColors(provider.harmoniousColors!),
                const SizedBox(height: 24),
              ],
              
              // Ошибки и загрузка
              if (provider.harmoniousColorsError != null) ...[
                _buildErrorCard(provider.harmoniousColorsError!),
                const SizedBox(height: 24),
              ],
              
              if (provider.isFindingHarmoniousColors) ...[
                _buildLoadingCard('Ищем гармоничные цвета...'),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  // Вкладка "Рекомендации"
  Widget _buildRecommendationsTab() {
    return Consumer<AIColorMatcherProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Цветовые рекомендации'),
              const SizedBox(height: 16),
              
              // Фильтры для рекомендаций
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Настройте параметры',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedOccasion,
                              decoration: const InputDecoration(
                                labelText: 'Случай',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'all', child: Text('Все случаи')),
                                ...provider._colorMatcherService.getAvailableOccasions().map(
                                  (occasion) => DropdownMenuItem(
                                    value: occasion,
                                    child: Text(provider._colorMatcherService.getOccasionName(occasion)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedOccasion = value ?? 'all');
                                provider.setOccasion(value ?? 'all');
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSeason,
                              decoration: const InputDecoration(
                                labelText: 'Сезон',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'all', child: Text('Все сезоны')),
                                ...provider._colorMatcherService.getAvailableSeasons().map(
                                  (season) => DropdownMenuItem(
                                    value: season,
                                    child: Text(provider._colorMatcherService.getSeasonName(season)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedSeason = value ?? 'all');
                                provider.setSeason(value ?? 'all');
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ElevatedButton.icon(
                        onPressed: () => _getRecommendations(context, provider),
                        icon: const Icon(Icons.lightbulb),
                        label: const Text('Получить рекомендации'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Рекомендации
              if (provider.colorRecommendations != null && provider.colorRecommendations!.isNotEmpty) ...[
                _buildRecommendations(provider.colorRecommendations!),
                const SizedBox(height: 24),
              ],
              
              // Ошибки и загрузка
              if (provider.recommendationsError != null) ...[
                _buildErrorCard(provider.recommendationsError!),
                const SizedBox(height: 24),
              ],
              
              if (provider.isLoadingRecommendations) ...[
                _buildLoadingCard('Загружаем рекомендации...'),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  // Вкладка "Тренды"
  Widget _buildTrendsTab() {
    return Consumer<AIColorMatcherProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Цветовые тренды'),
              const SizedBox(height: 16),
              
              // Фильтры для трендов
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Анализ трендов',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Категория',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'all', child: Text('Все категории')),
                                const DropdownMenuItem(value: 'dresses', child: Text('Платья')),
                                const DropdownMenuItem(value: 'tops', child: Text('Топы')),
                                const DropdownMenuItem(value: 'bottoms', child: Text('Брюки/Юбки')),
                                const DropdownMenuItem(value: 'accessories', child: Text('Аксессуары')),
                                const DropdownMenuItem(value: 'shoes', child: Text('Обувь')),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedCategory = value ?? 'all');
                                provider.setCategory(value ?? 'all');
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSeason,
                              decoration: const InputDecoration(
                                labelText: 'Сезон',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'all', child: Text('Все сезоны')),
                                ...provider._colorMatcherService.getAvailableSeasons().map(
                                  (season) => DropdownMenuItem(
                                    value: season,
                                    child: Text(provider._colorMatcherService.getSeasonName(season)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedSeason = value ?? 'all');
                                provider.setSeason(value ?? 'all');
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ElevatedButton.icon(
                        onPressed: () => _analyzeTrends(context, provider),
                        icon: const Icon(Icons.trending_up),
                        label: const Text('Анализировать тренды'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Тренды
              if (provider.colorTrends != null && provider.colorTrends!.isNotEmpty) ...[
                _buildColorTrends(provider.colorTrends!),
                const SizedBox(height: 24),
              ],
              
              // Ошибки и загрузка
              if (provider.trendsError != null) ...[
                _buildErrorCard(provider.trendsError!),
                const SizedBox(height: 24),
              ],
              
              if (provider.isLoadingTrends) ...[
                _buildLoadingCard('Анализируем тренды...'),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  // Вкладка "История"
  Widget _buildHistoryTab() {
    return Consumer<AIColorMatcherProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('История цветовых анализов'),
              const SizedBox(height: 24),
              
              // Статистика
              if (provider.userColorStats != null) ...[
                _buildUserStats(provider.userColorStats!),
                const SizedBox(height: 24),
              ],
              
              // История
              if (provider.colorHistory != null && provider.colorHistory!.isNotEmpty) ...[
                _buildColorHistory(provider.colorHistory!),
                const SizedBox(height: 24),
              ],
              
              // Пользовательские палитры
              if (provider.userPalettes != null && provider.userPalettes!.isNotEmpty) ...[
                _buildUserPalettes(provider.userPalettes!),
                const SizedBox(height: 24),
              ],
              
              // Ошибки и загрузка
              if (provider.colorHistoryError != null) ...[
                _buildErrorCard(provider.colorHistoryError!),
                const SizedBox(height: 24),
              ],
              
              if (provider.isLoadingHistory) ...[
                _buildLoadingCard('Загружаем историю...'),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  // Вспомогательные виджеты

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      ),
    );
  }

  Widget _buildColorSwatch(String color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Color(int.parse(color.replaceAll('#', '0xFF'))),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            color.replaceAll('#', ''),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(Map<String, dynamic> analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Результаты анализа',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Доминирующие цвета
            if (analysis['dominantColors'] != null) ...[
              const Text('Доминирующие цвета:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (analysis['dominantColors'] as List).map((color) => _buildColorSwatch(
                  color['color'],
                  () {},
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Рекомендации
            if (analysis['recommendations'] != null) ...[
              const Text('Рекомендации:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(analysis['recommendations'] as List).map((rec) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(rec['title'] ?? ''),
                  subtitle: Text(rec['description'] ?? ''),
                  leading: Icon(
                    rec['type'] == 'outfit' ? Icons.checkroom : Icons.style,
                    color: Colors.purple[600],
                  ),
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalPalette(List<Map<String, dynamic>> palette) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ваша персональная палитра',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: palette.map((color) => _buildColorSwatch(
                color['color'],
                () {},
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalPalettes(Map<String, dynamic> seasonalData) {
    final palettes = seasonalData['seasonalPalettes'] as Map<String, dynamic>?;
    if (palettes == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сезонные палитры',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...palettes.entries.map((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getSeasonName(entry.key)}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (entry.value as List).map((color) => _buildColorSwatch(
                    color,
                    () {},
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHarmoniousColors(List<Map<String, dynamic>> colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Гармоничные цвета',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colors.map((color) => _buildColorSwatch(
                color['color'],
                () {},
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<Map<String, dynamic>> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Рекомендации',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...recommendations.map((rec) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(rec['title'] ?? ''),
                subtitle: Text(rec['description'] ?? ''),
                leading: Icon(
                  rec['type'] == 'casual' ? Icons.casual : Icons.business_center,
                  color: Colors.purple[600],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTrends(List<Map<String, dynamic>> trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Цветовые тренды',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...trends.map((trend) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: _buildColorSwatch(trend['color'], () {}),
                title: Text('${trend['category'] ?? ''} - ${trend['trend'] ?? ''}'),
                subtitle: Text('${trend['percentage'] ?? 0}%'),
                trailing: Icon(
                  trend['trend'] == 'rising' ? Icons.trending_up : 
                  trend['trend'] == 'falling' ? Icons.trending_down : Icons.trending_flat,
                  color: trend['trend'] == 'rising' ? Colors.green : 
                         trend['trend'] == 'falling' ? Colors.red : Colors.grey,
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ваша статистика',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Анализов',
                    '${stats['totalAnalyses'] ?? 0}',
                    Icons.analytics,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Любимый цвет',
                    stats['mostUsed'] ?? 'Нет',
                    Icons.favorite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.purple[600]),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorHistory(List<Map<String, dynamic>> history) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'История анализов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...history.take(5).map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.purple),
                title: Text('Анализ ${item['id'] ?? ''}'),
                subtitle: Text('${item['createdAt'] ?? ''}'),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPalettes(List<Map<String, dynamic>> palettes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ваши палитры',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...palettes.take(3).map((palette) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.palette, color: Colors.purple),
                title: Text(palette['name'] ?? ''),
                subtitle: Text(palette['description'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Вспомогательные методы

  String _getSeasonName(String season) {
    final names = {
      'spring': 'Весна',
      'summer': 'Лето',
      'autumn': 'Осень',
      'winter': 'Зима',
    };
    return names[season] ?? season;
  }

  void _showPhotoOptions(BuildContext context, AIColorMatcherProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Сделать фото'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Реализовать камеру
                _mockPhotoAnalysis(provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Выбрать из галереи'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Реализовать галерею
                _mockPhotoAnalysis(provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mockPhotoAnalysis(AIColorMatcherProvider provider) {
    provider.analyzePhotoColors(
      imageUrl: 'https://example.com/mock-photo.jpg',
      userId: 'user123',
    );
  }

  void _generatePersonalPalette(BuildContext context, AIColorMatcherProvider provider) {
    provider.generatePersonalPalette(
      userId: 'user123',
      preferredColors: ['#FF6B6B', '#4ECDC4'],
      skinTone: 'warm',
      hairColor: 'brown',
      eyeColor: 'brown',
    );
  }

  void _findHarmoniousColors(BuildContext context, AIColorMatcherProvider provider, String baseColor) {
    provider.findHarmoniousColors(
      baseColor: baseColor,
      harmonyType: _selectedHarmonyType,
      count: 5,
    );
  }

  void _getRecommendations(BuildContext context, AIColorMatcherProvider provider) {
    provider.getColorRecommendations(
      userId: 'user123',
      occasion: _selectedOccasion == 'all' ? null : _selectedOccasion,
      season: _selectedSeason == 'all' ? null : _selectedSeason,
    );
  }

  void _analyzeTrends(BuildContext context, AIColorMatcherProvider provider) {
    provider.analyzeColorTrends(
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      season: _selectedSeason == 'all' ? null : _selectedSeason,
      limit: 10,
    );
  }
}
