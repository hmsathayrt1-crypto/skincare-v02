-- ============================================================
--  قاعدة بيانات تطبيق Dermalyze AI / DermAI
--  للاستيراد: افتح phpMyAdmin > استيراد > اختر هذا الملف
--  (ينشئ القاعدة والجداول تلقائياً)
-- ============================================================

CREATE DATABASE IF NOT EXISTS `skincare_db`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `skincare_db`;

-- 1) جدول المستخدمين
CREATE TABLE IF NOT EXISTS `users` (
  `id`            INT AUTO_INCREMENT PRIMARY KEY,
  `full_name`     VARCHAR(150) NOT NULL,
  `email`         VARCHAR(190) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `skin_type`     VARCHAR(50)  NULL,
  `created_at`    DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2) جدول توكنات الجلسات (للمصادقة)
CREATE TABLE IF NOT EXISTS `api_tokens` (
  `id`         INT AUTO_INCREMENT PRIMARY KEY,
  `user_id`    INT NOT NULL,
  `token`      VARCHAR(160) NOT NULL UNIQUE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
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
  -- نتائج الذكاء الاصطناعي
  `cv_detected_condition` VARCHAR(190) NULL,
  `cv_confidence_score`   DOUBLE NULL,
  `nlp_consultation_text` TEXT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
