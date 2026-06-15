<?php
/**
 * POST /api/logout.php   (يتطلب توكن: Authorization: Bearer <token>)
 * يحذف توكن الجلسة الحالي فيُسجَّل خروج المستخدم من هذا الجهاز.
 */
require_once __DIR__ . '/../helpers.php';
send_headers();

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    fail('استخدم POST.', 405);
}

// استخراج التوكن من الترويسة
$headers = function_exists('getallheaders') ? getallheaders() : [];
$auth = $headers['Authorization'] ?? $headers['authorization'] ?? ($_SERVER['HTTP_AUTHORIZATION'] ?? '');
if (!preg_match('/Bearer\s+(\S+)/', $auth, $m)) {
    fail('غير مصرّح: التوكن مفقود.', 401);
}

$stmt = db()->prepare('DELETE FROM api_tokens WHERE token = ?');
$stmt->execute([$m[1]]);

ok([], 'تم تسجيل الخروج بنجاح.');
