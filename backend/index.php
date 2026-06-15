<?php
/**
 * صفحة معلومات الـ API (للتأكد أن السيرفر يعمل).
 * افتح: http://localhost/backend/
 */
require_once __DIR__ . '/helpers.php';
send_headers();

ok([
    'api'       => 'Dermalyze AI Backend',
    'version'   => '1.1.0',
    'model'     => GEMINI_MODEL,
    'endpoints' => [
        'POST /api/register.php'   => 'إنشاء حساب (full_name, email, password, phone?, skin_type?)',
        'POST /api/login.php'      => 'تسجيل الدخول (email, password)',
        'POST /api/logout.php'     => 'تسجيل الخروج — يتطلب توكن',
        'GET  /api/profile.php'    => 'بيانات المستخدم — يتطلب توكن',
        'POST /api/profile.php'    => 'تحديث الملف (full_name, skin_type, phone, gender, date_of_birth) — يتطلب توكن',
        'POST /api/analyze.php'    => 'تحليل صورة بشرة (image, latitude?, longitude?) — يتطلب توكن',
        'GET  /api/scans.php'      => 'سجل الفحوصات (limit, offset, condition, from, to) — يتطلب توكن',
        'GET  /api/scans.php?id='  => 'تفاصيل فحص واحد — يتطلب توكن',
        'DELETE /api/scans.php'    => 'حذف فحص (soft delete) — يتطلب توكن',
        'GET  /api/chat.php'       => 'سجل المحادثات (limit, offset) — يتطلب توكن',
        'POST /api/chat.php'       => 'إرسال رسالة للمحادثة الذكية (message, scan_id?) — يتطلب توكن',
        'GET  /api/tips.php'       => 'نصائح يومية (skin_type?) — يتطلب توكن',
        'GET  /api/dashboard.php'  => 'لوحة معلومات سريعة — يتطلب توكن',
    ],
], 'الـ API يعمل ✅');
