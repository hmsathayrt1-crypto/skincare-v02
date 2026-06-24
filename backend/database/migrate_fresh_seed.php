<?php
/**
 * ============================================================
 *  إعادة بناء قاعدة البيانات + بيانات أولية (Seed)
 *  يعمل مثل: php artisan migrate:fresh --seed
 *
 *  التشغيل: http://localhost/backend/database/migrate_fresh_seed.php
 *  تحذير: يحذف كل البيانات الموجودة!
 * ============================================================
 */

require_once __DIR__ . '/../config.php';

header('Content-Type: text/html; charset=utf-8');

echo "<div dir='rtl' style='font-family:Tahoma,sans-serif; max-width:800px; margin:40px auto; padding:20px;'>";
echo "<h1>🗄️ إعادة بناء قاعدة البيانات — Dermalyze AI</h1>";
echo "<hr>";

try {
    // --- الاتصال (بدون اسم قاعدة لأننا قد نحذفها) ---
    $dsn = sprintf('mysql:host=%s;port=%s;charset=utf8mb4', DB_HOST, DB_PORT);
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    // ==============================
    //  1) حذف القاعدة إن وُجدت
    // ==============================
    step("حذف القاعدة القديمة (إن وُجدت)...");
    $pdo->exec("DROP DATABASE IF EXISTS `" . DB_NAME . "`");
    done();

    // ==============================
    //  2) إنشاء القاعدة من جديد
    // ==============================
    step("إنشاء القاعدة: " . DB_NAME . "...");
    $pdo->exec("CREATE DATABASE `" . DB_NAME . "` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    $pdo->exec("USE `" . DB_NAME . "`");
    done();

    // ==============================
    //  3) إنشاء الجداول
    // ==============================

    // --- users ---
    step("إنشاء جدول users...");
    $pdo->exec("
        CREATE TABLE `users` (
            `id`            INT AUTO_INCREMENT PRIMARY KEY,
            `full_name`     VARCHAR(150)  NOT NULL,
            `email`         VARCHAR(190)  NOT NULL UNIQUE,
            `phone`         VARCHAR(20)   NULL,
            `password_hash` VARCHAR(255)  NOT NULL,
            `skin_type`     VARCHAR(50)   NULL,
            `avatar_path`   VARCHAR(255)  NULL,
            `date_of_birth` DATE          NULL,
            `gender`        ENUM('male','female','other') NULL,
            `created_at`    DATETIME      DEFAULT CURRENT_TIMESTAMP,
            `updated_at`    DATETIME      NULL ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    done();

    // --- api_tokens ---
    step("إنشاء جدول api_tokens...");
    $pdo->exec("
        CREATE TABLE `api_tokens` (
            `id`          INT AUTO_INCREMENT PRIMARY KEY,
            `user_id`     INT          NOT NULL,
            `token`       VARCHAR(160) NOT NULL UNIQUE,
            `device_name` VARCHAR(100) NULL,
            `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP,
            `expires_at`  DATETIME     NULL,
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    done();

    // --- scans ---
    step("إنشاء جدول scans...");
    $pdo->exec("
        CREATE TABLE `scans` (
            `id`                    INT AUTO_INCREMENT PRIMARY KEY,
            `user_id`               INT          NOT NULL,
            `image_path`            VARCHAR(255) NOT NULL,
            `scan_date`             DATETIME     DEFAULT CURRENT_TIMESTAMP,
            `latitude`              DOUBLE       NULL,
            `longitude`             DOUBLE       NULL,
            `temperature`           DOUBLE       NULL,
            `humidity`              DOUBLE       NULL,
            `uv_index`              DOUBLE       NULL,
            `weather_description`   VARCHAR(190) NULL,
            `city_name`             VARCHAR(100) NULL,
            `cv_detected_condition` VARCHAR(190) NULL,
            `cv_confidence_score`   DOUBLE       NULL,
            `nlp_consultation_text` TEXT         NULL,
            `notes`                 TEXT         NULL,
            `is_deleted`            TINYINT(1)   DEFAULT 0,
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
            INDEX `idx_user`     (`user_id`),
            INDEX `idx_date`     (`scan_date`),
            INDEX `idx_condition`(`cv_detected_condition`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    done();

    // --- chat_messages ---
    step("إنشاء جدول chat_messages...");
    $pdo->exec("
        CREATE TABLE `chat_messages` (
            `id`         INT AUTO_INCREMENT PRIMARY KEY,
            `user_id`    INT  NOT NULL,
            `scan_id`    INT  NULL,
            `role`       ENUM('user','assistant') NOT NULL,
            `message`    TEXT NOT NULL,
            `image_path` VARCHAR(255) NULL,
            `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
            FOREIGN KEY (`scan_id`) REFERENCES `scans`(`id`) ON DELETE SET NULL,
            INDEX `idx_chat_user` (`user_id`),
            INDEX `idx_chat_scan` (`scan_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    done();

    // --- skin_tips ---
    step("إنشاء جدول skin_tips...");
    $pdo->exec("
        CREATE TABLE `skin_tips` (
            `id`         INT AUTO_INCREMENT PRIMARY KEY,
            `skin_type`  VARCHAR(50) NULL,
            `season`     ENUM('summer','winter','spring','autumn') NULL,
            `tip_text`   TEXT NOT NULL,
            `is_active`  TINYINT(1) DEFAULT 1,
            `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    done();

    // --- user_routines ---
    step("إنشاء جدول user_routines...");
    $pdo->exec("
        CREATE TABLE `user_routines` (
            `id`            INT AUTO_INCREMENT PRIMARY KEY,
            `user_id`       INT          NOT NULL,
            `routine_type`  ENUM('morning','evening') NOT NULL,
            `step_order`    INT          NOT NULL,
            `step_name`     VARCHAR(150) NOT NULL,
            `product_name`  VARCHAR(200) NULL,
            `is_completed`  TINYINT(1)   DEFAULT 0,
            `created_at`    DATETIME     DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
            INDEX `idx_routine_user` (`user_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    done();

    // --- daily_advice (نصيحة اليوم المولّدة بالذكاء الاصطناعي) ---
    step("إنشاء جدول daily_advice...");
    $pdo->exec("
        CREATE TABLE `daily_advice` (
            `id`                  INT  AUTO_INCREMENT PRIMARY KEY,
            `user_id`             INT  NOT NULL,
            `advice_date`         DATE NOT NULL,
            `advice_text`         TEXT NOT NULL,
            `skin_type`           VARCHAR(50)  NULL,
            `temperature`         DOUBLE       NULL,
            `humidity`            DOUBLE       NULL,
            `weather_description` VARCHAR(190) NULL,
            `city_name`           VARCHAR(100) NULL,
            `latitude`            DOUBLE       NULL,
            `longitude`           DOUBLE       NULL,
            `elevation`           DOUBLE       NULL,
            `created_at`          DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY `uniq_user_day` (`user_id`, `advice_date`),
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    done();

    // ==============================
    //  4) بيانات أولية (Seed Data)
    // ==============================
    echo "<h2>📦 إدخال البيانات الأولية...</h2>";

    // --- مستخدمون تجريبيون ---
    step("إضافة مستخدمين تجريبيين...");
    $users = [
        ['سارة أحمد',    'sara@example.com',    '+962791000001', 'oily',        'female', '1998-03-15'],
        ['أحمد محمد',    'ahmed@example.com',   '+962791000002', 'dry',         'male',   '1995-07-22'],
        ['لين خالد',     'leen@example.com',    '+962791000003', 'combination', 'female', '2000-11-08'],
        ['عمر يوسف',    'omar@example.com',    '+962791000004', 'sensitive',   'male',   '1997-01-30'],
        ['نور الدين',   'nour@example.com',    '+962791000005', 'normal',      'male',   '1999-05-12'],
    ];

    $passwordHash = password_hash('123456', PASSWORD_DEFAULT);

    $stmt = $pdo->prepare("
        INSERT INTO users (full_name, email, phone, password_hash, skin_type, gender, date_of_birth)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ");
    foreach ($users as $u) {
        $stmt->execute([$u[0], $u[1], $u[2], $passwordHash, $u[3], $u[4], $u[5]]);
    }
    done("تم إضافة " . count($users) . " مستخدمين (كلمة المرور: 123456)");

    // --- توكن تجريبي للمستخدم الأول ---
    step("إنشاء توكن تجريبي للمستخدم سارة...");
    $testToken = bin2hex(random_bytes(48));
    $pdo->prepare("INSERT INTO api_tokens (user_id, token, device_name) VALUES (1, ?, 'Test Device')")
        ->execute([$testToken]);
    done("التوكن: <code style='background:#eee;padding:4px 8px;font-size:11px;word-break:break-all;'>{$testToken}</code>");

    // --- فحوصات تجريبية ---
    step("إضافة فحوصات تجريبية...");
    $scans = [
        [1, '/backend/uploads/sample_scan_1.jpg', 31.95, 35.93, 32.5, 55, 7.2, 'مشمس جزئياً', 'عمّان', 'حب الشباب',        0.87, 'بناءً على تحليل الصورة، تظهر علامات حب شباب خفيف. ننصح بغسل الوجه مرتين يومياً بمنظف لطيف واستخدام واقي شمس. الطقس الحار والرطوبة العالية قد تزيد من إفرازات البشرة الدهنية.'],
        [1, '/backend/uploads/sample_scan_2.jpg', 31.95, 35.93, 28.0, 40, 5.0, 'غائم',         'عمّان', 'بشرة طبيعية',       0.92, 'البشرة تبدو بحالة جيدة. ننصح بالاستمرار في الروتين الحالي مع الحرص على الترطيب اليومي.'],
        [2, '/backend/uploads/sample_scan_3.jpg', 32.06, 36.09, 35.0, 30, 9.0, 'مشمس',         'إربد',  'جفاف البشرة',       0.78, 'تظهر علامات جفاف واضحة. ننصح بزيادة شرب الماء واستخدام مرطب طبي. تجنب التعرض المباشر للشمس.'],
        [3, '/backend/uploads/sample_scan_4.jpg', 31.77, 35.23, 30.0, 65, 6.0, 'غائم جزئياً',  'عمّان', 'التهاب جلد تماسي',  0.71, 'يُحتمل وجود التهاب جلد تماسي خفيف. ننصح بالتوقف عن استخدام المنتجات التجميلية مؤقتاً واستخدام مرطب خالي من العطور. يُفضل مراجعة طبيب جلدية.'],
        [1, '/backend/uploads/sample_scan_5.jpg', 31.95, 35.93, 25.0, 50, 4.0, 'غائم',         'عمّان', 'حب شباب خفيف',      0.83, 'تحسن ملحوظ عن الفحص السابق. الاستمرار في الروتين الحالي مع إضافة سيروم فيتامين سي صباحاً.'],
    ];

    $stmt = $pdo->prepare("
        INSERT INTO scans (user_id, image_path, latitude, longitude, temperature, humidity, uv_index,
                          weather_description, city_name, cv_detected_condition, cv_confidence_score, nlp_consultation_text, scan_date)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $dates = ['2026-05-15 09:30:00', '2026-05-28 14:20:00', '2026-06-01 10:00:00', '2026-06-05 16:45:00', '2026-06-09 11:15:00'];
    foreach ($scans as $i => $s) {
        $stmt->execute(array_merge($s, [$dates[$i]]));
    }
    done("تم إضافة " . count($scans) . " فحوصات تجريبية");

    // --- رسائل محادثة تجريبية ---
    step("إضافة رسائل محادثة تجريبية...");
    $messages = [
        [1, null, 'assistant', 'مرحباً سارة! أنا مساعدك الذكي للعناية بالبشرة. بناءً على تحليلك الأخير، يبدو أن بشرتك تميل إلى الدهنية. كيف تشعرين بها اليوم؟'],
        [1, null, 'user',      'أشعر ببعض الشد في منطقة الخدين بعد الاستيقاظ.'],
        [1, null, 'assistant', 'هذا طبيعي في مثل هذا الطقس الحار. أنصحك بزيادة الترطيب في روتينك الصباحي. استخدمي مرطب خفيف خالي من الزيوت (Oil-free) قبل واقي الشمس. هل تستخدمين واقي شمس يومياً؟'],
        [1, null, 'user',      'نعم، لكن أحياناً أنساه.'],
        [1, null, 'assistant', 'واقي الشمس أهم خطوة في أي روتين! خاصة مع مؤشر UV العالي في عمّان هذه الأيام. أنصحك بواقي شمس SPF 50 خفيف القوام. ضعيه كل صباح حتى في الأيام الغائمة.'],
    ];

    $stmt = $pdo->prepare("INSERT INTO chat_messages (user_id, scan_id, role, message) VALUES (?, ?, ?, ?)");
    foreach ($messages as $m) {
        $stmt->execute($m);
    }
    done("تم إضافة " . count($messages) . " رسالة محادثة");

    // --- نصائح يومية ---
    step("إضافة نصائح يومية...");
    $tips = [
        ['oily',        'summer', 'اغسلي وجهك مرتين يومياً بغسول خالي من الزيوت لتقليل اللمعان.'],
        ['oily',        'summer', 'استخدمي واقي شمس خفيف (Gel) بدلاً من الكريمات الثقيلة.'],
        ['oily',        'winter', 'لا تتخلي عن الترطيب حتى لو كانت بشرتك دهنية — الجفاف يزيد إفراز الزيوت.'],
        ['dry',         'summer', 'اشربي 8 أكواب ماء على الأقل يومياً للحفاظ على ترطيب البشرة من الداخل.'],
        ['dry',         'winter', 'استخدمي مرطب غني بالسيراميد قبل النوم لمنع فقدان الرطوبة أثناء الليل.'],
        ['dry',         'summer', 'تجنبي الاستحمام بالماء الساخن — استخدمي ماء فاتر للحفاظ على زيوت البشرة الطبيعية.'],
        ['sensitive',   'summer', 'تجنبي المنتجات التي تحتوي على عطور أو كحول — استخدمي منتجات Hypoallergenic.'],
        ['sensitive',   'winter', 'رطبي بشرتك فوراً بعد الغسل بينما لا تزال رطبة لتثبيت الرطوبة.'],
        ['combination', 'summer', 'استخدمي مرطب خفيف على منطقة T-zone ومرطب أغنى على الخدين.'],
        ['combination', 'winter', 'قشّري بشرتك مرة واحدة أسبوعياً بمقشر لطيف لتوحيد ملمسها.'],
        ['normal',      'summer', 'حافظي على روتينك البسيط: غسول لطيف + مرطب + واقي شمس.'],
        ['normal',      'winter', 'أضيفي سيروم فيتامين C لروتينك الصباحي لحماية البشرة وتفتيحها.'],
        [null,          null,     'اشربي كمية كافية من الماء يومياً — الترطيب الداخلي ينعكس على بشرتك.'],
        [null,          null,     'نامي 7-8 ساعات يومياً — قلة النوم تؤثر سلباً على صحة البشرة.'],
        [null,          null,     'غيّري غطاء الوسادة مرة أسبوعياً على الأقل لتجنب تراكم البكتيريا.'],
    ];

    $stmt = $pdo->prepare("INSERT INTO skin_tips (skin_type, season, tip_text) VALUES (?, ?, ?)");
    foreach ($tips as $t) {
        $stmt->execute($t);
    }
    done("تم إضافة " . count($tips) . " نصيحة");

    // --- روتين تجريبي للمستخدم الأول ---
    step("إضافة روتين عناية تجريبي لسارة...");
    $routines = [
        [1, 'morning', 1, 'غسول الوجه',     'CeraVe Foaming Cleanser'],
        [1, 'morning', 2, 'تونر',           'Thayers Witch Hazel'],
        [1, 'morning', 3, 'سيروم فيتامين C', 'The Ordinary Vitamin C'],
        [1, 'morning', 4, 'مرطب',           'Neutrogena Hydro Boost'],
        [1, 'morning', 5, 'واقي شمس',       'La Roche-Posay SPF 50'],
        [1, 'evening', 1, 'مزيل المكياج',   'Bioderma Micellar Water'],
        [1, 'evening', 2, 'غسول الوجه',     'CeraVe Foaming Cleanser'],
        [1, 'evening', 3, 'سيروم ريتينول',  'The Ordinary Retinol 0.5%'],
        [1, 'evening', 4, 'كريم ليلي',      'CeraVe PM Moisturizer'],
    ];

    $stmt = $pdo->prepare("INSERT INTO user_routines (user_id, routine_type, step_order, step_name, product_name) VALUES (?, ?, ?, ?, ?)");
    foreach ($routines as $r) {
        $stmt->execute($r);
    }
    done("تم إضافة " . count($routines) . " خطوة روتين");

    // ==============================
    //  5) ملخص
    // ==============================
    echo "<hr>";
    echo "<h2 style='color:green;'>✅ تم إعادة بناء القاعدة بنجاح!</h2>";
    echo "<table border='1' cellpadding='8' cellspacing='0' style='border-collapse:collapse; width:100%;'>";
    echo "<tr style='background:#f0f0f0;'><th>الجدول</th><th>عدد السجلات</th></tr>";

    $tables = ['users', 'api_tokens', 'scans', 'chat_messages', 'skin_tips', 'daily_advice', 'user_routines'];
    foreach ($tables as $t) {
        $count = $pdo->query("SELECT COUNT(*) FROM `{$t}`")->fetchColumn();
        echo "<tr><td>{$t}</td><td>{$count}</td></tr>";
    }
    echo "</table>";

    echo "<br><div style='background:#fff3cd; padding:16px; border-radius:8px; border:1px solid #ffc107;'>";
    echo "<strong>⚠️ بيانات الدخول التجريبية:</strong><br>";
    echo "البريد: <code>sara@example.com</code> — كلمة المرور: <code>123456</code><br>";
    echo "البريد: <code>ahmed@example.com</code> — كلمة المرور: <code>123456</code><br>";
    echo "البريد: <code>leen@example.com</code> — كلمة المرور: <code>123456</code><br>";
    echo "<br>التوكن التجريبي (للاختبار في Postman):<br>";
    echo "<code style='font-size:11px; word-break:break-all;'>{$testToken}</code>";
    echo "</div>";

    echo "<br><div style='background:#d4edda; padding:16px; border-radius:8px; border:1px solid #28a745;'>";
    echo "<strong>الخطوة التالية:</strong><br>";
    echo "1. ضع مفتاح Gemini في <code>config.php</code><br>";
    echo "2. اختبر الـ API: <a href='/backend/'>http://localhost/backend/</a><br>";
    echo "3. اختبر التسجيل والدخول عبر Postman";
    echo "</div>";

} catch (PDOException $e) {
    echo "<div style='background:#f8d7da; padding:16px; border-radius:8px; border:1px solid #dc3545; color:#721c24;'>";
    echo "<strong>❌ خطأ:</strong> " . htmlspecialchars($e->getMessage());
    echo "</div>";
}

echo "</div>";

// --- دوال مساعدة للعرض ---
function step(string $text): void {
    echo "<p>⏳ {$text} ";
}

function done(string $extra = ''): void {
    echo "<span style='color:green;'>✅</span>";
    if ($extra) echo " <small>({$extra})</small>";
    echo "</p>";
}
