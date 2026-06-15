@echo off
:: ============================================================
::  setup.bat — تهيئة وتشغيل باك إند SkinCare v02
::  شغّله على "جهاز السيرفر". يعمل من أي مكان (ينتقل لمجلده تلقائياً).
::  اختياري: مرّر المنفذ كوسيط إن كان 80 مشغولاً، مثال:
::      setup.bat 8081
:: ============================================================
chcp 65001 > nul
title إعداد باك إند SkinCare v02
setlocal EnableDelayedExpansion

:: الانتقال إلى مجلد المشروع (مكان هذا الملف) حتى تعمل المسارات أينما شُغّل.
cd /d "%~dp0"

:: ===== المنفذ: افتراضي 80، أو من أول وسيط للسكربت =====
set "PORT=80"
if not "%~1"=="" set "PORT=%~1"

echo ===================================================
echo   إعداد باك إند SkinCare v02   (المنفذ: %PORT%)
echo ===================================================
echo.

:: ===== 1) إيجاد php.exe =====
set "PHP="
if exist "C:\xampp\php\php.exe" set "PHP=C:\xampp\php\php.exe"
if not defined PHP for /f "delims=" %%p in ('where php 2^>nul') do if not defined PHP set "PHP=%%p"
if not defined PHP (
  echo [خطأ] لم يتم العثور على php.exe.
  echo        ثبّت XAMPP في C:\xampp أو أضف PHP إلى متغير PATH ثم أعد المحاولة.
  echo.
  pause & exit /b 1
)
echo [OK] PHP: %PHP%

:: ===== 2) التحقق من تشغيل MySQL =====
tasklist /fi "imagename eq mysqld.exe" 2>nul | find /i "mysqld.exe" >nul
if errorlevel 1 (
  echo [!]  MySQL لا يعمل — شغّل MySQL من لوحة تحكم XAMPP قبل بناء القاعدة.
) else (
  echo [OK] MySQL يعمل.
)

:: ===== 3) فتح المنفذ في جدار الحماية (يحتاج تشغيل السكربت كمسؤول) =====
netsh advfirewall firewall delete rule name="SkinCare Backend %PORT%" >nul 2>nul
netsh advfirewall firewall add rule name="SkinCare Backend %PORT%" dir=in action=allow protocol=TCP localport=%PORT% >nul 2>nul
if errorlevel 1 (
  echo [!]  لم أفتح المنفذ في الجدار الناري ^(شغّل الملف كمسؤول: كبسة يمين -^> Run as administrator^).
) else (
  echo [OK] تم السماح بالمنفذ %PORT% في جدار الحماية.
)

:: ===== عرض عناوين هذا الجهاز على الشبكة المحلية =====
echo.
echo ---------------------------------------------------
echo   عناوين هذا الجهاز — ضع أحدها في إعدادات التطبيق:
for /f "delims=" %%i in ('powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -match '^(192\.168|10\.|172\.(1[6-9]|2[0-9]|3[01]))\.'} | ForEach-Object {$_.IPAddress}" 2^>nul') do echo       %%i:%PORT%
echo ---------------------------------------------------
echo.

:menu
echo اختر العملية:
echo   [1] تشغيل خادم الباك إند     (متاح لكل الشبكة على المنفذ %PORT%)
echo   [2] بناء قاعدة البيانات + بيانات أولية   (تحذير: يحذف البيانات الحالية)
echo   [3] بناء القاعدة ثم تشغيل الخادم
echo   [4] خروج
set "choice="
set /p choice="الخيار [1/2/3/4]: "
if "%choice%"=="1" goto serve
if "%choice%"=="2" ( call :migrate & goto menu )
if "%choice%"=="3" ( call :migrate & goto serve )
if "%choice%"=="4" exit /b 0
echo خيار غير صحيح.
goto menu

:: --- بناء القاعدة (هجرة + بيانات أولية) ---
:migrate
echo.
set "confirm="
set /p confirm="⚠️  سيتم حذف كل البيانات وإعادة البناء من الصفر. متابعة؟ (y/n): "
if /i not "%confirm%"=="y" ( echo أُلغيت عملية البناء. & echo. & goto :eof )
echo ⏳ جاري بناء القاعدة...
"%PHP%" -f "backend\database\migrate_fresh_seed.php"
echo.
echo [OK] انتهى تنفيذ سكربت بناء القاعدة (راجع الرسائل بالأعلى).
echo.
goto :eof

:: --- تشغيل خادم PHP المدمج على كل واجهات الشبكة ---
:serve
echo.
echo ===================================================
echo 🌐 تشغيل الخادم على 0.0.0.0:%PORT%   (docroot: %CD%)
echo    في التطبيق ضع عنوان هذا الجهاز:  ^<IP^>:%PORT%
echo    رابط اختبار من المتصفح:  http://localhost:%PORT%/backend/
echo    لإيقاف الخادم اضغط: Ctrl+C
echo ===================================================
echo.
"%PHP%" -S 0.0.0.0:%PORT% -t "%CD%"
echo.
echo (توقف الخادم)
pause
exit /b 0
