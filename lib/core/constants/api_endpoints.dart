/// ثوابت روابط API الخلفية (FastAPI)
class ApiEndpoints {
  ApiEndpoints._();

  /// الرابط الأساسي للخادم (سيتم تحديثه عند النشر)
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // === المصادقة ===
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // === تحليل البشرة ===
  static const String skinAnalysis = '/analysis/skin';
  static const String analysisHistory = '/analysis/history';
  static const String analysisDetail = '/analysis/detail';

  // === المحادثة الذكية ===
  static const String chatMessage = '/chat/message';
  static const String chatHistory = '/chat/history';

  // === المستخدم ===
  static const String userProfile = '/user/profile';
  static const String userProfileUpdate = '/user/profile/update';

  // === البيانات البيئية ===
  static const String weatherData = '/weather/current';
  static const String locationData = '/location/current';

  /// يعيد الرابط الكامل concatenating baseUrl + endpoint
  static String fullUrl(String endpoint) => '$baseUrl$endpoint';
}
