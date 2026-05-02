import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

/// عميل HTTP أحادي يستخدم Dio للاتصال بخادم FastAPI
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }

  late final Dio _dio;

  /// طلب GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException {
      rethrow;
    }
  }

  /// طلب POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException {
      rethrow;
    }
  }

  /// طلب PUT
  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  /// طلب DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  /// رفع ملف (صورة البشرة)
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'image',
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
      });
      return await _dio.post(path, data: formData);
    } on DioException {
      rethrow;
    }
  }
}

/// معترض المصادقة - يضيف رمز Bearer تلقائياً
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // رمز المصادقة منتهي - يمكن إضافة منطق تجديد الرمز هنا
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('auth_token');
      });
    }
    handler.next(err);
  }
}
