import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyModusApp());
}

class MyModusApp extends StatelessWidget {
  const MyModusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Modus',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
