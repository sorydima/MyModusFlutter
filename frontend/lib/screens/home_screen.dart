import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../models/product_model.dart';
import '../utils/responsive_utils.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'nft_gallery_screen.dart';
import 'ai_chat_screen.dart';
import 'ai_virtual_tryon_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Инициализируем провайдер при создании экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Используем RepaintBoundary для оптимизации перестроений
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: _fadeAnimation.isCompleted
                  ? Column(
                      children: [
                        _buildWelcomeSection(theme),
                        _buildQuickActionsSection(theme),
                        _buildWeb3AIFunctionsSection(theme),
                        _buildFeaturedProductsSection(theme),
                        _buildCategoriesSection(theme),
                        _buildBrandsSection(theme),
                        const SizedBox(height: 40),
                      ],
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            _buildWelcomeSection(theme),
                            _buildQuickActionsSection(theme),
                            _buildWeb3AIFunctionsSection(theme),
                            _buildFeaturedProductsSection(theme),
                            _buildCategoriesSection(theme),
                            _buildBrandsSection(theme),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'My Modus',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Уведомления
          },
          icon: const Icon(Icons.notifications_outlined),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Настройки
          },
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Добро пожаловать! 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Откройте для себя мир моды, технологий и инноваций',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Быстрые действия',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
            crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
            mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
            childAspectRatio: ResponsiveUtils.getChildAspectRatio(context, mobile: 1.5),
            children: [
              _buildUpdateItem(
                icon: Icons.search,
                title: 'Поиск',
                subtitle: 'Найти товары',
                color: Colors.blue,
                onTap: () => _navigateToScreen(SearchScreen()),
              ),
              _buildUpdateItem(
                icon: Icons.favorite,
                title: 'Избранное',
                subtitle: 'Любимые товары',
                color: Colors.red,
                onTap: () => _navigateToScreen(FavoritesScreen()),
              ),
              _buildUpdateItem(
                icon: Icons.shopping_cart,
                title: 'Корзина',
                subtitle: 'Покупки',
                color: Colors.green,
                onTap: () => _navigateToScreen(CartScreen()),
              ),
              _buildUpdateItem(
                icon: Icons.person,
                title: 'Профиль',
                subtitle: 'Личный кабинет',
                color: Colors.purple,
                onTap: () => _navigateToScreen(ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeb3AIFunctionsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Web3 & AI функции',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
            crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
            mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
            childAspectRatio: ResponsiveUtils.getChildAspectRatio(context, mobile: 1.3),
            children: [
              _buildUpdateItem(
                icon: Icons.image,
                title: 'NFT Галерея',
                subtitle: 'Цифровое искусство',
                color: Colors.orange,
                onTap: () => _navigateToScreen(NFTGalleryScreen()),
              ),
              _buildUpdateItem(
                icon: Icons.style,
                title: 'AI Стилист',
                subtitle: 'Персональный стиль',
                color: Colors.pink,
                onTap: () => _navigateToScreen(AIVirtualTryOnScreen()),
              ),
              _buildUpdateItem(
                icon: Icons.account_balance_wallet,
                title: 'Web3 Кошелек',
                subtitle: 'Криптовалюта',
                color: Colors.indigo,
                onTap: () => _navigateToScreen(WalletScreen()),
              ),
              _buildUpdateItem(
                icon: Icons.chat,
                title: 'AI Чат',
                subtitle: 'Умный помощник',
                color: Colors.teal,
                onTap: () => _navigateToScreen(AIChatScreen()),
              ),
              _buildUpdateItem(
                icon: Icons.camera_alt,
                title: 'Виртуальная примерка',
                subtitle: 'AR технологии',
                color: Colors.cyan,
                onTap: () => _navigateToScreen(AIVirtualTryOnScreen()),
              ),
              _buildUpdateItem(
                icon: Icons.checkroom,
                title: 'Планировщик образов',
                subtitle: 'Создание луков',
                color: Colors.deepPurple,
                onTap: () => _navigateToScreen(SearchScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection(ThemeData theme) {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        if (productsProvider.isLoading) {
          return Container(
            margin: const EdgeInsets.all(20),
            height: 200,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final topProducts = productsProvider.getTopProducts(limit: 6);
        
        if (topProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Топ товары',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _navigateToScreen(SearchScreen());
                      },
                      child: const Text('Смотреть все'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: topProducts.length,
                    itemBuilder: (context, index) {
                      final product = topProducts[index];
                      return Container(
                        key: ValueKey('top_product_${product.id}'),
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        child: _buildProductCard(product, theme),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection(ThemeData theme) {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        if (productsProvider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Категории',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productsProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = productsProvider.categories[index];
                      return Container(
                        key: ValueKey('category_$category'),
                        width: 120,
                        margin: const EdgeInsets.only(right: 16),
                        child: _buildCategoryCard(category, theme),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandsSection(ThemeData theme) {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        if (productsProvider.popularBrands.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Популярные бренды',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: productsProvider.popularBrands.map((brand) {
                  return _buildBrandChip(brand, theme);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpdateItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Навигация к детальной странице товара
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.error, size: 30),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, ThemeData theme) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    
    final color = colors[category.hashCode % colors.length];
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<ProductsProvider>().setCategory(category);
        _navigateToScreen(SearchScreen());
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandChip(String brand, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<ProductsProvider>().setBrand(brand);
        _navigateToScreen(SearchScreen());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        ),
        child: Text(
          brand,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
