<?php
/**
 * ============================================================
 *  ترحيل آمن (لا يحذف بيانات): إضافة جدول daily_advice فقط
 *  لقواعد البيانات الموجودة مسبقاً.
 *
 *  التشغيل مرة واحدة: http://localhost/backend/database/migrate_daily_advice.php
 * ============================================================
 */

require_once __DIR__ . '/../config.php';

header('Content-Type: text/html; charset=utf-8');
echo "<div dir='rtl' style='font-family:Tahoma,sans-serif; max-width:800px; margin:40px auto; padding:20px;'>";
echo "<h1>🗄️ ترحيل: إضافة جدول نصيحة اليوم (daily_advice)</h1><hr>";

try {
    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_PORT, DB_NAME);
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `daily_advice` (
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

    $count = $pdo->query("SELECT COUNT(*) FROM `daily_advice`")->fetchColumn();
    echo "<div style='background:#d4edda; padding:16px; border-radius:8px; border:1px solid #28a745;'>";
    echo "<strong>✅ تم إنشاء/التأكد من جدول daily_advice بنجاح.</strong><br>";
    echo "عدد السجلات الحالية: {$count}";
    echo "</div>";

} catch (PDOException $e) {
    echo "<div style='background:#f8d7da; padding:16px; border-radius:8px; border:1px solid #dc3545; color:#721c24;'>";
    echo "<strong>❌ خطأ:</strong> " . htmlspecialchars($e->getMessage());
    echo "</div>";
}

echo "</div>";
