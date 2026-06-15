# 02 - إصلاح وتطوير الـ API Endpoints

## المشكلة الرئيسية

Flutter يستخدم عناوين FastAPI:
```
http://localhost:8000/api/v1/auth/login
```
لكن الباك إند PHP فعلياً على:
```
http://localhost/backend/api/login.php
```

**الحل:** تحديث Flutter `api_endpoints.dart` ليتوافق مع PHP.

---

## الـ Endpoints الحالية (تعمل)

| Method | URL الحقيقي | الوظيفة | الحالة |
|--------|-------------|---------|--------|
| POST | `/backend/api/register.php` | إنشاء حساب | يعمل |
| POST | `/backend/api/login.php` | تسجيل دخول | يعمل |
| POST | `/backend/api/logout.php` | تسجيل خروج | يعمل |
| GET/POST | `/backend/api/profile.php` | عرض/تحديث البروفايل | يعمل |
| POST | `/backend/api/analyze.php` | تحليل صورة بشرة | يعمل (يحتاج مفتاح Gemini) |
| GET | `/backend/api/scans.php` | سجل الفحوصات | يعمل |
| GET | `/backend/api/scans.php?id=X` | تفاصيل فحص | يعمل |
| GET | `/backend/` | حالة الـ API | يعمل |

---

## الـ Endpoints المطلوب إضافتها

### 1. `POST /backend/api/chat.php` — إرسال رسالة للمحادثة الذكية

**المدخلات (JSON):**
```json
{
  "message": "أشعر بجفاف في بشرتي",
  "scan_id": 5        // اختياري - لربط المحادثة بفحص معين
}
```

**المخرجات:**
```json
{
  "success": true,
  "reply": {
    "id": 42,
    "role": "assistant",
    "message": "بناءً على تحليلك الأخير...",
    "created_at": "2026-06-09 18:00:00"
  }
}
```

**التنفيذ:**
- يحفظ رسالة المستخدم في `chat_messages`
- يرسلها لـ Gemini مع سياق آخر فحص + نوع البشرة
- يحفظ رد Gemini في `chat_messages`
- يُعيد الرد

---

### 2. `GET /backend/api/chat.php` — جلب سجل المحادثات

**المدخلات (Query):**
```
?limit=50&offset=0
```

**المخرجات:**
```json
{
  "success": true,
  "messages": [
    {"id": 1, "role": "assistant", "message": "مرحباً!", "created_at": "..."},
    {"id": 2, "role": "user", "message": "مرحباً", "created_at": "..."}
  ]
}
```

---

### 3. `DELETE /backend/api/scans.php` — حذف فحص

**المدخلات (JSON):**
```json
{ "id": 12 }
```

**التنفيذ:** Soft delete (`is_deleted = 1`)

---

### 4. `GET /backend/api/tips.php` — جلب نصائح يومية

**المدخلات (Query):**
```
?skin_type=oily
```

**المخرجات:**
```json
{
  "success": true,
  "tips": [
    {"id": 1, "tip_text": "اشربي 8 أكواب ماء يومياً", "skin_type": "oily", "season": "summer"}
  ]
}
```

---

### 5. `GET /backend/api/dashboard.php` — لوحة معلومات سريعة

**المخرجات:**
```json
{
  "success": true,
  "dashboard": {
    "total_scans": 15,
    "last_scan_date": "2026-06-09",
    "last_condition": "حب الشباب",
    "skin_type": "oily",
    "tip_of_the_day": "اشربي 8 أكواب ماء..."
  }
}
```

---

## إصلاحات على Endpoints الحالية

### `register.php`
- **إضافة:** استقبال حقل `phone` وحفظه
- **إضافة:** التحقق من صيغة رقم الهاتف (اختياري)
- **إضافة:** التحقق من `skin_type` ضمن القيم المسموحة

### `profile.php`
- **إضافة:** إرجاع حقل `phone`
- **إضافة:** استقبال وتحديث `phone`
- **إضافة:** رفع صورة شخصية (avatar)
- **إضافة:** إرجاع `date_of_birth` و `gender`

### `scans.php`
- **إضافة:** دعم pagination: `?limit=20&offset=0`
- **إضافة:** تصفية بالحالة: `?condition=حب الشباب`
- **إضافة:** فلترة بالتاريخ: `?from=2026-01-01&to=2026-06-09`
- **إصلاح:** إضافة `WHERE is_deleted = 0` بعد تفعيل الحذف الناعم

### `analyze.php`
- **إصلاح:** إرجاع `city_name` في الاستجابة إن توفر من OpenWeatherMap

---

## ملاحظات التنفيذ

1. كل endpoint جديد يحتاج `require_once '../helpers.php'` و `send_headers()`
2. الـ Endpoints المحمية تحتاج `$user = current_user()`
3. يجب تحديث `index.php` لعرض الـ endpoints الجديدة
