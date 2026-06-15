# خطة ربط تطبيق Flutter بالـ Backend (Dermalyze AI)

> هذا الملف **توثيق وخطة فقط**. لم يتم تعديل أي كود Flutter. اتبع الخطوات عندما تريد الربط.

---

## 0) نظرة عامة على التدفق (Flow)

```
[Flutter App]
   │  (1) تسجيل/دخول  ──────────────► POST /register.php أو /login.php
   │       ◄── يرجع { token, user }   (خزّن التوكن محلياً)
   │
   │  (2) كل طلب لاحق يحمل الترويسة:  Authorization: Bearer <token>
   │
   │  (3) التقاط صورة + GPS  ────────► POST /analyze.php (multipart)
   │       ◄── يرجع { scan: {condition, confidence, consultation, weather, image_path} }
   │
   │  (4) سجل الفحوصات  ────────────► GET /scans.php
   │       ◄── يرجع { scans: [...] }
```

النموذج المستخدم: **`gemini-3.5-flash`** (يحلل الصورة ويكتب الاستشارة في طلب واحد).

---

## 1) الحزم المطلوبة (pubspec.yaml)

أضف هذه الحزم لاحقاً:

```yaml
dependencies:
  http: ^1.2.0                  # طلبات الـ API
  image_picker: ^1.1.2          # فتح الكاميرا/المعرض
  geolocator: ^13.0.1           # إحداثيات GPS
  flutter_secure_storage: ^9.2.2 # تخزين التوكن بأمان
  permission_handler: ^11.3.1   # صلاحيات الكاميرا والموقع
```

ثم: `flutter pub get`

---

## 2) الصلاحيات (Permissions)

**Android** — `android/app/src/main/AndroidManifest.xml` داخل وسم `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>نحتاج الكاميرا لتحليل بشرتك</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>نحتاج موقعك لجلب بيانات الطقس</string>
```

---

## 3) عنوان الـ API حسب بيئة التشغيل (مهم جداً)

| الجهاز | الـ baseUrl |
|--------|-------------|
| متصفح / Flutter Web | `http://localhost/skincare/backend/api` |
| محاكي Android (Emulator) | `http://10.0.2.2/skincare/backend/api` |
| جهاز حقيقي على نفس الشبكة | `http://<IP-جهازك>/skincare/backend/api` مثل `http://192.168.1.20/...` |
| محاكي iOS | `http://localhost/skincare/backend/api` |

> المحاكي لا يرى `localhost` على أنه جهازك — يستخدم `10.0.2.2` للوصول لـ XAMPP.

---

## 4) هيكل ملفات Flutter المقترح (عند الربط)

```
lib/
├── core/
│   ├── api_config.dart      # baseUrl + ثوابت
│   └── api_client.dart      # دوال http (get/post/multipart) + إدارة التوكن
├── models/
│   ├── user.dart
│   └── scan.dart
├── services/
│   ├── auth_service.dart    # register / login / logout / حفظ التوكن
│   └── scan_service.dart    # analyze / getScans
└── features/
    ├── auth/ (موجود)        # اربط onTap في login_screen.dart بـ auth_service
    ├── home/
    ├── camera/              # التقاط الصورة + GPS ثم استدعاء analyze
    └── history/             # عرض سجل الفحوصات
```

---

## 5) عقود الـ API (Request/Response Contracts)

كل الردود بالشكل الموحّد: `{ "success": bool, "message": string, ...data }`.

### تسجيل / دخول
```
POST /register.php   body(JSON): { full_name, email, password, skin_type? }
POST /login.php      body(JSON): { email, password }
→ 200: { success:true, token:"...", user:{ id, full_name, email, skin_type } }
→ 401/409: { success:false, message:"..." }
```

### تحليل صورة (الأساسي)
```
POST /analyze.php
Header: Authorization: Bearer <token>
body (multipart/form-data):
   image     = <ملف JPG/PNG/WEBP>   (مطلوب، حتى 8MB)
   latitude  = 31.95                 (اختياري)
   longitude = 35.93                 (اختياري)
→ 200: {
     success:true,
     scan:{
       id, image_path, scan_date,
       weather:{ temperature, humidity, uv_index, description },
       condition, confidence, consultation
     }
  }
```

### السجل والملف الشخصي
```
GET  /scans.php             → { scans:[ {...}, ... ] }
GET  /scans.php?id=12       → { scan:{...} }
GET  /profile.php           → { user:{ ..., scans_count } }
POST /profile.php (JSON)    → تحديث { full_name, skin_type }
POST /logout.php            → إنهاء الجلسة
```

---

## 6) خطوات الربط بالترتيب (Checklist)

- [ ] **أ.** أضف الحزم (قسم 1) والصلاحيات (قسم 2).
- [ ] **ب.** أنشئ `api_config.dart` وضع فيه `baseUrl` المناسب (قسم 3).
- [ ] **ج.** أنشئ `api_client.dart`: دالة `post(json)`, `postMultipart(file, fields)`, `get()` تضيف ترويسة التوكن تلقائياً.
- [ ] **د.** أنشئ `auth_service.dart` واربط زرّي **"تسجيل الدخول"** و **"إنشاء حساب"** في `login_screen.dart` (حالياً `onTap` فارغة) بـ `/login.php` و `/register.php`. خزّن التوكن في `flutter_secure_storage`.
- [ ] **هـ.** اربط زر **"ابدأ الرحلة"** في `main.dart` بالتنقل لشاشة الكاميرا.
- [ ] **و.** شاشة الكاميرا: `image_picker` لالتقاط الصورة + `geolocator` للموقع → استدعاء `/analyze.php` → عرض شاشة تحميل → عرض النتيجة (`condition` + `confidence` + `consultation`).
- [ ] **ز.** شاشة السجل: `GET /scans.php` وعرض القائمة.
- [ ] **ح.** تأكد قبل كل طلب محمي من إرفاق `Authorization: Bearer <token>`، وعالج الحالة 401 (توكن منتهٍ) بإعادة المستخدم لشاشة الدخول.

---

## 7) نقاط انتبه لها

1. **CORS**: مفعّل أصلاً في `helpers.php` (`Access-Control-Allow-Origin: *`) لدعم Flutter Web.
2. **رفع الصورة**: استخدم `http.MultipartRequest` وليس `jsonEncode` — الحقل اسمه `image` بالضبط.
3. **حجم الصورة**: اضغطها قبل الرفع (مثلاً `imageQuality: 70` في image_picker) لتسريع التحليل.
4. **الطقس اختياري**: إن لم ترسل GPS أو لم يكن مفتاح OpenWeather مضبوطاً، يكمل التحليل بدون بيانات طقس.
5. **التوكن لكل جهاز**: كل تسجيل دخول ينشئ توكناً مستقلاً؛ `logout` يحذف الحالي فقط.
6. **HTTP محلي على Android 9+**: للسماح بـ `http://` (غير https) أضف `android:usesCleartextTraffic="true"` في وسم `<application>`.

---

## 8) اختبار الـ Backend قبل ربط Flutter

شغّله من PowerShell للتأكد أن كل شيء يعمل:
```powershell
# 1) فحص الحالة
curl.exe http://localhost/skincare/backend/

# 2) إنشاء حساب (انسخ التوكن من الرد)
curl.exe -X POST http://localhost/skincare/backend/api/register.php `
  -H "Content-Type: application/json" `
  -d '{"full_name":"تجربة","email":"t@t.com","password":"123456"}'

# 3) تحليل صورة
curl.exe -X POST http://localhost/skincare/backend/api/analyze.php `
  -H "Authorization: Bearer <التوكن>" `
  -F "image=@C:\Users\Abdalgani\Pictures\skin.jpg" `
  -F "latitude=31.95" -F "longitude=35.93"
```
إن نجحت هذه، فالربط مع Flutter سيكون مباشراً وفق العقود أعلاه.
