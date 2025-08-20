import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/web3_provider.dart';
import '../models/web3_models.dart';

class MetaMaskIPFSDemoScreen extends StatefulWidget {
  const MetaMaskIPFSDemoScreen({super.key});

  @override
  State<MetaMaskIPFSDemoScreen> createState() => _MetaMaskIPFSDemoScreenState();
}

class _MetaMaskIPFSDemoScreenState extends State<MetaMaskIPFSDemoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _filePathController = TextEditingController();
  
  // IPFS тестирование
  String? _lastUploadedHash;
  String? _lastRetrievedData;
  bool _isUploading = false;
  bool _isRetrieving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Инициализируем Web3 при загрузке экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Web3Provider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _filePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MetaMask & IPFS Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'MetaMask'),
            Tab(icon: Icon(Icons.cloud_upload), text: 'IPFS'),
            Tab(icon: Icon(Icons.analytics), text: 'Статистика'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMetaMaskTab(),
          _buildIPFSTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildMetaMaskTab() {
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Информация о режиме подключения
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Режим подключения:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _getConnectionModeIcon(web3Provider.connectionMode),
                            color: _getConnectionModeColor(web3Provider.connectionMode),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getConnectionModeName(web3Provider.connectionMode),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Переключение режимов
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Переключение режимов:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => web3Provider.switchToTestMode(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: web3Provider.connectionMode == WalletConnectionMode.test
                                    ? Colors.green
                                    : null,
                              ),
                              child: const Text('Тест'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => web3Provider.switchToMetaMask(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: web3Provider.connectionMode == WalletConnectionMode.metamask
                                    ? Colors.blue
                                    : null,
                              ),
                              child: const Text('MetaMask'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => web3Provider.switchToPrivateKeyMode(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: web3Provider.connectionMode == WalletConnectionMode.privatekey
                                    ? Colors.orange
                                    : null,
                              ),
                              child: const Text('Приватный ключ'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Подключение кошелька
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Подключение кошелька:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      if (!web3Provider.isConnected) ...[
                        if (web3Provider.connectionMode == WalletConnectionMode.metamask) ...[
                          ElevatedButton.icon(
                            onPressed: web3Provider.isLoading
                                ? null
                                : () => web3Provider.connectWalletWithMetaMask(),
                            icon: const Icon(Icons.account_balance_wallet),
                            label: const Text('Подключиться через MetaMask'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            onPressed: web3Provider.isLoading
                                ? null
                                : () => web3Provider.connectWalletWithPrivateKey(''),
                            icon: const Icon(Icons.connect_without_contact),
                            label: const Text('Подключить кошелек'),
                          ),
                        ],
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: web3Provider.isLoading
                                    ? null
                                    : () => web3Provider.disconnectWallet(),
                                icon: const Icon(Icons.disconnect),
                                label: const Text('Отключить кошелек'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Подпись сообщений
              if (web3Provider.isConnected && 
                  web3Provider.connectionMode == WalletConnectionMode.metamask) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Подпись сообщений:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            labelText: 'Сообщение для подписи',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _signMessage,
                            icon: const Icon(Icons.edit),
                            label: const Text('Подписать сообщение'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              if (web3Provider.isLoading)
                const Center(child: CircularProgressIndicator()),
              
              if (web3Provider.error != null)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Ошибка:',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          web3Provider.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: web3Provider.clearError,
                          child: const Text('Очистить'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIPFSTab() {
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // IPFS Gateway информация
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IPFS Gateway:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.cloud, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              web3Provider.ipfsService.currentGateway,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => web3Provider.switchIPFSGateway(),
                        child: const Text('Переключить Gateway'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Загрузка файлов в IPFS
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Загрузка в IPFS:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _filePathController,
                        decoration: const InputDecoration(
                          labelText: 'Путь к файлу (для демо)',
                          border: OutlineInputBorder(),
                          hintText: 'Например: /path/to/file.jpg',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isUploading ? null : _uploadFileToIPFS,
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text('Загрузить файл'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isRetrieving ? null : _retrieveFileFromIPFS,
                              icon: const Icon(Icons.cloud_download),
                              label: const Text('Получить файл'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Результаты IPFS операций
              if (_lastUploadedHash != null || _lastRetrievedData != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Результаты IPFS:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_lastUploadedHash != null) ...[
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Загружено: $_lastUploadedHash',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (_lastRetrievedData != null) ...[
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Получено: $_lastRetrievedData',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              
              if (_isUploading || _isRetrieving)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) {
        final stats = web3Provider.getWeb3Stats();
        final ipfsStats = web3Provider.getIPFSCacheStats();
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Web3 статистика
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Web3 Статистика:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow('Подключен:', '${stats['is_connected']}'),
                      _buildStatRow('Режим:', '${stats['connection_mode']}'),
                      _buildStatRow('Сеть:', '${stats['network_name'] ?? 'Неизвестно'}'),
                      _buildStatRow('Адрес:', '${stats['wallet_address'] ?? 'Не подключен'}'),
                      _buildStatRow('Баланс:', '${stats['balance_eth'] ?? '0.0'} ETH'),
                      _buildStatRow('NFT:', '${stats['nfts_count']}'),
                      _buildStatRow('Токены:', '${stats['loyalty_tokens_count']}'),
                      _buildStatRow('Транзакции:', '${stats['transactions_count']}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // IPFS статистика
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IPFS Статистика:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow('Gateway:', '${stats['ipfs_gateway']}'),
                      _buildStatRow('Записей в кэше:', '${ipfsStats['totalEntries']}'),
                      _buildStatRow('Размер кэша:', '${ipfsStats['totalSize']} байт'),
                      _buildStatRow('Устаревших записей:', '${ipfsStats['expiredEntries']}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Управление IPFS
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Управление IPFS:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => web3Provider.clearIPFSCache(),
                              child: const Text('Очистить кэш'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => web3Provider.ipfsService.clearExpiredCache(),
                              child: const Text('Очистить устаревшие'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getConnectionModeIcon(WalletConnectionMode mode) {
    switch (mode) {
      case WalletConnectionMode.test:
        return Icons.test;
      case WalletConnectionMode.metamask:
        return Icons.account_balance_wallet;
      case WalletConnectionMode.walletconnect:
        return Icons.link;
      case WalletConnectionMode.privatekey:
        return Icons.key;
    }
  }

  Color _getConnectionModeColor(WalletConnectionMode mode) {
    switch (mode) {
      case WalletConnectionMode.test:
        return Colors.green;
      case WalletConnectionMode.metamask:
        return Colors.blue;
      case WalletConnectionMode.walletconnect:
        return Colors.purple;
      case WalletConnectionMode.privatekey:
        return Colors.orange;
    }
  }

  String _getConnectionModeName(WalletConnectionMode mode) {
    switch (mode) {
      case WalletConnectionMode.test:
        return 'Тестовый режим (Mock данные)';
      case WalletConnectionMode.metamask:
        return 'MetaMask (Реальный блокчейн)';
      case WalletConnectionMode.walletconnect:
        return 'WalletConnect (Мобильные кошельки)';
      case WalletConnectionMode.privatekey:
        return 'Приватный ключ (Разработка)';
    }
  }

  Future<void> _signMessage() async {
    if (_messageController.text.isEmpty) return;
    
    final web3Provider = context.read<Web3Provider>();
    final signature = await web3Provider.metaMaskService.signMessage(_messageController.text);
    
    if (signature != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Сообщение подписано: ${signature.substring(0, 20)}...'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка подписи сообщения'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadFileToIPFS() async {
    if (_filePathController.text.isEmpty) return;
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      final web3Provider = context.read<Web3Provider>();
      final mockData = Uint8List.fromList(_filePathController.text.codeUnits);
      
      final hash = await web3Provider.ipfsService.uploadFile(
        fileData: mockData,
        fileName: 'demo_file.txt',
        mimeType: 'text/plain',
      );
      
      if (hash != null) {
        setState(() {
          _lastUploadedHash = hash;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Файл загружен в IPFS: $hash'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _retrieveFileFromIPFS() async {
    if (_lastUploadedHash == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала загрузите файл в IPFS'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isRetrieving = true;
    });
    
    try {
      final web3Provider = context.read<Web3Provider>();
      final data = await web3Provider.ipfsService.getFile(_lastUploadedHash!);
      
      if (data != null) {
        setState(() {
          _lastRetrievedData = '${data.length} байт получено';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Файл успешно получен из IPFS'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось получить файл из IPFS'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка получения: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isRetrieving = false;
      });
    }
  }
}
