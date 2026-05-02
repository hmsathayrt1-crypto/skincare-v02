import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skincare_v02/core/router/app_router.dart';
import 'core/theme/app_theme.dart';

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
    return MaterialApp.router(
      title: 'Skin Analysis AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      // فرض الاتجاه العربي على التطبيق بالكامل (من اليمين لليسار)
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
