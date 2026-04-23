import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const AuthChatApp());
}

class AuthChatApp extends StatelessWidget {
  const AuthChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Chat VeigaGustavo',
      theme: AppTheme.glassDarkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
