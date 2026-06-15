import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // متغير للتحكم في إظهار/إخفاء كلمة المرور
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).login(email, password);

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      final error = ref.read(authProvider).error ?? 'حدث خطأ غير متوقع';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, textAlign: TextAlign.right),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // زر الرجوع للخلف (إضافة مفيدة لتجربة المستخدم)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
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
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'أدخل البريد الإلكتروني';
                          }
                          if (!value.contains('@')) {
                            return 'أدخل بريد إلكتروني صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "كلمة المرور",
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أدخل كلمة المرور';
                          }
                          if (value.length < 6) {
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),

                      // رابط نسيان كلمة المرور
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('سيتم تفعيل استعادة كلمة المرور قريباً')),
                            );
                          },
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
                              context.push('/register');
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
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0x0C635F40), // لون خلفية خفيف (bg-secondary/5)
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
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
            color: AppTheme.pinkGlow.withValues(alpha: 0.3),
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
          onTap: _isLoading ? null : _handleLogin,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black,
                    ),
                  )
                : Row(
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
        color: color.withValues(alpha: 0.2),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
