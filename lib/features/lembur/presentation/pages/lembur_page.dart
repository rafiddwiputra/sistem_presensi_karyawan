import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/riwayat_state.dart';
import '../bloc/lembur_bloc.dart';
import '../bloc/lembur_event.dart';
import '../bloc/lembur_state.dart';

enum LemburCardStatus { pending, approved, rejected, unknown }

class LemburPage extends StatefulWidget {
  const LemburPage({super.key});

  @override
  State<LemburPage> createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadRiwayat();
  }

  void _loadRiwayat() {
    context.read<LemburBloc>().add(FetchRiwayatLembur());
  }

  LemburCardStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return LemburCardStatus.pending;
      case 'disetujui':
      case 'approved':
        return LemburCardStatus.approved;
      case 'ditolak':
      case 'rejected':
        return LemburCardStatus.rejected;
      default:
        return LemburCardStatus.unknown;
    }
  }

  String _formatJam(String rawJam) {
    final trimmed = rawJam.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return trimmed;
  }

  String _formatRangeJam(String jamMulai, String jamSelesai) {
    final start = _formatJam(jamMulai);
    final end = _formatJam(jamSelesai);

    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start – $end WIB';
    }
    if (start.isNotEmpty) {
      return '$start WIB';
    }
    return '- WIB';
  }

  String _hitungDurasi(String jamMulai, String jamSelesai) {
    final startStr = _formatJam(jamMulai);
    final endStr = _formatJam(jamSelesai);
    if (startStr.isEmpty || endStr.isEmpty) return '-';

    try {
      final format = DateFormat('HH:mm');
      final start = format.parse(startStr);
      var end = format.parse(endStr);

      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }

      final diff = end.difference(start);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;

      if (hours == 0 && minutes == 0) return '0 Menit';
      if (minutes == 0) return '$hours Jam';
      if (hours == 0) return '$minutes Menit';
      return '$hours Jam $minutes Menit';
    } catch (e) {
      return '-';
    }
  }

  String _formatTanggalLembur(String rawDate, {bool fullMonth = false}) {
    if (rawDate.trim().isEmpty) return '-';
    try {
      final parsed = DateTime.tryParse(rawDate.trim()) ??
          DateFormat('yyyy-MM-dd').parse(rawDate.trim());
      final pattern = fullMonth ? 'EEEE, dd MMMM yyyy' : 'EEEE, dd MMM yyyy';
      return DateFormat(pattern, 'id_ID').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  String _formatSubmittedAt(String submittedStr, {bool fullMonth = false}) {
    if (submittedStr.isEmpty) return '-';
    final parsed = DateTime.tryParse(submittedStr);
    if (parsed == null) return submittedStr;

    final localDate = parsed.toLocal();
    final pattern = fullMonth ? 'dd MMMM yyyy, HH:mm' : 'dd MMM yyyy, HH:mm';
    return '${DateFormat(pattern, 'id_ID').format(localDate)} WIB';
  }

  String _getSubmittedAt(dynamic item) {
    try {
      return (item.submittedAt ?? '').toString().trim();
    } catch (_) {
      return '';
    }
  }

  String _getCatatanAdmin(dynamic item) {
    try {
      final raw = (item.catatanAdmin ?? '').toString().trim();
      return raw == '0' ? '' : raw;
    } catch (_) {
      return '';
    }
  }

  Map<String, List<dynamic>> _groupHistoryByMonth(List<dynamic> historyList) {
    final groupedData = <String, List<dynamic>>{};

    for (final item in historyList) {
      final String submitted = _getSubmittedAt(item);
      final String rawDate =
      submitted.isNotEmpty ? submitted : item.tanggalLembur;
      String monthLabel = 'Lainnya';

      if (rawDate.isNotEmpty) {
        final parsed = DateTime.tryParse(rawDate);
        if (parsed != null) {
          monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(parsed.toLocal());
        }
      }

      groupedData.putIfAbsent(monthLabel, () => []).add(item);
    }
    return groupedData;
  }

  void _showDetailBottomSheet(
      BuildContext context, {
        required String dateFull,
        required String timeRange,
        required String duration,
        required String submittedTime,
        required String statusLabel,
        required String description,
        required String rejectionReason,
        required bool isDark,
      }) {
    final Color sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color boxBg =
    isDark ? const Color(0xFF282828) : const Color(0xFFF8FAFC);

    final String detailAlasan = description.isNotEmpty
        ? description
        : 'Tidak ada keterangan tambahan.';

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
                'Detail Pengajuan Lembur',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              _buildDetailRow(
                'Tanggal Lembur',
                dateFull,
                textSecondary,
                textPrimary,
              ),
              SizedBox(height: 10.h),
              _buildDetailRow(
                'Waktu Lembur',
                '$timeRange ($duration)',
                textSecondary,
                textPrimary,
              ),
              if (submittedTime != '-') ...[
                SizedBox(height: 10.h),
                _buildDetailRow(
                  'Diajukan Pada',
                  submittedTime,
                  textSecondary,
                  textPrimary,
                ),
              ],
              SizedBox(height: 10.h),
              _buildDetailRow(
                'Status',
                statusLabel.isNotEmpty ? statusLabel : '-',
                textSecondary,
                textPrimary,
              ),
              SizedBox(height: 16.h),
              Text(
                'Alasan / Keterangan Lembur',
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
                  detailAlasan,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              if (rejectionReason.isNotEmpty) ...[
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
                    rejectionReason,
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
          width: 112.w,
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
    final Color primaryBlue =
    isDark ? const Color(0xFF3B82F6) : const Color(0xFF1961B6);
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
                child: RefreshIndicator(
                  onRefresh: () async => _loadRiwayat(),
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
                                      Icons.more_time_rounded,
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
                                          'Rencanakan Lembur Anda',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Ajukan jadwal lembur dan pantau status persetujuannya.',
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
                                    await context.push('/buat-lembur');
                                    if (mounted) {
                                      _loadRiwayat();
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
                                    'Ajukan Lembur',
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
                          'RIWAYAT PENGAJUAN LEMBUR',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        BlocBuilder<LemburBloc, LemburState>(
                          builder: (context, state) {
                            if (state.status == LemburStatus.loading &&
                                state.riwayatLembur.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 48.h),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: primaryBlue,
                                  ),
                                ),
                              );
                            }

                            if (state.status == LemburStatus.error &&
                                state.riwayatLembur.isEmpty) {
                              return RiwayatErrorCard(
                                message: state.errorMessage ??
                                    'Gagal memuat riwayat pengajuan lembur',
                                isDark: isDark,
                                onRetry: _loadRiwayat,
                              );
                            }

                            if (state.riwayatLembur.isEmpty) {
                              return RiwayatEmptyCard(
                                message: 'Belum ada riwayat pengajuan lembur',
                                icon: Icons.timer_outlined,
                                isDark: isDark,
                              );
                            }

                            final groupedData =
                            _groupHistoryByMonth(state.riwayatLembur);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: groupedData.entries.map((entry) {
                                final String monthName = entry.key;
                                final List<dynamic> items = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMonthHeader(monthName, textPrimary),
                                    ...items.map((lembur) {
                                      final LemburCardStatus cardStatus =
                                      _mapStatus(lembur.statusLabel);

                                      final String dateCompact =
                                      _formatTanggalLembur(
                                        lembur.tanggalLembur,
                                      );
                                      final String dateFull =
                                      _formatTanggalLembur(
                                        lembur.tanggalLembur,
                                        fullMonth: true,
                                      );

                                      final String timeRangeText =
                                      _formatRangeJam(
                                        lembur.jamMulai,
                                        lembur.jamSelesai,
                                      );

                                      final String durationText = _hitungDurasi(
                                        lembur.jamMulai,
                                        lembur.jamSelesai,
                                      );

                                      final String rawSubmitted =
                                      _getSubmittedAt(lembur);
                                      final String submittedCompact =
                                      _formatSubmittedAt(rawSubmitted);
                                      final String submittedFull =
                                      _formatSubmittedAt(
                                        rawSubmitted,
                                        fullMonth: true,
                                      );

                                      final String rawDescription =
                                      lembur.alasanLembur.trim();
                                      final String rejectionReason =
                                      _getCatatanAdmin(lembur);

                                      return _buildHistoryCard(
                                        title: dateCompact,
                                        timeRange: timeRangeText,
                                        submittedAt: submittedCompact,
                                        description: rawDescription,
                                        rejectionReason: rejectionReason,
                                        duration: durationText,
                                        type: 'Lembur',
                                        statusLabel: lembur.statusLabel,
                                        status: cardStatus,
                                        isDark: isDark,
                                        onTap: () => _showDetailBottomSheet(
                                          context,
                                          dateFull: dateFull,
                                          timeRange: timeRangeText,
                                          duration: durationText,
                                          submittedTime: submittedFull,
                                          statusLabel: lembur.statusLabel,
                                          description: rawDescription,
                                          rejectionReason: rejectionReason,
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
                        SizedBox(height: 16.h),
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
    required String timeRange,
    required String submittedAt,
    required String description,
    required String rejectionReason,
    required String duration,
    required String type,
    required String statusLabel,
    required LemburCardStatus status,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    Color iconColor;

    switch (status) {
      case LemburCardStatus.pending:
        bgColor = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
        borderColor =
        isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
        textColor = isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706);
        iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
        break;
      case LemburCardStatus.approved:
        bgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
        borderColor =
        isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0);
        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
        iconColor = isDark ? const Color(0xFF10B981) : const Color(0xFF10B981);
        break;
      case LemburCardStatus.rejected:
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
                    Icons.timer_rounded,
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
                        Icons.schedule_rounded,
                        size: 13.sp,
                        color: accentBlue,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          timeRange,
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