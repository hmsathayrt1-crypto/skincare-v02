<?php
/**
 * GET /api/daily_advice.php?lat=..&lon=..   -> نصيحة اليوم المخصصة بالذكاء الاصطناعي
 * (يتطلب توكن: Authorization: Bearer ***)
 *
 * المنطق:
 *  - نصيحة واحدة فقط لكل مستخدم في اليوم (قيد UNIQUE user_id+advice_date).
 *  - أول طلب في اليوم: يجلب الطقس + الارتفاع + المدينة (Open-Meteo/BigDataCloud)
 *    ثم يستدعي النموذج ويخزّن النتيجة.
 *  - بقية اليوم: يعيد النسخة المخزّنة مباشرة (بلا استدعاء AI = بلا تكلفة).
 */
require_once __DIR__ . '/../helpers.php';
send_headers();

$user = current_user();
$pdo  = db();

$lat = isset($_GET['lat']) && $_GET['lat'] !== '' ? (float)$_GET['lat'] : null;
$lon = isset($_GET['lon']) && $_GET['lon'] !== '' ? (float)$_GET['lon'] : null;

$today = date('Y-m-d');

/* ---------- 1) هل توجد نصيحة لليوم؟ أعِدها (Cache hit) ---------- */
$stmt = $pdo->prepare(
    'SELECT * FROM daily_advice WHERE user_id = ? AND advice_date = ? LIMIT 1'
);
$stmt->execute([$user['id'], $today]);
$row = $stmt->fetch();

if ($row) {
    respond_advice($row, true);
}

/* ---------- 2) لا توجد: اجمع المعطيات وولّد نصيحة جديدة ---------- */
$skinType = $user['skin_type'] ?? null;

$weather   = fetch_weather_openmeteo($lat, $lon);
$elevation = fetch_elevation($lat, $lon);
$city      = reverse_city($lat, $lon);

// نص الطقس للنموذج
if ($weather['temperature'] !== null) {
    $weatherCtx = sprintf(
        '%s، %s°م، رطوبة %s%%',
        $weather['description'] ?? '—',
        $weather['temperature'],
        $weather['humidity'] !== null ? $weather['humidity'] : '—'
    );
} else {
    $weatherCtx = 'غير متوفر';
}

$locationCtx = describe_location($city, $elevation);

$adviceText = generate_daily_advice($skinType, $weatherCtx, $locationCtx);

/* ---------- 3) خزّن (مع حماية من السباق عبر INSERT IGNORE) ---------- */
$ins = $pdo->prepare(
    'INSERT IGNORE INTO daily_advice
       (user_id, advice_date, advice_text, skin_type, temperature, humidity,
        weather_description, city_name, latitude, longitude, elevation)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
);
$ins->execute([
    $user['id'], $today, $adviceText, $skinType,
    $weather['temperature'], $weather['humidity'], $weather['description'],
    $city, $lat, $lon, $elevation,
]);

// أعد قراءة الصف (سواء أُدرج الآن أو سبق إدراجه في طلب متزامن)
$stmt = $pdo->prepare(
    'SELECT * FROM daily_advice WHERE user_id = ? AND advice_date = ? LIMIT 1'
);
$stmt->execute([$user['id'], $today]);
$row = $stmt->fetch();

respond_advice($row ?: [
    'advice_date'         => $today,
    'advice_text'         => $adviceText,
    'temperature'         => $weather['temperature'],
    'humidity'            => $weather['humidity'],
    'weather_description' => $weather['description'],
    'city_name'           => $city,
    'elevation'           => $elevation,
], false);

/* ---------- مُنسّق الاستجابة ---------- */
function respond_advice(array $row, bool $cached): void
{
    ok([
        'cached' => $cached,
        'advice' => [
            'advice_date' => $row['advice_date'] ?? date('Y-m-d'),
            'advice_text' => $row['advice_text'] ?? '',
            'weather'     => [
                'temperature' => isset($row['temperature']) ? (float)$row['temperature'] : null,
                'humidity'    => isset($row['humidity']) ? (float)$row['humidity'] : null,
                'description' => $row['weather_description'] ?? null,
            ],
            'location'    => [
                'city_name' => $row['city_name'] ?? null,
                'elevation' => isset($row['elevation']) ? (float)$row['elevation'] : null,
            ],
        ],
    ]);
}
