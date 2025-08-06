import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyModusApp());
}

class MyModusApp extends StatelessWidget {
  const MyModusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Modus",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
} 