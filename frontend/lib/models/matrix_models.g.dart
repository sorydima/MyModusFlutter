// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matrix_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BridgeConfig _$BridgeConfigFromJson(Map<String, dynamic> json) => BridgeConfig(
      id: json['id'] as String,
      type: $enumDecode(_$BridgeTypeEnumMap, json['type']),
      name: json['name'] as String,
      serverUrl: json['serverUrl'] as String,
      username: json['username'] as String?,
      password: json['password'] as String?,
      token: json['token'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      status: $enumDecodeNullable(_$BridgeStatusEnumMap, json['status']) ??
          BridgeStatus.disconnected,
      lastConnected: json['lastConnected'] == null
          ? null
          : DateTime.parse(json['lastConnected'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$BridgeConfigToJson(BridgeConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$BridgeTypeEnumMap[instance.type]!,
      'name': instance.name,
      'serverUrl': instance.serverUrl,
      'username': instance.username,
      'password': instance.password,
      'token': instance.token,
      'settings': instance.settings,
      'status': _$BridgeStatusEnumMap[instance.status]!,
      'lastConnected': instance.lastConnected?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

const _$BridgeTypeEnumMap = {
  BridgeType.irc: 'irc',
  BridgeType.slack: 'slack',
  BridgeType.discord: 'discord',
  BridgeType.telegram: 'telegram',
  BridgeType.whatsapp: 'whatsapp',
  BridgeType.signal: 'signal',
  BridgeType.xmpp: 'xmpp',
  BridgeType.email: 'email',
};

const _$BridgeStatusEnumMap = {
  BridgeStatus.connected: 'connected',
  BridgeStatus.connecting: 'connecting',
  BridgeStatus.disconnected: 'disconnected',
  BridgeStatus.error: 'error',
};

MatrixRoom _$MatrixRoomFromJson(Map<String, dynamic> json) => MatrixRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      topic: json['topic'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isDirect: json['isDirect'] as bool? ?? false,
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MatrixRoomToJson(MatrixRoom instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'topic': instance.topic,
      'avatarUrl': instance.avatarUrl,
      'members': instance.members,
      'isDirect': instance.isDirect,
      'isEncrypted': instance.isEncrypted,
      'lastActivity': instance.lastActivity.toIso8601String(),
      'unreadCount': instance.unreadCount,
    };

MatrixMessage _$MatrixMessageFromJson(Map<String, dynamic> json) =>
    MatrixMessage(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      timestamp: DateTime.parse(json['timestamp'] as String),
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MatrixMessageToJson(MatrixMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'content': instance.content,
      'type': instance.type,
      'timestamp': instance.timestamp.toIso8601String(),
      'isEncrypted': instance.isEncrypted,
      'metadata': instance.metadata,
    };

MatrixUser _$MatrixUserFromJson(Map<String, dynamic> json) => MatrixUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
    );

Map<String, dynamic> _$MatrixUserToJson(MatrixUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'isOnline': instance.isOnline,
      'lastSeen': instance.lastSeen?.toIso8601String(),
    };

BridgeEvent _$BridgeEventFromJson(Map<String, dynamic> json) => BridgeEvent(
      id: json['id'] as String,
      bridgeId: json['bridgeId'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isIncoming: json['isIncoming'] as bool,
    );

Map<String, dynamic> _$BridgeEventToJson(BridgeEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bridgeId': instance.bridgeId,
      'type': instance.type,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
      'isIncoming': instance.isIncoming,
    };
