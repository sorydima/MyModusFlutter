import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.appTitle)),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed('/home'),
          child: Text(t.gettingStarted),
        ),
      ),
    );
  }
}
