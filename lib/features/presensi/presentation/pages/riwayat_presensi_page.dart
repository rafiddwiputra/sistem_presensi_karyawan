import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import 'package:intl/intl.dart';

import '../bloc/riwayat_bloc.dart';
import '../bloc/riwayat_event.dart';
import '../bloc/riwayat_state.dart';


class RiwayatPresensiPage extends StatelessWidget {
  const RiwayatPresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RiwayatBloc>()..add(LoadRiwayatRequested(DateTime.now())),
      child: const RiwayatPresensiView(),
    );
  }
}

class RiwayatPresensiView extends StatefulWidget {
  const RiwayatPresensiView({super.key});

  @override
  State<RiwayatPresensiView> createState() => _RiwayatPresensiViewState();
}

class _RiwayatPresensiViewState extends State<RiwayatPresensiView> {

  String _formatMonthYear(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgApp = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color headerBg = isDark ? const Color(0xFF154B8C) : const Color(0xFF1E61B6);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color innerBoxBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F5F9);
    final Color summaryBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F6FF);

    return Scaffold(
      backgroundColor: bgApp,
      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Riwayat Presensi',
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),

      body: BlocBuilder<RiwayatBloc, RiwayatState>(
        builder: (context, state) {

          DateTime currentDate = DateTime.now();
          if (state is RiwayatLoading) currentDate = state.currentDate;
          if (state is RiwayatLoaded) currentDate = state.currentDate;
          if (state is RiwayatError) currentDate = state.currentDate;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                color: bgApp,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMonthNavButton(
                      icon: Icons.chevron_left,
                      isDark: isDark,
                      onTap: () {
                        final newDate = DateTime(currentDate.year, currentDate.month - 1);
                        context.read<RiwayatBloc>().add(LoadRiwayatRequested(newDate));
                      },
                    ),
                    Text(
                      _formatMonthYear(currentDate),
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                    _buildMonthNavButton(
                      icon: Icons.chevron_right,
                      isDark: isDark,
                      onTap: () {
                        final newDate = DateTime(currentDate.year, currentDate.month + 1);
                        context.read<RiwayatBloc>().add(LoadRiwayatRequested(newDate));
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(child: _buildSummaryBox('Hadir', '${state is RiwayatLoaded ? state.summary.hadir : '-'} Hari', summaryBg, textPrimary, textSecondary)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildSummaryBox('Lembur', '${state is RiwayatLoaded ? state.summary.lembur : '-'} Hari', summaryBg, textPrimary, textSecondary)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildSummaryBox('Izin', '${state is RiwayatLoaded ? state.summary.izin : '-'} Hari', summaryBg, textPrimary, textSecondary)),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text('DAFTAR KEHADIRAN', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.0)),
              ),

              SizedBox(height: 12.h),

              // --- LIST KEHADIRAN DINAMIS ---
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<RiwayatBloc>().add(LoadRiwayatRequested(currentDate));
                  },
                  child: _buildListContent(state, isDark, cardBg, innerBoxBg, textPrimary, textSecondary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListContent(RiwayatState state, bool isDark, Color cardBg, Color innerBoxBg, Color textPrimary, Color textSecondary) {
    if (state is RiwayatLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state is RiwayatError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 200),
          Center(
            child: Text(state.message, style: TextStyle(color: Colors.red, fontSize: 14.sp)),
          ),
        ],
      );
    }

    if (state is RiwayatLoaded) {
      if (state.riwayatList.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 200),
            Center(
              child: Text('Belum ada data kehadiran bulan ini.', style: TextStyle(color: textSecondary, fontSize: 14.sp)),
            ),
          ],
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.riwayatList.length,
        itemBuilder: (context, index) {
          final item = state.riwayatList[index];
          final status = item.status;

          IconData iconType;
          Color? iconColor;

          switch (status) {
            case 'Hadir':
              iconType = Icons.check_circle_outline;
              iconColor = null;
              break;
            case 'Izin':
              iconType = Icons.access_time_rounded;
              iconColor = const Color(0xFFF59E0B);
              break;
            case 'Cuti':
              iconType = Icons.beach_access_outlined;
              iconColor = const Color(0xFF3B82F6);
              break;
            case 'Tidak Hadir':
              iconType = Icons.cancel_outlined;
              iconColor = const Color(0xFFEF4444);
              break;
            default:
              iconType = Icons.calendar_today_outlined;
              iconColor = null;
          }

          final formattedDate = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(item.tanggal);

          return _buildAttendanceCard(
            date: formattedDate,
            subtitle: item.subtitle.isNotEmpty ? item.subtitle : null,
            status: status,
            timeIn: item.waktuMasuk,
            timeOut: item.waktuKeluar,
            iconType: iconType,
            iconColor: iconColor,
            isDark: isDark,
            cardBg: cardBg,
            innerBoxBg: innerBoxBg,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          );
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildMonthNavButton({required IconData icon, required bool isDark, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isDark ? Colors.white : const Color(0xFF1E293B), size: 24.sp),
      ),
    );
  }

  Widget _buildSummaryBox(String title, String value, Color bg, Color textPrimary, Color textSecondary) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12.sp, color: textSecondary, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          Text(value, style: TextStyle(fontSize: 14.sp, color: textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  ({Color bg, Color text}) _getStatusColors(String status, bool isDark) {
    switch (status) {
      case 'Hadir':
        return (
        bg: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
        text: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
        );
      case 'Izin':
        return (
        bg: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
        text: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
        );
      case 'Cuti':
        return (
        bg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
        text: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
        );
      case 'Tidak Hadir':
        return (
        bg: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
        text: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
        );
      default:
        return (
        bg: isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9),
        text: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        );
    }
  }

  Widget _buildAttendanceCard({
    required String date,
    String? subtitle,
    required String status,
    required String timeIn,
    required String timeOut,
    required IconData iconType,
    Color? iconColor,
    required bool isDark,
    required Color cardBg,
    required Color innerBoxBg,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final statusColors = _getStatusColors(status, isDark);
    final badgeBg = statusColors.bg;
    final badgeText = statusColors.text;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03), blurRadius: 10.r, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: innerBoxBg, borderRadius: BorderRadius.circular(8.r)),
                child: Icon(iconType, color: iconColor ?? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6)), size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(subtitle, style: TextStyle(fontSize: 12.sp, color: badgeText, fontWeight: FontWeight.w500)),
                    ]
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6.r)),
                child: Text(status, style: TextStyle(color: badgeText, fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(color: innerBoxBg, borderRadius: BorderRadius.circular(12.r)),
            child: Row(
              children: [
                Expanded(child: _buildTimeDetail(icon: Icons.login_rounded, iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6), label: 'Jam Masuk', time: timeIn, textPrimary: textPrimary, textSecondary: textSecondary)),
                Container(width: 1.w, height: 30.h, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                SizedBox(width: 16.w),
                Expanded(child: _buildTimeDetail(icon: Icons.logout_rounded, iconColor: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444), label: 'Jam Selesai', time: timeOut, textPrimary: textPrimary, textSecondary: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDetail({required IconData icon, required Color iconColor, required String label, required String time, required Color textPrimary, required Color textSecondary}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20.sp),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11.sp, color: textSecondary, fontWeight: FontWeight.w500)),
            SizedBox(height: 2.h),
            Text(time, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary)),
          ],
        ),
      ],
    );
  }
}