import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_commerce_provider.dart';
import '../widgets/social_commerce_card.dart';
import 'create_live_stream_screen.dart';
import 'live_stream_detail_screen.dart';

class SocialCommerceScreen extends StatefulWidget {
  const SocialCommerceScreen({super.key});

  @override
  State<SocialCommerceScreen> createState() => _SocialCommerceScreenState();
}

class _SocialCommerceScreenState extends State<SocialCommerceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Загружаем данные при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SocialCommerceProvider>();
      provider.getLiveStreams();
      provider.getGroupPurchases();
      provider.getReviews();
      provider.getPartnerships();
      provider.getSocialPlatforms();
    });
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
        title: const Text(
          '🌟 Социальная коммерция',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.live_tv), text: 'Live-стримы'),
            Tab(icon: Icon(Icons.group), text: 'Групповые покупки'),
            Tab(icon: Icon(Icons.star), text: 'Отзывы'),
            Tab(icon: Icon(Icons.handshake), text: 'Партнерства'),
            Tab(icon: Icon(Icons.analytics), text: 'Аналитика'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LiveStreamsTab(),
          GroupPurchasesTab(),
          ReviewsTab(),
          PartnershipsTab(),
          AnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptions(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Создать новый элемент',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.live_tv, color: Colors.red),
              title: const Text('Live-стрим'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateLiveStreamScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.blue),
              title: const Text('Групповую покупку'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
                // TODO: Показать форму создания групповой покупки
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.orange),
              title: const Text('Отзыв'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
                // TODO: Показать форму создания отзыва
              },
            ),
            ListTile(
              leading: const Icon(Icons.handshake, color: Colors.green),
              title: const Text('Партнерство'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(3);
                // TODO: Показать форму создания партнерства
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Live Streams Tab
class LiveStreamsTab extends StatelessWidget {
  const LiveStreamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialCommerceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingLiveStreams) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.liveStreamError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Ошибка: ${provider.liveStreamError}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.getLiveStreams(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (provider.liveStreams.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.live_tv, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Пока нет live-стримов',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Создайте первый стрим!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.getLiveStreams(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.liveStreams.length,
            itemBuilder: (context, index) {
              final stream = provider.liveStreams[index];
              return SocialCommerceCard(
                title: stream['title'] ?? 'Без названия',
                subtitle: stream['description'] ?? 'Без описания',
                status: stream['status'] ?? 'unknown',
                stats: {
                  'viewers': stream['viewers'] ?? 0,
                  'likes': stream['likes'] ?? 0,
                  'shares': stream['shares'] ?? 0,
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveStreamDetailScreen(
                        streamId: stream['id'] ?? 'unknown',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Group Purchases Tab
class GroupPurchasesTab extends StatelessWidget {
  const GroupPurchasesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialCommerceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingGroupPurchases) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.groupPurchaseError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Ошибка: ${provider.groupPurchaseError}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.getGroupPurchases(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (provider.groupPurchases.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Пока нет групповых покупок',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Создайте первую групповую покупку!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.getGroupPurchases(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.groupPurchases.length,
            itemBuilder: (context, index) {
              final group = provider.groupPurchases[index];
              return SocialCommerceCard(
                title: 'Групповая покупка',
                subtitle: group['description'] ?? 'Без описания',
                status: group['status'] ?? 'unknown',
                stats: {
                  'participants': group['currentParticipants'] ?? 0,
                  'min_participants': group['minParticipants'] ?? 0,
                  'discount': group['discountPercent'] ?? 0,
                },
                onTap: () {
                  // TODO: Открыть детальный экран групповой покупки
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Reviews Tab
class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialCommerceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingReviews) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.reviewError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Ошибка: ${provider.reviewError}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.getReviews(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (provider.reviews.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Пока нет отзывов',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Оставьте первый отзыв!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.getReviews(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.reviews.length,
            itemBuilder: (context, index) {
              final review = provider.reviews[index];
              return SocialCommerceCard(
                title: 'Отзыв',
                subtitle: review['comment'] ?? 'Без комментария',
                status: 'review',
                stats: {
                  'rating': review['rating'] ?? 0,
                  'likes': review['likes'] ?? 0,
                  'dislikes': review['dislikes'] ?? 0,
                },
                onTap: () {
                  // TODO: Открыть детальный экран отзыва
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Partnerships Tab
class PartnershipsTab extends StatelessWidget {
  const PartnershipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialCommerceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingPartnerships) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.partnershipError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Ошибка: ${provider.partnershipError}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.getPartnerships(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (provider.partnerships.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.handshake, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Пока нет партнерств',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Создайте первое партнерство!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.getPartnerships(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.partnerships.length,
            itemBuilder: (context, index) {
              final partnership = provider.partnerships[index];
              return SocialCommerceCard(
                title: 'Партнерство',
                subtitle: partnership['description'] ?? 'Без описания',
                status: partnership['status'] ?? 'unknown',
                stats: {
                  'commission': partnership['commission'] ?? 0,
                  'start_date': partnership['startDate'] ?? '',
                  'end_date': partnership['endDate'] ?? '',
                },
                onTap: () {
                  // TODO: Открыть детальный экран партнерства
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Analytics Tab
class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialCommerceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingAnalytics) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.analyticsError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Ошибка: ${provider.analyticsError}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.getSocialCommerceAnalytics(
                    userId: 'current_user', // TODO: Получить реальный ID пользователя
                  ),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (provider.analytics == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Аналитика недоступна',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Загрузите данные для просмотра',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.getSocialCommerceAnalytics(
                    userId: 'current_user', // TODO: Получить реальный ID пользователя
                  ),
                  child: const Text('Загрузить аналитику'),
                ),
              ],
            ),
          );
        }

        final analytics = provider.analytics!;
        return RefreshIndicator(
          onRefresh: () => provider.getSocialCommerceAnalytics(
            userId: 'current_user', // TODO: Получить реальный ID пользователя
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAnalyticsCard(
                'Общая статистика',
                [
                  {'label': 'Просмотры', 'value': analytics['totalViews'] ?? 0},
                  {'label': 'Лайки', 'value': analytics['totalLikes'] ?? 0},
                  {'label': 'Шары', 'value': analytics['totalShares'] ?? 0},
                  {'label': 'Покупки', 'value': analytics['totalPurchases'] ?? 0},
                ],
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard(
                'Показатели эффективности',
                [
                  {'label': 'Вовлеченность', 'value': '${analytics['engagementRate']?.toStringAsFixed(1) ?? 0}%'},
                  {'label': 'Конверсия', 'value': '${analytics['conversionRate']?.toStringAsFixed(1) ?? 0}%'},
                ],
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildTopProductsCard(analytics['topProducts'] ?? []),
              const SizedBox(height: 16),
              _buildTopCategoriesCard(analytics['topCategories'] ?? []),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(String title, List<Map<String, dynamic>> data, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            ...data.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    item['value'].toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsCard(List<dynamic> products) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Топ товары',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            ...products.take(5).map((product) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product['name'] ?? 'Неизвестный товар',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    '${product['views']} просмотров',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategoriesCard(List<dynamic> categories) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Топ категории',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.take(5).map((category) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category['name'] ?? 'Неизвестная категория',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${category['sales']} продаж',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
