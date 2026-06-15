<?php
/**
 * GET /api/dashboard.php  -> لوحة معلومات سريعة
 * (يتطلب توكن: Authorization: Bearer ***
 */
require_once __DIR__ . '/../helpers.php';
send_headers();

$user = current_user();
$pdo  = db();

// إجمالي الفحوصات
$stmt = $pdo->prepare('SELECT COUNT(*) AS c FROM scans WHERE user_id = ? AND is_deleted = 0');
$stmt->execute([$user['id']]);
$totalScans = (int)($stmt->fetch()['c'] ?? 0);

// آخر فحص
$stmt = $pdo->prepare('SELECT cv_detected_condition, scan_date FROM scans WHERE user_id = ? AND is_deleted = 0 ORDER BY scan_date DESC LIMIT 1');
$stmt->execute([$user['id']]);
$lastScan = $stmt->fetch();

// نصيحة عشوائية
$skinType = $user['skin_type'] ?? null;
if ($skinType) {
    $stmt = $pdo->prepare('SELECT tip_text FROM skin_tips WHERE is_active = 1 AND (skin_type = ? OR skin_type IS NULL) ORDER BY RAND() LIMIT 1');
    $stmt->execute([$skinType]);
} else {
    $stmt = $pdo->prepare('SELECT tip_text FROM skin_tips WHERE is_active = 1 ORDER BY RAND() LIMIT 1');
    $stmt->execute();
}
$tip = $stmt->fetch();

ok([
    'dashboard' => [
        'total_scans'     => $totalScans,
        'last_scan_date'  => $lastScan['scan_date'] ?? null,
        'last_condition'  => $lastScan['cv_detected_condition'] ?? null,
        'skin_type'       => $skinType,
        'tip_of_the_day'  => $tip['tip_text'] ?? null,
    ],
]);
