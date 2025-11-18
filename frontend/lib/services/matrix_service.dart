import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:hive/hive.dart';
import '../models/matrix_models.dart';
import 'package:flutter/foundation.dart';

class MatrixService extends ChangeNotifier {
  Client? _client;
  bool _isInitialized = false;
  final List<MatrixRoom> _rooms = [];
  final List<MatrixMessage> _messages = [];
  final StreamController<MatrixMessage> _messageStreamController =
      StreamController<MatrixMessage>.broadcast();

  Client? get client => _client;
  bool get isInitialized => _isInitialized;
  List<MatrixRoom> get rooms => _rooms;
  List<MatrixMessage> get messages => _messages;
  Stream<MatrixMessage> get messageStream => _messageStreamController.stream;

  Future<void> initialize({
    required String homeserverUrl,
    String? accessToken,
    String? userId,
  }) async {
    if (_isInitialized) return;

    try {
      // Get the application documents directory
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dir.path, 'matrix');

      // Create directory if it doesn't exist
      final matrixDir = Directory(dbPath);
      if (!await matrixDir.exists()) {
        await matrixDir.create(recursive: true);
      }

      // Initialize Hive database for Matrix
      final database = HiveCollectionDatabase(
        'matrix_client',
        path: dbPath,
      );

      _client = Client(
        'MyModus',
        database: database,
        supportedLoginTypes: {
          AuthenticationTypes.password,
          AuthenticationTypes.sso,
        },
      );

      await _client!.checkHomeserver(Uri.parse(homeserverUrl));
      _client!.homeserver = Uri.parse(homeserverUrl);

      if (accessToken != null && userId != null) {
        await _client!.init(
          newToken: accessToken,
          newUserID: userId,
        );
      } else {
        await _client!.init();
      }

      // Set up event listeners
      _client!.onSync.stream.listen(_onSync);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize Matrix client: $e');
      rethrow;
    }
  }

  Future<void> login({
    required String username,
    required String password,
    String? homeserverUrl,
  }) async {
    if (_client == null) throw Exception('Matrix client not initialized');

    try {
      await _client!.login(
        LoginType.mLoginPassword,
        identifier: AuthenticationUserIdentifier(user: username),
        password: password,
        initialDeviceDisplayName: 'MyModus App',
      );

      await _loadRooms();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to login: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_client == null) return;

    try {
      await _client!.logout();
      _rooms.clear();
      _messages.clear();
      _isInitialized = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to logout: $e');
      rethrow;
    }
  }

  Future<void> _loadRooms() async {
    if (_client == null) return;

    try {
      final joinedRooms = _client!.rooms.where((room) => room.membership == Membership.join);

      _rooms.clear();
      for (final room in joinedRooms) {
        final matrixRoom = MatrixRoom(
          id: room.id,
          name: room.getLocalizedDisplayname(),
          topic: room.topic,
          avatarUrl: room.avatar?.toString(),
          members: room.getParticipants().map((user) => user.id).toList(),
          isDirect: room.isDirectChat,
          isEncrypted: room.encrypted,
          lastActivity: room.lastEvent?.originServerTs ?? DateTime.now(),
          unreadCount: room.notificationCount,
        );
        _rooms.add(matrixRoom);
      }

      _rooms.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load rooms: $e');
    }
  }

  Future<void> sendMessage(String roomId, String message) async {
    if (_client == null) throw Exception('Matrix client not initialized');

    try {
      final room = _client!.getRoomById(roomId);
      if (room == null) throw Exception('Room not found');

      await room.sendTextEvent(message);

      final matrixMessage = MatrixMessage(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: _client!.userID!,
        senderName: _client!.userID!.split(':')[0],
        content: message,
        timestamp: DateTime.now(),
      );

      _messages.add(matrixMessage);
      _messageStreamController.add(matrixMessage);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to send message: $e');
      rethrow;
    }
  }

  Future<void> joinRoom(String roomIdOrAlias) async {
    if (_client == null) throw Exception('Matrix client not initialized');

    try {
      await _client!.joinRoom(roomIdOrAlias);
      await _loadRooms();
    } catch (e) {
      debugPrint('Failed to join room: $e');
      rethrow;
    }
  }

  Future<void> leaveRoom(String roomId) async {
    if (_client == null) throw Exception('Matrix client not initialized');

    try {
      final room = _client!.getRoomById(roomId);
      if (room != null) {
        await room.leave();
      }
      await _loadRooms();
    } catch (e) {
      debugPrint('Failed to leave room: $e');
      rethrow;
    }
  }

  void _onSync(SyncUpdate syncUpdate) {
    // Handle sync updates
    _loadRooms();
  }

  @override
  void dispose() {
    _messageStreamController.close();
    _client?.dispose();
    super.dispose();
  }
}
