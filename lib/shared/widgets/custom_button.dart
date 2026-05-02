import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// ويدجت زر مخصص قابل لإعادة الاستخدام
/// يدعم الوضع المتدرج والوضع المخطط والتحميل
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.gradientStart,
    this.gradientEnd,
    this.borderRadius = 50,
    this.verticalPadding = 16,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isOutlined;
  final Color? gradientStart;
  final Color? gradientEnd;
  final double borderRadius;
  final double verticalPadding;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) return _buildOutlined(context);
    return _buildGradient(context);
  }

  /// الزر المتدرج مع الظل والتوهج
  Widget _buildGradient(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (gradientStart ?? AppTheme.pinkGlow).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientStart ?? AppTheme.pinkGlow,
            gradientEnd ?? AppTheme.greenGlow,
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: isLoading ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.black,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (icon != null) ...[
                          const SizedBox(width: 8),
                          Icon(icon, color: Colors.black, size: 24),
                        ] else ...[
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 24,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// الزر المخطط
  Widget _buildOutlined(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE2E3E1)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator.adaptive()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.black, size: 24),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
