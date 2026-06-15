# 10 - خطة الاختبار الشاملة

## بيئة الاختبار

| المكون | الأداة |
|--------|--------|
| Backend API | Postman / cURL / المتصفح |
| Database | phpMyAdmin |
| Frontend | Flutter على Android Emulator أو جهاز حقيقي |
| Backend Server | XAMPP Apache (`http://localhost/backend/`) |

---

## المرحلة 1: اختبار قاعدة البيانات

### 1.1 إنشاء القاعدة
```
1. افتح XAMPP Control Panel
2. شغّل Apache و MySQL
3. افتح http://localhost/backend/database/migrate_fresh_seed.php
4. تحقق من الرسالة: "تم إعادة بناء القاعدة بنجاح"
```

### 1.2 التحقق من الجداول
```
1. افتح phpMyAdmin (http://localhost/phpmyadmin)
2. اختر قاعدة skincare_db
3. تحقق من وجود الجداول:
   ✅ users (مع بيانات تجريبية)
   ✅ api_tokens
   ✅ scans (مع بيانات تجريبية)
   ✅ chat_messages
   ✅ skin_tips (مع بيانات تجريبية)
   ✅ user_routines
4. تحقق من الحقول الجديدة في users: phone, avatar_path, gender, date_of_birth
5. تحقق من الحقول الجديدة في api_tokens: expires_at, device_name
6. تحقق من الحقول الجديدة في scans: city_name, notes, is_deleted
```

---

## المرحلة 2: اختبار API (Postman)

### 2.1 اختبار حالة الـ API
```
GET http://localhost/backend/
Expected: {"success": true, "message": "الـ API يعمل ✅", ...}
```

### 2.2 اختبار التسجيل
```
POST http://localhost/backend/api/register.php
Headers: Content-Type: application/json
Body:
{
  "full_name": "مستخدم تجريبي",
  "email": "test@test.com",
  "password": "123456",
  "phone": "+962791234567",
  "skin_type": "oily"
}

Expected:
✅ Status 200
✅ success: true
✅ token: string (96 حرف)
✅ user.id: integer
✅ user.email: "test@test.com"

حالات الخطأ:
❌ بدون email → 400 "حقل البريد الإلكتروني مطلوب"
❌ email مكرر → 409 "البريد مسجل مسبقاً"
❌ password < 6 → 400 "كلمة المرور قصيرة"
```

### 2.3 اختبار تسجيل الدخول
```
POST http://localhost/backend/api/login.php
Body: {"email": "test@test.com", "password": "123456"}

Expected:
✅ Status 200
✅ token: string
✅ user object

حالات الخطأ:
❌ email خاطئ → 401
❌ password خاطئ → 401
❌ حقول فارغة → 400
```

**مهم:** احفظ التوكن لاستخدامه في الاختبارات التالية!

### 2.4 اختبار البروفايل
```
GET http://localhost/backend/api/profile.php
Headers: Authorization: Bearer <TOKEN>

Expected:
✅ user.full_name, user.email, user.skin_type
✅ user.scans_count: integer

---

POST http://localhost/backend/api/profile.php
Headers: Authorization: Bearer <TOKEN>
Body: {"full_name": "اسم جديد", "skin_type": "dry"}

Expected:
✅ user.full_name: "اسم جديد"
✅ user.skin_type: "dry"
```

### 2.5 اختبار تحليل الصورة (الأهم!)
```
POST http://localhost/backend/api/analyze.php
Headers: Authorization: Bearer <TOKEN>
Body (form-data):
  - image: [اختر أي صورة JPG]
  - latitude: 31.95
  - longitude: 35.93

Expected:
✅ Status 200
✅ scan.condition: string (اسم حالة)
✅ scan.confidence: number (0-1)
✅ scan.consultation: string (نص طويل بالعربية)
✅ scan.weather.temperature: number (أو null)
✅ scan.image_path: string يبدأ بـ /backend/uploads/

حالات الخطأ:
❌ بدون صورة → 400
❌ صيغة غير مدعومة → 400
❌ حجم > 8MB → 400
❌ بدون توكن → 401
❌ مفتاح Gemini غير صالح → 500 أو 502
```

**ملاحظة:** هذا الاختبار يتطلب أن يكون `GEMINI_API_KEY` مُعداً في `config.php`

### 2.6 اختبار سجل الفحوصات
```
GET http://localhost/backend/api/scans.php
Headers: Authorization: Bearer <TOKEN>

Expected:
✅ scans: array (قد يكون فارغاً أو يحتوي على فحوصات)

---

GET http://localhost/backend/api/scans.php?id=1
Headers: Authorization: Bearer <TOKEN>

Expected:
✅ scan object مع كل الحقول
```

### 2.7 اختبار تسجيل الخروج
```
POST http://localhost/backend/api/logout.php
Headers: Authorization: Bearer <TOKEN>

Expected:
✅ success: true

بعدها:
GET http://localhost/backend/api/profile.php
Headers: Authorization: Bearer <TOKEN> (نفس التوكن)

Expected:
❌ 401 (التوكن لم يعد صالحاً)
```

### 2.8 اختبار المحادثة (بعد إنشاء chat.php)
```
POST http://localhost/backend/api/chat.php
Headers: Authorization: Bearer <TOKEN>
Body: {"message": "ما أفضل روتين لبشرتي الدهنية؟"}

Expected:
✅ reply.role: "assistant"
✅ reply.message: string (نص عربي)

---

GET http://localhost/backend/api/chat.php
Headers: Authorization: Bearer <TOKEN>

Expected:
✅ messages: array (رسالتان على الأقل: user + assistant)
```

---

## المرحلة 3: اختبار Flutter (على الجهاز)

### 3.1 تحضير البيئة
```
1. تأكد أن XAMPP شغال (Apache + MySQL)
2. تأكد أن القاعدة موجودة (شغّل migrate_fresh_seed.php)
3. تأكد أن GEMINI_API_KEY مُعد في config.php
4. تأكد من baseUrl في api_endpoints.dart:
   - Emulator: http://10.0.2.2/backend/api
   - جهاز حقيقي: http://192.168.X.X/backend/api
5. شغّل: flutter run
```

### 3.2 اختبار تدفق المستخدم الأساسي (Golden Path)

```
الخطوة 1: فتح التطبيق
✅ تظهر شاشة الترحيب
✅ زر "ابدأ الفحص" يوجه لـ /login (وليس /camera)

الخطوة 2: إنشاء حساب
✅ الضغط على "إنشاء حساب" يفتح شاشة التسجيل
✅ ملء الحقول (الاسم، الإيميل، الهاتف، كلمة المرور)
✅ شريط قوة كلمة المرور يتغير مع الكتابة
✅ تطابق كلمتي المرور — أو رسالة خطأ
✅ الموافقة على الشروط مطلوبة
✅ بعد الضغط: مؤشر تحميل يظهر
✅ بعد النجاح: ينتقل لـ /camera مع Bottom Nav

الخطوة 3: الكاميرا
✅ الكاميرا تعمل (أو placeholder في emulator)
✅ الإحداثيات تظهر حقيقية (وليس 34.05,-118)
✅ الفلاش يعمل (زر فعلي)
✅ تبديل الكاميرا يعمل
✅ التقاط الصورة → مؤشر تحميل "جاري التحليل..."
✅ بعد النجاح: ينتقل لشاشة النتائج

الخطوة 4: نتائج التحليل
✅ الحالة المكتشفة حقيقية (من Gemini)
✅ نسبة الثقة حقيقية
✅ الاستشارة نص عربي حقيقي
✅ زر الرجوع يرجع للكاميرا

الخطوة 5: السجل
✅ الضغط على tab "السجل" يعرض الفحوصات
✅ الفحص الأخير يظهر في القائمة
✅ الضغط على فحص يفتح تفاصيله

الخطوة 6: الملف الشخصي
✅ الاسم والإيميل يظهران بشكل صحيح
✅ تغيير نوع البشرة + حفظ يعمل
✅ تسجيل الخروج يعود لشاشة الدخول

الخطوة 7: إعادة تسجيل الدخول
✅ كتابة الإيميل وكلمة المرور
✅ الدخول ينجح
✅ البيانات السابقة (السجل، البروفايل) موجودة
```

### 3.3 اختبار حالات الخطأ

```
❌ تسجيل دخول بإيميل غير موجود → رسالة خطأ واضحة
❌ تسجيل دخول بكلمة مرور خاطئة → رسالة خطأ
❌ تسجيل بإيميل مكرر → رسالة "البريد مسجل مسبقاً"
❌ إيقاف XAMPP ثم محاولة تسجيل دخول → رسالة "فشل الاتصال بالسيرفر"
❌ التقاط صورة بدون إنترنت → رسالة خطأ
❌ رفض صلاحيات الكاميرا → عرض placeholder مع رسالة
❌ رفض صلاحيات الموقع → يكمل بدون إحداثيات
```

### 3.4 اختبار المحادثة الذكية

```
✅ فتح شاشة المحادثة → جلب الرسائل السابقة (أو فارغة)
✅ كتابة رسالة "ما أفضل روتين لبشرتي؟" → إرسال
✅ مؤشر "يكتب..." يظهر
✅ رد المساعد يظهر (نص عربي منطقي)
✅ إرسال رسالة ثانية → الرد يأخذ بعين الاعتبار السياق السابق
```

---

## المرحلة 4: اختبار إضافي

### 4.1 اختبار الصور
```
✅ رفع صورة JPG → يعمل
✅ رفع صورة PNG → يعمل
✅ رفع صورة WEBP → يعمل
❌ رفع ملف PDF → رفض
❌ رفع صورة > 8MB → رفض
```

### 4.2 اختبار الأداء
```
✅ زمن تحليل الصورة (Gemini): أقل من 15 ثانية
✅ زمن تسجيل الدخول: أقل من 2 ثانية
✅ زمن جلب السجل: أقل من 3 ثوانٍ
✅ زمن إرسال رسالة المحادثة: أقل من 10 ثوانٍ
```

### 4.3 التحقق من البيانات في القاعدة
```
بعد كل اختبار، افتح phpMyAdmin وتحقق:
✅ جدول users: المستخدم الجديد موجود مع كلمة مرور مشفرة
✅ جدول api_tokens: التوكن موجود ومرتبط بالمستخدم
✅ جدول scans: الفحص محفوظ مع كل البيانات
✅ جدول chat_messages: الرسائل محفوظة
✅ مجلد uploads/: الصورة محفوظة فعلياً
```

---

## قائمة التحقق النهائية (Checklist)

### Backend
- [ ] القاعدة تُنشأ بنجاح عبر migrate_fresh_seed.php
- [ ] مفتاح Gemini مُعد
- [ ] register.php يعمل
- [ ] login.php يعمل
- [ ] logout.php يعمل
- [ ] profile.php GET يعمل
- [ ] profile.php POST يعمل
- [ ] analyze.php يعمل (مع صورة حقيقية)
- [ ] scans.php يعمل (قائمة وتفاصيل)
- [ ] chat.php يعمل (إرسال واستقبال)

### Frontend
- [ ] شاشة الترحيب تعمل
- [ ] شاشة تسجيل الدخول تتصل بالـ API
- [ ] شاشة التسجيل تتصل بالـ API
- [ ] الكاميرا تعمل وترسل الصورة
- [ ] شاشة النتائج تعرض بيانات حقيقية
- [ ] المحادثة الذكية ترسل وتستقبل
- [ ] السجل يعرض فحوصات حقيقية
- [ ] الملف الشخصي يعرض ويحفظ
- [ ] تسجيل الخروج يعمل
- [ ] Auth Guard يمنع الوصول بدون تسجيل

### Navigation
- [ ] كل الأزرار تعمل (لا يوجد SnackBar بدون وظيفة)
- [ ] Bottom Nav يحتفظ بالحالة عند التنقل
- [ ] زر الرجوع يعمل بشكل صحيح
- [ ] لا يمكن الوصول لشاشات محمية بدون تسجيل
