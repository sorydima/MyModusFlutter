import 'package:flutter/material.dart';
import '../services/api.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _title = TextEditingController();
  final _url = TextEditingController();
  bool _loading = false;
  String _msg = '';

  void _scrape() async {
    final url = _url.text.trim();
    if (url.isEmpty) return;
    setState((){ _loading=true; _msg=''; });
    try {
      await scrapeUrl(url);
      setState(()=> _msg='Scraped and added!');
    } catch (e) {
      setState(()=> _msg='Error: '+e.toString());
    } finally { setState(()=> _loading=false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create post')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _title, decoration: InputDecoration(labelText: 'Caption')),
            TextField(controller: _url, decoration: InputDecoration(labelText: 'Marketplace product URL')),
            SizedBox(height:12),
            ElevatedButton(onPressed: _loading?null:_scrape, child: _loading?CircularProgressIndicator():Text('Import from URL')),
            SizedBox(height:12),
            Text(_msg)
          ],
        ),
      ),
    );
  }
}
