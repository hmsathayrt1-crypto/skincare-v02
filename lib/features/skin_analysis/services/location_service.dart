import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// خدمة الموقع - تحديد موقع المستخدم GPS للحصول على بيانات الطقس
class LocationService {
  /// طلب إذن الموقع
  Future<bool> requestPermission() async {
    try {
      // التحقق من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      // التحقق من الإذن الحالي
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) return false;

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('خطأ في طلب إذن الموقع: $e');
      return false;
    }
  }

  /// الحصول على الموقع الحالي
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('خطأ في تحديد الموقع: $e');
      return null;
    }
  }

  /// الحصول على نص الإحداثيات: "24.05,46.72"
  Future<String> getCoordinatesString() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return '--.--,--.--';
      return '${position.latitude.toStringAsFixed(2)},${position.longitude.toStringAsFixed(2)}';
    } catch (e) {
      debugPrint('خطأ في الحصول على الإحداثيات: $e');
      return '--.--,--.--';
    }
  }

  /// بث تحديثات الموقع المستمرة
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }

  /// الحصول على خط العرض
  Future<double?> getLatitude() async {
    final position = await getCurrentPosition();
    return position?.latitude;
  }

  /// الحصول على خط الطول
  Future<double?> getLongitude() async {
    final position = await getCurrentPosition();
    return position?.longitude;
  }
}
