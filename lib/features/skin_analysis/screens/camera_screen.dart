import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/scan_service.dart';
import '../../../core/models/scan_model.dart';
import '../services/camera_service.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isAnalyzing = false;
  double? _latitude;
  double? _longitude;

  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initializeCamera();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanLineController.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed && !_cameraService.isInitialized) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final success = await _cameraService.initializeCamera();
    if (mounted) {
      setState(() {
        _isCameraReady = success;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (_) {
      // silently ignore location errors
    }
  }

  Future<void> _toggleFlash() async {
    await _cameraService.toggleFlash();
    if (mounted) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  Future<void> _switchCamera() async {
    await _cameraService.switchCamera();
    if (mounted) {
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    }
  }

  Future<void> _capturePhoto() async {
    final photo = await _cameraService.takePhoto();
    if (photo == null || !mounted) return;

    setState(() => _isAnalyzing = true);

    try {
      final scanService = ScanService();
      final ScanModel result = await scanService.analyzeImage(
        filePath: photo.path,
        latitude: _latitude,
        longitude: _longitude,
      );

      if (!mounted) return;
      context.push('/analysis', extra: result);
    } on Exception catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التحليل: $errorMsg'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'إعادة',
            textColor: Colors.white,
            onPressed: _capturePhoto,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التحليل: تأكد من اتصال السيرفر وحاول مجدداً'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: _buildGlassAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. معاينة الكاميرا الحقيقية أو شاشة انتظار
          if (_isCameraReady && _cameraService.controller != null)
            CameraPreview(_cameraService.controller!)
          else
            _buildCameraPlaceholder(),

          // 2. تدرج التعتيم (Vignette)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black54],
                stops: [0.4, 1.0],
                radius: 1.5,
              ),
            ),
          ),

          // 3. شريط البيانات البيئية (الموقع)
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: _buildEnvironmentalData(),
          ),

          // 4. إطار المسح الضوئي (Scanning Frame)
          Center(
            child: _buildScanningFrame(),
          ),

          // 5. نص الإرشادات
          Positioned(
            bottom: 250,
            left: 24,
            right: 24,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "يرجى تركيز الكاميرا على المنطقة المراد فحصها",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 6. أزرار التحكم بالكاميرا (مرفوعة فوق شريط التنقل السفلي)
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: _buildCameraControls(),
          ),

          // 7. Loading overlay during analysis
          if (_isAnalyzing) _buildAnalyzingOverlay(),
        ],
      ),
    );
  }

  // شاشة بديلة عند تحميل الكاميرا أو فشلها
  Widget _buildCameraPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.white38, size: 64),
            SizedBox(height: 16),
            Text(
              "جاري تشغيل الكاميرا...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.7),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                context.go('/chat');
              },
            ),
            title: const Text(
              "تحليل البشرة",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            actions: [
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.grey, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentalData() {
    final locationText = (_latitude != null && _longitude != null)
        ? '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
        : 'جاري التحديد...';

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(50),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 32, offset: Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                locationText,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningFrame() {
    final frameSize = MediaQuery.of(context).size.width * 0.75;
    final frameHeight = MediaQuery.of(context).size.width * 1.0;

    return SizedBox(
      width: frameSize,
      height: frameHeight,
      child: Stack(
        children: [
          _buildCorner(Alignment.topLeft),
          _buildCorner(Alignment.topRight),
          _buildCorner(Alignment.bottomLeft),
          _buildCorner(Alignment.bottomRight),

          // خط المسح المتحرك - يكرر باستمرار
          AnimatedBuilder(
            animation: _scanLineController,
            builder: (context, child) {
              return Positioned(
                top: _scanLineController.value * (frameHeight - 4),
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppTheme.greenGlow.withValues(alpha: 0.9), Colors.transparent],
                    ),
                    boxShadow: const [
                      BoxShadow(color: AppTheme.greenGlow, blurRadius: 15, spreadRadius: 2),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    Border border;
    BorderRadius radius;
    const color = AppTheme.greenGlow;
    const width = 3.0;

    if (alignment == Alignment.topLeft) {
      border = const Border(top: BorderSide(color: color, width: width), left: BorderSide(color: color, width: width));
      radius = const BorderRadius.only(topLeft: Radius.circular(24));
    } else if (alignment == Alignment.topRight) {
      border = const Border(top: BorderSide(color: color, width: width), right: BorderSide(color: color, width: width));
      radius = const BorderRadius.only(topRight: Radius.circular(24));
    } else if (alignment == Alignment.bottomLeft) {
      border = const Border(bottom: BorderSide(color: color, width: width), left: BorderSide(color: color, width: width));
      radius = const BorderRadius.only(bottomLeft: Radius.circular(24));
    } else {
      border = const Border(bottom: BorderSide(color: color, width: width), right: BorderSide(color: color, width: width));
      radius = const BorderRadius.only(bottomRight: Radius.circular(24));
    }

    return Align(
      alignment: alignment,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(border: border, borderRadius: radius),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // زر الفلاش - فعال
        GestureDetector(
          onTap: _isCameraReady && !_isAnalyzing ? _toggleFlash : null,
          child: _buildGlassCircleButton(
            _isFlashOn ? Icons.flash_on : Icons.flash_off,
            48,
          ),
        ),
        const SizedBox(width: 32),

        // زر الالتقاط الرئيسي
        GestureDetector(
          onTap: _isCameraReady && !_isAnalyzing ? _capturePhoto : null,
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: _isCameraReady ? 1.0 : 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.pinkGlow.withValues(alpha: _isCameraReady ? 0.5 : 0.0),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppTheme.pinkGlow, AppTheme.greenGlow]),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),

        // زر تدوير الكاميرا - فعال
        GestureDetector(
          onTap: _isCameraReady && !_isAnalyzing ? _switchCamera : null,
          child: _buildGlassCircleButton(
            Icons.flip_camera_ios,
            48,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCircleButton(IconData icon, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: size,
          height: size,
          color: Colors.white.withValues(alpha: 0.5),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
      ),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.greenGlow,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'جاري تحليل بشرتك بالذكاء الاصطناعي...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
