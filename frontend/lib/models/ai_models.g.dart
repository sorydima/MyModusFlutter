// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIModel _$AIModelFromJson(Map<String, dynamic> json) => AIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      provider: json['provider'] as String,
      version: json['version'] as String,
      capabilities: json['capabilities'] as Map<String, dynamic>,
      isAvailable: json['isAvailable'] as bool,
      costPerToken: (json['costPerToken'] as num).toDouble(),
      maxTokens: (json['maxTokens'] as num).toInt(),
      contextLength: (json['contextLength'] as num).toInt(),
    );

Map<String, dynamic> _$AIModelToJson(AIModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'provider': instance.provider,
      'version': instance.version,
      'capabilities': instance.capabilities,
      'isAvailable': instance.isAvailable,
      'costPerToken': instance.costPerToken,
      'maxTokens': instance.maxTokens,
      'contextLength': instance.contextLength,
    };

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      contentType:
          $enumDecode(_$MessageContentTypeEnumMap, json['contentType']),
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      voiceUrl: json['voiceUrl'] as String?,
      fileUrl: json['fileUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      status: $enumDecode(_$MessageStatusEnumMap, json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      aiModelId: json['aiModelId'] as String?,
      tokenCount: (json['tokenCount'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'contentType': _$MessageContentTypeEnumMap[instance.contentType]!,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'voiceUrl': instance.voiceUrl,
      'fileUrl': instance.fileUrl,
      'metadata': instance.metadata,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'aiModelId': instance.aiModelId,
      'tokenCount': instance.tokenCount,
      'cost': instance.cost,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};

const _$MessageContentTypeEnumMap = {
  MessageContentType.text: 'text',
  MessageContentType.image: 'image',
  MessageContentType.voice: 'voice',
  MessageContentType.file: 'file',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.failed: 'failed',
};

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      aiModelId: json['aiModelId'] as String?,
      messageIds: (json['messageIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      settings: json['settings'] as Map<String, dynamic>?,
      isArchived: json['isArchived'] as bool,
    );

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'aiModelId': instance.aiModelId,
      'messageIds': instance.messageIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'settings': instance.settings,
      'isArchived': instance.isArchived,
    };

AISettings _$AISettingsFromJson(Map<String, dynamic> json) => AISettings(
      defaultModelId: json['defaultModelId'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      maxTokens: (json['maxTokens'] as num).toInt(),
      enableImageAnalysis: json['enableImageAnalysis'] as bool,
      enableVoiceRecognition: json['enableVoiceRecognition'] as bool,
      enableFileUpload: json['enableFileUpload'] as bool,
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AISettingsToJson(AISettings instance) =>
    <String, dynamic>{
      'defaultModelId': instance.defaultModelId,
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
      'enableImageAnalysis': instance.enableImageAnalysis,
      'enableVoiceRecognition': instance.enableVoiceRecognition,
      'enableFileUpload': instance.enableFileUpload,
      'customSettings': instance.customSettings,
    };

ImageAnalysisResult _$ImageAnalysisResultFromJson(Map<String, dynamic> json) =>
    ImageAnalysisResult(
      imageUrl: json['imageUrl'] as String,
      detectedObjects: (json['detectedObjects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      detectedStyles: (json['detectedStyles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      colorPalette: (json['colorPalette'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      fashionAnalysis: json['fashionAnalysis'] as Map<String, dynamic>?,
      recommendations: json['recommendations'] as Map<String, dynamic>?,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );

Map<String, dynamic> _$ImageAnalysisResultToJson(
        ImageAnalysisResult instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'detectedObjects': instance.detectedObjects,
      'detectedStyles': instance.detectedStyles,
      'colorPalette': instance.colorPalette,
      'description': instance.description,
      'fashionAnalysis': instance.fashionAnalysis,
      'recommendations': instance.recommendations,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
    };

ChatSuggestion _$ChatSuggestionFromJson(Map<String, dynamic> json) =>
    ChatSuggestion(
      id: json['id'] as String,
      text: json['text'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      iconName: json['iconName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChatSuggestionToJson(ChatSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'category': instance.category,
      'description': instance.description,
      'iconName': instance.iconName,
      'metadata': instance.metadata,
    };

AIUsageStats _$AIUsageStatsFromJson(Map<String, dynamic> json) => AIUsageStats(
      userId: json['userId'] as String,
      totalMessages: (json['totalMessages'] as num).toInt(),
      totalTokens: (json['totalTokens'] as num).toInt(),
      totalCost: (json['totalCost'] as num).toDouble(),
      modelUsage: Map<String, int>.from(json['modelUsage'] as Map),
      featureUsage: Map<String, int>.from(json['featureUsage'] as Map),
      lastUsed: DateTime.parse(json['lastUsed'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );

Map<String, dynamic> _$AIUsageStatsToJson(AIUsageStats instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalMessages': instance.totalMessages,
      'totalTokens': instance.totalTokens,
      'totalCost': instance.totalCost,
      'modelUsage': instance.modelUsage,
      'featureUsage': instance.featureUsage,
      'lastUsed': instance.lastUsed.toIso8601String(),
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
    };
