import 'package:dio/dio.dart';
import 'package:skincare_v02/core/models/scan_model.dart';
import 'package:skincare_v02/core/network/dio_client.dart';
import 'package:skincare_v02/core/constants/api_endpoints.dart';

class ScanService {
  final DioClient _client = DioClient();

  Future<Map<String, dynamic>> getScans({int page = 1, int limit = 10}) async {
    // الباك إند يتوقع offset/limit وليس page، فنحوّل رقم الصفحة إلى إزاحة.
    final resp = await _client.dio.get(
      ApiEndpoints.scans,
      queryParameters: {'offset': (page - 1) * limit, 'limit': limit},
    );
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true) {
      final scans = (data['scans'] as List)
          .map((s) => ScanModel.fromJson(s))
          .toList();
      return {
        'scans': scans,
        'total': data['total'] ?? scans.length,
        'page': data['page'] ?? page,
      };
    }
    throw Exception(data['message'] ?? 'Failed to load scans');
  }

  Future<ScanModel> getScanById(int id) async {
    final resp = await _client.dio.get('${ApiEndpoints.scans}?id=$id');
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return ScanModel.fromJson(data['scan']);
    }
    throw Exception(data['message'] ?? 'Failed to load scan');
  }

  Future<void> deleteScan(int id) async {
    final resp = await _client.dio.delete(
      ApiEndpoints.scans,
      data: {'id': id},
    );
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete scan');
    }
  }

  Future<ScanModel> analyzeImage({
    required String filePath,
    double? latitude,
    double? longitude,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });

    final resp = await _client.dio.post(
      ApiEndpoints.analyze,
      data: formData,
    );
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return ScanModel.fromJson(data['scan']);
    }
    throw Exception(data['message'] ?? 'Analysis failed');
  }
}
