# سكربت لإنشاء شجرة ملفات مشروع Skin Analysis
$baseDir = "lib"

# قائمة المجلدات
$directories = @(
    "$baseDir/core/constants",
    "$baseDir/core/theme",
    "$baseDir/core/utils",
    "$baseDir/core/network",
    "$baseDir/core/errors",
    "$baseDir/shared/widgets",
    "$baseDir/features/auth/screens",
    "$baseDir/features/auth/widgets",
    "$baseDir/features/auth/controllers",
    "$baseDir/features/onboarding/screens",
    "$baseDir/features/onboarding/widgets",
    "$baseDir/features/skin_analysis/screens",
    "$baseDir/features/skin_analysis/widgets",
    "$baseDir/features/skin_analysis/services",
    "$baseDir/features/skin_analysis/controllers",
    "$baseDir/features/history/screens",
    "$baseDir/features/history/widgets",
    "assets/images",
    "assets/icons"
)

# قائمة الملفات الفارغة
$files = @(
    "$baseDir/core/constants/app_colors.dart",
    "$baseDir/core/constants/app_strings.dart",
    "$baseDir/core/constants/api_endpoints.dart",
    "$baseDir/core/theme/app_theme.dart",
    "$baseDir/core/utils/helpers.dart",
    "$baseDir/core/network/dio_client.dart",
    "$baseDir/core/errors/failures.dart",
    "$baseDir/shared/widgets/custom_button.dart",
    "$baseDir/features/auth/screens/login_screen.dart",
    "$baseDir/features/auth/screens/register_screen.dart",
    "$baseDir/features/onboarding/screens/welcome_screen.dart",
    "$baseDir/features/skin_analysis/screens/camera_screen.dart",
    "$baseDir/features/skin_analysis/screens/analysis_result_screen.dart",
    "$baseDir/features/skin_analysis/services/location_service.dart",
    "$baseDir/features/skin_analysis/services/camera_service.dart",
    "$baseDir/features/history/screens/history_screen.dart"
)

Write-Host "Creating directories..." -ForegroundColor Cyan
foreach ($dir in $directories) {
    if (-Not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "Created Directory: $dir" -ForegroundColor Green
    }
}

Write-Host "Creating empty dart files..." -ForegroundColor Cyan
foreach ($file in $files) {
    if (-Not (Test-Path -Path $file)) {
        New-Item -ItemType File -Path $file | Out-Null
        Write-Host "Created File: $file" -ForegroundColor Green
    }
}

Write-Host "Project structure created successfully!" -ForegroundColor Yellow