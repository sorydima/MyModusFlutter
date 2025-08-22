import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/mobile_capabilities_service.dart';

/// Вкладка геолокации
class GeolocationTab extends StatefulWidget {
  final MobileCapabilitiesService mobileService;

  const GeolocationTab({
    super.key,
    required this.mobileService,
  });

  @override
  State<GeolocationTab> createState() => _GeolocationTabState();
}

class _GeolocationTabState extends State<GeolocationTab> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;
  Position? _currentPosition;
  List<GeolocationOffer> _nearbyOffers = [];
  List<StoreInfo> _nearbyStores = [];

  @override
  void initState() {
    super.initState();
    _userIdController.text = 'demo_user_123';
    _radiusController.text = '5.0';
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _radiusController.dispose();
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
              'Геолокация',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Описание
            const Text(
              'Получайте местоположение и находите ближайшие предложения',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Форма
            _buildLocationForm(),
            const SizedBox(height: 24),
            
            // Кнопки действий
            _buildActionButtons(),
            const SizedBox(height: 24),
            
            // Статус
            if (_statusMessage != null)
              _buildStatusMessage(),
            
            const SizedBox(height: 24),
            
            // Текущее местоположение
            if (_currentPosition != null)
              _buildCurrentLocation(),
            
            const SizedBox(height: 24),
            
            // Ближайшие предложения
            if (_nearbyOffers.isNotEmpty)
              _buildNearbyOffers(),
            
            const SizedBox(height: 24),
            
            // Ближайшие магазины
            if (_nearbyStores.isNotEmpty)
              _buildNearbyStores(),
          ],
        ),
    );
  }

  Widget _buildLocationForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Настройки геолокации',
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
              controller: _radiusController,
              decoration: const InputDecoration(
                labelText: 'Радиус поиска (км)',
                border: OutlineInputBorder(),
                hintText: '5.0',
              ),
              keyboardType: TextInputType.number,
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
            onPressed: _isLoading ? null : _getCurrentLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Мое местоположение'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _findNearbyOffers,
            icon: const Icon(Icons.search),
            label: const Text('Найти предложения'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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

  Widget _buildCurrentLocation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Текущее местоположение',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Широта:', '${_currentPosition!.latitude.toStringAsFixed(6)}°'),
            _buildInfoRow('Долгота:', '${_currentPosition!.longitude.toStringAsFixed(6)}°'),
            _buildInfoRow('Точность:', '${_currentPosition!.accuracy.toStringAsFixed(1)} м'),
            if (widget.mobileService.currentAddress != null)
              _buildInfoRow('Адрес:', widget.mobileService.currentAddress!),
            _buildInfoRow('Время:', 
                '${_currentPosition!.timestamp.hour}:${_currentPosition!.timestamp.minute.toString().padLeft(2, '0')}'),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyOffers() {
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
                  'Ближайшие предложения',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_nearbyOffers.length} найдено',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ..._nearbyOffers.map((offer) => _buildOfferCard(offer)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(GeolocationOffer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.local_offer, color: Colors.blue),
        ),
        title: Text(offer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${offer.category} • ${offer.distance.toStringAsFixed(1)} км'),
            if (offer.offers.isNotEmpty)
              Text(
                offer.offers.first['type'] ?? '',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showOfferDetails(offer),
      ),
    );
  }

  Widget _buildNearbyStores() {
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
                  'Ближайшие магазины',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_nearbyStores.length} найдено',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ..._nearbyStores.map((store) => _buildStoreCard(store)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(StoreInfo store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.store, color: Colors.orange),
        ),
        title: Text(store.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${store.category} • ${store.distance.toStringAsFixed(1)} км'),
            Text(store.address),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                Text(' ${store.rating.toStringAsFixed(1)}'),
                if (store.offers.isNotEmpty)
                  Text(' • ${store.offers.first}'),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showStoreDetails(store),
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

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      final position = await widget.mobileService.getCurrentLocation();
      
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
        _showStatus(true, 'Местоположение получено успешно');
      } else {
        _showStatus(false, 'Не удалось получить местоположение');
      }
      
    } catch (e) {
      _showStatus(false, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _findNearbyOffers() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _userIdController.text.trim();
      final radius = double.tryParse(_radiusController.text) ?? 5.0;
      
      if (userId.isEmpty) {
        _showStatus(false, 'Введите ID пользователя');
        return;
      }
      
      final offers = await widget.mobileService.getNearbyOffers(
        userId: userId,
        radiusKm: radius,
      );
      
      final stores = await widget.mobileService.getNearbyStores(
        userId: userId,
        radiusKm: radius,
      );
      
      setState(() {
        _nearbyOffers = offers;
        _nearbyStores = stores;
      });
      
      _showStatus(true, 'Найдено ${offers.length} предложений и ${stores.length} магазинов');
      
    } catch (e) {
      _showStatus(false, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOfferDetails(GeolocationOffer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(offer.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Категория: ${offer.category}'),
            Text('Расстояние: ${offer.distance.toStringAsFixed(1)} км'),
            Text('Координаты: ${offer.latitude.toStringAsFixed(6)}, ${offer.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 16),
            const Text('Предложения:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...offer.offers.map((o) => Text('• ${o['type']}: ${o['description']}')),
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

  void _showStoreDetails(StoreInfo store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(store.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Категория: ${store.category}'),
            Text('Расстояние: ${store.distance.toStringAsFixed(1)} км'),
            Text('Адрес: ${store.address}'),
            Text('Рейтинг: ${store.rating.toStringAsFixed(1)} ⭐'),
            const SizedBox(height: 16),
            const Text('Акции:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...store.offers.map((offer) => Text('• $offer')),
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
