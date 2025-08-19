import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final user = post['user'] ?? {};
    final media = post['media'] ?? [];
    final hashtags = post['hashtags'] ?? [];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок поста с аватаром пользователя
          ListTile(
            leading: CircleAvatar(
              backgroundImage: user['avatar_url'] != null
                  ? CachedNetworkImageProvider(user['avatar_url'])
                  : null,
              child: user['avatar_url'] == null
                  ? Text(
                      (user['name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  : null,
            ),
            title: Text(
              user['name'] ?? 'Пользователь',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _formatDate(post['created_at']),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                _handlePostAction(context, value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Поделиться'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report),
                      SizedBox(width: 8),
                      Text('Пожаловаться'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Текст поста
          if (post['caption']?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                post['caption'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          
          // Хештеги
          if (hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: hashtags.map<Widget>((tag) {
                  return GestureDetector(
                    onTap: () {
                      // TODO: Навигация к постам с этим хештегом
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          // Медиа контент
          if (media.isNotEmpty) _buildMediaContent(context, media),
          
          // Действия с постом
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _ActionButton(
                  icon: post['is_liked'] == true 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  label: '${post['likes_count'] ?? 0}',
                  color: post['is_liked'] == true 
                      ? Colors.red 
                      : null,
                  onTap: () => _handleLike(context),
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post['comments_count'] ?? 0}',
                  onTap: () => _handleComment(context),
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Поделиться',
                  onTap: () => _handleShare(context),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _handleBookmark(context),
                  icon: Icon(
                    post['is_bookmarked'] == true 
                        ? Icons.bookmark 
                        : Icons.bookmark_border,
                    color: post['is_bookmarked'] == true 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context, List media) {
    if (media.length == 1) {
      // Одно изображение
      return Container(
        width: double.infinity,
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: media[0],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade300,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.error),
            ),
          ),
        ),
      );
    } else if (media.length > 1) {
      // Несколько изображений в сетке
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: media.length == 2 ? 2 : 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: media.length > 6 ? 6 : media.length,
          itemBuilder: (context, index) {
            if (index == 5 && media.length > 6) {
              // Показываем счетчик дополнительных изображений
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: media[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '+${media.length - 6}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: media[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  void _handlePostAction(BuildContext context, String action) {
    switch (action) {
      case 'share':
        _handleShare(context);
        break;
      case 'report':
        _handleReport(context);
        break;
    }
  }

  void _handleLike(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final socialProvider = appProvider.socialProvider;
    
    if (post['is_liked'] == true) {
      socialProvider.unlikePost(post['id']);
    } else {
      socialProvider.likePost(post['id']);
    }
  }

  void _handleComment(BuildContext context) {
    // TODO: Навигация к экрану комментариев
    Navigator.pushNamed(
      context, 
      '/post-comments',
      arguments: post['id'],
    );
  }

  void _handleShare(BuildContext context) {
    // TODO: Реализовать шаринг поста
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция шаринга в разработке')),
    );
  }

  void _handleBookmark(BuildContext context) {
    // TODO: Реализовать добавление в закладки
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция закладок в разработке')),
    );
  }

  void _handleReport(BuildContext context) {
    // TODO: Реализовать жалобу на пост
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция жалоб в разработке')),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
