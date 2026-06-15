# 05 - ربط الكاميرا برفع الصورة والتحليل

## المشكلة الحالية

1. **الصورة تُلتقط لكن لا تُرسل:**
   ```dart
   // camera_screen.dart سطر 71-76
   Future<void> _capturePhoto() async {
     final photo = await _cameraService.takePhoto();
     if (photo != null && mounted) {
       context.push('/analysis'); // ينتقل بدون إرسال الصورة!
     }
   }
   ```

2. **بيانات الطقس والموقع ثابتة (hardcoded):**
   ```dart
   // سطر 234-239 - بيانات وهمية
   _buildDataPoint(Icons.thermostat, "24°"),    // ثابت
   _buildDataPoint(Icons.water_drop, "45%"),     // ثابت
   _buildDataPoint(Icons.light_mode, "UV: 6"),   // ثابت
   Text("34.05,-118"),                           // إحداثيات لوس أنجلس!
   ```

3. **LocationService موجود لكن غير مستخدم** في CameraScreen

4. **شاشة النتائج ثابتة** — تعرض نفس البيانات دائماً

---

## الإصلاحات المطلوبة

### 1. إنشاء ScanService

**الملف الجديد:** `lib/core/services/scan_service.dart`

```dart
import '../network/dio_client.dart';
import '../constants/api_endpoints.dart';
import '../models/scan_model.dart';

class ScanService {
  final _client = DioClient();
  
  Future<ScanModel> analyzeSkin({
    required String imagePath,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _client.uploadFile(
      ApiEndpoints.skinAnalysis,
      filePath: imagePath,
      fieldName: 'image',
      extraFields: {
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      },
    );
    
    return ScanModel.fromJson(response.data['scan']);
  }
  
  Future<List<ScanModel>> getHistory({int limit = 20, int offset = 0}) async {
    final response = await _client.get(
      ApiEndpoints.analysisHistory,
      queryParameters: {'limit': limit, 'offset': offset},
    );
    
    final scans = response.data['scans'] as List;
    return scans.map((s) => ScanModel.fromJson(s)).toList();
  }
  
  Future<ScanModel> getScanDetail(int id) async {
    final response = await _client.get(
      ApiEndpoints.analysisDetail,
      queryParameters: {'id': id},
    );
    
    return ScanModel.fromJson(response.data['scan']);
  }
}
```

### 2. تعديل CameraScreen - تفعيل الموقع

```dart
// إضافة في initState
late LocationService _locationService;
double? _latitude;
double? _longitude;

@override
void initState() {
  super.initState();
  _locationService = LocationService();
  _initializeCamera();
  _fetchLocation();
}

Future<void> _fetchLocation() async {
  final hasPermission = await _locationService.requestPermission();
  if (hasPermission) {
    final position = await _locationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
  }
}
```

### 3. تعديل CameraScreen - تحديث عرض الموقع

```dart
// تغيير البيانات البيئية من ثابتة لديناميكية
Widget _buildEnvironmentalData() {
  return Row(
    children: [
      _buildDataPoint(Icons.location_on, 
        _latitude != null 
          ? '${_latitude!.toStringAsFixed(2)},${_longitude!.toStringAsFixed(2)}'
          : 'جاري التحديد...'
      ),
    ],
  );
}
```

**ملاحظة:** بيانات الطقس (الحرارة، الرطوبة، UV) تُجلب من الباك إند مع نتيجة التحليل — لا نحتاج جلبها في الفرونت.
خيار بسيط: اعرض الموقع فقط في الكاميرا، واعرض الطقس في صفحة النتائج.

### 4. تعديل _capturePhoto - إرسال الصورة للتحليل

```dart
Future<void> _capturePhoto() async {
  final photo = await _cameraService.takePhoto();
  if (photo == null || !mounted) return;
  
  // عرض شاشة تحميل
  setState(() => _isAnalyzing = true);
  
  try {
    final scanService = ScanService();
    final result = await scanService.analyzeSkin(
      imagePath: photo.path,
      latitude: _latitude,
      longitude: _longitude,
    );
    
    if (mounted) {
      // تمرير النتيجة لشاشة التحليل
      context.push('/analysis', extra: result);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التحليل: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) setState(() => _isAnalyzing = false);
  }
}
```

### 5. إضافة شاشة تحميل أثناء التحليل

```dart
// إضافة overlay فوق الكاميرا عند _isAnalyzing = true
if (_isAnalyzing)
  Container(
    color: Colors.black54,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.greenGlow),
          const SizedBox(height: 24),
          const Text(
            "جاري تحليل بشرتك بالذكاء الاصطناعي...",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    ),
  ),
```

### 6. تعديل شاشة النتائج لتستقبل بيانات حقيقية

**الملف:** `analysis_result_screen.dart`

**قبل:**
```dart
class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});
```

**بعد:**
```dart
class AnalysisResultScreen extends StatelessWidget {
  final ScanModel? scanResult;
  const AnalysisResultScreen({super.key, this.scanResult});
```

**تحديث Router لتمرير البيانات:**
```dart
GoRoute(
  path: '/analysis',
  name: 'analysis',
  builder: (context, state) => AnalysisResultScreen(
    scanResult: state.extra as ScanModel?,
  ),
),
```

**تحديث النصوص الثابتة:**
```dart
// بدل:
Text("التهاب الجلد التماسي (محتمل)")
// استخدم:
Text(scanResult?.condition ?? "جاري التحليل...")

// بدل:
Text("85%")
// استخدم:
Text("${((scanResult?.confidence ?? 0) * 100).toInt()}%")

// بدل:
// النص الثابت للاستشارة
// استخدم:
Text(scanResult?.consultation ?? "لا توجد استشارة متاحة")
```

---

## تدفق العملية الكامل بعد الإصلاح

```
1. المستخدم يفتح الكاميرا
   ↓
2. LocationService يجلب الموقع (GPS)
   ↓
3. المستخدم يلتقط صورة
   ↓
4. ScanService.analyzeSkin() يُرسل:
   - الصورة (multipart)
   - latitude, longitude
   ↓
5. الباك إند (analyze.php):
   a. يحفظ الصورة
   b. يجلب الطقس من OpenWeatherMap
   c. يرسل الصورة + السياق لـ Gemini
   d. يحفظ النتائج في scans
   e. يرجع النتيجة JSON
   ↓
6. Flutter يستقبل ScanModel
   ↓
7. ينتقل لـ AnalysisResultScreen(scanResult: result)
   ↓
8. الشاشة تعرض البيانات الحقيقية
```

---

## ملخص الملفات المتأثرة

| الملف | التغيير |
|-------|---------|
| `camera_screen.dart` | تفعيل الموقع + إرسال الصورة + loading |
| `analysis_result_screen.dart` | استقبال ScanModel + عرض بيانات حقيقية |
| `app_router.dart` | تمرير extra data لـ /analysis |
| **جديد:** `scan_service.dart` | service للتحليل والسجل |
| **جديد:** `scan_model.dart` | model لبيانات الفحص |
| `dio_client.dart` | تحديث uploadFile |
