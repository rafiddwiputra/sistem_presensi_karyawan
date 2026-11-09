import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../profil/presentation/bloc/profil_bloc.dart';
import '../../../profil/presentation/bloc/profil_state.dart';
import '../bloc/izin_bloc.dart';
import '../bloc/izin_event.dart';
import '../bloc/izin_state.dart';

class KonfirmasiIzinBottomSheet extends StatefulWidget {
  final String jenisIzin;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final String keterangan;
  final File? lampiran;

  const KonfirmasiIzinBottomSheet({
    super.key,
    required this.jenisIzin,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.keterangan,
    this.lampiran,
  });

  @override
  State<KonfirmasiIzinBottomSheet> createState() => _KonfirmasiIzinBottomSheetState();
}

class _KonfirmasiIzinBottomSheetState extends State<KonfirmasiIzinBottomSheet> {
  late final String _uuidPengajuan;

  @override
  void initState() {
    super.initState();
    // Idempotency: Dihasilkan SEKALI saat form konfirmasi dibuka
    _uuidPengajuan = const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    // --- 1. Deklarasi UI dan Tema ---
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color primaryBlue = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);
    final Color bgSheet = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color bgGrey = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FA);
    final Color borderGrey = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color cardBg = isDark ? const Color(0xFF121212) : Colors.white;

    // --- 2. Perhitungan Dinamis ---
    final int durasiHari = widget.tanggalSelesai.difference(widget.tanggalMulai).inDays + 1;
    final String labelTglMulai = DateFormat('dd MMM yyyy').format(widget.tanggalMulai);
    final String hariTglMulai = DateFormat('EEEE', 'id_ID').format(widget.tanggalMulai);
    final String labelTglSelesai = DateFormat('dd MMM yyyy').format(widget.tanggalSelesai);
    final String hariTglSelesai = DateFormat('EEEE', 'id_ID').format(widget.tanggalSelesai);

    String namaFile = '';
    String sizeFile = '';
    if (widget.lampiran != null) {
      namaFile = widget.lampiran!.path.split('/').last;
      final bytes = widget.lampiran!.lengthSync();
      sizeFile = '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    // --- 3. Pengambilan Data Profil (Konsisten dengan arsitektur proyek) ---
    final profilState = context.watch<ProfilBloc>().state;
    final namaKaryawan = profilState is ProfilLoaded
        ? (profilState.user['nama'] as String? ?? 'Karyawan')
        : 'Karyawan';

    // --- 4. Bloc Consumer ---
    return BlocConsumer<IzinBloc, IzinState>(
      listener: (context, state) {
        if (state.status == IzinStatus.success) {
          if (context.canPop()) {
            context.pop();
          }

          context.pushReplacement('/izin-berhasil', extra: {
            'namaKaryawan': namaKaryawan,
            'jenisIzin': widget.jenisIzin,
            'keterangan': widget.keterangan,
            'tanggalMulai': widget.tanggalMulai,
            'tanggalSelesai': widget.tanggalSelesai,
            'namaLampiran': widget.lampiran?.path.split('/').last,
          });
        }

        if (state.status == IzinStatus.error) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              icon: Icon(Icons.warning_amber_rounded, color: const Color(0xFFEF4444), size: 48.w),
              title: Text(
                'Pengajuan Gagal',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: textPrimary),
                textAlign: TextAlign.center,
              ),
              content: Text(
                state.errorMessage ?? 'Terjadi kesalahan pada server. Silakan coba lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: textSecondary, height: 1.5),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: Text('Mengerti', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == IzinStatus.submitting;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgSheet,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 12.h, right: 16.w, left: 16.w),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.close, color: textSecondary, size: 24.w),
                          onPressed: isSubmitting ? null : () => context.pop(),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 64.w,
                          height: 64.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 56.w,
                                height: 56.w,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.assignment_turned_in_outlined, color: primaryBlue, size: 28.w),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(color: bgSheet, shape: BoxShape.circle),
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                                    child: Icon(Icons.check, color: Colors.white, size: 10.w),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Konfirmasi Pengajuan Izin',
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Periksa kembali data pengajuan Anda sebelum\ndikirim ke Admin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.sp, color: textSecondary, height: 1.5),
                        ),
                        SizedBox(height: 24.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: borderGrey),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 10.r, offset: Offset(0, 4.h)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.receipt_long_outlined, color: primaryBlue, size: 18.w),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Ringkasan Pengajuan',
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF),
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    child: Text(
                                      '$durasiHari Hari',
                                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: primaryBlue),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: Divider(color: borderGrey, height: 1.h),
                              ),
                              _buildDetailRow(
                                icon: Icons.medical_services_outlined,
                                label: 'Izin Karena?',
                                value: widget.jenisIzin,
                                isDark: isDark,
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateDetail(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Tanggal Mulai',
                                      date: labelTglMulai,
                                      day: hariTglMulai,
                                      isDark: isDark,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDateDetail(
                                      icon: Icons.event_available_outlined,
                                      label: 'Tanggal Selesai',
                                      date: labelTglSelesai,
                                      day: hariTglSelesai,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Alasan / Catatan Izin',
                                style: TextStyle(fontSize: 11.sp, color: textSecondary),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: bgGrey,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '"${widget.keterangan}"',
                                  style: TextStyle(fontSize: 13.sp, fontStyle: FontStyle.italic, color: textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        if (widget.lampiran != null)
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: borderGrey),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 10.r, offset: Offset(0, 4.h)),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.attach_file, color: primaryBlue, size: 18.w),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Lampiran Bukti Izin',
                                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                                            size: 12.w,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Terlampir',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: bgGrey,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF4C0519) : const Color(0xFFFFE4E6),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(
                                          namaFile.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
                                          color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFFE11D48),
                                          size: 24.w,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              namaFile,
                                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textPrimary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(sizeFile, style: TextStyle(fontSize: 11.sp, color: textSecondary)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.all(4.w),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF0F766E) : const Color(0xFF0D9488),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.check, color: Colors.white, size: 16.w),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 32.h),
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () {
                              final String formattedMulai = DateFormat('yyyy-MM-dd').format(widget.tanggalMulai);
                              final String formattedSelesai = DateFormat('yyyy-MM-dd').format(widget.tanggalSelesai);

                              context.read<IzinBloc>().add(
                                SubmitIzin(
                                  uuidPengajuan: _uuidPengajuan,
                                  jenisIzin: widget.jenisIzin,
                                  tanggalMulai: formattedMulai,
                                  tanggalSelesai: formattedSelesai,
                                  keterangan: widget.keterangan,
                                  lampiran: widget.lampiran,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              disabledBackgroundColor: primaryBlue.withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              elevation: 0,
                            ),
                            icon: isSubmitting ? const SizedBox.shrink() : Icon(Icons.send_outlined, color: Colors.white, size: 18.w),
                            label: isSubmitting
                                ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                                : Text('Konfirmasi & Kirim Izin', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: TextButton(
                            onPressed: isSubmitting ? null : () => context.pop(),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: Text('Periksa Kembali', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: textSecondary)),
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widgets Di Bawah ---
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailingBadge,
    required bool isDark,
  }) {
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color iconBg = isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: textSecondary, size: 20.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11.sp, color: textSecondary)),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? textPrimary,
                    ),
                  ),
                  if (trailingBadge != null) ...[
                    SizedBox(width: 8.w),
                    trailingBadge,
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateDetail({
    required IconData icon,
    required String label,
    required String date,
    required String day,
    required bool isDark,
  }) {
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color primaryBlue = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryBlue, size: 18.w),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10.sp, color: textSecondary)),
            SizedBox(height: 2.h),
            Text(
              date,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            Text(day, style: TextStyle(fontSize: 11.sp, color: textSecondary)),
          ],
        ),
      ],
    );
  }
}