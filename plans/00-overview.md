# خطة الإصلاح الشاملة - مشروع Dermalyze AI

## ملخص الحالة الحالية

| الجزء | النسبة المكتملة | ملاحظات |
|-------|-----------------|---------|
| واجهات الفرونت (UI) | ~90% | تصميم ممتاز، glassmorphic، RTL |
| ربط الفرونت بالباك | ~0% | لا يوجد أي اتصال حقيقي |
| الباك إند (PHP) | ~75% | الـ API جاهز لكن بحاجة لتحسينات |
| قاعدة البيانات | ~60% | بسيطة جداً، بحاجة لتوسيع |
| إدارة الحالة (State) | ~0% | Riverpod مُستورد لكن غير مُستخدم |

---

## ترتيب ملفات الخطط

| # | الملف | الموضوع | الأولوية |
|---|-------|---------|----------|
| 01 | `01-database-upgrade.md` | تحسين وتوسيع قاعدة البيانات | عالية |
| 02 | `02-api-endpoints-fix.md` | إصلاح وتطوير الـ API endpoints | عالية |
| 03 | `03-frontend-api-integration.md` | تحديث عناوين API في Flutter لتتوافق مع PHP | عالية |
| 04 | `04-auth-flow.md` | ربط تسجيل الدخول والتسجيل فعلياً | عالية |
| 05 | `05-camera-upload-flow.md` | ربط الكاميرا برفع الصورة والتحليل | عالية |
| 06 | `06-state-management.md` | تفعيل Riverpod لإدارة الحالة | متوسطة |
| 07 | `07-navigation-fixes.md` | إصلاح الانتقال بين الواجهات | عالية |
| 08 | `08-screens-fixes.md` | إصلاح كل شاشة (أزرار معطلة، بيانات ثابتة) | عالية |
| 09 | `09-chat-implementation.md` | تفعيل المحادثة الذكية | متوسطة |
| 10 | `10-testing-plan.md` | خطة اختبار شاملة (Postman + التطبيق) | عالية |

---

## المشكلة الأساسية

الباك إند PHP يعمل على `localhost/backend/api/login.php` بينما Flutter يتوقع FastAPI على `localhost:8000/api/v1/auth/login`. يجب توحيد العناوين.

## بيئة التشغيل

- **Backend:** XAMPP → `http://localhost/backend/`
- **Database:** MySQL (skincare_db) عبر phpMyAdmin
- **Frontend:** Flutter (Android/iOS)
- **AI:** Google Gemini 3.5 Flash
- **Weather:** OpenWeatherMap (اختياري)
