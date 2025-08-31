import 'package:flutter/material.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'Поддержка MyModus',
      'lastMessage': 'Спасибо за ваш заказ!',
      'timestamp': '12:30',
      'unreadCount': 0,
      'avatar': 'https://via.placeholder.com/50x50/4ECDC4/FFFFFF?text=MM',
    },
    {
      'id': '2',
      'name': 'Стилист Анна',
      'lastMessage': 'Как вам понравились предложенные образы?',
      'timestamp': 'Вчера',
      'unreadCount': 2,
      'avatar': 'https://via.placeholder.com/50x50/FF6B6B/FFFFFF?text=A',
    },
    {
      'id': '3',
      'name': 'AI Консультант',
      'lastMessage': 'Нашел для вас 15 товаров по вашему запросу',
      'timestamp': '2 дня назад',
      'unreadCount': 0,
      'avatar': 'https://via.placeholder.com/50x50/45B7D1/FFFFFF?text=AI',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: _startNewChat,
            icon: const Icon(Icons.add),
            tooltip: 'Новый чат',
          ),
        ],
      ),
      body: _chats.isEmpty
          ? _buildEmptyState()
          : _buildChatsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'У вас пока нет чатов',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Начните общение с поддержкой\nили AI консультантом',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startNewChat,
            icon: const Icon(Icons.chat),
            label: const Text('Начать чат'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
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

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chat['avatar']),
        radius: 25,
      ),
      title: Text(
        chat['name'],
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        chat['lastMessage'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chat['unreadCount'] > 0 
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade600,
          fontWeight: chat['unreadCount'] > 0 
              ? FontWeight.w500 
              : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat['timestamp'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          if (chat['unreadCount'] > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat['unreadCount'].toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () => _openChat(chat),
    );
  }

  void _startNewChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый чат'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Поддержка'),
              subtitle: const Text('Вопросы по заказам и доставке'),
              onTap: () {
                Navigator.pop(context);
                _addNewChat('Поддержка MyModus', 'support');
              },
            ),
            ListTile(
              leading: const Icon(Icons.style),
              title: const Text('Стилист'),
              subtitle: const Text('Персональные рекомендации'),
              onTap: () {
                Navigator.pop(context);
                _addNewChat('Стилист Анна', 'stylist');
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('AI Консультант'),
              subtitle: const Text('Умный помощник по выбору'),
              onTap: () {
                Navigator.pop(context);
                _addNewChat('AI Консультант', 'ai');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _addNewChat(String name, String type) {
    final newChat = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'lastMessage': 'Чат начат',
      'timestamp': 'Сейчас',
      'unreadCount': 0,
      'avatar': 'https://via.placeholder.com/50x50/4ECDC4/FFFFFF?text=${name[0]}',
    };

    setState(() {
      _chats.insert(0, newChat);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Чат с $name начат'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openChat(Map<String, dynamic> chat) {
    // TODO: Открыть чат
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Открываем чат с ${chat['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
