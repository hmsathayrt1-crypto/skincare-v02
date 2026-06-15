<?php
/**
 * GET  /api/chat.php            -> جلب سجل المحادثات (limit, offset)
 * POST /api/chat.php            -> إرسال رسالة والحصول على رد Gemini
 * (يتطلب توكن: Authorization: Bearer ***
 */
require_once __DIR__ . '/../helpers.php';
send_headers();

$user = current_user();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $limit  = isset($_GET['limit'])  ? (int)$_GET['limit']  : 50;
    $offset = isset($_GET['offset']) ? (int)$_GET['offset'] : 0;

    $stmt = db()->prepare(
        'SELECT id, role, message, image_path, created_at FROM chat_messages WHERE user_id = ? ORDER BY created_at ASC LIMIT ? OFFSET ?'
    );
    $stmt->execute([$user['id'], $limit, $offset]);
    $messages = $stmt->fetchAll();

    ok(['messages' => $messages]);

} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data    = input();
    $message = trim($data['message'] ?? '');
    $scanId  = isset($data['scan_id']) ? (int)$data['scan_id'] : null;

    if ($message === '') {
        fail('يجب كتابة رسالة.');
    }

    // حفظ رسالة المستخدم
    $stmt = db()->prepare(
        'INSERT INTO chat_messages (user_id, scan_id, role, message) VALUES (?, ?, "user", ?)'
    );
    $stmt->execute([$user['id'], $scanId, $message]);

    // بناء سياق المحادثة
    $context = buildChatContext($user, $scanId);

    // إرسال لـ Gemini
    $reply = chatWithGemini($message, $context, $user['skin_type']);

    // حفظ رد المساعد
    $stmt = db()->prepare(
        'INSERT INTO chat_messages (user_id, scan_id, role, message) VALUES (?, ?, "assistant", ?)'
    );
    $stmt->execute([$user['id'], $scanId, $reply]);
    $replyId = (int)db()->lastInsertId();

    ok([
        'reply' => [
            'id'         => $replyId,
            'role'       => 'assistant',
            'message'    => $reply,
            'created_at' => date('Y-m-d H:i:s'),
        ],
    ]);

} else {
    fail('استخدم GET أو POST.', 405);
}
