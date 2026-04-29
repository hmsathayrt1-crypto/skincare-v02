import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';

enum SkinType { oily, dry, normal, mixed }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SkinType? _selectedSkinType = SkinType.mixed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // 1. التوهج الخلفي
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.1,
            child: _buildAmbientGlow(const Color(0x80FADADD), size.width * 0.6),
          ),
          Positioned(
            bottom: 0,
            left: -size.width * 0.1,
            child: _buildAmbientGlow(const Color(0x66CFE6C7), size.width * 0.7),
          ),
          
          // 2. المحتوى
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 48),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildSkinTypeCard(),
              const SizedBox(height: 32),
              _buildSaveButton(context),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.7),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu, color: Colors.black)),
      title: const Text("الملف الشخصي", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFFF3E5AB), Colors.white, Color(0xFFF3E5AB)]),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 60,
              backgroundImage: CachedNetworkImageProvider("https://lh3.googleusercontent.com/aida-public/AB6AXuC2AyiHuPeKJbOmvjeIS4YGsACjZiCJX34zNRre8YvwPXK8cKMAsmWC_7zEDUzX0KHf8vinhsJEobX6YMkUUBH_9Ru3zc4ZAenyWRfkEWJ7R7LtA1rat75xqDWBwzZRLDIejxrWWTNGb5S0b1vqjyk0Bs5tqmNk9LY5p-HANK-j4EnstJ0_23T4ySK0Tcop_D1b_QUSjGMW0V8WMSFzGZWKr5wWcTQYQEQ_Y04qXJMT7VbHgqwK2pD4wK0_a6kuNM2eMiOWYUZZ_nM"),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text("سارة أحمد", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        Text("sara.ahmed@example.com", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildGlassCard({required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 12))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildGlassCard(children: [
      const Text("المعلومات الشخصية", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
      const SizedBox(height: 24),
      _buildTextField("الاسم الكامل", "سارة أحمد"),
      const SizedBox(height: 16),
      _buildTextField("البريد الإلكتروني", "sara.ahmed@example.com", isLtr: true),
      const SizedBox(height: 16),
      _buildTextField("رقم الهاتف", "+966 50 123 4567", isLtr: true),
    ]);
  }

  Widget _buildTextField(String label, String value, {bool isLtr = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        TextFormField(
          initialValue: value,
          textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          decoration: InputDecoration(
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.pinkGlow, width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildSkinTypeCard() {
    return _buildGlassCard(children: [
      const Text("نوع البشرة", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
      const SizedBox(height: 8),
      Text(
        "يساعدنا تحديد نوع بشرتك في تقديم توصيات أدق لمنتجات العناية.",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.8)),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChip("دهنية", SkinType.oily, const Color(0xFFDCEDC8), const Color(0xFF8BC34A)),
          _buildChip("جافة", SkinType.dry, const Color(0xFFFFE0B2), const Color(0xFFFF9800)),
          _buildChip("عادية", SkinType.normal, const Color(0xFFE0E0E0), const Color(0xFF9E9E9E)),
          _buildChip("مختلطة", SkinType.mixed, const Color(0xFFE1BEE7), const Color(0xFF9C27B0)),
        ],
      )
    ]);
  }

  Widget _buildChip(String label, SkinType type, Color bgColor, Color borderColor) {
    bool isSelected = _selectedSkinType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedSkinType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppTheme.pinkGlow, width: 2),
                gradient: const LinearGradient(colors: [Color(0xFFF7BAC1), Color(0xFFB8DCA9)]),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              )
            : BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: borderColor),
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) const Icon(Icons.check, size: 18, color: Colors.black),
            if (isSelected) const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [BoxShadow(color: Color(0x80FADADD), blurRadius: 20, offset: Offset(0, 4))],
        gradient: const LinearGradient(colors: [AppTheme.pinkGlow, AppTheme.greenGlow]),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                "حفظ التغييرات",
                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w800),
              ),
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
          colors: [color, Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}