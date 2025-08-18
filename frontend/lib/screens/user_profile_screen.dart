import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  
  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  bool _isLoading = false;

  // Тестовые данные пользователя
  final Map<String, dynamic> _userData = {
    'id': '1',
    'name': 'Fashionista',
    'username': '@fashionista',
    'avatar': 'https://via.placeholder.com/100x100/FF6B6B/FFFFFF?text=F',
    'bio': 'Fashion blogger | Style enthusiast | Love creating unique looks',
    'verified': true,
    'posts': 156,
    'followers': 12470,
    'following': 892,
    'isPrivate': false,
  };

  // Тестовые посты пользователя
  final List<Map<String, dynamic>> _userPosts = [
    {
      'id': '1',
      'image': 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=Post+1',
      'likes': 1247,
      'comments': 89,
    },
    {
      'id': '2',
      'image': 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=Post+2',
      'likes': 892,
      'comments': 45,
    },
    {
      'id': '3',
      'image': 'https://via.placeholder.com/300x300/96CEB4/FFFFFF?text=Post+3',
      'likes': 2156,
      'comments': 156,
    },
    {
      'id': '4',
      'image': 'https://via.placeholder.com/300x300/FFEAA7/FFFFFF?text=Post+4',
      'likes': 567,
      'comments': 23,
    },
    {
      'id': '5',
      'image': 'https://via.placeholder.com/300x300/DDA0DD/FFFFFF?text=Post+5',
      'likes': 1342,
      'comments': 78,
    },
    {
      'id': '6',
      'image': 'https://via.placeholder.com/300x300/98D8C8/FFFFFF?text=Post+6',
      'likes': 789,
      'comments': 34,
    },
  ];

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

  Future<void> _toggleFollow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Реализовать API вызов для подписки/отписки
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isFollowing = !_isFollowing;
        if (_isFollowing) {
          _userData['followers'] = (_userData['followers'] as int) + 1;
        } else {
          _userData['followers'] = (_userData['followers'] as int) - 1;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFollowers() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFollowersModal(),
    );
  }

  void _showFollowing() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFollowingModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreOptions(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(),
            ),
          ),

          // Profile Info
          SliverToBoxAdapter(
            child: _buildProfileInfo(),
          ),

          // Stats
          SliverToBoxAdapter(
            child: _buildStats(),
          ),

          // Action Buttons
          SliverToBoxAdapter(
            child: _buildActionButtons(),
          ),

          // Bio
          SliverToBoxAdapter(
            child: _buildBio(),
          ),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on), text: 'Посты'),
                  Tab(icon: Icon(Icons.bookmark_border), text: 'Сохраненные'),
                  Tab(icon: Icon(Icons.favorite_border), text: 'Лайки'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsTab(),
                _buildSavedTab(),
                _buildLikedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 45,
            backgroundImage: CachedNetworkImageProvider(_userData['avatar']),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _userData['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_userData['verified'])
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      _userData['username'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showFollowers,
              child: Column(
                children: [
                  Text(
                    '${_userData['posts']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Постов'),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showFollowers,
              child: Column(
                children: [
                  Text(
                    '${_userData['followers']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Подписчиков'),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showFollowing,
              child: Column(
                children: [
                  Text(
                    '${_userData['following']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Подписок'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: _isFollowing
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onPrimary,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isFollowing ? 'Отписаться' : 'Подписаться'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _sendMessage(),
              child: const Text('Сообщение'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _userData['bio'],
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPostsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return GestureDetector(
          onTap: () => _openPost(post),
          child: Stack(
            children: [
              Image.network(
                post['image'],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedTab() {
    return const Center(
      child: Text('Сохраненные посты'),
    );
  }

  Widget _buildLikedTab() {
    return const Center(
      child: Text('Лайки'),
    );
  }

  Widget _buildFollowersModal() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Подписчики',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      'https://via.placeholder.com/40x40/FF6B6B/FFFFFF?text=U$index',
                    ),
                  ),
                  title: Text('User $index'),
                  subtitle: Text('@user$index'),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Подписаться'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingModal() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Подписки',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      'https://via.placeholder.com/40x40/4ECDC4/FFFFFF?text=U$index',
                    ),
                  ),
                  title: Text('User $index'),
                  subtitle: Text('@user$index'),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Отписаться'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Пожаловаться'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Реализовать жалобу
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Заблокировать'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Реализовать блокировку
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    // TODO: Реализовать отправку сообщения
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция сообщений в разработке')),
    );
  }

  void _openPost(Map<String, dynamic> post) {
    // TODO: Реализовать открытие поста
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Открытие поста ${post['id']}')),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    SliverConstraints constraints,
    Widget child,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
