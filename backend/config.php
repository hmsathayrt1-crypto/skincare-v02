<?php
/**
 * ============================================================
 *  ملف الإعدادات الرئيسي (Configuration)
 *  هنا تضع كل المفاتيح والإعدادات. لا تعدّل باقي الملفات.
 * ============================================================
 */

// --- 1) إعدادات قاعدة البيانات (XAMPP / phpMyAdmin الافتراضية) ---
define('DB_HOST', '127.0.0.1');
define('DB_PORT', '3306');
define('DB_NAME', 'skincare_db');     // اسم القاعدة (أنشئها من phpMyAdmin أو استورد schema.sql)
define('DB_USER', 'root');            // مستخدم XAMPP الافتراضي
define('DB_PASS', '');                // كلمة سر XAMPP الافتراضية فارغة

// --- 2) إعدادات نموذج الذكاء الاصطناعي (بوابة متوافقة مع OpenAI) ---
// يستخدم المشروع بوابة abdalgani المتوافقة مع OpenAI (تدعم نماذج Gemini والرؤية).
// المفتاح يبدأ بـ sk-... ويُرسل في ترويسة Authorization: Bearer
define('GEMINI_API_KEY', 'sk-YFk0-Clu5gvAlRlkAfoXCw');

// اسم النموذج (متوفر عبر البوابة — يونيو 2026):
//   gemini-3.5-flash    => الأذكى، يدعم الرؤية (موصى به للإنتاج)
//   gemini-flash-latest => أحدث إصدار flash
//   gemini-2.5-flash    => أفضل سعر/أداء لزمن استجابة منخفض
define('GEMINI_MODEL', 'gemini-3.5-flash');

// نقطة النهاية المتوافقة مع OpenAI (chat completions)
define('GEMINI_ENDPOINT', 'https://api.abdalgani.com/v1/chat/completions');

// --- 3) إعدادات الطقس (OpenWeatherMap) — اختياري ---
// احصل على مفتاح مجاني من https://openweathermap.org/api
// إن تركته فارغاً، سيتخطى النظام جلب الطقس ويكمل التحليل عادي.
define('OPENWEATHER_API_KEY', '');

// --- 4) إعدادات عامة ---
define('UPLOAD_DIR', __DIR__ . '/uploads/');   // مكان حفظ الصور على السيرفر
define('UPLOAD_URL', '/backend/uploads/'); // المسار العام للوصول للصور عبر المتصفح (الباك إند منشور تحت /backend/)
define('TOKEN_BYTES', 48);                      // طول توكن الجلسة

// المنطقة الزمنية والترميز
date_default_timezone_set('Asia/Amman');
mb_internal_encoding('UTF-8');
