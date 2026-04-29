import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';

// Enum جديد لتصنيف نوع النتيجة والتحكم بالألوان
enum ScanTagType {
  normal,
  needsHydration,
  improving,
  oily,
  dry,
  combo,
}

// تحديث نموذج البيانات ليشمل النوع الجديد
class ScanResult {
  final String date;
  final String title;
  final String status;
  final String details;
  final IconData icon;
  final String imageUrl;
  final ScanTagType tagType; // إضافة نوع النتيجة

  ScanResult({
    required this.date,
    required this.title,
    required this.status,
    required this.details,
    required this.icon,
    required this.imageUrl,
    required this.tagType,
  });
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // دالة مساعدة لجلب الألوان بناءً على نوع النتيجة
  Map<String, Color> _getTagColors(ScanTagType type) {
    switch (type) {
      case ScanTagType.needsHydration:
        return {'bg': const Color(0x33FF4081), 'border': const Color(0xFFFF4081)};
      case ScanTagType.improving:
        return {'bg': const Color(0x334CAF50), 'border': const Color(0xFF4CAF50)};
      case ScanTagType.oily:
        return {'bg': const Color(0x338BC34A), 'border': const Color(0xFF8BC34A)};
      case ScanTagType.dry:
        return {'bg': const Color(0x33FF9800), 'border': const Color(0xFFFF9800)};
      case ScanTagType.combo:
        return {'bg': const Color(0x332196F3), 'border': const Color(0xFF2196F3)};
      case ScanTagType.normal:
      default:
        return {'bg': const Color(0x33FFEB3B), 'border': const Color(0xFFFFEB3B)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ScanResult> results = [
      ScanResult(
        date: "12 أكتوبر 2023 • 09:30 ص",
        title: "تحليل الوجه",
        status: "بشرة طبيعية",
        details: "نسبة الترطيب ممتازة",
        icon: Icons.water_drop,
        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDqG8631IdEEca9vdMJtRg7ATZBlyuxVIFQyGe8t-nT17h1MBLTMbrUxn8zPh74KsRnJCip1WNgUDt6ltbrISvgxopv1zSxzaJLg-RAjr8IjCRs4MLHbQPWde2Xo0e0Z7KpN7yz1SPvwx92EqKSRUqXwIeP4tFRCmC_VRE-S8EyGrzp8aA1cW5qewkTDb-WpTHocz439ofCqnLmTR58zBSAzvMW-IGtfC6AHtmohsaRIZYrv0ED-r72J03ox2p_MqDWU6Q8fmo67mU",
        tagType: ScanTagType.normal,
      ),
      ScanResult(
        date: "05 أكتوبر 2023 • 08:15 م",
        title: "منطقة الخد",
        status: "تحتاج ترطيب",
        details: "جفاف ملحوظ",
        icon: Icons.warning,
        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAPz-OfK9V5mgkpho2YB1loD4-YzUncSKY8wC6iZpoPuPst8QOVWEPNc8qtvoz97q6WCcnzwII3FyauaOgo_Gw-dkSty1L6xinquPeWCwViq4rZeYlEGQ6phD-wSCx8nwEkLxU2MQ7R-266mPRVzQsVmOYX-c7AwLAK83-vXT4Lhu4a8BgnfNTzNRCgON_nAyVabMbayDxC5m-btzrczsW-jxaB7vqlAuDxFRsuyhyXzhKxevu46fx8od7eufWa_kNVS1wUI6M0pXw",
        tagType: ScanTagType.needsHydration,
      ),
      ScanResult(
        date: "28 سبتمبر 2023 • 10:00 ص",
        title: "منطقة الجبهة",
        status: "تحسن ملحوظ",
        details: "انخفاض في الإفرازات",
        icon: Icons.trending_up,
        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuC24vax-Y_4WZ8N0itOZ9_2RuDpfQ2T_vhci7PY-E6kYeR3juTkH7gGbkHrjh4Vmw-mhjaksQf3JfQ_bt65MTTvQE0ZBADIW39ODM99pPbyqopUT8gsu2LQNerye2Hw98uIsnXOItV97WeBlLYNwH4XtFF_h1WijccN7TSf4mPH3eOdSHvMmcNsRuUf0kXNKACa3tGYhUq_o9f1f6WiWn3IpXD7QCVgqoDonxyKvkbUrNTdGwDitobMxaTQ1f3lG4c6-Ambx6IfVuc",
        tagType: ScanTagType.improving,
      ),
    ];

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
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildFilterPills(),
              const SizedBox(height: 24),
              _buildTimeline(results),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.75),
      elevation: 0,
      centerTitle: false,
      leading: const SizedBox.shrink(), // لإخفاء زر الرجوع الافتراضي
      leadingWidth: 0,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider("https://lh3.googleusercontent.com/aida-public/AB6AXuB0xTWEsprHVuJI2e8O7UBoIMcthurECJQax7Mgy_wv4fDEAxzFxl3_6Q9hVnQ5RA1LcxH-HsAUoAXMOgjRw4ZOc9gDiNdPkxP2xDwPBkgZGUtY-2Y-5v4UmgA9yxhG0BiQQY9wrkJiQsYVDl-XRfyx04icEmpztp7faknYueDtjMZ7q6IiQ4so8fczvRPn-SUOYOKjtvA9Vw8qYuyG-3XWUlC1TFgM6i8v1WGIHe8zOKKDnXbJHzwBbze5KTp6R-MaEvIADrB141Y"),
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
          onPressed: () {},
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

  Widget _buildFilterPills() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPill("الكل", isActive: true),
          _buildPill("بشرة دهنية", tagType: ScanTagType.oily),
          _buildPill("بشرة جافة", tagType: ScanTagType.dry),
          _buildPill("بشرة مختلطة", tagType: ScanTagType.combo),
        ],
      ),
    );
  }

  Widget _buildPill(String text, {bool isActive = false, ScanTagType? tagType}) {
    final colors = tagType != null ? _getTagColors(tagType) : null;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Colors.white : (colors != null ? colors['bg'] : Colors.white.withOpacity(0.6)),
          foregroundColor: Colors.black,
          shape: const StadiumBorder(),
          side: BorderSide(color: isActive ? Colors.black45 : (colors != null ? colors['border']! : Colors.transparent)),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Text(text, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildTimeline(List<ScanResult> results) {
    return Stack(
      children: [
        // الخط الزمني بالألوان الجديدة
        Positioned(
          right: 20,
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
          children: results.map((result) => _buildTimelineItem(result)).toList(),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(ScanResult result) {
    final dotColor = _getTagColors(result.tagType)['border']!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 2),
                    boxShadow: [BoxShadow(color: dotColor.withOpacity(0.9), blurRadius: 12)],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildResultCard(result)),
        ],
      ),
    );
  }

  Widget _buildResultCard(ScanResult result) {
    final tagColors = _getTagColors(result.tagType);
    final iconColor = result.tagType == ScanTagType.normal || result.tagType == ScanTagType.improving ? const Color(0xFF4CAF50) : tagColors['border']!;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: result.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container( // حاوية لإضافة التوهج للأيقونة
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: iconColor.withOpacity(0.6), blurRadius: 8)],
                              ),
                              child: Icon(result.icon, size: 18, color: iconColor),
                            ),
                            const SizedBox(width: 4),
                            Text(result.details, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColors['bg'],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tagColors['border']!),
                    ),
                    child: Text(result.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
                  ),
                ],
              ),
            ],
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
          colors: [color.withOpacity(0.4), Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}