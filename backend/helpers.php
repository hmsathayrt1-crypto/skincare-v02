<?php
/**
 * دوال مساعدة مشتركة: استجابة JSON، قراءة المدخلات، المصادقة، استدعاء Gemini والطقس.
 */
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/db.php';

/* ---------- CORS + ترويسات أساسية ---------- */
function send_headers(): void
{
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');           // للسماح لتطبيق Flutter (ويب) بالاتصال
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    // الرد على طلب preflight مباشرة
    if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
}

/* ---------- استجابة JSON موحّدة ---------- */
function respond($data, int $code = 200): void
{
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function ok($data = [], string $message = 'تم بنجاح'): void
{
    respond(array_merge(['success' => true, 'message' => $message], $data), 200);
}

function fail(string $message, int $code = 400, $extra = []): void
{
    respond(array_merge(['success' => false, 'message' => $message], (array)$extra), $code);
}

/* ---------- قراءة جسم الطلب (JSON أو form) ---------- */
function input(): array
{
    $raw = file_get_contents('php://input');
    if ($raw) {
        $json = json_decode($raw, true);
        if (is_array($json)) {
            return $json;
        }
    }
    return $_POST;
}

/* ---------- المصادقة عبر توكن Bearer ---------- */
function current_user(): array
{
    $headers = function_exists('getallheaders') ? getallheaders() : [];
    $auth = $headers['Authorization'] ?? $headers['authorization'] ?? ($_SERVER['HTTP_AUTHORIZATION'] ?? '');
    if (!preg_match('/Bearer\s+(\S+)/', $auth, $m)) {
        fail('غير مصرّح: التوكن مفقود.', 401);
    }
    $token = $m[1];

    $stmt = db()->prepare(
        'SELECT u.* FROM api_tokens t JOIN users u ON u.id = t.user_id WHERE t.token = ?'
    );
    $stmt->execute([$token]);
    $user = $stmt->fetch();
    if (!$user) {
        fail('غير مصرّح: توكن غير صالح.', 401);
    }
    return $user;
}

function make_token(): string
{
    return bin2hex(random_bytes(TOKEN_BYTES));
}

/* =====================================================================
 *  جلب حالة الطقس من OpenWeatherMap (اختياري)
 *  يرجع: [temperature, humidity, uv_index, description] أو قيم null
 * ===================================================================== */
function fetch_weather(?float $lat, ?float $lon): array
{
    $out = ['temperature' => null, 'humidity' => null, 'uv_index' => null, 'description' => null];
    if ($lat === null || $lon === null || OPENWEATHER_API_KEY === '') {
        return $out;
    }

    $url = 'https://api.openweathermap.org/data/2.5/weather?'
        . http_build_query([
            'lat'   => $lat,
            'lon'   => $lon,
            'units' => 'metric',
            'lang'  => 'ar',
            'appid' => OPENWEATHER_API_KEY,
        ]);

    $res = http_get($url);
    if ($res === null) {
        return $out;
    }
    $data = json_decode($res, true);
    if (!is_array($data) || !isset($data['main'])) {
        return $out;
    }

    $out['temperature'] = $data['main']['temp'] ?? null;
    $out['humidity']    = $data['main']['humidity'] ?? null;
    $out['description'] = $data['weather'][0]['description'] ?? null;
    // مؤشر UV يتطلب One Call API (قد يكون مدفوعاً) — نتركه null هنا.
    return $out;
}

/* =====================================================================
 *  استدعاء النموذج لتحليل صورة البشرة + توليد الاستشارة (مهمة واحدة)
 *  عبر بوابة متوافقة مع OpenAI (chat completions + رؤية).
 *  يرجع مصفوفة: [condition, confidence, consultation]
 * ===================================================================== */
function analyze_with_gemini(string $imagePath, string $mimeType, array $weather, ?string $skinType): array
{
    if (!ai_key_configured()) {
        fail('مفتاح الذكاء الاصطناعي غير مُعدّ. ضع المفتاح في config.php', 500);
    }

    $imageData = base64_encode(file_get_contents($imagePath));
    $dataUri   = "data:{$mimeType};base64,{$imageData}";

    // سياق الطقس لإدخاله في الـ prompt
    $weatherCtx = 'غير متوفرة';
    if ($weather['temperature'] !== null) {
        $weatherCtx = sprintf(
            'درجة الحرارة %s°م، الرطوبة %s%%، الحالة: %s',
            $weather['temperature'],
            $weather['humidity'] ?? '—',
            $weather['description'] ?? '—'
        );
    }
    $skinCtx = $skinType ? "نوع بشرة المستخدم: {$skinType}." : 'نوع البشرة غير محدد.';

    $prompt = <<<TXT
أنت مساعد طبي متخصص في الأمراض الجلدية (للأغراض التعليمية وليس بديلاً عن طبيب).
حلّل صورة البشرة المرفقة، وآخذاً بعين الاعتبار بيانات الطقس التالية: {$weatherCtx}. {$skinCtx}
أعطِ النتيجة بصيغة JSON فقط (كائن واحد بدون أي نص إضافي) بالحقول التالية:
- condition: اسم الحالة/المرض المحتمل (مثل: حب الشباب، إكزيما، بشرة طبيعية...).
- confidence: رقم بين 0 و 1 يمثل درجة الثقة.
- consultation: نص استشارة عربية مفصّلة (تشمل وصف الحالة، تأثير الطقس الحالي على البشرة، ونصائح للعناية والروتين المناسب). اختم بتنبيه لمراجعة طبيب مختص.
TXT;

    $payload = [
        'model'    => GEMINI_MODEL,
        'messages' => [[
            'role'    => 'user',
            'content' => [
                ['type' => 'text',      'text'      => $prompt],
                ['type' => 'image_url', 'image_url' => ['url' => $dataUri]],
            ],
        ]],
        'temperature'     => 0.4,
        'response_format' => ['type' => 'json_object'],
    ];

    $res = http_post_json(GEMINI_ENDPOINT, $payload, ai_auth_headers());
    if ($res === null) {
        fail('فشل الاتصال بنموذج الذكاء الاصطناعي.', 502);
    }

    $body = json_decode($res, true);
    if (isset($body['error'])) {
        fail('خطأ من النموذج: ' . ($body['error']['message'] ?? 'غير معروف'), 502);
    }

    $text   = $body['choices'][0]['message']['content'] ?? '';
    $parsed = extract_json($text);

    if (!is_array($parsed)) {
        // خطة بديلة: أعد النص كاستشارة خام إن لم يأتِ JSON سليم
        return ['condition' => 'غير محدد', 'confidence' => null, 'consultation' => $text ?: 'تعذّر التحليل.'];
    }

    return [
        'condition'    => $parsed['condition']    ?? 'غير محدد',
        'confidence'   => isset($parsed['confidence']) ? (float)$parsed['confidence'] : null,
        'consultation' => $parsed['consultation'] ?? '',
    ];
}

/* =====================================================================
 *  بناء سياق المحادثة للذكاء الاصطناعي
 * ===================================================================== */
function buildChatContext(array $user, ?int $scanId): string
{
    $ctx = "المستخدم: {$user['full_name']}. ";

    if (!empty($user['skin_type'])) {
        $ctx .= "نوع البشرة: {$user['skin_type']}. ";
    }

    // إضافة سياق آخر فحص إن وُجد
    if ($scanId) {
        $stmt = db()->prepare('SELECT * FROM scans WHERE id = ? AND user_id = ? AND is_deleted = 0');
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
            'SELECT * FROM scans WHERE user_id = ? AND is_deleted = 0 ORDER BY scan_date DESC LIMIT 1'
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

/* =====================================================================
 *  إرسال رسالة لـ Gemini والحصول على رد
 * ===================================================================== */
function chatWithGemini(string $userMessage, string $context, ?string $skinType): string
{
    if (!ai_key_configured()) {
        return 'عذراً، خدمة المحادثة غير متاحة حالياً. يرجى المحاولة لاحقاً.';
    }

    $skinCtx = $skinType ? "نوع بشرة المستخدم: {$skinType}." : '';

    $systemPrompt = <<<TXT
أنت مساعد ذكي متخصص في العناية بالبشرة (للأغراض التعليمية).
أجب بأسلوب ودود وبسيط بالعربية. أعطِ نصائح عملية مختصرة.
لا تشخّص أمراضاً — وجّه للطبيب عند الحاجة. {$skinCtx}

سياق المستخدم:
{$context}
TXT;

    $payload = [
        'model'    => GEMINI_MODEL,
        'messages' => [
            ['role' => 'system', 'content' => $systemPrompt],
            ['role' => 'user',   'content' => $userMessage],
        ],
        'temperature' => 0.7,
        // gemini-3.5-flash نموذج تفكير: يلزم سقف مرتفع ليتسع للتفكير + الجواب
        // (max_tokens المنخفض يُستهلك بالكامل في التفكير ويعيد رداً فارغاً).
        'max_tokens'  => 2048,
    ];

    $res = http_post_json(GEMINI_ENDPOINT, $payload, ai_auth_headers());
    if ($res === null) {
        return 'عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.';
    }

    $body = json_decode($res, true);
    if (isset($body['error'])) {
        return 'عذراً، تعذّر الحصول على رد: ' . ($body['error']['message'] ?? 'خطأ غير معروف');
    }

    return $body['choices'][0]['message']['content'] ?? 'تعذّر الحصول على رد.';
}

/* =====================================================================
 *  أدوات الذكاء الاصطناعي المشتركة (بوابة متوافقة مع OpenAI)
 * ===================================================================== */
function ai_key_configured(): bool
{
    return GEMINI_API_KEY !== ''
        && GEMINI_API_KEY !== 'PUT_YOUR_AI_STUDIO_API_KEY_HERE'
        && stripos(GEMINI_API_KEY, 'PUT_YOUR') === false;
}

function ai_auth_headers(): array
{
    return [
        'Content-Type: application/json',
        'Authorization: Bearer ' . GEMINI_API_KEY,
    ];
}

/**
 * يستخرج كائن JSON من نص الرد بشكل متسامح:
 * يدعم النص النقي، أو المُحاط بأسوار ```json، أو المغروس داخل نص.
 */
function extract_json(string $text)
{
    $text = trim($text);
    if ($text === '') {
        return null;
    }

    // محاولة مباشرة
    $parsed = json_decode($text, true);
    if (is_array($parsed)) {
        return $parsed;
    }

    // إزالة أسوار ```json ... ```
    if (preg_match('/```(?:json)?\s*(.+?)\s*```/is', $text, $m)) {
        $parsed = json_decode(trim($m[1]), true);
        if (is_array($parsed)) {
            return $parsed;
        }
    }

    // التقاط أول كائن JSON ضمن النص
    if (preg_match('/\{.*\}/s', $text, $m)) {
        $parsed = json_decode($m[0], true);
        if (is_array($parsed)) {
            return $parsed;
        }
    }

    return null;
}

/* ---------- أدوات HTTP عبر cURL ---------- */
function http_get(string $url): ?string
{
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT        => 20,
        CURLOPT_SSL_VERIFYPEER => false, // مناسب لبيئة XAMPP المحلية
    ]);
    $res = curl_exec($ch);
    curl_close($ch);
    return $res === false ? null : $res;
}

function http_post_json(string $url, array $payload, array $headers = ['Content-Type: application/json']): ?string
{
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST           => true,
        // ترميز الوحدات (Unicode) كـ \uXXXX لتفادي أي تشويش عبر البوابة
        CURLOPT_POSTFIELDS     => json_encode($payload),
        CURLOPT_HTTPHEADER     => $headers,
        CURLOPT_TIMEOUT        => 60,
        CURLOPT_SSL_VERIFYPEER => false,
    ]);
    $res = curl_exec($ch);
    curl_close($ch);
    return $res === false ? null : $res;
}
