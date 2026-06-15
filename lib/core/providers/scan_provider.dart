import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_model.dart';
import '../services/scan_service.dart';

// الفحص الحالي (نتيجة آخر تحليل)
final currentScanProvider = StateProvider<ScanModel?>((ref) => null);

// حالة التحليل
final isAnalyzingProvider = StateProvider<bool>((ref) => false);

// سجل الفحوصات
class ScanHistoryNotifier extends StateNotifier<AsyncValue<List<ScanModel>>> {
  final ScanService _scanService = ScanService();

  ScanHistoryNotifier() : super(const AsyncValue.loading());

  Future<void> loadScans({int page = 1, int limit = 20}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _scanService.getScans(page: page, limit: limit);
      state = AsyncValue.data(result['scans'] as List<ScanModel>);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteScan(int id) async {
    try {
      await _scanService.deleteScan(id);
      // إعادة تحميل القائمة
      await loadScans();
    } catch (_) {}
  }
}

final scanHistoryProvider =
    StateNotifierProvider<ScanHistoryNotifier, AsyncValue<List<ScanModel>>>((ref) {
  return ScanHistoryNotifier();
});
