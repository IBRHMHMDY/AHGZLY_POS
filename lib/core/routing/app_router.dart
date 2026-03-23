import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          // مؤقتاً لحين بناء شاشة الـ POS
          return const Scaffold(
            body: Center(
              child: Text('Ahgzly POS - Initialized', style: TextStyle(fontSize: 24)),
            ),
          );
        },
      ),
    ],
  );
}