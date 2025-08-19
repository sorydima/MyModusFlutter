import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  String _searchQuery = '';
  int _selectedTabIndex = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    
    if (_searchQuery.isNotEmpty) {
      _performSearch();
    }
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });
    
    // Выполняем поиск в зависимости от выбранной вкладки
    final appProvider = context.read<AppProvider>();
    
    if (_selectedTabIndex == 0) {
      // Поиск товаров
      appProvider.productProvider.searchProducts(_searchQuery);
    } else if (_selectedTabIndex == 1) {
      // Поиск пользователей
      // TODO: Реализовать поиск пользователей
    } else if (_selectedTabIndex == 2) {
      // Поиск постов
      // TODO: Реализовать поиск постов
    }
    
    setState(() {
      _isSearching = false;
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    
    if (_searchQuery.isNotEmpty) {
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Заголовок с поиском
          SliverAppBar(
            floating: true,
            title: SearchBar(
              controller: _searchController,
              onSubmitted: (query) => _performSearch(),
              onCleared: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              hintText: 'Поиск товаров, пользователей, постов...',
            ),
            actions: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          
          // Вкладки поиска
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchTabsDelegate(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  onTap: _onTabChanged,
                  tabs: const [
                    Tab(text: 'Товары'),
                    Tab(text: 'Пользователи'),
                    Tab(text: 'Посты'),
                  ],
                ),
              ),
            ),
          ),
          
          // Результаты поиска
          if (_searchQuery.isEmpty)
            _buildEmptyState()
          else
            _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Начните поиск',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ищите товары, пользователей и посты',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    switch (_selectedTabIndex) {
      case 0:
        return _buildProductsResults();
      case 1:
        return _buildUsersResults();
      case 2:
        return _buildPostsResults();
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  Widget _buildProductsResults() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final productProvider = appProvider.productProvider;
        final products = productProvider.products;
        
        if (products.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Товары не найдены',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Попробуйте изменить запрос',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: product.imageUrl != null
                      ? NetworkImage(product.imageUrl!)
                      : null,
                  child: product.imageUrl == null
                      ? const Icon(Icons.shopping_bag)
                      : null,
                ),
                title: Text(product.title),
                subtitle: Text(
                  '${product.price} ₽',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  // TODO: Навигация к деталям товара
                },
              );
            },
            childCount: products.length,
          ),
        );
      },
    );
  }

  Widget _buildUsersResults() {
    // TODO: Реализовать поиск пользователей
    return const SliverFillRemaining(
      child: Center(
        child: Text('Поиск пользователей в разработке'),
      ),
    );
  }

  Widget _buildPostsResults() {
    // TODO: Реализовать поиск постов
    return const SliverFillRemaining(
      child: Center(
        child: Text('Поиск постов в разработке'),
      ),
    );
  }
}

class _SearchTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SearchTabsDelegate({required this.child});

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
