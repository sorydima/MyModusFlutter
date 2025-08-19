import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final authProvider = appProvider.authProvider;
        final user = authProvider.user;
        
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Заголовок профиля
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(user),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // TODO: Навигация к настройкам
                      Navigator.pushNamed(context, '/settings');
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              
              // Статистика профиля
              SliverToBoxAdapter(
                child: _buildProfileStats(user),
              ),
              
              // Вкладки профиля
              SliverPersistentHeader(
                pinned: true,
                delegate: _ProfileTabsDelegate(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: TabBar(
                      onTap: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      tabs: const [
                        Tab(text: 'Посты'),
                        Tab(text: 'Избранное'),
                        Tab(text: 'Покупки'),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Содержимое вкладок
              _buildTabContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Аватар
            CircleAvatar(
              radius: 50,
              backgroundImage: user['avatar_url'] != null
                  ? CachedNetworkImageProvider(user['avatar_url'])
                  : null,
              child: user['avatar_url'] == null
                  ? Text(
                      (user['name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            
            // Имя пользователя
            Text(
              user['name'] ?? 'Пользователь',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            // Email
            if (user['email'] != null)
              Text(
                user['email'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            
            // Кнопка редактирования
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Навигация к редактированию профиля
                Navigator.pushNamed(context, '/edit-profile');
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Редактировать',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Посты',
            value: '${user['posts_count'] ?? 0}',
            icon: Icons.post_add,
          ),
          _StatItem(
            label: 'Подписчики',
            value: '${user['followers_count'] ?? 0}',
            icon: Icons.people,
          ),
          _StatItem(
            label: 'Подписки',
            value: '${user['following_count'] ?? 0}',
            icon: Icons.person_add,
          ),
          _StatItem(
            label: 'Покупки',
            value: '${user['purchases_count'] ?? 0}',
            icon: Icons.shopping_bag,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPostsTab();
      case 1:
        return _buildFavoritesTab();
      case 2:
        return _buildPurchasesTab();
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  Widget _buildPostsTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final socialProvider = appProvider.socialProvider;
        final posts = socialProvider.posts;
        
        if (posts.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.post_add,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'У вас пока нет постов',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Создайте свой первый пост!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = posts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: post['media']?.isNotEmpty == true
                      ? NetworkImage(post['media'][0])
                      : null,
                  child: post['media']?.isEmpty != false
                      ? const Icon(Icons.image)
                      : null,
                ),
                title: Text(post['caption'] ?? 'Без описания'),
                subtitle: Text(_formatDate(post['created_at'])),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: post['is_liked'] == true ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('${post['likes_count'] ?? 0}'),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.comment,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('${post['comments_count'] ?? 0}'),
                  ],
                ),
                onTap: () {
                  // TODO: Навигация к деталям поста
                },
              );
            },
            childCount: posts.length,
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    // TODO: Реализовать отображение избранных товаров
    return const SliverFillRemaining(
      child: Center(
        child: Text('Избранное в разработке'),
      ),
    );
  }

  Widget _buildPurchasesTab() {
    // TODO: Реализовать отображение истории покупок
    return const SliverFillRemaining(
      child: Center(
        child: Text('История покупок в разработке'),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Недавно';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}д назад';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}ч назад';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}м назад';
      } else {
        return 'Только что';
      }
    } catch (e) {
      return 'Недавно';
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ProfileTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ProfileTabsDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
