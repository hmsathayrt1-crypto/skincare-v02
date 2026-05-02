import 'package:flutter/material.dart';

/// ثوابت الألوان المستخدمة في تطبيق العناية بالبشرة
class AppColors {
  AppColors._();

  // === الألوان الأساسية ===
  /// لون الخلفية الرئيسي - أبيض دافئ
  static const Color background = Color(0xFFFAF9F9);

  /// اللون الوردي المتوهج - اللون الأساسي
  static const Color pinkGlow = Color(0xFFFADADD);

  /// اللون الأخضر المتوهج - اللون الثانوي
  static const Color greenGlow = Color(0xFFB2C9AB);

  // === ألوان النصوص ===
  /// لون النص الرئيسي على الأسطح
  static const Color onSurface = Color(0xFF1B1C1C);

  /// لون النص الثانوي على الأسطح
  static const Color onSurfaceVariant = Color(0xFF4F4445);

  // === ألوان الأسطح ===
  /// لون الحاوية الثانوية الثابتة
  static const Color primaryFixed = Color(0xFFFBDBDE);

  /// لون الحاوية الثانوية الثابتة
  static const Color secondaryFixed = Color(0xFFEAE3BC);

  /// خلفية ثانوية ثابتة
  static const Color bgSecondaryFixed = Color(0xFF635F40);

  /// حاوية الأسطح العالية
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);

  /// حاوية الأسطح المنخفضة جداً
  static const Color surfaceContainerLowest = Color(0xFFF5F3F3);

  // === ألوان الحاويات ===
  /// حاوية اللون الأساسي
  static const Color primaryContainer = Color(0xFFFADADD);

  /// حاوية اللون الثانوي
  static const Color secondaryContainer = Color(0xFFCFE6C7);

  // === ألوان الحدود والفواصل ===
  /// لون الحدود الفاتحة
  static const Color borderLight = Color(0xFFD2C3C4);

  /// لون الفواصل
  static const Color divider = Color(0xFFE2E3E1);

  // === ألوان خاصة ===
  /// لون الروابط
  static const Color linkColor = Color(0xFFD46A7E);

  /// اللون الأخضر الداكن
  static const Color darkGreen = Color(0xFF384C35);

  /// مؤشر الاتصال الأخضر
  static const Color onlineIndicator = Color(0xFFD2E9CA);

  /// لون الظل الخفيف
  static const Color shadowLight = Color(0xFF70585B);

  // === ألوان شريط قوة كلمة المرور ===
  /// مؤشر القوة الضعيفة
  static const Color passwordWeak = Color(0xFF635F40);

  // === ألوان أنواع البشرة (للشريحة) ===
  /// بشرة دهنية
  static const Color oilyBg = Color(0xFFDCEDC8);
  static const Color oilyBorder = Color(0xFF8BC34A);

  /// بشرة جافة
  static const Color dryBg = Color(0xFFFFE0B2);
  static const Color dryBorder = Color(0xFFFF9800);

  /// بشرة عادية
  static const Color normalBg = Color(0xFFE0E0E0);
  static const Color normalBorder = Color(0xFF9E9E9E);

  /// بشرة مختلطة
  static const Color mixedBg = Color(0xFFE1BEE7);
  static const Color mixedBorder = Color(0xFF9C27B0);

  // === ألوان التوهج ===
  /// توهج وردي فاتح
  static const Color pinkLight = Color(0xFFFFC1E3);

  /// توهج أخضر فاتح
  static const Color greenLight = Color(0xFF8BC34A);

  // === ألوان الأزرار الاجتماعية ===
  /// لون فيسبوك
  static const Color facebook = Color(0xFF1877F2);
}
