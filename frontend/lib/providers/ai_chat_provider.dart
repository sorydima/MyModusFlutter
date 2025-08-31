import 'package:flutter/foundation.dart';
import '../models/ai_models.dart';
import '../services/ai_service.dart';

class AIChatProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  
  // Состояние чата
  List<ChatMessageModel> _messages = [];
  ChatModel? _currentChat;
  AIModel? _selectedModel;
  AISettings _settings;
  
  // Состояние загрузки
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  List<ChatMessageModel> get messages => _messages;
  ChatModel? get currentChat => _currentChat;
  AIModel? get selectedModel => _selectedModel;
  AISettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Инициализация
  AIChatProvider() : _settings = AISettings(
    defaultModelId: 'gpt-3.5-turbo',
    temperature: 0.7,
    maxTokens: 1000,
    enableImageAnalysis: true,
    enableVoiceRecognition: true,
    enableFileUpload: true,
  ) {
    _initializeChat();
  }
  
  Future<void> _initializeChat() async {
    try {
      // Создаем новый чат
      _currentChat = ChatModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Новый чат',
        messageIds: [],
        createdAt: DateTime.now(),
        isArchived: false,
      );
      
      // Устанавливаем модель по умолчанию
      _selectedModel = PresetAIModels.getById(_settings.defaultModelId);
      
      // Добавляем приветственное сообщение
      _addSystemMessage(
        'Привет! Я ваш AI стилист. Я помогу вам с вопросами о моде, стиле и создании образов. '
        'Задавайте любые вопросы или загружайте фото для анализа!',
      );
      
    } catch (e) {
      _setError('Ошибка инициализации чата: $e');
    }
  }
  
  // Отправка сообщения
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    try {
      _setLoading(true);
      _clearError();
      
      // Добавляем сообщение пользователя
      final userMessage = _createMessage(
        content: content,
        role: MessageRole.user,
        contentType: MessageContentType.text,
      );
      _addMessage(userMessage);
      
      // Получаем ответ от AI
      await _getAIResponse(content);
      
    } catch (e) {
      _setError('Ошибка отправки сообщения: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Получение ответа от AI
  Future<void> _getAIResponse(String userMessage) async {
    try {
      if (_selectedModel == null) {
        throw Exception('AI модель не выбрана');
      }
      
      // Создаем сообщение AI
      final aiMessage = _createMessage(
        content: 'Думаю...',
        role: MessageRole.assistant,
        contentType: MessageContentType.text,
        aiModelId: _selectedModel!.id,
      );
      _addMessage(aiMessage);
      
      // Получаем ответ от AI сервиса
      final response = await _aiService.generateResponse(
        message: userMessage,
        modelId: _selectedModel!.id,
        settings: _settings,
      );
      
      // Обновляем сообщение AI
      final updatedMessage = aiMessage.copyWith(
        content: response.content,
        status: MessageStatus.delivered,
        tokenCount: response.tokenCount,
        cost: response.cost,
      );
      
      _updateMessage(updatedMessage);
      
    } catch (e) {
      _setError('Ошибка получения ответа от AI: $e');
      
      // Обновляем сообщение AI с ошибкой
      if (_messages.isNotEmpty && _messages.last.role == MessageRole.assistant) {
        final lastMessage = _messages.last;
        final errorMessage = lastMessage.copyWith(
          content: 'Извините, произошла ошибка. Попробуйте еще раз.',
          status: MessageStatus.failed,
        );
        _updateMessage(errorMessage);
      }
    }
  }
  
  // Регенерация ответа
  Future<void> regenerateResponse(ChatMessageModel message) async {
    if (message.role != MessageRole.assistant) return;
    
    try {
      _setLoading(true);
      _clearError();
      
      // Находим предыдущее сообщение пользователя
      final userMessageIndex = _messages.indexWhere((m) => 
        m.role == MessageRole.user && 
        _messages.indexOf(m) < _messages.indexOf(message)
      );
      
      if (userMessageIndex == -1) return;
      
      final userMessage = _messages[userMessageIndex];
      
      // Удаляем старый ответ AI
      _removeMessage(message.id);
      
      // Получаем новый ответ
      await _getAIResponse(userMessage.content);
      
    } catch (e) {
      _setError('Ошибка регенерации ответа: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Анализ изображения
  Future<void> analyzeImage(String imageUrl) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Добавляем сообщение с изображением
      final imageMessage = _createMessage(
        content: 'Анализирую изображение...',
        role: MessageRole.user,
        contentType: MessageContentType.image,
        imageUrl: imageUrl,
      );
      _addMessage(imageMessage);
      
      // Получаем анализ от AI
      final analysis = await _aiService.analyzeImage(
        imageUrl: imageUrl,
        modelId: _selectedModel?.id ?? _settings.defaultModelId,
        settings: _settings,
      );
      
      // Добавляем ответ AI с анализом
      final aiResponse = _createMessage(
        content: analysis.description ?? 'Анализ завершен',
        role: MessageRole.assistant,
        contentType: MessageContentType.text,
        aiModelId: _selectedModel?.id,
        metadata: {
          'analysis': analysis.toJson(),
        },
      );
      _addMessage(aiResponse);
      
    } catch (e) {
      _setError('Ошибка анализа изображения: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Смена AI модели
  Future<void> changeModel(String modelId) async {
    try {
      final newModel = PresetAIModels.getById(modelId);
      if (newModel == null) {
        throw Exception('Модель не найдена');
      }
      
      _selectedModel = newModel;
      
      // Обновляем настройки
      _settings = _settings.copyWith(defaultModelId: modelId);
      
      // Добавляем системное сообщение о смене модели
      _addSystemMessage(
        'Переключился на модель: ${newModel.name}',
      );
      
      notifyListeners();
      
    } catch (e) {
      _setError('Ошибка смены модели: $e');
    }
  }
  
  // Обновление настроек
  Future<void> updateSettings(AISettings newSettings) async {
    try {
      _settings = newSettings;
      
      // Обновляем выбранную модель
      if (_selectedModel?.id != newSettings.defaultModelId) {
        await changeModel(newSettings.defaultModelId);
      }
      
      notifyListeners();
      
    } catch (e) {
      _setError('Ошибка обновления настроек: $e');
    }
  }
  
  // Очистка чата
  Future<void> clearChat() async {
    try {
      _messages.clear();
      _currentChat = null;
      await _initializeChat();
      notifyListeners();
      
    } catch (e) {
      _setError('Ошибка очистки чата: $e');
    }
  }
  
  // Экспорт чата
  Future<String> exportChat() async {
    try {
      final chatData = {
        'chat': _currentChat?.toJson(),
        'messages': _messages.map((m) => m.toJson()).toList(),
        'settings': _settings.toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
      
      // TODO: Реализовать экспорт в файл
      return 'Чат экспортирован';
      
    } catch (e) {
      _setError('Ошибка экспорта чата: $e');
      return '';
    }
  }
  
  // Вспомогательные методы
  ChatMessageModel _createMessage({
    required String content,
    required MessageRole role,
    required MessageContentType contentType,
    String? imageUrl,
    String? voiceUrl,
    String? fileUrl,
    String? aiModelId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: _currentChat?.id ?? '',
      role: role,
      contentType: contentType,
      content: content,
      imageUrl: imageUrl,
      voiceUrl: voiceUrl,
      fileUrl: fileUrl,
      metadata: metadata,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
      aiModelId: aiModelId,
    );
  }
  
  void _addMessage(ChatMessageModel message) {
    _messages.add(message);
    _updateChatMessageIds();
    notifyListeners();
  }
  
  void _addSystemMessage(String content) {
    final systemMessage = _createMessage(
      content: content,
      role: MessageRole.system,
      contentType: MessageContentType.text,
    );
    _addMessage(systemMessage);
  }
  
  void _updateMessage(ChatMessageModel updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }
  
  void _removeMessage(String messageId) {
    _messages.removeWhere((m) => m.id == messageId);
    _updateChatMessageIds();
    notifyListeners();
  }
  
  void _updateChatMessageIds() {
    if (_currentChat != null) {
      _currentChat = _currentChat!.copyWith(
        messageIds: _messages.map((m) => m.id).toList(),
      );
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Очистка ресурсов
  @override
  void dispose() {
    super.dispose();
  }
}
