import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../profil/presentation/bloc/profil_bloc.dart';
import '../../../profil/presentation/bloc/profil_state.dart';
import '../bloc/reimbursement_bloc.dart';
import '../bloc/reimbursement_event.dart';
import '../bloc/reimbursement_state.dart';

class KonfirmasiReimbursementBottomSheet extends StatelessWidget {
  final String tanggal;
  final String keperluan;
  final String nominal;
  final File lampiran;

  const KonfirmasiReimbursementBottomSheet({
    super.key,
    required this.tanggal,
    required this.keperluan,
    required this.nominal,
    required this.lampiran,
  });

  // Helper untuk mendapatkan ukuran file dengan format yang rapi
  String _getFileSizeString(File file) {
    final int bytes = file.lengthSync();
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // Helper untuk format Rupiah
  String _formatRupiah(String amount) {
    try {
      final value = double.parse(amount.replaceAll('.', '').replaceAll(',', ''));
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    } catch (e) {
      return 'Rp $amount';
    }
  }

  // Helper untuk format tanggal dari backend YYYY-MM-DD ke format UI
  String _formatTanggalUI(String backendDate) {
    try {
      final date = DateTime.parse(backendDate);
      const List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return backendDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ambil nama karyawan dinamis dari ProfilBloc
    final profilState = context.watch<ProfilBloc>().state;
    final String namaKaryawan = profilState is ProfilLoaded
        ? (profilState.user['nama'] as String? ?? 'Karyawan')
        : 'Karyawan';

    // Definisi Warna Dinamis
    final Color bgSheet = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color cardBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color primaryBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF0B56A6);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color iconBgLight = isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9);
    final Color highlightBlueBg = isDark
        ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
        : const Color(0xFFEFF6FF);

    return BlocBuilder<ReimbursementBloc, ReimbursementState>(
      builder: (context, state) {
        final bool isLoading = state.status == ReimbursementStatus.loading;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgSheet,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  top: 12.h,
                  bottom: 20.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Handle Bar
                    Container(
                      width: 48.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // 2. Header Ikon & Tombol Close
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: SizedBox(
                              width: 64.w,
                              height: 64.w,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 64.w,
                                    height: 64.w,
                                    decoration: BoxDecoration(
                                      color: highlightBlueBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.receipt_long,
                                      color: primaryBlue,
                                      size: 32.sp,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        color: primaryBlue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: bgSheet,
                                          width: 2.w,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: isLoading ? null : () => context.pop(),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: iconBgLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: textSecondary,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    Text(
                      'Konfirmasi Pengajuan\nReimbursement',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Periksa kembali detail pengeluaran Anda sebelum\nmengirim pengajuan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // 3. Ringkasan Data & Aksi
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Kartu Rincian Pengajuan
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.5.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.02,
                                    ),
                                    blurRadius: 15.r,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nominal Pengajuan',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: textSecondary,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            _formatRupiah(nominal),
                                            style: TextStyle(
                                              fontSize: 24.sp,
                                              fontWeight: FontWeight.bold,
                                              color: primaryBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: highlightBlueBg,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.payments_outlined,
                                          color: primaryBlue,
                                          size: 24.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildListItem(
                                    icon: Icons.person_outline,
                                    title: 'Pemohon',
                                    value: namaKaryawan,
                                    isDark: isDark,
                                  ),
                                  _buildListItem(
                                    icon: Icons.calendar_today_outlined,
                                    title: 'Tanggal Transaksi',
                                    value: _formatTanggalUI(tanggal),
                                    isDark: isDark,
                                  ),
                                  _buildListItem(
                                    icon: Icons.category_outlined,
                                    title: 'Keperluan Pengeluaran',
                                    value: keperluan,
                                    hideDivider: true,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Kartu Lampiran Bukti Transaksi
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.5.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.02,
                                    ),
                                    blurRadius: 15.r,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_file,
                                        color: primaryBlue,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Lampiran Bukti Transaksi',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF064E3B)
                                              : const Color(0xFFCCFBF1),
                                          borderRadius: BorderRadius.circular(8.r),
                                          border: isDark
                                              ? Border.all(color: const Color(0xFF047857))
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: isDark
                                                  ? const Color(0xFF34D399)
                                                  : const Color(0xFF0F766E),
                                              size: 14.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Terlampir',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? const Color(0xFF34D399)
                                                    : const Color(0xFF0F766E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1A1A1A)
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF282828)
                                            : const Color(0xFFF1F5F9),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10.w),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF450A0A)
                                                : const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(10.r),
                                          ),
                                          child: Icon(
                                            lampiran.path.toLowerCase().endsWith('.pdf')
                                                ? Icons.picture_as_pdf_outlined
                                                : Icons.image_outlined,
                                            color: isDark
                                                ? const Color(0xFFF87171)
                                                : const Color(0xFFEF4444),
                                            size: 24.sp,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lampiran.uri.pathSegments.last,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: textPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                _getFileSizeString(lampiran),
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Icon(
                                          Icons.check_circle,
                                          color: isDark
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF047857),
                                          size: 28.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 32.h),

                            // Tombol Konfirmasi & Kirim (Memicu BLoC)
                            SizedBox(
                              width: double.infinity,
                              height: 52.h,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                  context.read<ReimbursementBloc>().add(
                                    SubmitReimbursement(
                                      tanggal: tanggal,
                                      keperluan: keperluan,
                                      nominal: nominal,
                                      lampiran: lampiran,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFF1E61B6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Konfirmasi & Kirim',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.send_outlined,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // Tombol Periksa Kembali
                            SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: TextButton(
                                onPressed: isLoading ? null : () => context.pop(),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'Periksa Kembali',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String value,
    bool hideDivider = false,
    required bool isDark,
  }) {
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color iconBgLight = isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9);

    return Padding(
      padding: EdgeInsets.only(bottom: hideDivider ? 0 : 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconBgLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: textSecondary, size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11.sp, color: textSecondary),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
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