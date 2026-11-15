import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RiwayatErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  const RiwayatErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 36.sp,
            color: const Color(0xFFDC2626),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: textSecondary),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class RiwayatEmptyCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isDark;

  const RiwayatEmptyCard({
    super.key,
    required this.message,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40.sp, color: textSecondary),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: textSecondary),
          ),
        ],
      ),
    );
  }
}