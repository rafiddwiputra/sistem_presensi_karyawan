import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgApp = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color headerBg = isDark ? const Color(0xFF154B8C) : const Color(0xFF1E61B6);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color shadowColor = Colors.black.withValues(alpha: isDark ? 0.3 : 0.03);

    return Scaffold(
      backgroundColor: bgApp,
      body: Stack(
        children: [
          Container(
            height: 260.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  Text(
                    'Profil Karyawan',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Informasi Data Karyawan',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 15.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFBBF24), width: 3.w),
                            color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
                            image: const DecorationImage(
                              // TODO:
                              image: AssetImage('assets/images/placeholder_profil.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Icon(Icons.person, color: isDark ? const Color(0xFF64748B) : Colors.white, size: 40),
                        ),
                        SizedBox(height: 16.h),

                        // Nama & Role
                        Text(
                          'Exclipse',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Full Stack Dev & Database Administrator',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: textSecondary,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8.r),
                                border: isDark ? Border.all(color: const Color(0xFF1E40AF)) : null,
                              ),
                              child: Text(
                                'ID: FK-002',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8.r),
                                border: isDark ? Border.all(color: const Color(0xFF047857)) : null,
                              ),
                              child: Text(
                                'Intern Aktif',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // --- CARD 2: MENU NAVIGASI ---
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 15.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          iconBgColor: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFEFF6FF),
                          iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
                          title: 'Edit Profil',
                          subtitle: 'Ubah data diri dan kontak',
                          isDark: isDark,
                          onTap: () {
                            context.push('/edit-profil');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          iconBgColor: isDark ? const Color(0xFF4C1D95).withValues(alpha: 0.5) : const Color(0xFFF3E8FF),
                          iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA),
                          title: 'Ubah Password',
                          subtitle: 'Keamanan akun & kata sandi',
                          isDark: isDark,
                          onTap: () {
                            context.push('/ubah-password');
                          },
                        ),
                        _buildDivider(isDark),
                        _buildMenuItem(
                          icon: Icons.calendar_today_outlined,
                          iconBgColor: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFECFDF5),
                          iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981),
                          title: 'Riwayat Presensi',
                          subtitle: 'Lihat log kehadiran',
                          isDark: isDark,
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_none_outlined,
                          iconBgColor: isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFFFBEB),
                          iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
                          title: 'Notifikasi',
                          subtitle: 'Pemberitahuan aplikasi',
                          isDark: isDark,
                          onTap: () {
                            context.push('/notifikasi');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          iconBgColor: isDark ? const Color(0xFF282828) : const Color(0xFFF8FAFC),
                          iconColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          title: 'Pengaturan',
                          subtitle: 'Bahasa, tema, dan preferensi',
                          isDark: isDark,
                          onTap: () {
                            context.push('/pengaturan');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // --- CARD 3: TOMBOL LOGOUT ---
                  GestureDetector(
                    onTap: () {
                      // TODO: Implementasi logika logout
                      // context.go('/login');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                            color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
                            width: 1.w
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444), size: 24.sp),
                          SizedBox(width: 16.w),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: isDark ? const Color(0xFFB91C1C) : const Color(0xFFFCA5A5), size: 24.sp),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  Text(
                    'Sistem Presensi Karyawan',
                    style: TextStyle(fontSize: 12.sp, color: textSecondary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Build 1.0.0 (Yogyakarta)',
                    style: TextStyle(fontSize: 12.sp, color: textSecondary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Dilindungi Hak Cipta',
                    style: TextStyle(fontSize: 12.sp, color: textSecondary),
                  ),

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        child: Row(
          children: [

            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),
            SizedBox(width: 16.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1), size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Divider(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9),
        thickness: 1.5.h,
        height: 0,
      ),
    );
  }
}