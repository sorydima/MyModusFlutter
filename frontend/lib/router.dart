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
import 'screens/feed_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/chats_list_screen.dart';
import 'screens/main_app_screen.dart';

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
      
      // Main app with navigation
      GoRoute(
        path: '/app',
        builder: (ctx, state) => const MainAppScreen(),
      ),
      
      // Individual screens (for direct navigation)
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
      
      // Social network routes
      GoRoute(
        path: '/feed',
        builder: (ctx, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (ctx, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/user-profile/:userId',
        builder: (ctx, state) {
          final userId = state.pathParameters['userId']!;
          final userName = state.queryParameters['userName'] ?? 'Пользователь';
          return UserProfileScreen(
            userId: userId,
            userName: userName,
          );
        },
      ),
      
      // Chat routes
      GoRoute(
        path: '/chats',
        builder: (ctx, state) => const ChatsListScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (ctx, state) {
          final chatId = state.pathParameters['chatId']!;
          final userName = state.queryParameters['userName'] ?? 'Пользователь';
          final userAvatar = state.queryParameters['userAvatar'] ?? 'https://via.placeholder.com/50x50/FF6B6B/FFFFFF?text=U';
          return ChatScreen(
            chatId: chatId,
            userName: userName,
            userAvatar: userAvatar,
          );
        },
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
