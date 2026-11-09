import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LemburBerhasilPage extends StatelessWidget {
  const LemburBerhasilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis
    final Color bgApp = Theme.of(context).scaffoldBackgroundColor;
    final Color primaryBlue = isDark
        ? const Color(0xFF3B82F6)
        : const Color(0xFF135CAE);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE2E8F0);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgApp,

        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(color: bgApp),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/beranda');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.home_filled, color: Colors.white, size: 20.w),
                label: Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 1. ILUSTRASI SUKSES ---
                _buildSuccessIllustration(isDark),
                SizedBox(height: 20.h),

                // --- 2. TEKS JUDUL & SUBJUDUL ---
                Text(
                  'Pengajuan Lembur Berhasil',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Pengajuan lembur Anda berhasil dikirim',
                  style: TextStyle(fontSize: 14.sp, color: textSecondary),
                ),
                SizedBox(height: 32.h),

                // --- 3. KARTU STATUS PENGAJUAN ---
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: isDark ? Border.all(color: borderColor) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.02,
                        ),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('STATUS PENGAJUAN', style: _labelStyle(isDark)),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Divider(color: borderColor, height: 1.h),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF451A03)
                                  : const Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.schedule,
                              color: isDark
                                  ? const Color(0xFFFBBF24)
                                  : const Color(0xFFF59E0B),
                              size: 18.w,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Menunggu Verifikasi Admin',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // --- 4. KARTU RINGKASAN PENGAJUAN ---
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: isDark ? Border.all(color: borderColor) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.02,
                        ),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Ringkasan
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 18.w,
                            color: primaryBlue,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'RINGKASAN PENGAJUAN',
                            style: _labelStyle(isDark),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E3A8A)
                                        .withValues(alpha: 0.3)
                                  : const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '4 Jam',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF60A5FA)
                                    : primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      _buildDetailRow(
                        'Pemohon Lembur',
                        'Rafid Dwi Putra Andino',
                        isDark,
                      ),
                      _buildDetailRow('Tanggal Lembur', '24 Okt 2026', isDark),
                      _buildDetailRow(
                        'Waktu Lembur',
                        '18:00 – 21:30 WIB',
                        isDark,
                      ),

                      SizedBox(height: 8.h),
                      Text(
                        'Alasan lembur:',
                        style: TextStyle(fontSize: 12.sp, color: textSecondary),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF121212)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF282828)
                                : const Color(0xFFF1F5F9),
                          ),
                        ),
                        child: Text(
                          '“Deployment Project Laravel & Konfigurasi Server”',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  TextStyle _labelStyle(bool isDark) {
    return TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.bold,
      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
      letterSpacing: 0.5,
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIllustration(bool isDark) {
    return SizedBox(
      height: 140.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF064E3B)
                  : const Color(0xFFD1FAE5).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Icon(Icons.check, color: Colors.white, size: 36.w),
          ),
          Positioned(
            top: 10.h,
            right: 30.w,
            child: Icon(
              Icons.circle,
              color: isDark ? const Color(0xFF34D399) : const Color(0xFF34D399),
              size: 8.w,
            ),
          ),
          Positioned(
            bottom: 15.h,
            left: 30.w,
            child: Icon(
              Icons.circle,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF60A5FA),
              size: 10.w,
            ),
          ),
          Positioned(
            bottom: 5.h,
            right: 40.w,
            child: Icon(
              Icons.circle,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF6EE7B7),
              size: 6.w,
            ),
          ),
          Positioned(
            top: 25.h,
            left: 20.w,
            child: Icon(
              Icons.circle,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF38BDF8),
              size: 8.w,
            ),
          ),
        ],
      ),
    );
  }
}
