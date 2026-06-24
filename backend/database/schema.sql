-- ============================================================
--  قاعدة بيانات تطبيق Dermalyze AI / DermAI
--  للاستيراد: افتح phpMyAdmin > استيراد > اختر هذا الملف
--  (ينشئ القاعدة والجداول تلقائياً — بدون بيانات تجريبية)
--
--  ملاحظة: لإنشاء القاعدة مع بيانات تجريبية (Seed)، شغّل بدلاً من ذلك:
--    http://localhost/backend/database/migrate_fresh_seed.php
--  هذا الملف يجب أن يبقى مطابقاً للجداول المُعرّفة في ذلك السكربت.
-- ============================================================

CREATE DATABASE IF NOT EXISTS `skincare_db`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `skincare_db`;

-- 1) جدول المستخدمين
CREATE TABLE IF NOT EXISTS `users` (
  `id`            INT AUTO_INCREMENT PRIMARY KEY,
  `full_name`     VARCHAR(150) NOT NULL,
  `email`         VARCHAR(190) NOT NULL UNIQUE,
  `phone`         VARCHAR(20)  NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `skin_type`     VARCHAR(50)  NULL,
  `avatar_path`   VARCHAR(255) NULL,
  `date_of_birth` DATE         NULL,
  `gender`        ENUM('male','female','other') NULL,
  `created_at`    DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2) جدول توكنات الجلسات (للمصادقة)
CREATE TABLE IF NOT EXISTS `api_tokens` (
  `id`          INT AUTO_INCREMENT PRIMARY KEY,
  `user_id`     INT NOT NULL,
  `token`       VARCHAR(160) NOT NULL UNIQUE,
  `device_name` VARCHAR(100) NULL,
  `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP,
  `expires_at`  DATETIME NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3) جدول الفحوصات (يربط المستخدم بالصورة والطقس ونتيجة الذكاء الاصطناعي)
CREATE TABLE IF NOT EXISTS `scans` (
  `id`                    INT AUTO_INCREMENT PRIMARY KEY,
  `user_id`               INT NOT NULL,
  `image_path`            VARCHAR(255) NOT NULL,
  `scan_date`             DATETIME DEFAULT CURRENT_TIMESTAMP,
  -- بيانات الموقع والطقس
  `latitude`              DOUBLE NULL,
  `longitude`             DOUBLE NULL,
  `temperature`           DOUBLE NULL,
  `humidity`              DOUBLE NULL,
  `uv_index`              DOUBLE NULL,
  `weather_description`   VARCHAR(190) NULL,
  `city_name`             VARCHAR(100) NULL,
  -- نتائج الذكاء الاصطناعي
  `cv_detected_condition` VARCHAR(190) NULL,
  `cv_confidence_score`   DOUBLE NULL,
  `nlp_consultation_text` TEXT NULL,
  `notes`                 TEXT NULL,
  `is_deleted`            TINYINT(1) DEFAULT 0,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_user`      (`user_id`),
  INDEX `idx_date`      (`scan_date`),
  INDEX `idx_condition` (`cv_detected_condition`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4) جدول رسائل المحادثة الذكية
CREATE TABLE IF NOT EXISTS `chat_messages` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5) جدول النصائح اليومية
CREATE TABLE IF NOT EXISTS `skin_tips` (
  `id`         INT AUTO_INCREMENT PRIMARY KEY,
  `skin_type`  VARCHAR(50) NULL,
  `season`     ENUM('summer','winter','spring','autumn') NULL,
  `tip_text`   TEXT NOT NULL,
  `is_active`  TINYINT(1) DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6.5) جدول "نصيحة اليوم" المولّدة بالذكاء الاصطناعي
--      قيد UNIQUE(user_id, advice_date) يضمن نصيحة واحدة فقط لكل مستخدم في اليوم
CREATE TABLE IF NOT EXISTS `daily_advice` (
  `id`                  INT AUTO_INCREMENT PRIMARY KEY,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7) جدول روتين العناية للمستخدم
CREATE TABLE IF NOT EXISTS `user_routines` (
  `id`           INT AUTO_INCREMENT PRIMARY KEY,
  `user_id`      INT NOT NULL,
  `routine_type` ENUM('morning','evening') NOT NULL,
  `step_order`   INT NOT NULL,
  `step_name`    VARCHAR(150) NOT NULL,
  `product_name` VARCHAR(200) NULL,
  `is_completed` TINYINT(1) DEFAULT 0,
  `created_at`   DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_routine_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
