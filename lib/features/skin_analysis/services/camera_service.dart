import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// خدمة الكاميرا - تتعامل مع فتح الكاميرا والتصوير والتبديل
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  /// هل تم تهيئة الكاميرا؟
  bool get isInitialized => _isInitialized && (_controller?.value.isInitialized ?? false);

  /// المتحكم بالكاميرا
  CameraController? get controller => _controller;

  /// وضع الفلاش الحالي
  FlashMode get currentFlashMode => _controller?.value.flashMode ?? FlashMode.auto;

  /// طلب إذن الكاميرا
  Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// تهيئة الكاميرا الخلفية
  Future<bool> initializeCamera() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return false;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return false;

      // البحث عن الكاميرا الخلفية
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('خطأ في تهيئة الكاميرا: $e');
      return false;
    }
  }

  /// التقاط صورة
  Future<XFile?> takePhoto() async {
    if (!isInitialized) return null;
    try {
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint('خطأ في التقاط الصورة: $e');
      return null;
    }
  }

  /// التبديل بين الكاميرا الأمامية والخلفية
  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    try {
      final currentDirection = _controller?.description.lensDirection;
      final newDirection = currentDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      final newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == newDirection,
        orElse: () => _cameras.first,
      );

      await _controller?.dispose();
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
    } catch (e) {
      debugPrint('خطأ في تبديل الكاميرا: $e');
    }
  }

  /// تبديل الفلاش (تشغيل/إطفاء الفلاش)
  Future<void> toggleFlash() async {
    if (!isInitialized) return;
    try {
      final newMode = currentFlashMode == FlashMode.torch
          ? FlashMode.off
          : FlashMode.torch;
      await _controller!.setFlashMode(newMode);
    } catch (e) {
      debugPrint('خطأ في تبديل الفلاش: $e');
    }
  }

  /// تحرير الموارد
  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }
}
