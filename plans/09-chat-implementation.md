# 09 - تفعيل المحادثة الذكية (AI Chat)

## الوضع الحالي

- الشاشة موجودة بتصميم جميل
- الرسائل وهمية (hardcoded) — 4 رسائل ثابتة
- لا يمكن إرسال رسالة حقيقية
- لا يوجد endpoint في الباك إند للمحادثة

---

## الخطوات المطلوبة

### الباك إند: إنشاء `backend/api/chat.php`

```php
<?php
require_once __DIR__ . '/../helpers.php';
send_headers();

$user = current_user();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // جلب سجل المحادثات
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 50;
    $offset = isset($_GET['offset']) ? (int)$_GET['offset'] : 0;
    
    $stmt = db()->prepare(
        'SELECT * FROM chat_messages WHERE user_id = ? ORDER BY created_at ASC LIMIT ? OFFSET ?'
    );
    $stmt->execute([$user['id'], $limit, $offset]);
    $messages = $stmt->fetchAll();
    
    ok(['messages' => $messages]);
    
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // إرسال رسالة والحصول على رد
    $data = input();
    $message = trim($data['message'] ?? '');
    $scanId = isset($data['scan_id']) ? (int)$data['scan_id'] : null;
    
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
            'id' => $replyId,
            'role' => 'assistant',
            'message' => $reply,
            'created_at' => date('Y-m-d H:i:s'),
        ],
    ]);
    
} else {
    fail('استخدم GET أو POST.', 405);
}
```

### دوال مساعدة إضافية في `helpers.php`

```php
function buildChatContext(array $user, ?int $scanId): string {
    $ctx = "المستخدم: {$user['full_name']}. ";
    
    if ($user['skin_type']) {
        $ctx .= "نوع البشرة: {$user['skin_type']}. ";
    }
    
    // إضافة سياق آخر فحص إن وُجد
    if ($scanId) {
        $stmt = db()->prepare('SELECT * FROM scans WHERE id = ? AND user_id = ?');
        $stmt->execute([$scanId, $user['id']]);
        $scan = $stmt->fetch();
        if ($scan) {
            $ctx .= "آخر تشخيص: {$scan['cv_detected_condition']} (ثقة {$scan['cv_confidence_score']}). ";
            if ($scan['temperature']) {
                $ctx .= "الطقس: {$scan['temperature']}°م، رطوبة {$scan['humidity']}%. ";
            }
        }
    } else {
        // جلب آخر فحص تلقائياً
        $stmt = db()->prepare(
            'SELECT * FROM scans WHERE user_id = ? ORDER BY scan_date DESC LIMIT 1'
        );
        $stmt->execute([$user['id']]);
        $scan = $stmt->fetch();
        if ($scan) {
            $ctx .= "آخر تشخيص: {$scan['cv_detected_condition']}. ";
        }
    }
    
    // جلب آخر 5 رسائل للسياق
    $stmt = db()->prepare(
        'SELECT role, message FROM chat_messages WHERE user_id = ? ORDER BY id DESC LIMIT 5'
    );
    $stmt->execute([$user['id']]);
    $history = array_reverse($stmt->fetchAll());
    
    if (!empty($history)) {
        $ctx .= "\nسجل المحادثة الأخيرة:\n";
        foreach ($history as $msg) {
            $role = $msg['role'] === 'user' ? 'المستخدم' : 'المساعد';
            $ctx .= "{$role}: {$msg['message']}\n";
        }
    }
    
    return $ctx;
}

function chatWithGemini(string $userMessage, string $context, ?string $skinType): string {
    if (GEMINI_API_KEY === '' || GEMINI_API_KEY === 'PUT_YOUR_AI_STUDIO_API_KEY_HERE') {
        return 'عذراً، خدمة المحادثة غير متاحة حالياً. يرجى المحاولة لاحقاً.';
    }
    
    $prompt = <<<TXT
أنت مساعد ذكي متخصص في العناية بالبشرة (للأغراض التعليمية).
أجب بأسلوب ودود وبسيط بالعربية. أعطِ نصائح عملية مختصرة.
لا تشخّص أمراضاً — وجّه للطبيب عند الحاجة.

{$context}

رسالة المستخدم الحالية: {$userMessage}
TXT;

    $payload = [
        'contents' => [[
            'parts' => [['text' => $prompt]],
        ]],
        'generationConfig' => [
            'temperature' => 0.7,
            'maxOutputTokens' => 500,
        ],
    ];

    $url = GEMINI_ENDPOINT . GEMINI_MODEL . ':generateContent?key=' . GEMINI_API_KEY;
    $res = http_post_json($url, $payload);
    
    if ($res === null) {
        return 'عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.';
    }
    
    $body = json_decode($res, true);
    return $body['candidates'][0]['content']['parts'][0]['text'] ?? 'تعذّر الحصول على رد.';
}
```

---

### الفرونت: إنشاء ChatService

**الملف الجديد:** `lib/core/services/chat_service.dart`

```dart
class ChatService {
  final _client = DioClient();
  
  Future<List<ChatMessageModel>> getHistory({int limit = 50}) async {
    final response = await _client.get(
      ApiEndpoints.chatHistory,
      queryParameters: {'limit': limit},
    );
    final messages = response.data['messages'] as List;
    return messages.map((m) => ChatMessageModel.fromJson(m)).toList();
  }
  
  Future<ChatMessageModel> sendMessage(String text, {int? scanId}) async {
    final response = await _client.post(
      ApiEndpoints.chatMessage,
      data: {
        'message': text,
        if (scanId != null) 'scan_id': scanId,
      },
    );
    return ChatMessageModel.fromJson(response.data['reply']);
  }
}
```

### الفرونت: تحويل ChatScreen

التحويلات المطلوبة:
1. `StatelessWidget` → `ConsumerStatefulWidget`
2. إضافة `TextEditingController` للإدخال
3. إزالة الرسائل الوهمية
4. جلب المحادثات من API عند فتح الشاشة
5. إرسال الرسائل عبر ChatService
6. إضافة scrollController للتمرير التلقائي لآخر رسالة
7. إضافة مؤشر "يكتب..." أثناء انتظار رد Gemini

---

## تدفق المحادثة

```
المستخدم يفتح شاشة المحادثة
  ↓
ChatProvider.loadHistory() → GET /api/chat.php
  ↓
عرض الرسائل السابقة (أو رسالة ترحيب افتراضية)
  ↓
المستخدم يكتب رسالة ويضغط إرسال
  ↓
1. إضافة رسالة المستخدم للقائمة (محلياً)
2. عرض مؤشر "يكتب..."
3. POST /api/chat.php → Gemini يرد
4. إضافة رد المساعد للقائمة
5. التمرير لآخر رسالة
```

---

## ميزات إضافية (اختيارية)

- **ربط "استشارة خبير"** في شاشة النتائج بالمحادثة (تمرير scan_id)
- **رسالة ترحيب تلقائية** عند أول فتح للمحادثة
- **عرض سياق الفحص** في رأس المحادثة إن كانت مرتبطة بفحص
