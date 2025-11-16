import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/matrix_provider.dart';
import '../models/matrix_models.dart';
import 'matrix_chat_screen.dart';

class MatrixRoomsScreen extends StatefulWidget {
  const MatrixRoomsScreen({super.key});

  @override
  State<MatrixRoomsScreen> createState() => _MatrixRoomsScreenState();
}

class _MatrixRoomsScreenState extends State<MatrixRoomsScreen> {
  final TextEditingController _roomIdController = TextEditingController();

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showJoinRoomDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showMatrixSettings(context),
          ),
        ],
      ),
      body: Consumer<MatrixProvider>(
        builder: (context, matrixProvider, child) {
          if (!matrixProvider.isMatrixInitialized) {
            return _buildLoginView(matrixProvider);
          }

          final rooms = matrixProvider.rooms;

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No rooms yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join a room to start chatting',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showJoinRoomDialog(context),
                    child: const Text('Join Room'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _buildRoomTile(context, room);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoginView(MatrixProvider matrixProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Connect to Matrix',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your Matrix homeserver to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Homeserver URL',
                hintText: 'https://matrix.org',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (url) => _initializeMatrix(matrixProvider, url),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final url = 'https://matrix.org'; // Default
                _initializeMatrix(matrixProvider, url);
              },
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, MatrixRoom room) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: room.avatarUrl != null ? NetworkImage(room.avatarUrl!) : null,
        child: room.avatarUrl == null ? const Icon(Icons.chat) : null,
      ),
      title: Text(
        room.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        room.topic ?? 'No topic',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: room.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                room.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MatrixChatScreen(room: room),
          ),
        );
      },
      onLongPress: () => _showRoomOptions(context, room),
    );
  }

  void _showJoinRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Room'),
        content: TextField(
          controller: _roomIdController,
          decoration: const InputDecoration(
            labelText: 'Room ID or Alias',
            hintText: '#room:matrix.org or !roomId:matrix.org',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final roomId = _roomIdController.text.trim();
              if (roomId.isNotEmpty) {
                try {
                  await context.read<MatrixProvider>().joinMatrixRoom(roomId);
                  Navigator.of(context).pop();
                  _roomIdController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to join room: $e')),
                  );
                }
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showRoomOptions(BuildContext context, MatrixRoom room) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Leave Room'),
            onTap: () async {
              try {
                await context.read<MatrixProvider>().leaveMatrixRoom(room.id);
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to leave room: $e')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Room Info'),
            onTap: () {
              Navigator.of(context).pop();
              _showRoomInfo(context, room);
            },
          ),
        ],
      ),
    );
  }

  void _showRoomInfo(BuildContext context, MatrixRoom room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(room.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room.topic != null) ...[
              const Text('Topic:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(room.topic!),
              const SizedBox(height: 8),
            ],
            Text('Members: ${room.members.length}'),
            Text('Encrypted: ${room.isEncrypted ? 'Yes' : 'No'}'),
            Text('Direct Chat: ${room.isDirect ? 'Yes' : 'No'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMatrixSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              try {
                await context.read<MatrixProvider>().logoutMatrix();
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to logout: $e')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.bridges),
            title: const Text('Manage Bridges'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Navigate to bridge management screen
            },
          ),
        ],
      ),
    );
  }

  void _initializeMatrix(MatrixProvider matrixProvider, String homeserverUrl) async {
    try {
      await matrixProvider.initializeMatrix(homeserverUrl: homeserverUrl);
      // After initialization, show login dialog
      _showLoginDialog(context, matrixProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize Matrix: $e')),
      );
    }
  }

  void _showLoginDialog(BuildContext context, MatrixProvider matrixProvider) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login to Matrix'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'user or @user:matrix.org',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              final password = passwordController.text.trim();

              if (username.isNotEmpty && password.isNotEmpty) {
                try {
                  await matrixProvider.loginMatrix(
                    username: username,
                    password: password,
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: $e')),
                  );
                }
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
