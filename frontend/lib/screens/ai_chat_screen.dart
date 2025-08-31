import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_chat_provider.dart';
import '../models/ai_models.dart';
import '../widgets/chat_message.dart';
import '../widgets/chat_input.dart';
import '../widgets/ai_model_selector.dart';
import '../widgets/chat_suggestions.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.surface,
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок AI чата
              _buildHeader(theme, colorScheme),
              
              // Селектор AI модели
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const AIModelSelector(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Основной чат
              Expanded(
                child: Consumer<AIChatProvider>(
                  builder: (context, aiProvider, child) {
                    final messages = aiProvider.messages;
                    final isLoading = aiProvider.isLoading;
                    
                    if (messages.isEmpty && !isLoading) {
                      return _buildWelcomeState(theme);
                    }
                    
                    return Column(
                      children: [
                        // Список сообщений
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return ChatMessage(
                                message: message,
                                onImageTap: () => _showImageDialog(context, message),
                                onCopy: () => _copyMessage(message),
                                onRegenerate: () => _regenerateMessage(message),
                              );
                            },
                          ),
                        ),
                        
                        // Индикатор загрузки
                        if (isLoading)
                          _buildLoadingIndicator(theme),
                        
                        // Предложения для чата
                        if (messages.isEmpty && !isLoading)
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: ChatSuggestions(
                                onSuggestionSelected: _handleSuggestion,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              
              // Поле ввода
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ChatInput(
                    controller: _textController,
                    onSendMessage: _sendMessage,
                    onImageSelected: (imageUrl) => _handleImageSelection(imageUrl),
                    onVoiceMessage: _handleVoiceMessage,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.surface,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Стилист',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Персональные рекомендации по стилю',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Добро пожаловать в AI Стилист!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Задайте вопрос о стиле, получите рекомендации по образу или загрузите фото для анализа',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Быстрые действия
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  theme,
                  Icons.camera_alt,
                  'Анализ фото',
                  'Загрузите фото для анализа стиля',
                  () => _handleImageSelection('https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=Photo+for+Analysis'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickAction(
                  theme,
                  Icons.style,
                  'Рекомендации',
                  'Получите персональные советы',
                  () => _sendMessage('Дайте рекомендации по стилю'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'AI думает...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Методы для действий
  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;
    
    final aiProvider = Provider.of<AIChatProvider>(context, listen: false);
    aiProvider.sendMessage(message);
    
    _textController.clear();
    _scrollToBottom();
  }

  void _handleSuggestion(ChatSuggestion suggestion) {
    _textController.text = suggestion.text;
    _sendMessage(suggestion.text);
  }

  void _handleImageSelection(String imageUrl) {
    final aiProvider = Provider.of<AIChatProvider>(context, listen: false);
    aiProvider.analyzeImage(imageUrl);
  }

  void _handleVoiceMessage() {
    // TODO: Реализовать голосовые сообщения
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция голосовых сообщений в разработке')),
    );
  }

  void _showImageDialog(BuildContext context, ChatMessageModel message) {
    if (message.imageUrl == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                message.imageUrl!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Сохранить изображение
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Сохранить'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Поделиться изображением
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Поделиться'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyMessage(ChatMessageModel message) {
    // TODO: Копировать сообщение в буфер обмена
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сообщение скопировано!')),
    );
  }

  void _regenerateMessage(ChatMessageModel message) {
    if (message.role == MessageRole.user) return;
    
    final aiProvider = Provider.of<AIChatProvider>(context, listen: false);
    aiProvider.regenerateResponse(message);
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки AI'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Настройки AI чата будут доступны в следующей версии'),
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
