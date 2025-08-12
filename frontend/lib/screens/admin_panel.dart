import 'package:flutter/material.dart';
import '../services/api.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  List<dynamic> jobs = [];
  bool loading = true;
  final _urlCtrl = TextEditingController();
  String _connector = 'generic';
  String _msg = '';
  bool _busy = false;

  void load() async {
    try {
      final res = await fetchJobs();
      setState(()=> jobs = res);
    } catch (e) {}
    setState(()=> loading = false);
  }

  void _launch() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    setState(()=> _busy = true; _msg = '');
    try {
      final res = await launchScrape(url, _connector);
      setState(()=> _msg = 'Enqueued: ' + (res['job_id']?.toString() ?? 'ok'));
      // refresh jobs list after short delay
      await Future.delayed(Duration(seconds:1));
      load();
    } catch (e) {
      setState(()=> _msg = 'Error: ' + e.toString());
    } finally { setState(()=> _busy = false); }
  }

  @override
  void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: _urlCtrl, decoration: InputDecoration(labelText: 'Product URL to scrape')),
            SizedBox(height:8),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _connector, items: ['generic','wildberries','ozon','lamoda'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(), onChanged: (v)=> setState(()=> _connector = v ?? 'generic'))),
              SizedBox(width:8),
              ElevatedButton(onPressed: _busy?null:_launch, child: _busy?CircularProgressIndicator():Text('Launch'))
            ]),
            SizedBox(height:8),
            if (_msg.isNotEmpty) Text(_msg),
            SizedBox(height:12),
            Expanded(child: loading?Center(child:CircularProgressIndicator()):ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (ctx,i) {
                final j = jobs[i];
                return ListTile(title: Text(j['url'] ?? ''), subtitle: Text(j['status'] ?? ''));
              },
            ))
          ],
        ),
      ),
    );
  }
}
