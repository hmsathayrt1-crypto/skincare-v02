import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/daily_advice_model.dart';
import '../../../core/models/scan_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/daily_advice_provider.dart';
import '../../../core/providers/scan_provider.dart';

/// الشاشة الرئيسية — تظهر فور تسجيل الدخول.
/// تعرض ودجت الطقس/الموقع، بطاقة "نصيحة اليوم" المولّدة بالذكاء الاصطناعي،
/// وملخص آخر تحليل للبشرة.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dailyAdviceProvider.notifier).load();
      ref.read(scanHistoryProvider.notifier).loadScans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final adviceAsync = ref.watch(dailyAdviceProvider);
    final scansAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // توهجات الخلفية بنفس هوية باقي الشاشات
          Positioned(top: -120, right: -100, child: _glow(const Color(0xFFFFC1E3), 420)),
          Positioned(bottom: -120, left: -100, child: _glow(const Color(0xFF8BC34A), 480)),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              children: [
                _buildHeader(user?.fullName),
                const SizedBox(height: 20),
                _buildWeatherWidget(adviceAsync),
                const SizedBox(height: 20),
                _buildAdviceCard(adviceAsync),
                const SizedBox(height: 28),
                _buildLastAnalysis(scansAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== الهيدر =====
  Widget _buildHeader(String? name) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
          ),
          child: const Icon(Icons.person, color: Colors.black54, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('مرحباً بعودتك 👋',
                  style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
              Text(
                (name == null || name.isEmpty) ? 'Dermalyze' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.6),
            border: Border.all(color: Colors.white),
          ),
          child: const Icon(Icons.notifications_none, color: Colors.black, size: 24),
        ),
      ],
    );
  }

  // ===== ودجت الطقس والموقع =====
  Widget _buildWeatherWidget(AsyncValue<DailyAdviceModel> adviceAsync) {
    final advice = adviceAsync.valueOrNull;
    final city = advice?.cityName ?? 'تحديد الموقع...';
    final hasWeather = advice?.hasWeather ?? false;

    return _glassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      hasWeather ? '${advice!.temperature!.round()}°' : '--°',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, height: 1),
                    ),
                    const SizedBox(width: 16),
                    if (hasWeather)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (advice!.humidity != null)
                            Text('رطوبة ${advice.humidity!.round()}%',
                                style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
                          if (advice.weatherDescription != null)
                            Text(advice.weatherDescription!,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF635F40), fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            child: Icon(_weatherIcon(advice?.weatherDescription),
                color: const Color(0xFF635F40), size: 32),
          ),
        ],
      ),
    );
  }

  // ===== بطاقة نصيحة اليوم (جوهر الميزة) =====
  Widget _buildAdviceCard(AsyncValue<DailyAdviceModel> adviceAsync) {
    return _glassCard(
      padding: const EdgeInsets.all(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -60, top: -60,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFADADD).withValues(alpha: 0.35),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF635F40), size: 20),
                  const SizedBox(width: 8),
                  const Text('نصيحة اليوم',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: Color(0xFF635F40))),
                  const Spacer(),
                  if (!adviceAsync.isLoading)
                    InkWell(
                      onTap: () => ref.read(dailyAdviceProvider.notifier).load(force: true),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.refresh, size: 18, color: Colors.black45),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              adviceAsync.when(
                loading: () => _adviceSkeleton(),
                error: (e, _) => _adviceError(),
                data: (advice) => Text(
                  advice.adviceText,
                  style: const TextStyle(
                      fontSize: 17, height: 1.6, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _adviceSkeleton() {
    Widget bar(double w) => Container(
          height: 14,
          width: w,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 22, width: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF8BC34A)),
        ),
        const SizedBox(height: 16),
        bar(double.infinity),
        bar(220),
        bar(160),
      ],
    );
  }

  Widget _adviceError() {
    return Row(
      children: [
        const Icon(Icons.cloud_off, color: Colors.black38, size: 20),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('تعذّر جلب نصيحة اليوم. تأكد من الاتصال بالخادم.',
              style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () => ref.read(dailyAdviceProvider.notifier).load(force: true),
          child: const Text('إعادة'),
        ),
      ],
    );
  }

  // ===== ملخص آخر تحليل =====
  Widget _buildLastAnalysis(AsyncValue<List<ScanModel>> scansAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 4, bottom: 12),
          child: Text('آخر تحليل للبشرة',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black)),
        ),
        scansAsync.when(
          loading: () => _glassCard(
            padding: const EdgeInsets.all(24),
            child: const Center(
              child: SizedBox(
                height: 22, width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF8BC34A)),
              ),
            ),
          ),
          error: (_, __) => _emptyAnalysisCard('تعذّر تحميل آخر تحليل'),
          data: (scans) {
            if (scans.isEmpty) {
              return _emptyAnalysisCard('لا توجد فحوصات بعد — ابدأ أول فحص لبشرتك');
            }
            return _lastScanCard(scans.first);
          },
        ),
      ],
    );
  }

  Widget _lastScanCard(ScanModel scan) {
    final confidence = ((scan.confidence ?? 0) * 100).round();
    return GestureDetector(
      onTap: () => context.push('/analysis', extra: scan),
      child: _glassCard(
        padding: const EdgeInsets.all(18),
        borderLeft: const Color(0xFF635F40),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF635F40), width: 2),
              ),
              child: Center(
                child: Text('$confidence%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF635F40))),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.condition ?? 'غير محدد',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(scan.scanDate,
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _emptyAnalysisCard(String text) {
    return _glassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, color: Color(0xFF8BC34A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ===== أدوات مساعدة للأسلوب =====
  Widget _glassCard({required Widget child, required EdgeInsets padding, Color? borderLeft}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: borderLeft == null
                ? Border.all(color: Colors.white.withValues(alpha: 0.8))
                : Border(right: BorderSide(color: borderLeft, width: 4)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.35), Colors.transparent],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }

  IconData _weatherIcon(String? desc) {
    if (desc == null) return Icons.wb_cloudy_outlined;
    if (desc.contains('مطر') || desc.contains('رذاذ') || desc.contains('زخات')) return Icons.umbrella;
    if (desc.contains('ثلج')) return Icons.ac_unit;
    if (desc.contains('رعد')) return Icons.thunderstorm;
    if (desc.contains('ضباب')) return Icons.foggy;
    if (desc.contains('غائم')) return Icons.cloud_outlined;
    return Icons.wb_sunny;
  }
}
