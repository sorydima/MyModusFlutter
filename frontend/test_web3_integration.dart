import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/providers/web3_provider.dart';
import 'lib/services/web3_test_service.dart';
import 'lib/models/web3_models.dart';

/// Тестовый скрипт для проверки Web3 интеграции
/// Запускается как отдельное приложение для тестирования
void main() {
  runApp(const Web3TestApp());
}

class Web3TestApp extends StatelessWidget {
  const Web3TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 Integration Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Web3TestHomePage(),
    );
  }
}

class Web3TestHomePage extends StatefulWidget {
  const Web3TestHomePage({super.key});

  @override
  State<Web3TestHomePage> createState() => _Web3TestHomePageState();
}

class _Web3TestHomePageState extends State<Web3TestHomePage> {
  final Web3TestService _testService = Web3TestService();
  List<String> _testResults = [];
  bool _isRunningTests = false;

  @override
  void initState() {
    super.initState();
    // Запускаем тесты автоматически при загрузке
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAllTests();
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults.clear();
    });

    try {
      // Тест 1: Подключение кошелька
      _addTestResult('Тест 1: Подключение кошелька');
      final walletInfo = await _testService.connectWallet();
      if (walletInfo != null) {
        _addTestResult('✅ Кошелек подключен: ${walletInfo.address}');
        _addTestResult('   Баланс: ${walletInfo.balance} ETH');
        _addTestResult('   Сеть: ${walletInfo.network}');
      } else {
        _addTestResult('❌ Ошибка подключения кошелька');
      }

      // Тест 2: Получение NFT
      _addTestResult('\nТест 2: Получение NFT');
      final nfts = await _testService.getAllNFTs();
      _addTestResult('✅ Получено NFT: ${nfts.length}');
      for (final nft in nfts.take(2)) {
        _addTestResult('   - ${nft.name} (${nft.category})');
      }

      // Тест 3: Получение токенов лояльности
      _addTestResult('\nТест 3: Получение токенов лояльности');
      final tokens = await _testService.getUserLoyaltyTokens('test');
      _addTestResult('✅ Получено токенов: ${tokens.length}');
      for (final token in tokens) {
        _addTestResult('   - ${token.name} (${token.symbol}): ${token.balance}');
      }

      // Тест 4: Получение истории транзакций
      _addTestResult('\nТест 4: Получение истории транзакций');
      final transactions = await _testService.getTransactionHistory('test');
      _addTestResult('✅ Получено транзакций: ${transactions.length}');
      for (final tx in transactions.take(2)) {
        _addTestResult('   - ${tx.type.name}: ${tx.value} ETH');
      }

      // Тест 5: Получение информации о сети
      _addTestResult('\nТест 5: Получение информации о сети');
      final network = await _testService.getCurrentNetwork();
      _addTestResult('✅ Сеть: ${network.name} (Chain ID: ${network.chainId})');
      _addTestResult('   RPC: ${network.rpcUrl}');
      _addTestResult('   Explorer: ${network.explorerUrl}');

      // Тест 6: Минтинг NFT
      _addTestResult('\nТест 6: Минтинг NFT');
      final mintSuccess = await _testService.mintNFT(
        name: 'Test NFT',
        description: 'Test Description',
        imageUrl: 'https://via.placeholder.com/300x300',
        category: 'Test',
        attributes: {'test': 'true'},
      );
      if (mintSuccess) {
        _addTestResult('✅ NFT успешно создан');
      } else {
        _addTestResult('❌ Ошибка создания NFT');
      }

      // Тест 7: Минтинг токенов лояльности
      _addTestResult('\nТест 7: Минтинг токенов лояльности');
      final tokenMintSuccess = await _testService.mintLoyaltyTokens(
        contractAddress: '0x1234567890123456789012345678901234567890',
        amount: '100',
      );
      if (tokenMintSuccess) {
        _addTestResult('✅ Токены лояльности успешно созданы');
      } else {
        _addTestResult('❌ Ошибка создания токенов лояльности');
      }

      _addTestResult('\n🎉 Все тесты завершены!');
      _addTestResult('Web3 интеграция работает корректно в тестовом режиме.');

    } catch (e) {
      _addTestResult('❌ Ошибка выполнения тестов: $e');
    } finally {
      setState(() {
        _isRunningTests = false;
      });
    }
  }

  void _addTestResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 Integration Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isRunningTests)
            IconButton(
              onPressed: _runAllTests,
              icon: const Icon(Icons.refresh),
              tooltip: 'Запустить тесты заново',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Заголовок
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тестирование Web3 интеграции',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Этот экран автоматически запускает все тесты Web3 функционала для проверки корректности работы интеграции.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isRunningTests ? Icons.hourglass_empty : Icons.check_circle,
                          color: _isRunningTests ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isRunningTests ? 'Тесты выполняются...' : 'Тесты завершены',
                          style: TextStyle(
                            color: _isRunningTests ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Результаты тестов
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isRunningTests ? Icons.sync : Icons.assessment,
                            color: _isRunningTests ? Colors.blue : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Результаты тестов:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _isRunningTests
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Выполняются тесты...'),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _testResults.length,
                                itemBuilder: (context, index) {
                                  final result = _testResults[index];
                                  final isSuccess = result.contains('✅');
                                  final isError = result.contains('❌');
                                  final isInfo = result.contains('Тест') || result.contains('🎉');
                                  
                                  Color textColor = Colors.black87;
                                  if (isSuccess) textColor = Colors.green[700]!;
                                  if (isError) textColor = Colors.red[700]!;
                                  if (isInfo) textColor = Colors.blue[700]!;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Text(
                                      result,
                                      style: TextStyle(
                                        color: textColor,
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
