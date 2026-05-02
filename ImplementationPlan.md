# خطة إصلاح مشروع SkinCare v02

## ملخص المشاكل المكتشفة
تم تشغيل `flutter analyze` ووجد **73 مشكلة** موزعة كالتالي:

| النوع | العدد | الخطورة |
|-------|-------|---------|
| `deprecated_member_use` (withOpacity) | 50 | متوسطة - deprecated API |
| `prefer_const_constructors` | 7 | منخفضة - أداء |
| `prefer_const_literals_to_create_immutables` | 2 | منخفضة - أداء |
| `unused_import` | 1 | متوسطة - كود ميت |
| `unreachable_switch_default` | 1 | متوسطة - منطق |
| `asset_directory_does_not_exist` | 2 | عالية - بناء |
| ملفات فارغة بلا محتوى | 9 | عالية - بنية ناقصة |
| اختبار قديم لا يطابق الكود | 1 | متوسطة |
| عدم استخدام go_router رغم إضافته | 1 | عالية - معمارية |

---

## المرحلة 1: إصلاح مشاكل التحليل الثابت (Static Analysis)

### 1.1 إصلاح `withOpacity` → `withValues()` في كل الملفات
الـ API الجديد: `Color.withValues(alpha: 0.7)` بدلاً من `Color.withOpacity(0.7)`

| الملف | عدد الاستبدالات |
|-------|----------------|
| chat_screen.dart | 7 |
| login_screen.dart | 2 |
| register_screen.dart | 5 |
| welcome_screen.dart | 3 |
| camera_screen.dart | 10 |
| analysis_result_screen.dart | 12 |
| history_screen.dart | 7 |
| profile_screen.dart | 7 |
| **المجموع** | **53** |

### 1.2 إصلاح `prefer_const_constructors`
| الملف | السطر | المطلوب |
|-------|-------|---------|
| chat_screen.dart | 48, 50, 52, 56 | إضافة `const` |
| profile_screen.dart | 150, 152 | إضافة `const` |
| analysis_result_screen.dart | 159, 161 | إضافة `const` |

### 1.3 إصلاح `prefer_const_literals_to_create_immutables`
| الملف | السطر |
|-------|-------|
| camera_screen.dart | 242 |
| analysis_result_screen.dart | 158 |

### 1.4 إصلاح مشاكل منطقية
| الملف | المشكلة | الإصلاح |
|-------|---------|---------|
| history_screen.dart:4 | unused import: app_theme.dart | حذف الاستيراد غير المستخدم |
| history_screen.dart:54 | unreachable_switch_default | حذف `default` الزائد |

---

## المرحلة 2: إصلاح البنية الناقصة (Empty Files)

### 2.1 ملفات Core فارغة
| الملف | المحتوى المطلوب |
|-------|----------------|
| `app_colors.dart` | تعريف الألوان المستخدمة في التطبيق |
| `app_strings.dart` | ثوابت النصوص العربية |
| `api_endpoints.dart` | روابط API الخلفية |
| `failures.dart` | كلاس Failure للتعامل مع الأخطاء |
| `dio_client.dart` | إعداد Dio مع Interceptors |
| `helpers.dart` | دوال مساعدة (تنسيق التاريخ، إلخ) |

### 2.2 ملفات Services فارغة
| الملف | المحتوى المطلوب |
|-------|----------------|
| `camera_service.dart` | خدمة الكاميرا مع camera package |
| `location_service.dart` | خدمة الموقع مع geolocator package |

### 2.3 ملفات Widgets فارغة
| الملف | المحتوى المطلوب |
|-------|----------------|
| `custom_button.dart` | ويدجت زر مخصص قابل لإعادة الاستخدام |

---

## المرحلة 3: إصلاح معمارية

### 3.1 تطبيق go_router
- إنشاء `lib/core/router/app_router.dart`
- تعريف كل المسارات (welcome, login, register, camera, analysis, chat, history, profile)
- تحديث `main.dart` لاستخدام `MaterialApp.router`
- استبدال كل `Navigator.push` بـ `context.go()` أو `context.push()`

### 3.2 تحديث الاختبار
- تحديث `widget_test.dart` ليعكس التطبيق الفعلي

### 3.3 إنشاء مجلدات الأصول
- إنشاء `assets/images/` مع `.gitkeep`
- إنشاء `assets/icons/` مع `.gitkeep`

---

## المرحلة 4: تحسينات

### 4.1 تحسين `app_theme.dart`
- إضافة dark theme
- إكمال colorScheme
- إضافة المزيد من أنماط النصوص

### 4.2 تحسين `analysis_options.yaml`
- تفعيل قواعد lint أقوى
- تفعيل `avoid_print`, `prefer_single_quotes`

---

## ترتيب التنفيذ
1. ✅ المرحلة 1 (إصلاح التحليل الثابت) - عبر 10 وكلاء فرعيين بالتوازي
2. ✅ المرحلة 2 (ملء الملفات الفارغة) - عبر 9 وكلاء فرعيين بالتوازي
3. ✅ المرحلة 3 (المعمارية) - عبر وكلاء فرعيين
4. ✅ المرحلة 4 (التحسينات)
5. تشغيل `flutter analyze` للتحقق من 0 مشاكل
