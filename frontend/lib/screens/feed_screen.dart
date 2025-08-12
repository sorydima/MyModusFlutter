import 'package:flutter/material.dart';
import '../services/api.dart';
import 'item_screen.dart';

class FeedScreen extends StatefulWidget {
  final ApiService api;
  const FeedScreen({super.key, required this.api});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() { loading = true; });
    final res = await widget.api.getFeed();
    if (res.containsKey('posts')) {
      setState(() { posts = res['posts']; loading = false; });
    } else {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: loading ? const Center(child: CircularProgressIndicator()) :
      ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, idx) {
          final p = posts[idx];
          final item = p['item'];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: item['image'] != null ? Image.network(item['image'], width: 56, height: 56, fit: BoxFit.cover) : null,
              title: Text(item['title'] ?? ''),
              subtitle: Text('${item['price'] ?? ''} ${item['currency'] ?? ''}'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemScreen(api: widget.api, itemId: item['id']))),
            ),
          );
        },
      ),
    );
  }
}
