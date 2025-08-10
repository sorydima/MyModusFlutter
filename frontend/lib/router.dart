import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/intro_page.dart';
import 'screens/product_feed_screen.dart';
import 'screens/search_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Auth routes
      GoRoute(
        path: '/',
        builder: (ctx, state) => IntroPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (ctx, state) => const RegisterScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const ProductFeedScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (ctx, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/product-detail',
        builder: (ctx, state) => ProductDetailScreen(
          product: state.extra as ProductModel,
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (ctx, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (ctx, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (ctx, state) => const ProfileScreen(),
      ),
      
      // Admin routes
      GoRoute(
        path: '/admin',
        builder: (ctx, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (ctx, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (ctx, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/scraping',
        builder: (ctx, state) => const AdminScrapingScreen(),
      ),
    ],
  );
}
