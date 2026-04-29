import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/welcome_screen.dart';

void main() {
  runApp(
    // استخدمنا ProviderScope لأننا سنحتاج Riverpod لاحقاً في المشروع
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Analysis AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // فرض الاتجاه العربي على التطبيق بالكامل (من اليمين لليسار)
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const WelcomeScreen(),
    );
  }
}