<?php
/**
 * POST /api/analyze.php   (يتطلب توكن: Authorization: Bearer ***
 * يستقبل صورة البشرة + إحداثيات GPS،
 * يجلب الطقس، يحلل بـ Gemini، يحفظ الفحص، ويعيد النتيجة.
 *
 * المدخلات (multipart/form-data):
 *   - image     : ملف الصورة (مطلوب)
 *   - latitude  : خط العرض (اختياري)
 *   - longitude : خط الطول (اختياري)
 */
require_once __DIR__ . '/../helpers.php';
send_headers();

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    fail('استخدم POST.', 405);
}

$user = current_user();

// --- 1) التحقق من الصورة ---
if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    fail('يجب إرفاق صورة صالحة في الحقل image.');
}

$file     = $_FILES['image'];
$mime     = mime_content_type($file['tmp_name']);
$allowed  = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
if (!isset($allowed[$mime])) {
    fail('صيغة الصورة غير مدعومة. المسموح: JPG, PNG, WEBP.');
}
if ($file['size'] > 8 * 1024 * 1024) {
    fail('حجم الصورة كبير جداً (الحد الأقصى 8MB).');
}

// --- 2) حفظ الصورة ---
if (!is_dir(UPLOAD_DIR)) {
    mkdir(UPLOAD_DIR, 0775, true);
}
$fileName = 'scan_' . $user['id'] . '_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $allowed[$mime];
$destPath = UPLOAD_DIR . $fileName;
if (!move_uploaded_file($file['tmp_name'], $destPath)) {
    fail('تعذّر حفظ الصورة على السيرفر.', 500);
}
$publicPath = UPLOAD_URL . $fileName;

// --- 3) الموقع والطقس ---
$lat = isset($_POST['latitude'])  && $_POST['latitude']  !== '' ? (float)$_POST['latitude']  : null;
$lon = isset($_POST['longitude']) && $_POST['longitude'] !== '' ? (float)$_POST['longitude'] : null;
$weather = fetch_weather($lat, $lon);

// جلب اسم المدينة من بيانات الطقس
$cityName = null;
if ($lat !== null && $lon !== null && OPENWEATHER_API_KEY !== '') {
    $cityUrl = 'https://api.openweathermap.org/data/2.5/weather?'
        . http_build_query(['lat' => $lat, 'lon' => $lon, 'appid' => OPENWEATHER_API_KEY]);
    $cityRes = http_get($cityUrl);
    if ($cityRes !== null) {
        $cityData = json_decode($cityRes, true);
        $cityName = $cityData['name'] ?? null;
    }
}

// --- 4) تحليل الذكاء الاصطناعي ---
$ai = analyze_with_gemini($destPath, $mime, $weather, $user['skin_type']);

// --- 5) حفظ الفحص في قاعدة البيانات ---
$stmt = db()->prepare(
    'INSERT INTO scans
     (user_id, image_path, latitude, longitude, temperature, humidity, uv_index,
      weather_description, city_name, cv_detected_condition, cv_confidence_score, nlp_consultation_text)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
);
$stmt->execute([
    $user['id'], $publicPath, $lat, $lon,
    $weather['temperature'], $weather['humidity'], $weather['uv_index'], $weather['description'],
    $cityName,
    $ai['condition'], $ai['confidence'], $ai['consultation'],
]);
$scanId = (int)db()->lastInsertId();

// --- 6) الرد ---
ok([
    'scan' => [
        'id'           => $scanId,
        'image_path'   => $publicPath,
        'scan_date'    => date('Y-m-d H:i:s'),
        'weather'      => $weather,
        'city_name'    => $cityName,
        'condition'    => $ai['condition'],
        'confidence'   => $ai['confidence'],
        'consultation' => $ai['consultation'],
    ],
], 'تم تحليل البشرة بنجاح.');
