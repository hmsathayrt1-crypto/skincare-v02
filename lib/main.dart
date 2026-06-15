import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skincare_v02/core/router/app_router.dart';
import 'package:skincare_v02/core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DermalyzeApp(),
    ),
  );
}

class DermalyzeApp extends StatelessWidget {
  const DermalyzeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dermalyze',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
