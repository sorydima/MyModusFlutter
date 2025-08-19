import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'post_card.dart';

class SocialFeed extends StatefulWidget {
  const SocialFeed({super.key});

  @override
  State<SocialFeed> createState() => _SocialFeedState();
}

class _SocialFeedState extends State<SocialFeed> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Загружаем посты при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
    
    // Добавляем слушатель скролла для пагинации
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.socialProvider.loadPosts(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Загружаем следующую страницу
      final appProvider = context.read<AppProvider>();
      appProvider.socialProvider.loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final socialProvider = appProvider.socialProvider;
        
        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Заголовок
              SliverAppBar(
                floating: true,
                title: const Text(
                  'Лента',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // TODO: Навигация к экрану создания поста
                      Navigator.pushNamed(context, '/create-post');
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              
              // Список постов
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == socialProvider.posts.length) {
                      // Показываем индикатор загрузки для следующей страницы
                      if (socialProvider.hasMorePosts) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return null;
                    }
                    
                    final post = socialProvider.posts[index];
                    return PostCard(post: post);
                  },
                  childCount: socialProvider.posts.length + 
                      (socialProvider.hasMorePosts ? 1 : 0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
