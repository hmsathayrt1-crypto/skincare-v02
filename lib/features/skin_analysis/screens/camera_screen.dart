import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../services/camera_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    if (photo != null && mounted) {
      context.push('/analysis');
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

          // 3. شريط البيانات البيئية (الطقس والموقع)
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
            bottom: 180,
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

          // 6. أزرار التحكم بالكاميرا
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: _buildCameraControls(),
          ),
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
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('القائمة الجانبية')),
                );
              },
            ),
            title: const Text(
              "تحليل البشرة",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            actions: [
              Padding(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentalData() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDataPoint(Icons.thermostat, "24°"),
              Container(width: 1, height: 20, color: Colors.black45),
              _buildDataPoint(Icons.water_drop, "45%"),
              Container(width: 1, height: 20, color: Colors.black45),
              _buildDataPoint(Icons.light_mode, "UV: 6"),
              Container(width: 1, height: 20, color: Colors.black45),
              const Text(
                "34.05,-118",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataPoint(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 18),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildScanningFrame() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.width * 1.0,
      child: Stack(
        children: [
          _buildCorner(Alignment.topLeft),
          _buildCorner(Alignment.topRight),
          _buildCorner(Alignment.bottomLeft),
          _buildCorner(Alignment.bottomRight),

          // خط المسح المتحرك
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Positioned(
                top: value * (MediaQuery.of(context).size.width * 1.0 - 4),
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
          onTap: _isCameraReady ? _toggleFlash : null,
          child: _buildGlassCircleButton(
            _isFlashOn ? Icons.flash_on : Icons.flash_off,
            48,
          ),
        ),
        const SizedBox(width: 32),

        // زر الالتقاط الرئيسي
        GestureDetector(
          onTap: _isCameraReady ? _capturePhoto : null,
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
          onTap: _isCameraReady ? _switchCamera : null,
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
}
