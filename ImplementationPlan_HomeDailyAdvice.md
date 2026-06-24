# خطة التنفيذ: الشاشة الرئيسية + "نصيحة اليوم" بالذكاء الاصطناعي

> الهدف: إضافة **شاشة رئيسية (Home)** تظهر فور تسجيل الدخول، تعرض **نصيحة يومية واحدة** يولّدها الذكاء
> الاصطناعي اعتماداً على **نوع بشرة المستخدم + بيانات الطقس + الموقع** (قرب البحر / الارتفاع عن سطح البحر).
> نصيحة واحدة فقط لكل يوم لكل مستخدم، تُولّد عند أول فتح/تسجيل دخول في اليوم وتُخزَّن (Cache) لباقي اليوم.

---

## 1) النطاق والوضع الحالي

| العنصر | الوضع الحالي | ما سنغيّره |
|--------|--------------|-----------|
| التوجيه بعد الدخول | `login_screen.dart:44` → `context.go('/home')` ثم `/home` يحوّل إلى `/chat` (`app_router.dart:117-121`) | يصبح `/home` شاشة فعلية وهي أول تبويب |
| شريط التنقل | 4 تبويبات: المحادثة، الفحص، السجل، الملف (`main_layout.dart`) | تُضاف "الرئيسية" كأول تبويب (يصبح 5 تبويبات) |
| النصائح | ثابتة من جدول `skin_tips` عبر `tips.php` / `dashboard.php` | نصيحة **مولّدة بالـ AI** يومياً عبر endpoint جديد |
| الطقس | `fetch_weather()` يعتمد OpenWeather ومفتاحه فارغ في `config.php:33` | نضيف بديلاً مجانياً بدون مفتاح (Open‑Meteo) + ارتفاع الموقع |
| الموقع | `location_service.dart` يعطي lat/lon فقط | نضيف اشتقاق "اسم المدينة + الارتفاع + قرب البحر" |

البنية الحالية كلها جاهزة لإعادة الاستخدام: بوابة AI متوافقة مع OpenAI تعمل في `helpers.php`،
ومصادقة Bearer، ونمط Service/Provider في Flutter.

---

## 2) القرارات المعتمدة (هذه اختياراتي وأنت طلبت أن أختار)

### 2.1 نموذج الذكاء الاصطناعي  ✅ (مُختبَر فعلياً على البوابة)
نختار **`gemini-2.5-flash` مع `reasoning_effort: "none"`** لنصيحة اليوم.

**اختبرتُ البوابة فعلياً واكتشفت أن كل نماذج gemini عليها "نماذج تفكير" (thinking)** — حتى `gemini-2.5-flash`
يلتهم التوكنات في التفكير. النتائج المقاسة لنفس الطلب (نصيحة قصيرة):

| الإعداد | finish | توكنات التفكير | إجمالي التوكنات | الزمن | الجودة |
|---------|--------|----------------|-----------------|-------|--------|
| `gemini-2.5-flash` max_tokens=256 (بلا علم) | length ✗ | 243 | 286 | 8s | رد مبتور/إنجليزي ✗ |
| `gemini-2.5-flash` max_tokens=2048 | stop | 970 | **1136** | 9s | جيدة لكن غالية |
| **`gemini-2.5-flash` + `reasoning_effort=none`** | **stop ✓** | **0** | **182** | **8s** | **سطران رسميان نظيفان ✓** |
| `gemini-flash-latest` max_tokens=2048 | stop | 488 | 672 | **41s** ✗ | جيدة لكن بطيئة جداً |

**الفائز:** `reasoning_effort: "none"` يُطفئ التفكير تماماً → **182 توكن فقط (أرخص ٦×) وأسرع** ونص عربي رسمي
سليم. هذا الإعداد المعتمد في الكود.

**الإعداد المنفّذ في `config.php`:**
```php
define('DAILY_TIP_MODEL', 'gemini-2.5-flash');
define('DAILY_TIP_REASONING', 'none');     // none | low | medium | high
define('DAILY_TIP_MAX_TOKENS', 300);
```
معاملات الاستدعاء: `temperature = 0.7`، `max_tokens = 300`، `reasoning_effort = none`، بدون `response_format` (نص عادي لا JSON).

### 2.2 مصدر الطقس والموقع (الأهم: "قرب البحر / الارتفاع عن سطح البحر")
مفتاح OpenWeather فارغ، لذلك نعتمد **Open‑Meteo (مجاني وبدون مفتاح API)** ويغطي كل ما نحتاجه:

| البيان | المصدر | الرابط |
|--------|--------|--------|
| الطقس (حرارة/رطوبة/وصف) | Open‑Meteo Forecast | `https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&current=temperature_2m,relative_humidity_2m,weather_code` |
| الارتفاع عن سطح البحر (متر) | Open‑Meteo Elevation | `https://api.open-meteo.com/v1/elevation?latitude=..&longitude=..` |
| اسم المدينة (بالعربية) | BigDataCloud reverse-geocode (بدون مفتاح) — لأن Open‑Meteo لا يدعم الـ reverse | `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=..&longitude=..&localityLanguage=ar` |

**اشتقاق "قرب البحر / مرتفع"** من الارتفاع (heuristic بسيط داخل الـ Backend):
- ارتفاع `< 50م` → "قريب من مستوى سطح البحر، غالباً منطقة ساحلية رطبة".
- `50–800م` → "ارتفاع معتدل".
- `> 800م` → "مرتفع عن سطح البحر، هواء أجف وأشعة شمس أقوى".

نمرّر هذا الوصف نصياً للنموذج ونترك له ربط التأثير على البشرة (أبسط وأدق من محاولة كشف السواحل برمجياً).

> ملاحظة: نُبقي `fetch_weather()` (OpenWeather) كما هي كخيار احتياطي إن وضع المستخدم مفتاحاً، لكن الافتراضي = Open‑Meteo.

### 2.3 البرومت النهائي (اعتمدنا برومتك الرسمي — الأسلوب الطبي الجاف)
اخترنا برومتك الثاني (الرسمي/الطبي المختصر) لأنه أنسب لـ "توصية اليوم": فصلناه إلى رسالة `system`
(القواعد) ورسالة `user` (المعطيات) لأن البوابة Chat‑Completions، وأضفنا "لا تذكر أنك ذكاء اصطناعي".

**رسالة system (المنفّذة في `generate_daily_advice`):**
```
أنت مستشار طبي متخصص في طب الجلدية. مهمتك تقديم توصية يومية مقتضبة، رسمية، ومباشرة بناءً على المعطيات المحددة.
الشروط:
1. الإيجاز الصارم: ألا تتجاوز التوصية سطراً واحداً إلى سطرين كحد أقصى.
2. الأسلوب: رسمي، مهني، وطبي جاف (تجنّب العبارات الودية أو التسويقية).
3. المضمون: اربط نوع البشرة بالطقس والموقع الحالي مباشرة، وحدّد الإجراء أو المادة الفعّالة المطلوبة (مثل: حمض الهيالورونيك، واقي شمس فيزيائي) دون ذكر علامات تجارية.
4. البداية: ابدأ بالتوصية مباشرة دون أي مقدمات أو ترحيب أو صياغات إنشائية، ولا تكرّر المعطيات، ولا تذكر أنك ذكاء اصطناعي.
```

**رسالة user (تُملأ من بيانات المستخدم):**
```
نوع البشرة: {skinType}
الطقس: {weather}
الموقع: {location}

أصدر التوصية الطبية المناسبة باختصار شديد.
```

مثال مُختبَر فعلياً (بشرة جافة، جدة):
`{location}` = `جدة، السعودية — قريب من مستوى سطح البحر (ارتفاع 9م)، غالباً منطقة ساحلية رطبة`
→ المخرَج: *«للبشرة الجافة في جدة، مع طقس حار وجاف، يوصى باستخدام مرطب غني بحمض الهيالورونيك مع واقي شمس واسع الطيف بعامل حماية لا يقل عن 50.»*

قيم بديلة عند نقص البيانات: نوع البشرة غير محدد → "غير محدد"؛ تعذّر الطقس/الموقع → "غير متوفر" (يبقى النموذج قادراً على إعطاء نصيحة عامة).

---

## 3) تغييرات الـ Backend (PHP)

### 3.1 جدول جديد لتخزين نصيحة اليوم (يفرض نصيحة واحدة/يوم/مستخدم)
يُضاف إلى `backend/database/schema.sql` و`migrate_fresh_seed.php`:
```sql
CREATE TABLE IF NOT EXISTS `daily_advice` (
  `id`                  INT AUTO_INCREMENT PRIMARY KEY,
  `user_id`             INT  NOT NULL,
  `advice_date`         DATE NOT NULL,
  `advice_text`         TEXT NOT NULL,
  `skin_type`           VARCHAR(50)  NULL,
  `temperature`         DOUBLE       NULL,
  `humidity`            DOUBLE       NULL,
  `weather_description` VARCHAR(190) NULL,
  `city_name`           VARCHAR(100) NULL,
  `latitude`            DOUBLE       NULL,
  `longitude`           DOUBLE       NULL,
  `elevation`           DOUBLE       NULL,
  `created_at`          DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uniq_user_day` (`user_id`, `advice_date`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```
قيد `UNIQUE(user_id, advice_date)` هو ضمان "نصيحة واحدة فقط في اليوم".

### 3.2 دوال جديدة في `helpers.php`
- `fetch_weather_openmeteo(?float $lat, ?float $lon): array` — يرجع `[temperature, humidity, description]` بدون مفتاح.
- `fetch_elevation(?float $lat, ?float $lon): ?float` — متر فوق سطح البحر من Open‑Meteo.
- `reverse_city(?float $lat, ?float $lon): ?string` — اسم المدينة (اختياري).
- `describe_location(?string $city, ?float $elevation): string` — يبني نص `{location}` حسب heuristic القسم 2.2.
- `generate_daily_advice(?string $skinType, string $weatherCtx, string $locationCtx): string` — يستدعي البوابة بـ `DAILY_TIP_MODEL` ورسالتي system/user من القسم 2.3 (يعيد استخدام `http_post_json` و`ai_auth_headers` الموجودين). عند فشل/عدم تهيئة المفتاح: يرجع نصيحة عامة احتياطية ثابتة بدل الانهيار.

### 3.3 Endpoint جديد: `backend/api/daily_advice.php`
```
GET /api/daily_advice.php?lat=..&lon=..        (Authorization: Bearer <token>)
```
المنطق:
1. `current_user()` → نحصل على `skin_type` (وربما `gender` لاحقاً).
2. ابحث في `daily_advice` عن صف `user_id = ? AND advice_date = CURDATE()`.
   - **إن وُجد** → أعِده مباشرة (Cache hit، لا استدعاء AI، لا تكلفة).
3. **إن لم يوجد:**
   - `fetch_weather_openmeteo(lat, lon)` + `fetch_elevation(lat, lon)` + `reverse_city(...)`.
   - ابنِ `weatherCtx` و`locationCtx` (`describe_location`).
   - `advice = generate_daily_advice(skinType, weatherCtx, locationCtx)`.
   - `INSERT` في `daily_advice` (مع snapshot للطقس/الموقع).
   - أعِد النصيحة.
4. شكل الاستجابة (متوافق مع `ok()` الموجود):
```json
{
  "success": true,
  "advice": {
    "advice_date": "2026-06-24",
    "advice_text": "نصيحة اليوم لبشرتك...",
    "weather": { "temperature": 31, "humidity": 55, "description": "صافٍ" },
    "location": { "city_name": "جدة", "elevation": 12 }
  }
}
```

> سباق الطلبات (نفس المستخدم يفتح التطبيق مرتين): يُعالَج بـ `INSERT ... ON DUPLICATE KEY UPDATE` أو `try/catch` على قيد UNIQUE ثم إعادة القراءة، فلا تُولَّد نصيحتان.

### 3.4 إعداد `config.php`
- إضافة `DAILY_TIP_MODEL`.
- (اختياري) ثابت `WEATHER_PROVIDER = 'openmeteo'` للتبديل بين Open‑Meteo و OpenWeather.

---

## 4) تغييرات الواجهة الأمامية (Flutter)

### 4.1 ملفات جديدة
| الملف | المسؤولية |
|-------|-----------|
| `lib/features/home/screens/home_screen.dart` | الشاشة الرئيسية (ترجمة `new add/code.html` إلى Flutter: هيدر + ودجت طقس/موقع + بطاقة "نصيحة اليوم" + ملخص آخر تحليل) |
| `lib/core/models/daily_advice_model.dart` | نموذج بيانات النصيحة (`adviceText`, `adviceDate`, طقس، موقع) |
| `lib/core/services/daily_advice_service.dart` | استدعاء `GET /daily_advice.php` عبر `DioClient` (بنفس نمط `chat_service.dart`) مع تمرير `lat,lon` |
| `lib/core/providers/daily_advice_provider.dart` | **Riverpod** `StateNotifierProvider<…, AsyncValue<DailyAdviceModel>>` يحمّل النصيحة مرة واحدة (حالات loading/error/data) بنفس نمط `chat_provider.dart` |

> ملاحظة: المشروع يستخدم **Riverpod** (وليس Provider/ChangeNotifier) — المزوّدات عامة (global) فلا تحتاج تسجيلاً في `main.dart`.

### 4.2 تعديلات على ملفات موجودة
- **`api_endpoints.dart`**: إضافة `static const String dailyAdvice = '/daily_advice.php';`.
- **`app_router.dart`**:
  - حذف مسار `/home` الذي كان يحوّل إلى `/chat`.
  - إضافة **فرع جديد كأول فرع (index 0)** داخل `StatefulShellRoute.indexedStack` لمسار `/home` يبني `HomeScreen`.
  - ترتيب الفروع الجديد: `0:/home` ، `1:/chat` ، `2:/camera` ، `3:/history` ، `4:/profile`.
  - يبقى redirect ما بعد الدخول كما هو (`isLoggedIn && isOnPublicPath → '/home'`) لأنه أصبح شاشة فعلية.
- **`main_layout.dart`**: إضافة عنصر تنقل "الرئيسية" (أيقونة `Icons.home_outlined`) كأول عنصر، وتعديل الفهارس من 0..4.

### 4.3 سلوك الشاشة الرئيسية (HomeScreen)
1. في `initState`/أول بناء → `LocationService.getCurrentPosition()` (إن رُفض الإذن، نكمل بدون موقع).
2. استدعاء `HomeProvider.loadDailyAdvice(lat, lon)` مرة واحدة.
3. حالة التحميل: Shimmer/مؤشر دائري داخل بطاقة "نصيحة اليوم".
4. عرض النص العائد، مع زر "تحديث" اختياري (لن يولّد جديداً قبل الغد لأن الـ Backend يرجع نسخة اليوم المخزّنة).
5. التصميم: نطبّق نظام ألوان `new add/DESIGN (2).md` (وردي/سيج، خط Cairo، RTL، بطاقات زجاجية `premium-card`).

---

## 5) تدفق المستخدم (User Flow)
```
تسجيل الدخول ─▶ /home (الشاشة الرئيسية)
                 │
                 ├─ طلب إذن الموقع (مرة واحدة)
                 ├─ GET /daily_advice.php?lat&lon
                 │       │
                 │       ├─ يوجد صف لليوم؟ ──نعم──▶ يعيد النصيحة المخزّنة (بلا تكلفة AI)
                 │       └─ لا ▶ يجلب الطقس+الارتفاع+المدينة ▶ يستدعي gemini-2.5-flash
                 │              ▶ يخزّن في daily_advice ▶ يعيد النصيحة
                 └─ عرض "نصيحة اليوم لبشرتك..." + ودجت الطقس/الموقع + ملخص آخر فحص
```

---

## 6) خطوات التنفيذ بالترتيب
1. **Backend – قاعدة البيانات:** إضافة جدول `daily_advice` إلى `schema.sql` و`migrate_fresh_seed.php`، وتشغيل migration.
2. **Backend – الدوال:** إضافة دوال Open‑Meteo + `describe_location` + `generate_daily_advice` في `helpers.php`، وثابت `DAILY_TIP_MODEL` في `config.php`.
3. **Backend – Endpoint:** إنشاء `daily_advice.php` مع منطق الـ Cache اليومي.
4. **اختبار الـ Backend:** عبر المتصفح/Postman بتوكن صالح والتأكد من: (أ) التوليد أول مرة، (ب) إعادة نفس النص ثانية بلا استدعاء AI، (ج) اختلاف النصيحة بتغيّر lat/lon.
5. **Frontend – الطبقة:** `daily_advice_model` → `daily_advice_service` → `home_provider` → تسجيله في `main.dart`.
6. **Frontend – الشاشة:** بناء `home_screen.dart` حسب `code.html` + ربطه بالـ Provider.
7. **Frontend – التنقل:** تعديل `app_router.dart` و`main_layout.dart` و`api_endpoints.dart`.
8. **تشغيل وتحقق:** `flutter run`، الدخول، ورؤية النصيحة تظهر فوراً وتتغيّر تأثّرها بالطقس/الموقع، وثباتها طوال اليوم.

---

## 7) الاختبار والقبول (Acceptance Criteria)
- [ ] بعد تسجيل الدخول تظهر الشاشة الرئيسية مباشرة (لا تحويل إلى الشات).
- [ ] تظهر نصيحة واحدة تبدأ بـ "نصيحة اليوم لبشرتك..." خلال ثوانٍ.
- [ ] النصيحة تعكس نوع البشرة + الطقس + الموقع (تجربة بإحداثيات ساحلية مقابل مرتفعة → نصيحة مختلفة).
- [ ] فتح التطبيق ثانيةً نفس اليوم → نفس النصيحة (بلا استدعاء AI جديد — تحقق من السجلات).
- [ ] رفض إذن الموقع → نصيحة عامة بلا انهيار.
- [ ] عدم وجود مفتاح AI → رسالة/نصيحة احتياطية لطيفة.

---

## 8) اعتبارات وتحسينات مستقبلية
- **مخاطبة حسب الجنس:** استخدام `users.gender` لجعل البداية "بشرتكِ/بشرتك" تلقائياً.
- **ربط زر "تسوق المنتجات المقترحة"** في البطاقة بتبويب منتجات لاحقاً (غير مشمول الآن).
- **مؤشر UV:** يتطلب One Call API مدفوع؛ يمكن لاحقاً تمريره ضمن `{weather}` لتحسين نصيحة واقي الشمس.
- **إشعار يومي (Push)** يذكّر المستخدم بنصيحة اليوم.
- **تنظيف الجدول:** مهمة دورية لحذف صفوف `daily_advice` الأقدم من ٣٠ يوماً للحفاظ على الحجم.
- **تنبيه طبي:** النصيحة تعليمية وليست بديلاً عن طبيب (نضيف سطراً صغيراً في الواجهة).
