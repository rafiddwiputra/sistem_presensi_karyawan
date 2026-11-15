import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/authenticated_profile_image.dart';
import '../widgets/menu_card.dart';

import 'package:sistem_presensi_karyawan/features/presensi/presentation/bloc/riwayat_bloc.dart';
import 'package:sistem_presensi_karyawan/features/presensi/presentation/bloc/riwayat_state.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_state.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  String _getFormattedDate() {
    final now = DateTime.now();
    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final List<String> days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryBlue =
    isDark ? const Color(0xFF154B8C) : const Color(0xFF1961B6);
    final Color primaryBlueDeep =
    isDark ? const Color(0xFF0F3666) : const Color(0xFF12498C);
    final Color cardSurface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            // 1. CORPORATE HERO BACKGROUND
            Positioned(
              top: -500,
              left: 0,
              right: 0,
              child: Container(
                height: 500 + 235.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryBlue, primaryBlueDeep],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32.r),
                    bottomRight: Radius.circular(32.r),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40.w,
                      bottom: -30.h,
                      child: Container(
                        width: 180.w,
                        height: 180.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30.w,
                      bottom: 40.h,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. KONTEN UTAMA
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOP BAR PROFIL & NOTIFIKASI ---
                Padding(
                  padding: EdgeInsets.only(top: 56.h, left: 20.w, right: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: BlocBuilder<ProfilBloc, ProfilState>(
                          builder: (context, state) {
                            String namaPanggilan = 'Karyawan';
                            String? fotoProfilUrl;

                            if (state is ProfilLoaded) {
                              String namaLengkap =
                                  state.user['nama'] ?? 'Karyawan';
                              namaPanggilan = namaLengkap.split(' ').first;
                              fotoProfilUrl = state.user['foto_url'];
                            }

                            return Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: AuthenticatedProfileImage(
                                    imagePath: fotoProfilUrl,
                                    size: 46.w,
                                    isDark: isDark,
                                    borderWidth: 0,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Halo, $namaPanggilan',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.14),
                                          borderRadius:
                                          BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          'Fullstack Dev & Database Administrator',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFFDE68A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () => context.push('/notifikasi'),
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 22.w,
                              ),
                              Positioned(
                                right: 10.w,
                                top: 10.h,
                                child: Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                // --- CAPSULE TANGGAL & SHIFT ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13.w,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _getFormattedDate(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // --- BODY KARTU & MENU ---
                Padding(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    bottom: 110.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. KARTU JADWAL & JAM KERJA HARI INI
                      GestureDetector(
                        onTap: () => context.push('/presensi'),
                        child: Container(
                          padding: EdgeInsets.all(18.w),
                          decoration: BoxDecoration(
                            color: cardSurface,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: borderColor, width: 1.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.35 : 0.07,
                                ),
                                blurRadius: 18.r,
                                offset: Offset(0, 6.h),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header Kartu Shift
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 16.w,
                                        color: isDark
                                            ? const Color(0xFF60A5FA)
                                            : const Color(0xFF1961B6),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'JADWAL PRESENSI HARI INI',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 14.h),

                              // Dua Kotak Jam Masuk & Jam Selesai
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF141B24)
                                            : const Color(0xFFF0F9FF),
                                        borderRadius:
                                        BorderRadius.circular(14.r),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF1E3A5F)
                                              : const Color(0xFFBAE6FD),
                                          width: 1.w,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0EA5E9)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                              BorderRadius.circular(10.r),
                                            ),
                                            child: Icon(
                                              Icons.login_rounded,
                                              color: const Color(0xFF0EA5E9),
                                              size: 18.w,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Jam Masuk',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: const Color(
                                                      0xFF0284C7,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                  Alignment.centerLeft,
                                                  child: Text(
                                                    '08.00',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                      FontWeight.w800,
                                                      color: textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF231618)
                                            : const Color(0xFFFEF2F2),
                                        borderRadius:
                                        BorderRadius.circular(14.r),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF4C1D24)
                                              : const Color(0xFFFECACA),
                                          width: 1.w,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: AppColors.error
                                                  .withValues(alpha: 0.14),
                                              borderRadius:
                                              BorderRadius.circular(10.r),
                                            ),
                                            child: Icon(
                                              Icons.logout_rounded,
                                              color: AppColors.error,
                                              size: 18.w,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Jam Selesai',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: AppColors.error,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                  Alignment.centerLeft,
                                                  child: Text(
                                                    '--.--',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                      FontWeight.w800,
                                                      color: textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 12.h),

                              // Strip Pintasan ke Halaman Absensi
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF141414)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 15.w,
                                          color: isDark
                                              ? const Color(0xFF60A5FA)
                                              : const Color(0xFF1961B6),
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Ketuk untuk rekam kehadiran GPS',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12.w,
                                      color: textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 18.h),

                      // 2. KARTU REKAP PRESENSI BULANAN
                      _buildRekapPresensiCard(context, isDark),

                      SizedBox(height: 24.h),

                      // 3. SECTION HEADER LAYANAN MANDIRI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Layanan Karyawan',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Pengajuan administrasi & klaim bulan ini',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 14.h),

                      // 4. GRID MENU 2x2 ENTERPRISE
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14.w,
                        mainAxisSpacing: 14.h,
                        childAspectRatio: 1.02,
                        children: [
                          MenuCard(
                            title: 'IZIN',
                            subtitle: 'Izin bulan ini',
                            count: '2',
                            backgroundColor: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF5F3FF),
                            iconBackgroundColor: const Color(0xFF5E548E),
                            icon: Icons.mail_outline_rounded,
                            onTap: () => context.push('/izin'),
                          ),
                          MenuCard(
                            title: 'CUTI',
                            subtitle: 'Cuti bulan ini',
                            count: '1',
                            backgroundColor: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFECFDF5),
                            iconBackgroundColor: const Color(0xFF2E7D60),
                            icon: Icons.calendar_today_outlined,
                            onTap: () => context.push('/cuti'),
                          ),
                          MenuCard(
                            title: 'LEMBUR',
                            subtitle: 'Pengajuan lembur',
                            count: '0',
                            backgroundColor: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFFFF7ED),
                            iconBackgroundColor: const Color(0xFFD9531E),
                            icon: Icons.access_time_rounded,
                            onTap: () => context.push('/lembur'),
                          ),
                          MenuCard(
                            title: 'REIMBURSEMENT',
                            subtitle: 'Reimburs bulan ini',
                            count: '0',
                            backgroundColor: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFFDF2F8),
                            iconBackgroundColor: const Color(0xFF9E3E6E),
                            icon: Icons.receipt_long_outlined,
                            onTap: () => context.push('/reimbursement'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRekapPresensiCard(BuildContext context, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        context.push('/rekap-presensi');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 14.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Rekap Presensi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(9.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.bar_chart_rounded,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF1961B6),
                          size: 20.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rekap Presensi',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Ringkasan kehadiran bulan ini',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF282828)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF1961B6),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF1961B6),
                        size: 16.w,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            BlocBuilder<RiwayatBloc, RiwayatState>(
              builder: (context, state) {
                String totalMasuk = '0';
                String totalTerlambat = '0';
                String totalTanpaAbsen = '0';

                if (state is RiwayatLoaded) {
                  totalMasuk = state.summary.hadir.toString();
                  totalTanpaAbsen = state.summary.tidakHadir.toString();

                  int terlambatCount = 0;
                  for (var item in state.riwayatList) {
                    if (item.menitTerlambat > 0) {
                      terlambatCount++;
                    }
                  }
                  totalTerlambat = terlambatCount.toString();
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildRekapTile(
                        isDark: isDark,
                        angka: totalMasuk,
                        label: 'Masuk',
                        warnaAngka: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669),
                        warnaBg: isDark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                            : const Color(0xFFECFDF5),
                        textSecondary: textSecondary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildRekapTile(
                        isDark: isDark,
                        angka: totalTerlambat,
                        label: 'Terlambat',
                        warnaAngka: isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFD97706),
                        warnaBg: isDark
                            ? const Color(0xFF78350F).withValues(alpha: 0.35)
                            : const Color(0xFFFFFBEB),
                        textSecondary: textSecondary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildRekapTile(
                        isDark: isDark,
                        angka: totalTanpaAbsen,
                        label: 'Tanpa Absen',
                        warnaAngka: isDark
                            ? const Color(0xFFF87171)
                            : const Color(0xFFDC2626),
                        warnaBg: isDark
                            ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
                            : const Color(0xFFFEF2F2),
                        textSecondary: textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRekapTile({
    required bool isDark,
    required String angka,
    required String label,
    required Color warnaAngka,
    required Color warnaBg,
    required Color textSecondary,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: warnaBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text(
            angka,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: warnaAngka,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white.withValues(alpha: 0.85) : textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
