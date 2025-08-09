import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.home)),
      body: Center(child: Text(t.welcome)),
    );
  }
}
