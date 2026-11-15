import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/riwayat_state.dart';
import '../bloc/riwayat_bloc.dart';
import '../bloc/riwayat_event.dart';
import '../bloc/riwayat_state.dart';

class RiwayatPresensiPage extends StatelessWidget {
  const RiwayatPresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      sl<RiwayatBloc>()..add(LoadRiwayatRequested(DateTime.now())),
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
  String? _selectedStatusFilter;

  void _loadRiwayat(BuildContext context, DateTime date) {
    if (_selectedStatusFilter != null) {
      setState(() {
        _selectedStatusFilter = null;
      });
    }
    context.read<RiwayatBloc>().add(LoadRiwayatRequested(date));
  }

  String _formatMonthYear(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDateString(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date);
  }

  bool _matchesFilter(String itemStatus, String filter) {
    if (filter == 'Alpha') {
      return itemStatus == 'Tidak Hadir' || itemStatus == 'Alpha';
    }
    return itemStatus == filter;
  }

  Future<void> _pickMonthYear(
      BuildContext context,
      DateTime currentDate,
      bool isDark,
      Color headerBlue,
      ) async {
    final Color primaryColor = isDark
        ? const Color(0xFF60A5FA)
        : headerBlue;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            )
                : ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null &&
        (picked.month != currentDate.month ||
            picked.year != currentDate.year)) {
      if (context.mounted) {
        _loadRiwayat(context, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool canPop = context.canPop();
    final Color bgApp = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8FAFC);
    final Color headerBlue = isDark
        ? const Color(0xFF154B8C)
        : const Color(0xFF135CAE);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: headerBlue,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<RiwayatBloc, RiwayatState>(
            builder: (context, state) {
              DateTime currentDate = DateTime.now();
              final bool isLoading = state is RiwayatLoading;

              if (state is RiwayatLoading) {
                currentDate = state.currentDate;
              } else if (state is RiwayatLoaded) {
                currentDate = state.currentDate;
              } else if (state is RiwayatError) {
                currentDate = state.currentDate;
              }

              return Column(
                children: [
                  // --- 1. HEADER & NAVIGASI PERIODE BULAN/TAHUN ---
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (canPop) ...[
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  color: Colors.transparent,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                            ],
                            Expanded(
                              child: Text(
                                'Riwayat & Rekap Presensi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMonthArrowButton(
                              icon: Icons.chevron_left,
                              enabled: !isLoading,
                              onTap: () {
                                final prevMonth = DateTime(
                                  currentDate.year,
                                  currentDate.month - 1,
                                );
                                _loadRiwayat(context, prevMonth);
                              },
                            ),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => _pickMonthYear(
                                context,
                                currentDate,
                                isDark,
                                headerBlue,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: Colors.white,
                                      size: 16.w,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      _formatMonthYear(currentDate),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white,
                                      size: 18.w,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _buildMonthArrowButton(
                              icon: Icons.chevron_right,
                              enabled: !isLoading,
                              onTap: () {
                                final nextMonth = DateTime(
                                  currentDate.year,
                                  currentDate.month + 1,
                                );
                                _loadRiwayat(context, nextMonth);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- 2. KONTEN UTAMA (REKAPITULASI & LOG HARIAN) ---
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
                      child: _buildBodyContent(
                        context: context,
                        state: state,
                        currentDate: currentDate,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent({
    required BuildContext context,
    required RiwayatState state,
    required DateTime currentDate,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (state is RiwayatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is RiwayatError) {
      return RefreshIndicator(
        onRefresh: () async => _loadRiwayat(context, currentDate),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.all(20.w),
          child: RiwayatErrorCard(
            message: state.message.isNotEmpty
                ? state.message
                : 'Gagal memuat data presensi',
            isDark: isDark,
            onRetry: () => _loadRiwayat(context, currentDate),
          ),
        ),
      );
    }

    if (state is RiwayatLoaded) {
      final filteredList = _selectedStatusFilter == null
          ? state.riwayatList
          : state.riwayatList
          .where(
            (item) => _matchesFilter(item.status, _selectedStatusFilter!),
      )
          .toList();

      return RefreshIndicator(
        onRefresh: () async => _loadRiwayat(context, currentDate),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // --- BAGIAN REKAPITULASI BULANAN ---
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REKAPITULASI PERIODE',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: textSecondary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        if (state.summary.lembur > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF312E81)
                                  : const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.nights_stay,
                                  size: 12.w,
                                  color: isDark
                                      ? const Color(0xFFA5B4FC)
                                      : const Color(0xFF4338CA),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Lembur: ${state.summary.lembur} Hari',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFA5B4FC)
                                        : const Color(0xFF4338CA),
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
                        Expanded(
                          child: _buildStatCard(
                            title: 'Hadir',
                            value: state.summary.hadir.toString(),
                            color: Colors.green,
                            isDark: isDark,
                            isSelected: _selectedStatusFilter == 'Hadir',
                            onTap: () => _toggleFilter('Hadir'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Izin',
                            value: state.summary.izin.toString(),
                            color: Colors.orange,
                            isDark: isDark,
                            isSelected: _selectedStatusFilter == 'Izin',
                            onTap: () => _toggleFilter('Izin'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Cuti',
                            value: state.summary.cuti.toString(),
                            color: Colors.blue,
                            isDark: isDark,
                            isSelected: _selectedStatusFilter == 'Cuti',
                            onTap: () => _toggleFilter('Cuti'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Alpha',
                            value: state.summary.tidakHadir.toString(),
                            color: Colors.red,
                            isDark: isDark,
                            isSelected: _selectedStatusFilter == 'Alpha',
                            onTap: () => _toggleFilter('Alpha'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedStatusFilter == null
                              ? 'RIWAYAT PRESENSI HARIAN'
                              : 'FILTER: ${_selectedStatusFilter!.toUpperCase()} (${filteredList.length})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: textSecondary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        if (_selectedStatusFilter != null)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedStatusFilter = null),
                            child: Text(
                              'Tampilkan Semua',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF135CAE),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // --- BAGIAN DAFTAR RIWAYAT HARIAN ---
            if (filteredList.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: RiwayatEmptyCard(
                    message: _selectedStatusFilter == null
                        ? 'Belum ada data kehadiran bulan ini'
                        : 'Tidak ada data dengan status $_selectedStatusFilter',
                    icon: Icons.event_note_outlined,
                    isDark: isDark,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                sliver: SliverList.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return _buildDetailCard(
                      status: item.status,
                      tanggal: item.tanggal,
                      waktuMasuk: item.waktuMasuk ?? '--:--',
                      waktuKeluar: item.waktuKeluar ?? '--:--',
                      menitTerlambat: item.menitTerlambat ?? 0,
                      isLembur: item.isLembur,
                      subtitle: item.subtitle ?? '',
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  },
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _toggleFilter(String status) {
    setState(() {
      _selectedStatusFilter = _selectedStatusFilter == status ? null : status;
    });
  }

  Widget _buildMonthArrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22.sp),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required bool isDark,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                ? const Color(0xFF333333)
                : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? color
                    : (isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String status,
    required DateTime tanggal,
    required String waktuMasuk,
    required String waktuKeluar,
    required int menitTerlambat,
    required bool isLembur,
    required String subtitle,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final Color statusColor;
    if (status == 'Hadir') {
      statusColor = Colors.green;
    } else if (status == 'Izin') {
      statusColor = Colors.orange;
    } else if (status == 'Cuti') {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.red;
    }

    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE2E8F0);

    final String formattedDate = _formatDateString(tanggal);
    final String jamLembur = isLembur ? 'Ya' : '-';
    final String keterangan = (status == 'Izin' || status == 'Cuti')
        ? (subtitle.isNotEmpty ? subtitle : 'Keterangan tidak tersedia')
        : '';

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
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 16.w,
                      color: isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF135CAE),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: borderColor, height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.login,
                  label: 'Masuk',
                  value: waktuMasuk,
                  iconColor: Colors.green,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.logout,
                  label: 'Keluar',
                  value: waktuKeluar,
                  iconColor: Colors.red,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.warning_amber_rounded,
                  label: 'Terlambat',
                  value: '$menitTerlambat Menit',
                  iconColor: menitTerlambat > 0 ? Colors.orange : textSecondary,
                  valueColor: menitTerlambat > 0
                      ? const Color(0xFFEF4444)
                      : textPrimary,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.nights_stay,
                  label: 'Lembur',
                  value: jamLembur,
                  iconColor: isLembur ? Colors.indigo : textSecondary,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
          if (status == 'Izin' || status == 'Cuti') ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: statusColor.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes, size: 14.w, color: statusColor),
                      SizedBox(width: 6.w),
                      Text(
                        'Keterangan',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    keterangan,
                    style: TextStyle(fontSize: 12.sp, color: textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color textPrimary,
    required Color textSecondary,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: iconColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: textSecondary),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}