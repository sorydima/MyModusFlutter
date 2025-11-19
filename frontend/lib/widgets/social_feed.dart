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
  bool _isLoadingMore = false;

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
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll - 200;
    
    if (currentScroll >= threshold && !_isLoadingMore) {
      final appProvider = context.read<AppProvider>();
      final socialProvider = appProvider.socialProvider;
      
      // Проверяем, что есть еще данные для загрузки и не идет загрузка
      if (socialProvider.hasMorePosts && !socialProvider.isLoading) {
        setState(() {
          _isLoadingMore = true;
        });
        
        socialProvider.loadPosts().then((_) {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        });
      }
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
                      if (socialProvider.hasMorePosts && !_isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return null;
                    }
                    
                    final post = socialProvider.posts[index];
                    return RepaintBoundary(
                      child: PostCard(
                        key: ValueKey('post_${post.id}'),
                        post: post,
                      ),
                    );
                  },
                  childCount: socialProvider.posts.length + 
                      (socialProvider.hasMorePosts && !_isLoadingMore ? 1 : 0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
