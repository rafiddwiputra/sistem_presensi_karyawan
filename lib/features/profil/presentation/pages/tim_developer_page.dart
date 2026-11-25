import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TimDeveloperPage extends StatelessWidget {
  const TimDeveloperPage({super.key});

  static const List<_DeveloperMember> _developers = [
    _DeveloperMember(
      name: 'Rafid Dwi Putra Andino',
      role: 'Mobile Developer & Web Panel Karyawan & PRD System',
      division: 'Teknologi Informasi • Politeknik Negeri Madiun',
      initials: 'RD',
      photoAsset: 'assets/images/foto-rafid.jpg',
      accentColor: Color(0xFF1E61B6),
    ),
    _DeveloperMember(
      name: 'Rizal',
      role: 'Tim Backend ( Web Admin & Web Karyawan',
      division: 'Teknologi Informasi | Politeknik Negeri Madiun',
      initials: 'RIZAL',
      accentColor: Color(0xFF0F766E),
    ),
    _DeveloperMember(
      name: 'Bimo Elang Tatasrinunci',
      role: 'Tim Backend ( Web Karyawan & Design 3D Modeling Box IoT)',
      division: 'Teknologi Informasi | Politeknik Negeri Madiun',
      initials: 'BIMO',
      accentColor: Color(0xFF4338CA),
    ),
    _DeveloperMember(
      name: 'Alvin',
      role: 'Internet Of Things (IoT)',
      division: 'Teknologi Informasi | Politeknik Negeri Madiun',
      initials: 'ALVIN',
      accentColor: Color(0xFF4338CA),
    ),

    _DeveloperMember(
      name: '-',
      role: '-',
      division: 'CROG Robotic International Engineering',
      initials: 'AB',
      accentColor: Color(0xFF4338CA),
    ),

    _DeveloperMember(
      name: '-',
      role: '-',
      division: 'CROG Robotic International Engineering',
      initials: 'AB',
      accentColor: Color(0xFF4338CA),
    ),

    _DeveloperMember(
      name: '-',
      role: '-',
      division: 'CROG Robotic International Engineering',
      initials: 'AB',
      accentColor: Color(0xFF4338CA),
    ),
  ];

  static const List<_TechStackItem> _techStacks = [
    _TechStackItem(
      icon: Icons.phone_android_rounded,
      title: 'Flutter & BLoC',
      subtitle: 'Aplikasi Mobile Android',
    ),
    _TechStackItem(
      icon: Icons.dns_outlined,
      title: 'Laravel & MySQL',
      subtitle: 'REST API & Panel Admin',
    ),
    _TechStackItem(
      icon: Icons.fingerprint_rounded,
      title: 'IoT Fingerprint',
      subtitle: 'Integrasi Mesin Presensi',
    ),
    _TechStackItem(
      icon: Icons.notifications_active_outlined,
      title: 'Firebase FCM',
      subtitle: 'Notifikasi Real-Time',
    ),
  ];

  void _showPhotoPreview(
      BuildContext context,
      _DeveloperMember member,
      bool isDark,
      ) {
    final String? assetPath = member.photoAsset;
    if (assetPath == null || assetPath.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  assetPath,
                  width: 240.w,
                  height: 240.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                member.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                member.role,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF1E61B6),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color headerBlue =
    isDark ? const Color(0xFF154B8C) : const Color(0xFF1E61B6);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // App Bar Solid Blue
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              bottom: 16.h,
              left: 20.w,
              right: 20.w,
            ),
            color: headerBlue,
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
                  'Tim Developer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Konten Utama
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Ringkasan Tim
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46.w,
                          height: 46.w,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.code_rounded,
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF1E61B6),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengembang Sistem Presensi',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Dirancang dan dikembangkan secara terintegrasi antara aplikasi mobile, panel web admin/owner, serta perangkat absensi IoT.',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Daftar Anggota Tim
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                    child: Text(
                      'ANGGOTA TIM PENGEMBANG SYSTEM & MENTOR',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _developers.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final member = _developers[index];
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.2 : 0.02),
                              blurRadius: 10.r,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildMemberAvatar(context, member, isDark),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    member.role,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF1E61B6),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    member.division,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Teknologi yang Digunakan
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                    child: Text(
                      'TEKNOLOGI & EKOSISTEM',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _techStacks.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.55,
                    ),
                    itemBuilder: (context, index) {
                      final tech = _techStacks[index];
                      return Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tech.icon,
                              size: 20.sp,
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : const Color(0xFF1E61B6),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              tech.title,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              tech.subtitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(
      BuildContext context,
      _DeveloperMember member,
      bool isDark,
      ) {
    final String? assetPath = member.photoAsset;
    if (assetPath == null || assetPath.isEmpty) {
      return _buildInitialsAvatar(member, isDark);
    }

    return GestureDetector(
      onTap: () => _showPhotoPreview(context, member, isDark),
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: member.accentColor.withValues(alpha: isDark ? 0.6 : 0.35),
            width: 1.5.w,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            width: 52.w,
            height: 52.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildInitialsAvatar(member, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(_DeveloperMember member, bool isDark) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: member.accentColor.withValues(alpha: isDark ? 0.25 : 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF93C5FD) : member.accentColor,
        ),
      ),
    );
  }
}

class _DeveloperMember {
  final String name;
  final String role;
  final String division;
  final String initials;
  final String? photoAsset;
  final Color accentColor;

  const _DeveloperMember({
    required this.name,
    required this.role,
    required this.division,
    required this.initials,
    this.photoAsset,
    required this.accentColor,
  });
}

class _TechStackItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TechStackItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}