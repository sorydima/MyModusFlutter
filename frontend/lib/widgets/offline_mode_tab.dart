import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/mobile_capabilities_service.dart';

/// Вкладка офлайн режима
class OfflineModeTab extends StatefulWidget {
  final MobileCapabilitiesService mobileService;

  const OfflineModeTab({
    super.key,
    required this.mobileService,
  });

  @override
  State<OfflineModeTab> createState() => _OfflineModeTabState();
}

class _OfflineModeTabState extends State<OfflineModeTab> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _dataTypeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _userIdController.text = 'demo_user_123';
    _dataTypeController.text = 'products';
    _dataController.text = '{"name": "Демо товар", "price": 1000}';
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _dataTypeController.dispose();
    _dataController.dispose();
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
            'Офлайн режим',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Описание
          const Text(
            'Сохраняйте данные локально и синхронизируйте их при подключении к интернету',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Форма сохранения данных
          _buildSaveDataForm(),
          const SizedBox(height: 24),
          
          // Кнопки управления
          _buildActionButtons(),
          const SizedBox(height: 24),
          
          // Статус
          if (_statusMessage != null)
            _buildStatusMessage(),
          
          const SizedBox(height: 24),
          
          // Информация о кэше
          _buildCacheInfo(),
        ],
      ),
    );
  }

  Widget _buildSaveDataForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сохранить данные в кэш',
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
            
            TextField(
              controller: _dataTypeController,
              decoration: const InputDecoration(
                labelText: 'Тип данных',
                border: OutlineInputBorder(),
                hintText: 'products, notifications, preferences',
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(
                labelText: 'Данные (JSON)',
                border: OutlineInputBorder(),
                hintText: '{"key": "value"}',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveToCache,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Сохранить в кэш'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _syncData,
            icon: const Icon(Icons.sync),
            label: const Text('Синхронизировать'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _clearCache,
            icon: const Icon(Icons.clear),
            label: const Text('Очистить кэш'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
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

  Widget _buildCacheInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о кэше',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Consumer<MobileCapabilitiesService>(
              builder: (context, mobileService, child) {
                final cache = mobileService._localCache;
                final totalUsers = cache.length;
                final totalDataTypes = cache.values
                    .map((userCache) => userCache.length)
                    .fold(0, (sum, count) => sum + count);
                
                return Column(
                  children: [
                    _buildInfoRow('Пользователей в кэше:', totalUsers.toString()),
                    _buildInfoRow('Типов данных:', totalDataTypes.toString()),
                    _buildInfoRow('Статус подключения:', 
                        mobileService.isOnline ? 'Онлайн' : 'Офлайн'),
                  ],
                );
              },
            ),
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

  // ===== ДЕЙСТВИЯ =====

  Future<void> _saveToCache() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _userIdController.text.trim();
      final dataType = _dataTypeController.text.trim();
      final dataString = _dataController.text.trim();
      
      if (userId.isEmpty || dataType.isEmpty || dataString.isEmpty) {
        _showStatus(false, 'Заполните все поля');
        return;
      }
      
      Map<String, dynamic> data;
      try {
        data = jsonDecode(dataString);
      } catch (e) {
        _showStatus(false, 'Неверный формат JSON');
        return;
      }
      
      await widget.mobileService.saveToLocalCache(
        userId: userId,
        dataType: dataType,
        data: data,
      );
      
      _showStatus(true, 'Данные успешно сохранены в кэш');
      
      // Очищаем поля
      _dataController.clear();
      _dataTypeController.clear();
      
    } catch (e) {
      _showStatus(false, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncData() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _userIdController.text.trim();
      if (userId.isEmpty) {
        _showStatus(false, 'Введите ID пользователя');
        return;
      }
      
      final success = await widget.mobileService.syncLocalData(userId: userId);
      
      if (success) {
        _showStatus(true, 'Синхронизация завершена успешно');
      } else {
        _showStatus(false, 'Синхронизация не удалась');
      }
      
    } catch (e) {
      _showStatus(false, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearCache() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _userIdController.text.trim();
      if (userId.isEmpty) {
        _showStatus(false, 'Введите ID пользователя');
        return;
      }
      
      // Очищаем кэш для пользователя
      widget.mobileService.clearUserData();
      
      _showStatus(true, 'Кэш очищен');
      
    } catch (e) {
      _showStatus(false, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
