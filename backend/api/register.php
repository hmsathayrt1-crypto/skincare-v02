<?php
/**
 * POST /api/register.php
 * المدخلات: full_name, email, password, phone (اختياري), skin_type (اختياري)
 * المخرجات: بيانات المستخدم + توكن جلسة
 */
require_once __DIR__ . '/../helpers.php';
send_headers();

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    fail('استخدم POST.', 405);
}

$in        = input();
$fullName  = trim($in['full_name'] ?? '');
$email     = trim(strtolower($in['email'] ?? ''));
$password  = (string)($in['password'] ?? '');
$phone     = trim($in['phone'] ?? '') ?: null;
$skinType  = trim($in['skin_type'] ?? '') ?: null;

if ($fullName === '' || $email === '' || $password === '') {
    fail('الاسم والبريد وكلمة المرور حقول مطلوبة.');
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    fail('صيغة البريد الإلكتروني غير صحيحة.');
}
if (strlen($password) < 6) {
    fail('كلمة المرور يجب أن تكون 6 أحرف على الأقل.');
}

// التحقق من صيغة الهاتف (اختياري)
if ($phone !== null && !preg_match('/^\+?[0-9\s\-]{7,20}$/', $phone)) {
    fail('صيغة رقم الهاتف غير صحيحة.');
}

// التحقق من skin_type
$allowedSkinTypes = ['oily', 'dry', 'combination', 'sensitive', 'normal'];
if ($skinType !== null && !in_array($skinType, $allowedSkinTypes)) {
    fail('نوع البشرة غير صالح. المسموح: oily, dry, combination, sensitive, normal.');
}

$pdo = db();

// تحقق من عدم تكرار البريد
$stmt = $pdo->prepare('SELECT id FROM users WHERE email = ?');
$stmt->execute([$email]);
if ($stmt->fetch()) {
    fail('هذا البريد مسجّل مسبقاً.', 409);
}

$hash = password_hash($password, PASSWORD_DEFAULT);
$stmt = $pdo->prepare(
    'INSERT INTO users (full_name, email, phone, password_hash, skin_type) VALUES (?, ?, ?, ?, ?)'
);
$stmt->execute([$fullName, $email, $phone, $hash, $skinType]);
$userId = (int)$pdo->lastInsertId();

// إنشاء توكن جلسة (ينتهي بعد 30 يوم)
$token = make_token();
$expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
$pdo->prepare('INSERT INTO api_tokens (user_id, token, expires_at) VALUES (?, ?, ?)')
    ->execute([$userId, $token, $expiresAt]);

ok([
    'token' => $token,
    'user'  => [
        'id'        => $userId,
        'full_name' => $fullName,
        'email'     => $email,
        'phone'     => $phone,
        'skin_type' => $skinType,
    ],
], 'تم إنشاء الحساب بنجاح.');
