import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'buat_izin_page.dart';

class IzinPage extends StatelessWidget {
  const IzinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color headerBlue = isDark ? const Color(0xFF154B8C) : const Color(0xFF1961B6);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color bgApp = Theme.of(context).scaffoldBackgroundColor;

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
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Izin Anda',
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
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E1E1E), const Color(0xFF12243E)]
                      : [Colors.white, const Color(0xFFEFF6FF)],
                ),
                boxShadow: [
                  BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF1961B6).withValues(alpha: 0.05),
                      blurRadius: 20.r,
                      offset: Offset(0, 4.h)
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
                          color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.description_outlined, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 24.w),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Butuh izin?', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                            SizedBox(height: 4.h),
                            Text('Ajukan izin dan pantau status perizinan Anda.', style: TextStyle(fontSize: 12.sp, color: textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BuatIzinPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.add, color: Colors.white, size: 20.w),
                      label: Text('Buat surat izin', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            Text(
              'RIWAYAT PENGAJUAN IZIN',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 0.5),
            ),
            SizedBox(height: 16.h),

            _buildMonthHeader('September', textPrimary),
            _buildHistoryCard(
              title: 'Izin Sakit karena Dema...',
              date: '28 - 29 September 2026',
              duration: '1 Hari',
              type: 'surat dokter',
              status: 'Pending',
              isPending: true,
              isDark: isDark,
            ),
            _buildHistoryCard(
              title: 'Izin Sakit Flu',
              date: '3 - 4 September 2026',
              duration: '1 Hari',
              type: 'surat dokter',
              status: 'Disetujui',
              isPending: false,
              isDark: isDark,
            ),

            SizedBox(height: 8.h),

            _buildMonthHeader('Agustus', textPrimary),
            _buildHistoryCard(
              title: 'Izin Sakit Diare',
              date: '28 - 29 Agustus 2026',
              duration: '1 Hari',
              type: 'surat dokter',
              status: 'Disetujui',
              isPending: false,
              isDark: isDark,
            ),
            _buildHistoryCard(
              title: 'Izin Sakit Pusing Kepala',
              date: '3 - 4 Agustus 2026',
              duration: '1 Hari',
              type: 'surat dokter',
              status: 'Disetujui',
              isPending: false,
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


  Widget _buildMonthHeader(String month, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
      child: Text(
        month,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String date,
    required String duration,
    required String type,
    required String status,
    required bool isPending,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 10.r,
              offset: Offset(0, 2.h)
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle
            ),
            child: Icon(Icons.mail_outline, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), size: 24.w),
          ),
          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: TextStyle(fontSize: 12.sp, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),

                Row(
                  children: [
                    _buildTag(duration, isDark),
                    SizedBox(width: 8.w),
                    _buildTag(type, isDark),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isPending
                  ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
                  : (isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4)),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                  color: isPending
                      ? (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA))
                      : (isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0)),
                  width: 1.w
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 3.r,
                  backgroundColor: isPending
                      ? (isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444))
                      : (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981)),
                ),
                SizedBox(width: 6.w),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isPending
                        ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444))
                        : (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)
        ),
      ),
    );
  }
}