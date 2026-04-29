import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'register_screen.dart'; // أضف هذا السطر في الأعلى
import '../../skin_analysis/screens/camera_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // متغير للتحكم في إظهار/إخفاء كلمة المرور
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. التوهج الخلفي
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: _buildAmbientGlow(AppTheme.pinkGlow, 400),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: _buildAmbientGlow(AppTheme.greenGlow, 500),
          ),

          // 2. المحتوى
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // زر الرجوع للخلف (إضافة مفيدة لتجربة المستخدم)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // العنوان
                    Text(
                      "تسجيل الدخول",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.black,
                            fontSize: 34,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "مرحباً بك مجدداً في مساحتك الخاصة للعناية ببشرتك.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // فورم تسجيل الدخول
                    _buildTextField(
                      label: "البريد الإلكتروني",
                      keyboardType: TextInputType.emailAddress,
                      isPassword: false,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "كلمة المرور",
                      keyboardType: TextInputType.visiblePassword,
                      isPassword: true,
                    ),

                    // رابط نسيان كلمة المرور
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "نسيت كلمة المرور؟",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر الدخول المتدرج
                    _buildLoginButton(context),

                    const SizedBox(height: 24),


                    // رابط إنشاء حساب
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ليس لديك حساب؟",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black,
                              ),
                        ),
                       TextButton(
                          onPressed: () {
                            // الانتقال لشاشة إنشاء الحساب
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "إنشاء حساب",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تصميم حقول الإدخال (Floating Label Pattern)
  Widget _buildTextField({
    required String label,
    required TextInputType keyboardType,
    required bool isPassword,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0x0C635F40), // لون خلفية خفيف (bg-secondary/5)
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        obscureText: isPassword ? _isPasswordObscured : false,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          // الخط السفلي للحقل
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFd2c3c4), width: 2),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFd2c3c4), width: 2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppTheme.pinkGlow, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // أيقونة إظهار/إخفاء كلمة المرور
          prefixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  // تصميم زر الدخول
  Widget _buildLoginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pinkGlow.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
  Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
              (route) => false,
            );

            // تنفيذ تسجيل الدخول
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "دخول",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_back, // سهم لليسار بسبب RTL
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // التوهج الخلفي (نفس المستخدم في شاشة الترحيب)
  Widget _buildAmbientGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}