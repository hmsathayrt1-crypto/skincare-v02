import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';

enum SkinType { oily, dry, normal, mixed }

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  SkinType? _selectedSkinType = SkinType.mixed;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _controllersPopulated = false;

  @override
  void initState() {
    super.initState();
    _populateControllers();
  }

  void _populateControllers() {
    final user = ref.read(authProvider).user;
    if (user != null && !_controllersPopulated) {
      _nameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      if (user.skinType != null) {
        _selectedSkinType = _skinTypeFromString(user.skinType!);
      }
      _controllersPopulated = true;
    }
  }

  SkinType? _skinTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'oily':
      case 'دهنية':
        return SkinType.oily;
      case 'dry':
      case 'جافة':
        return SkinType.dry;
      case 'normal':
      case 'عادية':
        return SkinType.normal;
      case 'mixed':
      case 'combination':
      case 'مختلطة':
        return SkinType.mixed;
      default:
        return null;
    }
  }

  String _skinTypeToString(SkinType? type) {
    switch (type) {
      case SkinType.oily:
        return 'oily';
      case SkinType.dry:
        return 'dry';
      case SkinType.normal:
        return 'normal';
      case SkinType.mixed:
        return 'combination';
      default:
        return 'combination';
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final updatedUser = await _authService.updateProfile({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'skin_type': _skinTypeToString(_selectedSkinType),
      });
      ref.read(authProvider.notifier).updateUser(updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحفظ: $errorStr'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'إعادة',
              textColor: Colors.white,
              onPressed: _saveProfile,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = ref.watch(authProvider).user;

    // Re-populate if user data arrives after build
    if (user != null && !_controllersPopulated) {
      _populateControllers();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      drawer: _buildNavigationDrawer(context),
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
              _buildAvatarSection(user),
              const SizedBox(height: 48),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildSkinTypeCard(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 16),
              _buildLogoutButton(),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      elevation: 0,
      centerTitle: true,
      // Builder لإعطاء context تحت الـ Scaffold حتى يعمل openDrawer
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Colors.black),
        ),
      ),
      title: const Text("الملف الشخصي", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () => _showSettingsDialog(context),
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

  /// قائمة جانبية تحتوي جميع الواجهات المتاحة
  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F0F0)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ترويسة القائمة
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.pinkGlow, AppTheme.greenGlow]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.face_retouching_natural, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    ref.watch(authProvider).user?.fullName ?? 'المستخدم',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    ref.watch(authProvider).user?.email ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildDrawerItem(context, Icons.smart_toy_outlined, 'المحادثة الذكية', '/chat'),
            _buildDrawerItem(context, Icons.center_focus_strong, 'فحص البشرة', '/camera'),
            _buildDrawerItem(context, Icons.history, 'سجل النتائج', '/history'),
            _buildDrawerItem(context, Icons.person_outline, 'الملف الشخصي', '/profile'),
            const Divider(indent: 20, endIndent: 20),
            _buildDrawerItem(context, Icons.lightbulb_outline, 'نصائح يومية', null, onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('💡 نصائح يومية - قريباً')),
              );
            }),
            _buildDrawerItem(context, Icons.info_outline, 'حول التطبيق', null, onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Dermalyze',
                applicationVersion: '1.0.0',
                applicationLegalese: 'نظام تحليل البشرة بالذكاء الاصطناعي',
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String? route, {VoidCallback? onTap}) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isActive = route != null && currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppTheme.greenGlow : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          color: isActive ? AppTheme.greenGlow : Colors.black87,
        ),
      ),
      trailing: isActive ? const Icon(Icons.check_circle, color: AppTheme.greenGlow, size: 20) : null,
      onTap: onTap ?? () {
        Navigator.pop(context); // إغلاق القائمة
        if (route != null && !isActive) {
          context.go(route);
        }
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.black),
            SizedBox(width: 12),
            Text('الإعدادات'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('الإشعارات'),
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('الوضع الداكن'),
              trailing: Switch(value: false, onChanged: (v) {}),
            ),
            const ListTile(
              leading: Icon(Icons.language),
              title: Text('اللغة'),
              trailing: Text('العربية'),
            ),
            const ListTile(
              leading: Icon(Icons.storage),
              title: Text('إدارة البيانات'),
              trailing: Icon(Icons.chevron_left),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(UserModel? user) {
    final displayName = user?.fullName ?? 'المستخدم';
    final displayEmail = user?.email ?? '';

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
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.pinkGlow.withValues(alpha: 0.3),
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(displayEmail, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black.withValues(alpha: 0.7))),
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
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 12))],
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
      _buildTextField("الاسم الكامل", _nameController, isLtr: false),
      const SizedBox(height: 16),
      _buildTextField("البريد الإلكتروني", _emailController, isLtr: true),
      const SizedBox(height: 16),
      _buildTextField("رقم الهاتف", _phoneController, isLtr: true),
    ]);
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isLtr = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        TextFormField(
          controller: controller,
          textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          decoration: const InputDecoration(
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.pinkGlow, width: 2)),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
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
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black.withValues(alpha: 0.8)),
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

  Widget _buildSaveButton() {
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
          onTap: _isLoading ? null : _saveProfile,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                    )
                  : const Text(
                      "حفظ التغييرات",
                      style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: Colors.red, size: 22),
        label: const Text(
          'تسجيل الخروج',
          style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: Colors.red, width: 1.5),
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
