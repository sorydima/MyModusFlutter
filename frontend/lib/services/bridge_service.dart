import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/matrix_models.dart';
import 'matrix_service.dart';
import 'package:flutter/foundation.dart';

class BridgeService extends ChangeNotifier {
  final MatrixService _matrixService;
  final List<BridgeConfig> _bridges = [];
  final Map<String, StreamSubscription> _bridgeSubscriptions = {};
  final StreamController<BridgeEvent> _eventStreamController =
      StreamController<BridgeEvent>.broadcast();

  BridgeService(this._matrixService);

  List<BridgeConfig> get bridges => _bridges;
  Stream<BridgeEvent> get eventStream => _eventStreamController.stream;

  Future<void> loadBridges() async {
    // Load bridges from local storage
    // For now, using mock data - in production, implement proper storage
    _bridges.clear();
    // TODO: Load from secure storage
    notifyListeners();
  }

  Future<void> addBridge(BridgeConfig config) async {
    try {
      // Validate bridge configuration
      await _validateBridgeConfig(config);

      // Test connection
      await _testBridgeConnection(config);

      _bridges.add(config);
      await _startBridgeMonitoring(config);

      // Save to storage
      await _saveBridges();

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add bridge: $e');
      rethrow;
    }
  }

  Future<void> updateBridge(String bridgeId, BridgeConfig updatedConfig) async {
    try {
      final index = _bridges.indexWhere((b) => b.id == bridgeId);
      if (index == -1) throw Exception('Bridge not found');

      // Stop monitoring old bridge
      await _stopBridgeMonitoring(bridgeId);

      // Validate and test new config
      await _validateBridgeConfig(updatedConfig);
      await _testBridgeConnection(updatedConfig);

      _bridges[index] = updatedConfig;
      await _startBridgeMonitoring(updatedConfig);

      // Save to storage
      await _saveBridges();

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update bridge: $e');
      rethrow;
    }
  }

  Future<void> removeBridge(String bridgeId) async {
    try {
      await _stopBridgeMonitoring(bridgeId);
      _bridges.removeWhere((b) => b.id == bridgeId);
      await _saveBridges();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to remove bridge: $e');
      rethrow;
    }
  }

  Future<void> _validateBridgeConfig(BridgeConfig config) async {
    if (config.name.isEmpty) throw Exception('Bridge name is required');
    if (config.serverUrl.isEmpty) throw Exception('Server URL is required');

    switch (config.type) {
      case BridgeType.irc:
        if (config.username == null || config.username!.isEmpty) {
          throw Exception('IRC bridge requires username');
        }
        break;
      case BridgeType.slack:
        if (config.token == null || config.token!.isEmpty) {
          throw Exception('Slack bridge requires token');
        }
        break;
      case BridgeType.discord:
        if (config.token == null || config.token!.isEmpty) {
          throw Exception('Discord bridge requires token');
        }
        break;
      case BridgeType.telegram:
        if (config.token == null || config.token!.isEmpty) {
          throw Exception('Telegram bridge requires bot token');
        }
        break;
      default:
        // Other bridges may have different requirements
        break;
    }
  }

  Future<void> _testBridgeConnection(BridgeConfig config) async {
    try {
      // Update status to connecting
      final index = _bridges.indexWhere((b) => b.id == config.id);
      if (index != -1) {
        _bridges[index] = config.copyWith(status: BridgeStatus.connecting);
        notifyListeners();
      }

      // Test connection based on bridge type
      switch (config.type) {
        case BridgeType.irc:
          await _testIRCConnection(config);
          break;
        case BridgeType.slack:
          await _testSlackConnection(config);
          break;
        case BridgeType.discord:
          await _testDiscordConnection(config);
          break;
        case BridgeType.telegram:
          await _testTelegramConnection(config);
          break;
        default:
          // For other bridges, just simulate success
          await Future.delayed(const Duration(seconds: 1));
          break;
      }

      // Update status to connected
      if (index != -1) {
        _bridges[index] = config.copyWith(
          status: BridgeStatus.connected,
          lastConnected: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      // Update status to error
      final index = _bridges.indexWhere((b) => b.id == config.id);
      if (index != -1) {
        _bridges[index] = config.copyWith(
          status: BridgeStatus.error,
          errorMessage: e.toString(),
        );
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> _testIRCConnection(BridgeConfig config) async {
    // Simulate IRC connection test
    await Future.delayed(const Duration(seconds: 2));
    // In production, implement actual IRC connection test
  }

  Future<void> _testSlackConnection(BridgeConfig config) async {
    try {
      final response = await http.get(
        Uri.parse('https://slack.com/api/auth.test'),
        headers: {'Authorization': 'Bearer ${config.token}'},
      );

      if (response.statusCode != 200) {
        throw Exception('Invalid Slack token');
      }

      final data = json.decode(response.body);
      if (!data['ok']) {
        throw Exception(data['error'] ?? 'Slack authentication failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to Slack: $e');
    }
  }

  Future<void> _testDiscordConnection(BridgeConfig config) async {
    try {
      final response = await http.get(
        Uri.parse('https://discord.com/api/users/@me'),
        headers: {'Authorization': 'Bot ${config.token}'},
      );

      if (response.statusCode != 200) {
        throw Exception('Invalid Discord token');
      }
    } catch (e) {
      throw Exception('Failed to connect to Discord: $e');
    }
  }

  Future<void> _testTelegramConnection(BridgeConfig config) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.telegram.org/bot${config.token}/getMe'),
      );

      if (response.statusCode != 200) {
        throw Exception('Invalid Telegram token');
      }

      final data = json.decode(response.body);
      if (!data['ok']) {
        throw Exception(data['description'] ?? 'Telegram authentication failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to Telegram: $e');
    }
  }

  Future<void> _startBridgeMonitoring(BridgeConfig config) async {
    // Create a periodic check for bridge health
    final subscription = Stream.periodic(const Duration(minutes: 5)).listen((_) async {
      try {
        await _testBridgeConnection(config);
      } catch (e) {
        debugPrint('Bridge health check failed for ${config.name}: $e');
        final index = _bridges.indexWhere((b) => b.id == config.id);
        if (index != -1) {
          _bridges[index] = config.copyWith(
            status: BridgeStatus.error,
            errorMessage: e.toString(),
          );
          notifyListeners();
        }
      }
    });

    _bridgeSubscriptions[config.id] = subscription;

    // Start monitoring messages/events from the bridge
    _startBridgeEventMonitoring(config);
  }

  Future<void> _stopBridgeMonitoring(String bridgeId) async {
    final subscription = _bridgeSubscriptions[bridgeId];
    if (subscription != null) {
      await subscription.cancel();
      _bridgeSubscriptions.remove(bridgeId);
    }
  }

  void _startBridgeEventMonitoring(BridgeConfig config) {
    // Monitor events from the legacy platform and forward to Matrix
    // This is a simplified implementation - in production, implement
    // proper event streaming for each bridge type

    switch (config.type) {
      case BridgeType.slack:
        _monitorSlackEvents(config);
        break;
      case BridgeType.discord:
        _monitorDiscordEvents(config);
        break;
      case BridgeType.telegram:
        _monitorTelegramEvents(config);
        break;
      default:
        // Other bridges would need their own monitoring implementations
        break;
    }
  }

  void _monitorSlackEvents(BridgeConfig config) {
    // Implement Slack RTM or Events API monitoring
    // This is a placeholder - actual implementation would use WebSocket or polling
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        // Check for new messages and forward to Matrix
        // Implementation depends on specific bridge setup
      } catch (e) {
        debugPrint('Error monitoring Slack events: $e');
      }
    });
  }

  void _monitorDiscordEvents(BridgeConfig config) {
    // Implement Discord Gateway monitoring
    // This is a placeholder - actual implementation would use WebSocket
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        // Check for new messages and forward to Matrix
        // Implementation depends on specific bridge setup
      } catch (e) {
        debugPrint('Error monitoring Discord events: $e');
      }
    });
  }

  void _monitorTelegramEvents(BridgeConfig config) {
    // Implement Telegram Bot API monitoring
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        // Check for new messages and forward to Matrix
        // Implementation depends on specific bridge setup
      } catch (e) {
        debugPrint('Error monitoring Telegram events: $e');
      }
    });
  }

  Future<void> sendMessageToBridge(String bridgeId, String message, {String? channel}) async {
    final bridge = _bridges.firstWhere((b) => b.id == bridgeId);

    try {
      switch (bridge.type) {
        case BridgeType.slack:
          await _sendSlackMessage(bridge, message, channel: channel);
          break;
        case BridgeType.discord:
          await _sendDiscordMessage(bridge, message, channel: channel);
          break;
        case BridgeType.telegram:
          await _sendTelegramMessage(bridge, message, channel: channel);
          break;
        default:
          throw Exception('Sending messages not implemented for ${bridge.type}');
      }

      // Emit bridge event
      final event = BridgeEvent(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        bridgeId: bridgeId,
        type: 'message_sent',
        data: {'message': message, 'channel': channel},
        timestamp: DateTime.now(),
        isIncoming: false,
      );
      _eventStreamController.add(event);
    } catch (e) {
      debugPrint('Failed to send message to bridge: $e');
      rethrow;
    }
  }

  Future<void> _sendSlackMessage(BridgeConfig bridge, String message, {String? channel}) async {
    final channelId = channel ?? bridge.settings['defaultChannel'];
    if (channelId == null) throw Exception('No channel specified for Slack bridge');

    final response = await http.post(
      Uri.parse('https://slack.com/api/chat.postMessage'),
      headers: {
        'Authorization': 'Bearer ${bridge.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'channel': channelId,
        'text': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send Slack message');
    }
  }

  Future<void> _sendDiscordMessage(BridgeConfig bridge, String message, {String? channel}) async {
    final channelId = channel ?? bridge.settings['defaultChannel'];
    if (channelId == null) throw Exception('No channel specified for Discord bridge');

    final response = await http.post(
      Uri.parse('https://discord.com/api/channels/$channelId/messages'),
      headers: {
        'Authorization': 'Bot ${bridge.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': message,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send Discord message');
    }
  }

  Future<void> _sendTelegramMessage(BridgeConfig bridge, String message, {String? channel}) async {
    final chatId = channel ?? bridge.settings['defaultChatId'];
    if (chatId == null) throw Exception('No chat ID specified for Telegram bridge');

    final response = await http.post(
      Uri.parse('https://api.telegram.org/bot${bridge.token}/sendMessage'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'chat_id': chatId,
        'text': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send Telegram message');
    }
  }

  Future<void> _saveBridges() async {
    // Save bridges to secure storage
    // TODO: Implement secure storage persistence
  }

  @override
  void dispose() {
    for (final subscription in _bridgeSubscriptions.values) {
      subscription.cancel();
    }
    _bridgeSubscriptions.clear();
    _eventStreamController.close();
    super.dispose();
  }
}
