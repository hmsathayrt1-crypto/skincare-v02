import 'package:skincare_v02/core/models/daily_advice_model.dart';
import 'package:skincare_v02/core/network/dio_client.dart';
import 'package:skincare_v02/core/constants/api_endpoints.dart';

/// خدمة جلب "نصيحة اليوم" من الخادم.
/// يمرّر الإحداثيات (إن توفّرت) ليولّد الخادم نصيحة حسب الطقس والموقع.
class DailyAdviceService {
  final DioClient _client = DioClient();

  Future<DailyAdviceModel> getDailyAdvice({double? lat, double? lon}) async {
    final resp = await _client.dio.get(
      ApiEndpoints.dailyAdvice,
      queryParameters: {
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
      },
    );
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true && data['advice'] != null) {
      return DailyAdviceModel.fromJson(data['advice'] as Map<String, dynamic>);
    }
    throw Exception(data['message'] ?? 'تعذّر جلب نصيحة اليوم');
  }
}
