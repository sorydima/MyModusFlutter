import 'package:flutter/material.dart';

class SocialCommerceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Map<String, dynamic> stats;
  final VoidCallback? onTap;
  final String? imageUrl;
  final List<String>? tags;

  const SocialCommerceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.stats,
    this.onTap,
    this.imageUrl,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(status),
                ],
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Image if available
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Tags if available
              if (tags != null && tags!.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tags!.map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[50],
                    side: BorderSide(color: Colors.blue[200]!),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Stats
              _buildStatsRow(),
              
              // Action buttons
              const SizedBox(height: 12),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'live':
        color = Colors.red;
        label = 'LIVE';
        icon = Icons.live_tv;
        break;
      case 'scheduled':
        color = Colors.blue;
        label = 'Запланирован';
        icon = Icons.schedule;
        break;
      case 'ended':
        color = Colors.grey;
        label = 'Завершен';
        icon = Icons.stop_circle;
        break;
      case 'active':
        color = Colors.green;
        label = 'Активна';
        icon = Icons.check_circle;
        break;
      case 'completed':
        color = Colors.purple;
        label = 'Завершена';
        icon = Icons.done_all;
        break;
      case 'cancelled':
        color = Colors.orange;
        label = 'Отменена';
        icon = Icons.cancel;
        break;
      case 'pending':
        color = Colors.amber;
        label = 'Ожидает';
        icon = Icons.pending;
        break;
      case 'review':
        color = Colors.indigo;
        label = 'Отзыв';
        icon = Icons.star;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: stats.entries.map((entry) {
        String label = _getStatLabel(entry.key);
        dynamic value = entry.value;
        
        return Expanded(
          child: Column(
            children: [
              Text(
                _formatStatValue(value),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getStatLabel(String key) {
    switch (key) {
      case 'viewers':
        return 'Зрители';
      case 'likes':
        return 'Лайки';
      case 'shares':
        return 'Шары';
      case 'participants':
        return 'Участники';
      case 'min_participants':
        return 'Мин. участников';
      case 'discount':
        return 'Скидка';
      case 'rating':
        return 'Рейтинг';
      case 'dislikes':
        return 'Дизлайки';
      case 'commission':
        return 'Комиссия';
      case 'start_date':
        return 'Начало';
      case 'end_date':
        return 'Конец';
      default:
        return key;
    }
  }

  String _formatStatValue(dynamic value) {
    if (value is num) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      } else {
        return value.toString();
      }
    } else if (value is String) {
      // Try to parse date
      try {
        final date = DateTime.parse(value);
        return '${date.day}.${date.month}';
      } catch (e) {
        return value;
      }
    }
    return value.toString();
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.visibility,
          label: 'Просмотр',
          onTap: () {},
          color: Colors.blue,
        ),
        _buildActionButton(
          icon: Icons.share,
          label: 'Поделиться',
          onTap: () {},
          color: Colors.green,
        ),
        _buildActionButton(
          icon: Icons.favorite_border,
          label: 'В избранное',
          onTap: () {},
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Специализированные карточки для разных типов контента

class LiveStreamCard extends StatelessWidget {
  final Map<String, dynamic> stream;
  final VoidCallback? onTap;

  const LiveStreamCard({
    super.key,
    required this.stream,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SocialCommerceCard(
      title: stream['title'] ?? 'Без названия',
      subtitle: stream['description'] ?? 'Без описания',
      status: stream['status'] ?? 'unknown',
      stats: {
        'viewers': stream['viewers'] ?? 0,
        'likes': stream['likes'] ?? 0,
        'shares': stream['shares'] ?? 0,
      },
      imageUrl: stream['thumbnailUrl'],
      onTap: onTap,
    );
  }
}

class GroupPurchaseCard extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback? onTap;

  const GroupPurchaseCard({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SocialCommerceCard(
      title: 'Групповая покупка',
      subtitle: group['description'] ?? 'Без описания',
      status: group['status'] ?? 'unknown',
      stats: {
        'participants': group['currentParticipants'] ?? 0,
        'min_participants': group['minParticipants'] ?? 0,
        'discount': group['discountPercent'] ?? 0,
      },
      onTap: onTap,
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback? onTap;

  const ReviewCard({
    super.key,
    required this.review,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SocialCommerceCard(
      title: 'Отзыв',
      subtitle: review['comment'] ?? 'Без комментария',
      status: 'review',
      stats: {
        'rating': review['rating'] ?? 0,
        'likes': review['likes'] ?? 0,
        'dislikes': review['dislikes'] ?? 0,
      },
      imageUrl: review['photos']?.isNotEmpty == true ? review['photos'][0] : null,
      onTap: onTap,
    );
  }
}

class PartnershipCard extends StatelessWidget {
  final Map<String, dynamic> partnership;
  final VoidCallback? onTap;

  const PartnershipCard({
    super.key,
    required this.partnership,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SocialCommerceCard(
      title: 'Партнерство',
      subtitle: partnership['description'] ?? 'Без описания',
      status: partnership['status'] ?? 'unknown',
      stats: {
        'commission': partnership['commission'] ?? 0,
        'start_date': partnership['startDate'] ?? '',
        'end_date': partnership['endDate'] ?? '',
      },
      onTap: onTap,
    );
  }
}
