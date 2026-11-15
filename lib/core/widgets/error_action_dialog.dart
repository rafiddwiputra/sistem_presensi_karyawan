import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String retryText;
  final String closeText;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorActionDialog({
    super.key,
    required this.title,
    required this.message,
    this.retryText = 'Coba Lagi',
    this.closeText = 'Tutup',
    this.onRetry,
    this.icon,
  });

  static Future<void> show(
      BuildContext context, {
        String title = 'Gagal Menyimpan Perubahan',
        required String message,
        String retryText = 'Coba Lagi',
        String closeText = 'Tutup',
        VoidCallback? onRetry,
        IconData? icon,
        bool barrierDismissible = false,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => ErrorActionDialog(
        title: title,
        message: message,
        retryText: retryText,
        closeText: closeText,
        onRetry: onRetry,
        icon: icon,
      ),
    );
  }

  IconData _resolveIcon() {
    if (icon != null) return icon!;
    final lower = message.toLowerCase();
    if (lower.contains('koneksi') ||
        lower.contains('server') ||
        lower.contains('internet') ||
        lower.contains('timeout')) {
      return Icons.cloud_off_rounded;
    }
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor =
    isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color primaryBlue =
    isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);
    final Color errorColor =
    isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    final Color errorBg = isDark
        ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
        : const Color(0xFFFEE2E2);

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: isDark ? BorderSide(color: borderColor) : BorderSide.none,
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: errorBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _resolveIcon(),
                color: errorColor,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        closeText,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRetry!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          retryText,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}