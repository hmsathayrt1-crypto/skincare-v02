# 07 - إصلاح الانتقال بين الواجهات (Navigation)

## المشاكل الحالية

### 1. تسجيل الدخول يتخطى المصادقة
**الموقع:** `login_screen.dart:235`
```dart
context.go('/camera'); // بدون أي تحقق!
```
**الإصلاح:** ربط بـ AuthService (انظر خطة 04)

### 2. التسجيل يتخطى المصادقة
**الموقع:** `register_screen.dart:341`
```dart
context.go('/camera'); // بدون أي تحقق!
```
**الإصلاح:** ربط بـ AuthService (انظر خطة 04)

### 3. شاشة الترحيب تقفز للكاميرا مباشرة
**الموقع:** `welcome_screen.dart` — زر "ابدأ الفحص الآمن"
```dart
context.go('/camera'); // المفروض يروح لـ /login أولاً
```
**الإصلاح:**
```dart
onTap: () {
  context.go('/login'); // أو /register حسب التصميم
},
```

### 4. لا يوجد Auth Guard (حماية المسارات)
**المشكلة:** يمكن الوصول لأي شاشة بدون تسجيل دخول عبر الـ URL
**الإصلاح:** إضافة `redirect` في GoRouter (انظر خطة 04)

### 5. شاشة النتائج لا تمرر بيانات
**الموقع:** `camera_screen.dart:74`
```dart
context.push('/analysis'); // بدون أي بيانات!
```
**الإصلاح:** تمرير ScanModel عبر `extra` (انظر خطة 05)

### 6. زر الرجوع في شاشة النتائج
**الموقع:** `analysis_result_screen.dart:150-155`
```dart
if (context.canPop()) {
  context.pop();
} else {
  context.go('/camera');
}
```
**الحالة:** يعمل بشكل صحيح

### 7. لا يوجد تسجيل خروج
**المشكلة:** لا يوجد زر خروج في أي مكان
**الإصلاح:** إضافة زر في شاشة الملف الشخصي:
```dart
// في profile_screen.dart
TextButton(
  onPressed: () async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/login');
  },
  child: const Text("تسجيل الخروج", style: TextStyle(color: Colors.red)),
),
```

### 8. أزرار القائمة الجانبية غير مفعلة
**الموقع:** `camera_screen.dart:189` و `profile_screen.dart:64`
```dart
onPressed: () {
  ScaffoldMessenger.of(context).showSnackBar(...); // لا تعمل!
},
```
**الإصلاح:** إما:
- **حذفها** إذا لا نحتاج قائمة جانبية
- **تحويلها** لزر رجوع أو فتح drawer

### 9. زر الإعدادات في الملف الشخصي
**الموقع:** `profile_screen.dart:76`
**الحالة:** يعرض SnackBar فقط
**الإصلاح:** بما أن هذا مشروع تخرج — يمكن حذف الزر أو إبقاءه كما هو

---

## التدفق الصحيح للتنقل (بعد الإصلاح)

```
تشغيل التطبيق
  ↓
[Auth Guard يتحقق من التوكن]
  ↓
هل المستخدم مسجل دخول؟
  ├─ لا → شاشة الترحيب (/)
  │        ├─ "ابدأ الفحص" → /login
  │        └─ "تسجيل الدخول" → /login
  │              ├─ نجح → /camera (مع Bottom Nav)
  │              └─ "إنشاء حساب" → /register
  │                    └─ نجح → /camera (مع Bottom Nav)
  │
  └─ نعم → /camera (مع Bottom Nav)
              ├─ التقاط صورة → Loading → /analysis (مع بيانات)
              ├─ Tab: المحادثة → /chat
              ├─ Tab: السجل → /history
              │     └─ ضغط على فحص → /analysis (مع بيانات)
              └─ Tab: الملف الشخصي → /profile
                    └─ تسجيل خروج → /login
```

---

## جدول كامل لحالة كل رابط تنقل

| من | إلى | الحالة | المشكلة |
|----|-----|--------|---------|
| Welcome → "ابدأ الفحص" | `/camera` | خطأ | يجب `/login` |
| Welcome → "تسجيل الدخول" | `/login` | صحيح | - |
| Login → زر "دخول" | `/camera` | خطأ | يجب API call أولاً |
| Login → "إنشاء حساب" | `/register` | صحيح | - |
| Register → زر "إنشاء حساب" | `/camera` | خطأ | يجب API call أولاً |
| Register → "سجل دخولك" | `/login` | صحيح | - |
| Camera → التقاط | `/analysis` | خطأ | يجب إرسال الصورة أولاً |
| Analysis → زر الرجوع | `/camera` | صحيح | - |
| Analysis → "استشارة خبير" | SnackBar | غير مفعل | يمكن ربطه بـ `/chat` |
| Chat → إرسال رسالة | SnackBar | غير مفعل | يجب ربط بـ API |
| Chat → رفع صورة | SnackBar | غير مفعل | يمكن تأجيله |
| Chat → إدخال صوتي | SnackBar | غير مفعل | يمكن تأجيله |
| History → فلترة | SnackBar | غير مفعل | يجب ربط بفلترة حقيقية |
| History → بطاقة فحص | لا ينتقل | خطأ | يجب `/analysis?id=X` |
| Profile → حفظ | SnackBar | غير مفعل | يجب ربط بـ API |
| Profile → إعدادات | SnackBar | غير مفعل | يمكن حذفه |
| Profile → قائمة جانبية | SnackBar | غير مفعل | يمكن حذفه |

---

## أولوية الإصلاح

1. **عاجل:** Auth guard + ربط Login/Register بالـ API
2. **عاجل:** ربط Camera بالتحليل + تمرير البيانات لـ Analysis
3. **مهم:** ربط History ببيانات حقيقية + إضافة onTap للبطاقات
4. **مهم:** ربط Profile بالـ API (حفظ + عرض)
5. **متوسط:** ربط Chat بالـ API
6. **منخفض:** إزالة/تفعيل الأزرار المعطلة (إعدادات، قائمة جانبية)
