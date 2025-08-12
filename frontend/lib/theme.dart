import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: Color(0xFFF6F6F9),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
  );
}
