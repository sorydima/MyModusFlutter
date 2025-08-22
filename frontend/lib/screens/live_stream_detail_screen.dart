import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_commerce_provider.dart';

class LiveStreamDetailScreen extends StatefulWidget {
  final String streamId;

  const LiveStreamDetailScreen({
    super.key,
    required this.streamId,
  });

  @override
  State<LiveStreamDetailScreen> createState() => _LiveStreamDetailScreenState();
}

class _LiveStreamDetailScreenState extends State<LiveStreamDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Загружаем данные стрима
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SocialCommerceProvider>();
      provider.getLiveStream(widget.streamId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialCommerceProvider>(
      builder: (context, provider, child) {
        final stream = provider.currentLiveStream;
        
        if (stream == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              stream['title'] ?? 'Live-стрим',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(_isFollowing ? Icons.person : Icons.person_add),
                onPressed: () {
                  setState(() {
                    _isFollowing = !_isFollowing;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFollowing ? 'Подписались!' : 'Отписались'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Реализовать шаринг
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Поделились!')),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Трансляция'),
                Tab(text: 'Товары'),
                Tab(text: 'Чат'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStreamTab(stream),
              _buildProductsTab(stream),
              _buildChatTab(stream),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreamTab(Map<String, dynamic> stream) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Видео плеер (заглушка)
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.live_tv,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Трансляция идет',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Информация о стриме
          Text(
            stream['title'] ?? 'Без названия',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stream['description'] ?? 'Без описания',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Статистика
          Row(
            children: [
              _buildStatItem(
                Icons.visibility,
                '${stream['viewers'] ?? 0}',
                'Зрители',
                Colors.blue,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                Icons.favorite,
                '${stream['likes'] ?? 0}',
                'Лайки',
                Colors.red,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                Icons.share,
                '${stream['shares'] ?? 0}',
                'Шары',
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Кнопки действий
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                  },
                  icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                  label: Text(_isLiked ? 'Лайкнуто' : 'Лайк'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLiked ? Colors.red : Colors.grey[300],
                    foregroundColor: _isLiked ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Реализовать покупку
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Переход к покупке')),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Купить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(Map<String, dynamic> stream) {
    final productIds = stream['productIds'] as List<dynamic>? ?? [];
    
    if (productIds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'В этом стриме нет товаров',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // TODO: Получить реальные товары по ID
    final mockProducts = [
      {
        'id': '1',
        'name': 'Стильное платье',
        'price': '5000 ₽',
        'image': 'https://via.placeholder.com/150',
        'description': 'Элегантное платье для особых случаев',
      },
      {
        'id': '2',
        'name': 'Джинсы классические',
        'price': '3000 ₽',
        'image': 'https://via.placeholder.com/150',
        'description': 'Универсальные джинсы на каждый день',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockProducts.length,
      itemBuilder: (context, index) {
        final product = mockProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['image']!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['description']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['price']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Реализовать покупку товара
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Покупка ${product['name']}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Купить'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatTab(Map<String, dynamic> stream) {
    // TODO: Получить реальные комментарии
    final mockComments = [
      {
        'user': 'Анна',
        'message': 'Отличный стрим!',
        'time': '2 мин назад',
        'avatar': 'https://via.placeholder.com/40',
      },
      {
        'user': 'Михаил',
        'message': 'Какой размер у платья?',
        'time': '1 мин назад',
        'avatar': 'https://via.placeholder.com/40',
      },
      {
        'user': 'Елена',
        'message': 'Сколько стоит доставка?',
        'time': '30 сек назад',
        'avatar': 'https://via.placeholder.com/40',
      },
    ];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mockComments.length,
            itemBuilder: (context, index) {
              final comment = mockComments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(comment['avatar']!),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Handle error
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment['user']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                comment['time']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(comment['message']!),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      onPressed: () {
                        // TODO: Лайк комментария
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Поле ввода комментария
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Написать комментарий...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    // TODO: Отправить комментарий
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Комментарий отправлен!')),
                    );
                    _commentController.clear();
                  }
                },
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
