import 'package:flutter/material.dart';
import '../services/mobile_capabilities_service.dart';

/// Вкладка фоновой синхронизации
class BackgroundSyncTab extends StatefulWidget {
  final MobileCapabilitiesService mobileService;

  const BackgroundSyncTab({
    super.key,
    required this.mobileService,
  });

  @override
  State<BackgroundSyncTab> createState() => _BackgroundSyncTabState();
}

class _BackgroundSyncTabState extends State<BackgroundSyncTab> {
  final TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;
  bool _isAutoSyncEnabled = false;
  String _lastSyncTime = 'Никогда';
  int _syncedItems = 0;
  int _failedItems = 0;

  @override
  void initState() {
    super.initState();
    _userIdController.text = 'demo_user_123';
    _isAutoSyncEnabled = widget.mobileService.isBackgroundSyncEnabled;
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          const Text(
            'Фоновая синхронизация',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Описание
          const Text(
            'Автоматическая синхронизация данных в фоновом режиме',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Настройки синхронизации
          _buildSyncSettings(),
          const SizedBox(height: 24),
          
          // Статус синхронизации
          _buildSyncStatus(),
          const SizedBox(height: 24),
          
          // Кнопки управления
          _buildActionButtons(),
          const SizedBox(height: 24),
          
          // Статус операций
          if (_statusMessage != null)
            _buildStatusMessage(),
          
          const SizedBox(height: 24),
          
          // Информация о синхронизации
          _buildSyncInfo(),
        ],
      ),
    );
  }

  Widget _buildSyncSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Настройки синхронизации',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'ID пользователя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Автоматическая синхронизация'),
              subtitle: const Text('Синхронизировать данные автоматически'),
              value: _isAutoSyncEnabled,
              onChanged: (value) {
                setState(() {
                  _isAutoSyncEnabled = value;
                });
                // В реальном приложении здесь должно быть изменение настроек
              },
              secondary: Icon(
                _isAutoSyncEnabled ? Icons.sync : Icons.sync_disabled,
                color: _isAutoSyncEnabled ? Colors.green : Colors.grey,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Параметры синхронизации:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            _buildSyncParameter('Интервал синхронизации:', 'Каждый час'),
            _buildSyncParameter('Типы данных:', 'Продукты, уведомления, настройки'),
            _buildSyncParameter('Условия:', 'При подключении к Wi-Fi'),
            _buildSyncParameter('Батарея:', 'Только при зарядке'),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncParameter(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Статус синхронизации',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Consumer<MobileCapabilitiesService>(
                  builder: (context, mobileService, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: mobileService.isOnline ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        mobileService.isOnline ? 'Онлайн' : 'Офлайн',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Consumer<MobileCapabilitiesService>(
              builder: (context, mobileService, child) {
                return Column(
                  children: [
                    _buildStatusRow(
                      'Подключение к интернету:',
                      mobileService.isOnline ? 'Активно' : 'Отсутствует',
                      mobileService.isOnline ? Colors.green : Colors.red,
                    ),
                    _buildStatusRow(
                      'Геолокация:',
                      mobileService.isLocationEnabled ? 'Разрешена' : 'Заблокирована',
                      mobileService.isLocationEnabled ? Colors.green : Colors.orange,
                    ),
                    _buildStatusRow(
                      'Фоновая синхронизация:',
                      mobileService.isBackgroundSyncEnabled ? 'Включена' : 'Отключена',
                      mobileService.isBackgroundSyncEnabled ? Colors.green : Colors.grey,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _startManualSync,
                icon: const Icon(Icons.sync),
                label: const Text('Запустить синхронизацию'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkConnectivity,
                icon: const Icon(Icons.wifi),
                label: const Text('Проверить подключение'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _forceSync,
                icon: const Icon(Icons.sync_problem),
                label: const Text('Принудительная синхронизация'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _clearSyncData,
                icon: const Icon(Icons.clear_all),
                label: const Text('Очистить данные'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isSuccess ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isSuccess ? Icons.check_circle : Icons.error,
            color: _isSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage!,
              style: TextStyle(
                color: _isSuccess ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о синхронизации',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Последняя синхронизация:', _lastSyncTime),
            _buildInfoRow('Синхронизировано элементов:', _syncedItems.toString()),
            _buildInfoRow('Ошибок синхронизации:', _failedItems.toString()),
            _buildInfoRow('Следующая синхронизация:', _getNextSyncTime()),
            _buildInfoRow('Размер кэша:', _getCacheSize()),
            
            const SizedBox(height: 16),
            
            const Divider(),
            
            const Text(
              'Статистика за сегодня:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            _buildInfoRow('Успешных операций:', '15'),
            _buildInfoRow('Попыток синхронизации:', '8'),
            _buildInfoRow('Время работы:', '2ч 30м'),
            _buildInfoRow('Экономия трафика:', '45%'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  String _getNextSyncTime() {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    return '${nextHour.hour.toString().padLeft(2, '0')}:00';
  }

  String _getCacheSize() {
    // В реальном приложении здесь должен быть расчет размера кэша
    return '2.4 МБ';
  }

  // ===== ДЕЙСТВИЯ =====

  Future<void> _startManualSync() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _userIdController.text.trim();
      if (userId.isEmpty) {
        _showStatus(false, 'Введите ID пользователя');
        return;
      }
      
      // Устанавливаем пользователя для синхронизации
      widget.mobileService.setCurrentUser(userId);
      
      // Запускаем синхронизацию
      await widget.mobileService.forceSync();
      
      // Обновляем статистику
      setState(() {
        _lastSyncTime = _formatDateTime(DateTime.now());
        _syncedItems = 15; // Демо данные
        _failedItems = 0;
      });
      
      _showStatus(true, 'Синхронизация завершена успешно');
      
    } catch (e) {
      _showStatus(false, 'Ошибка синхронизации: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkConnectivity() async {
    setState(() => _isLoading = true);
    
    try {
      await widget.mobileService.checkConnectivity();
      
      _showStatus(true, 'Проверка подключения завершена');
      
    } catch (e) {
      _showStatus(false, 'Ошибка проверки: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forceSync() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _userIdController.text.trim();
      if (userId.isEmpty) {
        _showStatus(false, 'Введите ID пользователя');
        return;
      }
      
      // Принудительная синхронизация всех данных
      await widget.mobileService.forceSync();
      
      _showStatus(true, 'Принудительная синхронизация завершена');
      
    } catch (e) {
      _showStatus(false, 'Ошибка принудительной синхронизации: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearSyncData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить данные синхронизации?'),
        content: const Text(
          'Это действие удалит все локальные данные и кэш. '
          'Данные будут загружены заново при следующей синхронизации.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmClearSyncData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  void _confirmClearSyncData() async {
    setState(() => _isLoading = true);
    
    try {
      // Очищаем данные пользователя
      widget.mobileService.clearUserData();
      
      // Сбрасываем статистику
      setState(() {
        _lastSyncTime = 'Никогда';
        _syncedItems = 0;
        _failedItems = 0;
      });
      
      _showStatus(true, 'Данные синхронизации очищены');
      
    } catch (e) {
      _showStatus(false, 'Ошибка очистки: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showStatus(bool success, String message) {
    setState(() {
      _isSuccess = success;
      _statusMessage = message;
    });
    
    // Автоматически скрываем сообщение через 5 секунд
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _statusMessage = null;
        });
      }
    });
  }
}
