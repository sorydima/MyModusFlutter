import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class L10n {
  static const LocalizationsDelegate localizationsDelegates = const _L10nDelegate();
  static const supportedLocales = [Locale('en'), Locale('ru')];

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  String get appTitle => Intl.message('MyModus', name: 'appTitle');
  String get gettingStarted => Intl.message('Get started', name: 'gettingStarted');
  String get home => Intl.message('Home', name: 'home');
  String get welcome => Intl.message('Welcome to MyModus!', name: 'welcome');
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<L10n> load(Locale locale) async {
    Intl.defaultLocale = locale.languageCode;
    return L10n();
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<L10n> old) => false;
}
