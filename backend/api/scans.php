<?php
/**
 * GET    /api/scans.php              -> قائمة فحوصات المستخدم (مع pagination)
 * GET    /api/scans.php?id=12        -> تفاصيل فحص واحد
 * DELETE /api/scans.php              -> حذف فحص (soft delete)
 * (يتطلب توكن: Authorization: Bearer ***
 */
require_once __DIR__ . '/../helpers.php';
send_headers();

$user   = current_user();
$pdo    = db();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

// --- DELETE: حذف فحص (soft delete) ---
if ($method === 'DELETE') {
    $data = input();
    $scanId = isset($data['id']) ? (int)$data['id'] : (isset($_GET['id']) ? (int)$_GET['id'] : null);

    if (!$scanId) {
        fail('يجب تحديد معرّف الفحص.');
    }

    $stmt = $pdo->prepare('UPDATE scans SET is_deleted = 1 WHERE id = ? AND user_id = ?');
    $stmt->execute([$scanId, $user['id']]);

    if ($stmt->rowCount() === 0) {
        fail('الفحص غير موجود.', 404);
    }

    ok([], 'تم حذف الفحص بنجاح.');
}

// --- GET ---
if ($method !== 'GET') {
    fail('استخدم GET أو DELETE.', 405);
}

// فحص واحد
if (isset($_GET['id'])) {
    $stmt = $pdo->prepare('SELECT * FROM scans WHERE id = ? AND user_id = ? AND is_deleted = 0');
    $stmt->execute([(int)$_GET['id'], $user['id']]);
    $scan = $stmt->fetch();
    if (!$scan) {
        fail('الفحص غير موجود.', 404);
    }
    ok(['scan' => $scan]);
}

// قائمة الفحوصات مع pagination + فلاتر
$limit  = isset($_GET['limit'])  ? max(1, min(100, (int)$_GET['limit']))  : 20;
$offset = isset($_GET['offset']) ? max(0, (int)$_GET['offset'])           : 0;

$where  = 'WHERE user_id = ? AND is_deleted = 0';
$params = [$user['id']];

// فلترة بالحالة
if (isset($_GET['condition']) && $_GET['condition'] !== '') {
    $where .= ' AND cv_detected_condition LIKE ?';
    $params[] = '%' . $_GET['condition'] . '%';
}

// فلترة بالتاريخ
if (isset($_GET['from']) && $_GET['from'] !== '') {
    $where .= ' AND scan_date >= ?';
    $params[] = $_GET['from'] . ' 00:00:00';
}
if (isset($_GET['to']) && $_GET['to'] !== '') {
    $where .= ' AND scan_date <= ?';
    $params[] = $_GET['to'] . ' 23:59:59';
}

// عدد النتائج الكلي
$countStmt = $pdo->prepare("SELECT COUNT(*) AS c FROM scans {$where}");
$countStmt->execute($params);
$total = (int)($countStmt->fetch()['c'] ?? 0);

// جلب النتائج
$stmt = $pdo->prepare("SELECT * FROM scans {$where} ORDER BY scan_date DESC LIMIT ? OFFSET ?");
$params[] = $limit;
$params[] = $offset;
$stmt->execute($params);

ok([
    'scans'  => $stmt->fetchAll(),
    'total'  => $total,
    'limit'  => $limit,
    'offset' => $offset,
]);
