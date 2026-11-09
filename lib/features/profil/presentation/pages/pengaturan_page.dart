import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sistem_presensi_karyawan/app/theme/theme_notifier.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  // State untuk Toggle Notifikasi
  bool _isPengingatPresensi = true;
  bool _isInfoIzinCuti = true;

  // State untuk Toggle Tampilan
  bool _isDarkMode = false;
  bool _isLightMode = true;

  // Fungsi untuk mengatur logika Tampilan
  void _setDarkMode(bool value) {
    if (value) {
      setState(() {
        _isDarkMode = true;
        _isLightMode = false;
      });
      ThemeNotifier.setDarkMode();
    }
  }

  void _setLightMode(bool value) {
    if (value) {
      setState(() {
        _isLightMode = true;
        _isDarkMode = false;
      });
      ThemeNotifier.setLightMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kunci utama: Mendeteksi apakah saat ini sedang Dark Mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            color: const Color(0xFF1E61B6),
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
                  'Pengaturan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. Area Konten Scrollable
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: NOTIFIKASI ---
                  _buildSectionHeader('NOTIFIKASI', isDark),
                  Container(
                    decoration: _cardDecoration(isDark),
                    child: Column(
                      children: [
                        _buildToggleItem(
                          icon: Icons.alarm,
                          title: 'Pengingat Presensi',
                          subtitle: 'Pengingat masuk dan pulang kerja',
                          value: _isPengingatPresensi,
                          onChanged: (val) =>
                              setState(() => _isPengingatPresensi = val),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildToggleItem(
                          icon: Icons.calendar_today_outlined,
                          title: 'Informasi Izin dan Cuti',
                          subtitle: 'Pembaruan status pengajuan',
                          value: _isInfoIzinCuti,
                          onChanged: (val) =>
                              setState(() => _isInfoIzinCuti = val),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // --- SECTION 2: TAMPILAN ---
                  _buildSectionHeader('TAMPILAN', isDark),
                  Container(
                    decoration: _cardDecoration(isDark),
                    child: Column(
                      children: [
                        _buildToggleItem(
                          isIconBlank: true,
                          title: 'Dark Mode',
                          subtitle: 'Mode Gelap',
                          value: _isDarkMode,
                          onChanged: _setDarkMode,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildToggleItem(
                          isIconBlank: true,
                          title: 'Light Mode',
                          subtitle: 'Mode Terang',
                          value: _isLightMode,
                          onChanged: _setLightMode,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // --- SECTION 3: KEAMANAN ---
                  _buildSectionHeader('KEAMANAN', isDark),
                  Container(
                    decoration: _cardDecoration(isDark),
                    child: _buildNavigationItem(
                      icon: Icons.shield_outlined,
                      title: 'Keamanan Akun',
                      subtitle: 'Kelola keamanan akunmu',
                      onTap: () {},
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // --- SECTION 4: INFORMASI ---
                  _buildSectionHeader('INFORMASI', isDark),
                  Container(
                    decoration: _cardDecoration(isDark),
                    child: Column(
                      children: [
                        _buildNavigationItem(
                          icon: Icons.help_outline,
                          title: 'Tim Developer',
                          subtitle: 'Pengembang Sistem',
                          onTap: () {},
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildNavigationItem(
                          icon: Icons.info_outline,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Ketentuan layanan dan kebijakan',
                          onTap: () {},
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // --- FOOTER ---
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF282828)
                                : const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Sistem Presensi Karyawan',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Versi x.x.x (Build xxxx.xx)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'In Comming',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS DENGAN DUKUNGAN DARK MODE ---

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
          blurRadius: 15.r,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9),
        thickness: 1.5.h,
        height: 0,
      ),
    );
  }

  Widget _buildToggleItem({
    IconData? icon,
    bool isIconBlank = false,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF282828) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: isIconBlank
                ? null
                : Icon(
                    icon,
                    color: isDark
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF1D4ED8),
                    size: 22.sp,
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: value,
              activeTrackColor: const Color(0xFF1E61B6),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF282828)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isDark
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFF1D4ED8),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}
