import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/scan_model.dart';
import '../../../core/providers/scan_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // الحالة المختارة للتصفية (null = عرض الكل)
  String? _activeCondition;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(scanHistoryProvider.notifier).loadScans();
    });
  }

  // دالة مساعدة لجلب الألوان بناءً على الحالة
  Map<String, Color> _getTagColors(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'acne':
      case 'حب الشباب':
        return {'bg': const Color(0x33FF4081), 'border': const Color(0xFFFF4081)};
      case 'normal':
      case 'بشرة طبيعية':
        return {'bg': const Color(0x334CAF50), 'border': const Color(0xFF4CAF50)};
      case 'oily':
      case 'بشرة دهنية':
        return {'bg': const Color(0x338BC34A), 'border': const Color(0xFF8BC34A)};
      case 'dry':
      case 'بشرة جافة':
        return {'bg': const Color(0x33FF9800), 'border': const Color(0xFFFF9800)};
      case 'combination':
      case 'بشرة مختلطة':
        return {'bg': const Color(0x332196F3), 'border': const Color(0xFF2196F3)};
      default:
        return {'bg': const Color(0x33FFEB3B), 'border': const Color(0xFFFFEB3B)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final scansAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // 1. التوهج الخلفي بالألوان الجديدة
          Positioned(
            top: -100,
            right: -100,
            child: _buildAmbientGlow(const Color(0xFFffc1e3), 400),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildAmbientGlow(const Color(0xFF8bc34a), 500),
          ),

          // 2. المحتوى الرئيسي
          scansAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8bc34a),
              ),
            ),
            error: (error, stack) => _buildErrorState(error),
            data: (scans) {
              if (scans.isEmpty) {
                return _buildEmptyState();
              }
              return _buildContent(scans);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFFF4081),
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ أثناء تحميل السجل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(scanHistoryProvider.notifier).loadScans();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8bc34a),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8bc34a).withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.history,
                size: 64,
                color: Color(0xFF8bc34a),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد فحوصات سابقة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ أول فحص لبشرتك لرؤية النتائج هنا',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<ScanModel> scans) {
    // استخراج الحالات المتوفرة فعلياً من النتائج لبناء أزرار تصفية حقيقية
    final conditions = scans
        .map((s) => s.condition)
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    // إن كانت الحالة المختارة لم تعد موجودة، نرجع للكل
    final activeExists = _activeCondition == null || conditions.contains(_activeCondition);
    final effectiveFilter = activeExists ? _activeCondition : null;

    final filtered = effectiveFilter == null
        ? scans
        : scans.where((s) => s.condition == effectiveFilter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      children: [
        _buildFilterPills(context, conditions),
        const SizedBox(height: 24),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'لا توجد فحوصات ضمن هذا التصنيف',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
          )
        else
          _buildTimeline(filtered),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.75),
      elevation: 0,
      centerTitle: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFEAE7E7),
            child: Icon(Icons.person, color: Colors.black54, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            "سجل النتائج",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('خيارات التصفية والفرز')),
            );
          },
          icon: const Icon(Icons.tune, color: Colors.black),
        ),
      ],
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildFilterPills(BuildContext context, List<String> conditions) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPill(context, "الكل", condition: null),
          ...conditions.map((c) => _buildPill(context, c, condition: c)),
        ],
      ),
    );
  }

  Widget _buildPill(BuildContext context, String text, {String? condition}) {
    final isActive = _activeCondition == condition;
    final colors = condition != null ? _getTagColors(condition) : null;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextButton(
        onPressed: () => setState(() => _activeCondition = condition),
        style: TextButton.styleFrom(
          backgroundColor: isActive
              ? Colors.white
              : (colors != null ? colors['bg'] : Colors.white.withValues(alpha: 0.6)),
          foregroundColor: Colors.black,
          shape: const StadiumBorder(),
          side: BorderSide(
              color: isActive
                  ? Colors.black45
                  : (colors != null ? colors['border']! : Colors.transparent)),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Text(text,
            style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildTimeline(List<ScanModel> scans) {
    return Stack(
      children: [
        // الخط الزمني بالألوان الجديدة
        Positioned(
          left: 18,
          top: 0,
          bottom: 0,
          width: 2,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x33ffc1e3), Color(0xCC8bc34a), Color(0x33ffc1e3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Column(
          children: scans.map((scan) => _buildTimelineItem(scan)).toList(),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(ScanModel scan) {
    final dotColor = _getTagColors(scan.condition)['border']!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 2),
                    boxShadow: [BoxShadow(color: dotColor.withValues(alpha: 0.9), blurRadius: 12)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _buildResultCard(scan)),
        ],
      ),
    );
  }

  Widget _buildResultCard(ScanModel scan) {
    final tagColors = _getTagColors(scan.condition);
    final isPositive = scan.condition?.toLowerCase() == 'normal' ||
        scan.condition?.toLowerCase() == 'بشرة طبيعية';
    final iconColor = isPositive ? const Color(0xFF4CAF50) : tagColors['border']!;
    final confidencePercent = ((scan.confidence ?? 0) * 100).toInt();

    return GestureDetector(
      onTap: () {
        context.push('/analysis', extra: scan);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scan.scanDate,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: scan.fullImageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(scan.condition ?? 'غير معروف',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Colors.black)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: iconColor.withValues(alpha: 0.6), blurRadius: 8)
                                  ],
                                ),
                                child: Icon(
                                    isPositive ? Icons.check_circle : Icons.info_outline,
                                    size: 18,
                                    color: iconColor),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text('نسبة الثقة: $confidencePercent%',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.black87)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.4), Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}
