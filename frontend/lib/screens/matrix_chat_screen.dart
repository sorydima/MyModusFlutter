import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/matrix_provider.dart';
import '../models/matrix_models.dart';

class MatrixChatScreen extends StatefulWidget {
  final MatrixRoom room;

  const MatrixChatScreen({super.key, required this.room});

  @override
  State<MatrixChatScreen> createState() => _MatrixChatScreenState();
}

class _MatrixChatScreenState extends State<MatrixChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load messages for this room
    // TODO: Implement message loading
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showRoomInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MatrixProvider>(
              builder: (context, matrixProvider, child) {
                // Filter messages for this room
                final roomMessages = matrixProvider.matrixService.messages
                    .where((msg) => msg.roomId == widget.room.id)
                    .toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: roomMessages.length,
                  itemBuilder: (context, index) {
                    final message = roomMessages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MatrixMessage message) {
    final isOwnMessage = message.senderId == context.read<MatrixProvider>().matrixService.client?.userID;

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isOwnMessage ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOwnMessage)
              Text(
                message.senderName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isOwnMessage ? Colors.white70 : Colors.black54,
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isOwnMessage ? Colors.white : Colors.black,
              ),
            ),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isOwnMessage ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      await context.read<MatrixProvider>().sendMatrixMessage(widget.room.id, message);
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
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

  void _showRoomInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.room.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (widget.room.topic != null) ...[
              const SizedBox(height: 8),
              Text('Topic: ${widget.room.topic}'),
            ],
            const SizedBox(height: 8),
            Text('${widget.room.members.length} members'),
            if (widget.room.isEncrypted) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.lock, size: 16),
                  SizedBox(width: 4),
                  Text('Encrypted'),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
