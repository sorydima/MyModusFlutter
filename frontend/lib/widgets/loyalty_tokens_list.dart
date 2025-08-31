import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class LoyaltyTokensList extends StatelessWidget {
  const LoyaltyTokensList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final web3Provider = appProvider.web3Provider;
        
        if (!web3Provider.isConnected) {
          return _buildNotConnectedState(context);
        }
        
        if (web3Provider.isLoadingTokens) {
          return _buildLoadingState();
        }
        
        if (web3Provider.tokensError != null) {
          return _buildErrorState(context, web3Provider);
        }
        
        if (web3Provider.loyaltyTokens.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildTokensList(context, web3Provider);
      },
    );
  }

  Widget _buildNotConnectedState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Подключите кошелек',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Для просмотра токенов лояльности необходимо подключить Web3 кошелек',
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

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Web3Provider web3Provider) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки токенов',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              web3Provider.tokensError!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Повторить загрузку токенов
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.token,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Токены лояльности не найдены',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'У вас пока нет токенов лояльности. Создайте свой первый токен!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreateTokenDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Создать токен'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokensList(BuildContext context, Web3Provider web3Provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и кнопка создания
          Row(
            children: [
              Text(
                'Токены лояльности (${web3Provider.loyaltyTokens.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateTokenDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Создать'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Список токенов
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: web3Provider.loyaltyTokens.length,
            itemBuilder: (context, index) {
              final token = web3Provider.loyaltyTokens[index];
              return _TokenCard(token: token);
            },
          ),
        ],
      ),
    );
  }

  void _showCreateTokenDialog(BuildContext context) {
    // TODO: Реализовать диалог создания токена
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция создания токена в разработке')),
    );
  }
}

class _TokenCard extends StatelessWidget {
  final Map<String, dynamic> token;

  const _TokenCard({required this.token});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Иконка токена
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.token,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Информация о токене
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название и символ
                  Row(
                    children: [
                      Text(
                        token['name'] ?? 'Без названия',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          token['symbol'] ?? 'TKN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Описание
                  if (token['description'] != null)
                    Text(
                      token['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Детали токена
                  Row(
                    children: [
                      _TokenDetail(
                        label: 'Баланс',
                        value: '${token['balance'] ?? 0}',
                        icon: Icons.account_balance_wallet,
                      ),
                      const SizedBox(width: 16),
                      _TokenDetail(
                        label: 'Всего',
                        value: '${token['total_supply'] ?? 0}',
                        icon: Icons.token,
                      ),
                      const SizedBox(width: 16),
                      _TokenDetail(
                        label: 'Дек. знаки',
                        value: '${token['decimals'] ?? 18}',
                        icon: Icons.precision_manufacturing,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Действия с токеном
            PopupMenuButton<String>(
              onSelected: (value) => _handleTokenAction(context, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16),
                      SizedBox(width: 8),
                      Text('Просмотр'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'transfer',
                  child: Row(
                    children: [
                      Icon(Icons.send, size: 16),
                      SizedBox(width: 8),
                      Text('Передать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'burn',
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 16),
                      SizedBox(width: 8),
                      Text('Сжечь'),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTokenAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        _viewToken(context);
        break;
      case 'transfer':
        _transferToken(context);
        break;
      case 'burn':
        _burnToken(context);
        break;
    }
  }

  void _viewToken(BuildContext context) {
    // TODO: Реализовать просмотр токена
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Просмотр токена в разработке')),
    );
  }

  void _transferToken(BuildContext context) {
    // TODO: Реализовать передачу токена
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Передача токена в разработке')),
    );
  }

  void _burnToken(BuildContext context) {
    // TODO: Реализовать сжигание токена
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сжигание токена в разработке')),
    );
  }
}

class _TokenDetail extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TokenDetail({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
