import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/lembur_bloc.dart';
import '../bloc/lembur_event.dart';
import '../bloc/lembur_state.dart';

class KonfirmasiLemburBottomSheet extends StatelessWidget {
  final String uuidPengajuan;
  final String namaKaryawan;
  final DateTime tanggalLembur;
  final TimeOfDay jamMulai;
  final TimeOfDay jamSelesai;
  final String alasanLembur;

  const KonfirmasiLemburBottomSheet({
    super.key,
    required this.uuidPengajuan,
    required this.namaKaryawan,
    required this.tanggalLembur,
    required this.jamMulai,
    required this.jamSelesai,
    required this.alasanLembur,
  });

  String _hitungDurasi() {
    int totalMinutes = (jamSelesai.hour * 60 + jamSelesai.minute) - (jamMulai.hour * 60 + jamMulai.minute);
    if (totalMinutes <= 0) totalMinutes += 24 * 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) return '$hours Jam';
    if (hours == 0) return '$minutes Menit';
    return '$hours Jam $minutes Menit';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF135CAE);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color bgLightBlue = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF);
    final Color bgSheet = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color cardBg = isDark ? const Color(0xFF121212) : Colors.white;

    final String tglString = DateFormat('dd MMM yyyy', 'id_ID').format(tanggalLembur);
    final String jamString = '${jamMulai.hour.toString().padLeft(2, '0')}:${jamMulai.minute.toString().padLeft(2, '0')} - ${jamSelesai.hour.toString().padLeft(2, '0')}:${jamSelesai.minute.toString().padLeft(2, '0')} WIB';
    final String durasi = _hitungDurasi();

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 12.h, bottom: MediaQuery.of(context).padding.bottom + 24.h),
        decoration: BoxDecoration(color: bgSheet, borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r))),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 48.w, height: 5.h, decoration: BoxDecoration(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(10.r))),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Container(padding: EdgeInsets.all(4.w), decoration: BoxDecoration(color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9), shape: BoxShape.circle), child: Icon(Icons.close, size: 16.w, color: textSecondary)),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: 72.w, height: 72.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64.w, height: 64.w,
                      decoration: BoxDecoration(color: bgLightBlue, shape: BoxShape.circle, border: Border.all(color: bgSheet, width: 4.w)),
                      child: Icon(Icons.access_time, color: primaryBlue, size: 32.w),
                    ),
                    Positioned(
                      top: 0, right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(color: bgSheet, shape: BoxShape.circle),
                        child: Icon(Icons.verified, color: const Color(0xFF2DD4BF), size: 18.w),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text('Konfirmasi Pengajuan Lembur', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: textPrimary)),
              SizedBox(height: 8.h),
              Text('Periksa kembali detail pengajuan lembur Anda sebelum dikirim.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: textSecondary, height: 1.5)),
              SizedBox(height: 24.h),

              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: cardBg, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: borderColor),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 10.r, offset: Offset(0, 4.h))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 18.w, color: primaryBlue),
                        SizedBox(width: 8.w),
                        Text('Ringkasan Pengajuan', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(color: bgLightBlue, borderRadius: BorderRadius.circular(5.r)),
                          child: Text(durasi, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: primaryBlue)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(color: bgLightBlue, borderRadius: BorderRadius.circular(10.r)),
                          child: Icon(Icons.badge_outlined, color: primaryBlue, size: 20.w),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pemohon Lembur', style: TextStyle(fontSize: 11.sp, color: textSecondary)),
                              SizedBox(height: 2.h),
                              Text(namaKaryawan, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 16.h), child: Divider(color: borderColor, height: 1.h)),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(color: bgLightBlue, borderRadius: BorderRadius.circular(8.r)),
                                child: Icon(Icons.calendar_today_outlined, color: primaryBlue, size: 16.w),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tanggal Lembur', style: TextStyle(fontSize: 11.sp, color: textSecondary)),
                                    SizedBox(height: 2.h),
                                    Text(tglString, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(color: bgLightBlue, borderRadius: BorderRadius.circular(8.r)),
                                child: Icon(Icons.access_time, color: primaryBlue, size: 16.w),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Waktu Lembur', style: TextStyle(fontSize: 11.sp, color: textSecondary)),
                                    SizedBox(height: 2.h),
                                    Text(jamString, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text('ALASAN LEMBUR:', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 0.5)),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity, padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9)),
                      ),
                      child: Text('“$alasanLembur”', style: TextStyle(fontSize: 13.sp, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155), fontStyle: FontStyle.italic, height: 1.5)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: BlocConsumer<LemburBloc, LemburState>(
                  listener: (context, state) {
                    if (state.status == LemburStatus.success) {
                      context.pop();
                      context.pushReplacement('/lembur-berhasil');
                    } else if (state.status == LemburStatus.error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage ?? 'Gagal.'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.status == LemburStatus.submitting) {
                      return ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        child: const CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    return ElevatedButton.icon(
                      onPressed: () {
                        context.read<LemburBloc>().add(SubmitLembur(
                          uuidPengajuan: uuidPengajuan,
                          tanggalLembur: tanggalLembur,
                          jamMulai: jamMulai,
                          jamSelesai: jamSelesai,
                          alasanLembur: alasanLembur,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), elevation: 0,
                      ),
                      icon: Icon(Icons.send_outlined, color: Colors.white, size: 18.w),
                      label: Text('Konfirmasi & Kirim', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity, height: 52.h,
                child: TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                  child: Text('Periksa Kembali', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF475569))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}