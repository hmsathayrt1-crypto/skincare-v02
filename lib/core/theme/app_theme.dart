import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان المأخوذة من التصميم
  static const Color background = Color(0xFFFAF9F9);
  static const Color pinkGlow = Color(0xFFFADADD);
  static const Color greenGlow = Color(0xFFB2C9AB);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF4F4445);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: pinkGlow,
      colorScheme: ColorScheme.fromSeed(seedColor: pinkGlow),
      // إعداد الخطوط الافتراضية
      textTheme: TextTheme(
        // العناوين باستخدام خط Cairo
        displayLarge: GoogleFonts.cairo(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.02,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        // النصوص العادية باستخدام خط Tajawal
        bodyLarge: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
      ),
    );
  }

  
}