import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CutiPage extends StatelessWidget {
  const CutiPage({super.key});

  @override
  Widget build(BuildContext context) {

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
                'Pengajuan Cuti',
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
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
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
                              'Rencanakan Cuti Anda',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Ingin mengajukan Cuti?',
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
                        context.push('/buat-cuti');
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
                        'Ajukan Cuti',
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

            Text(
              'RIWAYAT PENGAJUAN CUTI',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 16.h),

            _buildHistoryCard(
              date: '20 – 22 Okt 2026',
              duration: '3 Hari Kerja',
              submittedDate: 'Diajukan 15 Okt 2026',
              reason: 'Keperluan keluarga di luar kota',
              status: 'Pending',
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            _buildHistoryCard(
              date: '12 – 14 Agu 2026',
              duration: '3 Hari Kerja',
              submittedDate: 'Diajukan 1 Agu 2026',
              reason: 'Acara pernikahan saudara kandung',
              status: 'Disetujui',
              isDark: isDark,
            ),
                    _buildHistoryCard(
                      date: '02 – 03 Jul 2026',
                      duration: '2 Hari Kerja',
                      submittedDate: 'Diajukan 25 Jun 2026',
                      reason: 'Urusan administrasi kependudukan',
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

  // Helper Widget untuk Kartu Riwayat
  Widget _buildHistoryCard({
    required String date,
    required String duration,
    required String submittedDate,
    required String reason,
    required String status,
    required bool isDark,
  }) {
    final bool isApproved = status == 'Disetujui';

    // Konfigurasi warna dinamis berdasarkan status dan tema
    final Color badgeBgColor = isApproved
        ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
        : (isDark ? const Color(0xFF450A0A) : const Color(0xFFFFE4E6));

    final Color badgeTextColor = isApproved
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
        : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFE11D48));

    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color reasonBgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);

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
          // Baris 1: Tanggal dan Badge Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(5.r),
                  border: isDark ? Border.all(
                      color: isApproved ? const Color(0xFF047857) : const Color(0xFF7F1D1D),
                      width: 1.w
                  ) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.check_circle : Icons.circle,
                      color: badgeTextColor,
                      size: 10.w,
                    ),
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

          // Baris 2: Durasi dan Tanggal Pengajuan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, color: textSecondary, size: 14.w),
                  SizedBox(width: 4.w),
                  Text(
                    'Durasi: ',
                    style: TextStyle(fontSize: 12.sp, color: textSecondary),
                  ),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                submittedDate,
                style: TextStyle(fontSize: 11.sp, color: textSecondary),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Baris 3: Kotak Alasan Cuti
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: reasonBgColor,
              borderRadius: BorderRadius.circular(8.r),
              border: isDark ? Border.all(color: const Color(0xFF282828)) : null,
            ),
            child: Row(
              children: [
                Icon(Icons.sort, color: textSecondary, size: 16.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right, color: textSecondary, size: 20.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}