// كلاسات الأخطاء للتعامل مع حالات الفشل في التطبيق
// تتبع نمط Clean Architecture

/// الصنف الأساسي المجرد لجميع أنواع الأخطاء
abstract class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure && message == other.message && code == other.code;

  @override
  int get hashCode => message.hashCode ^ (code?.hashCode ?? 0);
}

/// خطأ الخادم (API)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });
}

/// خطأ الشبكة / الاتصال
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'لا يوجد اتصال بالإنترنت',
    super.code,
  });
}

/// خطأ التخزين المحلي
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'خطأ في التخزين المحلي',
    super.code,
  });
}

/// خطأ المصادقة
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'خطأ في المصادقة',
    super.code,
  });
}

/// خطأ الكاميرا
class CameraFailure extends Failure {
  const CameraFailure({
    super.message = 'خطأ في الوصول للكاميرا',
    super.code,
  });
}

/// خطأ تحديد الموقع
class LocationFailure extends Failure {
  const LocationFailure({
    super.message = 'خطأ في تحديد الموقع',
    super.code,
  });
}

/// خطأ التحقق من المدخلات
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'بيانات غير صالحة',
    super.code,
    this.fieldErrors,
  });
}
