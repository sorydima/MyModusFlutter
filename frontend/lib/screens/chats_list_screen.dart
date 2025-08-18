import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<ChatPreview> _chats = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Загрузить чаты с сервера
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Тестовые чаты
      _chats.addAll([
        ChatPreview(
          id: '1',
          userName: 'Fashionista',
          userAvatar: 'https://via.placeholder.com/50x50/FF6B6B/FFFFFF?text=F',
          lastMessage: 'Где ты купил эту куртку? Очень стильно выглядит!',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
          unreadCount: 2,
          isOnline: true,
        ),
        ChatPreview(
          id: '2',
          userName: 'Style Guru',
          userAvatar: 'https://via.placeholder.com/50x50/4ECDC4/FFFFFF?text=S',
          lastMessage: 'Спасибо за совет! Образ получился отличный',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
          unreadCount: 0,
          isOnline: false,
        ),
        ChatPreview(
          id: '3',
          userName: 'Trend Setter',
          userAvatar: 'https://via.placeholder.com/50x50/96CEB4/FFFFFF?text=T',
          lastMessage: 'Когда планируешь новый пост?',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
          unreadCount: 1,
          isOnline: true,
        ),
        ChatPreview(
          id: '4',
          userName: 'Fashion Designer',
          userAvatar: 'https://via.placeholder.com/50x50/FFEAA7/FFFFFF?text=D',
          lastMessage: 'Отличная идея для коллаборации!',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 0,
          isOnline: false,
        ),
        ChatPreview(
          id: '5',
          userName: 'Style Consultant',
          userAvatar: 'https://via.placeholder.com/50x50/DDA0DD/FFFFFF?text=C',
          lastMessage: 'Жду твоих новых образов!',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
          unreadCount: 0,
          isOnline: false,
        ),
      ]);
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки чатов: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'Сейчас';
    }
  }

  void _openChat(ChatPreview chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chat.id,
          userName: chat.userName,
          userAvatar: chat.userAvatar,
        ),
      ),
    );
  }

  void _createNewChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildNewChatModal(),
    );
  }

  Widget _buildNewChatModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Новый чат',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Поиск пользователей
          TextField(
            decoration: InputDecoration(
              hintText: 'Поиск пользователей...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          // Список пользователей
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      'https://via.placeholder.com/40x40/FF6B6B/FFFFFF?text=U$index',
                    ),
                  ),
                  title: Text('User $index'),
                  subtitle: Text('@user$index'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Создать чат с пользователем
                    },
                    child: const Text('Написать'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Сообщения'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _createNewChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск в сообщениях...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              onChanged: (value) {
                // TODO: Реализовать поиск по чатам
              },
            ),
          ),
          
          // Список чатов
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _chats.isEmpty
                    ? _buildEmptyState()
                    : _buildChatsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Нет сообщений',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Начните разговор с другими пользователями',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createNewChat,
            child: const Text('Начать чат'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return _buildChatTile(chat);
      },
    );
  }

  Widget _buildChatTile(ChatPreview chat) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(chat.userAvatar),
          ),
          if (chat.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            _formatTime(chat.lastMessageTime),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: chat.unreadCount > 0
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${chat.unreadCount}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () => _openChat(chat),
      onLongPress: () => _showChatOptions(chat),
    );
  }

  void _showChatOptions(ChatPreview chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('Закрепить чат'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Реализовать закрепление чата
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('Отключить уведомления'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Реализовать отключение уведомлений
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Удалить чат'),
              onTap: () {
                Navigator.pop(context);
                _deleteChat(chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteChat(ChatPreview chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить чат'),
        content: Text('Вы уверены, что хотите удалить чат с ${chat.userName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _chats.remove(chat);
              });
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class ChatPreview {
  final String id;
  final String userName;
  final String userAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatPreview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });
}
