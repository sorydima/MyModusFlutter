import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';
import 'l10n/l10n.dart';

class MyModusApp extends StatelessWidget {
  MyModusApp({Key? key}) : super(key: key);

  final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MyModus',
      theme: appTheme,
      routerConfig: _router,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
    );
  }
}
