
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

// ============================================================
// MODEL DATA CUTI
// ============================================================

enum _CutiStatus {
  pending,
  approved,
  rejected,
  unknown,
}

class _CutiHistory {
  final String date;
  final String duration;
  final String submittedDate;
  final String reason;
  final _CutiStatus status;

  const _CutiHistory({
    required this.date,
    required this.duration,
    required this.submittedDate,
    required this.reason,
    required this.status,
  });
}

// ============================================================
// MOCK DATA SEMENTARA
// ============================================================

const List<_CutiHistory> _mockCutiHistory = [
  _CutiHistory(
    date: '20 – 22 Okt 2026',
    duration: '3 Hari Kerja',
    submittedDate: 'Diajukan 15 Okt 2026',
    reason: 'Keperluan keluarga di luar kota',
    status: _CutiStatus.pending,
  ),
  _CutiHistory(
    date: '12 – 14 Agu 2026',
    duration: '3 Hari Kerja',
    submittedDate: 'Diajukan 1 Agu 2026',
    reason: 'Acara pernikahan saudara kandung',
    status: _CutiStatus.approved,
  ),
  _CutiHistory(
    date: '02 – 03 Jul 2026',
    duration: '2 Hari Kerja',
    submittedDate: 'Diajukan 25 Jun 2026',
    reason: 'Urusan administrasi kependudukan',
    status: _CutiStatus.approved,
  ),
  _CutiHistory(
    date: '10 – 11 Mei 2026',
    duration: '2 Hari Kerja',
    submittedDate: 'Diajukan 8 Mei 2026',
    reason: 'Pemeriksaan medis lanjutan',
    status: _CutiStatus.rejected,
  ),
];

// ============================================================
// CUTI PAGE
// ============================================================

class CutiPage extends StatelessWidget {
  const CutiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color bgApp =
        Theme.of(context).scaffoldBackgroundColor;

    final Color primaryBlue = isDark
        ? const Color(0xFF3B82F6)
        : const Color(0xFF135CAE);

    final Color headerBlue = isDark
        ? const Color(0xFF154B8C)
        : const Color(0xFF135CAE);

    final Color textPrimary = isDark
        ? Colors.white
        : const Color(0xFF1E293B);

    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final Color cardBg = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    return Scaffold(
      backgroundColor: headerBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==================================================
            // APP BAR
            // ==================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    tooltip: 'Kembali',
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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

            // ==================================================
            // KONTEN UTAMA
            // ==================================================

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
                    // TODO:
                    // Hubungkan dengan CutiBloc untuk mengambil
                    // ulang riwayat cuti dari backend API.
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
                        // ======================================
                        // KARTU AJUKAN CUTI
                        // ======================================

                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius:
                            BorderRadius.circular(20.r),
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
                                      borderRadius:
                                      BorderRadius.circular(12.r),
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
                                      borderRadius:
                                      BorderRadius.circular(12.r),
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

                        // ======================================
                        // HEADER RIWAYAT
                        // ======================================

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

                        // ======================================
                        // DAFTAR RIWAYAT CUTI
                        // ======================================

                        if (_mockCutiHistory.isEmpty)
                          Center(
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
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: _mockCutiHistory.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final item = _mockCutiHistory[index];

                              return _buildHistoryCard(
                                item: item,
                                isDark: isDark,
                              );
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

  // ============================================================
  // HELPER WIDGET: KARTU RIWAYAT CUTI
  // ============================================================

  Widget _buildHistoryCard({
    required _CutiHistory item,
    required bool isDark,
  }) {
    final Color cardBg = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    final Color textPrimary = isDark
        ? Colors.white
        : const Color(0xFF1E293B);

    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final Color borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFF1F5F9);

    final Color reasonBgColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8FAFC);

    // ================================================
    // KONFIGURASI STATUS CUTI
    // ================================================

    late final Color badgeBgColor;
    late final Color badgeTextColor;
    late final IconData badgeIcon;
    late final String statusLabel;

    switch (item.status) {
      case _CutiStatus.approved:
        badgeBgColor = isDark
            ? const Color(0xFF064E3B)
            : const Color(0xFFD1FAE5);

        badgeTextColor = isDark
            ? const Color(0xFF34D399)
            : const Color(0xFF059669);

        badgeIcon = Icons.check_circle;
        statusLabel = 'Disetujui';

      case _CutiStatus.pending:
        badgeBgColor = isDark
            ? const Color(0xFF451A03)
            : const Color(0xFFFEF3C7);

        badgeTextColor = isDark
            ? const Color(0xFFFBBF24)
            : const Color(0xFFD97706);

        badgeIcon = Icons.schedule;
        statusLabel = 'Pending';

      case _CutiStatus.rejected:
        badgeBgColor = isDark
            ? const Color(0xFF450A0A)
            : const Color(0xFFFFE4E6);

        badgeTextColor = isDark
            ? const Color(0xFFFCA5A5)
            : const Color(0xFFE11D48);

        badgeIcon = Icons.cancel;
        statusLabel = 'Ditolak';

      case _CutiStatus.unknown:
        badgeBgColor = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0);

        badgeTextColor = isDark
            ? const Color(0xFFCBD5E1)
            : const Color(0xFF475569);

        badgeIcon = Icons.info_outline;
        statusLabel = 'Status tidak diketahui';
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.2 : 0.02,
            ),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // TANGGAL CUTI DAN STATUS
          // ==========================================

          Row(
            children: [
              Expanded(
                child: Text(
                  item.date,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        badgeIcon,
                        color: badgeTextColor,
                        size: 12.w,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ==========================================
          // DURASI DAN TANGGAL PENGAJUAN
          // ==========================================

          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: textSecondary,
                      size: 14.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Durasi:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        item.duration,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  item.submittedDate,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ==========================================
          // ALASAN PENGAJUAN CUTI
          // ==========================================

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: reasonBgColor,
              borderRadius: BorderRadius.circular(8.r),
              border: isDark
                  ? Border.all(
                color: const Color(0xFF282828),
              )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  color: textSecondary,
                  size: 16.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    item.reason,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
