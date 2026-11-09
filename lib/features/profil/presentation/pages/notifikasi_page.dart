import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis Latar Belakang
    final Color bgApp = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8FAFC);
    final Color headerBg = isDark
        ? const Color(0xFF154B8C)
        : const Color(0xFF1E61B6);
    final Color sectionTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgApp,
      body: Column(
        children: [
          // 1. Custom App Bar Solid Blue
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              bottom: 16.h,
              left: 20.w,
              right: 20.w,
            ),
            color: headerBg,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. Area List Notifikasi (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION: HARI INI ---
                  Text(
                    'HARI INI',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: sectionTextColor,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Item 1: Presensi Masuk
                  _buildNotificationItem(
                    isDark: isDark,
                    icon: Icons.check_circle,
                    iconBgColor: isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                        : const Color(0xFFCCFBF1),
                    iconColor: isDark
                        ? const Color(0xFF2DD4BF)
                        : const Color(0xFF0F766E),
                    title: 'Presensi Masuk Berhasil',
                    time: '08.02',
                    description: 'Presensi masuk Anda hari ini berhasil dicatat pada pukul 08.02 WIB di Kantor CROG INTERNATIONAL.',
                    isUnread: true,
                    badgeText: 'Presensi Valid',
                    badgeBgColor: isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                        : const Color(0xFFCCFBF1),
                    badgeTextColor: isDark
                        ? const Color(0xFF2DD4BF)
                        : const Color(0xFF0F766E),
                  ),
                  SizedBox(height: 16.h),

                  // Item 2: Presensi Pulang
                  _buildNotificationItem(
                    isDark: isDark,
                    icon: Icons.check_circle,
                    iconBgColor: isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                        : const Color(0xFFCCFBF1),
                    iconColor: isDark
                        ? const Color(0xFF2DD4BF)
                        : const Color(0xFF0F766E),
                    title: 'Presensi Pulang Berhasil',
                    time: '16.30',
                    description: 'Presensi pulang Anda hari ini berhasil dicatat pada pukul 16.30 WIB menggunakan mesin presensi.',
                    isUnread: true,
                    badgeText: 'Biometrik Terverifikasi',
                    badgeBgColor: isDark
                        ? const Color(0xFF312E81).withValues(alpha: 0.4)
                        : const Color(0xFFE0E7FF),
                    badgeTextColor: isDark
                        ? const Color(0xFF818CF8)
                        : const Color(0xFF4338CA),
                    badgeIcon: Icons.fingerprint,
                  ),
                  SizedBox(height: 28.h),

                  // --- SECTION: SEBELUMNYA ---
                  Text(
                    'SEBELUMNYA',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: sectionTextColor,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Item 3: Pengajuan Izin Cuti
                  _buildNotificationItem(
                    isDark: isDark,
                    icon: Icons.calendar_today_outlined,
                    iconBgColor: isDark
                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                        : const Color(0xFFEFF6FF),
                    iconColor: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    title: 'Pengajuan Izin Cuti',
                    time: '24/09/2026',
                    description: 'Pengajuan izin sakit Anda untuk tanggal 28-29 Sep telah disetujui oleh Pembimbing Magang.',
                    badgeText: 'Disetujui',
                    badgeBgColor: isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                        : const Color(0xFFCCFBF1),
                    badgeTextColor: isDark
                        ? const Color(0xFF2DD4BF)
                        : const Color(0xFF0F766E),
                    badgeIcon: Icons.verified_outlined,
                  ),
                  SizedBox(height: 16.h),

                  // Item 4: Pengajuan Izin Lembur
                  _buildNotificationItem(
                    isDark: isDark,
                    icon: Icons.description_outlined,
                    iconBgColor: isDark
                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                        : const Color(0xFFEFF6FF),
                    iconColor: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    title: 'Pengajuan Izin Lembur',
                    time: '20/09/2026',
                    description: 'Pengajuan lembur Anda untuk tanggal 20 September telah disetujui oleh Admin.',
                    badgeText: 'Disetujui Admin',
                    badgeBgColor: isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                        : const Color(0xFFCCFBF1),
                    badgeTextColor: isDark
                        ? const Color(0xFF2DD4BF)
                        : const Color(0xFF0F766E),
                    badgeIcon: Icons.verified_outlined,
                  ),

                  SizedBox(height: 32.h), // Spasi lega di bawah
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk membangun Card Notifikasi
  Widget _buildNotificationItem({
    required bool isDark,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String time,
    required String description,
    bool isUnread = false,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    IconData? badgeIcon,
  }) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color descColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color timeColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);
    final Color unreadDotColor = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF2563EB);
    final Color borderColor = isDark
        ? const Color(0xFF333333)
        : Colors.transparent;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: isDark ? Border.all(color: borderColor) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 15.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon Kiri
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),

          // Konten Kanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Judul & Waktu)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12.sp, color: timeColor),
                    ),
                    // Indikator Titik Biru (Unread)
                    if (isUnread) ...[
                      SizedBox(width: 6.w),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: unreadDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ] else ...[
                      // Penyeimbang margin jika tidak ada titik biru
                      SizedBox(width: 14.w),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),

                // Deskripsi
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: descColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),

                // Badge Status
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeIcon != null) ...[
                        Icon(badgeIcon, color: badgeTextColor, size: 14.sp),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: badgeTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
