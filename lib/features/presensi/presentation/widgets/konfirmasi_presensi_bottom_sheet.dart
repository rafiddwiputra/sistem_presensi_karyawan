import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../presentation/pages/presensi_berhasil_page.dart';
import '../bloc/presensi_bloc.dart';
import '../bloc/presensi_event.dart';
import '../bloc/presensi_state.dart';
import '../../../../core/utils/date_formatter.dart';

class KonfirmasiPresensiBottomSheet extends StatelessWidget {
  const KonfirmasiPresensiBottomSheet({super.key});

  String _formatTanggal(String? rawDate) {
    if (rawDate == null) return '-';
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return rawDate;
    }
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color primaryBlue = isDark ? const Color(0xFF1961B6) : const Color(0xFF135CAE);
    final Color bgSheet = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return BlocConsumer<PresensiBloc, PresensiState>(
      listener: (context, state) {
        if (state.status == PresensiStatus.submitSuccess) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PresensiBerhasilPage(),
            ),
          );
        }
      },
      builder: (context, state) {
        final data = state.attendanceData;
        final isSubmitting = state.status == PresensiStatus.submitting;
        final aksi = data?.aksiBerikutnya ?? 'Masuk';
        final namaKaryawan = data?.nama ?? '-';

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: bgSheet,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF333333) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 24.h),

                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981), size: 28.w),
                ),
                SizedBox(height: 16.h),

                Text(
                  'Konfirmasi Presensi $aksi',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Pastikan data presensi Anda sudah benar sebelum melanjutkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, color: textSecondary),
                ),
                SizedBox(height: 24.h),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0), width: 1.w),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0),
                            shape: BoxShape.circle
                        ),
                        child: Icon(Icons.check, color: isDark ? Colors.white : const Color(0xFF065F46), size: 12.w),
                      ),
                      SizedBox(width: 12.w),
                      Text('Lokasi Valid', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46))),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF047857) : const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text('${state.jarakMeter} M dari pusat', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46))),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DETAIL PRESENSI',
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: textSecondary),
                  ),
                ),
                SizedBox(height: 12.h),

                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: isDark ? Border.all(color: const Color(0xFF333333), width: 1.w) : null,
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Nama Karyawan', Text(namaKaryawan, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textPrimary)), isDark: isDark),
                      _buildDetailRow('Tanggal Presensi', Text(_formatTanggal(data?.tanggal), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textPrimary)), isDark: isDark),
                      _buildDetailRow('Waktu Presensi', Text('${_getCurrentTime()} WIB', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textPrimary)), isDark: isDark),
                      _buildDetailRow(
                        'Jenis Presensi',
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(4.r)
                          ),
                          child: Text(aksi, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8))),
                        ),
                        isDark: isDark,
                      ),
                      _buildDetailRow('Lokasi Kantor', Text(data?.kantor?.nama ?? '-', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textPrimary)), isLast: true, isDark: isDark),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                      final uuid = state.uuidPresensi;
                      if (uuid == null) return;

                      context.read<PresensiBloc>().add(
                          SubmitPresensi(
                            uuidPresensi: uuid,
                            jenisPresensi: aksi,
                          )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor: primaryBlue.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : Text('Konfirmasi Presensi', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 16.h),

                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: Text('Batalkan', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: textSecondary)),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, Widget valueWidget, {bool isLast = false, required bool isDark}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 12.sp, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
          Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: valueWidget)),
        ],
      ),
    );
  }
}