import 'package:flutter/material.dart';
import '../services/api.dart';

class ItemScreen extends StatefulWidget {
  final ApiService api;
  final int itemId;
  const ItemScreen({super.key, required this.api, required this.itemId});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  Map? item;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final res = await widget.api.getItem(widget.itemId);
    if (res.containsKey('id')) {
      setState(() { item = res; loading = false; });
    } else {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item?['title'] ?? 'Item')),
      body: loading ? const Center(child: CircularProgressIndicator()) :
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (item?['image'] != null) Image.network(item!['image'], height: 220, fit: BoxFit.cover),
          const SizedBox(height: 12),
          Text(item?['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${item?['price'] ?? ''} ${item?['currency'] ?? ''}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(item?['description'] ?? ''),
        ]),
      ),
    );
  }
}
