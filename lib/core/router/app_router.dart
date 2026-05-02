import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/skin_analysis/screens/camera_screen.dart';
import '../../features/skin_analysis/screens/analysis_result_screen.dart';
import '../../features/ai_chat/screens/chat_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

/// موجه التطبيق - تعريف جميع المسارات
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/camera',
      name: 'camera',
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: '/analysis',
      name: 'analysis',
      builder: (context, state) => const AnalysisResultScreen(),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'الصفحة غير موجودة: ${state.error?.message ?? ""}',
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    ),
  ),
);

/// أسماء المسارات للاستخدام في التنقل
class AppRoutes {
  AppRoutes._();
  static const welcome = '/';
  static const login = '/login';
  static const register = '/register';
  static const camera = '/camera';
  static const analysis = '/analysis';
  static const chat = '/chat';
  static const history = '/history';
  static const profile = '/profile';
}
