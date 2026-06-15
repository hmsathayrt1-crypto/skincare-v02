# Dermalyze AI — Backend (PHP + MySQL / XAMPP)

واجهة برمجية بسيطة بلغة PHP متصلة بـ MySQL (phpMyAdmin ضمن XAMPP)، تستخدم نموذج
**Google Gemini Flash** (متعدد الوسائط) لتحليل صورة البشرة وكتابة الاستشارة في طلب واحد.

## 1) التشغيل على XAMPP

1. شغّل **Apache** و **MySQL** من لوحة XAMPP.
2. انسخ مجلد المشروع بحيث يصبح المسار:
   ```
   C:\xampp\htdocs\skincare\backend\
   ```
   (أو اعمل Symlink / غيّر `UPLOAD_URL` في `config.php` حسب مسارك الفعلي.)
3. افتح **phpMyAdmin** → تبويب **استيراد (Import)** → اختر الملف:
   ```
   backend/database/schema.sql
   ```
   سيُنشئ القاعدة `skincare_db` وكل الجداول تلقائياً.

## 2) الإعدادات (`config.php`)

| الثابت | الوصف |
|--------|-------|
| `GEMINI_API_KEY`     | مفتاحك من https://aistudio.google.com/apikey |
| `GEMINI_MODEL`       | `gemini-flash-latest` أو `gemini-2.5-flash` |
| `OPENWEATHER_API_KEY`| اختياري — لجلب الطقس حسب الموقع |
| `DB_*`               | إعدادات قاعدة البيانات (افتراضي XAMPP) |

## 3) نقاط النهاية (Endpoints)

| الطريقة | المسار | الوصف |
|---------|--------|-------|
| GET  | `/backend/` | فحص حالة الـ API |
| POST | `/backend/api/register.php` | إنشاء حساب |
| POST | `/backend/api/login.php` | تسجيل الدخول |
| POST | `/backend/api/analyze.php` | تحليل صورة بشرة (يتطلب توكن) |
| GET  | `/backend/api/scans.php` | سجل الفحوصات (يتطلب توكن) |
| GET  | `/backend/api/scans.php?id=N` | تفاصيل فحص (يتطلب توكن) |

المصادقة: أرسل التوكن في الترويسة `Authorization: Bearer <token>`.

## 4) أمثلة اختبار سريعة (PowerShell)

```powershell
# تسجيل
curl.exe -X POST http://localhost/skincare/backend/api/register.php `
  -H "Content-Type: application/json" `
  -d '{"full_name":"اختبار","email":"test@mail.com","password":"123456"}'

# تحليل صورة (استبدل TOKEN ومسار الصورة)
curl.exe -X POST http://localhost/skincare/backend/api/analyze.php `
  -H "Authorization: Bearer TOKEN" `
  -F "image=@C:\path\skin.jpg" -F "latitude=31.95" -F "longitude=35.93"
```

## ملاحظات
- هذا النظام **تعليمي** وليس بديلاً عن تشخيص طبيب مختص.
- الصور تُحفظ في `backend/uploads/` ويُخزَّن مسارها فقط في قاعدة البيانات.
