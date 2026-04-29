import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../skin_analysis/screens/camera_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 1. التوهج الخلفي (Background Halos)
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.2, // معكوسة للـ RTL
            child: _buildAmbientGlow(const Color(0xFFFBDBDE), 400), // Primary Fixed
          ),
          Positioned(
            bottom: -size.height * 0.1,
            right: -size.width * 0.2,
            child: _buildAmbientGlow(const Color(0xFFEAE3BC), 400), // Secondary Fixed
          ),

          // 2. المحتوى الرئيسي
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  children: [
                    // Glassmorphic Card (تأثير الزجاج)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7), // Surface container lowest / 70%
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF70585B).withOpacity(0.05),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // العنوان
                              Text(
                                "إنشاء حساب",
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Colors.black,
                                      fontSize: 28,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "ابدأ رحلتك نحو بشرة مثالية",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

                              // الحقول
                              _buildTextField(label: "الاسم الكامل", keyboardType: TextInputType.name),
                              const SizedBox(height: 16),
                              _buildTextField(label: "البريد الإلكتروني", keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: "رقم الهاتف",
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr, // الأرقام دائماً من اليسار لليمين
                              ),
                              const SizedBox(height: 16),

                              // كلمة المرور مع شريط القوة
                              _buildPasswordField(
                                label: "كلمة المرور",
                                isObscured: _isPasswordObscured,
                                onToggle: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                              ),
                              const SizedBox(height: 8),
                              _buildPasswordStrength(), // شريط قوة كلمة المرور
                              const SizedBox(height: 16),

                              // تأكيد كلمة المرور
                              _buildPasswordField(
                                label: "تأكيد كلمة المرور",
                                isObscured: _isConfirmPasswordObscured,
                                onToggle: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                              ),

                              const SizedBox(height: 24),

                              // الشروط والأحكام
                              _buildTermsCheckbox(context),

                              const SizedBox(height: 24),

                              // زر التسجيل
                              _buildRegisterButton(context),

                              const SizedBox(height: 24),

                              // الفاصل (أو)
                              _buildDivider(),

                              const SizedBox(height: 24),

                              // أزرار التسجيل الاجتماعي
                              _buildSocialButton(
                                icon: Icons.g_mobiledata,
                                iconColor: Colors.blue,
                                label: "التسجيل بواسطة جوجل",
                                iconSize: 32,
                              ),
                              const SizedBox(height: 12),
                              _buildSocialButton(
                                icon: Icons.facebook,
                                iconColor: const Color(0xFF1877F2),
                                label: "التسجيل بواسطة فيسبوك",
                              ),

                              const SizedBox(height: 24),

                              // مؤشر الأمان
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shield_outlined, size: 16, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(
                                    "بياناتك محمية ومشفرة",
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // العودة لتسجيل الدخول
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "لديك حساب بالفعل؟",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                              ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context), // العودة للشاشة السابقة
                          child: Text(
                            "سجل دخولك",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
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

  // بناء حقول الإدخال العادية
  Widget _buildTextField({required String label, required TextInputType keyboardType, TextDirection? textDirection}) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0x0C635F40), // bg-secondary-fixed/5
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        textDirection: textDirection,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd2c3c4), width: 2)),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd2c3c4), width: 2)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.pinkGlow, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // بناء حقل كلمة المرور
  Widget _buildPasswordField({required String label, required bool isObscured, required VoidCallback onToggle}) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0x0C635F40),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: TextFormField(
        obscureText: isObscured,
        textDirection: TextDirection.ltr,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd2c3c4), width: 2)),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd2c3c4), width: 2)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.pinkGlow, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: IconButton(
            icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.black54, size: 20),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  // شريط قوة كلمة المرور (مؤشر ثابت للتصميم حالياً)
  Widget _buildPasswordStrength() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E3E1), borderRadius: BorderRadius.circular(4)),
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: 0.33, // 33% ضعيفة
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF635F40), borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text("ضعيفة", style: TextStyle(fontSize: 10, color: Color(0xFF4F4445))),
        ],
      ),
    );
  }

  // مربع الشروط والأحكام
  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            activeColor: AppTheme.pinkGlow,
            onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
              children: const [
                TextSpan(text: "أوافق على "),
                TextSpan(text: "شروط الخدمة", style: TextStyle(color: Color(0xFFD46A7E), decoration: TextDecoration.underline)),
                TextSpan(text: " و "),
                TextSpan(text: "سياسة الخصوصية", style: TextStyle(color: Color(0xFFD46A7E), decoration: TextDecoration.underline)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // زر إنشاء الحساب
  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB6C1).withOpacity(0.39),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB6C1), Color(0xFFC1E1C1)], // الألوان المحددة بالتصميم
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
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                "إنشاء حساب",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // الفاصل (أو)
  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE2E3E1), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("أو", style: TextStyle(color: Colors.black54, fontSize: 12)),
        ),
        Expanded(child: Divider(color: Color(0xFFE2E3E1), thickness: 1)),
      ],
    );
  }

  // أزرار التسجيل الاجتماعي
  Widget _buildSocialButton({required IconData icon, required Color iconColor, required String label, double iconSize = 24}) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE2E3E1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // التوهج الخلفي
  Widget _buildAmbientGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.3)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}