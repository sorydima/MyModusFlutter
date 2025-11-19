import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Тестовые данные постов - используем List для возможности обновления
  late List<Map<String, dynamic>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = [
      {
        'id': '1',
        'user': {
          'name': 'Fashionista',
          'avatar': 'https://via.placeholder.com/50x50/FF6B6B/FFFFFF?text=F',
          'verified': true,
        },
        'image': 'https://via.placeholder.com/400x500/FF6B6B/FFFFFF?text=Fashion+Post+1',
        'caption': '🔥 Новый образ для весны! Как вам этот look? #мода #стиль #весна',
        'likes': 1247,
        'comments': 89,
        'timeAgo': '2 часа назад',
        'isLiked': false,
        'isSaved': false,
        'products': [
          {
            'id': '1',
            'title': 'Nike Air Max 270',
            'price': 12990,
            'imageUrl': 'https://via.placeholder.com/80x80/FF6B6B/FFFFFF?text=Nike',
          },
        ],
      },
      {
        'id': '2',
        'user': {
          'name': 'Style Guru',
          'avatar': 'https://via.placeholder.com/50x50/4ECDC4/FFFFFF?text=S',
          'verified': false,
        },
        'image': 'https://via.placeholder.com/400x500/4ECDC4/FFFFFF?text=Fashion+Post+2',
        'caption': '💫 Минимализм в моде! Простые линии и качественные материалы всегда в тренде #минимализм #стиль',
        'likes': 892,
        'comments': 45,
        'timeAgo': '5 часов назад',
        'isLiked': true,
        'isSaved': true,
        'products': [
          {
            'id': '3',
            'title': 'Levi\'s 501 Jeans',
            'price': 7990,
            'imageUrl': 'https://via.placeholder.com/80x80/45B7D1/FFFFFF?text=Levis',
          },
          {
            'id': '6',
            'title': 'Converse Chuck',
            'price': 5990,
            'imageUrl': 'https://via.placeholder.com/80x80/FF6B9D/FFFFFF?text=Converse',
          },
        ],
      },
      {
        'id': '3',
        'user': {
          'name': 'Trend Setter',
          'avatar': 'https://via.placeholder.com/50x50/96CEB4/FFFFFF?text=T',
          'verified': true,
        },
        'image': 'https://via.placeholder.com/400x500/96CEB4/FFFFFF?text=Fashion+Post+3',
        'caption': '🌟 Вечерний выход! Какой образ выберете для вечеринки? #вечер #гламур #стиль',
        'likes': 2156,
        'comments': 156,
        'timeAgo': '1 день назад',
        'isLiked': false,
        'isSaved': false,
        'products': [
          {
            'id': '4',
            'title': 'Apple Watch Series 8',
            'price': 45990,
            'imageUrl': 'https://via.placeholder.com/80x80/96CEB4/FFFFFF?text=Apple',
          },
        ],
      },
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleLike(int index) {
    setState(() {
      final post = _posts[index];
      post['isLiked'] = !post['isLiked'];
      if (post['isLiked']) {
        post['likes'] = (post['likes'] as int) + 1;
      } else {
        post['likes'] = (post['likes'] as int) - 1;
      }
    });
  }

  void _toggleSave(int index) {
    setState(() {
      _posts[index]['isSaved'] = !_posts[index]['isSaved'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        cacheExtent: 500,
        slivers: [
          // App Bar
          SliverAppBar(
            title: const Text(
              'Лента',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            pinned: true,
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Navigate to create post
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // TODO: Navigate to messages
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          
          // Посты
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildPostCard(_posts[index], index);
              },
              childCount: _posts.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    return RepaintBoundary(
      child: Container(
        key: ValueKey('post_${post['id']}'),
        margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок поста
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Аватар пользователя
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: post['user']['verified'] 
                          ? Colors.blue 
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: post['user']['avatar'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Информация о пользователе
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post['user']['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (post['user']['verified']) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        post['timeAgo'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Кнопка меню
                IconButton(
                  onPressed: () {
                    // TODO: Show post menu
                  },
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Изображение поста
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: post['image'],
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: double.infinity,
                  height: 400,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 400,
                color: Colors.grey.shade300,
                child: const Icon(Icons.error, size: 50),
              ),
            ),
          ),
          
          // Действия с постом
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Кнопки действий
                Row(
                  children: [
                    // Лайк
                    GestureDetector(
                      onTap: () => _toggleLike(index),
                      child: Icon(
                        post['isLiked'] 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                        size: 28,
                        color: post['isLiked'] 
                            ? Colors.red 
                            : Colors.grey.shade600,
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Комментарий
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 28,
                      color: Colors.grey.shade600,
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Поделиться
                    Icon(
                      Icons.send_outlined,
                      size: 28,
                      color: Colors.grey.shade600,
                    ),
                    
                    const Spacer(),
                    
                    // Сохранить
                    GestureDetector(
                      onTap: () => _toggleSave(index),
                      child: Icon(
                        post['isSaved'] 
                            ? Icons.bookmark 
                            : Icons.bookmark_border,
                        size: 28,
                        color: post['isSaved'] 
                            ? Colors.amber 
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Количество лайков
                Text(
                  '${post['likes']} лайков',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Подпись к посту
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${post['user']['name']} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: post['caption'],
                        style: TextStyle(
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Комментарии
                Text(
                  'Посмотреть все ${post['comments']} комментариев',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Связанные товары
                if (post['products'] != null && (post['products'] as List).isNotEmpty) ...[
                  Text(
                    'Товары в посте:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (post['products'] as List).length,
                      itemBuilder: (context, productIndex) {
                        final product = (post['products'] as List)[productIndex];
                        return Container(
                          key: ValueKey('product_${product['id']}_$productIndex'),
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product['imageUrl'],
                                  width: 80,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 80,
                                      height: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(product['price'] / 1000).toStringAsFixed(1)}k ₽',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
