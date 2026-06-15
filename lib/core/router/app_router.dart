import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/main_layout.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/skin_analysis/screens/camera_screen.dart';
import '../../features/skin_analysis/screens/analysis_result_screen.dart';
import '../../features/ai_chat/screens/chat_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../core/models/scan_model.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// موجه التطبيق - تعريف جميع المسارات
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final isLoggedIn = token != null && token.isNotEmpty;

    final publicPaths = ['/', '/login', '/register'];
    final isOnPublicPath = publicPaths.contains(state.matchedLocation);

    if (!isLoggedIn && !isOnPublicPath) {
      return '/login';
    }

    if (isLoggedIn && isOnPublicPath) {
      return '/home';
    }

    return null;
  },
  routes: [
    // ===== مسارات ما قبل تسجيل الدخول (بدون شريط تنقل) =====
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

    // ===== شاشة نتيجة التحليل (تابعة للفحص لكن تظهر كصفحة منفصلة) =====
    GoRoute(
      path: '/analysis',
      name: 'analysis',
      builder: (context, state) => AnalysisResultScreen(
        scanResult: state.extra as ScanModel?,
      ),
    ),

    // ===== المسارات الرئيسية (داخل شريط التنقل الثابت) =====
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        // الفرع 0: المحادثة الذكية
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              name: 'chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        // الفرع 1: الفحص بالكاميرا
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/camera',
              name: 'camera',
              builder: (context, state) => const CameraScreen(),
            ),
          ],
        ),
        // الفرع 2: سجل النتائج
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        // الفرع 3: الملف الشخصي
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // ===== مسار الصفحة الرئيسية (للتوجيه بعد تسجيل الدخول) =====
    GoRoute(
      path: '/home',
      name: 'home',
      redirect: (context, state) => '/chat',
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
  static const home = '/home';
}
