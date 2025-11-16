import 'package:flutter/foundation.dart';
import '../services/matrix_service.dart';
import '../services/bridge_service.dart';
import '../models/matrix_models.dart';

class MatrixProvider extends ChangeNotifier {
  final MatrixService _matrixService;
  final BridgeService _bridgeService;

  MatrixProvider()
      : _matrixService = MatrixService(),
        _bridgeService = BridgeService(MatrixService()) {
    _initialize();
  }

  MatrixService get matrixService => _matrixService;
  BridgeService get bridgeService => _bridgeService;

  bool get isMatrixInitialized => _matrixService.isInitialized;
  List<MatrixRoom> get rooms => _matrixService.rooms;
  List<BridgeConfig> get bridges => _bridgeService.bridges;

  Future<void> _initialize() async {
    await _bridgeService.loadBridges();
    notifyListeners();
  }

  Future<void> initializeMatrix({
    required String homeserverUrl,
    String? accessToken,
    String? userId,
  }) async {
    try {
      await _matrixService.initialize(
        homeserverUrl: homeserverUrl,
        accessToken: accessToken,
        userId: userId,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize Matrix: $e');
      rethrow;
    }
  }

  Future<void> loginMatrix({
    required String username,
    required String password,
    String? homeserverUrl,
  }) async {
    try {
      await _matrixService.login(
        username: username,
        password: password,
        homeserverUrl: homeserverUrl,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to login to Matrix: $e');
      rethrow;
    }
  }

  Future<void> logoutMatrix() async {
    try {
      await _matrixService.logout();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to logout from Matrix: $e');
      rethrow;
    }
  }

  Future<void> sendMatrixMessage(String roomId, String message) async {
    try {
      await _matrixService.sendMessage(roomId, message);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to send Matrix message: $e');
      rethrow;
    }
  }

  Future<void> joinMatrixRoom(String roomIdOrAlias) async {
    try {
      await _matrixService.joinRoom(roomIdOrAlias);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to join Matrix room: $e');
      rethrow;
    }
  }

  Future<void> leaveMatrixRoom(String roomId) async {
    try {
      await _matrixService.leaveRoom(roomId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to leave Matrix room: $e');
      rethrow;
    }
  }

  Future<void> addBridge(BridgeConfig config) async {
    try {
      await _bridgeService.addBridge(config);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add bridge: $e');
      rethrow;
    }
  }

  Future<void> updateBridge(String bridgeId, BridgeConfig config) async {
    try {
      await _bridgeService.updateBridge(bridgeId, config);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update bridge: $e');
      rethrow;
    }
  }

  Future<void> removeBridge(String bridgeId) async {
    try {
      await _bridgeService.removeBridge(bridgeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to remove bridge: $e');
      rethrow;
    }
  }

  Future<void> sendMessageToBridge(String bridgeId, String message, {String? channel}) async {
    try {
      await _bridgeService.sendMessageToBridge(bridgeId, message, channel: channel);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to send message to bridge: $e');
      rethrow;
    }
  }

  Stream<MatrixMessage> get matrixMessageStream => _matrixService.messageStream;
  Stream<BridgeEvent> get bridgeEventStream => _bridgeService.eventStream;

  @override
  void dispose() {
    _matrixService.dispose();
    _bridgeService.dispose();
    super.dispose();
  }
}
