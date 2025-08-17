import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';

class AIPostGeneratorScreen extends StatefulWidget {
  const AIPostGeneratorScreen({super.key});

  @override
  State<AIPostGeneratorScreen> createState() => _AIPostGeneratorScreenState();
}

class _AIPostGeneratorScreenState extends State<AIPostGeneratorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _selectedCategory = 'Fashion';
  String _selectedTone = 'Casual';
  String _selectedLength = 'Medium';

  final List<String> _categories = ['Fashion', 'Lifestyle', 'Beauty', 'Travel', 'Food', 'Fitness'];
  final List<String> _tones = ['Casual', 'Professional', 'Funny', 'Inspirational', 'Educational', 'Trendy'];
  final List<String> _lengths = ['Short', 'Medium', 'Long'];

  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topicController.dispose();
    _keywordsController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Генератор постов'),
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
          // Фильтры и настройки
          _buildGeneratorSettings(),
          
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
                Tab(text: 'Генерация'),
                Tab(text: 'Шаблоны'),
                Tab(text: 'История'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGenerationTab(),
                _buildTemplatesTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratorSettings() {
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
            'Настройки генерации',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          // Тема поста
          TextField(
            controller: _topicController,
            decoration: InputDecoration(
              labelText: 'Тема поста',
              hintText: 'Например: весенние тренды 2024',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.topic),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Ключевые слова
          TextField(
            controller: _keywordsController,
            decoration: InputDecoration(
              labelText: 'Ключевые слова',
              hintText: 'Например: мода, стиль, тренды',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.key),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Настройки
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Категория',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Тон',
                  value: _selectedTone,
                  items: _tones,
                  onChanged: (value) => setState(() => _selectedTone = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Длина',
                  value: _selectedLength,
                  items: _lengths,
                  onChanged: (value) => setState(() => _selectedLength = value!),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Кнопка генерации
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _generatePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Сгенерировать пост',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
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

  Widget _buildGenerationTab() {
    return _buildTabContent(
      title: 'Генерация постов',
      subtitle: 'Создавайте уникальный контент с помощью AI',
      children: [
        _buildGeneratedPostCard(
          title: 'Весенние тренды 2024: что носить этой весной',
          content: 'Весна 2024 приносит нам свежие идеи и вдохновение! 🌸\n\n'
              '✨ Основные тренды:\n'
              '• Пастельные тона с яркими акцентами\n'
              '• Экологичные материалы и sustainable fashion\n'
              '• Oversize силуэты и комфортные ткани\n'
              '• Минимализм с элементами maximalism\n\n'
              '💡 Как носить:\n'
              'Сочетайте легкие платья с объемными куртками, '
              'добавляйте яркие аксессуары к базовым образам. '
              'Не бойтесь экспериментировать с цветами!',
          hashtags: ['#весна2024', '#тренды', '#мода', '#стиль', '#fashion'],
          imageUrl: 'https://via.placeholder.com/300x200/FFB6C1/FFFFFF?text=Spring+Trends',
          likes: 234,
          comments: 45,
          shares: 12,
        ),
        _buildGeneratedPostCard(
          title: '5 способов обновить базовый гардероб',
          content: 'Хотите обновить свой стиль без больших затрат? '
              'Вот 5 проверенных способов! 💫\n\n'
              '1️⃣ Добавьте яркие аксессуары\n'
              '2️⃣ Поэкспериментируйте с layering\n'
              '3️⃣ Обновите обувь\n'
              '4️⃣ Добавьте statement piece\n'
              '5️⃣ Поиграйте с текстурами\n\n'
              'Помните: стиль - это самовыражение!',
          hashtags: ['#гардероб', '#стиль', '#мода', '#советы', '#fashion'],
          imageUrl: 'https://via.placeholder.com/300x200/87CEEB/FFFFFF?text=Wardrobe+Tips',
          likes: 189,
          comments: 32,
          shares: 8,
        ),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    return _buildTabContent(
      title: 'Шаблоны постов',
      subtitle: 'Готовые шаблоны для быстрого создания контента',
      children: [
        _buildTemplateCard(
          title: 'Обзор товара',
          description: 'Шаблон для обзора модных товаров',
          icon: Icons.shopping_bag,
          color: Colors.blue,
          template: '🔥 Новинка! {название товара}\n\n'
              '✨ Что особенного:\n'
              '• {особенность 1}\n'
              '• {особенность 2}\n'
              '• {особенность 3}\n\n'
              '💰 Цена: {цена}\n'
              '🛒 Где купить: {ссылка}\n\n'
              '💭 Ваше мнение?',
        ),
        _buildTemplateCard(
          title: 'Стилистический совет',
          description: 'Шаблон для стилистических рекомендаций',
          icon: Icons.style,
          color: Colors.purple,
          template: '💡 Стилистический совет дня\n\n'
              '🎯 Тема: {тема совета}\n\n'
              '📝 Описание:\n'
              '{описание совета}\n\n'
              '✅ Как применить:\n'
              '• {шаг 1}\n'
              '• {шаг 2}\n'
              '• {шаг 3}\n\n'
              '💭 Пробовали такой подход?',
        ),
        _buildTemplateCard(
          title: 'Тренд-анализ',
          description: 'Шаблон для анализа модных трендов',
          icon: Icons.trending_up,
          color: Colors.orange,
          template: '📈 Тренд-анализ: {название тренда}\n\n'
              '🔍 Что это:\n'
              '{описание тренда}\n\n'
              '📊 Популярность: {уровень популярности}\n'
              '⏰ Длительность: {время жизни тренда}\n\n'
              '💡 Как носить:\n'
              '{советы по носке}\n\n'
              '🤔 Ваше отношение к этому тренду?',
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return _buildTabContent(
      title: 'История генераций',
      subtitle: 'Ваши ранее созданные посты',
      children: [
        _buildHistoryCard(
          title: 'Весенние тренды 2024',
          date: '15 марта 2024',
          status: 'Опубликован',
          engagement: 'Высокое',
          color: Colors.green,
        ),
        _buildHistoryCard(
          title: '5 способов обновить гардероб',
          date: '12 марта 2024',
          status: 'Черновик',
          engagement: 'Среднее',
          color: Colors.orange,
        ),
        _buildHistoryCard(
          title: 'Обзор новой коллекции',
          date: '10 марта 2024',
          status: 'Опубликован',
          engagement: 'Высокое',
          color: Colors.green,
        ),
        _buildHistoryCard(
          title: 'Стилистические советы',
          date: '8 марта 2024',
          status: 'Архивирован',
          engagement: 'Низкое',
          color: Colors.grey,
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

  Widget _buildGeneratedPostCard({
    required String title,
    required String content,
    required List<String> hashtags,
    required String imageUrl,
    required int likes,
    required int comments,
    required int shares,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                
                // Хештеги
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: hashtags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
                
                const SizedBox(height: 20),
                
                // Статистика и кнопки
                Row(
                  children: [
                    _buildStatItem(Icons.favorite, likes.toString(), Colors.red),
                    const SizedBox(width: 20),
                    _buildStatItem(Icons.comment, comments.toString(), Colors.blue),
                    const SizedBox(width: 20),
                    _buildStatItem(Icons.share, shares.toString(), Colors.green),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Опубликовать пост
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Опубликовать'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Редактировать
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Редактировать'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String template,
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
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              template,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
                fontFamily: 'monospace',
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Использовать шаблон
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Использовать'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Настроить шаблон
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Настроить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String date,
    required String status,
    required String engagement,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(status),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                engagement,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Опубликован':
        return Icons.check_circle;
      case 'Черновик':
        return Icons.edit;
      case 'Архивирован':
        return Icons.archive;
      default:
        return Icons.info;
    }
  }

  void _generatePost() {
    setState(() {
      _isLoading = true;
    });
    
    // Имитация генерации поста
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
      
      // Показать результат
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пост успешно сгенерирован!'),
          backgroundColor: Colors.green,
        ),
      );
    });
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
