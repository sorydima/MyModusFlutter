import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class SocialProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Состояние постов
  List<Map<String, dynamic>> _posts = [];
  bool _isLoadingPosts = false;
  String? _postsError;
  
  // Состояние чатов
  List<Map<String, dynamic>> _chats = [];
  Map<String, List<Map<String, dynamic>>> _chatMessages = {};
  bool _isLoadingChats = false;
  String? _chatsError;
  
  // Пагинация для постов
  int _currentPostsPage = 0;
  int _postsLimit = 20;
  bool _hasMorePosts = true;
  
  // Фильтры для постов
  String? _selectedUserId;
  String? _selectedHashtag;

  // Геттеры для постов
  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoadingPosts => _isLoadingPosts;
  String? get postsError => _postsError;
  bool get hasMorePosts => _hasMorePosts;
  String? get selectedUserId => _selectedUserId;
  String? get selectedHashtag => _selectedHashtag;

  // Геттеры для чатов
  List<Map<String, dynamic>> get chats => _chats;
  bool get isLoadingChats => _isLoadingChats;
  String? get chatsError => _chatsError;

  // Инициализация
  Future<void> initialize() async {
    await Future.wait([
      loadPosts(refresh: true),
      loadChats(),
    ]);
  }

  // ===== ПОСТЫ =====

  // Загрузка постов
  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPostsPage = 0;
      _posts.clear();
      _hasMorePosts = true;
    }

    if (!_hasMorePosts || _isLoadingPosts) return;

    try {
      _setPostsLoading(true);
      _postsError = null;
      
      final posts = await _apiService.getPosts(
        limit: _postsLimit,
        offset: _currentPostsPage * _postsLimit,
        userId: _selectedUserId,
      );
      
      if (refresh) {
        _posts = posts;
      } else {
        _posts.addAll(posts);
      }
      
      _hasMorePosts = posts.length == _postsLimit;
      _currentPostsPage++;
      notifyListeners();
    } catch (e) {
      _postsError = e.toString();
      notifyListeners();
    } finally {
      _setPostsLoading(false);
    }
  }

  // Создание поста
  Future<bool> createPost({
    required String caption,
    List<String>? imageUrls,
    List<String>? hashtags,
  }) async {
    try {
      _setPostsLoading(true);
      _postsError = null;
      
      final newPost = await _apiService.createPost(
        caption: caption,
        imageUrls: imageUrls,
        hashtags: hashtags,
      );
      
      // Добавляем новый пост в начало списка
      _posts.insert(0, newPost);
      notifyListeners();
      return true;
    } catch (e) {
      _postsError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setPostsLoading(false);
    }
  }

  // Лайк поста
  Future<void> likePost(String postId) async {
    try {
      await _apiService.likePost(postId);
      
      // Обновляем состояние поста
      final postIndex = _posts.indexWhere((post) => post['id'] == postId);
      if (postIndex != -1) {
        final post = Map<String, dynamic>.from(_posts[postIndex]);
        post['is_liked'] = true;
        post['likes_count'] = (post['likes_count'] ?? 0) + 1;
        _posts[postIndex] = post;
        notifyListeners();
      }
    } catch (e) {
      // Обработка ошибки
      print('Error liking post: $e');
    }
  }

  // Убрать лайк с поста
  Future<void> unlikePost(String postId) async {
    try {
      await _apiService.unlikePost(postId);
      
      // Обновляем состояние поста
      final postIndex = _posts.indexWhere((post) => post['id'] == postId);
      if (postIndex != -1) {
        final post = Map<String, dynamic>.from(_posts[postIndex]);
        post['is_liked'] = false;
        post['likes_count'] = (post['likes_count'] ?? 1) - 1;
        _posts[postIndex] = post;
        notifyListeners();
      }
    } catch (e) {
      // Обработка ошибки
      print('Error unliking post: $e');
    }
  }

  // Добавление комментария
  Future<bool> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final comment = await _apiService.addComment(
        postId: postId,
        content: content,
      );
      
      // Обновляем количество комментариев в посте
      final postIndex = _posts.indexWhere((post) => post['id'] == postId);
      if (postIndex != -1) {
        final post = Map<String, dynamic>.from(_posts[postIndex]);
        post['comments_count'] = (post['comments_count'] ?? 0) + 1;
        _posts[postIndex] = post;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Фильтрация постов по пользователю
  Future<void> filterPostsByUser(String? userId) async {
    _selectedUserId = userId;
    await loadPosts(refresh: true);
  }

  // Фильтрация постов по хештегу
  Future<void> filterPostsByHashtag(String? hashtag) async {
    _selectedHashtag = hashtag;
    // TODO: Реализовать фильтрацию по хештегу на backend
    await loadPosts(refresh: true);
  }

  // ===== ЧАТЫ =====

  // Загрузка списка чатов
  Future<void> loadChats() async {
    try {
      _setChatsLoading(true);
      _chatsError = null;
      
      final chats = await _apiService.getChats();
      _chats = chats;
      notifyListeners();
    } catch (e) {
      _chatsError = e.toString();
      notifyListeners();
    } finally {
      _setChatsLoading(false);
    }
  }

  // Загрузка сообщений чата
  Future<void> loadChatMessages(String chatId) async {
    if (_chatMessages.containsKey(chatId)) return;

    try {
      final messages = await _apiService.getChatMessages(chatId);
      _chatMessages[chatId] = messages;
      notifyListeners();
    } catch (e) {
      print('Error loading chat messages: $e');
    }
  }

  // Отправка сообщения
  Future<bool> sendMessage({
    required String chatId,
    required String content,
    String? messageType,
  }) async {
    try {
      final message = await _apiService.sendMessage(
        chatId: chatId,
        content: content,
        messageType: messageType,
      );
      
      // Добавляем сообщение в чат
      if (!_chatMessages.containsKey(chatId)) {
        _chatMessages[chatId] = [];
      }
      _chatMessages[chatId]!.add(message);
      
      // Обновляем последнее сообщение в списке чатов
      final chatIndex = _chats.indexWhere((chat) => chat['id'] == chatId);
      if (chatIndex != -1) {
        final chat = Map<String, dynamic>.from(_chats[chatIndex]);
        chat['last_message'] = message;
        chat['last_message_time'] = message['created_at'];
        _chats[chatIndex] = chat;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Получение сообщений чата
  List<Map<String, dynamic>> getChatMessages(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  // Получение чата по ID
  Map<String, dynamic>? getChatById(String chatId) {
    try {
      return _chats.firstWhere((chat) => chat['id'] == chatId);
    } catch (e) {
      return null;
    }
  }

  // ===== УТИЛИТЫ =====

  // Очистка ошибок
  void clearPostsError() {
    _postsError = null;
    notifyListeners();
  }

  void clearChatsError() {
    _chatsError = null;
    notifyListeners();
  }

  // Приватные методы
  void _setPostsLoading(bool loading) {
    _isLoadingPosts = loading;
    notifyListeners();
  }

  void _setChatsLoading(bool loading) {
    _isLoadingChats = loading;
    notifyListeners();
  }

  // Обновление поста (например, после редактирования)
  void updatePost(String postId, Map<String, dynamic> updatedPost) {
    final index = _posts.indexWhere((post) => post['id'] == postId);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  // Удаление поста
  void removePost(String postId) {
    _posts.removeWhere((post) => post['id'] == postId);
    notifyListeners();
  }

  // Получение статистики
  Map<String, dynamic> getSocialStats() {
    final totalPosts = _posts.length;
    final totalChats = _chats.length;
    final totalLikes = _posts.fold<int>(0, (sum, post) => sum + (post['likes_count'] ?? 0));
    final totalComments = _posts.fold<int>(0, (sum, post) => sum + (post['comments_count'] ?? 0));
    
    return {
      'total_posts': totalPosts,
      'total_chats': totalChats,
      'total_likes': totalLikes,
      'total_comments': totalComments,
    };
  }
}
