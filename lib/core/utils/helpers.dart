/// دوال مساعدة عامة للتطبيق
class Helpers {
  Helpers._();

  /// الشهور الميلادية بالعربية
  static const List<String> _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  /// يعيد اسم الشهر الميلادي بالعربية
  static String getArabicMonth(int month) {
    if (month < 1 || month > 12) return '';
    return _arabicMonths[month - 1];
  }

  /// تنسيق التاريخ بالعربية: "12 أكتوبر 2023 • 09:30 ص"
  static String formatDateArabic(DateTime date) {
    final day = date.day;
    final month = getArabicMonth(date.month);
    final year = date.year;
    final time = formatTimeArabic(date);
    return '$day $month $year • $time';
  }

  /// تنسيق الوقت بالعربية: "09:30 ص"
  static String formatTimeArabic(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  /// اقتطاع النص مع إضافة "..."
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// التحقق من صحة رقم الهاتف (يبدأ بـ +، أرقام فقط)
  static bool isValidPhone(String phone) {
    final regex = RegExp(r'^\+\d{7,15}$');
    return regex.hasMatch(phone.replaceAll(' ', ''));
  }

  /// ترجمة نوع البشرة للعربية
  static String getSkinTypeNameArabic(String type) {
    switch (type.toLowerCase()) {
      case 'oily':
        return 'دهنية';
      case 'dry':
        return 'جافة';
      case 'normal':
        return 'عادية';
      case 'mixed':
      case 'combination':
        return 'مختلطة';
      default:
        return type;
    }
  }

  /// حساب قوة كلمة المرور (0.0 - 1.0)
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;

    // الطول
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.1;

    // أحرف كبيرة
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;

    // أحرف صغيرة
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;

    // أرقام
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;

    // رموز خاصة
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    return strength.clamp(0.0, 1.0);
  }

  /// وصف قوة كلمة المرور
  static String getPasswordStrengthLabel(double strength) {
    if (strength < 0.33) return 'ضعيفة';
    if (strength < 0.66) return 'متوسطة';
    return 'قوية';
  }
}
