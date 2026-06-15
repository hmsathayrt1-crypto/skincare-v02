# 📋 UserReport - SkinCare v02

## 🏗️ نظرة عامة
تطبيق موبايل (Skin Analysis AI) مخصص لتحليل صور البشرة باستخدام الذكاء الاصطناعي مع تقديم إرشادات طبية مبدئية استنادًا لحالة البشرة والعوامل البيئية (الطقس والموقع). يعتمد المشروع على Flutter بتصميم متطور (Glassmorphism) وتقنية Riverpod لإدارة الحالة و go_router للتنقل.

## 📝 سجل التغييرات
| التاريخ | التغيير | الملفات المتأثرة |
|---------|---------|------------------|
| 2026-06-15 | سحب آخر تعديل من GitHub وحل تعارض دمج (Merge Conflict) بنجاح في شاشة نتائج التحليل | `lib/features/skin_analysis/screens/analysis_result_screen.dart` |
| 2026-06-15 | رفع وتثبيت التعديلات البرمجية الأخيرة بنجاح على GitHub | جميع الملفات المعدلة و `.gitignore` |
| 2026-06-15 | تشغيل التطبيق ومراقبة السجلات للدقيقة الأولى على الهاتف الأندرويد `R5CYA0MKBGW` (لم يتم رصد أخطاء أو كراشات، فقط تحذيرات أداء Choreographer و Davey البسيطة) | - |
| 2026-06-15 | إنشاء ملف المساعدة `setup.bat` لتبسيط إعداد وتهيئة قاعدة البيانات تلقائياً دون الحاجة لخطوات يدوية في phpMyAdmin | `setup.bat` |
| 2026-06-15 | إضافة زر إعدادات الخادم العائم (Server Connection Floating Button) وتخزين سجل العناوين السابقة واختبار الاتصال بالخلفية | `lib/main.dart`, `lib/core/router/app_router.dart`, `lib/core/constants/api_endpoints.dart`, `lib/shared/server_config_floating_button.dart` |
| 2026-06-15 | استرجاع الثيم الفاتح (ThemeMode.light) لتجربة الألوان الفاتحة | `lib/main.dart` |
| 2026-06-15 | تفعيل السماح بحركة مرور البيانات غير المشفرة (Cleartext HTTP) في الأندرويد، وتصحيح التحقق من استجابة اختبار الاتصال بالخادم | `android/app/src/main/AndroidManifest.xml`, `lib/shared/server_config_floating_button.dart` |
| 2026-06-15 | تصحيح استيرادات الحزمة وبناء نسخة APK بنجاح | `lib/main.dart`, `lib/core/services/auth_service.dart`, `lib/core/services/chat_service.dart`, `lib/core/services/scan_service.dart` |
| 2026-05-03 | إنشاء ملفات التوثيق Agent.md و UserReport.md | `Agent.md`, `UserReport.md` |
| 2026-05-03 | إصلاح مشاكل الواجهات والربط عبر استخدام `go_router` بدلًا من `Navigator` | `welcome_screen.dart`, `login_screen.dart`, `register_screen.dart`, `camera_screen.dart`, `analysis_result_screen.dart` |

## 🐛 المشاكل والحلول
| المشكلة | الحالة | الحل |
|---------|--------|------|
| صعوبة اختبار التطبيق مع خوادم محلية مختلفة أو عناوين IP متغيرة | تم الحل | إضافة واجهة إعدادات عائمة ديناميكية تحفظ آخر عنوان وتتيح اختيار العناوين السابقة من قائمة تاريخ وتحديث عميل HTTP (Dio) فورياً |
| أخطاء في واجهات التطبيق وعدم عمل التنقل بشكل صحيح | تم الحل | استبدال `Navigator.push` و `Navigator.pop` بـ `context.push` و `context.go` و `context.pop` ليتوافق مع إعدادات `app_router.dart` |
| خطأ في تجميع التطبيق بسبب استيرادات حزمة باسم قديم `dermalyze` | تم الحل | استبدال جميع استيرادات `package:dermalyze/` بـ `package:skincare_v02/` في كامل ملفات المشروع |
| توقف الباك إند عن الاستجابة لطلبات إنشاء الحساب والمصادقة | تم الحل | 1. تشغيل خادم MySQL الخاص بـ XAMPP.<br>2. إنشاء قاعدة البيانات `skincare_db` واستيراد الجداول والبيانات الأولية عبر سكربت `migrate_fresh_seed.php`.<br>3. تشغيل خادم PHP المحلي على المنفذ 80 لخدمة ملفات الباك إند. |

## 💻 أخطاء التيرمينال
| الأمر | الخطأ | الحل |
|-------|-------|------|
| `flutter analyze` | `Undefined name '_serverIpPort'` | تم استبدال الاسم القديم بـ `serverIpPort` بعد حذف الـ getter والـ setter للتبسيط وتجنب تحذيرات التحليل |
| `flutter analyze` | `The function 'MyApp' isn't defined` | تغيير `MyApp()` إلى `DermalyzeApp()` في ملف `test/widget_test.dart` لتطابق إعادة التسمية في `main.dart` |
| `flutter build apk --release` | `Couldn't resolve the package 'dermalyze'` | استبدال الاستيرادات الخاطئة بالاسم الفعلي للحزمة `skincare_v02` |
| `test_db.php` | `SQLSTATE[HY000] [2002] connection refused` | تشغيل خادم MySQL (`mysqld.exe`) من مسار XAMPP. |
| `test_db.php` | `SQLSTATE[HY000] [1049] Unknown database 'skincare_db'` | تشغيل سكربت `migrate_fresh_seed.php` لإنشاء وهيكلة قاعدة البيانات. |

