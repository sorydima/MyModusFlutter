import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NFTGrid extends StatelessWidget {
  const NFTGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final web3Provider = appProvider.web3Provider;
        
        if (!web3Provider.isConnected) {
          return _buildNotConnectedState(context);
        }
        
        if (web3Provider.isLoadingNFTs) {
          return _buildLoadingState();
        }
        
        if (web3Provider.nftsError != null) {
          return _buildErrorState(context, web3Provider);
        }
        
        if (web3Provider.nfts.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildNFTGrid(context, web3Provider);
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
              'Для просмотра NFT необходимо подключить Web3 кошелек',
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
              'Ошибка загрузки NFT',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              web3Provider.nftsError!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Повторить загрузку NFT
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
              Icons.image_not_supported,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'NFT не найдены',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'У вас пока нет NFT. Создайте свой первый токен!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showMintNFTDialog(context),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Минт NFT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNFTGrid(BuildContext context, Web3Provider web3Provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и кнопка создания
          Row(
            children: [
              Text(
                'Мои NFT (${web3Provider.nfts.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showMintNFTDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Минт'),
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
          
          // Сетка NFT
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: web3Provider.nfts.length,
            itemBuilder: (context, index) {
              final nft = web3Provider.nfts[index];
              return _NFTCard(nft: nft);
            },
          ),
        ],
      ),
    );
  }

  void _showMintNFTDialog(BuildContext context) {
    // TODO: Реализовать диалог минтинга NFT
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция минтинга NFT в разработке')),
    );
  }
}

class _NFTCard extends StatelessWidget {
  final Map<String, dynamic> nft;

  const _NFTCard({required this.nft});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение NFT
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: nft['image_url'] != null
                    ? CachedNetworkImage(
                        imageUrl: nft['image_url'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
            ),
          ),
          
          // Информация об NFT
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название
                  Text(
                    nft['name'] ?? 'Без названия',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Описание
                  Text(
                    nft['description'] ?? 'Без описания',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // Тип токена и действия
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          nft['token_type'] ?? 'NFT',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleNFTAction(context, value),
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
                            value: 'sell',
                            child: Row(
                              children: [
                                Icon(Icons.sell, size: 16),
                                SizedBox(width: 8),
                                Text('Продать'),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(
                          Icons.more_vert,
                          size: 16,
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
  }

  void _handleNFTAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        _viewNFT(context);
        break;
      case 'transfer':
        _transferNFT(context);
        break;
      case 'sell':
        _sellNFT(context);
        break;
    }
  }

  void _viewNFT(BuildContext context) {
    // TODO: Реализовать просмотр NFT
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Просмотр NFT в разработке')),
    );
  }

  void _transferNFT(BuildContext context) {
    // TODO: Реализовать передачу NFT
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Передача NFT в разработке')),
    );
  }

  void _sellNFT(BuildContext context) {
    // TODO: Реализовать продажу NFT
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Продажа NFT в разработке')),
    );
  }
}
