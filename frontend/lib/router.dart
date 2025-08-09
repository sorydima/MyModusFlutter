import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/intro_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (ctx, state) => IntroPage()),
      GoRoute(path: '/home', builder: (ctx, state) => HomePage()),
    ],
  );
}
