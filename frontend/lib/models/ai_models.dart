import 'package:json_annotation/json_annotation.dart';

part 'ai_models.g.dart';

/// Роль сообщения в чате
enum MessageRole {
  user,      // Пользователь
  assistant, // AI ассистент
  system,    // Системное сообщение
}

/// Тип контента сообщения
enum MessageContentType {
  text,      // Текстовое сообщение
  image,     // Изображение
  voice,     // Голосовое сообщение
  file,      // Файл
}

/// Статус сообщения
enum MessageStatus {
  sending,   // Отправляется
  sent,      // Отправлено
  delivered, // Доставлено
  failed,    // Ошибка
}

/// AI модель
@JsonSerializable()
class AIModel {
  final String id;
  final String name;
  final String description;
  final String provider;
  final String version;
  final Map<String, dynamic> capabilities;
  final bool isAvailable;
  final double costPerToken;
  final int maxTokens;
  final int contextLength;

  const AIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.provider,
    required this.version,
    required this.capabilities,
    required this.isAvailable,
    required this.costPerToken,
    required this.maxTokens,
    required this.contextLength,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) => _$AIModelFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelToJson(this);

  /// Создать копию модели с обновленными полями
  AIModel copyWith({
    String? id,
    String? name,
    String? description,
    String? provider,
    String? version,
    Map<String, dynamic>? capabilities,
    bool? isAvailable,
    double? costPerToken,
    int? maxTokens,
    int? contextLength,
  }) {
    return AIModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      provider: provider ?? this.provider,
      version: version ?? this.version,
      capabilities: capabilities ?? this.capabilities,
      isAvailable: isAvailable ?? this.isAvailable,
      costPerToken: costPerToken ?? this.costPerToken,
      maxTokens: maxTokens ?? this.maxTokens,
      contextLength: contextLength ?? this.contextLength,
    );
  }
}

/// Сообщение в чате
@JsonSerializable()
class ChatMessageModel {
  final String id;
  final String chatId;
  final MessageRole role;
  final MessageContentType contentType;
  final String content;
  final String? imageUrl;
  final String? voiceUrl;
  final String? fileUrl;
  final Map<String, dynamic>? metadata;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? updatedAt;
  final String? aiModelId;
  final int? tokenCount;
  final double? cost;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.role,
    required this.contentType,
    required this.content,
    this.imageUrl,
    this.voiceUrl,
    this.fileUrl,
    this.metadata,
    required this.status,
    required this.timestamp,
    this.updatedAt,
    this.aiModelId,
    this.tokenCount,
    this.cost,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  /// Создать копию сообщения с обновленными полями
  ChatMessageModel copyWith({
    String? id,
    String? chatId,
    MessageRole? role,
    MessageContentType? contentType,
    String? content,
    String? imageUrl,
    String? voiceUrl,
    String? fileUrl,
    Map<String, dynamic>? metadata,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? updatedAt,
    String? aiModelId,
    int? tokenCount,
    double? cost,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      aiModelId: aiModelId ?? this.aiModelId,
      tokenCount: tokenCount ?? this.tokenCount,
      cost: cost ?? this.cost,
    );
  }
}

/// Чат
@JsonSerializable()
class ChatModel {
  final String id;
  final String title;
  final String? description;
  final String? aiModelId;
  final List<String> messageIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? settings;
  final bool isArchived;

  ChatModel({
    required this.id,
    required this.title,
    this.description,
    this.aiModelId,
    required this.messageIds,
    required this.createdAt,
    this.updatedAt,
    this.settings,
    required this.isArchived,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatModelToJson(this);

  /// Создать копию чата с обновленными полями
  ChatModel copyWith({
    String? id,
    String? title,
    String? description,
    String? aiModelId,
    List<String>? messageIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
    bool? isArchived,
  }) {
    return ChatModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      aiModelId: aiModelId ?? this.aiModelId,
      messageIds: messageIds ?? this.messageIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

/// Настройки AI
@JsonSerializable()
class AISettings {
  final String defaultModelId;
  final double temperature;
  final int maxTokens;
  final bool enableImageAnalysis;
  final bool enableVoiceRecognition;
  final bool enableFileUpload;
  final Map<String, dynamic>? customSettings;

  AISettings({
    required this.defaultModelId,
    required this.temperature,
    required this.maxTokens,
    required this.enableImageAnalysis,
    required this.enableVoiceRecognition,
    required this.enableFileUpload,
    this.customSettings,
  });

  factory AISettings.fromJson(Map<String, dynamic> json) => _$AISettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AISettingsToJson(this);

  /// Создать копию настроек с обновленными полями
  AISettings copyWith({
    String? defaultModelId,
    double? temperature,
    int? maxTokens,
    bool? enableImageAnalysis,
    bool? enableVoiceRecognition,
    bool? enableFileUpload,
    Map<String, dynamic>? customSettings,
  }) {
    return AISettings(
      defaultModelId: defaultModelId ?? this.defaultModelId,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      enableImageAnalysis: enableImageAnalysis ?? this.enableImageAnalysis,
      enableVoiceRecognition: enableVoiceRecognition ?? this.enableVoiceRecognition,
      enableFileUpload: enableFileUpload ?? this.enableFileUpload,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

/// Анализ изображения
@JsonSerializable()
class ImageAnalysisResult {
  final String imageUrl;
  final List<String> detectedObjects;
  final List<String> detectedStyles;
  final List<String> colorPalette;
  final String? description;
  final Map<String, dynamic>? fashionAnalysis;
  final Map<String, dynamic>? recommendations;
  final DateTime analyzedAt;

  ImageAnalysisResult({
    required this.imageUrl,
    required this.detectedObjects,
    required this.detectedStyles,
    required this.colorPalette,
    this.description,
    this.fashionAnalysis,
    this.recommendations,
    required this.analyzedAt,
  });

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) => _$ImageAnalysisResultFromJson(json);
  Map<String, dynamic> toJson() => _$ImageAnalysisResultToJson(this);

  /// Создать копию анализа с обновленными полями
  ImageAnalysisResult copyWith({
    String? imageUrl,
    List<String>? detectedObjects,
    List<String>? detectedStyles,
    List<String>? colorPalette,
    String? description,
    Map<String, dynamic>? fashionAnalysis,
    Map<String, dynamic>? recommendations,
    DateTime? analyzedAt,
  }) {
    return ImageAnalysisResult(
      imageUrl: imageUrl ?? this.imageUrl,
      detectedObjects: detectedObjects ?? this.detectedObjects,
      detectedStyles: detectedStyles ?? this.detectedStyles,
      colorPalette: colorPalette ?? this.colorPalette,
      description: description ?? this.description,
      fashionAnalysis: fashionAnalysis ?? this.fashionAnalysis,
      recommendations: recommendations ?? this.recommendations,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }
}

/// Предложение для чата
@JsonSerializable()
class ChatSuggestion {
  final String id;
  final String text;
  final String category;
  final String? description;
  final String? iconName;
  final Map<String, dynamic>? metadata;

  const ChatSuggestion({
    required this.id,
    required this.text,
    required this.category,
    this.description,
    this.iconName,
    this.metadata,
  });

  factory ChatSuggestion.fromJson(Map<String, dynamic> json) => _$ChatSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$ChatSuggestionToJson(this);

  /// Создать копию предложения с обновленными полями
  ChatSuggestion copyWith({
    String? id,
    String? text,
    String? category,
    String? description,
    String? iconName,
    Map<String, dynamic>? metadata,
  }) {
    return ChatSuggestion(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Статистика использования AI
@JsonSerializable()
class AIUsageStats {
  final String userId;
  final int totalMessages;
  final int totalTokens;
  final double totalCost;
  final Map<String, int> modelUsage;
  final Map<String, int> featureUsage;
  final DateTime lastUsed;
  final DateTime periodStart;
  final DateTime periodEnd;

  AIUsageStats({
    required this.userId,
    required this.totalMessages,
    required this.totalTokens,
    required this.totalCost,
    required this.modelUsage,
    required this.featureUsage,
    required this.lastUsed,
    required this.periodStart,
    required this.periodEnd,
  });

  factory AIUsageStats.fromJson(Map<String, dynamic> json) => _$AIUsageStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AIUsageStatsToJson(this);

  /// Создать копию статистики с обновленными полями
  AIUsageStats copyWith({
    String? userId,
    int? totalMessages,
    int? totalTokens,
    double? totalCost,
    Map<String, int>? modelUsage,
    Map<String, int>? featureUsage,
    DateTime? lastUsed,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return AIUsageStats(
      userId: userId ?? this.userId,
      totalMessages: totalMessages ?? this.totalMessages,
      totalTokens: totalTokens ?? this.totalTokens,
      totalCost: totalCost ?? this.totalCost,
      modelUsage: modelUsage ?? this.modelUsage,
      featureUsage: featureUsage ?? this.featureUsage,
      lastUsed: lastUsed ?? this.lastUsed,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }
}

/// Предустановленные AI модели
class PresetAIModels {
  static const List<AIModel> models = [
    const AIModel(
      id: 'gpt-4',
      name: 'GPT-4',
      description: 'Самый продвинутый языковой AI от OpenAI',
      provider: 'OpenAI',
      version: '4.0',
      capabilities: {
        'text_generation': true,
        'code_generation': true,
        'creative_writing': true,
        'analysis': true,
      },
      isAvailable: true,
      costPerToken: 0.00003,
      maxTokens: 8192,
      contextLength: 8192,
    ),
    const AIModel(
      id: 'gpt-3.5-turbo',
      name: 'GPT-3.5 Turbo',
      description: 'Быстрый и эффективный AI для повседневных задач',
      provider: 'OpenAI',
      version: '3.5',
      capabilities: {
        'text_generation': true,
        'code_generation': true,
        'creative_writing': true,
        'analysis': true,
      },
      isAvailable: true,
      costPerToken: 0.000002,
      maxTokens: 4096,
      contextLength: 4096,
    ),
    const AIModel(
      id: 'claude-3',
      name: 'Claude 3',
      description: 'AI ассистент от Anthropic с фокусом на безопасность',
      provider: 'Anthropic',
      version: '3.0',
      capabilities: {
        'text_generation': true,
        'analysis': true,
        'creative_writing': true,
        'safety': true,
      },
      isAvailable: true,
      costPerToken: 0.000015,
      maxTokens: 100000,
      contextLength: 100000,
    ),
    const AIModel(
      id: 'gemini-pro',
      name: 'Gemini Pro',
      description: 'Многофункциональный AI от Google',
      provider: 'Google',
      version: '1.0',
      capabilities: {
        'text_generation': true,
        'image_analysis': true,
        'code_generation': true,
        'multimodal': true,
      },
      isAvailable: true,
      costPerToken: 0.00001,
      maxTokens: 32768,
      contextLength: 32768,
    ),
  ];

  /// Получить модель по ID
  static AIModel? getById(String id) {
    try {
      return models.firstWhere((model) => model.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Получить доступные модели
  static List<AIModel> getAvailable() {
    return models.where((model) => model.isAvailable).toList();
  }
}

/// Предустановленные предложения для чата
class PresetChatSuggestions {
  static const List<ChatSuggestion> suggestions = [
    const ChatSuggestion(
      id: 'style_advice',
      text: 'Дайте рекомендации по стилю для моего типа фигуры',
      category: 'style',
      description: 'Получите персональные советы по стилю',
    ),
    const ChatSuggestion(
      id: 'outfit_help',
      text: 'Помогите составить образ для важной встречи',
      category: 'outfit',
      description: 'Создайте идеальный образ для любого случая',
    ),
    const ChatSuggestion(
      id: 'color_analysis',
      text: 'Проанализируйте мою цветовую палитру',
      category: 'analysis',
      description: 'Узнайте, какие цвета вам подходят',
    ),
    const ChatSuggestion(
      id: 'trends_info',
      text: 'Расскажите о последних трендах в моде',
      category: 'trends',
      description: 'Будьте в курсе актуальных трендов',
    ),
    const ChatSuggestion(
      id: 'shopping_guide',
      text: 'Составьте список покупок для базового гардероба',
      category: 'shopping',
      description: 'Планируйте покупки с умом',
    ),
    const ChatSuggestion(
      id: 'care_advice',
      text: 'Как правильно ухаживать за одеждой?',
      category: 'care',
      description: 'Советы по уходу за вещами',
    ),
  ];

  /// Получить предложения по категории
  static List<ChatSuggestion> getByCategory(String category) {
    return suggestions.where((suggestion) => suggestion.category == category).toList();
  }

  /// Получить все предложения
  static List<ChatSuggestion> getAll() {
    return suggestions;
  }
}
