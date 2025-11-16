import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/matrix_provider.dart';
import '../models/matrix_models.dart';

class BridgeManagementScreen extends StatefulWidget {
  const BridgeManagementScreen({super.key});

  @override
  State<BridgeManagementScreen> createState() => _BridgeManagementScreenState();
}

class _BridgeManagementScreenState extends State<BridgeManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridge Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBridgeDialog(context),
          ),
        ],
      ),
      body: Consumer<MatrixProvider>(
        builder: (context, matrixProvider, child) {
          final bridges = matrixProvider.bridges;

          if (bridges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No bridges configured',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add bridges to connect legacy platforms',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showAddBridgeDialog(context),
                    child: const Text('Add Bridge'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: bridges.length,
            itemBuilder: (context, index) {
              final bridge = bridges[index];
              return _buildBridgeTile(context, bridge);
            },
          );
        },
      ),
    );
  }

  Widget _buildBridgeTile(BuildContext context, BridgeConfig bridge) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getBridgeColor(bridge.type),
          child: Icon(_getBridgeIcon(bridge.type), color: Colors.white),
        ),
        title: Text(bridge.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${bridge.type.name.toUpperCase()} • ${bridge.serverUrl}'),
            Text(
              'Status: ${_getStatusText(bridge.status)}',
              style: TextStyle(
                color: _getStatusColor(bridge.status),
                fontSize: 12,
              ),
            ),
            if (bridge.errorMessage != null)
              Text(
                bridge.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBridgeAction(context, bridge, value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'test', child: Text('Test Connection')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => _showBridgeDetails(context, bridge),
      ),
    );
  }

  void _showAddBridgeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddBridgeDialog(),
    );
  }

  void _showBridgeDetails(BuildContext context, BridgeConfig bridge) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BridgeDetailsSheet(bridge: bridge),
    );
  }

  void _handleBridgeAction(BuildContext context, BridgeConfig bridge, String action) async {
    final matrixProvider = context.read<MatrixProvider>();

    switch (action) {
      case 'edit':
        _showEditBridgeDialog(context, bridge);
        break;
      case 'test':
        try {
          // Create a temporary config for testing
          final testConfig = bridge.copyWith(status: BridgeStatus.connecting);
          await matrixProvider.bridgeService._testBridgeConnection(testConfig);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bridge connection test successful')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bridge connection test failed: $e')),
          );
        }
        break;
      case 'delete':
        _showDeleteBridgeDialog(context, bridge);
        break;
    }
  }

  void _showEditBridgeDialog(BuildContext context, BridgeConfig bridge) {
    showDialog(
      context: context,
      builder: (context) => AddBridgeDialog(bridge: bridge),
    );
  }

  void _showDeleteBridgeDialog(BuildContext context, BridgeConfig bridge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bridge'),
        content: Text('Are you sure you want to delete the bridge "${bridge.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<MatrixProvider>().removeBridge(bridge.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bridge deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete bridge: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getBridgeColor(BridgeType type) {
    switch (type) {
      case BridgeType.irc:
        return Colors.blue;
      case BridgeType.slack:
        return Colors.purple;
      case BridgeType.discord:
        return Colors.indigo;
      case BridgeType.telegram:
        return Colors.blueAccent;
      case BridgeType.whatsapp:
        return Colors.green;
      case BridgeType.signal:
        return Colors.blueGrey;
      case BridgeType.xmpp:
        return Colors.orange;
      case BridgeType.email:
        return Colors.red;
    }
  }

  IconData _getBridgeIcon(BridgeType type) {
    switch (type) {
      case BridgeType.irc:
        return Icons.chat;
      case BridgeType.slack:
        return Icons.message;
      case BridgeType.discord:
        return Icons.discord;
      case BridgeType.telegram:
        return Icons.telegram;
      case BridgeType.whatsapp:
        return Icons.phone;
      case BridgeType.signal:
        return Icons.security;
      case BridgeType.xmpp:
        return Icons.alternate_email;
      case BridgeType.email:
        return Icons.email;
    }
  }

  String _getStatusText(BridgeStatus status) {
    switch (status) {
      case BridgeStatus.connected:
        return 'Connected';
      case BridgeStatus.connecting:
        return 'Connecting...';
      case BridgeStatus.disconnected:
        return 'Disconnected';
      case BridgeStatus.error:
        return 'Error';
    }
  }

  Color _getStatusColor(BridgeStatus status) {
    switch (status) {
      case BridgeStatus.connected:
        return Colors.green;
      case BridgeStatus.connecting:
        return Colors.orange;
      case BridgeStatus.disconnected:
        return Colors.grey;
      case BridgeStatus.error:
        return Colors.red;
    }
  }
}

class AddBridgeDialog extends StatefulWidget {
  final BridgeConfig? bridge;

  const AddBridgeDialog({super.key, this.bridge});

  @override
  State<AddBridgeDialog> createState() => _AddBridgeDialogState();
}

class _AddBridgeDialogState extends State<AddBridgeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();

  BridgeType _selectedType = BridgeType.slack;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bridge != null) {
      _nameController.text = widget.bridge!.name;
      _serverUrlController.text = widget.bridge!.serverUrl;
      _usernameController.text = widget.bridge!.username ?? '';
      _passwordController.text = widget.bridge!.password ?? '';
      _tokenController.text = widget.bridge!.token ?? '';
      _selectedType = widget.bridge!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bridge == null ? 'Add Bridge' : 'Edit Bridge'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<BridgeType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Bridge Type'),
                items: BridgeType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Bridge Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _serverUrlController,
                decoration: const InputDecoration(labelText: 'Server URL'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              if (_requiresUsername(_selectedType))
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
              if (_requiresPassword(_selectedType))
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              if (_requiresToken(_selectedType))
                TextFormField(
                  controller: _tokenController,
                  decoration: const InputDecoration(labelText: 'Token/API Key'),
                  obscureText: true,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBridge,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.bridge == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  bool _requiresUsername(BridgeType type) {
    return type == BridgeType.irc || type == BridgeType.xmpp;
  }

  bool _requiresPassword(BridgeType type) {
    return type == BridgeType.irc || type == BridgeType.xmpp;
  }

  bool _requiresToken(BridgeType type) {
    return type == BridgeType.slack ||
           type == BridgeType.discord ||
           type == BridgeType.telegram;
  }

  void _saveBridge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final config = BridgeConfig(
        id: widget.bridge?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        name: _nameController.text.trim(),
        serverUrl: _serverUrlController.text.trim(),
        username: _usernameController.text.isNotEmpty ? _usernameController.text : null,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        token: _tokenController.text.isNotEmpty ? _tokenController.text : null,
      );

      final matrixProvider = context.read<MatrixProvider>();

      if (widget.bridge == null) {
        await matrixProvider.addBridge(config);
      } else {
        await matrixProvider.updateBridge(config.id, config);
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bridge ${widget.bridge == null ? 'added' : 'updated'} successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save bridge: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class BridgeDetailsSheet extends StatelessWidget {
  final BridgeConfig bridge;

  const BridgeDetailsSheet({super.key, required this.bridge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getBridgeColor(bridge.type),
                child: Icon(_getBridgeIcon(bridge.type), color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bridge.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      bridge.type.name.toUpperCase(),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Server URL', bridge.serverUrl),
          if (bridge.username != null) _buildDetailRow('Username', bridge.username!),
          _buildDetailRow('Status', _getStatusText(bridge.status)),
          if (bridge.lastConnected != null)
            _buildDetailRow('Last Connected', _formatDateTime(bridge.lastConnected!)),
          if (bridge.errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bridge.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getBridgeColor(BridgeType type) {
    switch (type) {
      case BridgeType.irc:
        return Colors.blue;
      case BridgeType.slack:
        return Colors.purple;
      case BridgeType.discord:
        return Colors.indigo;
      case BridgeType.telegram:
        return Colors.blueAccent;
      case BridgeType.whatsapp:
        return Colors.green;
      case BridgeType.signal:
        return Colors.blueGrey;
      case BridgeType.xmpp:
        return Colors.orange;
      case BridgeType.email:
        return Colors.red;
    }
  }

  IconData _getBridgeIcon(BridgeType type) {
    switch (type) {
      case BridgeType.irc:
        return Icons.chat;
      case BridgeType.slack:
        return Icons.message;
      case BridgeType.discord:
        return Icons.discord;
      case BridgeType.telegram:
        return Icons.telegram;
      case BridgeType.whatsapp:
        return Icons.phone;
      case BridgeType.signal:
        return Icons.security;
      case BridgeType.xmpp:
        return Icons.alternate_email;
      case BridgeType.email:
        return Icons.email;
    }
  }

  String _getStatusText(BridgeStatus status) {
    switch (status) {
      case BridgeStatus.connected:
        return 'Connected';
      case BridgeStatus.connecting:
        return 'Connecting...';
      case BridgeStatus.disconnected:
        return 'Disconnected';
      case BridgeStatus.error:
        return 'Error';
    }
  }
}
