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

// --- 2) إعدادات نموذج الذكاء الاصطناعي (Google AI Studio - Gemini) ---
// ضع هنا المفتاح الذي ستحصل عليه من https://aistudio.google.com/apikey
define('GEMINI_API_KEY', 'PUT_YOUR_AI_STUDIO_API_KEY_HERE');

// اسم النموذج (محدّث حسب توثيق Google — يونيو 2026):
//   gemini-3.5-flash    => مستقر GA، الأذكى (موصى به للإنتاج)
//   gemini-flash-latest => يشير دائماً لأحدث إصدار flash (يتحدث تلقائياً)
//   gemini-2.5-flash    => أفضل سعر/أداء لزمن استجابة منخفض
// ملاحظة: gemini-2.0-flash تم إيقافه في 2026-06-01.
define('GEMINI_MODEL', 'gemini-3.5-flash');

// نقطة النهاية الرسمية (لا تحتاج لتغييرها عادة)
define('GEMINI_ENDPOINT', 'https://generativelanguage.googleapis.com/v1beta/models/');

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
