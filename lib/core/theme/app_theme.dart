import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ثيم التطبيق - الألوان والخطوط والأنماط
class AppTheme {
  AppTheme._();

  // === الألوان الأساسية ===
  static const Color background = Color(0xFFFAF9F9);
  static const Color pinkGlow = Color(0xFFFADADD);
  static const Color greenGlow = Color(0xFFB2C9AB);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF4F4445);

  // === الثيم الفاتح ===
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: pinkGlow,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pinkGlow,
        brightness: Brightness.light,
        surface: background,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        primary: pinkGlow,
        secondary: greenGlow,
      ),
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
        displaySmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleSmall: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
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
        bodySmall: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        labelSmall: GoogleFonts.tajawal(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
      ),
      // نمط حقول الإدخال
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFd2c3c4), width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFd2c3c4), width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: pinkGlow, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: Colors.black87),
      ),
    );
  }

  // === الثيم الداكن ===
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      primaryColor: pinkGlow,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pinkGlow,
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1A1A),
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
        primary: pinkGlow,
        secondary: greenGlow,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.02,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        labelLarge: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelSmall: GoogleFonts.tajawal(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24, width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: pinkGlow, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: Colors.white60),
      ),
    );
  }
}
