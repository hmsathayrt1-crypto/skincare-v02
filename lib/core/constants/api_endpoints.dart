/// ثوابت روابط API الخلفية (PHP)
class ApiEndpoints {
  ApiEndpoints._();

  /// الرابط الأساسي للخادم
  static const String baseUrl = 'http://10.0.2.2/backend/api';

  // === المصادقة ===
  static const String register = '/register.php';
  static const String login = '/login.php';
  static const String logout = '/logout.php';
  static const String profile = '/profile.php';

  // === تحليل البشرة ===
  static const String analyze = '/analyze.php';
  static const String scans = '/scans.php';

  // === المحادثة الذكية ===
  static const String chat = '/chat.php';

  // === أخرى ===
  static const String tips = '/tips.php';
  static const String dashboard = '/dashboard.php';

  /// يعيد الرابط الكامل
  static String fullUrl(String endpoint) => '$baseUrl$endpoint';
}
