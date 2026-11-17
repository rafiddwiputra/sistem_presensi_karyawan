import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/riwayat_state.dart';
import '../../data/models/izin_history_model.dart';
import '../bloc/izin_bloc.dart';
import '../bloc/izin_event.dart';
import '../bloc/izin_state.dart';

enum IzinCardStatus { pending, approved, rejected, unknown }

class IzinPage extends StatelessWidget {
  const IzinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      GetIt.instance<IzinBloc>()..add(const FetchIzinHistory()),
      child: const _IzinView(),
    );
  }
}

class _IzinView extends StatelessWidget {
  const _IzinView();

  void _loadRiwayat(BuildContext context) {
    context.read<IzinBloc>().add(const FetchIzinHistory());
  }

  IzinCardStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return IzinCardStatus.pending;
      case 'disetujui':
      case 'approved':
        return IzinCardStatus.approved;
      case 'ditolak':
      case 'rejected':
        return IzinCardStatus.rejected;
      default:
        return IzinCardStatus.unknown;
    }
  }

  String _calculateDuration(String startDate, String endDate) {
    if (startDate.isEmpty || endDate.isEmpty) return '-';
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final days = end.difference(start).inDays + 1;
      return '$days Hari';
    } catch (e) {
      return '-';
    }
  }

  Map<String, List<IzinHistoryItem>> _groupHistoryByMonth(
      List<IzinHistoryItem> historyList,
      ) {
    final groupedData = <String, List<IzinHistoryItem>>{};

    for (var item in historyList) {
      if (item.submittedAt.isEmpty) continue;

      try {
        final DateTime date = DateTime.parse(item.submittedAt).toLocal();
        final String monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(date);

        if (groupedData.containsKey(monthLabel)) {
          groupedData[monthLabel]!.add(item);
        } else {
          groupedData[monthLabel] = [item];
        }
      } catch (e) {
        debugPrint('Error parsing date for grouping: $e');
      }
    }
    return groupedData;
  }

  String _formatDateRange(String tglMulai, String tglSelesai) {
    if (tglMulai.isEmpty || tglSelesai.isEmpty) return '-';
    try {
      final DateTime start = DateTime.parse(tglMulai);
      final DateTime end = DateTime.parse(tglSelesai);

      final String monthYear = DateFormat('MMMM yyyy', 'id_ID').format(start);
      final String startDay = DateFormat('dd').format(start);
      final String endDay = DateFormat('dd').format(end);

      if (start.month == end.month && start.year == end.year) {
        if (startDay == endDay) {
          return '$startDay $monthYear';
        }
        return '$startDay - $endDay $monthYear';
      }
      return '${DateFormat('dd MMM yyyy', 'id_ID').format(start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(end)}';
    } catch (e) {
      return tglMulai.length >= 10 ? tglMulai.substring(0, 10) : tglMulai;
    }
  }

  String _formatSubmittedAt(String submittedAt, {bool fullMonth = false}) {
    if (submittedAt.isEmpty) return '-';
    final parsed = DateTime.tryParse(submittedAt);
    if (parsed == null) return submittedAt;

    final localDate = parsed.toLocal();
    final pattern = fullMonth ? 'dd MMMM yyyy, HH:mm' : 'dd MMM yyyy, HH:mm';
    return '${DateFormat(pattern, 'id_ID').format(localDate)} WIB';
  }

  void _showDetailBottomSheet(
      BuildContext context, {
        required IzinHistoryItem item,
        required String title,
        required String date,
        required String duration,
        required String submittedTime,
        required bool isDark,
      }) {
    final Color sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color boxBg =
    isDark ? const Color(0xFF282828) : const Color(0xFFF8FAFC);

    final String detailKeterangan = item.keterangan.isNotEmpty
        ? item.keterangan
        : (item.purpose.isNotEmpty
        ? item.purpose
        : 'Tidak ada keterangan tambahan.');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Detail Pengajuan Izin',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              _buildDetailRow('Izin Karena', title, textSecondary, textPrimary),
              SizedBox(height: 10.h),
              _buildDetailRow(
                'Tanggal Izin',
                '$date ($duration)',
                textSecondary,
                textPrimary,
              ),
              SizedBox(height: 10.h),
              _buildDetailRow(
                'Diajukan Pada',
                submittedTime,
                textSecondary,
                textPrimary,
              ),
              SizedBox(height: 10.h),
              _buildDetailRow(
                'Status',
                item.statusLabel.isNotEmpty ? item.statusLabel : '-',
                textSecondary,
                textPrimary,
              ),
              SizedBox(height: 16.h),
              Text(
                'Alasan Izin',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: boxBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  detailKeterangan,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              if (item.catatanAdmin.isNotEmpty) ...[
                SizedBox(height: 14.h),
                Text(
                  'Alasan Penolakan Admin',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFDC2626),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF450A0A).withValues(alpha: 0.45)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF7F1D1D)
                          : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Text(
                    item.catatanAdmin,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFFB91C1C),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
      String label,
      String value,
      Color labelColor,
      Color valueColor,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: labelColor),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color headerBlue =
    isDark ? const Color(0xFF154B8C) : const Color(0xFF1961B6);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
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
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
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
                child: RefreshIndicator(
                  onRefresh: () async => _loadRiwayat(context),
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
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                const Color(0xFF1E1E1E),
                                const Color(0xFF12243E),
                              ]
                                  : [Colors.white, const Color(0xFFEFF6FF)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.3)
                                    : const Color(0xFF1961B6)
                                    .withValues(alpha: 0.05),
                                blurRadius: 20.r,
                                offset: Offset(0, 4.h),
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
                                          : const Color(0xFFDBEAFE),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF2563EB),
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
                                          'Butuh izin?',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Ajukan izin dan pantau status perizinan Anda.',
                                          style: TextStyle(
                                            fontSize: 12.sp,
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
                                height: 48.h,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await context.push('/buat-izin');
                                    if (context.mounted) {
                                      _loadRiwayat(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D4ED8),
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
                                    'Buat surat izin',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
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
                          'RIWAYAT PENGAJUAN IZIN',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        BlocBuilder<IzinBloc, IzinState>(
                          builder: (context, state) {
                            if (state.isLoadingHistory &&
                                state.historyList.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 48.h),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (state.errorMessage != null &&
                                state.errorMessage!.isNotEmpty &&
                                state.historyList.isEmpty) {
                              return RiwayatErrorCard(
                                message: state.errorMessage!,
                                isDark: isDark,
                                onRetry: () => _loadRiwayat(context),
                              );
                            }

                            if (state.historyList.isEmpty) {
                              return RiwayatEmptyCard(
                                message: 'Belum ada riwayat pengajuan izin',
                                icon: Icons.mail_outline_rounded,
                                isDark: isDark,
                              );
                            }

                            final groupedData = _groupHistoryByMonth(
                              state.historyList,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: groupedData.entries.map((entry) {
                                final String monthName = entry.key;
                                final List<IzinHistoryItem> items = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMonthHeader(monthName, textPrimary),
                                    ...items.map((item) {
                                      final IzinCardStatus cardStatus =
                                      _mapStatus(item.status);

                                      final String displayTitle =
                                      item.purpose.isNotEmpty
                                          ? item.purpose
                                          : 'Pengajuan Izin';

                                      final String formattedDate =
                                      _formatDateRange(
                                        item.startDate,
                                        item.endDate,
                                      );

                                      final String durationText =
                                      _calculateDuration(
                                        item.startDate,
                                        item.endDate,
                                      );

                                      final String submittedCompact =
                                      _formatSubmittedAt(item.submittedAt);

                                      final String submittedFull =
                                      _formatSubmittedAt(
                                        item.submittedAt,
                                        fullMonth: true,
                                      );

                                      return _buildHistoryCard(
                                        title: displayTitle,
                                        date: formattedDate,
                                        submittedAt: submittedCompact,
                                        description: item.keterangan,
                                        rejectionReason: item.catatanAdmin,
                                        duration: durationText,
                                        type: item.jenisLabel.isNotEmpty
                                            ? item.jenisLabel
                                            : 'Izin',
                                        statusLabel: item.statusLabel,
                                        status: cardStatus,
                                        isDark: isDark,
                                        onTap: () => _showDetailBottomSheet(
                                          context,
                                          item: item,
                                          title: displayTitle,
                                          date: formattedDate,
                                          duration: durationText,
                                          submittedTime: submittedFull,
                                          isDark: isDark,
                                        ),
                                      );
                                    }),
                                    SizedBox(height: 8.h),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),
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

  Widget _buildMonthHeader(String month, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
      child: Text(
        month,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String date,
    required String submittedAt,
    required String description,
    required String rejectionReason,
    required String duration,
    required String type,
    required String statusLabel,
    required IzinCardStatus status,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    Color iconColor;

    switch (status) {
      case IzinCardStatus.pending:
        bgColor = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
        borderColor =
        isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
        textColor = isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706);
        iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
        break;
      case IzinCardStatus.approved:
        bgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
        borderColor =
        isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0);
        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
        iconColor = isDark ? const Color(0xFF10B981) : const Color(0xFF10B981);
        break;
      case IzinCardStatus.rejected:
        bgColor = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
        borderColor =
        isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA);
        textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
        iconColor = isDark ? const Color(0xFFEF4444) : const Color(0xFFEF4444);
        break;
      default:
        bgColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
        borderColor =
        isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0);
        textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);
    }

    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color cardBorder =
    isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E8F0);
    final Color subtleSurface =
    isDark ? const Color(0xFF252525) : const Color(0xFFF8FAFC);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color accentBlue =
    isDark ? const Color(0xFF60A5FA) : const Color(0xFF1961B6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cardBorder, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.03),
              blurRadius: 12.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: IKON + JUDUL & JAM PENGAJUAN + BADGE STATUS ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.45)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: accentBlue,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      if (submittedAt != '-') ...[
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12.sp,
                              color: textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                'Diajukan $submittedAt',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: borderColor, width: 1.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3.r, backgroundColor: iconColor),
                      SizedBox(width: 5.w),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // --- BODY: TANGGAL IZIN, DURASI & ALASAN IZIN ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: subtleSurface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13.sp,
                        color: accentBlue,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      _buildTag(duration, isDark),
                      SizedBox(width: 6.w),
                      _buildTag(type, isDark),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Divider(
                        height: 1.h,
                        color: cardBorder,
                      ),
                    ),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.45,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // --- FOOTER: ALASAN PENOLAKAN (JIKA DITOLAK) ---
            if (rejectionReason.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF450A0A).withValues(alpha: 0.45)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF7F1D1D)
                        : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 14.sp,
                        color: isDark
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Alasan ditolak: $rejectionReason',
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.4,
                          color: isDark
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        ),
      ),
    );
  }
}