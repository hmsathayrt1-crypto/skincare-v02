<?php
/**
 * GET /api/tips.php              -> جلب نصائح يومية
 * ?skin_type=oily  (اختياري)
 * (يتطلب توكن: Authorization: Bearer ***
 */
require_once __DIR__ . '/../helpers.php';
send_headers();

$user = current_user();
$pdo  = db();

$skinType = isset($_GET['skin_type']) ? trim($_GET['skin_type']) : ($user['skin_type'] ?? null);

if ($skinType) {
    // نصائح حسب نوع البشرة + نصائح عامة
    $stmt = $pdo->prepare(
        'SELECT id, skin_type, season, tip_text FROM skin_tips WHERE is_active = 1 AND (skin_type = ? OR skin_type IS NULL) ORDER BY RAND() LIMIT 5'
    );
    $stmt->execute([$skinType]);
} else {
    $stmt = $pdo->prepare(
        'SELECT id, skin_type, season, tip_text FROM skin_tips WHERE is_active = 1 ORDER BY RAND() LIMIT 5'
    );
    $stmt->execute();
}

ok(['tips' => $stmt->fetchAll()]);
