import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import 'analysis_result_screen.dart';
// سننشئ هذا المجلد والملف في الخطوة التالية
import '../../ai_chat/screens/chat_screen.dart';
// سننشئ هذا المجلد والملف في الخطوة التالية
import '../../history/screens/history_screen.dart';
// سننشئ هذا المجلد والملف في الخطوة التالية
import '../../profile/screens/profile_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    // إعداد حركة خط المسح (يتحرك للأعلى والأسفل كل ثانيتين)
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold مع extendBody لكي تمتد الكاميرا خلف الـ AppBar و الـ BottomNavigationBar
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black, // خلفية سوداء للكاميرا
      appBar: _buildGlassAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. خلفية الكاميرا (حالياً صورة، لاحقاً سنضع CameraPreview هنا)
          Opacity(
            opacity: 0.85,
            child: CachedNetworkImage(
              imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCG6FYHYKenv-rKK_z5XHLvMUPWj90ShWxwWv74-zSiI_7sRjmUVXIS3SLHNV_fB9G5UrEX6DBaeq-_lkbPZscJAdgGJhWY41UjJ7P_8VcE6lDtAqcPU9MzX_O2lErk_amVUebUtdGSFTs9PtnUwC9fwEzZM8uX6xKYQ3FZbVbuVAS8oxfdsb7y6aDU2_RLps2gVihufrjA0ibWBTBYddTo6dB256GBudNCWWG60ciMAovX44V8JAAyuSORxhDQQWvTNLq4XLVG_DQ",
              fit: BoxFit.cover,
            ),
          ),

          // 2. تدرج التعتيم (Vignette)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black54],
                stops: [0.4, 1.0],
                radius: 1.5,
              ),
            ),
          ),

          // 3. شريط البيانات البيئية (الطقس والموقع)
          Positioned(
            top: 100, // أسفل الـ AppBar
            left: 24,
            right: 24,
            child: _buildEnvironmentalData(),
          ),

          // 4. إطار المسح الضوئي (Scanning Frame)
          Center(
            child: _buildScanningFrame(),
          ),

          // 5. نص الإرشادات
          Positioned(
            bottom: 180,
            left: 24,
            right: 24,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "يرجى تركيز الكاميرا على المنطقة المراد فحصها",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 6. أزرار التحكم بالكاميرا
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: _buildCameraControls(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // الـ AppBar الزجاجي
  PreferredSizeWidget _buildGlassAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.7),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {},
            ),
            title: const Text(
              "تحليل البشرة",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    image: const DecorationImage(
                      image: CachedNetworkImageProvider("https://lh3.googleusercontent.com/aida-public/AB6AXuBFN6qyi6NPQm5vmu_onj1pPJNIeXCLcH6wy-HEBeH207vQ2J67-x3zyTmJ-L-_lRSllwUTZL8sXeNjJiFT5zZfVC77nTeRclIXQRi9FAFAgKhZYJEWD_mZX_Fkr-GqLkQoRv84tl_AOELGlBgTGSIWfIgDsED9OefDze-MG4EMfZwj41icR4O9bvbyB3G8pQ4lBH06JOxpvnGhPSBSzC7xUZ2qU11quhOGM9ipoYhX3mRYmpQefx6_ntjGkzokYD9Yd9id5jPkgnY"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // شريط البيانات البيئية
  Widget _buildEnvironmentalData() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(50),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 32, offset: Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDataPoint(Icons.thermostat, "24°"),
              Container(width: 1, height: 20, color: Colors.black45),
              _buildDataPoint(Icons.water_drop, "45%"),
              Container(width: 1, height: 20, color: Colors.black45),
              _buildDataPoint(Icons.light_mode, "UV: 6"),
              Container(width: 1, height: 20, color: Colors.black45),
              const Text(
                "34.05,-118", // اختصار لتناسب الشاشة
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataPoint(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 18),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  // المربع المضيء في المنتصف وخط المسح
  Widget _buildScanningFrame() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.width * 1.0, // نسبة 3/4 تقريباً
      child: Stack(
        children: [
          // الزوايا المضيئة
          _buildCorner(Alignment.topLeft),
          _buildCorner(Alignment.topRight),
          _buildCorner(Alignment.bottomLeft),
          _buildCorner(Alignment.bottomRight),

          // خط المسح المتحرك
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                top: _scanAnimation.value * (MediaQuery.of(context).size.width * 1.0 - 4),
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppTheme.greenGlow.withValues(alpha: 0.9), Colors.transparent],
                    ),
                boxShadow: const [
                  BoxShadow(color: AppTheme.greenGlow, blurRadius: 15, spreadRadius: 2),
                ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    // تحديد حواف المربع بناءً على الزاوية
    Border border;
    BorderRadius radius;
    const color = AppTheme.greenGlow;
    const width = 3.0;

    if (alignment == Alignment.topLeft) {
      border = const Border(top: BorderSide(color: color, width: width), left: BorderSide(color: color, width: width));
      radius = const BorderRadius.only(topLeft: Radius.circular(24));
    } else if (alignment == Alignment.topRight) {
      border = const Border(top: BorderSide(color: color, width: width), right: BorderSide(color: color, width: width));
      radius = const BorderRadius.only(topRight: Radius.circular(24));
    } else if (alignment == Alignment.bottomLeft) {
      border = const Border(bottom: BorderSide(color: color, width: width), left: BorderSide(color: color, width: width));
      radius = const BorderRadius.only(bottomLeft: Radius.circular(24));
    } else {
      border = const Border(bottom: BorderSide(color: color, width: width), right: BorderSide(color: color, width: width));
      radius = const BorderRadius.only(bottomRight: Radius.circular(24));
    }

    return Align(
      alignment: alignment,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(border: border, borderRadius: radius),
      ),
    );
  }

  // أزرار التحكم في الكاميرا
  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // زر الفلاش
        _buildGlassCircleButton(Icons.flash_off, 48),
        const SizedBox(width: 32),
        // زر الالتقاط الرئيسي
      // زر الالتقاط الرئيسي
        GestureDetector(
          onTap: () {
            // الانتقال لشاشة النتائج عند الضغط على زر التصوير
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnalysisResultScreen()),
            );
          },
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: AppTheme.pinkGlow.withValues(alpha: 0.5), blurRadius: 40)],
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppTheme.pinkGlow, AppTheme.greenGlow]),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        // زر تدوير الكاميرا
        _buildGlassCircleButton(Icons.flip_camera_ios, 48),
      ],
    );
  }

  Widget _buildGlassCircleButton(IconData icon, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: size,
          height: size,
          color: Colors.white.withValues(alpha: 0.5),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
      ),
    );
  }

  // شريط التنقل السفلي (Bottom Navigation Bar)
  Widget _buildBottomNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
// استبدل أول عنصر _buildNavItem بهذا الكود
GestureDetector(
  onTap: () {
    // الانتقال إلى شاشة المحادثة
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  },
  child: _buildNavItem(Icons.smart_toy_outlined, "المحادثة الذكية", false),
),
              _buildNavItem(Icons.center_focus_strong, "الفحص", true),
             // استبدل ثالث عنصر _buildNavItem بهذا الكود
GestureDetector(
  onTap: () {
    // الانتقال إلى شاشة السجل
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  },
  child: _buildNavItem(Icons.history, "السجل", false),
),
// استبدل آخر عنصر _buildNavItem بهذا الكود
GestureDetector(
  onTap: () {
    // الانتقال إلى شاشة الملف الشخصي
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  },
  child: _buildNavItem(Icons.person_outline, "الملف الشخصي", false),
),            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.black.withValues(alpha: isActive ? 1.0 : 0.6),
          size: isActive ? 28 : 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withValues(alpha: isActive ? 1.0 : 0.6),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}