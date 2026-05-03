import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. التوهج الوردي في الزاوية العلوية اليسرى (بسبب الـ RTL)
          Positioned(
            top: -size.height * 0.05,
            left: -size.width * 0.1, // معكوسة لتطابق التصميم في الـ RTL
            child: _buildAmbientGlow(AppTheme.pinkGlow, 400),
          ),

          // 2. التوهج الأخضر في الزاوية السفلية اليمنى
          Positioned(
            bottom: size.height * 0.1,
            right: -size.width * 0.1,
            child: _buildAmbientGlow(AppTheme.greenGlow, 500),
          ),

          // 3. المحتوى الأساسي
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),

                    // الصورة ثلاثية الأبعاد مع تأثير الدمج والتلاشي (Mask)
                    SizedBox(
                      width: size.width > 600 ? 450 : size.width * 0.9,
                      height: size.width > 600 ? 450 : size.width * 0.9,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const RadialGradient(
                            center: Alignment.center,
                            radius: 0.5,
                            colors: [Colors.black, Colors.transparent],
                            stops: [0.4, 0.7],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: CachedNetworkImage(
                          imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuALeS01TdgbcNaz6JA-0cqJBWeTRutKCCLvnV7yfkKmRL-E5WoEVkPHIGXQqjX4wl4b3l4-QOtCLBSD5h2wx96YicdD-6bftmMSpvCapbFt_vdfQmvGFJxepqL0_7BVwQmcipH_rrBlIJv-ke767_wP0f5tF4iEC7YRj8OidixwGTZ8d6pa7WYVzKUeyMGBo4zWoKY2qoZuik-jbiWyt_nQ3kcRbpy921zjDIPT8gw1n8JH7p4h4OkCs7WigNcTLDH7fHjo25QlP2w",
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: AppTheme.pinkGlow),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // النصوص
                    Text(
                      "رؤية أعمق.. لبشرة أفضل",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w300, // Light font
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "تقنية ذكاء اصطناعي متطورة لتحليل بشرتك بدقة سريرية، لروتين عناية مخصص لك.",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // زر البدء بالتدرج اللوني
                    _buildGradientButton(context),

                    const SizedBox(height: 32),

                    // رابط تسجيل الدخول
// رابط تسجيل الدخول

// ثم في الأسفل، عدّل زر تسجيل الدخول:
                    // رابط تسجيل الدخول
                    TextButton(
                      onPressed: () {
                        // كود الانتقال إلى شاشة تسجيل الدخول
                        context.push('/login');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF384C35),
                      ),
                      child: Text(
                        "تسجيل الدخول",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF384C35),
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: AppTheme.greenGlow.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لرسم التوهج الخلفي (Glow effect)
  Widget _buildAmbientGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.3),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  // دالة مساعدة لرسم الزر المتدرج مع الظل
// دالة مساعدة لرسم الزر المتدرج مع الظل
  Widget _buildGradientButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppTheme.greenGlow.withValues(alpha: 0.35),
            blurRadius: 25,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.pinkGlow, AppTheme.greenGlow],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            // الانتقال لشاشة الكاميرا لاحقاً
            context.go('/camera');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "ابدأ الفحص الآمن",
                  // استخدام copyWith لتغيير اللون ليصبح داكناً وزيادة سماكة الخط
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.onSurface, // لون أسود/رمادي داكن
                    fontWeight: FontWeight.w700, // خط عريض
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_back, 
                  color: AppTheme.onSurface, // تعديل لون الأيقونة لتطابق النص
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



}