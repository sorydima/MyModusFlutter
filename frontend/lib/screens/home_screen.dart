import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/story_widget.dart';
import '../widgets/category_list.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'feed_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // App Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Логотип
                Text(
                  'MyModus',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                // Поиск
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Уведомления
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Корзина
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stories
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                StoryWidget(
                  username: 'Ваша история',
                  imageUrl: 'https://via.placeholder.com/60x60/6750A4/FFFFFF?text=+',
                  isViewed: false,
                ),
                StoryWidget(
                  username: 'Nike',
                  imageUrl: 'https://via.placeholder.com/60x60/FF6B6B/FFFFFF?text=N',
                  isViewed: false,
                ),
                StoryWidget(
                  username: 'Adidas',
                  imageUrl: 'https://via.placeholder.com/60x60/4ECDC4/FFFFFF?text=A',
                  isViewed: true,
                ),
                StoryWidget(
                  username: 'Levi\'s',
                  imageUrl: 'https://via.placeholder.com/60x60/45B7D1/FFFFFF?text=L',
                  isViewed: false,
                ),
                StoryWidget(
                  username: 'Apple',
                  imageUrl: 'https://via.placeholder.com/60x60/96CEB4/FFFFFF?text=A',
                  isViewed: true,
                ),
                StoryWidget(
                  username: 'Samsung',
                  imageUrl: 'https://via.placeholder.com/60x60/FFE66D/000000?text=S',
                  isViewed: false,
                ),
              ],
            ),
          ),

          // Категории
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const CategoryList(),
          ),

          // Табы категорий
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              tabs: const [
                Tab(text: 'Все'),
                Tab(text: 'Обувь'),
                Tab(text: 'Одежда'),
                Tab(text: 'Аксессуары'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Сетка товаров
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ProductGrid(categoryIndex: 0),
                ProductGrid(categoryIndex: 1),
                ProductGrid(categoryIndex: 2),
                ProductGrid(categoryIndex: 3),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          if (index == 1) {
            // Лента
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FeedScreen(),
              ),
            );
          } else if (index == 2) {
            // Корзина
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            );
          } else if (index == 3) {
            // Профиль
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.feed_outlined),
            selectedIcon: Icon(Icons.feed),
            label: 'Лента',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
