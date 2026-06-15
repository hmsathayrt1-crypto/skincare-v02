# 03 - ربط Flutter بـ PHP Backend

## المشكلة

Flutter حالياً يشير لـ FastAPI (غير موجود):
```dart
// api_endpoints.dart
static const String baseUrl = 'http://localhost:8000/api/v1';
static const String authLogin = '/auth/login';
```

لكن الباك إند الحقيقي PHP على XAMPP:
```
http://localhost/backend/api/login.php
```

---

## التغييرات المطلوبة

### الملف: `lib/core/constants/api_endpoints.dart`

**قبل:**
```dart
static const String baseUrl = 'http://localhost:8000/api/v1';
static const String authLogin = '/auth/login';
static const String authRegister = '/auth/register';
static const String authLogout = '/auth/logout';
static const String skinAnalysis = '/analysis/skin';
static const String analysisHistory = '/analysis/history';
static const String analysisDetail = '/analysis/detail';
static const String chatMessage = '/chat/message';
static const String chatHistory = '/chat/history';
static const String userProfile = '/user/profile';
static const String userProfileUpdate = '/user/profile/update';
```

**بعد:**
```dart
// للأندرويد Emulator: استخدم 10.0.2.2
// للجهاز الحقيقي عبر WiFi: استخدم IP الكمبيوتر (مثلاً 192.168.1.x)
// للويب أو iOS Simulator: استخدم localhost
static const String baseUrl = 'http://10.0.2.2/backend/api';

static const String authLogin = '/login.php';
static const String authRegister = '/register.php';
static const String authLogout = '/logout.php';
static const String skinAnalysis = '/analyze.php';
static const String analysisHistory = '/scans.php';
static const String analysisDetail = '/scans.php';    // ?id=X
static const String chatMessage = '/chat.php';         // POST
static const String chatHistory = '/chat.php';         // GET
static const String userProfile = '/profile.php';      // GET
static const String userProfileUpdate = '/profile.php'; // POST
static const String dashboard = '/dashboard.php';
static const String tips = '/tips.php';

// حذف الـ endpoints غير الموجودة
// authRefresh - لا يوجد في PHP
// weatherData - الطقس يُجلب من الباك مباشرة
// locationData - الموقع يُرسل مع analyze
```

---

### الملف: `lib/core/network/dio_client.dart`

**التغييرات:**
1. تغيير `Content-Type` الافتراضي ليدعم `multipart/form-data` عند الرفع
2. إضافة `baseUrl` من `ApiEndpoints.baseUrl`
3. **مهم:** عند رفع الصورة، إضافة `latitude` و `longitude` مع الـ FormData

**تعديل دالة `uploadFile`:**
```dart
Future<Response> uploadFile(
  String path, {
  required String filePath,
  String fieldName = 'image',
  Map<String, dynamic>? extraFields,
}) async {
  final formData = FormData.fromMap({
    fieldName: await MultipartFile.fromFile(filePath),
    ...?extraFields,
  });
  return await _dio.post(path, data: formData);
}
```

---

### ملاحظة مهمة: عنوان الـ Base URL

| بيئة التشغيل | عنوان baseUrl |
|--------------|---------------|
| Android Emulator | `http://10.0.2.2/backend/api` |
| جهاز حقيقي (WiFi) | `http://192.168.X.X/backend/api` |
| iOS Simulator | `http://localhost/backend/api` |
| Flutter Web | `http://localhost/backend/api` |

**نصيحة:** اجعل الـ baseUrl يعتمد على `Platform`:
```dart
import 'dart:io' show Platform;

static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2/backend/api';
  }
  return 'http://localhost/backend/api';
}
```

---

## إنشاء Data Models

### الملف الجديد: `lib/core/models/user_model.dart`
```dart
class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? skinType;
  final String? avatarPath;
  final String? createdAt;
  final int? scansCount;
  
  // fromJson, toJson
}
```

### الملف الجديد: `lib/core/models/scan_model.dart`
```dart
class ScanModel {
  final int id;
  final String imagePath;
  final String scanDate;
  final double? latitude;
  final double? longitude;
  final double? temperature;
  final double? humidity;
  final double? uvIndex;
  final String? weatherDescription;
  final String? condition;
  final double? confidence;
  final String? consultation;
  
  // fromJson, toJson
}
```

### الملف الجديد: `lib/core/models/chat_message_model.dart`
```dart
class ChatMessageModel {
  final int id;
  final String role;     // 'user' or 'assistant'
  final String message;
  final String? imagePath;
  final String createdAt;
  
  // fromJson, toJson
}
```

---

## خطوات التنفيذ بالترتيب

1. تحديث `api_endpoints.dart` بالعناوين الصحيحة
2. إنشاء مجلد `lib/core/models/` وإضافة الـ models
3. تحديث `dio_client.dart` (دالة uploadFile + baseUrl)
4. إنشاء `lib/core/services/` مع:
   - `auth_service.dart` — login, register, logout
   - `scan_service.dart` — analyze, getHistory, getScan
   - `chat_service.dart` — sendMessage, getHistory
   - `profile_service.dart` — getProfile, updateProfile
5. اختبار كل endpoint عبر Postman أولاً
6. ربط الـ services بالشاشات
