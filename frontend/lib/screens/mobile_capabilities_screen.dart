import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mobile_capabilities_service.dart';
import '../widgets/offline_mode_tab.dart';
import '../widgets/geolocation_tab.dart';
import '../widgets/calendar_tab.dart';
import '../widgets/background_sync_tab.dart';

/// Главный экран мобильных возможностей приложения
class MobileCapabilitiesScreen extends StatefulWidget {
  const MobileCapabilitiesScreen({super.key});

  @override
  State<MobileCapabilitiesScreen> createState() => _MobileCapabilitiesScreenState();
}

class _MobileCapabilitiesScreenState extends State<MobileCapabilitiesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📱 Мобильные возможности'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.offline_bolt), text: 'Офлайн режим'),
            Tab(icon: Icon(Icons.location_on), text: 'Геолокация'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Календарь'),
            Tab(icon: Icon(Icons.sync), text: 'Синхронизация'),
          ],
        ),
      ),
      body: Consumer<MobileCapabilitiesService>(
        builder: (context, mobileService, child) {
          return Column(
            children: [
              // Статус подключения
              _buildConnectionStatus(mobileService),
              
              // Содержимое вкладок
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    OfflineModeTab(mobileService: mobileService),
                    GeolocationTab(mobileService: mobileService),
                    CalendarTab(mobileService: mobileService),
                    BackgroundSyncTab(mobileService: mobileService),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(MobileCapabilitiesService mobileService) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: mobileService.isOnline ? Colors.green.shade50 : Colors.red.shade50,
      child: Row(
        children: [
          Icon(
            mobileService.isOnline ? Icons.wifi : Icons.wifi_off,
            color: mobileService.isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            mobileService.isOnline ? 'Онлайн' : 'Офлайн',
            style: TextStyle(
              color: mobileService.isOnline ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (mobileService.isLocationEnabled)
            const Icon(Icons.location_on, color: Colors.blue),
          if (mobileService.isBackgroundSyncEnabled)
            const Icon(Icons.sync, color: Colors.orange),
        ],
      ),
    );
  }
}
