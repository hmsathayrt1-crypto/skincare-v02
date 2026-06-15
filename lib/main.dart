import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skincare_v02/core/router/app_router.dart';
import 'package:skincare_v02/core/theme/app_theme.dart';
import 'package:skincare_v02/core/constants/api_endpoints.dart';
import 'package:skincare_v02/core/network/dio_client.dart';
import 'package:skincare_v02/shared/server_config_floating_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تحميل إعدادات الاتصال المخزنة محلياً عند الإقلاع
  final prefs = await SharedPreferences.getInstance();
  final savedIpPort = prefs.getString('server_ip_port') ?? '127.0.0.1:80';
  ApiEndpoints.serverIpPort = savedIpPort;
  
  // تهيئة العنوان الأساسي لـ DioClient مباشرة
  DioClient().dio.options.baseUrl = ApiEndpoints.baseUrl;

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
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false, // يمنع اهتزاز الزر عند ظهور الكيبورد
          body: Stack(
            children: [
              if (child != null) child,
              const Positioned(
                bottom: 100, // يرفع الزر فوق شريط التنقل السفلي الذي يبلغ ارتفاعه 80
                right: 16,
                child: ServerConfigFloatingButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}
