# 🧠 Agent.md - SkinCare v02

## 📊 نظرة عامة
- **نوع المشروع:** تطبيق موبايل (Mobile App)
- **اللغة:** Dart
- **الإطار:** Flutter
- **الإصدار:** SDK >=3.2.3 <4.0.0
- **نقطة الدخول:** `lib/main.dart`

## 🌲 المخطط الشجري للمشروع
```text
012/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── network/
│   │   ├── router/          # AppRouter using go_router
│   │   ├── theme/           # AppTheme, Colors, Texts
│   │   └── utils/
│   ├── features/
│   │   ├── ai_chat/
│   │   ├── auth/
│   │   ├── history/
│   │   ├── onboarding/
│   │   ├── profile/
│   │   └── skin_analysis/
│   ├── shared/
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

## 🛠️ أوامر التشغيل
| الأمر | الوظيفة |
|-------|---------|
| `flutter run` | تشغيل التطبيق في بيئة التطوير |
| `flutter analyze` | فحص الكود بحثًا عن أخطاء |
| `flutter test` | تشغيل الاختبارات |

## 📦 التبعيات الرئيسية
| المكتبة | الوظيفة |
|---------|---------|
| `flutter_riverpod` | إدارة الحالة |
| `go_router` | التوجيه والتنقل |
| `dio` | الاتصال بالـ API |
| `camera` | التقاط صور البشرة |
| `geolocator` | تحديد الموقع لتأثير العوامل البيئية |

## ✅ أفضل الممارسات المكتشفة
- استخدام `go_router` للتنقل بدلاً من `Navigator.push`.
- استخدام `withValues` للألوان بدلاً من `withOpacity` الذي أصبح مهملًا.
- تنظيم الشاشات بحسب الميزات (Feature-first architecture).
- استخدام أنماط Glassmorphism للتصميم.

## ⚠️ المشاكل المعروفة والحلول
| المشكلة | السبب | الحل | التاريخ |
|---------|-------|------|---------|
| كثرة أخطاء الواجهات والربط بينها | استخدام `Navigator` الافتراضي مع وجود إعدادات `go_router` | استبدال جميع استدعاءات `Navigator` بدوال `go_router` مثل `context.push` و `context.go` | 2026-05-03 |

## 🚫 أنماط يجب تجنبها
- استخدام `Navigator.push` في المشاريع التي تم إعداد `go_router` لها.
- استخدام `withOpacity` مع الألوان.

## 🔗 ملاحظات البيئة
- التطبيق يدعم اللغة العربية (RTL) بشكل أساسي.
- تصميم الواجهة يركز على الـ Glassmorphism والتأثيرات اللونية (Pink & Green Glow).

## 🧹 صيانة الذاكرة (Memory Hygiene)
### آخر تنظيف: 2026-05-03
