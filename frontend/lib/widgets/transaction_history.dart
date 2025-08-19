import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final web3Provider = appProvider.web3Provider;
        
        if (!web3Provider.isConnected) {
          return _buildNotConnectedState(context);
        }
        
        if (web3Provider.isLoadingTransactions) {
          return _buildLoadingState();
        }
        
        if (web3Provider.transactionsError != null) {
          return _buildErrorState(context, web3Provider);
        }
        
        if (web3Provider.transactions.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildTransactionsList(context, web3Provider);
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
              'Для просмотра истории транзакций необходимо подключить Web3 кошелек',
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
              'Ошибка загрузки транзакций',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              web3Provider.transactionsError!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Повторить загрузку транзакций
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
              Icons.receipt_long,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Транзакции не найдены',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'У вас пока нет транзакций. Совершите первую транзакцию!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showSendETHDialog(context),
              icon: const Icon(Icons.send),
              label: const Text('Отправить ETH'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, Web3Provider web3Provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и кнопка отправки
          Row(
            children: [
              Text(
                'История транзакций (${web3Provider.transactions.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showSendETHDialog(context),
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Отправить'),
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
          
          // Список транзакций
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: web3Provider.transactions.length,
            itemBuilder: (context, index) {
              final transaction = web3Provider.transactions[index];
              return _TransactionCard(transaction: transaction);
            },
          ),
        ],
      ),
    );
  }

  void _showSendETHDialog(BuildContext context) {
    // TODO: Реализовать диалог отправки ETH
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция отправки ETH в разработке')),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction['type'] == 'incoming';
    final status = transaction['status'] ?? 'pending';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок транзакции
            Row(
              children: [
                // Иконка типа транзакции
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isIncoming 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isIncoming ? Icons.call_received : Icons.call_made,
                    color: isIncoming ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Основная информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIncoming ? 'Получено' : 'Отправлено',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(transaction['timestamp']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Статус транзакции
                _TransactionStatus(status: status),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Детали транзакции
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Сумма
                  Row(
                    children: [
                      Text(
                        'Сумма:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${transaction['amount'] ?? '0'} ${transaction['currency'] ?? 'ETH'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Адрес
                  Row(
                    children: [
                      Text(
                        isIncoming ? 'От:' : 'К:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: Text(
                          _formatAddress(transaction['address'] ?? ''),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  
                  // Хеш транзакции
                  if (transaction['hash'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Хеш:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          child: Text(
                            _formatHash(transaction['hash']),
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Комиссия
                  if (transaction['gas_used'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Комиссия:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${transaction['gas_used']} gas',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Действия
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewOnExplorer(context),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('В эксплорере'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyHash(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Копировать хеш'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'Неизвестно';
    
    try {
      final date = DateTime.parse(timestamp);
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
      return 'Неизвестно';
    }
  }

  String _formatAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatHash(String hash) {
    if (hash.length <= 12) return hash;
    return '${hash.substring(0, 6)}...${hash.substring(hash.length - 6)}';
  }

  void _viewOnExplorer(BuildContext context) {
    // TODO: Реализовать открытие в блокчейн эксплорере
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Открытие в эксплорере в разработке')),
    );
  }

  void _copyHash(BuildContext context) {
    // TODO: Реализовать копирование хеша
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Хеш скопирован')),
    );
  }
}

class _TransactionStatus extends StatelessWidget {
  final String status;

  const _TransactionStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Подтверждено';
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        label = 'В обработке';
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        label = 'Ошибка';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = 'Неизвестно';
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
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
