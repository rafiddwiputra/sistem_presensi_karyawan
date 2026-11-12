import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../bloc/cuti_bloc.dart';
import '../bloc/cuti_event.dart';
import '../bloc/cuti_state.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    context.read<CutiBloc>().add(FetchRiwayatCuti());
  }

  String _formatRangeTanggal(String startStr, String endStr) {
    try {
      final start = DateTime.parse(startStr);
      final end = DateTime.parse(endStr);

      final startDay = DateFormat('dd', 'id_ID').format(start);
      final endFormat = DateFormat('dd MMM yyyy', 'id_ID').format(end);

      if (start.month == end.month && start.year == end.year) {
        if (start.day == end.day) return endFormat;
        return '$startDay – $endFormat';
      }

      final startBulan = DateFormat('dd MMM', 'id_ID').format(start);
      return '$startBulan – $endFormat';
    } catch (e) {
      return '$startStr - $endStr';
    }
  }

  String _hitungDurasi(String startStr, String endStr) {
    try {
      final start = DateTime.parse(startStr);
      final end = DateTime.parse(endStr);
      final difference = end.difference(start).inDays + 1;
      return '$difference Hari';
    } catch (e) {
      return '-';
    }
  }

  String _formatSubmittedDate(String submittedStr) {
    try {
      final date = DateTime.parse(submittedStr);
      return 'Diajukan ${DateFormat('dd MMM yyyy', 'id_ID').format(date)}';
    } catch (e) {
      return 'Diajukan -';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgApp = Theme.of(context).scaffoldBackgroundColor;
    final Color primaryBlue = isDark
        ? const Color(0xFF3B82F6)
        : const Color(0xFF135CAE);
    final Color headerBlue = isDark
        ? const Color(0xFF154B8C)
        : const Color(0xFF135CAE);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
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
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
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
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<CutiBloc>().add(FetchRiwayatCuti());
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: primaryBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
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
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.03,
                                ),
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
                                      color: isDark
                                          ? const Color(0xFF1E3A8A)
                                          : const Color(0xFFE0E7FF),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : primaryBlue,
                                      size: 24.w,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20.w,
                                  ),
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

                        // --- HEADER RIWAYAT ---
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

                        BlocBuilder<CutiBloc, CutiState>(
                          builder: (context, state) {
                            // MENGGUNAKAN ENUM state.status, BUKAN state is ...
                            if (state.status == CutiStatus.loading) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: CircularProgressIndicator(
                                    color: primaryBlue,
                                  ),
                                ),
                              );
                            } else if (state.status == CutiStatus.error) {
                              // MENGGUNAKAN errorMessage
                              return Center(
                                child: Text(
                                  state.errorMessage ?? 'Terjadi kesalahan',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            } else if (state.status == CutiStatus.loaded) {
                              final data = state.riwayatCuti;

                              if (data.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 40.h,
                                    ),
                                    child: Text(
                                      'Belum ada riwayat pengajuan cuti.',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 16.h),
                                itemBuilder: (context, index) {
                                  final item = data[index];
                                  return _buildHistoryCard(
                                    date: _formatRangeTanggal(
                                      item.startDate,
                                      item.endDate,
                                    ),
                                    duration: _hitungDurasi(
                                      item.startDate,
                                      item.endDate,
                                    ),
                                    submittedDate: _formatSubmittedDate(
                                      item.submittedAt,
                                    ),
                                    reason: item.purpose ?? 'Tidak ada alasan',
                                    status: item.statusLabel, // Hapus validasi ?? 'Pending' karena non-nullable
                                    isDark: isDark,
                                  );
                                },
                              );
                            }
                            // Default / Initial State
                            return const SizedBox.shrink();
                          },
                        ),

                        SizedBox(height: 24.h),
                      ],
                    ),
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
    final bool isApproved = status.toLowerCase() == 'disetujui';
    final bool isPending =
        status.toLowerCase() == 'pending' || status.toLowerCase() == 'menunggu';

    Color badgeBgColor;
    Color badgeTextColor;
    IconData badgeIcon;

    if (isApproved) {
      badgeBgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      badgeTextColor = isDark
          ? const Color(0xFF34D399)
          : const Color(0xFF059669);
      badgeIcon = Icons.check_circle;
    } else if (isPending) {
      badgeBgColor = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
      badgeTextColor = isDark
          ? const Color(0xFFFBBF24)
          : const Color(0xFFD97706);
      badgeIcon = Icons.schedule;
    } else {
      badgeBgColor = isDark ? const Color(0xFF450A0A) : const Color(0xFFFFE4E6);
      badgeTextColor = isDark
          ? const Color(0xFFFCA5A5)
          : const Color(0xFFE11D48);
      badgeIcon = Icons.cancel;
    }

    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFF1F5F9);
    final Color reasonBgColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8FAFC);

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
                ),
                child: Row(
                  children: [
                    Icon(badgeIcon, color: badgeTextColor, size: 12.w),
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: reasonBgColor,
              borderRadius: BorderRadius.circular(8.r),
              border: isDark
                  ? Border.all(color: const Color(0xFF282828))
                  : null,
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
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF334155),
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
