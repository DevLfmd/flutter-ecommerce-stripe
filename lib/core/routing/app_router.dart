import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/email_confirmation_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/confirm',
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          return EmailConfirmationPage(code: code);
        },
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      
      // Products Routes
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailPage(productId: productId);
        },
      ),
      
      // Cart Route
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      
      // Checkout Route
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      
      // Orders Routes
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailPage(orderId: orderId);
        },
      ),
      
      // Profile Route
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}