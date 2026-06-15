import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/scan_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/helpers.dart';

class AnalysisResultScreen extends ConsumerWidget {
  final ScanModel? scanResult;
  const AnalysisResultScreen({super.key, this.scanResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    // نوع البشرة الحقيقي من ملف المستخدم (إن وُجد)
    final skinTypeRaw = ref.watch(authProvider).user?.skinType;
    final skinTypeArabic =
        (skinTypeRaw != null && skinTypeRaw.isNotEmpty) ? Helpers.getSkinTypeNameArabic(skinTypeRaw) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context),
      body: Stack(
        children: [
          // 1. التوهج الخلفي (Ambient Glows)
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.1,
            child: _buildAmbientGlow(AppTheme.pinkGlow, size.width * 0.7),
          ),
          Positioned(
            bottom: size.height * 0.1,
            left: -size.width * 0.1,
            child: _buildAmbientGlow(AppTheme.greenGlow, size.width * 0.6),
          ),

          // 2. المحتوى الرئيسي القابل للتمرير
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // شارة التحقق بالذكاء الاصطناعي
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user, color: AppTheme.greenGlow, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "تم التحقق بواسطة الذكاء الاصطناعي",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.greenGlow,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // العناوين التوضيحية
                  Text(
                    "تقرير فحص البشرة",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "تم تحليل الصورة المرفقة بنجاح. يرجى مراجعة النتائج أدناه، مع ملاحظة أن هذا التحليل لا يغني عن الاستشارة الطبية المتخصصة.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // كرت الحالة والتشخيص المطور
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(Icons.analytics, "الحالة المكتشفة", AppTheme.pinkGlow),
                        const SizedBox(height: 24),
                        _buildConditionDetails(context, skinTypeArabic),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // كرت الاستشارة الطبية المبدئية
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(Icons.medical_information, "الاستشارة الطبية المبدئية", AppTheme.greenGlow),
                        const SizedBox(height: 24),
                        _buildConsultationDetails(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // كرت نسبة الثقة والدقة
                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildSectionHeader(Icons.insights, "مستوى الثقة", AppTheme.greenGlow, center: true),
                        const SizedBox(height: 24),
                        _buildConfidenceOrb(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // كرت معلومات الطقس والبيئة الخارجية
                  if (scanResult?.temperature != null || scanResult?.humidity != null || scanResult?.cityName != null) ...[
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(Icons.cloud, "معلومات الطقس", AppTheme.greenGlow),
                          const SizedBox(height: 24),
                          _buildWeatherDetails(context),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 24),

                  // زر الإجراء الرئيسي
                  _buildGradientButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // الـ AppBar الزجاجي
  PreferredSizeWidget _buildGlassAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.6),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppTheme.greenGlow),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/camera');
                }
              },
            ),
            title: Text(
              "Dermalyze",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.pinkGlow,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // كرت زجاجي مرن
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 30)],
          ),
          child: child,
        ),
      ),
    );
  }

  // ترويسة الأقسام
  Widget _buildSectionHeader(IconData icon, String title, Color color, {bool center = false}) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
        ),
      ],
    );
    return center ? Center(child: content) : content;
  }

  // تفاصيل كرت النتيجة المعدل لتجنب المشاكل البصرية والـ Overflow
  Widget _buildConditionDetails(BuildContext context, String? skinTypeArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. عرض التاريخ بوضوح في الأعلى
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "تاريخ التحليل",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            Text(
              scanResult?.scanDate ?? "غير محدد",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: Colors.black12, height: 1),
        const SizedBox(height: 16),

        // 2. المحتوى الأفقي (الصورة + التفاصيل الجانبية)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حاوية الصورة ذات أبعاد ثابتة مناسبة للكرت
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: scanResult?.imagePath != null && scanResult!.imagePath.isNotEmpty
                    ? Image.network(
                        scanResult!.fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.camera_alt, color: Colors.grey, size: 30),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // التفاصيل النصية بجانب الصورة (مغلفة بـ Expanded لمنع حدوث الـ Overflow والتفاف الحروف بشكل خاطئ)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // التشخيص المكتشف
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppTheme.pinkGlow.withValues(alpha: 0.15),
                      border: Border.all(color: AppTheme.pinkGlow.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      scanResult?.condition ?? "جاري التحليل...",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // نوع البشرة من ملف المستخدم (يُعرض فقط إن كان محدداً)
                  if (skinTypeArabic != null) ...[
                    Text(
                      "نوع البشرة: $skinTypeArabic",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // مستوى الدقة (من نتيجة التحليل الفعلية)
                  Text(
                    "مستوى الدقة: ${((scanResult?.confidence ?? 0.0) * 100).toInt()}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // صندوق المعلومات الصغير
  Widget _buildInfoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value, 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // الاستشارة الطبية المبدئية
  Widget _buildConsultationDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان بعرض الشاشة الكامل بدون أيقونة جانبية
        const Text(
          "توصيات العناية الفورية",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 12),
        if (scanResult?.consultation != null && scanResult!.consultation!.isNotEmpty)
          Text(
            scanResult!.consultation!,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.normal, // Regular
              fontSize: 14,
              height: 1.7, // تباعد أسطر أوضح
              color: Colors.black87,
            ),
          )
        else ...[
          _buildListItem("التوقف عن استخدام أي منتجات تجميلية أو عطور على المنطقة المصابة."),
          _buildListItem("استخدام مرطب طبي خالي من العطور والمواد المهيجة مرتين يومياً."),
          _buildListItem("تجنب التعرض المباشر لأشعة الشمس واستخدم واقي شمس مناسب."),
        ],
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: const Border(right: BorderSide(color: AppTheme.pinkGlow, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("متى يجب زيارة الطبيب؟", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
              const SizedBox(height: 8),
              Text(
                "إذا لم تتحسن الأعراض خلال 3-5 أيام، يُنصح بحجز موعد مع طبيب جلدية مختص فوراً.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: AppTheme.pinkGlow, fontWeight: FontWeight.bold, fontSize: 18)),
          Expanded(
            child: Text(
              text, 
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // مستوى الدقة (مؤشر الثقة الدائري)
  Widget _buildConfidenceOrb(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.greenGlow.withValues(alpha: 0.3), blurRadius: 40)],
                ),
              ),
              CircularProgressIndicator(
                value: scanResult?.confidence ?? 0.0,
                strokeWidth: 8,
                backgroundColor: Colors.black.withValues(alpha: 0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.greenGlow),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${((scanResult?.confidence ?? 0) * 100).toInt()}%",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.black),
                      textDirection: TextDirection.ltr,
                    ),
                    const Text("دقة التحليل", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "يعتمد مستوى الثقة على وضوح الصورة ومدى تطابق الأعراض مع قاعدة البيانات الطبية الخاصة بنا.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  // زر استشارة خبير
  Widget _buildGradientButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: AppTheme.pinkGlow.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
        gradient: const LinearGradient(colors: [AppTheme.pinkGlow, AppTheme.greenGlow]),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            context.go('/chat');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 48.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "استشارة خبير",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_back, color: Colors.black, size: 24), // متوافق مع الاتجاه العربي RTL
              ],
            ),
          ),
        ),
      ),
    );
  }

  // كرت تفاصيل الطقس
  Widget _buildWeatherDetails(BuildContext context) {
    return Row(
      children: [
        if (scanResult?.cityName != null)
          Expanded(child: _buildInfoBox("المدينة", scanResult!.cityName!)),
        if (scanResult?.cityName != null && (scanResult?.temperature != null || scanResult?.humidity != null))
          const SizedBox(width: 16),
        if (scanResult?.temperature != null)
          Expanded(child: _buildInfoBox("الحرارة", "${scanResult!.temperature!.toStringAsFixed(1)}°")),
        if (scanResult?.temperature != null && scanResult?.humidity != null)
          const SizedBox(width: 16),
        if (scanResult?.humidity != null)
          Expanded(child: _buildInfoBox("الرطوبة", "${scanResult!.humidity!.toStringAsFixed(0)}%")),
      ],
    );
  }

  // الهالات المضيئة الخلفية — تدرّج شعاعي يتلاشى للشفافية لتأثير توهج ناعم.
  // (التركيب السابق كان يضع BackdropFilter داخل حاوية ملوّنة فيُلغى مفعول الـ blur.)
  Widget _buildAmbientGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.35), Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}