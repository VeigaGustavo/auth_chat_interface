import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../session/session_store.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/chat/presentation/chat_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuth = SessionStore.instance.isAuthenticated;
      final bool inLogin = state.matchedLocation == '/login';

      if (!isAuth && !inLogin) {
        return '/login';
      }
      if (isAuth && inLogin) {
        return '/chat';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (BuildContext context, GoRouterState state) {
          return const ChatPage();
        },
      ),
    ],
  );
}
