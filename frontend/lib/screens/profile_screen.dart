import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Инициализируем провайдер при создании экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showSettingsDialog();
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Профиль пользователя
            _buildUserProfile(),
            
            const SizedBox(height: 32),
            
            // Статистика
            _buildUserStats(),
            
            const SizedBox(height: 32),
            
            // Основные разделы
            _buildMainSections(),
            
            const SizedBox(height: 32),
            
            // Дополнительные разделы
            _buildAdditionalSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Аватар пользователя
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Информация о пользователе
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Пользователь MyModus',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'user@mymodus.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Кнопка редактирования
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showEditProfileDialog();
            },
            icon: Icon(
              Icons.edit,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite,
                title: 'Избранное',
                value: '${productsProvider.favoritesCount}',
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.shopping_cart,
                title: 'Корзина',
                value: '${productsProvider.cartItemCount}',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                title: 'Отзывы',
                value: '12',
                color: Colors.amber,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
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
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Основные разделы',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildSectionTile(
          icon: Icons.shopping_bag,
          title: 'Мои заказы',
          subtitle: 'История покупок и текущие заказы',
          onTap: () {
            HapticFeedback.lightImpact();
            _showFeatureDialog('Мои заказы');
          },
        ),
        
        _buildSectionTile(
          icon: Icons.favorite,
          title: 'Избранное',
          subtitle: 'Сохраненные товары',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pushNamed('/favorites');
          },
        ),
        
        _buildSectionTile(
          icon: Icons.location_on,
          title: 'Адреса доставки',
          subtitle: 'Управление адресами',
          onTap: () {
            HapticFeedback.lightImpact();
            _showFeatureDialog('Адреса доставки');
          },
        ),
        
        _buildSectionTile(
          icon: Icons.payment,
          title: 'Способы оплаты',
          subtitle: 'Карты и другие методы',
          onTap: () {
            HapticFeedback.lightImpact();
            _showFeatureDialog('Способы оплаты');
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Дополнительно',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildSectionTile(
          icon: Icons.support_agent,
          title: 'Поддержка',
          subtitle: 'Связаться с нами',
          onTap: () {
            HapticFeedback.lightImpact();
            _showSupportDialog();
          },
        ),
        
        _buildSectionTile(
          icon: Icons.info,
          title: 'О приложении',
          subtitle: 'Версия и информация',
          onTap: () {
            HapticFeedback.lightImpact();
            _showAboutDialog();
          },
        ),
        
        _buildSectionTile(
          icon: Icons.logout,
          title: 'Выйти',
          subtitle: 'Завершить сессию',
          onTap: () {
            HapticFeedback.lightImpact();
            _showLogoutDialog();
          },
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive 
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade400,
          size: 16,
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки'),
        content: const Text(
          'Раздел настроек находится в разработке. '
          'В ближайшее время здесь появятся настройки профиля, уведомлений и другие опции.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактирование профиля'),
        content: const Text(
          'Функция редактирования профиля находится в разработке. '
          'В ближайшее время вы сможете изменить имя, email и другие данные профиля.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showFeatureDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(featureName),
        content: Text(
          'Раздел "$featureName" находится в разработке. '
          'В ближайшее время здесь появится полный функционал.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поддержка'),
        content: const Text(
          'Для получения поддержки:\n\n'
          '• Email: support@mymodus.com\n'
          '• Телефон: +7 (800) 555-0123\n'
          '• Время работы: Пн-Пт 9:00-18:00'
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: const Text(
          'MyModus v1.0.0\n\n'
          'Современное приложение для покупок с интеграцией Web3, AI и социальных функций.\n\n'
          '© 2024 MyModus. Все права защищены.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта'),
        content: const Text(
          'Вы уверены, что хотите выйти из аккаунта?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Реализовать выход из аккаунта
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Выход из аккаунта выполнен'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
