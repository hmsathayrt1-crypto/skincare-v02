<?php
/**
 * ============================================================
 *  قالب الإعدادات (Example) — انسخه إلى config.php وعبّئ مفاتيحك.
 *      cp config.example.php config.php
 *  ملف config.php الحقيقي مُستثنى من Git (يحتوي أسراراً) فلا تنشره.
 * ============================================================
 */

// --- 1) إعدادات قاعدة البيانات (XAMPP / phpMyAdmin الافتراضية) ---
define('DB_HOST', '127.0.0.1');
define('DB_PORT', '3306');
define('DB_NAME', 'skincare_db');
define('DB_USER', 'root');
define('DB_PASS', '');                // كلمة سر XAMPP الافتراضية فارغة

// --- 2) إعدادات نموذج الذكاء الاصطناعي (بوابة متوافقة مع OpenAI) ---
// ضع مفتاحك هنا (يبدأ بـ sk-...). لا تشاركه ولا ترفعه إلى Git.
define('GEMINI_API_KEY', 'PUT_YOUR_AI_GATEWAY_KEY_HERE');

// اسم النموذج (متوفر عبر البوابة):
//   gemini-3.5-flash    => الأذكى، يدعم الرؤية (موصى به للتحليل)
//   gemini-2.5-flash    => أفضل سعر/أداء لزمن استجابة منخفض (مستخدم لنصيحة اليوم)
define('GEMINI_MODEL', 'gemini-3.5-flash');

// نقطة النهاية المتوافقة مع OpenAI (chat completions)
define('GEMINI_ENDPOINT', 'https://api.abdalgani.com/v1/chat/completions');

// (اختياري) تجاوز إعدادات نموذج "نصيحة اليوم" — وإلا تُستخدم الافتراضيات في helpers.php
// define('DAILY_TIP_MODEL', 'gemini-2.5-flash');
// define('DAILY_TIP_REASONING', 'none');
// define('DAILY_TIP_MAX_TOKENS', 300);

// --- 3) إعدادات الطقس (OpenWeatherMap) — اختياري ---
// نصيحة اليوم تستخدم Open-Meteo المجاني بدون مفتاح، فهذا اختياري فقط.
define('OPENWEATHER_API_KEY', '');

// --- 4) إعدادات عامة ---
define('UPLOAD_DIR', __DIR__ . '/uploads/');
define('UPLOAD_URL', '/backend/uploads/');
define('TOKEN_BYTES', 48);

date_default_timezone_set('Asia/Amman');
mb_internal_encoding('UTF-8');
