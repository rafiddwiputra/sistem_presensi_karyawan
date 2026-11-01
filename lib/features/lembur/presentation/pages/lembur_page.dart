import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LemburPage extends StatelessWidget {
  const LemburPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis
    final Color bgApp = Theme.of(context).scaffoldBackgroundColor;
    final Color primaryBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF135CAE);
    final Color headerBlue = isDark ? const Color(0xFF154B8C) : const Color(0xFF135CAE);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
        backgroundColor: headerBlue,
        body: SafeArea(
          bottom: false,
          child: Column(
              children: [
          Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Text(
                'Pengajuan Lembur',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgApp,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                            blurRadius: 15.r,
                            offset: Offset(0, 5.h),
                          ),
                        ],
                      ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.timer_outlined,
                          color: isDark ? const Color(0xFF60A5FA) : primaryBlue,
                          size: 24.w,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rencanakan Lembur Anda',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Ingin merencanakan untuk Lembur?',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/buat-lembur');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.add, color: Colors.white, size: 20.w),
                      label: Text(
                        'Ajukan Lembur',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // --- JUDUL SEKSI RIWAYAT ---
            Text(
              'RIWAYAT PENGAJUAN LEMBUR',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 16.h),

            // --- DAFTAR RIWAYAT KARTU ---
            _buildHistoryCard(
              date: 'Jumat, 24 Okt 2026',
              timeRange: '04:00 – 05:00 WIB',
              duration: '1 Jam',
              description: 'Penyelesaian deployment modul e-presensi dan bug fixing integrasi API sprint 4.',
              status: 'Menunggu',
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            _buildHistoryCard(
              date: 'Selasa, 20 Okt 2026',
              timeRange: '04:00 – 20:00 WIB',
              duration: '4 Jam',
              description: 'Support maintenance server rutin bulanan dan monitoring backup database.',
              status: 'Disetujui',
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            _buildHistoryCard(
              date: 'Kamis, 15 Okt 2026',
              timeRange: '04:00 – 21:00 WIB',
              duration: '5 Jam',
              description: 'Mempersiapkan materi presentasi dan demo sprint review kepada klien.',
              status: 'Disetujui',
              isDark: isDark,
            ),
                  ],
                ),
              ),
            ),
        ),
              ],
          ),
        ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String timeRange,
    required String duration,
    required String description,
    required String status,
    required bool isDark,
  }) {
    final bool isApproved = status == 'Disetujui';

    final Color badgeBgColor = isApproved
        ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
        : (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7));

    final Color badgeTextColor = isApproved
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
        : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706));

    final Color badgeDotColor = badgeTextColor;

    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color iconColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);

    final Color timeRangeBg = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color durationBg = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFDBEAFE);
    final Color durationText = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
    final Color descriptionText = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16.w, color: iconColor),
                  SizedBox(width: 8.w),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(5.r),
                  border: isDark ? Border.all(
                      color: isApproved ? const Color(0xFF047857) : const Color(0xFF92400E),
                      width: 1.w
                  ) : null,
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: badgeDotColor, size: 8.w),
                    SizedBox(width: 4.w),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Baris 2: Waktu Lembur & Durasi
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: timeRangeBg,
                  borderRadius: BorderRadius.circular(5.r),
                  border: isDark ? Border.all(color: const Color(0xFF282828)) : null,
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14.w, color: textSecondary),
                    SizedBox(width: 6.w),
                    Text(
                      timeRange,
                      style: TextStyle(fontSize: 12.sp, color: descriptionText),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: durationBg,
                  borderRadius: BorderRadius.circular(5.r),
                  border: isDark ? Border.all(color: const Color(0xFF1E3A8A)) : null,
                ),
                child: Text(
                  duration,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: durationText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Baris 3: Deskripsi & Ikon Chevron
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: descriptionText,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right, color: textSecondary, size: 20.w),
            ],
          ),
        ],
      ),
    );
  }
}