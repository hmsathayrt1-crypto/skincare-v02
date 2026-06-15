@echo off
:: ترميز UTF-8 لدعم اللغة العربية في الكونسول
chcp 65001 > nul
title تهيئة قاعدة بيانات SkinCare v02

echo ===================================================
echo   🛠️ سكربت إعداد وتهيئة قاعدة البيانات - SkinCare v02
echo ===================================================
echo.
echo سيقوم هذا السكربت بتشغيل ملف الهجرة والبيانات الأولية (Migrate & Seed).
echo تأكد من تشغيل Apache و MySQL في XAMPP قبل البدء!
echo.
pause

echo.
echo ⏳ جاري تشغيل Migration...
php -f backend/database/migrate_fresh_seed.php

echo.
echo ===================================================
echo ✅ تم الانتهاء من محاولة التشغيل.
echo إذا رأيت رسائل نجاح بالأعلى، فهذا يعني أن قاعدة البيانات بُنيت بالكامل.
echo.
echo 🌐 يمكنك أيضاً تشغيل التهيئة في أي وقت من المتصفح عبر الرابط:
echo http://localhost/backend/database/migrate_fresh_seed.php
echo ===================================================
echo.
pause
