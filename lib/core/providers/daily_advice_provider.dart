import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_advice_model.dart';
import '../services/daily_advice_service.dart';
import '../../features/skin_analysis/services/location_service.dart';

/// مزوّد "نصيحة اليوم".
/// يحمّل النصيحة مرة واحدة لكل جلسة (الخادم يضمن نصيحة واحدة/يوم)، ويحاول
/// جلب موقع المستخدم لتخصيص النصيحة حسب الطقس والموقع — وإن رُفض الإذن يكمل بدونه.
class DailyAdviceNotifier extends StateNotifier<AsyncValue<DailyAdviceModel>> {
  final DailyAdviceService _service = DailyAdviceService();
  final LocationService _location = LocationService();

  bool _hasLoaded = false;

  DailyAdviceNotifier() : super(const AsyncValue.loading());

  Future<void> load({bool force = false}) async {
    // لا نعيد التحميل في كل مرة تُبنى فيها الشاشة
    if (_hasLoaded && !force && state.hasValue) return;

    state = const AsyncValue.loading();
    try {
      double? lat;
      double? lon;
      try {
        final pos = await _location.getCurrentPosition();
        lat = pos?.latitude;
        lon = pos?.longitude;
      } catch (_) {
        // تجاهل أخطاء الموقع — النصيحة العامة تكفي
      }

      final advice = await _service.getDailyAdvice(lat: lat, lon: lon);
      state = AsyncValue.data(advice);
      _hasLoaded = true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dailyAdviceProvider =
    StateNotifierProvider<DailyAdviceNotifier, AsyncValue<DailyAdviceModel>>(
  (ref) => DailyAdviceNotifier(),
);
