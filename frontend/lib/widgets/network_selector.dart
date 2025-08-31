import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/web3_models.dart';

class NetworkSelector extends StatefulWidget {
  const NetworkSelector({super.key});

  @override
  State<NetworkSelector> createState() => _NetworkSelectorState();
}

class _NetworkSelectorState extends State<NetworkSelector> {
  bool _isExpanded = false;

  // Поддерживаемые сети
  final List<NetworkInfo> _supportedNetworks = [
    NetworkInfo(
      name: 'Ethereum Mainnet',
      chainId: 1,
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://etherscan.io',
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: false,
    ),
    NetworkInfo(
      name: 'Sepolia Testnet',
      chainId: 11155111,
      rpcUrl: 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://sepolia.etherscan.io',
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: true,
    ),
    NetworkInfo(
      name: 'Mumbai Testnet',
      chainId: 80001,
      rpcUrl: 'https://polygon-mumbai.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      explorerUrl: 'https://mumbai.polygonscan.com',
      nativeCurrency: 'MATIC',
      decimals: 18,
      isTestnet: true,
    ),
    NetworkInfo(
      name: 'Local Ganache',
      chainId: 1337,
      rpcUrl: 'http://127.0.0.1:7545',
      explorerUrl: null,
      nativeCurrency: 'ETH',
      decimals: 18,
      isTestnet: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        final currentNetwork = walletProvider.currentNetwork;
        
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
            children: [
              // Заголовок
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Padding(
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
                          Icons.network_check,
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
                              'Сеть',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (currentNetwork != null)
                              Text(
                                currentNetwork.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: currentNetwork?.isTestnet == true
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: currentNetwork?.isTestnet == true
                                ? Colors.orange.withOpacity(0.3)
                                : Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          currentNetwork?.isTestnet == true ? 'Testnet' : 'Mainnet',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: currentNetwork?.isTestnet == true
                                ? Colors.orange
                                : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Список сетей
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildNetworksList(theme, walletProvider),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNetworksList(ThemeData theme, WalletProvider walletProvider) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: _supportedNetworks.map((network) {
          final isSelected = walletProvider.currentNetwork?.chainId == network.chainId;
          
          return InkWell(
            onTap: () {
              walletProvider.switchNetwork(network);
              setState(() {
                _isExpanded = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Иконка сети
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getNetworkColor(network).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNetworkIcon(network),
                      color: _getNetworkColor(network),
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Информация о сети
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          network.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chain ID: ${network.chainId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Статус выбора
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  
                  // Индикатор типа сети
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: network.isTestnet
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      network.isTestnet ? 'TEST' : 'MAIN',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: network.isTestnet ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getNetworkColor(NetworkInfo network) {
    switch (network.chainId) {
      case 1: // Ethereum Mainnet
        return Colors.blue;
      case 11155111: // Sepolia
        return Colors.purple;
      case 80001: // Mumbai
        return Colors.pink;
      case 1337: // Local
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getNetworkIcon(NetworkInfo network) {
    switch (network.chainId) {
      case 1: // Ethereum Mainnet
        return Icons.currency_bitcoin;
      case 11155111: // Sepolia
        return Icons.science;
      case 80001: // Mumbai
        return Icons.diamond;
      case 1337: // Local
        return Icons.computer;
      default:
        return Icons.network_check;
    }
  }
}
