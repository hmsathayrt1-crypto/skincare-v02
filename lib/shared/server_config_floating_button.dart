import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/dio_client.dart';
import '../core/router/app_router.dart';

/// زر عائم شامل لإعدادات الاتصال بالسيرفر
class ServerConfigFloatingButton extends StatefulWidget {
  const ServerConfigFloatingButton({super.key});

  @override
  State<ServerConfigFloatingButton> createState() => _ServerConfigFloatingButtonState();
}

class _ServerConfigFloatingButtonState extends State<ServerConfigFloatingButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // نستخدم Directionality للتأكد من الاتجاه الصحيح (RTL) للغة العربية
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        type: MaterialType.transparency,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedScale(
            scale: _isHovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: GestureDetector(
              onTap: () => _showSettingsDialog(),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFADADD), // pinkGlow
                      Color(0xFFB2C9AB), // greenGlow
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.settings_ethernet,
                  color: Color(0xFF1B1C1C), // onSurface
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'إغلاق',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const ServerConfigDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// نافذة إعدادات الاتصال بالخادم
class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  final TextEditingController _ipPortController = TextEditingController();
  List<String> _history = [];
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _ipPortController.dispose();
    super.dispose();
  }

  // تحميل الإعدادات وتاريخ العناوين
  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final currentIpPort = prefs.getString('server_ip_port') ?? '127.0.0.1:80';
    final history = prefs.getStringList('server_ip_history') ?? ['127.0.0.1:80'];

    setState(() {
      _ipPortController.text = currentIpPort;
      _history = history;
    });
  }

  // حفظ الإعدادات الحالية وتاريخ العناوين
  Future<void> _saveConfig() async {
    final newIpPort = _ipPortController.text.trim();
    if (newIpPort.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip_port', newIpPort);

    // إضافة العنوان إلى التاريخ إن لم يكن موجوداً
    if (!_history.contains(newIpPort)) {
      _history.insert(0, newIpPort);
      // تقييد التاريخ بآخر 5 عناوين
      if (_history.length > 5) {
        _history = _history.sublist(0, 5);
      }
      await prefs.setStringList('server_ip_history', _history);
    }

    // تحديث الإعدادات النشطة
    ApiEndpoints.serverIpPort = newIpPort;
    DioClient().dio.options.baseUrl = ApiEndpoints.baseUrl;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ إعدادات خادم الاتصال بنجاح: $newIpPort',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFB2C9AB), // greenGlow
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  // اختبار الاتصال بالباك إند
  Future<void> _testConnection() async {
    final targetIpPort = _ipPortController.text.trim();
    if (targetIpPort.isEmpty) {
      setState(() {
        _testResult = 'الرجاء إدخال عنوان IP والمنفذ (Port)';
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    // إنشاء رابط اختبار مبني على العنوان المدخل
    final testUrl = 'http://$targetIpPort/backend/index.php';

    try {
      final dioTemp = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));

      final response = await dioTemp.get(testUrl);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['status'] == 'success') {
          setState(() {
            _testResult = 'تم الاتصال بنجاح! الباك إند يعمل ✅';
            _testSuccess = true;
          });
        } else {
          setState(() {
            _testResult = 'تم الاتصال بالخادم، لكن الباك إند أعاد استجابة غير متوقعة.';
            _testSuccess = false;
          });
        }
      } else {
        setState(() {
          _testResult = 'فشل الاتصال: كود الحالة ${response.statusCode}';
          _testSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'فشل الاتصال بالخادم. تأكد من تشغيل XAMPP والعنوان المكتوب.';
        _testSuccess = false;
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9F9).withValues(alpha: 0.95), // background
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // العنوان
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFADADD), // pinkGlow
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings_ethernet, color: Color(0xFF1B1C1C)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'إعدادات اتصال الخادم',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B1C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // حقل الإدخال
                  Text(
                    'عنوان السيرفر (IP:PORT)',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4F4445),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ipPortController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      hintText: 'مثال: 127.0.0.1:80',
                      hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.link, size: 20),
                      suffixIcon: _history.isNotEmpty
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              onSelected: (String value) {
                                setState(() {
                                  _ipPortController.text = value;
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return _history.map((String value) {
                                  return PopupMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.tajawal(),
                                    ),
                                  );
                                }).toList();
                              },
                            )
                          : null,
                    ),
                    style: GoogleFonts.tajawal(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // تاريخ العناوين السابقة السريعة
                  if (_history.isNotEmpty) ...[
                    Text(
                      'العناوين السابقة:',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _history.map((ip) {
                        final isActive = _ipPortController.text == ip;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _ipPortController.text = ip;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFB2C9AB).withValues(alpha: 0.3) // active greenGlow
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive
                                    ? const Color(0xFFB2C9AB)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              ip,
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive
                                    ? const Color(0xFF1B1C1C)
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // نتيجة اختبار الاتصال
                  if (_testResult != null) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _testSuccess
                            ? const Color(0xFFB2C9AB).withValues(alpha: 0.15)
                            : const Color(0xFFFADADD).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _testSuccess
                              ? const Color(0xFFB2C9AB)
                              : const Color(0xFFFADADD),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _testSuccess ? Icons.check_circle : Icons.error,
                            color: _testSuccess
                                ? const Color(0xFF3B7A57)
                                : const Color(0xFFD32F2F),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _testResult!,
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: _testSuccess
                                    ? const Color(0xFF1B1C1C)
                                    : const Color(0xFF1B1C1C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // أزرار العمليات
                  Row(
                    children: [
                      // زر اختبار الاتصال
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isTesting ? null : _testConnection,
                          icon: _isTesting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                  ),
                                )
                              : const Icon(Icons.flash_on, size: 18),
                          label: Text(
                            _isTesting ? 'جاري الفحص...' : 'اختبار الاتصال',
                            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1B1C1C),
                            side: const BorderSide(color: Color(0xFF4F4445)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // زر حفظ
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveConfig,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB2C9AB), // greenGlow
                            foregroundColor: const Color(0xFF1B1C1C),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'حفظ العنوان',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // زر إلغاء
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4F4445),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'إلغاء',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
