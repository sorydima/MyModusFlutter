import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/product_feed.dart';
import '../widgets/social_feed.dart';
import '../widgets/search_screen.dart';
import '../widgets/chats_list_screen.dart';
import '../widgets/profile_screen.dart';
import '../screens/web3_screen.dart';
import '../screens/ipfs_screen.dart';
import '../widgets/ipfs_upload_dialog.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Инициализируем провайдеры при загрузке экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeProviders() async {
    if (_isInitialized) return;
    
    try {
      final appProvider = context.read<AppProvider>();
      
      // Инициализируем все провайдеры
      await Future.wait([
        appProvider.authProvider.initialize(),
        appProvider.productProvider.initialize(),
        appProvider.socialProvider.initialize(),
        appProvider.web3Provider.initialize(),
        // IPFS провайдер уже инициализирован в main.dart
      ]);
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Обрабатываем ошибки инициализации
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка инициализации: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitialized
          ? PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: const [
                ProductFeed(),
                SocialFeed(),
                SearchScreen(),
                Web3Screen(),
                IPFSScreen(),
                ProfileScreen(),
              ],
            )
          : _buildLoadingScreen(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Загрузка приложения...'),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    // Показываем FAB на социальной ленте и IPFS экране
    if (_currentIndex == 1) {
      // FAB для социальной ленты
      return FloatingActionButton(
        onPressed: () {
          // TODO: Навигация к экрану создания поста
          Navigator.pushNamed(context, '/create-post');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      );
    } else if (_currentIndex == 4) {
      // FAB для IPFS экрана
      return FloatingActionButton(
        onPressed: () {
          // Показываем диалог загрузки файлов
          showDialog(
            context: context,
            builder: (context) => const IPFSUploadDialog(),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: const Icon(Icons.upload_file),
      );
    }
    
    return null;
  }
}
