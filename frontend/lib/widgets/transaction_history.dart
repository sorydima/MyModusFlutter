import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/web3_models.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  // Тестовые данные транзакций
  final List<TransactionModel> _transactions = [
    TransactionModel(
      hash: '0x1234...5678',
      from: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      to: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      value: '0.5',
      gasUsed: '21000',
      gasPrice: '20000000000',
      blockNumber: 12345678,
      status: TransactionStatus.confirmed,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: TransactionType.transfer,
      network: 'Ethereum Mainnet',
    ),
    TransactionModel(
      hash: '0x8765...4321',
      from: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      to: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      value: '0.3',
      gasUsed: '65000',
      gasPrice: '25000000000',
      blockNumber: 12345677,
      status: TransactionStatus.confirmed,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.swap,
      network: 'Ethereum Mainnet',
    ),
    TransactionModel(
      hash: '0xabcd...efgh',
      from: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      to: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      value: '0.1',
      gasUsed: '21000',
      gasPrice: '18000000000',
      blockNumber: 12345676,
      status: TransactionStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.transfer,
      network: 'Ethereum Mainnet',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        final isConnected = walletProvider.isConnected;
        
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.history,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'История транзакций',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${_transactions.length} транзакций',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isConnected)
                      IconButton(
                        onPressed: () {
                          // TODO: Обновить историю
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('История обновлена!')),
                          );
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Список транзакций
              if (!isConnected)
                _buildNotConnectedState(theme)
              else if (_transactions.isEmpty)
                _buildEmptyState(theme)
              else
                _buildTransactionsList(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotConnectedState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Кошелек не подключен',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Подключите кошелек для просмотра истории транзакций',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Нет транзакций',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'У вас пока нет транзакций в этой сети',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(ThemeData theme) {
    return Column(
      children: _transactions.map((transaction) {
        return _buildTransactionItem(theme, transaction);
      }).toList(),
    );
  }

  Widget _buildTransactionItem(ThemeData theme, TransactionModel transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Иконка типа транзакции
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTransactionTypeColor(transaction.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTransactionTypeIcon(transaction.type),
              color: _getTransactionTypeColor(transaction.type),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Детали транзакции
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getTransactionTypeText(transaction.type),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(transaction.status).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(transaction.status),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(transaction.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  '${transaction.value} ETH',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Text(
                      _formatTimestamp(transaction.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction.network,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Действия
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            onSelected: (value) {
              _handleTransactionAction(value, transaction);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 16),
                    SizedBox(width: 8),
                    Text('Просмотреть'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 16),
                    SizedBox(width: 8),
                    Text('Копировать хеш'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'explorer',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new, size: 16),
                    SizedBox(width: 8),
                    Text('Открыть в эксплорере'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.swap:
        return Colors.orange;
      case TransactionType.stake:
        return Colors.purple;
      case TransactionType.mint:
        return Colors.green;
      case TransactionType.burn:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.swap:
        return Icons.swap_horiz;
      case TransactionType.stake:
        return Icons.check_circle;
      case TransactionType.mint:
        return Icons.add_circle;
      case TransactionType.burn:
        return Icons.remove_circle;
      default:
        return Icons.receipt;
    }
  }

  String _getTransactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return 'Перевод';
      case TransactionType.swap:
        return 'Обмен';
      case TransactionType.stake:
        return 'Стейкинг';
      case TransactionType.mint:
        return 'Минтинг';
      case TransactionType.burn:
        return 'Сжигание';
      default:
        return 'Транзакция';
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirmed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirmed:
        return 'Завершено';
      case TransactionStatus.pending:
        return 'В процессе';
      case TransactionStatus.failed:
        return 'Ошибка';
      default:
        return 'Неизвестно';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'Только что';
    }
  }

  void _handleTransactionAction(String action, TransactionModel transaction) {
    switch (action) {
      case 'view':
        _showTransactionDetails(transaction);
        break;
      case 'copy':
        // TODO: Копировать хеш в буфер обмена
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Хеш скопирован!')),
        );
        break;
      case 'explorer':
        // TODO: Открыть в блокчейн эксплорере
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Открываю в эксплорере...')),
        );
        break;
    }
  }

  void _showTransactionDetails(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Детали транзакции'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Хеш', transaction.hash),
            _buildDetailRow('От', transaction.from),
            _buildDetailRow('К', transaction.to),
            _buildDetailRow('Сумма', '${transaction.value} ETH'),
            _buildDetailRow('Статус', _getStatusText(transaction.status)),
            _buildDetailRow('Сеть', transaction.network),
            _buildDetailRow('Время', _formatTimestamp(transaction.timestamp)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
