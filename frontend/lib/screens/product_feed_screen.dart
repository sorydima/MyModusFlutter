
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/cache_service.dart';
import 'package:http/http.dart' as http;

class ProductFeedScreen extends StatefulWidget {
  final String backendUrl;
  const ProductFeedScreen({super.key, required this.backendUrl});

  @override
  State<ProductFeedScreen> createState() => _ProductFeedScreenState();
}

class _ProductFeedScreenState extends State<ProductFeedScreen> {
  List products = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadCached();
    _refresh();
  }

  void _loadCached() {
    final cached = CacheService().get('products');
    if (cached != null && cached is List) {
      setState(() { products = cached; });
    }
  }

  Future<void> _refresh() async {
    setState(() { loading = true; });
    try {
      final res = await http.get(Uri.parse('${widget.backendUrl}/api/products'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() { products = data; });
        await CacheService().set('products', data);
      }
    } catch (e) {
      // ignore network errors
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: loading && products.isEmpty ? const Center(child: CircularProgressIndicator()) :
        ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, i) {
            final p = products[i];
            return ListTile(title: Text(p['title'] ?? 'No title'), subtitle: Text(p['price']?.toString() ?? ''));
          },
        ),
      ),
    );
  }
}
