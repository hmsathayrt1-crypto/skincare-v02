<?php
/**
 * GET  /api/profile.php   -> بيانات المستخدم الحالي + عدد فحوصاته
 * POST /api/profile.php   -> تحديث الملف الشخصي
 * (يتطلب توكن: Authorization: Bearer ***
 */
require_once __DIR__ . '/../helpers.php';
send_headers();

$user   = current_user();
$pdo    = db();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    $stmt = $pdo->prepare('SELECT COUNT(*) AS c FROM scans WHERE user_id = ? AND is_deleted = 0');
    $stmt->execute([$user['id']]);
    $scansCount = (int)($stmt->fetch()['c'] ?? 0);

    ok([
        'user' => [
            'id'             => (int)$user['id'],
            'full_name'      => $user['full_name'],
            'email'          => $user['email'],
            'phone'          => $user['phone'] ?? null,
            'skin_type'      => $user['skin_type'],
            'avatar_path'    => $user['avatar_path'] ?? null,
            'date_of_birth'  => $user['date_of_birth'] ?? null,
            'gender'         => $user['gender'] ?? null,
            'created_at'     => $user['created_at'],
            'scans_count'    => $scansCount,
        ],
    ]);
}

if ($method === 'POST') {
    $in       = input();
    $fullName = array_key_exists('full_name', $in) ? trim($in['full_name']) : $user['full_name'];
    $skinType = array_key_exists('skin_type', $in) ? (trim($in['skin_type']) ?: null) : $user['skin_type'];
    $phone    = array_key_exists('phone', $in) ? (trim($in['phone']) ?: null) : ($user['phone'] ?? null);
    $gender   = array_key_exists('gender', $in) ? (trim($in['gender']) ?: null) : ($user['gender'] ?? null);
    $dob      = array_key_exists('date_of_birth', $in) ? (trim($in['date_of_birth']) ?: null) : ($user['date_of_birth'] ?? null);

    if ($fullName === '') {
        fail('الاسم لا يمكن أن يكون فارغاً.');
    }

    // التحقق من skin_type
    $allowedSkinTypes = ['oily', 'dry', 'combination', 'sensitive', 'normal'];
    if ($skinType !== null && !in_array($skinType, $allowedSkinTypes)) {
        fail('نوع البشرة غير صالح.');
    }

    // التحقق من gender
    if ($gender !== null && !in_array($gender, ['male', 'female', 'other'])) {
        fail('الجنس غير صالح.');
    }

    $stmt = $pdo->prepare('UPDATE users SET full_name = ?, skin_type = ?, phone = ?, gender = ?, date_of_birth = ? WHERE id = ?');
    $stmt->execute([$fullName, $skinType, $phone, $gender, $dob, $user['id']]);

    ok([
        'user' => [
            'id'            => (int)$user['id'],
            'full_name'     => $fullName,
            'email'         => $user['email'],
            'phone'         => $phone,
            'skin_type'     => $skinType,
            'gender'        => $gender,
            'date_of_birth' => $dob,
        ],
    ], 'تم تحديث الملف الشخصي.');
}

fail('طريقة غير مدعومة.', 405);
