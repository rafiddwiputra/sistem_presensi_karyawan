import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/lembur_bloc.dart';
import '../bloc/lembur_event.dart';
import '../bloc/lembur_state.dart';

class LemburPage extends StatefulWidget {
  const LemburPage({super.key});

  @override
  State<LemburPage> createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {
  @override
  void initState() {
    super.initState();

    context.read<LemburBloc>().add(FetchRiwayatLembur());
  }

  String _hitungDurasi(String jamMulai, String jamSelesai) {
    if (jamMulai.isEmpty || jamSelesai.isEmpty) return '-';
    try {
      final format = DateFormat('HH:mm');
      final start = format.parse(jamMulai);
      var end = format.parse(jamSelesai);

      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }

      final diff = end.difference(start);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;

      if (minutes == 0) return '$hours Jam';
      if (hours == 0) return '$minutes Menit';
      return '$hours Jam $minutes Menit';
    } catch (e) {
      return '-';
    }
  }

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
                                        style: TextStyle(fontSize: 13.sp, color: textSecondary),
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

                      BlocBuilder<LemburBloc, LemburState>(
                        builder: (context, state) {
                          if (state.status == LemburStatus.loading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state.status == LemburStatus.error) {
                            return Center(
                              child: Text(
                                state.errorMessage ?? 'Gagal memuat data',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (state.status == LemburStatus.loaded || state.status == LemburStatus.success) {
                            if (state.riwayatLembur.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: Text(
                                    'Belum ada riwayat pengajuan lembur.',
                                    style: TextStyle(color: textSecondary, fontSize: 13.sp),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.riwayatLembur.length,
                              separatorBuilder: (_, __) => SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                final lembur = state.riwayatLembur[index];

                                String tglFormat = lembur.tanggalLembur;
                                if (tglFormat.isNotEmpty) {
                                  try {
                                    final parsed = DateFormat('yyyy-MM-dd').parse(lembur.tanggalLembur);
                                    tglFormat = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(parsed);
                                  } catch (_) {}
                                } else {
                                  tglFormat = '-';
                                }

                                String timeRangeText = '- WIB';
                                if (lembur.jamMulai.isNotEmpty && lembur.jamSelesai.isNotEmpty) {
                                  timeRangeText = '${lembur.jamMulai} – ${lembur.jamSelesai} WIB';
                                } else if (lembur.jamMulai.isNotEmpty) {
                                  timeRangeText = '${lembur.jamMulai} WIB';
                                }

                                return _buildHistoryCard(
                                  date: tglFormat,
                                  timeRange: timeRangeText,
                                  duration: _hitungDurasi(lembur.jamMulai, lembur.jamSelesai),
                                  description: lembur.alasanLembur.isNotEmpty ? lembur.alasanLembur : '-',
                                  status: lembur.statusLabel,
                                  isDark: isDark,
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
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

    final bool isApproved = status.toLowerCase() == 'disetujui';
    final bool isPending = status.toLowerCase() == 'menunggu konfirmasi' || status.toLowerCase() == 'pending';
    final bool isRejected = status.toLowerCase() == 'ditolak';

    Color badgeBgColor;
    Color badgeTextColor;

    if (isApproved) {
      badgeBgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      badgeTextColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    } else if (isRejected) {
      badgeBgColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
      badgeTextColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    } else {
      badgeBgColor = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
      badgeTextColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    }

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