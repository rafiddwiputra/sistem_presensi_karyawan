import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../bloc/presensi_bloc.dart';
import '../bloc/presensi_event.dart';
import '../bloc/presensi_state.dart';
import '../widgets/konfirmasi_presensi_bottom_sheet.dart';

class PresensiPage extends StatelessWidget {
  const PresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Daftarkan BLoC dan langsung tembak event LoadPresensiData saat halaman dibuka
    return BlocProvider(
      create: (context) => sl<PresensiBloc>()..add(LoadPresensiData()),
      child: const PresensiView(),
    );
  }
}

class PresensiView extends StatefulWidget {
  const PresensiView({super.key});

  @override
  State<PresensiView> createState() => _PresensiViewState();
}

class _PresensiViewState extends State<PresensiView> {
  String _formatTanggal(String? rawDate) {
    if (rawDate == null) return '-';
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color headerBlue = Color(0xFF1961B6);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color mapBgColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFE8EDF2);
    final Color borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF154B8C) : headerBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Absensi Hari ini',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: BlocConsumer<PresensiBloc, PresensiState>(
        listener: (context, state) {
          if (state.status == PresensiStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == PresensiStatus.submitSuccess &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) context.pop();
            });
          }
        },
        builder: (context, state) {
          if (state.status == PresensiStatus.initial ||
              (state.status == PresensiStatus.loading &&
                  state.attendanceData == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = state.attendanceData;
          final isDalamRadius = state.isDalamRadius;
          final isCheckingLokasi =
              state.status == PresensiStatus.locationChecking;

          return Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.65,
                width: double.infinity,
                color: mapBgColor,
                child: Stack(
                  children: [
                    Positioned(
                      top: 100.h,
                      left: 60.w,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isCheckingLokasi
                                  ? Colors.blue
                                  : const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                if (isCheckingLokasi) ...[
                                  SizedBox(
                                    width: 10.w,
                                    height: 10.w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Mencari GPS...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 14.w,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Posisi Anda (${state.jarakMeter}m)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: headerBlue.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: const BoxDecoration(
                                  color: headerBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 16.h,
                right: 16.w,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'btn_location',
                      backgroundColor: isDark
                          ? const Color(0xFF282828)
                          : Colors.white,
                      onPressed: () =>
                          context.read<PresensiBloc>().add(RefreshLokasi()),
                      child: Icon(
                        Icons.my_location,
                        color: headerBlue,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    FloatingActionButton.small(
                      heroTag: 'btn_layers',
                      backgroundColor: isDark
                          ? const Color(0xFF282828)
                          : Colors.white,
                      onPressed: () {},
                      child: Icon(
                        Icons.layers_outlined,
                        color: textSecondary,
                        size: 20.w,
                      ),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.4 : 0.12,
                        ),
                        blurRadius: 20.r,
                        offset: Offset(0, -5.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF333333)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      isCheckingLokasi
                          ? const Center(child: CircularProgressIndicator())
                          : (isDalamRadius
                                ? _buildDalamRadiusCard(
                                    isDark,
                                    state.jarakMeter,
                                  )
                                : _buildLuarRadiusCard(
                                    isDark,
                                    state.jarakMeter,
                                  )),

                      SizedBox(height: 16.h),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF121212)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: borderColor, width: 1.0.w),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: headerBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : headerBlue,
                                      size: 20.w,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Tanggal Presensi',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            _formatTanggal(data?.tanggal),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
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
                            Container(
                              height: 40.h,
                              width: 1.w,
                              color: borderColor,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: headerBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(
                                      Icons.access_time_outlined,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : headerBlue,
                                      size: 20.w,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Jadwal Masuk',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            data?.jadwal.jamMasuk ?? '--:--',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
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
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: headerBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : headerBlue,
                              size: 24.w,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOKASI KANTOR',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  data?.kantor?.nama ?? 'Memuat lokasi...',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),

                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child:
                            (isDalamRadius &&
                                !isCheckingLokasi &&
                                data != null &&
                                !data.presensiSelesai)
                            ? ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<PresensiBloc>(),
                                      child:
                                          const KonfirmasiPresensiBottomSheet(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: headerBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  data.aksiBerikutnya == 'Pulang'
                                      ? 'Pulang Kerja'
                                      : 'Masuk Kerja',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF333333)
                                      : const Color(0xFFE2E8F0),
                                  disabledBackgroundColor: isDark
                                      ? const Color(0xFF333333)
                                      : const Color(0xFFE2E8F0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: 0,
                                ),
                                icon: Icon(
                                  Icons.lock_outline,
                                  color: const Color(0xFF94A3B8),
                                  size: 20.w,
                                ),
                                label: Text(
                                  (data?.presensiSelesai == true)
                                      ? 'Presensi Selesai'
                                      : (data?.aksiBerikutnya == 'Pulang'
                                            ? 'Sudah Presensi Masuk'
                                            : 'Belum Waktunya Presensi'),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLuarRadiusCard(bool isDark, int jarak) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3F2704) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF78350F)
                      : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: isDark
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFD97706),
                  size: 18.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Di Luar Radius',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: isDark
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Lokasi Anda berada di luar area',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? const Color(0xFFFDE68A).withValues(alpha: 0.8)
                            : const Color(0xFF92400E).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                height: 35.h,
                width: 1.w,
                color: isDark
                    ? const Color(0xFF92400E)
                    : const Color(0xFFFDE68A),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$jarak m',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Jarak Anda',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isDark
                          ? const Color(0xFFFDE68A).withValues(alpha: 0.7)
                          : const Color(0xFF92400E).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDalamRadiusCard(bool isDark, int jarak) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0),
          width: 1.0.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 16.w),
          ),
          SizedBox(width: 12.w),
          Text(
            'Dalam Radius',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          Container(
            height: 40.h,
            width: 1.w,
            color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$jarak m',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Jarak Anda',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? const Color(0xFFA7F3D0)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
