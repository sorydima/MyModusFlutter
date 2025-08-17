import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';

class AIStylistScreen extends StatefulWidget {
  const AIStylistScreen({super.key});

  @override
  State<AIStylistScreen> createState() => _AIStylistScreenState();
}

class _AIStylistScreenState extends State<AIStylistScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _selectedStyle = 'Casual';
  String _selectedSeason = 'Spring';
  String _selectedOccasion = 'Daily';

  final List<String> _styles = ['Casual', 'Business', 'Sporty', 'Elegant', 'Street', 'Vintage'];
  final List<String> _seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
  final List<String> _occasions = ['Daily', 'Work', 'Party', 'Date', 'Travel', 'Sport'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('AI Стилист'),
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
          // Фильтры стиля
          _buildStyleFilters(),
          
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
                Tab(text: 'Образы'),
                Tab(text: 'Комбинации'),
                Tab(text: 'Советы'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOutfitsTab(),
                _buildCombinationsTab(),
                _buildTipsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleFilters() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Стиль
          Row(
            children: [
              Text(
                'Стиль:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _styles.map((style) => _buildFilterChip(
                      label: style,
                      isSelected: _selectedStyle == style,
                      onTap: () => setState(() => _selectedStyle = style),
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Сезон и повод
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сезон:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _seasons.map((season) => _buildFilterChip(
                          label: season,
                          isSelected: _selectedSeason == season,
                          onTap: () => setState(() => _selectedSeason = season),
                          isSmall: true,
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Повод:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _occasions.map((occasion) => _buildFilterChip(
                          label: occasion,
                          isSelected: _selectedOccasion == occasion,
                          onTap: () => setState(() => _selectedOccasion = occasion),
                          isSmall: true,
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: isSmall ? 12 : 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitsTab() {
    return _buildTabContent(
      title: 'Готовые образы',
      subtitle: 'AI подобрал для вас идеальные комбинации',
      children: [
        _buildOutfitCard(
          name: 'Casual Spring Look',
          description: 'Легкий и стильный образ для весенних прогулок',
          items: ['Джинсы Levi\'s 501', 'Белая футболка', 'Джинсовая куртка', 'Кроссовки Nike'],
          confidence: 0.94,
          price: '25,400 ₽',
          imageUrl: 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Spring+Look',
        ),
        _buildOutfitCard(
          name: 'Business Elegance',
          description: 'Деловой образ для важных встреч',
          items: ['Костюм Hugo Boss', 'Белая рубашка', 'Галстук Hermès', 'Туфли Oxford'],
          confidence: 0.91,
          price: '89,500 ₽',
          imageUrl: 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Business+Look',
        ),
        _buildOutfitCard(
          name: 'Weekend Street Style',
          description: 'Уличный стиль для выходных',
          items: ['Худи Champion', 'Брюки-карго', 'Кеды Converse', 'Бейсболка New Era'],
          confidence: 0.88,
          price: '18,200 ₽',
          imageUrl: 'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Street+Look',
        ),
      ],
    );
  }

  Widget _buildCombinationsTab() {
    return _buildTabContent(
      title: 'Комбинации вещей',
      subtitle: 'Создайте свой уникальный стиль',
      children: [
        _buildCombinationCard(
          title: 'Верх',
          items: [
            {'name': 'Футболка Nike', 'price': '3,200 ₽', 'color': 'Белый'},
            {'name': 'Рубашка Zara', 'price': '4,500 ₽', 'color': 'Голубой'},
            {'name': 'Свитер H&M', 'price': '5,800 ₽', 'color': 'Серый'},
          ],
        ),
        _buildCombinationCard(
          title: 'Низ',
          items: [
            {'name': 'Джинсы Levi\'s', 'price': '8,900 ₽', 'color': 'Синий'},
            {'name': 'Брюки Uniqlo', 'price': '6,500 ₽', 'color': 'Черный'},
            {'name': 'Шорты Adidas', 'price': '4,200 ₽', 'color': 'Черный'},
          ],
        ),
        _buildCombinationCard(
          title: 'Обувь',
          items: [
            {'name': 'Кроссовки Nike', 'price': '12,500 ₽', 'color': 'Белый'},
            {'name': 'Кеды Converse', 'price': '8,900 ₽', 'color': 'Белый'},
            {'name': 'Туфли Clarks', 'price': '15,800 ₽', 'color': 'Коричневый'},
          ],
        ),
      ],
    );
  }

  Widget _buildTipsTab() {
    return _buildTabContent(
      title: 'Стилистические советы',
      subtitle: 'AI рекомендации по стилю',
      children: [
        _buildTipCard(
          title: 'Цветовые сочетания',
          content: 'Для весеннего сезона рекомендуем сочетать пастельные тона с яркими акцентами. Попробуйте комбинацию бежевого с мятным или лавандовым.',
          icon: Icons.palette,
          color: Colors.purple,
        ),
        _buildTipCard(
          title: 'Пропорции фигуры',
          content: 'Если у вас длинные ноги, носите укороченные топы. Для уравновешивания пропорций используйте объемные верхние части с облегающими низом.',
          icon: Icons.accessibility,
          color: Colors.blue,
        ),
        _buildTipCard(
          title: 'Ткани и фактуры',
          content: 'Весной отдавайте предпочтение легким натуральным тканям: хлопок, лен, шелк. Комбинируйте гладкие и фактурные материалы для создания глубины.',
          icon: Icons.texture,
          color: Colors.green,
        ),
        _buildTipCard(
          title: 'Аксессуары',
          content: 'Не перегружайте образ аксессуарами. Выберите 2-3 ключевых элемента: часы, сумку и украшение. Следите за цветовой гармонией.',
          icon: Icons.watch,
          color: Colors.orange,
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

  Widget _buildOutfitCard({
    required String name,
    required String description,
    required List<String> items,
    required double confidence,
    required String price,
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
                // Заголовок и уверенность
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(confidence * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                
                const SizedBox(height: 16),
                
                // Список вещей
                Text(
                  'Состав образа:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
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
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 16),
                
                // Цена и кнопки
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Добавить в корзину
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Добавить'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Сохранить образ
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Сохранить'),
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

  Widget _buildCombinationCard({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getColorFromName(item['color']!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Цвет: ${item['color']}',
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
                    Text(
                      item['price']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {
                        // TODO: Добавить в корзину
                      },
                      child: const Text('Добавить'),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required String title,
    required String content,
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
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'белый':
        return Colors.white;
      case 'черный':
        return Colors.black;
      case 'синий':
        return Colors.blue;
      case 'красный':
        return Colors.red;
      case 'зеленый':
        return Colors.green;
      case 'желтый':
        return Colors.yellow;
      case 'оранжевый':
        return Colors.orange;
      case 'фиолетовый':
        return Colors.purple;
      case 'розовый':
        return Colors.pink;
      case 'коричневый':
        return Colors.brown;
      case 'серый':
        return Colors.grey;
      case 'голубой':
        return Colors.lightBlue;
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
