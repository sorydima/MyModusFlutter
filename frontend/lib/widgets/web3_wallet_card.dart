import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Web3WalletCard extends StatefulWidget {
  const Web3WalletCard({super.key});

  @override
  State<Web3WalletCard> createState() => _Web3WalletCardState();
}

class _Web3WalletCardState extends State<Web3WalletCard> {
  final TextEditingController _privateKeyController = TextEditingController();
  bool _showPrivateKey = false;

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final web3Provider = appProvider.web3Provider;
        
        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Web3 Кошелек',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (web3Provider.isConnected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Подключен',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                if (web3Provider.isConnected)
                  _buildConnectedWallet(web3Provider)
                else
                  _buildConnectWallet(web3Provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectedWallet(Web3Provider web3Provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Информация о сети
        Row(
          children: [
            Icon(
              Icons.wifi,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              web3Provider.networkName ?? 'Неизвестная сеть',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Адрес кошелька
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        web3Provider.getShortWalletAddress(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copyToClipboard(
                        web3Provider.walletAddress?.hex ?? '',
                        'Адрес скопирован',
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Баланс ETH
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.currency_bitcoin,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Баланс',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${web3Provider.getBalanceInETH()} ETH',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showSendETHDialog(context),
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Быстрые действия
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showMintNFTDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Минт NFT'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCreateTokenDialog(context),
                icon: const Icon(Icons.token),
                label: const Text('Создать токен'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectWallet(Web3Provider web3Provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Подключите свой Web3 кошелек для доступа к NFT, токенам лояльности и блокчейн функциям.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Подключение через приватный ключ (для разработки)
        ExpansionTile(
          title: const Text('Подключение через приватный ключ'),
          subtitle: const Text('Только для разработки'),
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _privateKeyController,
              obscureText: !_showPrivateKey,
              decoration: InputDecoration(
                labelText: 'Приватный ключ',
                hintText: '0x...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _showPrivateKey = !_showPrivateKey;
                    });
                  },
                  icon: Icon(
                    _showPrivateKey ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _privateKeyController.text.isNotEmpty
                    ? () => _connectWithPrivateKey()
                    : null,
                child: const Text('Подключить'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Подключение через MetaMask
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _connectWithMetaMask(),
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Подключить MetaMask'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Информация о сетях
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Поддерживаемые сети:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Ethereum Mainnet\n• Polygon\n• Local Ganache (разработка)\n• Testnet сети',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _connectWithPrivateKey() async {
    if (_privateKeyController.text.isEmpty) return;
    
    final appProvider = context.read<AppProvider>();
    final success = await appProvider.web3Provider.connectWalletWithPrivateKey(
      _privateKeyController.text.trim(),
    );
    
    if (success) {
      _privateKeyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Кошелек успешно подключен!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка подключения: ${appProvider.web3Provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _connectWithMetaMask() async {
    final appProvider = context.read<AppProvider>();
    final success = await appProvider.web3Provider.connectWalletWithMetaMask();
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка подключения: ${appProvider.web3Provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard(String text, String message) {
    // TODO: Реализовать копирование в буфер обмена
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSendETHDialog(BuildContext context) {
    // TODO: Реализовать диалог отправки ETH
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция отправки ETH в разработке')),
    );
  }

  void _showMintNFTDialog(BuildContext context) {
    // TODO: Реализовать диалог минтинга NFT
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция минтинга NFT в разработке')),
    );
  }

  void _showCreateTokenDialog(BuildContext context) {
    // TODO: Реализовать диалог создания токена
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция создания токена в разработке')),
    );
  }
}
