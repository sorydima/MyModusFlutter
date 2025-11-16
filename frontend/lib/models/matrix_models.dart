import 'package:json_annotation/json_annotation.dart';

part 'matrix_models.g.dart';

enum BridgeType {
  @JsonValue('irc')
  irc,
  @JsonValue('slack')
  slack,
  @JsonValue('discord')
  discord,
  @JsonValue('telegram')
  telegram,
  @JsonValue('whatsapp')
  whatsapp,
  @JsonValue('signal')
  signal,
  @JsonValue('xmpp')
  xmpp,
  @JsonValue('email')
  email,
}

enum BridgeStatus {
  @JsonValue('connected')
  connected,
  @JsonValue('connecting')
  connecting,
  @JsonValue('disconnected')
  disconnected,
  @JsonValue('error')
  error,
}

@JsonSerializable()
class BridgeConfig {
  final String id;
  final BridgeType type;
  final String name;
  final String serverUrl;
  final String? username;
  final String? password;
  final String? token;
  final Map<String, dynamic> settings;
  final BridgeStatus status;
  final DateTime? lastConnected;
  final String? errorMessage;

  BridgeConfig({
    required this.id,
    required this.type,
    required this.name,
    required this.serverUrl,
    this.username,
    this.password,
    this.token,
    this.settings = const {},
    this.status = BridgeStatus.disconnected,
    this.lastConnected,
    this.errorMessage,
  });

  factory BridgeConfig.fromJson(Map<String, dynamic> json) =>
      _$BridgeConfigFromJson(json);

  Map<String, dynamic> toJson() => _$BridgeConfigToJson(this);

  BridgeConfig copyWith({
    String? id,
    BridgeType? type,
    String? name,
    String? serverUrl,
    String? username,
    String? password,
    String? token,
    Map<String, dynamic>? settings,
    BridgeStatus? status,
    DateTime? lastConnected,
    String? errorMessage,
  }) {
    return BridgeConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      settings: settings ?? this.settings,
      status: status ?? this.status,
      lastConnected: lastConnected ?? this.lastConnected,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@JsonSerializable()
class MatrixRoom {
  final String id;
  final String name;
  final String? topic;
  final String? avatarUrl;
  final List<String> members;
  final bool isDirect;
  final bool isEncrypted;
  final DateTime lastActivity;
  final int unreadCount;

  MatrixRoom({
    required this.id,
    required this.name,
    this.topic,
    this.avatarUrl,
    this.members = const [],
    this.isDirect = false,
    this.isEncrypted = false,
    required this.lastActivity,
    this.unreadCount = 0,
  });

  factory MatrixRoom.fromJson(Map<String, dynamic> json) =>
      _$MatrixRoomFromJson(json);

  Map<String, dynamic> toJson() => _$MatrixRoomToJson(this);
}

@JsonSerializable()
class MatrixMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  final String type; // 'text', 'image', 'file', etc.
  final DateTime timestamp;
  final bool isEncrypted;
  final Map<String, dynamic>? metadata;

  MatrixMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = 'text',
    required this.timestamp,
    this.isEncrypted = false,
    this.metadata,
  });

  factory MatrixMessage.fromJson(Map<String, dynamic> json) =>
      _$MatrixMessageFromJson(json);

  Map<String, dynamic> toJson() => _$MatrixMessageToJson(this);
}

@JsonSerializable()
class MatrixUser {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  MatrixUser({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  factory MatrixUser.fromJson(Map<String, dynamic> json) =>
      _$MatrixUserFromJson(json);

  Map<String, dynamic> toJson() => _$MatrixUserToJson(this);
}

@JsonSerializable()
class BridgeEvent {
  final String id;
  final String bridgeId;
  final String type; // 'message', 'join', 'leave', 'error', etc.
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isIncoming; // true if from legacy platform to Matrix

  BridgeEvent({
    required this.id,
    required this.bridgeId,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.isIncoming,
  });

  factory BridgeEvent.fromJson(Map<String, dynamic> json) =>
      _$BridgeEventFromJson(json);

  Map<String, dynamic> toJson() => _$BridgeEventToJson(this);
}
