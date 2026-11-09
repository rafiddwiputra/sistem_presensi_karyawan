import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../bloc/izin_bloc.dart';
import '../bloc/izin_event.dart';
import '../bloc/izin_state.dart';
import '../../data/models/izin_history_model.dart';

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
        final DateTime date = DateTime.parse(item.submittedAt);

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
      return tglMulai.substring(0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color headerBlue = isDark
        ? const Color(0xFF154B8C)
        : const Color(0xFF1961B6);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                                    context.read<IzinBloc>().add(
                                      const FetchIzinHistory(),
                                    );
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
                          if (state.isLoadingHistory) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30.h),
                                child: const CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (state.historyList.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30.h),
                                child: Text(
                                  'Belum ada riwayat pengajuan izin.',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
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

                                    return _buildHistoryCard(
                                      title: displayTitle,
                                      date: _formatDateRange(
                                        item.startDate,
                                        item.endDate,
                                      ),
                                      duration: _calculateDuration(
                                        item.startDate,
                                        item.endDate,
                                      ),
                                      type: item.jenisLabel.isNotEmpty
                                          ? item.jenisLabel
                                          : 'Izin',
                                      statusLabel: item.statusLabel,
                                      status: cardStatus,
                                      isDark: isDark,
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
    required String duration,
    required String type,
    required String statusLabel,
    required IzinCardStatus status,
    required bool isDark,
  }) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    Color iconColor;

    switch (status) {
      case IzinCardStatus.pending:
        bgColor = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
        borderColor = isDark
            ? const Color(0xFF78350F)
            : const Color(0xFFFDE68A);
        textColor = isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706);
        iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
        break;
      case IzinCardStatus.approved:
        bgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
        borderColor = isDark
            ? const Color(0xFF047857)
            : const Color(0xFFA7F3D0);
        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
        iconColor = isDark ? const Color(0xFF10B981) : const Color(0xFF10B981);
        break;
      case IzinCardStatus.rejected:
        bgColor = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
        borderColor = isDark
            ? const Color(0xFF7F1D1D)
            : const Color(0xFFFECACA);
        textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
        iconColor = isDark ? const Color(0xFFEF4444) : const Color(0xFFEF4444);
        break;
      default:
        bgColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
        borderColor = isDark
            ? const Color(0xFF475569)
            : const Color(0xFFE2E8F0);
        textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mail_outline,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
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
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildTag(duration, isDark),
                    SizedBox(width: 8.w),
                    _buildTag(type, isDark),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: borderColor, width: 1.w),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3.r, backgroundColor: iconColor),
                SizedBox(width: 6.w),
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
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
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
